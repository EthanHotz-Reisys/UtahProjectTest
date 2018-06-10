public with sharing class AwardFinetCodeTriggerHelper extends GNT.TriggerHelper {
    public static Boolean skipTrigger = false;
    private String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');

    public override void processBeforeInsert() {
        system.debug('--skipTrigger--' + skipTrigger);
        if (skipTrigger == false) {
            if (appName == null || appName == 'StateasGrantor') {
                List<AwardFinetCode__C> finetCodes =  (List<AwardFinetCode__C>) Trigger.New;
                populateOldAmounts(finetCodes);
            }
        }
    }

    void populateOldAmounts(List<AwardFinetCode__C> finetCodes) {
        Map<string, AwardFinetCode__C> finetMap = new Map<string, AwardFinetCode__C>();
        for (AwardFinetCode__C finet : finetCodes) {
            finetMap.put(finet.MSPUniqueKeyFormula__c, finet);
        }
        Id awardId = finetCodes[0].Award__c;
        Award__c tempAward = [SELECT Id, GrantorOrganization__c, Grant__r.USBEPathway__c, Grant__r.Program__c, Grant__r.FiscalYear__c from Award__C where id = :awardId];
        String fiscalYear =  tempAward.Grant__r.FiscalYear__c;// '2018';
        String pathWay = tempAward.Grant__r.USBEPathway__c;
        String grantorOrganization = tempAward.GrantorOrganization__c;

        if (fiscalYear != null && pathWay != null && grantorOrganization != null && grantorOrganization == 'USBE') {
            List<Award__c> awardList = [SELECT Id, Grant__r.InternalOrganization__c, Grant__r.Program__c, Grant__c, Grant__r.NumberofAwards__c, (SELECT Id, MSPUniqueKeyFormula__c, Amount__c, Award__r.Grant__c, Award__r.Grant__r.NumberofAwards__c FROM Award_FINET_Codes__r) FROM Award__c WHERE Grant__r.USBEPathway__c = :pathWay  AND Grant__r.FiscalYear__c = :fiscalYear AND Status__c = 'Activated'];
            Map<String, AwardFINETCode__c> existingFinetMap = new Map<String, AwardFINETCode__c>();
            Map<String, Award__c> awardMap = new Map<String, Award__c>();
            for (Award__c award : awardList) {
                awardMap.put(award.Grant__r.InternalOrganization__c + '_' + award.Grant__r.Program__c, award);
                for (AwardFINETCode__c afc : award.Award_FINET_Codes__r) {
                    existingFinetMap.put(afc.MSPUniqueKeyFormula__c, afc);
                }
            }
            system.debug('finetmap >>>' + finetMap);
            system.debug('existing finetmap >>>' + existingFinetMap);

            for (string key : finetMap.keySet()) {
                AwardFinetCode__C existingFinetCode = existingFinetMap.get(key);
                AwardFinetCode__C finetCode = finetMap.get(key);
                if (existingFinetCode != null && finetCode != null && finetCode.OldAmount__c == null && existingFinetCode.Amount__c != null) {
                    finetCode.OldAmount__c =  existingFinetCode.Amount__c;
                    //finetCode.RemainingAmount__c =
                    system.debug('result >>>' + finetCode);
                }
            }
        }
    }



}