/* This class runs everyday to check the Schedules for Grantor Progress Reports. All qualifying Schedules are converted to Progress Report tasks
*/
global class ProgressReportsTasksHandler extends GNT.BatchApexHandler /*implements  Database.Batchable<sObject> ,Schedulable, Database.Stateful*/{
  Integer recordCount;
  ProgressReportsConfig__c progressRptCfg;    
 //  global Database.QueryLocator start(Database.BatchableContext BC){
    global override String getQuery() {
    progressRptCfg = ProgressReportsConfig__c.getInstance('Grantor_Reports');
    String query='Select Id,TermAndCondition__r.Award__c,DueDate__c,TermAndCondition__r.Award__r.GrantAdministrator__c, TermAndCondition__r.Award__r.EIN__c,TermAndCondition__r.Award__r.FederalGrantAwardIdFAIN__c,'+
    'TermAndCondition__r.Frequency__c, Status__c , TermAndCondition__r.Award__r.Grant__r.GranteePOC__r.Email, TermAndCondition__r.ReportingFrequency__c,TermAndCondition__r.Award__r.createdbyId,TermAndCondition__r.Award__r.Grant__r.InternalOrganization__c,'+
    'TermAndCondition__r.Award__r.Grant__r.ExternalOrganization__c, TermAndCondition__r.Award__r.GrantorOrganization__c,TermAndCondition__r.Award__r.DUNSNumber__c,TermAndCondition__r.Award__r.Grant__r.GranteePOC__c,TermAndCondition__r.Award__r.Grant__r.GrantNumber__c,'+
    'TermAndCondition__r.ReportName__c, EndDate__c, StartDate__c, TermAndCondition__r.Award__r.Grant__c,TermAndCondition__r.Category__c,TermAndCondition__r.Award__r.Grant__r.Name from TermConditionSchedule__c where TaskCreationDate__c=LAST_N_DAYS:7' + ' and TaskCreated__c=false '+
    ' and Status__c=\'Not Started\' and TermAndCondition__r.Award__r.Status__c IN (\'Activated\')  and TermAndCondition__r.Award__r.RecordType.DeveloperName=\'Grantor\' and RecordType.DeveloperName=\'ProgressReport\' and ReportStatus__c=\'N/A\'';
   //return Database.getQueryLocator(query);
   return query;
   }
  
 // global void execute(Database.BatchableContext BC, List<TermConditionSchedule__c> scope){   
   global override void execute(List<SObject> scope){
    List<ProgressReports__c> lstProgressReports=new List<ProgressReports__c>();
    List<Task> progressReportTasks = new List<Task>();
    try{     
        Integer taskCreationAge = (Integer)progressRptCfg.TaskCreationAge__c; 
        List<ProgressReports__c> lst = prepareProgressReports(scope);
        for(ProgressReports__c prRpt : lst){
            List<Task> progressReportRevisionTasks = GNT.TaskCreationHandler.createTasks(prRpt.AssignedTo__c,
                                                                        prRpt.Id, 'Create Progress Reports',
                                                                        prRpt.Title__c, null, false, null,
                                                                        'Approval', prRpt.Title__c, false);
            system.debug('Recipient is ' +prRpt.AssignedTo__c);
        new GNT.EmailFeeder().TargetObjectID(prRpt.AssignedTo__c).template('ProgressReportCreated').contextRecordId(prRpt.Id).send();                                                         
             
             if(progressReportRevisionTasks != null && progressReportRevisionTasks.size() > 0) {
               progressReportTasks.add(progressReportRevisionTasks[0]);
               prRpt.status__c='Created';
               lstProgressReports.add(prRpt);
               }
       }
       insert progressReportTasks;
       update lstProgressReports;
       if(lstProgressReports.size()>0)
            updateTermConditionSchedules(scope);
     }catch(Exception exc)  { System.debug('An exception Occured while running the batch  '+exc); }
    }
 
 // In the Finish method, the list of notification users and batch runner (user) is sent a status mail 
   // global void finish(Database.BatchableContext BC){
     global override void finish(){
      // AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =
      //      :BC.getJobId()];
       List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();    
       String msgDetails = 'Task Completed for '+Date.today();
       msgDetails+='\n  Total number of Reports created : '+ recordCount==null? 0 : recordCount;
             /* Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
              mail.setTargetObjectId(UserInfo.getUserId());
              mail.saveAsActivity = false;            
              mail.setSubject(' ProgressReportsTasksHandler has completed ');
              system.debug(msgDetails);
              mail.setPlainTextBody(msgDetails);
              mails.add(mail);
              Messaging.sendEmail(mails);*/
              if(recordCount!=null && recordCount>0){
                new GNT.EmailFeeder().TargetObjectId(UserInfo.getUserId()).subject('ProgressReportsTasksHandler has completed').htmlBody(msgDetails).send();
              }
              scheduleMe();
       }
       
       global static void scheduleMe() {
       // CreateCommunityUserBatch batch = new CreateCommunityUserBatch();
        ProgressReportsTasksHandler batch = new ProgressReportsTasksHandler();
        String cronExpression = GNT.BatchApexJobScheduler.prepareJobsSchTime(System.now(), 2);
        String jobName = GNT.BatchApexJobScheduler.getUniqueJobName('ProgressReportsTasksHandler');
        if (!Test.isRunningTest()) {
            System.schedule(jobName, cronExpression, new GNT.BatchApexJobScheduler(batch, 1));
        }
    }
   
   // This is the schedulable method which will be run as daily schedule.
   global void execute(SchedulableContext sc) 
    {
    ID BatchId = Database.executeBatch(new ProgressReportsTasksHandler());
    }  
  
   private  List<ProgressReports__c> prepareProgressReports(List<TermConditionSchedule__c> lstSchedules){     
      List<ProgressReports__c> lstReports= new List<ProgressReports__c>();
      List<TermCondition__c> terms = new List<TermCondition__c>();
      List<RecordType> rctTypeList= [select Id from RecordType where Name = 'Grantor' and SobjectType = 'ProgressReports__c' limit 1];
      Map<Id,TermConditionSchedule__c> progressReportScheduleMap = new Map<Id, TermConditionSchedule__c>();
          
      for(TermConditionSchedule__c termSchedule : lstSchedules){ 
            ProgressReports__c   progressReport = new ProgressReports__c();
            progressReport.RecordTypeId= rctTypeList[0].Id;
            progressReport.Award__c=termSchedule.TermAndCondition__r.Award__c;
            progressReport.Grant__c=termSchedule.TermAndCondition__r.Award__r.Grant__c;
            progressReport.DUNSNumber__c=termSchedule.TermAndCondition__r.Award__r.DUNSNumber__c;
            progressReport.EIN__c=termSchedule.TermAndCondition__r.Award__r.EIN__c;
            progressReport.FederalGrant__c=termSchedule.TermAndCondition__r.Award__r.FederalGrantAwardIdFAIN__c;
            progressReport.Frequency__c=termSchedule.TermAndCondition__r.Frequency__c;
            progressReport.status__c='Created';
            progressReport.ReportingFrequency__c=termSchedule.TermAndCondition__r.ReportingFrequency__c;
            progressReport.AssignedTo__c=termSchedule.TermAndCondition__r.Award__r.Grant__r.GranteePOC__c; 
            progressReport.ReportingPeriodStartDate__c = termSchedule.StartDate__c;                                   
            progressReport.ReportingPeriodEndDate__c = termSchedule.EndDate__c;
            progressReport.GrantName__c=termSchedule.TermAndCondition__r.Award__r.Grant__r.Name;        
            progressReport.RecipientOrganization__c=termSchedule.TermAndCondition__r.Award__r.Grant__r.InternalOrganization__c;                                    
            progressReport.FederalAgency__c=termSchedule.TermAndCondition__r.Award__r.Grant__r.ExternalOrganization__c;
            progressReport.ReceipientAccountNumber__c=termSchedule.TermAndCondition__r.Award__r.Grant__r.GrantNumber__c;
            progressReport.Title__c=termSchedule.TermAndCondition__r.ReportName__c;  
            progressReport.ProgramApprover__c=termSchedule.TermAndCondition__r.Award__r.createdbyId;                                    
            progressReport.TermandCondition__c=termSchedule.TermAndCondition__c; 
            progressReport.ReportDueDate__c = termSchedule.DueDate__c;
            progressReport.GrantAdministrator__c = termSchedule.TermAndCondition__r.Award__r.GrantAdministrator__c;                                
            //progressReport.ReportType__c=termSchedule.TermAndCondition__r.Category__c=='Federal Financial Report' ? 'Fiscal' : termSchedule.TermAndCondition__r.Category__c=='Federal Program/Progress Report' ? 'Program' : null;
            progressReport.ReportType__c=termSchedule.TermAndCondition__r.Category__c=='Desk Review' ? 'Desk Review' : termSchedule.TermAndCondition__r.Category__c=='Progress Report' ? 'Progress' : termSchedule.TermAndCondition__r.Category__c=='Program Report' ? 'Program' : null;
            progressReport.OwnerId = termSchedule.TermAndCondition__r.Award__r.Grant__r.GranteePOC__c; 
            lstReports.add(progressReport);
        }
        recordCount=lstReports.size();
        if(lstReports.size()>0){
            insert lstReports;
        
            EmailTemplate emailTemplate = [Select Id from EmailTemplate where Name = 'GG Create Progress Reports' limit 1];
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
        for(TermConditionSchedule__c termSchedule : lstSchedules) {
           termSchedule.Status__c='Completed';
           termSchedule.TaskCreated__c=true;
          }
         update lstSchedules;
     } 
   }