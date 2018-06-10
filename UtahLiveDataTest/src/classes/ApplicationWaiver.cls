global class ApplicationWaiver extends GNT.ApprovalDecisionActionHandler {
    public class NotWaivedWithdrawnException extends Exception {}
    public class NullContactIdException extends Exception {}
    Map<String,Object> resultMap = new Map<String,Object>();
    PageReference pageRef = null;

    global override String execute(){
        Savepoint savestate = Database.setSavepoint();
            String actionType; //Application Waived or Withdrawn
            EmailTemplate templateEmail;
            system.debug('Connecting...!');
            if(selectedAction == 'Approve'){
            
            Id appId = selectedRecordId;
            system.debug('id is' +appId);
            
            try{

            Application__c app = [SELECT Id, Announcement__c, Announcement__r.Program__c, Announcement__r.Program__r.OwnerId, Status__c, WaiveWithdraw__c, Approver__c from Application__c where id = :appId Limit 1];
            //List<Announcement__c> ann = [Select NumberOfApplications__c, ApplicationDeadlineWithDateTime__c, ExtensionDays__c, TimeExtensionAllowed__c from Announcement__c where Id = :app.Announcement__c];   
            

            if (app.WaiveWithdraw__c  == 'Waive') {
                actionType = 'waived';
                templateEmail = [SELECT Id FROM EmailTemplate WHERE Name = 'Award ready for subrecipient approval' LIMIT 1]; //Email template is application waived template
                app.Status__c = 'Waived';
            }
            else 
            {
                throw new NotWaivedWithdrawnException('You cannot do this unless the application was waived. '); //This can be changed later if we want to add more functionality to it
            }

            ApplicationTriggerHelper.skipTrigger = true;
            update app;
            ApplicationTriggerHelper.skipTrigger = false;
            User programOwner = [SELECT Id, ContactId, Email FROM User WHERE Id=:app.Announcement__r.Program__r.OwnerId];
            System.debug('MANUALDEBUG >>> program owner = ' + programOwner);
            System.debug('MANUALDEBUG >>> program owner email = ' + programOwner.Email);


            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTemplateId(templateEmail.Id);
            if (programOwner.ContactId != null) {
                mail.setTargetObjectId(programOwner.ContactId);
            }
            else {
                mail.setTargetObjectId('00535000000XfXGAA0');
                //throw new NullContactIdException('The program owner does not have a contactId associated with them. Email cannot be sent.');
                System.debug('Email sent to user with contactId 00535000000XfXGAA0');
            }
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail}, false);
            
            List<Task> taskList = [Select Id, Status, WhatId from Task where WhatId = :app.Id AND OwnerId=:app.Approver__c AND Status='In Progress'];
            if(taskList != null && taskList.size()>0){
                for(Task task: taskList){
                    task.Status='Completed';
                }                   
                update taskList;
            }
           

           }
           catch(NotWaivedWithdrawnException e) {
            Database.rollback(savestate);
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, ''+e);
            ApexPages.addMessage(errorMessage );
            return null;
        }
        //catch(NullContactIdException e) {
        //    Database.rollback(savestate);
        //    ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, ''+e);
        //    ApexPages.addMessage(errorMessage );
        //    return null;
        //}
        catch(Exception e){
            Database.rollback(savestate);
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, ''+e);
            ApexPages.addMessage(errorMessage );
            return null;
        }
        return ('Waiving Application');
            }
        return ('Waiving failed. Internal approval required.');
             
        }
}