global class MSPGrantCreateAndAmendValidateBatch implements Database.Batchable<sObject>, Database.Stateful {

    public String query;
    public List<String> errors;
    public FileBatch__c fb;
    public Set<String> amendGrantIdSet;
    public List<String> finetCodeSet;
    public Integer index;

    global MSPGrantCreateAndAmendValidateBatch(FileBatch__c fb, List<String> finetCodeSet, Integer index) {
        this.fb = fb;
        this.finetCodeSet = finetCodeSet;
        this.index = index;
        errors = new List<String>();
        amendGrantIdSet = new Set<String>();
    }

    global MSPGrantCreateAndAmendValidateBatch(FileBatch__c fb, List<String> finetCodeSet, Integer index, List<String> errors, Set<String> amendGrantIdSet) {
        this.fb = fb;
        this.finetCodeSet = finetCodeSet;
        this.index = index;
        this.errors = errors;
        this.amendGrantIdSet = amendGrantIdSet;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        try {
            query = 'SELECT Id, SubRecipient__r.LEA_Id__c, Program__r.ProgramKey__c, AwardAmount__c, DisplayOrder__c, ObjectCode__c, Program__c, ProgramCode__c, SubRecipient__c, UniqueKeyFormula__c, AwardAmountFormula__c, ProgramComment__c, LEAComment__c, DeltaAmount__c FROM MSPFinancialStage__c WHERE FileBatch__c = \'' + fb.Id + '\' AND ProgramCode__c = \'' + finetCodeSet[index] + '\' ORDER BY SubRecipient__r.LEA_Id__c';
            return Database.getQueryLocator(query);
        } catch (Exception e) {
            errors.add(e.getMessage());
            return null;
        }
    }
    
    global void execute(Database.BatchableContext BC, List<MSPFinancialStage__c> scope) {
        Savepoint sp = Database.setSavepoint();
        if (scope == null) {
            return;
        }

        Map<String, AwardFINETCode__c> afcMap = new Map<String, AwardFINETCode__c>();
        try {
            List<Award__c> awardList = [SELECT Id, Grant__r.InternalOrganization__c, Grant__r.Program__c, Grant__c, Grant__r.NumberofAwards__c, (SELECT Id, MSPUniqueKeyFormula__c, Amount__c, Award__r.Grant__c, Award__r.Grant__r.NumberofAwards__c FROM Award_FINET_Codes__r) FROM Award__c WHERE Grant__r.USBEPathway__c = :fb.RecordType.Name AND Grant__r.FiscalYear__c = :fb.FiscalYear__c AND Status__c = 'Activated'];
            Map<String, Award__c> awardMap = new Map<String, Award__c>();
            for (Award__c award : awardList) {
                awardMap.put(award.Grant__r.InternalOrganization__c + '_' + award.Grant__r.Program__c, award);
                for (AwardFINETCode__c afc : award.Award_FINET_Codes__r) {
                    afcMap.put(afc.MSPUniqueKeyFormula__c, afc);
                }
            }

            Map<String, List<MSPFinancialStage__c>> mfmMap = new Map<String, List<MSPFinancialStage__c>>();
            for (MSPFinancialStage__c mfm : scope) {
                if (mfmMap.get(mfm.SubRecipient__c + '_' + mfm.Program__c) == null) {
                    List<MSPFinancialStage__c> tempList = new List<MSPFinancialStage__c>();
                    mfmMap.put(mfm.SubRecipient__c + '_' + mfm.Program__c, tempList);
                }
                mfmMap.get(mfm.SubRecipient__c + '_' + mfm.Program__c).add(mfm);
            }

            User currentUser = [SELECT Id, Organization__c FROM User WHERE Id = :UserInfo.getUserId()];
            List<String> newKeyList = new List<String>();
            List<Award__c> newMSPAwards = new List<Award__c>();
            List<Grant__c> newMSPGrants = new List<Grant__c>();
            for (String key : mfmMap.keySet()) {
                if (!awardMap.containsKey(key)) {
                    newKeyList.add(key);
                } else {
                    List<AwardFINETCode__c> oldAfcList = awardMap.get(key).Award_FINET_Codes__r;
                    Map<String, AwardFINETCode__c> oldAfcKeyMap = new Map<String, AwardFINETCode__c>();
                    for (AwardFINETCode__c afc : oldAfcList) {
                        oldAfcKeyMap.put(afc.MSPUniqueKeyFormula__c, afc);
                    }

                    for (MSPFinancialStage__c mfm : mfmMap.get(key)) {
                        if ((!oldAfcKeyMap.containsKey(mfm.UniqueKeyFormula__c) || oldAfcKeyMap.get(mfm.UniqueKeyFormula__c).Amount__c != mfm.AwardAmountFormula__c) && !amendGrantIdSet.contains(awardMap.get(key).Grant__c)) {
                            amendGrantIdSet.add(awardMap.get(key).Grant__c);
                            Award__c temp = new Award__c(
                                Grant__c = awardMap.get(key).Grant__c,
                                VersionNumber__c = awardMap.get(key).Grant__r.NumberofAwards__c + 1,
                                USBEPathway__c = fb.RecordType.Name,
                                Status__c = 'Activated'
                            );
                            newMSPAwards.add(temp);
                        }
                    }
                }
            }

            Map<Id, Program__c> pMap = new Map<Id, Program__c>([SELECT Id, ProgramKey__c FROM Program__c]);
            Map<Id, Account> aMap = new Map<Id, Account>([SELECT Id, LEA_Id__c FROM Account]);
            for (String newKey : newKeyList) {
                String[] str = newKey.split('_');
                Grant__c temp = new Grant__c(
                    Name = fb.RecordType.Name + ' GT-' + pMap.get(str[1]).ProgramKey__c + '-' + aMap.get(str[0]).LEA_Id__c + '-' + fb.FiscalYear__c,
                    FiscalYear__c = fb.FiscalYear__c,
                    InternalOrganization__c = str[0],
                    Program__c = str[1],
                    ExternalOrganization__c = currentUser.Organization__c,
                    USBEPathway__c = fb.RecordType.Name,
                    Status__c = 'Active'
                );
                newMSPGrants.add(temp);
            }

            insert newMSPGrants;
            for (Grant__c newGrant : newMSPGrants) {
                amendGrantIdSet.add(newGrant.Id);
            }

            List<Grant__c> mgs = [SELECT Id, Name, NumberofAwards__c, USBEPathway__c FROM Grant__c WHERE Id IN :newMSPGrants];
            for (Grant__c mg : mgs) {
                Award__c temp = new Award__c(
                    Name = fb.RecordType.Name + ' AD-' + mg.Name.substring(6) + '-' + String.valueOf(mg.NumberofAwards__c + 1),
                    Grant__c = mg.Id,
                    VersionNumber__c = mg.NumberofAwards__c + 1,
                    USBEPathway__c = mg.USBEPathway__c,
                    Status__c = 'Activated'
                );
                newMSPAwards.add(temp);
            }

            insert newMSPAwards;
            List<Id> programIdList = new List<Id>();
            List<Id> subIdList = new List<Id>();
            List<Award__c> newAwardList = [SELECT Id, Grant__r.InternalOrganization__c, Grant__r.Program__c, ObligatedAwardAmount__c FROM Award__c WHERE Id IN :newMSPAwards];
            for (Award__c a : newAwardList) {
                programIdList.add(a.Grant__r.Program__c);
                subIdList.add(a.Grant__r.InternalOrganization__c);
            }

            List<MSPFinancialStage__c> amendMfmList = [SELECT Id, ProgramCode__c, ObjectCode__c, AwardAmountFormula__c, SubRecipient__c, Program__c, DeltaAmount__c, UniqueKeyFormula__c FROM MSPFinancialStage__c WHERE Program__c IN : programIdList AND SubRecipient__c IN : subIdList AND FileBatch__c = :fb.Id];
            List<String> programCodeList = new List<String>();
            List<String> objectCodeList = new List<String>();
            Map<String, List<MSPFinancialStage__c>> amendMfmMap = new Map<String, List<MSPFinancialStage__c>>();
            for (MSPFinancialStage__c mfm : amendMfmList) {
                if (amendMfmMap.get(mfm.SubRecipient__c + '_' + mfm.Program__c) == null) {
                    List<MSPFinancialStage__c> tempList = new List<MSPFinancialStage__c>();
                    amendMfmMap.put(mfm.SubRecipient__c + '_' + mfm.Program__c, tempList);
                }
                amendMfmMap.get(mfm.SubRecipient__c + '_' + mfm.Program__c).add(mfm);
                programCodeList.add(mfm.ProgramCode__c);
                objectCodeList.add(mfm.ObjectCode__c);
            }

            Map<String, Award__c> amendAwardMap = new Map<String, Award__c>();
            for (Award__c award : newAwardList) {
                amendAwardMap.put(award.Grant__r.InternalOrganization__c + '_' + award.Grant__r.Program__c, award);
            }

            List<r_prog__c> programCode = [SELECT Id, PROG_CD__c FROM r_prog__c WHERE PROG_CD__c IN :programCodeList];
            List<r_obj__c> objectCode = [SELECT Id, OBJ_CD__c FROM r_obj__c WHERE OBJ_CD__c IN :objectCodeList];
            Map<String, Id> programCodeMap = new Map<String, Id>();
            Map<String, Id> objectCodeMap = new Map<String, Id>();

            for (r_prog__c pc : programCode) {
                programCodeMap.put(pc.PROG_CD__c, pc.Id);
            }

            for (r_obj__c oc : objectCode) {
                objectCodeMap.put(oc.OBJ_CD__c, oc.Id);
            }

            Map<String, Double> amountMap = new Map<String, Double>();
            List<AwardFINETCode__c> newAfcList = new List<AwardFINETCode__c>();
            for (String key : amendMfmMap.keySet()) {
                if (amendAwardMap.get(key) == null) {
                    continue;
                }
                Double total = 0.00;
                for (MSPFinancialStage__c mfm : amendMfmMap.get(key)) {
                    AwardFINETCode__c temp = new AwardFINETCode__c(
                        ProgramCode__c = programCodeMap.get(mfm.ProgramCode__c),
                        ObjectCode__c = objectCodeMap.get(mfm.ObjectCode__c),
                        Amount__c = mfm.AwardAmountFormula__c,
                        Award__c = amendAwardMap.get(key).Id,
                        DeltaAmount__c = afcMap.get(mfm.UniqueKeyFormula__c) == null ? mfm.AwardAmountFormula__c : mfm.AwardAmountFormula__c - afcMap.get(mfm.UniqueKeyFormula__c).Amount__c,
                        OldAmount__c = afcMap.get(mfm.UniqueKeyFormula__c) == null ? 0 : afcMap.get(mfm.UniqueKeyFormula__c).Amount__c
                    );
                    newAfcList.add(temp);
                    total = total + temp.Amount__c;
                }
                amountMap.put(key, total);
            }

            insert newAfcList;
            for (String key : amountMap.keySet()) {
                amendAwardMap.get(key).ObligatedAwardAmount__c = amountMap.get(key);
            }

            update amendAwardMap.values();

        } catch (Exception e) {
            errors.add(e.getMessage() + ':::' + e.getStackTraceString() + ':::' + e.getLineNumber() + ':::' + e.getCause());
        }
        Database.rollback(sp);
        for (MSPFinancialStage__c mfs : scope) {
            mfs.DeltaAmount__c = afcMap.get(mfs.UniqueKeyFormula__c) == null ? mfs.AwardAmountFormula__c : mfs.AwardAmountFormula__c - afcMap.get(mfs.UniqueKeyFormula__c).Amount__c;
            mfs.OldAwardedAmount__c = mfs.AwardAmountFormula__c - mfs.DeltaAmount__c;
        }
        update scope;
    }

    global void finish(Database.BatchableContext BC) {
        if(index == finetCodeSet.size() - 1){
            if (errors.size() == 0) {
                Database.executeBatch(new GCAMProgramPhaseCreationBatch(fb, finetCodeSet), 1);
                //Database.executeBatch(new MSPGrantAndAwardCreateAndAmendBatch(fb, finetCodeSet, 0), 200);
            } else {
                for (String err : errors) {
                    fb.ErrorLog__c =  fb.ErrorLog__c + ';' + err;
                }

                fb.Status__c = 'Error';
                update fb;
            }
        }else{
            index++;
            Database.executeBatch(new MSPGrantCreateAndAmendValidateBatch(fb, finetCodeSet, index, errors, amendGrantIdSet), 200);
        }
    }
}