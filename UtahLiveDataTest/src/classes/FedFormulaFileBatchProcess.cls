public with sharing class FedFormulaFileBatchProcess implements FileBatchProcess {

    public FedFormulaFileBatchProcess() {

    }
    List<FEDBudgetStage__c> stageItems;
    List<FEDBudgetMain__c> mainItems;

    public Map<String, String> getData(FileBatch__c fb) {
        Map<String, String> results = new Map<String, String>();
        List<FedBudgetMain__C> mainItems = [SELECT Program__r.ProgramName__c, SubRecipient__r.Name, SubRecipient__r.LEA_Id__c, BudgetAmount__c, UniqueKeyFormula__c, ProgramCode__c, ObjectCode__c  FROM FedBudgetMain__C WHERE FiscalYear__c = :fb.FiscalYear__c ORDER BY DisplayOrder__c];
        List<FEDBudgetStage__c> stageItems = [SELECT Program__r.ProgramName__c, SubRecipient__r.Name, SubRecipient__r.LEA_Id__c, BudgetAmount__c, UniqueKeyFormula__c, ProgramCode__c, ObjectCode__c  FROM FEDBudgetStage__c WHERE FileBatch__c = :fb.Id ORDER BY DisplayOrder__c];

        List<BudgetWrapper> stageWrapperItems = new List<BudgetWrapper>();
        for (FEDBudgetStage__c f : stageItems) {
            BudgetWrapper temp = new BudgetWrapper();
            temp.programName = f.Program__r.ProgramName__c;
            temp.subRecipientName = f.SubRecipient__r.Name;
            temp.awardAmount = f.BudgetAmount__c;
            temp.uniqueKeyFormula = f.UniqueKeyFormula__c;
            temp.leaId = f.SubRecipient__r.LEA_Id__c;
            temp.programCode = f.ProgramCode__c;
            temp.objectCode = f.ObjectCode__c;
            stageWrapperItems.add(temp);
        }
        List<BudgetWrapper> mainWrapperItems = new List<BudgetWrapper>();
        for (FedBudgetMain__C f : mainItems) {
            BudgetWrapper temp = new BudgetWrapper();
            temp.programName = f.Program__r.ProgramName__c;
            temp.subRecipientName = f.SubRecipient__r.Name;
            temp.awardAmount = f.BudgetAmount__c;
            temp.uniqueKeyFormula = f.UniqueKeyFormula__c;
            temp.leaId = f.SubRecipient__r.LEA_Id__c;
            temp.programCode = f.ProgramCode__c;
            temp.objectCode = f.ObjectCode__c;
            mainWrapperItems.add(temp);
        }
        results.put('stageJSON', JSON.serialize(stageWrapperItems));
        results.put('mainJSON', JSON.serialize(mainWrapperItems));
        return results;
    }



    public Map<String, List<String>> approve(FileBatch__c fb) {
        Map<String, List<String>> results = new Map<String, List<String>>();
        results.put('Error', new List<String>());
        if (fb.FirstApprover__c == UserInfo.getUserId() && fb.Status__c == 'Processed') {
            List<FileBatch__c> fbsSameYear = [SELECT Id FROM FileBatch__c WHERE FiscalYear__c = :fb.FiscalYear__c AND Id != :fb.Id AND Status__c IN ('Sent for Activation', 'Active') AND RecordType.Name = :fb.RecordType.Name];
            if (fbsSameYear.size() > 0 && fb.ActionType__c == 'Create') {
                results.get('Error').add('One create batch already approved or active for this year');
                return results;
            }
            getDefaultData(fb);
            List<String> validateStagingDataResult = validateStagingData(stageItems);
            if(validateStagingDataResult.size() > 0){
                for(String str : validateStagingDataResult){    
                    results.get('Error').add('Duplicate unique key in Excel: ' + str);
                }
                return results;
            }

            updateBatchApprovalTask(fb);
            createBudgetCreationTask(fb);
            fb.Status__c = 'Sent for Activation';
            update fb;
        } else if (fb.SecondApprover__c == UserInfo.getUserId() && fb.Status__c == 'Sent for Activation' && fb.ActionType__c != null) {
            updateBudgetCreationTask(fb);
            fb.Status__c = 'Processing';
            update fb;
            //process(fb);
            Database.executeBatch(new FedFormulaValidateBatch(fb), 20);

           
        } else {
            results.get('Error').add('You are not supposed be here');
        }
        return results;
    }

    public Map<String, List<String>> reject(FileBatch__c fb) {
        Map<String, List<String>> results = new Map<String, List<String>>();
        results.put('Error', new List<String>());
        if (fb.Status__c == 'Processed') {
            updateBatchApprovalTask(fb);
            fb.Status__c = 'Rejected';
        } else if (fb.Status__c == 'Sent for Activation') {
            updateBudgetCreationTask(fb);
            fb.Status__c = 'Rejected';
            //Database.executeBatch(new DeleteMSPFinancialMainBatch(fb), 200);
        } else {
            results.get('Error').add('You are not supposed be here');
        }
        update fb;
        return results;
    }

    private List<String> validateStagingData(List<FEDBudgetStage__c> stages){
        Boolean isValid = true;
        Set<String> keySets = new Set<String>();
        List<String> result = new List<String>();
        for(FEDBudgetStage__c stage : stages){
            if(!keySets.contains(stage.UniqueKeyFormula__c)){
                keySets.add(stage.UniqueKeyFormula__c);
            }else{
                isValid = false;
                result.add(stage.UniqueKeyFormula__c);
            }
        }
        return result;
    }

    private void createBudgetCreationTask(FileBatch__c fb) {
        List<Task> budgetCreationApprovalTask = GNT.TaskCreationHandler.createTasks(fb.SecondApprover__c,
                                                fb.Id, 'Fed Formula Creation',
                                                 fb.FiscalYear__c + ' ' + fb.ActionType__c, null, false, null,
                                                'Approval', 'Review and Approve ' + fb.FiscalYear__c + ' ' + fb.ActionType__c, false
                                                                                   );

        if (budgetCreationApprovalTask != null && budgetCreationApprovalTask.size() > 0) {
            insert budgetCreationApprovalTask[0];
        }
    }

    private void updateBatchApprovalTask(FileBatch__c fb) {
        List<Task> approvalTaskList = [SELECT Id, Status FROM Task WHERE WhatId = :fb.Id AND OwnerId = :UserInfo.getUserId() AND GNT__TaskAction__c = 'Fed Formula Batch'];
        if (approvalTaskList != null && approvalTaskList.size() > 0) {
            for (Task t : approvalTaskList) {
                t.Status = 'Completed';
            }
        } else {
            return;
        }
        update approvalTaskList;
    }

    private void updateBudgetCreationTask(FileBatch__c fb) {
        Id userId = UserInfo.getUserId();
        List<Task> creationTaskList = [SELECT Id, Status FROM Task WHERE WhatId = :fb.Id AND OwnerId =: userId AND GNT__TaskAction__c = 'Fed Formula Creation'];
        if (creationTaskList != null && creationTaskList.size() > 0) {
            for (Task t : creationTaskList) {
                t.Status = 'Completed';
            }
            User currentUser = [SELECT Id, Email, AccountId, ContactId FROM User WHERE Id =: userId];
            GNT.EmailFeeder email = new GNT.EmailFeeder().contextRecordId(fb.Id).template('Budget_Upload_Rejection').TargetObjectId(currentUser.ContactId).toEmail(currentUser.Email);
            GNT.EmailFeeder.SendEmails(new List<GNT.EmailFeeder>{email});
        } 
        else {
            return;
        }
        update creationTaskList;
    }

    BudgetWrapper createBudgetWrapper(FEDBudgetStage__c  f) {
        BudgetWrapper temp = new BudgetWrapper();
        temp.programName = f.Program__r.ProgramName__c;
        temp.subRecipientName = f.SubRecipient__r.Name;
        temp.awardAmount = f.BudgetAmount__c;
        temp.leaId = f.SubRecipient__r.LEA_Id__c;
        temp.programId = f.Program__r.Id;
        temp.subRecipientId = f.SubRecipient__r.Id;
        temp.keyContactId = f.keyContactId__c;

        return temp;
    }

    void createAnnouncementsApplications(FileBatch__C fb, Map<string, decimal> announcements, Map<string, decimal> applications, Map<Id, Id> keyContacts) {
        Id recordTypeId = Schema.SObjectType.Application__c.getRecordTypeInfosByName().get('Grantor').getRecordTypeId();
        Map<Id, Program__C> programs = getPrograms(announcements.keySet());
        List<Announcement__c> lstAnnouncements = new List<Announcement__c>();
        Map<Id, Announcement__c> programAnnouncements = new Map<Id, Announcement__c>();
        System.debug('MANUALDEBUG >>> mapped applications >>>' + applications.size() + ',:' + applications);

        for (String programId : announcements.keySet()) {
            Program__c program = programs.get(programId);
            Decimal budgetAmount = announcements.get(programId).setScale(2);
            Announcement__c announcement = new Announcement__c();
            announcement.Program__c = programId;
            announcement.AnnouncementName__c =  program.ProgramName__c + ' - ' + string.valueOf(fb.FiscalYear__c) ;
            announcement.AnnouncementType__c = 'Formula Grants';
            announcement.AnnouncementDescription__c = program.Objectives__c;
            announcement.FOAStatus__c = 'Draft';
            announcement.Status__c = 'Create';
            announcement.AwardCeiling__c = announcements.get(programId);
            announcement.AwardFloor__c = 0;//budgetAmount;
            announcement.SetAsideAmount__c = budgetAmount;
            announcement.ObligatedAmount__c = budgetAmount;
            announcement.Organization__c = program.Account__C;
            //announcement.PreApplicationDeadlineWithDateTime__c = '2018-01-28';
            announcement.FOAPublicationDate__c =  date.valueOf(DateTime.now().addDays(1)); //Foa Release date
            announcement.ApplicationDeadlineWithDateTime__c = program.ApplicationDeadline__c;// date.valueOf('2018-06-26'); //application deadline with date time.
            //announcement.ProjectedAwardDateTime__c = date.valueOf('2018-09-28'); //project award date time
            announcement.EstimatedProjectPeriodStartDate__c = program.StartDate__c ;
            announcement.EstimatedProjectPeriodEndDate__c = program.EndDate__C;// date.valueOf('2019-09-28');
            lstAnnouncements.add(announcement);
            programAnnouncements.put(programId, announcement);
        }
        /*
        List<String> leaIdList = new List<String>();
        for(String programAccountKey : applications.keySet()){
            leaIdList.add(programAccountKey.split('_')[1]);
        }
        List<Account> leaList = new List<Account>([SELECT Id, Name FROM Account WHERE Id IN :leaIdList]);
        Map<String, Id> leaNameIdMap = new Map<String, Id>();
        for(Account lea : leaList){
            leaNameIdMap.put(lea.Name, lea.Id);
        }
        */
        List<Group> queueList = new List<Group>([SELECT Id, Name FROM Group WHERE Type = 'Queue']);
        Map<String, Group> queueAccountIdMap = new Map<String, Group>();
        for(Group g : queueList){
            queueAccountIdMap.put(g.Name, g);
        }

        //System.debug(lstAnnouncements);
        List<Application__c> lstApplications = new List<Application__c>();
        for (string programAccountKey : applications.keySet()) {
            List<string> tempPairs = programAccountKey.split('_');
            Id programId = tempPairs[0];
            Id subRecipientId = tempPairs[1];
            Id keyContactId = keyContacts.get(subRecipientId);
            Announcement__c announcement = programAnnouncements.get(programId);
            decimal awardAmount = applications.get(programAccountKey);
            Application__c tempApplication = new Application__c();
            lstApplications.add(tempApplication);
            //tempApplication.Announcement__c = announcement.Id;
            tempApplication.FederalProgram__c = announcement.Program__c;
            tempApplication.ExternalOrganization__c = subRecipientId;
            tempApplication.AwardCeiling__c = awardAmount.setScale(2);
            tempApplication.AwardFloor__c = awardAmount.setScale(2);
            tempApplication.BudgetAllocation__c = awardAmount.setScale(2);
            tempApplication.ProjectPeriodStartDate__c = announcement.EstimatedProjectPeriodStartDate__c;
            tempApplication.ProjectPeriodEndDate__c = announcement.EstimatedProjectPeriodEndDate__c;
            tempApplication.ApplicationDeadlineWithDateTime__c = announcement.ApplicationDeadlineWithDateTime__c;
            //tempApplication.OwnerId = string.valueOf(keyContactId);
            tempApplication.OwnerId = queueAccountIdMap.get('SubQueue' + subRecipientId).Id;
            tempApplication.RecordTypeId = recordTypeId;
            tempApplication.Title__C = announcement.AnnouncementName__c;
            tempApplication.FiscalYear__c = fb.FiscalYear__C;
            tempApplication.ProjectDirector__c = string.valueOf(keyContactId);
            tempApplication.ChangeOwnerAndCloseTask__c = 'No';
        }

        System.debug('MANUALDEBUG >>> before announcements >>>' + lstAnnouncements.size() + ',:' + lstAnnouncements);
        System.debug('MANUALDEBUG >>> before applications >>>' + lstApplications.size() + ',:' + lstApplications);

        //Database.executeBatch(new FedFormulaAnnouncementBatch(fb, lstAnnouncements, lstApplications), 2000);

    }

    Map<Id, Program__C> getPrograms(Set<string> programIds) {
        List<Program__C> programs = [SELECT Id, Account__C, ProgramName__c, StartDate__c, EndDate__C, ApplicationDeadline__c, Objectives__c  FROM Program__C WHERE id in : programIds];
        Map<Id, Program__C> historyMap = new Map<Id, Program__C>();
        for (Program__C p : programs) {
            historyMap.put(p.Id, p);
        }
        return historyMap;
    }

    void updateNonAwardApplications(Map<Id, decimal> preApplications, Set<Id> applicationsIds) {
        List<Application__c> dbApplications = [Select Id, AwardCeiling__c, AwardFloor__c, BudgetAllocation__c from Application__C where id in:applicationsIds];
        List<Application__C> results = new List<Application__C>();
        for (Application__c application : dbApplications) {
            //Doublecheck the applications passed and if the allocations actually changed
            if (application.BudgetAllocation__c != preApplications.get(application.Id)) {
                decimal amount = preApplications.get(application.Id);
                application.BudgetAllocation__c = amount;
                application.AwardCeiling__c = amount;
                application.AwardFloor__c = amount;
                application.Status__c ='Created';
                results.add(application);
            }
        }
        system.debug('non award applications>>>'+results);
        if (results.size() > 0) {

            update results;
        }
    }

    void getDefaultData(FileBatch__c fb){
        Id fileBatchId = fb.Id;
        string fiscalYear = fb.FiscalYear__c;
        stageItems = [SELECT Program__r.Id, FileBatch__R.FiscalYear__C, Ownerid, ObjectCode__C, ProgramCode__C,  Program__r.ProgramName__c, SubRecipient__r.Name, LEAComment__c, SubRecipient__C, SubRecipient__r.LEA_Id__c, BudgetAmount__c, KeyContactId__C , UniqueKeyFormula__c FROM FEDBudgetStage__c where FileBatch__C = :fileBatchId];
        mainItems = [SELECT Program__r.Id, Program__r.ProgramName__c, Ownerid, ObjectCode__C, ProgramCode__C, SubRecipient__r.Name, SubRecipient__C, LEAComment__c, SubRecipient__r.LEA_Id__c, BudgetAmount__c, UniqueKeyFormula__c FROM FEDBudgetMain__c where fiscalyear__C = :fiscalYear];
    }

    void process(FileBatch__c fb) {
        Id fileBatchId = fb.Id;
        string fiscalYear = fb.FiscalYear__c;
        string APPID_SET = 'noAwardAppIdSet';
        string AWARDID_SET = 'awardAppIdSet';
        List<FEDBudgetStage__c> stageItems = [SELECT Program__r.Id, FileBatch__R.FiscalYear__C, Ownerid, ObjectCode__C, ProgramCode__C,  Program__r.ProgramName__c, SubRecipient__r.Name, LEAComment__c, SubRecipient__C, SubRecipient__r.LEA_Id__c, BudgetAmount__c, KeyContactId__C , UniqueKeyFormula__c FROM FEDBudgetStage__c where FileBatch__C = :fileBatchId];
        List<FEDBudgetMain__c> mainItems = [SELECT Program__r.Id, Program__r.ProgramName__c, Ownerid, ObjectCode__C, ProgramCode__C, SubRecipient__r.Name, SubRecipient__C, LEAComment__c, SubRecipient__r.LEA_Id__c, BudgetAmount__c, UniqueKeyFormula__c FROM FEDBudgetMain__c where fiscalyear__C = :fiscalYear];
        List<Application__C> dbApplications = [select Id, Announcement__R.Program__C, Ownerid, ExternalOrganization__c, BudgetAllocation__c from Application__c  where fiscalyear__C = :fiscalYear and Status__c != 'Snapshot'];
        Map<string, decimal> dbApplicationAmounts = new Map<string, decimal>();
        Map<string, Id> dbApplicationIds = new Map<string, Id>();
        Map<Id, Id> keyContacts = new Map<Id, Id>();

        Set<Id> programs = new Set<Id>();
        Set<Id> leas = new Set<Id>();
        Map<string, FedBudgetStage__C> stageUniqueIds = new Map<string, FedBudgetStage__C>();
        Map<string, FEDBudgetMain__c> mainUniqueIds = new Map<string, FEDBudgetMain__c>();
        Map<string, BatchWrapper> batchUniqueDifferences = new Map<string, BatchWrapper>();
        Map<string, decimal> batchProgramLeaDifferenceAmounts = new Map<string, decimal>();

        Map<string, decimal> mainProgramLeaMap =   getMainProgramLeaMap(mainItems);
        Map<string, decimal> stageProgramLeaMap =   getStagingApplicationsMap(stageItems);
        Map<Id, decimal> preApplicationIdDifferences = new Map<Id, decimal>();
        List<FedBudgetStage__C> newItems = new List<FedBudgetStage__C>();
        List<FedBudgetMain__C> newMainItems = new List<FedBudgetMain__C>();

        for (Application__C application : dbApplications ) {
            dbApplicationAmounts.put(application.Announcement__R.Program__C + '_' + application.ExternalOrganization__c, application.BudgetAllocation__c);
            dbApplicationIds.put(application.Announcement__R.Program__C + '_' + application.ExternalOrganization__c, application.Id);
        }

        for (FEDBudgetMain__c budget : mainItems ) {
            mainUniqueIds.put(budget.UniqueKeyFormula__c, budget);
            programs.add(budget.Program__c);
            leas.add(budget.SubRecipient__c);
        }

        for (FEDBudgetStage__c budget : stageItems ) {
            stageUniqueIds.put(budget.UniqueKeyFormula__c, budget);
            keyContacts.put(budget.SubRecipient__c, budget.KeyContactId__C);
            if (!programs.contains(budget.Program__c) || !leas.contains(budget.SubRecipient__c)) {
                newItems.add(budget);
            } else if (mainUniqueIds.containsKey(budget.UniqueKeyFormula__c)) {
                FEDBudgetMain__c main = mainUniqueIds.get(budget.UniqueKeyFormula__c);
                if (main.BudgetAmount__c != budget.BudgetAmount__c) {
                    batchUniqueDifferences.put(budget.UniqueKeyFormula__c, new BatchWrapper(main, budget));
                }
            }
        }

        for (string key : stageProgramLeaMap.keySet()) {
            if (mainProgramLeaMap.containsKey(key) && mainProgramLeaMap.get(key) != stageProgramLeaMap.get(key)) {
                batchProgramLeaDifferenceAmounts.put(key, stageProgramLeaMap.get(key));
            }
        }


        for (string key : batchProgramLeaDifferenceAmounts.keySet()) {
            if (dbApplicationIds.containsKey(key) && dbApplicationAmounts.containsKey(key) && dbApplicationAmounts.get(key) != batchProgramLeaDifferenceAmounts.get(key)) {
                Id applicationId = dbApplicationIds.get(key);
                preApplicationIdDifferences.put(applicationId, batchProgramLeaDifferenceAmounts.get(key));
            }
        }
        Map<string, decimal> newProgramLeaMap =  getStagingApplicationsMap(newItems);
        Map<string, decimal> newProgramMap =  getStagingAnnouncementsMap(newItems);



        system.debug('new items to be added into main >>> ' + newItems);
        system.debug('new announcements to be created >>> ' + newProgramMap);
        system.debug('new applications to be created >>> ' + newProgramLeaMap);
        system.debug('possibile applications needs to be modified >>> ' + preApplicationIdDifferences);
        system.debug('update main amounts for program code object code >>> ' + batchUniqueDifferences);

        for (FedBudgetStage__C stage : newItems) {
            newMainItems.add(createMain(stage));
        }
        if (newMainItems.size() > 0) {
            insert newMainItems;
            createAnnouncementsApplications(fb, newProgramMap, newProgramLeaMap, keyContacts);
        }
        //find out applications need to be modified and awards
        if (preApplicationIdDifferences.size() > 0) {
            Map<String, Set<Id>> temp = USBEAmendApplicationInReviewHelper.resolveApplicationIds(preApplicationIdDifferences.keySet());
            //For Awarded applications
            if (temp.containsKey(AWARDID_SET) == true) {
                Set<Id> awardApplicationIds = temp.get(AWARDID_SET);
                Map<Id, Decimal> awardApplications = new Map<Id, Decimal>();
                for (Id applicationId : awardApplicationIds) {
                    awardApplications.put(applicationId, preApplicationIdDifferences.get(applicationId));
                }
                if (awardApplications.size() > 0) {
                    USBEAmendApplicationInReviewHelper.updateAwardAllocatedAmounts(awardApplications);
                }
            }

            //For Applications which are in draft, review and fdm
            if (temp.containsKey(APPID_SET) == true && temp.get(APPID_SET).size() > 0) {
                Set<Id> applicationIdDifferences = temp.get(APPID_SET);
                //call process method to update application status
                USBEAmendApplicationInReviewHelper.process(applicationIdDifferences);
                //call JL method to create snapshots
                ApplicationSnapshotHelper snapShotHelper = new ApplicationSnapshotHelper();
                system.debug('snapshot ids ' + applicationIdDifferences);
                snapShotHelper.createSnapshot(new List<Id>(applicationIdDifferences));
                updateNonAwardApplications(preApplicationIdDifferences, applicationIdDifferences);

            }

            //update main batch items with amounts
            List<FEDBudgetMain__c> updatedMainItems = new List<FEDBudgetMain__c>();
            for (string key : batchUniqueDifferences.keySet()) {
                BatchWrapper wrapper = batchUniqueDifferences.get(key);
                FedBudgetStage__C stage = wrapper.stage;
                FEDBudgetMain__c main = wrapper.main;
                main.BudgetAmount__c = stage.BudgetAmount__c;
                updatedMainItems.add(main);
            }
            if (updatedMainItems.size() > 0) {
                system.debug('updated main items' + updatedMainItems);
                update updatedMainItems;
            }
        }

        if (fb.ActionType__c == 'Amend') {
            fb.Status__c = 'Active';
            update fb;
            List<FileBatch__c> otherfbs = [SELECT Id, Status__c FROM FileBatch__c WHERE Id != :fb.Id AND Status__c = 'Active'  AND FiscalYear__c = :fb.FiscalYear__c];

            for (FileBatch__c otherfb : otherfbs) {
                otherfb.Status__c = 'Replaced';
            }
            update otherfbs;
        }

    }



    Map<string, decimal> getStagingAnnouncementsMap(List<FedBudgetStage__C> items) {
        Map<string, decimal> result = new Map<string, decimal>();
        for (FedBudgetStage__C item : items) {
            string key = item.Program__c;
            decimal budgetAmount = 0;
            if (result.containsKey(key)) {
                budgetAmount = result.get(key);
            }
            budgetAmount = budgetAmount + decimal.valueOf(item.BudgetAmount__c);
            result.put(key, budgetAmount);
        }
        return result;
    }

    Map<string, decimal> getStagingApplicationsMap(List<FedBudgetStage__C> items) {
        Map<string, decimal> result = new Map<string, decimal>();
        for (FedBudgetStage__C item : items) {
            string key = item.Program__c + '_' + item.SubRecipient__c;
            decimal budgetAmount = 0;
            if (result.containsKey(key)) {
                budgetAmount = result.get(key);
            }
            budgetAmount = budgetAmount + decimal.valueOf(item.BudgetAmount__c);
            result.put(key, budgetAmount);
        }
        return result;
    }

    FEDBudgetMain__c createMain(FedBudgetStage__C stage) {
        FEDBudgetMain__c main = new FEDBudgetMain__c();
        main.BudgetAmount__c = stage.BudgetAmount__c;
        main.LEAComment__c = stage.LEAComment__c;
        main.ObjectCode__c = stage.ObjectCode__c;
        main.OwnerId = stage.OwnerId;
        main.ProgramCode__c = stage.ProgramCode__c;
        main.Program__c = stage.Program__c;
        main.SubRecipient__c = stage.SubRecipient__c;
        main.FiscalYear__c = stage.FileBatch__R.FiscalYear__C;
        return main;
    }

    Map<string, decimal> getMainProgramLeaMap(List<FEDBudgetMain__c> items) {
        Map<string, decimal> result = new Map<string, decimal>();
        for (FEDBudgetMain__c item : items) {
            string key = item.Program__c + '_' + item.SubRecipient__c;
            decimal budgetAmount = 0;
            if (result.containsKey(key)) {
                budgetAmount = result.get(key);
            }
            budgetAmount = budgetAmount + decimal.valueOf(item.BudgetAmount__c);
            result.put(key, budgetAmount);
        }
        return result;
    }

    class BatchWrapper {
        public BatchWrapper(FEDBudgetMain__c  main, FEDBudgetStage__c stage) {
            this.stage = stage;
            this.main = main;
        }
        public FEDBudgetStage__c stage {get; set;}
        public FEDBudgetMain__c main {get; set;}
    }

    class BudgetWrapper {
        public String programName {get; set;}
        public String subRecipientName {get; set;}
        public String awardAmount {get; set;}
        public String uniqueKeyFormula {get; set;}
        public String programCode {get; set;}
        public String objectCode {get; set;}
        public String leaId {get; set;}
        public String subRecipientId {get; set;}
        public String programId {get; set;}
        public String keyContactId {get; set;}

    }


}