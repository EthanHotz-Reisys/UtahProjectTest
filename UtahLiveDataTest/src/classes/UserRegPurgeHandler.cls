global with sharing class UserRegPurgeHandler extends GNT.BatchApexHandler{ /*Database.Batchable<sObject> {*/
    
 //global Database.QueryLocator start(Database.BatchableContext BC){
 global override String getQuery() {
    String query = 'Select id,name from UserRegistration__c ' +
                    'where Status__c IN(\'In Progress\',\'New\')'; 
                
    
    //return Database.getQueryLocator(query);
    return query;
 }
 
 //global void execute(Database.BatchableContext BC, List<UserRegistration__c> records) {
   global override void execute(List<SObject> scope){
    List<UserRegistration__c> records = (List<UserRegistration__c>)scope;
    List<UserRegistration__c> uRegToDelete = new List<UserRegistration__c>();
   
    
   
    Savepoint sp = Database.setSavepoint();
    try{
        for(UserRegistration__c uReg : records){
            
            uRegToDelete.add(uReg);
            }
            
     if(uRegToDelete.size()>0){
            delete uRegToDelete;
        }
            
           
   }catch(Exception ex){
        Database.rollback(sp);
        System.debug('UserRegPurgeHandler >>>execute Exception ' + ex.getMessage());
    }
    
 }
 
// global void finish(Database.BatchableContext BC) {
      global override void finish(){
      
 }
 

     global static void scheduleMe() {
        UserRegPurgeHandler  batch = new UserRegPurgeHandler();
        String cronExpression = GNT.BatchApexJobScheduler.prepareJobsSchTime(System.now(), 2);
        String jobName = GNT.BatchApexJobScheduler.getUniqueJobName('UserRegPurgeHandler');
        if (!Test.isRunningTest()) {
            System.schedule(jobName, cronExpression, new GNT.BatchApexJobScheduler(batch, 1));
        }
    } 
 
}