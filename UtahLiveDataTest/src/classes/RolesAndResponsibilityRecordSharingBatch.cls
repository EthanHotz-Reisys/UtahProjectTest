global class RolesAndResponsibilityRecordSharingBatch extends GNT.BatchApexHandler{ /*implements Database.Batchable<sObject>{*/

     
     //global Database.QueryLocator start(Database.BatchableContext BC){
    global override String getQuery(){
      String query = 'select Id,Name__c,Agency__c,Program__c,StrategicPlan__c,Announcement__c,Application__c,PreApplication__c,AmendmentRequest__c,Award__c,ProgressReport__c' +
       ',RiskAssessment__c ,Closeout__c, SiteVisit__c,BusinessRole__c from RolesAndResponsibilities__c where BatchSharing__c = true';
       
       System.debug('==== <<<<<<  BATCH JOB START METHOD  >>>>>> ====');
      //return Database.getQueryLocator(query); 
      return query;
    }
    
    //global void execute(Database.BatchableContext BC, List<sObject> scope){
         global override void execute(List<SObject> scope){
        System.debug('==== <<<<<<  BATCH JOB EXECUTE METHOD  >>>>>> ====');
         List<RolesAndResponsibilities__c> rolesAndReponsibilities = scope;
         
         List<Id> applicationID = new List<Id>();
         List<RolesAndResponsibilities__c> lstRoleResp = new List<RolesAndResponsibilities__c>();
         Map<Id,Id> appOwnerId = new Map<Id,Id>();
         
         List<AccountShare> accountShare = new List<AccountShare>();        
         List<Program__Share> progShare = new List<Program__Share>();
         List<Application__Share> lstApplicationShare= new List<Application__Share>();

         for(RolesAndResponsibilities__c role : rolesAndReponsibilities ){
            if(role.Application__c!=null && role.BusinessRole__c !='Owner'){
                Application__Share appShare = new Application__Share();
                appShare.ParentId = role.Application__c;
                appShare.UserOrGroupId = role.Name__c;
                appShare.AccessLevel = 'Edit';
                appShare.RowCause = Schema.Application__Share.RowCause.SharingforReviewandApproval__c;
                lstApplicationShare.add(appShare);  
                role.BatchSharing__c = false;  
            } 
            if(role.Application__c!=null && role.BusinessRole__c =='Owner'){
              appOwnerId.put(role.Application__c,role.Name__c);
            } 
            
         }
         
         List<Application__c> lstApp = [Select OwnerId from Application__c where Id in: appOwnerId.keyset()]; 
         
             for(Application__c app: lstApp){     
                System.debug('==== <<<<<< OWNER IS UPDATE >>>>>> ===='+appOwnerId.get(app.Id));     
                app.OwnerId =  appOwnerId.get(app.Id);
             }            
             
             try{
                 update lstApp;
              }Catch(Exception e){ 
                System.debug('==== <<<<<< OWNER IS UPDATE >>>>>> ===='+e);
              }
         
         if(lstApplicationShare != null && lstApplicationShare.size() > 0){
             SystemContextMethodsHelper SystemContextMethodsHelper = new SystemContextMethodsHelper();
             SystemContextMethodsHelper.upsertApplicationShare(lstApplicationShare); 
         }
         if(!rolesAndReponsibilities.isEmpty()){
             update rolesAndReponsibilities;
         } 
           System.debug('==== <<<<<<  BATCH JOB IS FINSHED  >>>>>> ====');
     }
     
     // global void finish(Database.BatchableContext BC){
         global override void finish(){
          System.debug('==== <<<<<<  BATCH JOB IS FINSHED  >>>>>> ====');
          scheduleMe();
       }
       
       global static void scheduleMe() {
        RolesAndResponsibilityRecordSharingBatch batch = new RolesAndResponsibilityRecordSharingBatch();
        
        Integer scheduleTime = GNT.KeyValueStoreHelper.getIntegerValue('OwnerChangeTime',true); 
        String cronExpression = GNT.BatchApexJobScheduler.prepareJobsSchTime(System.now(), 2); 
        String jobName = GNT.BatchApexJobScheduler.getUniqueJobName('RolesAndResponsibilityRecordSharingBatch');  

        if (!Test.isRunningTest()) {
            System.schedule(jobName, cronExpression, new GNT.BatchApexJobScheduler(batch, 1));
        }
    }
      
 }