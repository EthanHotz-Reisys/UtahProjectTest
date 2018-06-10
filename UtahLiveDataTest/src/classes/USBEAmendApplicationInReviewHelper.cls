//Reset Helper
global with sharing class USBEAmendApplicationInReviewHelper {
    global static void process(Set<Id> appIdSet){

        Map<String, Set<Id>> appIdMap = resolveApplicationIds(appIdSet);

        /*
        List<ChangeRequest__c> changeReqList = new List<ChangeRequest__c>([SELECT Id, Name FROM ChangeRequest__c WHERE Application__c IN :appIdSet]);
        delete changeReqList;
        */
        List<PanelApplication__c> panelAppList = new List<PanelApplication__c>([SELECT Id, Name, (SELECT Id, ReviewPanel__c, PanelUser__c FROM Reviews__r WHERE Status__c != 'Assigned') FROM PanelApplication__c WHERE Application__c IN :appIdMap.get('noAwardAppIdSet')]);
        Map<Id, Integer> panelUserIdCountMap = new Map<Id, Integer>();
        for(PanelApplication__c panelApp : panelAppList){
            for(Review__c review : panelApp.Reviews__r){
                if(!panelUserIdCountMap.containsKey(review.PanelUser__c)){
                    panelUserIdCountMap.put(review.PanelUser__c, 0);
                }
                panelUserIdCountMap.put(review.PanelUser__c, panelUserIdCountMap.get(review.PanelUser__c) + 1);
            }
        }

        List<PanelUser__c> panelUserList = [SELECT Id, NoOfApplicationsAssigned__c FROM PanelUser__c WHERE Id IN :panelUserIdCountMap.keySet()];
        for(PanelUser__c panelUser : panelUserList){
            panelUser.NoOfApplicationsAssigned__c = (panelUser.NoOfApplicationsAssigned__c == null ? 0 : panelUser.NoOfApplicationsAssigned__c) - panelUserIdCountMap.get(panelUser.Id);
        }
        update panelUserList;

        delete panelAppList;

        List<ReviewStepApplication__c> rsaList = new List<ReviewStepApplication__c>([SELECT Id, Name FROM ReviewStepApplication__c WHERE Application__c IN :appIdMap.get('noAwardAppIdSet')]);
        delete rsaList;

        List<Application__c> appNeedUpdate = new List<Application__c>([SELECT Id, Name, Status__c, AwardDecisionStatus__c, ChangeRequestStatus__c, 
                                                                            FinalApproverComments__c, FinalGrantAmountNegotiated__c, LastReviewDecision__c, 
                                                                            LastReviewStep__c, MgmtRecAmount__c, ObligatedAmount__c, OwnerId 
                                                                            FROM Application__c WHERE Id IN :appIdMap.get('noAwardAppIdSet')]);
        
        for(Application__c app : appNeedUpdate){
            app.Status__c = 'Created';
            app.AwardDecisionStatus__c = null;
            app.ChangeRequestStatus__c = null;
            app.FinalApproverComments__c = null;
            app.FinalGrantAmountNegotiated__c = null;
            app.LastReviewDecision__c = null;
            app.LastReviewStep__c = null;
            app.MgmtRecAmount__c = 0;
            app.ObligatedAmount__c = 0;
        }
        
         ApplicationTriggerHelperUSBE.skipTrigger = true;
        update appNeedUpdate;
        ApplicationTriggerHelperUSBE.skipTrigger = false;
        
        /*
        List<Task> appTaskList = new List<Task>();
        for(Application__c app : appNeedUpdate){
            appTaskList.add(GNT.TaskCreationHandler.createTasks(app.OwnerId,
                app.Id,'Modify Application',
                'Modify Application ' + app.Name, null, false, null,
                'Review', 'Modify Application ' + app.Name, false
            )[0]);
        }

        insert appTaskList;
        */
        List<GNT.TaskCreationHandler.TaskBulkClass> tasksList = new List<GNT.TaskCreationHandler.TaskBulkClass>();
        for(Application__c app : appNeedUpdate){
            if(app.OwnerId.getSObjectType() == User.SObjectType) {
                GNT.TaskCreationHandler.TaskBulkClass task = new GNT.TaskCreationHandler.TaskBulkClass();
                task.ownerUserId = app.OwnerId;
                task.recordId = app.Id;
                task.action = 'Modify Application';
                task.recordName = app.Name;
                task.subject = 'Modify Application ' + app.Name;
                tasksList.add(task);
            }
        }
        List<Task> insertedTaskList = GNT.TaskCreationHandler.createBulkTasks(tasksList, true);         
        
        List<GNT.EmailFeeder> emails = new List<GNT.EmailFeeder>();
        for(Application__c app : appNeedUpdate){
            emails.add(new GNT.EmailFeeder().contextRecordId(app.Id).subject('test').plainTextBody('test').TargetObjectId(app.OwnerId));
        }

        GNT.EmailFeeder.SendEmails(emails);
        

    }

    global static Map<String, Set<Id>> resolveApplicationIds(Set<Id> appIdSet){
        List<Award__c> awardList = new List<Award__c>([SELECT Id, Name, Application__c FROM Award__c WHERE Application__c IN :appIdSet]);
        Set<Id> awardAppIdSet = new Set<Id>();
        Set<Id> noAwardAppIdSet = new Set<Id>();

        for(Award__c award : awardList){
            if(!awardAppIdSet.contains(award.Application__c)){
                awardAppIdSet.add(award.Application__c);
            }
        }
        for(Id appId : appIdSet){
            if(!awardAppIdSet.contains(appId)){
                noAwardAppIdSet.add(appId);
            }
        }

        Map<String, Set<Id>> result = new Map<String, Set<Id>>();
        result.put('awardAppIdSet', awardAppIdSet);
        result.put('noAwardAppIdSet', noAwardAppIdSet);
        return result;
    }
    
    global static void updateAwardAllocatedAmounts (Map<Id, Decimal> applications){
        //Get Awards that are active, are in active grants, and are for the applications passed to it (thus of the correct type for USBE) 
        List<Award__c> awards = new List<Award__c>([
            SELECT Id, Name, Application__c, Status__c, AllocatedAmount__c, Grant__c, Grant__r.Status__c 
            FROM Award__c 
            WHERE Application__c IN: applications.keySet() AND Status__c = 'Activated']);
        //Set active Award allocated amounts from appIdMapAllocation
        List<Award__c> results = new List<Award__c>();
        for(Award__c award : awards) {
            //Doublecheck the applications passed and if the allocations actually changed
            if (applications.containsKey(award.Application__c) && award.AllocatedAmount__c != applications.get(award.Application__c)) {
                award.AllocatedAmount__c = applications.get(award.Application__c); 
                results.add(award);
            }
        }
        if (results.size() > 0) {
            update results;
        }   
    }
    
}