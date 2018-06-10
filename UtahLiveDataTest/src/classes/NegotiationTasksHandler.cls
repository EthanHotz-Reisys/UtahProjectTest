/* This class runs everyday to check the Negotiation Tasks
* 1. Send a mail to Grantee POC for responding to Negotiation requests
* 2. After due date if negotiation is not completed, mark it to failed state
*/
global class NegotiationTasksHandler extends GNT.BatchApexHandler{ //implements Database.Batchable<sObject> ,Schedulable, Database.Stateful{
 
  Integer recordCount;    
//   global Database.QueryLocator start(Database.BatchableContext BC){
    global override String getQuery() {
    String query='Select Id,Name, DueDate__c,Application__c,Application__r.ExternalOrganization__c from ChangeRequest__c where GranteeNotified__c=false and DueDate__c =NEXT_N_DAYS:7 and Application__r.RecordType.DeveloperName=\'Grantor\'';   
   // return Database.getQueryLocator(query);
    return query;
   }
  
  //global void execute(Database.BatchableContext BC, List<ChangeRequest__c> scope){   
     global override void execute(List<SObject> scope){
     try{     
       notifyGrantee(scope);
       invalidateExpiredNegotiations(scope);   
       
       }catch(Exception exc)  { System.debug('An exception Occured while running the batch  '+exc); }
    }
 
 // In the Finish method, the list of notification users and batch runner (user) is sent a status mail 
   // global void finish(Database.BatchableContext BC){
       global override void finish(){
     //  AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =
     //       :BC.getJobId()];
       //List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();    
       String msgDetails = 'Task Completed for '+Date.today();
       msgDetails+='\n  Total number of Reports created : '+ recordCount==null? 0 : recordCount;
             /*Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
              mail.setTargetObjectId(UserInfo.getUserId());
              mail.saveAsActivity = false;            
              mail.setSubject(' ProgressReportsTasksHandler has completed');
              system.debug(msgDetails);
              mail.setPlainTextBody(msgDetails);
              mails.add(mail);
              Messaging.sendEmail(mails); 
              */
              new GNT.EmailFeeder().Subject(' ProgressReportsTasksHandler has completed').TargetObjectId(UserInfo.getUserId()).htmlBody(msgDetails).send();
       }
   
   // This is the schedulable method which will be run as daily schedule.
   global void execute(SchedulableContext sc) 
    {
    ID BatchId = Database.executeBatch(new ProgressReportsTasksHandler());
    }  
    
    private void notifyGrantee(List<ChangeRequest__c> crList){
    
        Set<Id> accIdSet = new Set<Id>();
        
        for(ChangeRequest__c cr: crList){
        accIdSet.add(cr.Application__r.ExternalOrganization__c);
        }
    
                String[] toAddresses = new String[] {};
                List<User> userList = [SELECT Id,Email FROM User WHERE IsActive = true AND AccountId IN: accIdSet LIMIT 2 ];
                for(User u: userList){  
                    toAddresses.add(u.Email);
                }
                if(toAddresses.size() > 0){ 
                    Map<Id, String[]> recIdToAddressMap = new Map<Id, String[]> ();
                   // recIdToAddressMap.put(changeReq.Id, toAddresses);
                    List<EmailTemplate> emailTemplate = [Select id From EmailTemplate Where DeveloperName = 'PreAwardRequestAssigned' Limit 1];// TODO, get new email name
                    Contact cont = [select id, Email from Contact where email <> null limit 1];
                    AppUtils.sendEmailUsingTemplate(emailTemplate[0].Id, recIdToAddressMap, cont.Id, false);// 
                }  
    
    }
     private void invalidateExpiredNegotiations(List<ChangeRequest__c> crList){
     
     Set<Id> appIdSet = new Set<Id>();
        
        for(ChangeRequest__c cr: crList){
           if(cr.DueDate__c<System.Today()){
           appIdSet.add(cr.Application__c);
           }
        
        }
        
        List<Application__c> appList = [Select Id, Name, Status__c from Application__c where Id IN : appIdSet];
        
        for(Application__c app :applist){
        app.Status__c='Revision Failed';
        }
        update appList;
        
     }
  
   }