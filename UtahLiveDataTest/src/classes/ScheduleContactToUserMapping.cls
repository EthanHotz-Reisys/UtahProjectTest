/**
* This batch class updates ContactReference field in the user object for all standard users
* @author: Sarat Mahavratayajula
*/

global with sharing class ScheduleContactToUserMapping extends GNT.BatchApexHandler/*implements Database.Batchable<sObject>*/{
    private Integer varSize = 0;
    //global Database.QueryLocator start(Database.BatchableContext BC) {
         global override String getQuery() {
        String query = 'select Id,UserReference__c,FirstName,LastName from contact where '+ 
                        'UserReference__c != null';
       // return Database.getQueryLocator(query);
       return query;
    }

//    global void execute(Database.BatchableContext BC,List<Contact> records) {
         global override void execute(List<SObject> sObjRecords){
        List<User> userUpdateList = new List<User>();
        Savepoint sp = Database.setSavepoint();
        List<Contact> records = (List<Contact>)sObjRecords;
        try {
            if(records.size() > 0 ){
                Set<Id> userReferenceIds = new Set<Id>();
                for(Contact c : records) {
                    system.debug('User reference ' + c.UserReference__c);
                    userReferenceIds.add(c.UserReference__c);
                }

                List<User> userList = [select Id,ContactReference__c from User where
                                        UserType = 'Standard' and Id IN :userReferenceIds];


                for(Contact con : records) {
                    for(User key : userList) {
                        if(key.ContactReference__c == null && key.Id == con.UserReference__c){
                            User u = new User();
                            u.Id = key.Id;
                            u.ContactReference__c = con.Id;
                            userUpdateList.add(u);
                        }
                    }
                }
                UserTriggerHelper.skipTrigger = true;
                system.debug('Updating ' + userUpdateList.size() + ' number of users');
                if(userUpdateList.size() > 0) {
                    varSize = userUpdateList.size();
                    update(userUpdateList);
                }
                
            }
        }
        catch (Exception ex) {
            Database.rollback(sp);
        }
    }

   // global void finish(Database.BatchableContext BC) {
    global override void finish(){
      // Implement interfaces to send emails and attachment
      system.debug(varSize);
      if(varSize > 0) {

      }
    }

    /*global static void scheduleMe() {
        ScheduleContactToUserMapping batch = new ScheduleContactToUserMapping();
        String cronExpression = GNT.BatchApexJobScheduler.prepareJobsSchTime(System.now(), 5);
        String jobName = GNT.BatchApexJobScheduler.getUniqueJobName('ScheduleContactToUserMapping');
        if (!Test.isRunningTest()) {
            System.schedule(jobName, cronExpression, new GNT.BatchApexJobScheduler(batch, 1));
        }
    }*/ 

}