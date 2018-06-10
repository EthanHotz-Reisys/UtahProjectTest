public with sharing class MSPFileBatchProcess implements FileBatchProcess{
    public Map<String, String> getData(FileBatch__c fb){
        Map<String, String> results = new Map<String, String>();
        List<AwardFINETCode__c> fms = [SELECT Award__r.Grant__r.Program__r.ProgramName__c, Award__r.Grant__r.InternalOrganization__r.Name, Award__r.Grant__r.InternalOrganization__r.LEA_Id__c, Amount__c, MSPUniqueKeyFormula__c, ProgramCode__c, ObjectCode__c FROM AwardFINETCode__c WHERE Award__r.Grant__r.FiscalYear__c =:fb.FiscalYear__c AND Award__r.Grant__r.USBEPathway__c = :fb.recordType.Name AND Award__r.Status__c = 'Activated' ORDER BY DisplayOrder__c];
        List<MSPFinancialStage__c> fs = [SELECT Program__r.ProgramName__c, SubRecipient__r.Name, SubRecipient__r.LEA_Id__c, AwardAmount__c, UniqueKeyFormula__c, ProgramCode__c, ObjectCode__c FROM MSPFinancialStage__c WHERE FileBatch__c =:fb.Id ORDER BY DisplayOrder__c];
        Map<String, String> keyAmountMap = new Map<String, String>();
        for(AwardFINETCode__c fm : fms){
            keyAmountMap.put(fm.MSPUniqueKeyFormula__c, String.valueOf(fm.Amount__c));
        }

        List<AwardWrapper> stageWrapper = new List<AwardWrapper>();
        for(MSPFinancialStage__c f : fs){
            AwardWrapper temp = new AwardWrapper();
            temp.programName = f.Program__r.ProgramName__c;
            temp.subRecipientName = f.SubRecipient__r.Name;
            temp.awardAmount = f.AwardAmount__c;
            temp.uniqueKeyFormula = f.UniqueKeyFormula__c;
            temp.programCode = f.ProgramCode__c;
            temp.objectCode = f.ObjectCode__c;
            temp.leaId = f.SubRecipient__r.LEA_Id__c;
            temp.oldAwardAmount = keyAmountMap.get(f.UniqueKeyFormula__c) == null ? '0' : keyAmountMap.get(f.UniqueKeyFormula__c);
            stageWrapper.add(temp);
        }
        
        List<AwardWrapper> mainWrapper = new List<AwardWrapper>();
        /*
        for(AwardFINETCode__c fm : fms){
                AwardWrapper temp = new AwardWrapper();
                temp.programName = fm.Award__r.Grant__r.Program__r.ProgramName__c;
                temp.subRecipientName = fm.Award__r.Grant__r.InternalOrganization__r.Name;
                temp.awardAmount = String.valueOf(fm.Amount__c);
                temp.uniqueKeyFormula = fm.MSPUniqueKeyFormula__c;
                temp.programCode = fm.ProgramCode__c;
                temp.objectCode = fm.ObjectCode__c;
                temp.leaId = fm.Award__r.Grant__r.InternalOrganization__r.LEA_Id__c;
                mainWrapper.add(temp);
        }
        */
        System.debug('----------------->' + stageWrapper.size());
        System.debug('----------------->' + mainWrapper.size());
        results.put('stageJSON', JSON.serialize(stageWrapper));
        results.put('mainJSON', JSON.serialize(mainWrapper));
        return results;
    }

    public Map<String, List<String>> approve(FileBatch__c fbOld){
        Map<String, List<String>> results = new Map<String, List<String>>();
        results.put('Error', new List<String>());
        FileBatch__c fb = [SELECT Id, ActionType__c, FirstApprover__c, SecondApprover__c, FiscalYear__c, Status__c, RecordType.Name, ErrorLog__c FROM FileBatch__c WHERE Id = :fbOld.Id];
        if(fb.FirstApprover__c == UserInfo.getUserId() && fb.Status__c == 'Processed'){
            List<FileBatch__c> fbsSameYear = [SELECT Id FROM FileBatch__c WHERE FiscalYear__c = :fb.FiscalYear__c AND Id != :fb.Id AND Status__c IN ('Active') AND RecordType.Name = :fb.RecordType.Name];
            if(fbsSameYear.size() > 0 && fb.ActionType__c == 'Create'){
                results.get('Error').add('One create batch already active for this year');
                return results;
            }

            List<FileBatch__c> fbsApprovedSameYear = [SELECT Id FROM FileBatch__c WHERE FiscalYear__c = :fb.FiscalYear__c AND Id != :fb.Id AND Status__c IN ('Sent for Activation') AND RecordType.Name = :fb.RecordType.Name];
            if(fbsApprovedSameYear.size() > 0 && fb.ActionType__c == 'Amend'){
                results.get('Error').add('One amend batch already approved for this year');
                return results;
            }

            List<MSPFinancialStage__c> mfss = [SELECT Id, UniqueKeyFormula__c FROM MSPFinancialStage__c WHERE FileBatch__c = :fb.Id];
            List<AwardFINETCode__c> mfms = [SELECT Id, MSPUniqueKeyFormula__c FROM AwardFINETCode__c WHERE Award__r.Grant__r.FiscalYear__c =:fb.FiscalYear__c AND Award__r.Grant__r.USBEPathway__c = :fb.recordType.Name AND Award__r.Status__c = 'Activated'];
            List<String> validateStagingDataResult = validateStagingData(mfss);
            if(validateStagingDataResult.size() > 0){
                for(String str : validateStagingDataResult){    
                    results.get('Error').add('Duplicate unique key in Excel: ' + str);
                }
                return results;
            }

            if(!validateStaingMainMap(mfss, mfms) && fb.ActionType__c == 'Amend'){
                results.get('Error').add('Award is missing in Excel');
                return results;
            }

            //Database.executeBatch(new MSPMainCreateAndAmendBatch(fb), 200);
            updateBatchApprovalTask(fb);
            createAwardCreationTask(fb);
            fb.Status__c = 'Sent for Activation';
            update fb;
        }else if(fb.SecondApprover__c == UserInfo.getUserId() && fb.Status__c == 'Sent for Activation' && fb.ActionType__c != null){
            List<MSPFinancialStage__c> mfss = [SELECT Id, ProgramCode__c FROM MSPFinancialStage__c WHERE FileBatch__c = :fb.Id];
            List<String> finetCodeList = new List<String>();
            for(MSPFinancialStage__c mfs : mfss){
                if(!finetCodeList.contains(mfs.ProgramCode__c)){
                    finetCodeList.add(mfs.ProgramCode__c);
                }
            }
            finetCodeList.sort();
            Database.executeBatch(new MSPGrantCreateAndAmendValidateBatch(fb, finetCodeList, 0), 200);
            updateAwardCreationTask(fb);
            fb.Status__c = 'Processing';
            update fb;
        }else{
            results.get('Error').add('Please refresh page');
        }
        return results;
    }

    public Map<String, List<String>> reject(FileBatch__c fbOld){
        Map<String, List<String>> results = new Map<String, List<String>>();
        results.put('Error', new List<String>());
        FileBatch__c fb = [SELECT Id, ActionType__c, FirstApprover__c, SecondApprover__c, FiscalYear__c, Status__c, RecordType.Name FROM FileBatch__c WHERE Id = :fbOld.Id];
        if(fb.FirstApprover__c == UserInfo.getUserId() && fb.Status__c == 'Processed'){
            updateBatchApprovalTask(fb);
            fb.Status__c = 'Rejected';
        }else if(fb.SecondApprover__c == UserInfo.getUserId() && fb.Status__c == 'Sent for Activation'){
            updateAwardCreationTask(fb);
            fb.Status__c = 'Rejected';
        }else{
            results.get('Error').add('Please refresh page');
        }
        update fb;
        return results;
    }


    private void createAwardCreationTask(FileBatch__c fb){
        List<Task> awardCreationApprovalTask = GNT.TaskCreationHandler.createTasks(fb.SecondApprover__c,
            fb.Id,'MSP Award Creation Approval',
            fb.FiscalYear__c + ' ' + fb.ActionType__c, null, false, null,
            'Approval', fb.FiscalYear__c + ' ' + fb.ActionType__c, false
        );

        if(awardCreationApprovalTask != null && awardCreationApprovalTask.size() > 0) {
            insert awardCreationApprovalTask[0];
        }
    }

    private void updateBatchApprovalTask(FileBatch__c fb){
        List<Task> approvalTaskList = [SELECT Id, Status FROM Task WHERE WhatId = :fb.Id AND OwnerId = :UserInfo.getUserId() AND GNT__TaskAction__c = 'MSP Batch Approval'];
        if(approvalTaskList != null && approvalTaskList.size() > 0){
            for(Task t : approvalTaskList){
                t.Status = 'Completed';
            }
        }else{
            return;
        }
        update approvalTaskList;
    }

    private void updateAwardCreationTask(FileBatch__c fb){
        List<Task> creationTaskList = [SELECT Id, Status FROM Task WHERE WhatId = :fb.Id AND OwnerId = :UserInfo.getUserId() AND GNT__TaskAction__c = 'MSP Award Creation Approval'];
        if(creationTaskList != null && creationTaskList.size() > 0){
            for(Task t : creationTaskList){
                t.Status = 'Completed';
            }
        }else{
            return;
        }
        update creationTaskList;        
    }


    private List<String> validateStagingData(List<MSPFinancialStage__c> mfss){
        Boolean isValid = true;
        Set<String> keySets = new Set<String>();
        List<String> result = new List<String>();
        for(MSPFinancialStage__c mfs : mfss){
            if(!keySets.contains(mfs.UniqueKeyFormula__c)){
                keySets.add(mfs.UniqueKeyFormula__c);
            }else{
                isValid = false;
                result.add(mfs.UniqueKeyFormula__c);
            }
        }
        return result;
    }

    private Boolean validateStaingMainMap(List<MSPFinancialStage__c> mfss, List<AwardFINETCode__c> mfms){
        Boolean isValid = true;
        Set<String> mfsKeys = new Set<String>();
        for(MSPFinancialStage__c mfs : mfss){
            mfsKeys.add(mfs.UniqueKeyFormula__c);
        }

        for(AwardFINETCode__c mfm : mfms){
            if(!mfsKeys.contains(mfm.MSPUniqueKeyFormula__c)){
                isValid = false;
                break;
            }
        }
        return isValid;
    }


    class AwardWrapper{
        public String programName{get;set;}
        public String subRecipientName{get;set;}
        public String awardAmount{get;set;}
        public String uniqueKeyFormula{get;set;}
        public String programCode{get;set;}
        public String objectCode{get;set;}
        public String leaId{get;set;}
        public String oldAwardAmount{get;set;}
    }
}