global with sharing class EmailNotificationHandler implements Database.Batchable<sObject>, Database.Stateful {
    global List<RolesandResponsibilities__c> updatedRoles;

    global EmailNotificationHandler(){
        
    }
 global Database.QueryLocator start(Database.BatchableContext BC){
 
    String query = 'SELECT Name__c,BusinessRole__c,Name__r.Email,RecordType.Name FROM RolesandResponsibilities__c WHERE EmailNotificationStatus__c= \'Queued\'';
    return Database.getQueryLocator(query);
 }
 
 global void execute(Database.BatchableContext BC, List<RolesandResponsibilities__c> records) {
   List<RolesandResponsibilities__c> newRecords=records;
   List<String> reviewers = new List<String>();
   List<String> strategicRoles = new List<String>();
   updatedRoles = records;

   List<EmailTemplate> emailtemp = [SELECT Id,CreatedById,Name FROM EmailTemplate /*WHERE Name = 'Grantee Notify Reviewer to Review Pre-Application'*/];
   try{
        for(RolesandResponsibilities__c roles: newRecords){
            // String name = [Select Name from RecordType where Id =:roles.RecordTypeId limit 1].name;
            if(roles.TaskCreated__c){
                if(roles.Name__r.Email!=null){
                    List<String> emailId=new List<String>();
                    emailId.add(roles.Name__r.Email);
                    for(Emailtemplate x:emailtemp){
                        //if(x.Name.equals('Notify Review for '+roles.RecordType.Name)){
                        if(x.Name.equals('Grantee Notify Reviewer to Review Pre-Application')){
                            sendEmail(emailId,x);
                        }
                    }
                }

            }
            else{
                if(roles.Name__r.Email!=null){
                    List<String> emailId=new List<String>();
                    emailId.add(roles.Name__r.Email);
                    for(Emailtemplate x:emailtemp){
                        if(x.Name.equals('Grantee Notify Reviewer to Review Pre-Application')){
                            sendEmail(emailId,x);
                        }
                    }
                }
            }


        }
        // sendEmail(reviewers,emailTemp);
        

   }
   catch(Exception e){
    System.debug('Email Notification Handler >>>execute Exception ' + e.getMessage());
   }
    
 }
 
 global void finish(Database.BatchableContext BC) {
    try{
        for(RolesandResponsibilities__c role: updatedRoles){
            role.EmailNotificationStatus__c = 'Processed';
        }
        update updatedRoles;

       // scheduleMe();
    }
    catch(Exception e){
        System.debug('Exception -->'+e);
    }
    
 }

 global void sendEmail(List<String> addresses, Emailtemplate emailTmp){

   /* Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
    string [] toaddress=addresses;
    email.setTemplateId(emailTmp.Id);
    // swati : added 
    email.setTargetObjectId(emailTmp.CreatedById);
    email.saveAsActivity = false;  
    //
    email.setToAddresses(toaddress);
    Messaging.sendEmail(New Messaging.SingleEmailMessage[]{email});*/
    
    new GNT.EmailFeeder().toEmail(String.join(addresses,',')).template(emailTmp.Name).TargetObjectId(UserInfo.getUserId());
 }

 global static void scheduleMe() {
        EmailNotificationHandler batch = new EmailNotificationHandler();
        //String cronExpression = GNT.BatchApexJobScheduler.prepareJobsSchTime(System.now(),2);
        String jobName = GNT.BatchApexJobScheduler.getUniqueJobName('EmailNotificationHandler');
        if (!Test.isRunningTest()) {
            System.schedule(jobName,'0 5 * * * ?', new GNT.BatchApexJobScheduler(batch, 1));
        }
    }

 
}