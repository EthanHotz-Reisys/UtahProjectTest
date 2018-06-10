/*
    This is a class with keyword "without sharing".
    This enables the methods defined here to execute in System Context, that is, the current user's permissions, 
    field-level security, and sharing rules aren�t taken into account during code execution.     
    *******************************************************************************************************************
    Audit History
    ********************************************************************************************************************
    26-Aug-2014        Prem Pal    Created
    **********************************************************************************************************************  
*/ 
global without sharing class SystemContextMethodsHelper {
private Set<Id> paymentIds;    
    
    /*
        Called from ApplicationTriggerHelper && PreApplicationTriggerHelper
    */
    public void updateAnnouncements(List<Announcement__c> announceList){

            update announceList;
       
    }

 /*
        Called from AnnouncementTriggerHelper 
    */
   

    public void insertAttachments(List<Attachment> attachments){

            insert attachments;
       
    } 
    
    /*
        Called from AnnouncementTriggerHelper && ApplicationTriggerHelper && GrantTriggerHelper
    */
    public void updateAccounts(List<Account> accntList){

            update accntList;
       
    } 

    public void insertAmdRequestRoles(){
        RolesandResponsibilitiesTriggerHelper rrTriggerHelper=new RolesandResponsibilitiesTriggerHelper();
        rrTriggerHelper.insertRoles('Grantor');
    }

    public void insertSObjectList(List<SObject> sobjList){
        insert sobjList;
    }
    public void deleteSobjectList(List<Sobject> sobjList){
        delete sobjList;
    }

    public void upsertSObjectList(List<SObject> sobjList){
        upsert sobjList;
    }

    
    /*
        Called from RiskAssessmentTriggerHelper 
    */
    public void updateGrants(List<Grant__c> granstList){

            update granstList;
       
    } 
    /*
        Called from ApplicationTriggerHelper
    */
    global void updateApplications(List<Application__c> applicationList){

            update applicationList;
       
    }  
    /*
        Called from PreApplicationTriggerHelper
    */
    global void updatePreApplications(List<PreApplication__c> preapplicationList){

            update preapplicationList;
       
    }  
    /*
        Called from SubmissionReportTaskHelper
    */
    public void updateTermConditions(List<TermCondition__c> termConditionList){

            update termConditionList ;
        
    }  
    
    /*
        To share account with external users
    */       
    
    public AccountShare shareExternalAccount(Id userId,Id accountId,boolean isOwner, Boolean isInsert){
        AccountShare share= new AccountShare();
        share.AccountId= accountId;
        share.UserOrGroupId = userId;
        share.AccountAccessLevel =  isOwner?'edit':'read';
        share.CaseAccessLevel = isOwner?'edit':'read';
        share.opportunityAccessLevel = isOwner?'edit':'read';

        if (isInsert) {
            insert share;
        }        
        return share;
    }
    
    /*
        Called from ReviewTriggerHelper
    */
   /* public void insertReviewGroupShare(List<ReviewGroup__Share> revGroupShareList){
        //insert revGroupShareList;
        Database.saveResult [] saveResult = Database.insert(revGroupShareList, false);
    }  */
    
    public void insertGrantShare(List<Grant__Share>grantShareList){
        //insert revGroupShareList;
        Database.saveResult [] saveResult = Database.insert(grantShareList, false);
    }

    public void insertGrant(List<Grant__c> grantList){
        insert grantList;
    }

    public void insertAward(List<Award__c> awardList){
        insert awardList;
    }
    
    public void insertAwardAmend(Award__c award){
        insert award;
    }

    public void insertApplicationShare(List<Application__Share> appShareList){
        insert appShareList;
    }  
    
    public void insertAnnouncementShare(List<Announcement__Share> annShareList){
        insert annShareList;
    }

    public void upsertAnnouncementShare(List<Announcement__Share> annShareList){
        upsert annShareList;
    }

    public void upsertGrantShare(List<Grant__Share> grantShareList){
        upsert grantShareList;
    }

    //public void upsertAmendmentRequestShare(List<AmendmentRequest__Share> amendShareList){
    //    upsert amendShareList;
    //}

    public void upsertApplicationShare(List<Application__Share> appShareList){
        upsert appShareList;
    }

    public void upsertFundingSourceShare(List<FundingSource__Share> fsShareList){
        upsert fsShareList;
    } 
    
    public void upsertProgressReportShare(List<ProgressReports__Share> prShareList){
        upsert prShareList;
    }

    public void upsertSiteVisitShare(List<SiteVisit__Share> svShareList){
        upsert svShareList;
    }

    public void insertReviewShare(List<Review__Share> revShareList){
        insert revShareList;
    } 

    public static void insertSoleSourceRecipientShare(List<SoleSourceAwardRecipient__c> soleSourceRecpList){
        insert soleSourceRecpList;
    }
    
    public void insertPreApplicationShare(List<PreApplication__Share> preappShareList){ 
        insert preappShareList;
    } 
    
    public void updateTasks(List<Task> taskList){
        update taskList;
    }
    
    public void updateAwards(List<Award__c> awardList){
      update awardList;
    }
    

    global Map<Id,SiteVisit__c> getSiteVisitReportApprovers(Map<Id,SiteVisit__c> newSiteReport) {
        /*Map<Id,SiteVisit__c> siteReportApprovers = new Map<Id,SiteVisit__c>([select id,SubAwardee__r.Email,Award__r.ProjectOfficer__r.Email, TermConditionSchedule__r.TermAndCondition__r.Award__r.GrantMonitor__c,TermConditionSchedule__r.TermAndCondition__r.Award__r.GrantMonitor__r.Email,
            TermConditionSchedule__r.TermAndCondition__r.Award__r.ProgramManager__c,TermConditionSchedule__r.TermAndCondition__r.Award__r.ProgramManager__r.Email
            FROM SiteVisit__c where id in : newSiteReport.keyset()]);
        return siteReportApprovers;*/ 
        return null;
            }
    global List<Program__c> getProgramIds(Id programId){
        return [Select id from Program__c where id = :programId LIMIT 1];
    }
    global Program__c getProgramfields(List<Program__c> program){
        return [Select FunderType__c,OrganizationName__c from Program__c where id IN:program LIMIT 1];
    }
    global List<Task> getRelatedTasks(Set<Id> progressReportIds) {
        return [select id,OwnerId, Status,   GNT__TaskAction__c,    GNT__ParentRecordId__c from Task where     GNT__ParentRecordId__c in : progressReportIds];
        }

    global List<Task> getRelatedTasksForRoles(Set<Id> progressReportIds) {
        return [select id,OwnerId, Status,   GNT__TaskAction__c,    GNT__ParentRecordId__c from Task where     WhatId in : progressReportIds];
        }

    // This method is written by charan for updating task for reviewers and added a filter condition which cannot be used for general purposes.
    // 06/04/2017
    global List<Task> getTasks(List<String> progressReportIds,String searchString) {
        return [select id,Status,   GNT__TaskAction__c,    GNT__ParentRecordId__c from Task where     GNT__ParentRecordId__c in : progressReportIds and GNT__TaskAction__c like:searchString];
        }

    global void updateTermCondSchedules(List<TermConditionSchedule__c> termConditionSchedules) {
            update termConditionSchedules;
    }
    
    global void insertTermCondSchedules(List<TermConditionSchedule__c> termConditionSchedules) {
            insert termConditionSchedules;
    }

    public void updateBudgetPeriods(List<BudgetPeriod__c> budgetPeriodLst){
        update budgetPeriodLst;     
    }
    
    public void updatePrograms(List<Program__Share> programShareLst){
        insert programShareLst;     
    }

    public void insertNewRootList(List<WBSTaskSchedule__c> newRootList) {
        insert newRootList;
    } 
    
     
    public void shareAnnouncement(Map<Id,List<Id>> announcementUser ){
        System.debug('The Application User is '+announcementUser);  
        List<Announcement__Share> lstAnnouncmentShare = new List<Announcement__Share>();
        for(Id announcementId : announcementUser.keySet()){
   
            List<Id> lstUser = announcementUser.get(announcementId);
            for(Id userId :lstUser){ 
                Announcement__Share appShare = new Announcement__Share();  
                appShare.ParentId = announcementId;
                System.debug('11 ANNOUNCEMENT ID IS >>>>>> '+announcementId);
                System.debug('22 USER ID IS >>>>>>       '+userId);
                appShare.UserOrGroupId = userId;
                appShare.AccessLevel = 'Edit';
                appShare.RowCause = Schema.Announcement__Share.RowCause.SharingforReviewandApproval__c;
                lstAnnouncmentShare.add(appShare);
                }    
            } 
             System.debug('33 lstAnnouncmentShare IS >>>>>>      '+lstAnnouncmentShare);
             upsert lstAnnouncmentShare;  
     }
     
     
      public void shareApplicationEdit(Map<Id,List<Id>> applicationUser ){
        System.debug('The Application User is '+applicationUser); 
        List<Application__Share> lstApplicationShare = new List<Application__Share>();
        for(Id applicationId : applicationUser.keySet()){

            List<Id> lstUser = applicationUser.get(applicationId);
            for(Id userId :lstUser){
                Application__Share appShare = new Application__Share();
                appShare.ParentId = applicationId;
                appShare.UserOrGroupId = userId;
                appShare.AccessLevel = 'Edit';
                appShare.RowCause = Schema.Application__Share.RowCause.SharingforReviewandApproval__c;
                lstApplicationShare.add(appShare);
                }
            }
              insert lstApplicationShare; 
        }
    
    public void insertPanelUserTemplates(List<PanelUserTemplate__c> putList){
        insert putList;
    }
           
        public void updateReviewStepTemplates(List<ReviewStepTemplate__Share> rstList){
            upsert rstList;
       }
    
       public void updateReviewPanelTemplates(List<ReviewPanelTemplate__c> rptList){
            upsert rptList;
       }
       
        public static void updateReviewGroupShares(List<ReviewGroup__Share> rgShares){
            upsert rgShares;
       }
       
       public void updatePaymentRequestShares(List<PaymentRequest__Share> prShares){
            upsert prShares;
       }
        
        public void sharePreApplicationEdit(Map<Id,List<Id>> applicationUser ){
            System.debug('The Application User is '+applicationUser); 
            List<PreApplication__Share> lstApplicationShare = new List<PreApplication__Share>();
            for(Id applicationId : applicationUser.keySet()){
   
            List<Id> lstUser = applicationUser.get(applicationId);
            for(Id userId :lstUser){
                PreApplication__Share appShare = new PreApplication__Share();
                appShare.ParentId = applicationId;
                appShare.UserOrGroupId = userId;
                appShare.AccessLevel = 'Edit';
                appShare.RowCause = Schema.PreApplication__Share.RowCause.Sharing_for_Review__c;
                lstApplicationShare.add(appShare);
                }
            }
              insert lstApplicationShare; 
        }

        public static void shareOpportunityToExternalUser(List<OpportunityQualification__c> opps) {
            Id roleId = UserInfo.getUserRoleId();
            List<Group> publicGroup  = [select id from Group where type='RoleAndSubordinates' and relatedId =:roleId];        
            if(publicGroup != null && publicGroup.size() > 0){
                List<OpportunityQualification__Share> oppShares  = new List<OpportunityQualification__Share>();
                for(OpportunityQualification__c opp : opps){
                OpportunityQualification__Share oppShare = new OpportunityQualification__Share();
                oppShare.parentId = opp.id;
                oppShare.UserOrGroupId = publicGroup[0].id;
                oppShare.AccessLevel = 'Edit';
                oppShare.RowCause = Schema.OpportunityQualification__Share.RowCause.SharetoExternalUsers__c;
                oppShares.add(oppShare);
                 }
            insert oppShares;
            }
        }
        
        public static List<Note> getNotes(String parentId) {
            List<Note> notes = [SELECT Id,Body,Title,OwnerId, CreatedDate,LastModifiedDate,Owner.Name,ParentId,CreatedBy.Name,CreatedBy.FirstName,CreatedBy.LastName,CreatedById
                                        FROM Note 
                                        WHERE ParentId = :parentId ORDER BY LastModifiedDate DESC];
            return notes;
        }

        public static List<Task>   upsertTasks(List<Task> taskList){
            upsert taskList;
            return taskList;
        }

        
        public static Map<String, User> getUsers(List<String> userIds) {
            Map<String, User> userMap = new Map<String, User>([select id, smallPhotoUrl from User where Id in:userIds]);
            return userMap;
        }

        public void createSnapshots(Review__c assign){
             GNT.SnapshotUtils.createSnapshot(assign.Id,assign.ReviewPanel__r.ReviewStep__r.ReviewFormConfig__r.Name,'',null,assign.Application__r.ExternalOrganization__c);
        }

        public void insertSingleApplicationToReview(Application__c app){
            System.debug('Enter SystemContextMethodsHelper');
            ReviewTasksHandler rt = new ReviewTasksHandler();
            rt.processSingleAppOrPreapp(app.Id);
        }
        
        public Award__c getAward(String awardId) {
            Award__c award = [SELECT Id, Grant__r.Program__r.ProgramKey__c,GrantorOrganization__c,BudgetRevisionInitiatedByUSBE__c FROM Award__c WHERE id =: awardId];
            return award;
        }
        
        public PaymentRequest__c getPaymentRequest(String paymentId) {
            PaymentRequest__c payreq = [SELECT Id, Grant__r.Program__r.ProgramKey__c FROM PaymentRequest__c WHERE Id =: paymentId];
            return payreq;
        }
        
        public List<Award__c> getAwardsFromProgramKey(List<String> programKeys) {
            List<Award__c> awards = [SELECT Id, RemainingBudget__c,PendingPayment__c,BudgetRevisionInitiatedByUSBE__c FROM Award__c WHERE Grant__r.Program__r.ProgramKey__c IN: programKeys];
            return awards;
        }

        public SiteVisit__c getSv(Id recordId){
            SiteVisit__c sv = [select id,Grant__c,TermConditionSchedule__r.TermAndCondition__r.SubmissionPackage__r.GNT__PageTemplateConfig__r.Name 
                                    from SiteVisit__c 
                                    where id =: recordId limit 1];
            return sv;
        }

        public ReviewStep__c getRevStep(Id recordId){
            ReviewStep__c revStep = [SELECT ID,Name,RecordType.DeveloperName, AnnouncementId__c, CountReviewPanels__c, ReviewGroup__c, ReviewGroup__r.Announcement__r.Name, ReviewGroup__r.Announcement__r.Program__r.ReviewProcess__c, 
                ReviewStepLayout__r.Name FROM ReviewStep__c WHERE Id = :recordId];
            return revStep;
        }

        public void insertRoles(List<RolesAndResponsibilities__c> rolesList){
            insert rolesList;
        }

        public void insertUsers(List<User> userList){
            insert userList;
        }

        public void rejectProcess(Id awardId){
            List<PaymentRequest__c> paymentList = [Select id from PaymentRequest__c where Award__c = :awardId and Status__c IN ('Submitted for Approval','Submitted to Grantor')]; 
            ProcessInstanceWorkitem[] workItems = [SELECT Id FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId IN :paymentList AND ProcessInstance.Status = 'Pending'];
            Approval.ProcessWorkitemRequest pwr = new Approval.ProcessWorkitemRequest();
            //List<Approval.ProcessWorkitemRequest> pwrList = new List<Approval.ProcessWorkitemRequest>();
            for(ProcessInstanceWorkitem workItem : workItems ){
                if(workItem!=null){
                    pwr.setAction('Reject');
                    pwr.setWorkItemId(workItem.id);
                    Approval.ProcessResult result = Approval.process(pwr);
                }
            }
            List<Task> taskList = [Select id from Task where WhatId IN :paymentList AND Status IN ('Not Started','In Progress')];
            if(taskList!=null){
                delete taskList;
            }            
            /*
            if(pwrList!=null){
                SystemContextMethodsHelper contexthelper = new SystemContextMethodsHelper();
                contexthelper.rejectProcess(pwrList);
            }
            */
        }
        public void insertBudgetPeriods(List<BudgetPeriod__c> budgetPeriodLst) {
            insert budgetPeriodLst;  
        }
        
        public void insertApplicationServiceArea(List<ApplicationServiceArea__c> appSerAreaList) {
            insert appSerAreaList;
        }
        
        public void upsertApplicationBudgetCategory(List<ApplicationBudgetCategory2__c> appBugCatList) {
            upsert appBugCatList;
        }
        public void updateIndirectCosts(List<PaymentRequest__c> paymentList){
            paymentIds = new Set<Id>();
            for (PaymentRequest__c payreq : paymentList){
                paymentIds.add(payreq.Id);
            }
            List<PaymentBudgetCategory__c> indirectList = [SELECT Id,PaymentRequest__c,RequestedExpense__c FROM PaymentBudgetCategory__c WHERE PaymentRequest__c IN: paymentIds AND RowNumber__c = '213'];
            for (PaymentRequest__c payreq : paymentList) {
                for (PaymentBudgetCategory__c indirect : indirectList) {
                    if (indirect.PaymentRequest__c == payreq.Id) {
                        indirect.Q1__c = payreq.IndirectQ1__c;
                        indirect.Q2__c = payreq.IndirectQ2__c;
                        indirect.Q3__c = payreq.IndirectQ3__c;
                        indirect.Q4__c = payreq.IndirectQ4__c;
                        indirect.RequestedExpense__c = indirect.Q1__c + indirect.Q2__c + indirect.Q3__c + indirect.Q4__c;
                    }
                }
            }
            PaymentBudgetCategoryTriggerHelper.skipTrigger = true;
            update indirectList;
            PaymentBudgetCategoryTriggerHelper.skipTrigger = false;
        }
        
        public void closePaymentProcesses(Set<Id> paymentIds){
            USBEPaymentRequestTriggerHelper.skipTrigger = true;
            UOVCPaymentRequestTriggerHelper.skipTrigger = true;
            PaymentRequestTriggerHelper.skipTrigger = true;
            List<ProcessInstanceWorkItem> approvalItemList = [SELECT Id FROM ProcessInstanceWorkItem WHERE ProcessInstance.TargetObjectId IN: paymentIds AND ProcessInstance.Status = 'Pending'];
            for (ProcessInstanceWorkItem approvalItem : approvalItemList) {
                Approval.ProcessWorkItemRequest request = new Approval.ProcessWorkItemRequest();
                request.setComments('Rejected Due to Budget Revision');
                request.setAction('Reject');
                request.setWorkItemId(approvalItem.Id);
                Approval.ProcessResult result = Approval.process(request);
            }
            USBEPaymentRequestTriggerHelper.skipTrigger = false;
            UOVCPaymentRequestTriggerHelper.skipTrigger = false;
            PaymentRequestTriggerHelper.skipTrigger = false;
        }
        
        
        public void unlockObjectsInApprovalProcess(List<Id> lockedObjectIds) {
            //Find if any of the records are locked via an approval process
            Approval.UnlockResult[] unlockResultList = Approval.unlock(lockedObjectIds, false);
            /*List<Id> lockedObjectIds = new List<Id>();
            for (Id idIterator : objectIds) {
                if(Approval.isLocked(idIterator)) { 
                    lockedObjectIds.add(idIterator);
                }
            }*/
            /*
            List<SObject> results = new List<SObject>();
            for (Id id: lockedObjectIds) {
                results.add(Schema.getGlobalDescribe().get(String.valueOf(id.getSObjectType())).newSObject(Id = id));
                //results.add(Schema.getGlobalDescribe().get(String.valueOf(idIterator.getSObjectType())).newSObject(Id = idIterator));
            }
            if (results.size() > 0) {
                Approval.UnlockResult[] unlockResultList = Approval.unlock(results, false);
                for(Approval.UnlockResult unlockResultIterator : unlockResultList) { // Iterate through each returned result
                    if (unlockResultIterator.isSuccess()) { // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully unlocked record with ID: ' + unlockResultIterator.getId());
                    }
                    else { // Operation failed, so get all errors                       
                        for(Database.Error err : unlockResultIterator.getErrors()) {                 
                            System.debug('Error has occured with record unlocking'); // with: ' + err.getFields() + ' : ' + err.getStatusCode() + ' : ' + err.getMessage());
                        }
                    }
                }
            }*/
            //If there are any who are locked, unlock them
            //if (lockedObjectIds.size() > 0) { 
                //Approval.UnlockResult[] unlockResultList = Approval.unlock(lockedObjectIds, false);
                //List<Approval.UnlockResult> unlockResultList = Approval.unlock(lockedObjectIds);
                //Approval.UnlockResult[] unlockResultList = Approval.unlock(lockedObjectIds);
                /*for(List<Approval.UnlockResult> unlockResultIterator : unlockResultList) { // Iterate through each returned result
                    if (unlockResultIterator.isSuccess()) { // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully unlocked record with ID: ' + unlockResultIterator.getId());
                    }
                    else { // Operation failed, so get all errors                       
                        for(Database.Error err : unlockResultIterator.getErrors()) {                 
                            System.debug('Error has occured with record unlocking'); // with: ' + err.getFields() + ' : ' + err.getStatusCode() + ' : ' + err.getMessage());
                        }
                    }
                } */  
            //}
            //Now that they are unlocked, we can modify those objects
        }

        public void rejectPayments(List<PaymentRequest__c> paymentList){
            List<PaymentRequest__c> paymentToReject = new List<PaymentRequest__c>();
            for(PaymentRequest__c payment : paymentList){
                if(payment.Status__c == 'Created'){
                    payment.Status__c = 'Rejected';
                }
                paymentToReject.add(payment);
            }
            if(paymentToReject.size()>0){
                update paymentToReject;
            }
            ProcessInstanceWorkitem[] workItems = [SELECT Id FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId IN :paymentList AND ProcessInstance.Status = 'Pending'];
            Approval.ProcessWorkitemRequest pwr = new Approval.ProcessWorkitemRequest();
            //List<Approval.ProcessWorkitemRequest> pwrList = new List<Approval.ProcessWorkitemRequest>();
            for(ProcessInstanceWorkitem workItem : workItems ){
                if(workItem!=null){
                    pwr.setAction('Reject');
                    pwr.setWorkItemId(workItem.id);
                    Approval.ProcessResult result = Approval.process(pwr);
                }
            }
            List<Task> taskList = [Select id from Task where WhatId IN :paymentList AND Status IN ('Not Started','In Progress')];
            if(taskList!=null){
                delete taskList;
            }            
            /*
            if(pwrList!=null){
                SystemContextMethodsHelper contexthelper = new SystemContextMethodsHelper();
                contexthelper.rejectProcess(pwrList);
            }
            */
        }
        
        
        //Map<Id, Id> oldUserIdMapNewUserId = new Map<Id, Id>();
        //Map<String, Map<Id, Id>> businessRoleMapOldUserIdMapNewUserId = new Map<String, Map<Id, Id>>();
        //Map<Id, Map<String, Map<Id, Id>>> objectIdMapBusinessRoleMapOldUserIdMapNewUserId = new Map<Id, Map<String, Map<Id, Id>>>();
        public void tasksApprovalUserUpdate(List<Id> lockedObjectIds, Map<Id, Map<Id, Id>> objectIdMapOldUserIdMapNewUserId){
            //Parse the list of child object Ids to find which ones are suitable for mass update and which need direct object update    
            System.debug('MANUALDEBUG >>> objectIdMapOldUserIdMapNewUserId: ' + objectIdMapOldUserIdMapNewUserId);
            if (lockedObjectIds.size() > 0) { 
                //Update the approval tasks for the new role users
                List<Task> taskList = [SELECT Id, Status, OwnerId, WhatId FROM Task WHERE WhatId IN: lockedObjectIds AND Status != 'Completed'];
                for (Task taskIterator : taskList) {
                    Map<Id, Id> oldUserIdMapNewUserId = objectIdMapOldUserIdMapNewUserId.get(taskIterator.WhatId);
                    if ((oldUserIdMapNewUserId.keySet()).contains(taskIterator.OwnerId)) { //If the person the task is assigned to among those changed in the roles...
                        taskIterator.OwnerId = oldUserIdMapNewUserId.get(taskIterator.OwnerId); //Change the person the task is assigned to from the old user to the new user
                    }
                }
                System.debug('MANUALDEBUG >>> taskList: ' + taskList);
                update taskList;
        
                //Update the approval processes for the new role users
                List<ProcessInstance> processInstanceList = [
                    SELECT Id, TargetObjectId 
                    FROM ProcessInstance 
                    WHERE TargetObjectId IN: lockedObjectIds AND Status = 'Pending'];
                List<Id> processInstanceIds = new List<Id>();
                Map<Id, Id> processInstanceIdMapObjectId = new Map<Id, Id>();
                for (ProcessInstance processInstanceIterator : processInstanceList) {
                    processInstanceIds.add(processInstanceIterator.Id);
                    processInstanceIdMapObjectId.put(processInstanceIterator.Id, processInstanceIterator.TargetObjectId);
                }
                ProcessInstanceWorkitem[] workItems = [
                    SELECT Id, ActorId, ProcessInstanceId 
                    FROM ProcessInstanceWorkitem 
                    WHERE ProcessInstanceId IN: processInstanceIds];   
                //Map<ProcessInstanceWorkitem, ProcessInstance> workItemMapInstance = new Map<ProcessInstanceWorkitem, ProcessInstance>();
                System.debug('MANUALDEBUG >>> workItems' + workItems );
                for (ProcessInstanceWorkitem workItem : workItems) {
                    Map<Id, Id> oldUserIdMapNewUserId = objectIdMapOldUserIdMapNewUserId.get(processInstanceIdMapObjectId.get(workItem.ProcessInstanceId)); 
                    if ((oldUserIdMapNewUserId.keySet()).contains(workItem.ActorId)) { //If the person the approval process is assigned to is the one that is being changed in the roles...
                        workItem.ActorId = oldUserIdMapNewUserId.get(workItem.ActorId); //Change the person the approval process is assigned to from the old user to the new user
                    }
                }
                update workItems; 
                /*
                //Now that we're done with the editing, relock the records
                List<SObject> results = new List<SObject>();
                for (Id id: lockedObjectIds) {
                    results.add(Schema.getGlobalDescribe().get(String.valueOf(id.getSObjectType())).newSObject(Id = id));
                    //results.add(Schema.getGlobalDescribe().get(String.valueOf(idIterator.getSObjectType())).newSObject(Id = idIterator));
                }
                if (results.size() > 0) {
                    Approval.LockResult[] lockResultList = Approval.Lock(results, false);
                    for(Approval.LockResult lockResultIterator : lockResultList) { // Iterate through each returned result
                        if (lockResultIterator.isSuccess()) { // Operation was successful, so get the ID of the record that was processed
                            System.debug('Successfully locked record with ID: ' + lockResultIterator.getId());
                        }
                        else { // Operation failed, so get all errors                       
                            for(Database.Error err : lockResultIterator.getErrors()) {                 
                                System.debug('Error has occured with record locking'); // with: ' + err.getFields() + ' : ' + err.getStatusCode() + ' : ' + err.getMessage());
                            }
                        }
                    }
                }*/
                //Approval.LockResult[] lockResultList = Approval.Lock(lockedObjectIds, false);
                //List<Approval.LockResult> lockResultList = Approval.Lock(lockedObjectIds);
                /*for(List<Approval.LockResult> lockResultIterator : lockResultList) { // Iterate through each returned result
                    if (lockResultIterator.isSuccess()) { // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully locked record with ID: ' + lockResultIterator.getId());
                    }
                    else { // Operation failed, so get all errors                       
                        for(Database.Error err : lockResultIterator.getErrors()) {                 
                            System.debug('Error has occured with: ' + err.getFields() + ' : ' + err.getStatusCode() + ' : ' + err.getMessage());
                        }
                    }
                }*/   
            }
        }

}