global class SubmissionRequestCloseTask extends GNT.DynamicLayoutActionRedirect {
    private static Id recordId;
    private static Sobject sobj;
    global override Pagereference whenClicked() {
        String namespace = AppUtils.getNamespacePrefix();
        Boolean isError = false;
        Decimal match;
        Id appId;
        Id userId;
        ChangeRequest__c oldReq;
        List<Application__c> appList;
        Application__c app;
        Task task;
        recordId = layoutHolder.getPrimarySObject().Id;
        sobj = layoutHolder.getPrimarySObject();
        Savepoint sp = Database.setSavepoint();
        ChangeRequest__c changeReq = (ChangeRequest__c)layoutHolder.recordMap.get(namespace + 'ChangeRequest__c');
        oldReq = [Select Id, Status__c, Name, Type__c, DueDate__c, Comments__c, ApplicantComments__c,
                  Application__r.Id, Application__r.SubmittedBy__c
                  from ChangeRequest__c where id = :recordId Limit 1];
        System.debug('oldReq '+oldReq);
        try {
            if (oldReq.Status__c == 'In Progress' || oldReq.Status__c == 'Initiated') {
                appId = oldReq.Application__r.Id;
                appList = [Select ChangeRequestStatus__c, Announcement__r.MatchRequired__c, Announcement__r.GranteeMatch__c, Announcement__r.OrganizationName__c, ExternalOrganization__r.ApplicantType__c, FinalGrantAmountNegotiated__c, TotalFederalMatch__c, TotalCashMatch__c, TotalInKindMatch__c, TotalGrantCost__c, FormsValidated__c From Application__c Where id = :appId Limit 1];
                System.debug('applist '+applist);
                app = appList[0];
                if (app.TotalGrantCost__c == 0 && app.Announcement__r.OrganizationName__c == 'UOVC') {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please input the application budget in the Budget Tab '));
                    isError = true;
                } else if (app.TotalGrantCost__c != 0) {
                    match = (app.TotalCashMatch__c + app.TotalInKindMatch__c) / app.TotalGrantCost__c * 100;
                }
                if (match != null && app.Announcement__r.MatchRequired__c == true && match.setScale(2) < app.Announcement__r.GranteeMatch__c && app.ExternalOrganization__r.ApplicantType__c != 'Non Profit Victim Services' && app.Announcement__r.OrganizationName__c == 'UOVC') {
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please make sure that the value of ((Total Cash Match+Total In-Kind Match)*100/Grant including indirect cost) is greater than ' + app.Announcement__r.GranteeMatch__c + '%. The present cash match percentage is ' + match.setScale(2) + '%.'));
                    //isError = true;
                    throw new MyException(GNT.ErrorMessageHelper.fetchMessage('Please make sure that the value of ((Total Cash Match+Total In-Kind Match)*100/Grant including indirect cost) is greater than ' + app.Announcement__r.GranteeMatch__c + '%. The present cash match percentage is '));
                }

                //    if ( app.Announcement__r.OrganizationName__c.equalsIgnoreCase('UOVC')){
                //    if(app.TotalFederalMatch__c!=app.FinalGrantAmountNegotiated__c){
                //        throw new MyException(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-61202'));
                //    }
                //}

                //Update the field. TotalFederalmatch is for UOVC.
                //Budgets_Requested__c
                //if ( app.Announcement__r.OrganizationName__c.equalsIgnoreCase('USBE')){
                //    //if(app.TotalFederalMatch__c!=app.FinalGrantAmountNegotiated__c){
                //    //    throw new MyException(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-61202'));
                //    //}
                //}
                //if ( app.Announcement__r.OrganizationName__c.equalsIgnoreCase('UOVC')) {
                    if (oldReq.ApplicantComments__c == null) {
                        throw new MyException(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-61205'));
                    }
                //}
                if (!app.FormsValidated__c) {
                    // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Forms needs to be validated before the application can be submitted.'));
                    throw new ApplicantCommentsMissingException(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-61201'));
                }
                
                if (app.Announcement__r.OrganizationName__c == 'UOVC'){
	                app.ChangeRequestStatus__c = 'Revision Request Completed';
	                update app;
	                String[] toAddresses = new String[] {};
	                List<User> userList = [SELECT Id, Email FROM User WHERE IsActive = true AND Id = : oldReq.Application__r.SubmittedBy__c LIMIT 1 ];
	                toAddresses.add(userList[0].Email);
	                Map<Id, String[]> recIdToAddressMap = new Map<Id, String[]> ();
	                recIdToAddressMap.put(changeReq.Id, toAddresses);
	                List<EmailTemplate> emailTemplate = [Select id From EmailTemplate Where DeveloperName = 'PreAwardRequestEvaluationCompleted' Limit 1];
	                Contact cont = [select id, Email from Contact where email <> null limit 1];
	                //AppUtils.sendEmailUsingTemplate(emailTemplate[0].Id, recIdToAddressMap, cont.Id, false);//
                	oldReq.Status__c = 'Submitted';
	                update oldReq;
	                updateTasks(UserInfo.getUserId(), oldReq.Id);
                } else{
                	GNT.TaskCreationHandler.createApprovalProcessTasks(oldReq.Id, 'USBE Approval', oldReq.Name, null, System.TODAY() + 7, 'This negotiation request has been submitted for internal approval',  true);
                }
            }
        } catch (Exception e) {
            Database.rollback(sp);
            System.debug('Error Occured -- ' + e);
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
            //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('M01-GRNTR-34727'));
            ApexPages.addMessage(myMsg);
            return null;
            //return new PageReference('/apex/'+namespace+'SubmissionRequestEdit?id='+appId);
        }

        return new PageReference('/apex/' + namespace + 'ApplicationView?id=' + appId);
    }


    public class MyException extends Exception {}
    public class ApplicantCommentsMissingException extends Exception {}
    /* Pranjali: This method is not used in this class and hence commenting it */

    private void updateTasks(String userId, String crId) {
        recordId = layoutHolder.getPrimarySObject().Id;
        system.debug('record Id is ' + recordId);
        ChangeRequest__c changeRequest = [Select Id, Status__c, CreatedById, ApplicationTitle__c, Application__c, Name, Type__c, DueDate__c, Comments__c,
                                          Application__r.Id, Application__r.SubmittedBy__c, Application__r.OwnerId
                                          from ChangeRequest__c where id = :recordId Limit 1];
        system.debug('tej debug' + changeRequest.createdbyId + ' Id' + changeRequest.Id + 'Name' + changeRequest.Name + 'Title' + changeRequest.ApplicationTitle__c);
        List<Task> taskList = [Select Id, Status, WhatId from Task where
                               OwnerId = :userId AND WhatId = :crId];
        for (Task t : taskList) {
            t.Status = 'Completed';
        }
        update taskList;
        GNT.TaskCreationHandler.createTasks(changeRequest.Application__r.OwnerId, changeRequest.Id, 'RevisionRequestSubmission', changeRequest.Name, null, false, System.TODAY() + 7, null, changeRequest.ApplicationTitle__c, true);

    }
}