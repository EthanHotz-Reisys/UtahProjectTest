/* This class runs everyday to check the Schedules for Grantor Site Visit. All qualifying Schedules are converted to Site Visit tasks
*/
global class SiteVisitTasksHandler extends GNT.BatchApexHandler{ /* implements Database.Batchable<sObject> ,Schedulable, Database.Stateful{*/
 
  Integer recordCount,sVisitAge;
    
   //global Database.QueryLocator start(Database.BatchableContext BC){
     global override String getQuery() {
   String query='Select Id,TermAndCondition__r.Award__c,TermAndCondition__r.Grant__r.GranteePOC__r.Email,TermAndCondition__r.Award__r.createdById ,TermAndCondition__r.SiteVisitDateTime__c,TermAndCondition__r.VisitEndDateTime__c, Status__c,TaskCreationDate__c,TaskCreated__c,DueDate__c, '+
   'TermAndCondition__r.Frequency__c, TermAndCondition__r.Award__r.Grant__r.GranteePOC__r.Email, TermAndCondition__r.ReportingFrequency__c,TermAndCondition__r.Award__r.POUser__c,TermAndCondition__r.SiteVisitLocationText__c, '+
   'TermAndCondition__r.ReportName__c,Name,StartDate__c , EndDate__c,  TermAndCondition__r.Award__r.Grant__c,TermAndCondition__r.Category__c, TermAndCondition__r.Award__r.GrantAdministrator__c,'+
   'TermAndCondition__r.Award__r.Grant__r.Name,TermAndCondition__r.SiteVisitLocation__c,TermAndCondition__r.SecondaryLocation__c '+
   ' from TermConditionSchedule__c where TaskCreationDate__c=LAST_N_DAYS:7 AND TaskCreated__c=false AND TermAndCondition__r.Award__r.RecordType.Name=\'Grantor\' AND Status__c=\'Not Started\' AND TermAndCondition__r.Award__r.Status__c IN (\'Activated\') AND RecordType.Name =\'Site Visit\'';
    //return Database.getQueryLocator(query);
    return query;
   }

  
 // global void execute(Database.BatchableContext BC, List<TermConditionSchedule__c> scope){
      global override void execute(List<SObject> scope){
    List<SiteVisit__c> lstSiteVisits=new List<SiteVisit__c>();
    List<Task> siteVisitTasks = new List<Task>();
    try{     
      ProgressReportsConfig__c progressRptCfg = ProgressReportsConfig__c.getInstance('Grantor_Reports');
      List<SiteVisit__c> lst = prepareSiteVisits(scope);
      for(SiteVisit__c sVisit : lst){
      List<Task> siteVisitRevisionTasks = GNT.TaskCreationHandler.createTasks(sVisit.GrantAdministrator__c, sVisit.Id, 'Site Visit Preparation', 
                                          sVisit.SiteVisitName__c, null, false, System.TODAY() + 7, 'Populate site visit details', true);
      new GNT.EmailFeeder().TargetObjectID(sVisit.GrantAdministrator__c).template('SiteVisitCreated').contextRecordId(sVisit.Id).send();                                                      
       if(siteVisitRevisionTasks != null && siteVisitRevisionTasks.size() > 0) {
       siteVisitTasks.add(siteVisitRevisionTasks[0]);
       sVisit.status__c='Created';
       lstSiteVisits.add(sVisit);
        }
     }
      //  insert siteVisitTasks;
      //  update lstSiteVisits;
      //  if(lstSiteVisits.size()>0)
          updateTermConditionSchedules(scope);
     }catch(Exception exc)  { System.debug('An exception Occured while running the batch  '+exc); }     
    }
 
 // In the Finish method, the list of notification users and batch runner (user) is sent a status mail 
  //  global void finish(Database.BatchableContext BC){ 
       global override void finish(){
       //AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =
     //       :BC.getJobId()];       
       String msgDetails = 'Task Completed for '+Date.today();
         msgDetails+='<br/>  Total number of Reports created : '+ recordCount==null? 0 : recordCount;
       /*List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();   
         Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();             
         mail.setTargetObjectId(UserInfo.getUserId());
         mail.saveAsActivity = false;
         mail.setSubject(' SiteVisitTasksHandler has completed');
         mail.setPlainTextBody(msgDetails);
         mails.add(mail);
         Messaging.sendEmail(mails); */
         if(recordCount!=null && recordCount>0){
            new GNT.EmailFeeder().TargetObjectId(UserInfo.getUserId()).subject('SiteVisitTasksHandler has completed').htmlBody(msgDetails).send();
         }
         scheduleMe();       
   }
   
   global static void scheduleMe() {
       // CreateCommunityUserBatch batch = new CreateCommunityUserBatch();
        SiteVisitTasksHandler batch = new SiteVisitTasksHandler();
        String cronExpression = GNT.BatchApexJobScheduler.prepareJobsSchTime(System.now(), 2);
        String jobName = GNT.BatchApexJobScheduler.getUniqueJobName('SiteVisitTasksHandler');
        if (!Test.isRunningTest()) {
            System.schedule(jobName, cronExpression, new GNT.BatchApexJobScheduler(batch, 1));
        }
    }
   
   // This is the schedulable method which will be run as daily schedule.
   global void execute(SchedulableContext sc) 
    {
    ID BatchId = Database.executeBatch(new SiteVisitTasksHandler());
    }  
  
   private  List<SiteVisit__c> prepareSiteVisits(List<TermConditionSchedule__c> lstSchedules){
       List<SiteVisit__c> lstReports= new List<SiteVisit__c>();
       List<RecordType> lst = [SELECT Id FROM RecordType where SObjectType='SiteVisit__c' and DeveloperName='Grantor' Limit 1];
       Id rcrdTypeId = lst[0].Id;
       List<TermCondition__c> terms = new List<TermCondition__c>();         
       for(TermConditionSchedule__c termSchedule : lstSchedules){
            SiteVisit__c   siteVisit= new SiteVisit__c();
            siteVisit.Award__c=termSchedule.TermAndCondition__r.Award__c;
            siteVisit.Grant__c=termSchedule.TermAndCondition__r.Award__r.Grant__c;
            siteVisit.Frequency__c=termSchedule.TermAndCondition__r.Frequency__c;
            siteVisit.status__c='Created';
            siteVisit.RecordTypeId=rcrdTypeId;
            siteVisit.VisitDateandTime__c=DateTime.newinstance(termSchedule.StartDate__c.year(),termSchedule.StartDate__c.month(),termSchedule.StartDate__c.day(),termSchedule.TermAndCondition__r.SiteVisitDateTime__c.hour(),termSchedule.TermAndCondition__r.SiteVisitDateTime__c.minute(),0);
            siteVisit.VisitEndDateTime__c=DateTime.newinstance(termSchedule.EndDate__c.year(),termSchedule.EndDate__c.month(),termSchedule.EndDate__c.day(),termSchedule.TermAndCondition__r.VisitEndDateTime__c.hour(),termSchedule.TermAndCondition__r.VisitEndDateTime__c.minute(),0);
            siteVisit.ReportingFrequency__c=termSchedule.TermAndCondition__r.ReportingFrequency__c;                    
            siteVisit.ReportingPeriodStartDate__c = termSchedule.StartDate__c;
            siteVisit.ReportingPeriodEndDate__c = termSchedule.EndDate__c;
            siteVisit.ApplicantEmail__c = termSchedule.TermAndCondition__r.Award__r.Grant__r.GranteePOC__r.Email;
            if(termSchedule.TermAndCondition__r.SiteVisitLocation__c=='Primary Place of Performance')                                
             siteVisit.SiteLocation__c=termSchedule.TermAndCondition__r.SiteVisitLocationText__c;
            else
             siteVisit.SiteLocation__c=termSchedule.TermAndCondition__r.secondaryLocation__c;
            siteVisit.SiteVisitName__c=termSchedule.TermAndCondition__r.ReportName__c;  
            siteVisit.reportDueDate__c=termSchedule.DueDate__c;
            siteVisit.ProgramApprover__c=termSchedule.TermAndCondition__r.Award__r.POUser__c;
            siteVisit.ProjectManager__c=termSchedule.TermAndCondition__r.Award__r.createdById;
            siteVisit.TermandCondition__c=termSchedule.TermAndCondition__c;
            siteVisit.OwnerId = termSchedule.TermAndCondition__r.Award__r.Grant__r.GranteePOC__c;
            siteVisit.GrantAdministrator__c = termSchedule.TermAndCondition__r.Award__r.GrantAdministrator__c;
            siteVisit.Subawardee__c = termSchedule.TermAndCondition__r.Award__r.Grant__r.GranteePOC__c;
            lstReports.add(siteVisit);
         }        
        recordCount=lstReports.size();
           if(lstReports.size()>0){
             insert lstReports; 
              EmailTemplate emailTemplate = [Select Id from EmailTemplate where Name = 'Notify Grantee of the Site Visit' limit 1];
            for(Integer i = 0; i < lstReports.size(); i++){
              Map<Id, String[]> recIdToAddressMap = new Map<Id, String[]>();
              List<String> mailTo = new List<String>();
              mailTo.add(lstSchedules.get(i).TermAndCondition__r.Award__r.Grant__r.GranteePOC__r.Email);
              System.debug('To Address------------------->' + lstSchedules.get(i).TermAndCondition__r.Award__r.Grant__r.GranteePOC__r.Email);
              recIdToAddressMap.put(lstReports.get(i).Id, mailTo);
                Contact cont = [select id, Email from Contact where email <> null limit 1];
              //AppUtils.sendEmailUsingTemplate(emailTemplate.Id, recIdToAddressMap, cont.Id, false);
              
              }


           }
             
           return lstReports;
     }
     
  // Updating the Term Condition Schedule records so that duplicate reports are not created
      private  void updateTermConditionSchedules(List<TermConditionSchedule__c> lstSchedules){
        
         for(TermConditionSchedule__c termSchedule : lstSchedules){
            termSchedule.Status__c='Completed';
            termSchedule.TaskCreated__c=true;
          }
          update lstSchedules;
         }    
   }