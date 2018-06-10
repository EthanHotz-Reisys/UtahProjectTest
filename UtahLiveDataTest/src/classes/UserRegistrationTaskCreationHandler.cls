global with sharing class UserRegistrationTaskCreationHandler extends GNT.batchApexHandler{ /* implements Database.Batchable<sObject> {*/
    global UserRegistrationTaskCreationHandler(){
        
    }
 // global Database.QueryLocator start(Database.BatchableContext BC){
 global override String getQuery() {
    String query = 'Select Id, Name, TaskCreationFlag__c from UserRegistration__c where TaskCreationFlag__c=true AND Status__c=\'Submitted for Approval\'';
    //return Database.getQueryLocator(query);
    return query;
 }
 
// global void execute(Database.BatchableContext BC, List<UserRegistration__c> records) {
     global override void execute(List<SObject> scope){
        List<UserRegistration__c> records = (List<UserRegistration__c>)scope;
    List<UserRegistration__c> uRegToUpdate = new List<UserRegistration__c>();
    Savepoint sp = Database.setSavepoint();
    try{
        for(UserRegistration__c uReg : records)
        {
            uReg.TaskCreationFlag__c=false;
            uRegToUpdate.add(uReg);
            //GNT.TaskCreationHandler.createApprovalProcessTasks(uReg.Id, 'Review User Registration', uReg.Name, 'UserRegistrationApprover', System.TODAY() + 7,  true);
            GNT.TaskCreationHandler.createApprovalProcessTasks(uReg.Id, 'Review User Registration', uReg.Name, null, System.TODAY() + 7, uReg.Name, true);
            System.debug('UserRegistrationTaskCreationHandler>>>task  created ');
        }
        if(uRegToUpdate != null && uRegToUpdate.size() > 0){
            update uRegToUpdate;
            System.debug('UserRegistrationTaskCreationHandler>>>update done ');                
        }
    }catch(Exception ex){
        Database.rollback(sp);
        System.debug('UserRegistrationTaskCreationHandler>>>execute Exception ' + ex.getMessage());
    }
    
 }
 
// global void finish(Database.BatchableContext BC) {
 global override void finish(){
    
 }
 
}