global with sharing class NotifyGrantorWaivedWithdrawnApp extends GNT.DynamicLayoutActionRedirect{
    
    public class NotWaivedWithdrawnException extends Exception {}
    public class NullContactIdException extends Exception {}
    
    global override PageReference whenClicked(){  
    
        Savepoint savestate = Database.setSavepoint();
        Map<String,Object> retVal = new Map<String,Object>();
        Id recordId = layoutHolder.getPrimarySObject().Id;
        System.debug('MANUALDEBUG >>> Application Id = ' + recordId);
        String actionType; //Application Waived or Withdrawn
        
        EmailTemplate templateEmail;
        
        try{
            Application__c currentApplication = [SELECT Id, Announcement__c, Announcement__r.Program__c, Announcement__r.Program__r.OwnerId, Status__c, WaiveWithdraw__c, Approver__c FROM Application__c WHERE Id =: recordId]; 
            System.debug('MANUALDEBUG >>> Application: ' + currentApplication);
            
            System.debug('MANUALDEBUG >>> waivewithdraw = ' + currentApplication.WaiveWithdraw__c);
            if (currentApplication.WaiveWithdraw__c  == 'Waive') {
                actionType = 'waived';
                templateEmail = [SELECT Id FROM EmailTemplate WHERE Name = 'Award ready for subrecipient approval' LIMIT 1]; //Email template is application waived template
                currentApplication.Status__c = 'Waived';
            }
            else if (currentApplication.WaiveWithdraw__c == 'Withdraw') {
                actionType = 'withdrawn';
                templateEmail = [SELECT Id FROM EmailTemplate WHERE Name = 'Award ready for subrecipient approval' LIMIT 1]; //Email template is application withdrawn template
                currentApplication.Status__c = 'Withdrawn';
            }
            else {
                throw new NotWaivedWithdrawnException('You cannot do this unless the application was waived or withdrawn'); //This can be changed later if we want to add more functionality to it
            }
            ApplicationTriggerHelper.skipTrigger = true;
            update currentApplication;
            ApplicationTriggerHelper.skipTrigger = false;
            User programOwner = [SELECT Id, ContactId, Email FROM User WHERE Id=:currentApplication.Announcement__r.Program__r.OwnerId];
            System.debug('MANUALDEBUG >>> program owner = ' + programOwner);
            System.debug('MANUALDEBUG >>> program owner email = ' + programOwner.Email);
            //Email to USBE program owner
            /*
            List<String> mailTo = new List<String>();
            Map<Id, String[]> recIdMapEmail = new Map<Id, String[]>();
            Map<Id, List<String>> recIdMapEmailString = new Map<Id, List<String>>();
            Map<Id, Map<Id, String[]>> appIdMapRecIdMapEmail = new Map<Id,Map<Id, String[]>>();
            mailTo.add(programOwner.Email);
            recIdMapEmail.put(recordId, mailTo);
            appIdMapRecIdMapEmail.put(recordId, recIdMapEmail);
            AppUtils.sendEmailUsingTemplate(emailTemplate.Id, recIdMapEmailString.get(recordId), programOwner.Id, false);
            */    
            
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
            
            List<Task> taskList = [Select Id, Status, WhatId from Task where WhatId = :currentApplication.Id AND OwnerId=:currentApplication.Approver__c AND Status='In Progress'];
            if(taskList != null && taskList.size()>0){
                for(Task task: taskList){
                    task.Status='Completed';
                }                   
                update taskList;
            }
            
            //Add message to page saying that the waiving was successful and has been sent for internal approval
            ApexPages.Message successMessage = new ApexPages.Message(ApexPages.Severity.INFO, 'Your application has been fully ' + actionType + '. An email notification has been sucessfully sent to the USBE program owner');
            ApexPages.addMessage(successMessage);            
        }
        catch(NotWaivedWithdrawnException e) {
            Database.rollback(savestate);
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, ''+e);
            ApexPages.addMessage(errorMessage );
            return null;
        }
        catch(NullContactIdException e) {
            Database.rollback(savestate);
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, ''+e);
            ApexPages.addMessage(errorMessage );
            return null;
        }
        catch(Exception e){
            Database.rollback(savestate);
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, ''+e);
            ApexPages.addMessage(errorMessage );
            return null;
        }
        
        PageReference pageref = Page.ApplicationView; 
        pageref.getParameters().put('Id',recordId);
        pageref.setRedirect(true); 
        return pageref;
        //return null;
    }
}