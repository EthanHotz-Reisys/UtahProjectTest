global class MSPMainCreateAndAmendBatch implements Database.Batchable<sObject>, Database.Stateful {
    public String query;
    public List<String> errors;
    public FileBatch__c fb;

    global MSPMainCreateAndAmendBatch(FileBatch__c fb){
        this.fb = fb;
        errors = new List<String>();
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        try{
            query = 'SELECT Id, Program__c, SubRecipient__c, AwardAmount__c, FileBatch__r.FiscalYear__c, DisplayOrder__c, ObjectCode__c, ProgramCode__c, UniqueKeyFormula__c, ProgramComment__c, LEAComment__c FROM MSPFinancialStage__c WHERE FileBatch__c = \'' + fb.Id + '\'';
            return Database.getQueryLocator(query);
        }catch(Exception e){
            errors.add(e.getMessage());
            return null;
        }
    }

    global void execute(Database.BatchableContext BC, List<MSPFinancialStage__c> scope){
        Savepoint sp = Database.setSavepoint();
        if(scope == null){
            return;
        }

        try{
            if(fb.ActionType__c == 'Create'){
                List<MSPFinancialMain__c> mfms = new List<MSPFinancialMain__c>();

                for(MSPFinancialStage__c mfs : scope){
                    MSPFinancialMain__c temp = new MSPFinancialMain__c(
                        Program__c = mfs.Program__c,
                        SubRecipient__c = mfs.SubRecipient__c,
                        AwardAmount__c = mfs.AwardAmount__c,
                        FiscalYear__c = mfs.FileBatch__r.FiscalYear__c,
                        DisplayOrder__c = mfs.DisplayOrder__c,
                        ObjectCode__c = mfs.ObjectCode__c,
                        ProgramCode__c = mfs.ProgramCode__c,
                        ProgramComment__c = mfs.ProgramComment__c,
                        LEAComment__c = mfs.LEAComment__c
                    );
                    mfms.add(temp);
                }

                if(mfms.size() > 0){
                    insert mfms;
                }

            }else if(fb.ActionType__c == 'Amend'){
                List<MSPFinancialMain__c> mfms = [SELECT Id, AwardAmount__c, UniqueKeyFormula__c, ProgramComment__c, LEAComment__c FROM MSPFinancialMain__c WHERE FiscalYear__c = :fb.FiscalYear__c];
                Map<String, MSPFinancialMain__c> mainMap = new Map<String, MSPFinancialMain__c>();

                for(MSPFinancialMain__c mfm : mfms){
                    mainMap.put(mfm.UniqueKeyFormula__c, mfm);
                }

                List<MSPFinancialMain__c> upsertmfms = new List<MSPFinancialMain__c>();

                for(MSPFinancialStage__c mfs : scope){
                    MSPFinancialMain__c mfm = mainMap.get(mfs.UniqueKeyFormula__c);

                    if(mfm == null){
                        MSPFinancialMain__c temp = new MSPFinancialMain__c(
                            Program__c = mfs.Program__c,
                            SubRecipient__c = mfs.SubRecipient__c,
                            AwardAmount__c = mfs.AwardAmount__c,
                            FiscalYear__c = mfs.FileBatch__r.FiscalYear__c,
                            DisplayOrder__c = mfs.DisplayOrder__c,
                            ObjectCode__c = mfs.ObjectCode__c,
                            ProgramCode__c = mfs.ProgramCode__c,
                            ProgramComment__c = mfs.ProgramComment__c,
                            LEAComment__c = mfs.LEAComment__c                           
                        );
                        upsertmfms.add(temp);
                    }else if(mfm.AwardAmount__c != mfs.AwardAmount__c){
                        mfm.AwardAmount__c = mfs.AwardAmount__c;
                        mfm.ProgramComment__c = mfs.ProgramComment__c;
                        mfm.LEAComment__c = mfs.LEAComment__c;
                        upsertmfms.add(mfm);
                    }
                }

                if(upsertmfms.size() > 0){
                    upsert upsertmfms;
                }
            }

        }catch(Exception e){
            errors.add(e.getMessage());
            Database.rollback(sp);
            return;
        }
    }

    global void finish(Database.BatchableContext BC){
        if(errors.size() == 0){
            fb.Status__c = 'Approved';
            update fb;
        }else{
            for(String err : errors){
                fb.ErrorLog__c =  fb.ErrorLog__c + ';' + err;
            }
            fb.Status__c = 'Error';
            update fb;          
        }
    }

    public class MyException extends Exception{}

}