/* This class runs everyday to check the Schedules for Grantee Site Visit. All qualifying Schedules are converted to Site Visit tasks
*/
global class GranteeSiteVisitTasksHandler extends GNT.BatchApexHandler /* implements Database.Batchable<sObject> ,Schedulable, Database.Stateful*/{ 
   Integer recordCount,sVisitAge;
   
   //global Database.QueryLocator start(Database.BatchableContext BC){ 
   global override String getQuery(){  
    String query='Select Id,TermAndCondition__r.Award__c,TermAndCondition__r.Award__r.createdById , Status__c,TaskCreationDate__c,TaskCreated__c,DueDate__c,TermAndCondition__r.SiteVisitDateTime__c, '+
   'TermAndCondition__r.Frequency__c, TermAndCondition__r.ReportingFrequency__c,TermAndCondition__r.SiteVisitLocationText__c, '+
   'TermAndCondition__r.ReportName__c,Name,StartDate__c , TermAndCondition__r.Award__r.POUser__c,EndDate__c,  TermAndCondition__r.Award__r.Grant__c,TermAndCondition__r.Category__c, '+
   'TermAndCondition__r.Award__r.Grant__r.Name,TermAndCondition__r.SiteVisitLocation__c,TermAndCondition__r.SecondaryLocation__c '+
   ' from TermConditionSchedule__c where TaskCreationDate__c=LAST_N_DAYS:3 AND TaskCreated__c=false AND TermAndCondition__r.Award__r.RecordType.DeveloperName=\'Grantee\' AND TermAndCondition__r.Award__r.Status__c IN (\'Activated\')  AND Status__c=\'Not Started\' AND RecordType.DeveloperName =\'SiteVisit\'';
   //return Database.getQueryLocator(query);
   return query;
   }
  
  //global void execute(Database.BatchableContext BC, List<TermConditionSchedule__c> scope){  
   global override void execute(List<SObject> scope){  
   List<SiteVisit__c> lstSiteVisits=new List<SiteVisit__c>();
   List<Task> siteVisitTasks = new List<Task>(); 
   try{
    ProgressReportsConfig__c progressRptCfg = ProgressReportsConfig__c.getInstance('Grantee_Reports');
    List<SiteVisit__c> lst = prepareSiteVisits(scope);
    for(SiteVisit__c sVisit: lst){
         List<Task> siteVisitRevisionTasks = GNT.TaskCreationHandler.createTasks(sVisit.ProjectManager__c,
                                                                    sVisit.Id, 'Create Site Visit Report',
                                                                    sVisit.Name, null, false, null,
                                                                    'Approval', sVisit.Name, false);                                                           
        if(siteVisitRevisionTasks != null && siteVisitRevisionTasks.size() > 0) {
        siteVisitTasks.add(siteVisitRevisionTasks[0]);
        sVisit.status__c='Created';
        lstSiteVisits.add(sVisit);
        }
     }
       insert siteVisitTasks;
       update lstSiteVisits;
       if(lstSiteVisits.size()>0)
           updateTermConditionSchedules(scope);
      }catch(Exception exc)  { System.debug('An exception Occured while running the batch  '+exc); }
    }
 
 // In the Finish method, the list of notification users and batch runner (user) is sent a status mail 
 //  global void finish(Database.BatchableContext BC){
    global override void finish(){  
     //  AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =
    //        :BC.getJobId()];       
       //List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();    
       String msgDetails = 'Task Completed for '+Date.today();
       msgDetails+='<br/>  Total number of Reports created : '+ recordCount==null? 0 : recordCount;
       /*Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       mail.setTargetObjectId(UserInfo.getUserId());
       mail.saveAsActivity = false;            
       mail.setSubject(' SiteVisitTasksHandler has completed  ');
       mail.setPlainTextBody(msgDetails);
       mails.add(mail);
       Messaging.sendEmail(mails);*/
       new GNT.EmailFeeder().TargetObjectId(UserInfo.getUserId() ).subject(' SiteVisitTasksHandler has completed ').htmlBody(msgDetails).send();
       
   }
   
   // This is the schedulable method which will be run as daily schedule.
   global void execute(SchedulableContext sc) 
    {
    ID BatchId = Database.executeBatch(new GranteeSiteVisitTasksHandler());
    }
  
   private  List<SiteVisit__c> prepareSiteVisits(List<TermConditionSchedule__c> lstSchedules){   
      List<SiteVisit__c> lstReports= new List<SiteVisit__c>();
      List<RecordType> lst = [SELECT Id FROM RecordType where SObjectType='SiteVisit__c' and DeveloperName='Grantee' Limit 1];
      Id rcrdTypeId = lst[0].Id;
      List<TermCondition__c> terms = new List<TermCondition__c>();
      for(TermConditionSchedule__c termSchedule : lstSchedules)// Getting list of TnC
         {
            SiteVisit__c   siteVisit= new SiteVisit__c();
            siteVisit.Award__c=termSchedule.TermAndCondition__r.Award__c;
            siteVisit.Grant__c=termSchedule.TermAndCondition__r.Award__r.Grant__c;
            siteVisit.Frequency__c=termSchedule.TermAndCondition__r.Frequency__c;
            siteVisit.status__c='Created';
            siteVisit.RecordTypeId=rcrdTypeId;
            siteVisit.VisitDateandTime__c=termSchedule.StartDate__c;
            siteVisit.VisitEndDateTime__c=termSchedule.EndDate__c;
            siteVisit.ReportingFrequency__c=termSchedule.TermAndCondition__r.ReportingFrequency__c;            
            siteVisit.ReportingPeriodStartDate__c = termSchedule.StartDate__c;
            siteVisit.ReportingPeriodEndDate__c = termSchedule.EndDate__c;
            if(termSchedule.TermAndCondition__r.SiteVisitLocation__c=='Primary Place of Performance')                                
               siteVisit.SiteLocation__c=termSchedule.TermAndCondition__r.SiteVisitLocationText__c;
            else
               siteVisit.SiteLocation__c=termSchedule.TermAndCondition__r.secondaryLocation__c;
            siteVisit.SiteVisitName__c=termSchedule.TermAndCondition__r.ReportName__c;  
            siteVisit.reportDueDate__c=termSchedule.DueDate__c;
            siteVisit.ProjectManager__c=termSchedule.TermAndCondition__r.Award__r.createdById;
            siteVisit.ProgramApprover__c=termSchedule.TermAndCondition__r.Award__r.POUser__c;
            siteVisit.TermandCondition__c=termSchedule.TermAndCondition__c;
            lstReports.add(siteVisit);
        }
        recordCount=lstReports.size();
           if(lstReports.size()>0)
              insert lstReports; 
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