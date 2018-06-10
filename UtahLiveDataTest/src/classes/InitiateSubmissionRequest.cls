global class InitiateSubmissionRequest extends GNT.DynamicLayoutActionRedirect{
    private static Id recordId;
    private static Sobject sobj;
    
    global override Pagereference whenClicked(){ 
        List<Application__c> appList;
        List<ChangeRequest__c> changeReqList ;
        Application__c app;
        ChangeRequest__c changeReq;
        recordId = layoutHolder.getPrimarySObject().Id;
        sobj = layoutHolder.getPrimarySObject();
        String namespace = AppUtils.getNamespacePrefix();
        changeReqList = [Select Id,Status__c, Name, Type__c, DueDate__c,Comments__c,ApplicationTitle__c, Application__c
                          from ChangeRequest__c where id=:recordId Limit 1];
        System.debug('changeReqList-------->>>'+changeReqList);
        Savepoint sp = Database.setSavepoint();
        try{
            if(changeReqList.size() > 0 && changeReqList[0].Status__c == 'Not Initiated'){
                changeReq = changeReqList[0];
                
                changeReq.Status__c='Initiated';
                
                update changeReq; 
                appList = [Select id,Approver__c,Status__c, ChangeRequestStatus__c , DataEvaluator__c, GrantMonitor__c, 
                           ProjectOfficer__c, Announcement__r.AnnouncementName__c,ExternalOrganization__c,ExternalOrganization__r.PointofContactUser__c, FormsValidated__c, OwnerId
                           from Application__c Where id = :changeReq.Application__c Limit 1];
                           System.debug('appList-------->>>'+appList);
                if(appList.size()>0){
                    app = appList[0];
                    app.ChangeRequestStatus__c= 'Revision Request Assigned';
                    app.FormsValidated__c = false;
                    update app;
                    String[] toAddresses = new String[] {};
                    List<User> userList = [SELECT Id,Email FROM User WHERE IsActive = true AND AccountId =: app.ExternalOrganization__c LIMIT 1 ];
                    for(User u: userList){
                        GNT.TaskCreationHandler.createTasks(u.Id, changeReq.Id, 'Revision Request', app.Announcement__r.AnnouncementName__c, null, false, changeReq.DueDate__c, null, changeReq.ApplicationTitle__c, true);
                    }
                    User appUser = [SELECT Id, Email, AccountId, ContactId FROM User WHERE Id =: app.OwnerId];         
                    Map<Id, List<User>> accountIdMapUserList = new Map<Id, List<User>>();
                    accountIdMapUserList.put(app.ExternalOrganization__c, new List<User>{appUser});
                    AppUtils.TaskEmailWrapper taskEmailer = new AppUtils.TaskEmailWrapper();
                    taskEmailer.setObjectList(changeReq.Id);
                    taskEmailer.setUserList(appUser);
                    taskEmailer.setAccountIdMapUserList(accountIdMapUserList);
                    taskEmailer.setEmailTemplateDevName('Negotiation_Initiated');
                    String resultMessage = taskEmailer.massSendEmail();
                    ApplicationSnapshotHelper snapshot = new ApplicationSnapshotHelper();
                    snapshot.createSnapshot(new List<Id>{app.id});
                }
            }
       }
       catch(Exception e){
            Database.rollback(sp);
            ApexPages.addMessages(e);
            return null;
       }
       return new PageReference('/apex/'+namespace+'applicationview?id='+app.Id);
    }
}