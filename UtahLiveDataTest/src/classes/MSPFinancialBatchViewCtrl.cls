public with sharing class MSPFinancialBatchViewCtrl {
    
    public String recordId{get;set;}
    public String packageId{get;set;}
    public PageReference deleteURL{get;set;}
    public String stageJSON{get;set;}
    public String fbStatus{get;set;}
    public String mainJSON{get;set;}
    public Boolean isCurrentUserBatchApprover{get;set;}
    public Boolean isCurrentUserAwardCreationApprover{get;set;}
    public String fbType{get;set;}

    public MSPFinancialBatchViewCtrl (ApexPages.StandardController stdController) {
        recordId = ApexPages.CurrentPage().getParameters().get('id');
        packageId = null;
        deleteURL = null;
        MSPFinancialBatch__c fb = [SELECT Id, Type__c, Status__c, FiscalYear__c, BatchApprover__c, AwardCreationApprover__c FROM MSPFinancialBatch__c WHERE Id = :recordId];
        fbStatus = fb.Status__c;
        if(fb.BatchApprover__c == UserInfo.getUserId()){
            isCurrentUserBatchApprover = true;
        }else{
            isCurrentUserBatchApprover = false;
        }
        if(fb.AwardCreationApprover__c == UserInfo.getUserId()){
            isCurrentUserAwardCreationApprover = true;
        }else{
            isCurrentUserAwardCreationApprover = false;
        }
        fbType = fb.Type__c;
        List<MSPFinancialMain__c> fms = [SELECT Program__r.ProgramName__c, SubRecipient__r.Name, SubRecipient__r.LEA_Id__c, AwardAmount__c, UniqueKeyFormula__c, ProgramCode__c, ObjectCode__c FROM MSPFinancialMain__c WHERE FiscalYear__c =:fb.FiscalYear__c ORDER BY DisplayOrder__c];
        List<MSPFinancialStage__c> fs = [SELECT Program__r.ProgramName__c, SubRecipient__r.Name, SubRecipient__r.LEA_Id__c, AwardAmount__c, UniqueKeyFormula__c, ProgramCode__c, ObjectCode__c FROM MSPFinancialStage__c WHERE MSPFinancialBatch__c =:recordId ORDER BY DisplayOrder__c];

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
            stageWrapper.add(temp);
        }

        List<AwardWrapper> mainWrapper = new List<AwardWrapper>();
        for(MSPFinancialMain__c fm : fms){
            AwardWrapper temp = new AwardWrapper();
            temp.programName = fm.Program__r.ProgramName__c;
            temp.subRecipientName = fm.SubRecipient__r.Name;
            temp.awardAmount = fm.AwardAmount__c;
            temp.uniqueKeyFormula = fm.UniqueKeyFormula__c;
            temp.programCode = fm.ProgramCode__c;
            temp.objectCode = fm.ObjectCode__c;
            temp.leaId = fm.SubRecipient__r.LEA_Id__c;
            mainWrapper.add(temp);
        }

        mainJSON = JSON.serialize(mainWrapper);
        if(fbStatus == 'Approved'){    
            stageJSON = JSON.serialize(mainWrapper);
        }else{
            stageJSON = JSON.serialize(stageWrapper);
        }

    } 

    public String getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('batchId', recordId);
        return JSON.serialize(keyValueMap);
    }
    
    public String getListParameters(){
        Map<String,Set<String>> listParams = new Map<String,Set<String>>();
        return JSON.serialize(listParams);
    }

    public PageReference approve(){
        MSPFinancialBatch__c pf = [SELECT FiscalYear__c, Type__c, Status__c, AwardCreationApprover__c FROM MSPFinancialBatch__c WHERE Id = :recordId];
        List<MSPFinancialBatch__c> fbsSameYear = [SELECT Status__c FROM MSPFinancialBatch__c WHERE FiscalYear__c = :pf.FiscalYear__c AND Id != :pf.Id AND Status__c IN ('Approved','Active')];
        if(fbsSameYear.size() > 0 && pf.Type__c == 'Create'){
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'One create batch already approved or active for this year'));
             return null;
        }
        Savepoint sp = Database.setSavepoint();
        try{
            //Database.executeBatch(new MSPMainCreateAndAmendBatch(pf), 200);
            updateBatchApprovalTask();
            createAwardCreationTask(pf);
            pf.Status__c = 'Processing Approve';
            update pf;
            PageReference pageref = Page.PhaseView;
            pageref.getParameters().put('t','GrantorPlanning');
            pageref.setRedirect(true);
            return pageref;
        }catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
            Database.rollback(sp);
            return null;
        }
    }

    public PageReference createAwards(){
        Savepoint sp = Database.setSavepoint();
        try{
            MSPFinancialBatch__c pf = [SELECT FiscalYear__c, Status__c, Type__c FROM MSPFinancialBatch__c WHERE Id = :recordId];
            //Database.executeBatch(new MSPGrantAndAwardCreateAndAmendBatch(pf), 200);
            updateAwardCreationTask();
            createPaymentSchedule();
            pf.Status__c = 'Processing Active';
            update pf;
            PageReference pageref = Page.PhaseView;
            pageref.getParameters().put('t','GrantorPlanning');
            pageref.setRedirect(true);
            return pageref;
        }catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
            Database.rollback(sp);
            return null;
        }
    }

    public PageReference reject(){
        Savepoint sp = Database.setSavepoint();
        try{
            MSPFinancialBatch__c pf = [SELECT Status__c, FiscalYear__c FROM MSPFinancialBatch__c WHERE Id = :recordId];
            if(pf.Status__c == 'Processed'){
                updateBatchApprovalTask();
                pf.Status__c = 'Rejected';
            }else if(pf.Status__c == 'Approved'){
                updateAwardCreationTask();
                pf.Status__c = 'Processing';
                //Database.executeBatch(new DeleteMSPFinancialMainBatch(pf), 200);
            }
            
            update pf;
            PageReference pageref = Page.PhaseView;
            pageref.getParameters().put('t','GrantorPlanning');
            pageref.setRedirect(true);
            return pageref;
        }catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
            Database.rollback(sp);
            return null;
        }
    }

    public PageReference cancel(){
        PageReference pageref = Page.PhaseView;
        pageref.getParameters().put('t','GrantorPlanning');
        pageref.setRedirect(true);
        return pageref;
    }

    private void createAwardCreationTask(MSPFinancialBatch__c mfb){
        List<Task> awardCreationApprovalTask = GNT.TaskCreationHandler.createTasks(mfb.AwardCreationApprover__c,
            mfb.Id,'MSP Award Creation Approval',
            mfb.FiscalYear__c + ' ' + mfb.Type__c, null, false, null,
            'Approval', mfb.FiscalYear__c + ' ' + mfb.Type__c, false
        );

        if(awardCreationApprovalTask != null && awardCreationApprovalTask.size() > 0) {
            insert awardCreationApprovalTask[0];
        }
    }

    private void updateBatchApprovalTask(){
        List<Task> approvalTaskList = [SELECT Id, Status FROM Task WHERE WhatId = :recordId AND OwnerId = :UserInfo.getUserId() AND GNT__TaskAction__c = 'MSP Batch Approval'];
        if(approvalTaskList != null && approvalTaskList.size() > 0){
            for(Task t : approvalTaskList){
                t.Status = 'Completed';
            }
        }else{
            return;
        }
        update approvalTaskList;
    }

    private void updateAwardCreationTask(){
        List<Task> creationTaskList = [SELECT Id, Status FROM Task WHERE WhatId = :recordId AND OwnerId = :UserInfo.getUserId() AND GNT__TaskAction__c = 'MSP Award Creation Approval'];
        if(creationTaskList != null && creationTaskList.size() > 0){
            for(Task t : creationTaskList){
                t.Status = 'Completed';
            }
        }else{
            return;
        }
        update creationTaskList;        
    }

    private void createPaymentSchedule(){
        MSPFinancialBatch__c mfb = [SELECT Id, Status__c, FiscalYear__c, Type__c, BatchApprover__c, AwardCreationApprover__c FROM MSPFinancialBatch__c WHERE Id = :recordId];
        if(mfb.Type__c == 'Create'){
            List<MSPPaymentSchedule__c> mpss = new List<MSPPaymentSchedule__c>();
            Date paymentStartDate = Date.newInstance(Integer.valueOf(mfb.FiscalYear__c) - 1, 7, 15);
            for(Integer i = 0; i < 12; i++){
                MSPPaymentSchedule__c temp = new MSPPaymentSchedule__c(
                    FiscalYear__c = mfb.FiscalYear__c,
                    ScheduleDate__c = paymentStartDate.addMonths(i),
                    FirstApprover__c = mfb.BatchApprover__c,
                    FinalApprover__c = mfb.AwardCreationApprover__c
                );
                mpss.add(temp);
            }
            insert mpss;
        }
    }

    class AwardWrapper{
        public String programName{get;set;}
        public String subRecipientName{get;set;}
        public String awardAmount{get;set;}
        public String uniqueKeyFormula{get;set;}
        public String programCode{get;set;}
        public String objectCode{get;set;}
        public String leaId{get;set;}
    }
    /*
    private void createMSPMain(MSPFinancialBatch__c pf){
        if(pf.Type__c == 'Create'){
            List<MSPFinancialStage__c> fs = [SELECT Id, Program__c, SubRecipient__c, AwardAmount__c, MSPFinancialBatch__r.FiscalYear__c, DisplayOrder__c, ObjectCode__c, ProgramCode__c FROM MSPFinancialStage__c WHERE MSPFinancialBatch__c = :recordId];
            List<MSPFinancialMain__c> fms = new List<MSPFinancialMain__c>();
            for(MSPFinancialStage__c f : fs){
                MSPFinancialMain__c temp = new MSPFinancialMain__c(
                    Program__c = f.Program__c,
                    SubRecipient__c = f.SubRecipient__c,
                    AwardAmount__c = f.AwardAmount__c,
                    FiscalYear__c = f.MSPFinancialBatch__r.FiscalYear__c,
                    DisplayOrder__c = f.DisplayOrder__c,
                    ObjectCode__c = f.ObjectCode__c,
                    ProgramCode__c = f.ProgramCode__c
                );
                fms.add(temp);
            }
            if(fms.size() > 0){
                insert fms;
            }
            pf.Status__c = 'Approved';
        }else if(pf.Type__c == 'Amend'){
            List<MSPFinancialMain__c> mfms = [SELECT Id, AwardAmount__c, UniqueKeyFormula__c FROM MSPFinancialMain__c WHERE FiscalYear__c = :pf.FiscalYear__c];
            Map<String, MSPFinancialMain__c> mainMap = new Map<String, MSPFinancialMain__c>();
            for(MSPFinancialMain__c mfm : mfms){
                mainMap.put(mfm.UniqueKeyFormula__c, mfm);
            }

            List<MSPFinancialStage__c> mfss = [SELECT Id, AwardAmount__c, Program__c, SubRecipient__c, MSPFinancialBatch__r.FiscalYear__c, DisplayOrder__c, ObjectCode__c, ProgramCode__c, UniqueKeyFormula__c FROM MSPFinancialStage__c WHERE MSPFinancialBatch__c = :recordId];
            List<MSPFinancialMain__c> upsertmfms = new List<MSPFinancialMain__c>();
            for(MSPFinancialStage__c mfs : mfss){
                MSPFinancialMain__c mfm = mainMap.get(mfs.UniqueKeyFormula__c);
                if(mfm == null){
                    MSPFinancialMain__c temp = new MSPFinancialMain__c(
                        Program__c = mfs.Program__c,
                        SubRecipient__c = mfs.SubRecipient__c,
                        AwardAmount__c = mfs.AwardAmount__c,
                        FiscalYear__c = mfs.MSPFinancialBatch__r.FiscalYear__c,
                        DisplayOrder__c = mfs.DisplayOrder__c,
                        ObjectCode__c = mfs.ObjectCode__c,
                        ProgramCode__c = mfs.ProgramCode__c
                    );
                    upsertmfms.add(temp);
                }else{
                    if(mfs.AwardAmount__c != mfm.AwardAmount__c){
                        mfm.AwardAmount__c = mfs.AwardAmount__c;
                        upsertmfms.add(mfm);
                    }
                }
            }
            if(upsertmfms.size() > 0){
                upsert upsertmfms;
            }
            pf.Status__c = 'Approved';
        }
        update pf;
    }
    */

    /*
    private void createGrantsAndAwards(){
        MSPFinancialBatch__c mfb = [SELECT Id, Status__c, FiscalYear__c, Type__c FROM MSPFinancialBatch__c WHERE Id = :recordId];
        if(mfb.Type__c == 'Create'){
            List<MSPFinancialMain__c> mfms = [SELECT Id, SubRecipient__r.LEA_Id__c, Program__r.ProgramKey__c, AwardAmount__c, DisplayOrder__c, FiscalYear__c, ObjectCode__c, Program__c, ProgramCode__c, SubRecipient__c, UniqueKeyFormula__c, AwardAmountFormula__c FROM MSPFinancialMain__c WHERE FiscalYear__c =:mfb.FiscalYear__c];
            List<MSPGrant__c> newMSPGrants = new List<MSPGrant__c>();
            for(MSPFinancialMain__c mfm : mfms){
                MSPGrant__c temp = new MSPGrant__c(
                    Name = 'MSPGT-' + mfm.Program__r.ProgramKey__c + '-' + mfm.SubRecipient__r.LEA_Id__c + '-' + mfm.FiscalYear__c + '-' + mfm.ProgramCode__c + '-' + mfm.ObjectCode__c,
                    DisplayOrder__c = mfm.DisplayOrder__c,
                    FiscalYear__c = mfm.FiscalYear__c,
                    ObjectCode__c = mfm.ObjectCode__c,
                    Program__c = mfm.Program__c,
                    ProgramCode__c = mfm.ProgramCode__c,
                    SubRecipient__c = mfm.SubRecipient__c,
                    CurrentAwardAmount__c = mfm.AwardAmountFormula__c
                );
                newMSPGrants.add(temp);
            }

            insert newMSPGrants;
            List<MSPGrant__c> mgs = [SELECT Id, Name, UniqueKeyFormula__c, AwardCount__c, CurrentAwardAmount__c FROM MSPGrant__c WHERE Id IN :newMSPGrants];
            List<MSPAward__c> newMSPAwards = new List<MSPAward__c>();
            for(MSPGrant__c mg : mgs){
                MSPAward__c temp = new MSPAward__c(
                    Name = 'MSPAD-' + mg.Name.substring(6) + '-' + String.valueOf(mg.AwardCount__c + 1),
                    MSPGrant__c = mg.Id,
                    AwardAmount__c = mg.CurrentAwardAmount__c,
                    VersionNumber__c = mg.AwardCount__c + 1
                );
                newMSPAwards.add(temp);
            }

            insert newMSPAwards;

        }else if(mfb.Type__c == 'Amend'){
            List<MSPGrant__c> mgs = [SELECT Id, Name, UniqueKeyFormula__c, AwardCount__c, CurrentAwardAmount__c FROM MSPGrant__c WHERE FiscalYear__c =:mfb.FiscalYear__c];
            Map<String, MSPGrant__c> keyMSPGrantMap = new Map<String, MSPGrant__c>();
            for(MSPGrant__c mg : mgs){
                keyMSPGrantMap.put(mg.UniqueKeyFormula__c, mg);
            }

            List<MSPFinancialMain__c> mfms = [SELECT Id, SubRecipient__r.LEA_Id__c, Program__r.ProgramKey__c, AwardAmount__c, DisplayOrder__c, FiscalYear__c, ObjectCode__c, Program__c, ProgramCode__c, SubRecipient__c, UniqueKeyFormula__c, AwardAmountFormula__c FROM MSPFinancialMain__c WHERE FiscalYear__c =:mfb.FiscalYear__c];
            List<MSPGrant__c> newMSPGrants = new List<MSPGrant__c>();
            List<MSPAward__c> newMSPAwards = new List<MSPAward__c>();
            List<MSPGrant__c> updateMSPGrant = new List<MSPGrant__c>();
            for(MSPFinancialMain__c mfm : mfms){
                MSPGrant__c currentMSPGrant = keyMSPGrantMap.get(mfm.UniqueKeyFormula__c);
                if(currentMSPGrant == null){    
                    MSPGrant__c temp = new MSPGrant__c(
                        Name = 'MSPGT-' + mfm.Program__r.ProgramKey__c + '-' + mfm.SubRecipient__r.LEA_Id__c + '-' + mfm.FiscalYear__c + '-' + mfm.ProgramCode__c + '-' + mfm.ObjectCode__c,
                        DisplayOrder__c = mfm.DisplayOrder__c,
                        FiscalYear__c = mfm.FiscalYear__c,
                        ObjectCode__c = mfm.ObjectCode__c,
                        Program__c = mfm.Program__c,
                        ProgramCode__c = mfm.ProgramCode__c,
                        SubRecipient__c = mfm.SubRecipient__c,
                        CurrentAwardAmount__c = mfm.AwardAmountFormula__c
                    );
                    newMSPGrants.add(temp);

                }else if(currentMSPGrant.CurrentAwardAmount__c != mfm.AwardAmountFormula__c){
                    currentMSPGrant.CurrentAwardAmount__c = mfm.AwardAmountFormula__c;
                    updateMSPGrant.add(currentMSPGrant);
                    MSPAward__c temp = new MSPAward__c(
                        Name = 'MSPAD-' + currentMSPGrant.Name.substring(6) + '-' + String.valueOf(currentMSPGrant.AwardCount__c + 1),
                        MSPGrant__c = currentMSPGrant.Id,
                        AwardAmount__c = mfm.AwardAmountFormula__c,
                        VersionNumber__c = currentMSPGrant.AwardCount__c + 1
                    );
                    newMSPAwards.add(temp);
                }
            }

            if(newMSPGrants.size() > 0){
                insert newMSPGrants;
                List<MSPGrant__c> newMgs = [SELECT Id, Name, UniqueKeyFormula__c, AwardCount__c, CurrentAwardAmount__c FROM MSPGrant__c WHERE Id IN :newMSPGrants];
                for(MSPGrant__c mg : newMgs){
                    MSPAward__c tempAward = new MSPAward__c(
                        Name = 'MSPAD-' + mg.Name.substring(6) + '-' + String.valueOf(mg.AwardCount__c + 1),
                        MSPGrant__c = mg.Id,
                        AwardAmount__c = mg.CurrentAwardAmount__c,
                        VersionNumber__c = mg.AwardCount__c + 1
                    );
                    newMSPAwards.add(tempAward);
                }
            }
            if(updateMSPGrant.size() > 0){
                update updateMSPGrant;
            }
            if(newMSPAwards.size() > 0){
                insert newMSPAwards;
            }

            List<MSPFinancialBatch__c> otherMfbs = [SELECT Id, Status__c FROM MSPFinancialBatch__c WHERE Id != :mfb.Id AND Status__c = 'Active' AND FiscalYear__c = :mfb.FiscalYear__c];
            for(MSPFinancialBatch__c otherMfb : otherMfbs){
                otherMfb.Status__c = 'Replaced';
            }
            update otherMfbs;
        }
    }
    */
        /*
        AggregateResult[] mainAggs = [SELECT SUM(AwardAmountFormula__c) awardSum, Program__c programId FROM MSPFinancialMain__c WHERE FiscalYear__c =:fb.FiscalYear__c GROUP BY Program__c ];
        List<Id> mainProgramIds = new List<Id>();
        for(AggregateResult agg : mainAggs){
            mainProgramIds.add(String.valueOf(agg.get('programId')));
        }

       List<Program__c> mainPrograms = [SELECT Id, ProgramName__c, DisplayOrder__c, ProgramKey__c FROM Program__c WHERE Id IN :mainProgramIds ORDER BY DisplayOrder__c];

        for(Program__c p : mainPrograms){
            for(AggregateResult agg : mainAggs){
                if(p.Id == String.valueOf(agg.get('programId'))){
                    AwardWrapper temp = new AwardWrapper();
                    temp.programName = p.ProgramName__c;
                    temp.subRecipientName = 'Total';
                    temp.awardAmount = String.valueOf(agg.get('awardSum'));
                    temp.uniqueKeyFormula = 'ProgramTotal' + p.ProgramKey__c;
                    mainWrapper.add(temp);
                }
            }
        }
        */
        /*
        AggregateResult[] aggs = [SELECT SUM(AwardAmountFormula__c) awardSum, Program__c programId FROM MSPFinancialStage__c WHERE MSPFinancialBatch__c = :recordId GROUP BY Program__c ];
        List<Id> programIds = new List<Id>();
        for(AggregateResult agg : aggs){
            programIds.add(String.valueOf(agg.get('programId')));
        }

       List<Program__c> programs = [SELECT Id, ProgramName__c, DisplayOrder__c, ProgramKey__c FROM Program__c WHERE Id IN :programIds ORDER BY DisplayOrder__c];

        for(Program__c p : programs){
            for(AggregateResult agg : aggs){
                if(p.Id == String.valueOf(agg.get('programId'))){
                    AwardWrapper temp = new AwardWrapper();
                    temp.programName = p.ProgramName__c;
                    temp.subRecipientName = 'Total';
                    temp.awardAmount = String.valueOf(agg.get('awardSum'));
                    temp.uniqueKeyFormula = 'ProgramTotal' + p.ProgramKey__c;
                    stageWrapper.add(temp);
                }
            }
        }
        */
}