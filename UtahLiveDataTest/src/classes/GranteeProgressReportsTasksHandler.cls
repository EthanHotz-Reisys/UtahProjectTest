/* This class runs everyday to check the Schedules for Grantee Progress Reports. All qualifying Schedules are converted to Progress Report tasks
*/
global class GranteeProgressReportsTasksHandler extends GNT.BatchApexHandler /*implements Database.Batchable<sObject> ,Schedulable, Database.Stateful*/{
 
  Integer recordCount;    
 //  global Database.QueryLocator start(Database.BatchableContext BC){
     global override String getQuery() {
    String query='Select Id,TermAndCondition__r.Award__c, TermAndCondition__r.Award__r.POUser__c, TermAndCondition__r.Award__r.EIN__c,TermAndCondition__r.Award__r.FederalGrantAwardIdFAIN__c,'+
    'TermAndCondition__r.Frequency__c, Status__c ,DueDate__c,TermAndCondition__r.ReportingFrequency__c, TermAndCondition__r.Award__r.Grant__r.InternalOrganization__c,'+
    'TermAndCondition__r.Award__r.Grant__r.ExternalOrganization__c, TermAndCondition__r.Award__r.GrantorOrganization__c,TermAndCondition__r.Award__r.DUNSNumber__c,TermAndCondition__r.Award__r.createdById,TermAndCondition__r.Award__r.Grant__r.GrantNumber__c,'+
    'TermAndCondition__r.ReportName__c, EndDate__c, StartDate__c, TermAndCondition__r.Award__r.Grant__c,TermAndCondition__r.Category__c,TermAndCondition__r.Award__r.Grant__r.Name from TermConditionSchedule__c where TaskCreationDate__c=LAST_N_DAYS:3 and TaskCreated__c=false and Status__c=\'Not Started\' and '+
    ' TermAndCondition__r.Award__r.Status__c IN (\'Activated\') and TermAndCondition__r.Award__r.RecordType.DeveloperName=\'Grantee\' and RecordType.DeveloperName=\'ProgressReport\' and ReportStatus__c=\'N/A\'';
  // return Database.getQueryLocator(query);
    return query;
   }
  
  //global void execute(Database.BatchableContext BC, List<TermConditionSchedule__c> scope){
     global override void execute(List<SObject> scope1){
    List<ProgressReports__c> lstProgressReports=new List<ProgressReports__c>();
    List<Task> progressReportTasks = new List<Task>();
  try{
    ProgressReportsConfig__c progressRptCfg = ProgressReportsConfig__c.getInstance('Grantee_Reports');
    List<ProgressReports__c> lst = prepareProgressReports(scope1);
    for(ProgressReports__c prRpt : lst){
         List<Task> progressReportRevisionTasks = GNT.TaskCreationHandler.createTasks(prRpt.AssignedTo__c,
                                                                    prRpt.Id, 'Create Progress Reports',
                                                                    prRpt.Title__c, null, false, null,
                                                                    'Approval', prRpt.Title__c, false);                                                           
         if(progressReportRevisionTasks != null && progressReportRevisionTasks.size() > 0) {
          progressReportTasks.add(progressReportRevisionTasks[0]);
          prRpt.status__c='Created';
          lstProgressReports.add(prRpt);
        }    
     }
       insert progressReportTasks;
       update lstProgressReports;
       if(lstProgressReports.size()>0)
         updateTermConditionSchedules(scope1);
     }catch(Exception exc)  { System.debug('An exception Occured while running the batch  '+exc); }
    }
 
 // In the Finish method, the list of notification users and batch runner (user) is sent a status mail 
  //  global void finish(Database.BatchableContext BC){
        global override void finish(){
	       String msgDetails = 'Task Completed for '+Date.today();
	       msgDetails+='\n  Total number of Reports created : '+ recordCount==null? 0 : recordCount;
            
       /*List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();      
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       mail.setTargetObjectId(UserInfo.getUserId());
       mail.saveAsActivity = false;            
       mail.setSubject(' GranteeProgressReportsTasksHandler has completed ');
       mail.setPlainTextBody(msgDetails);
       mails.add(mail);
       Messaging.sendEmail(mails);*/
       new GNT.EmailFeeder().TargetObjectID(UserInfo.getUserId()).subject(' GranteeProgressReportsTasksHandler has completed').htmlBody(msgDetails).send();
   }
   
   // This is the schedulable method which will be run as daily schedule.
   global void execute(SchedulableContext sc) 
    {
    ID BatchId = Database.executeBatch(new GranteeProgressReportsTasksHandler());
    }  
  
   private  List<ProgressReports__c> prepareProgressReports(List<TermConditionSchedule__c> lstSchedules){     
       List<ProgressReports__c> lstReports= new List<ProgressReports__c>();        
       List<TermCondition__c> terms = new List<TermCondition__c>();
       List<RecordType> rctTypeList= [select Id from RecordType where Name = 'Grantee' and SobjectType = 'ProgressReports__c' limit 1];

       for(TermConditionSchedule__c termSchedule : lstSchedules)// Getting list of TnC
             {
                ProgressReports__c   progressReport = new ProgressReports__c();
                progressReport.RecordType= rctTypeList[0];
                progressReport.Award__c=termSchedule.TermAndCondition__r.Award__c;
                progressReport.Grant__c=termSchedule.TermAndCondition__r.Award__r.Grant__c;
                progressReport.DUNSNumber__c=termSchedule.TermAndCondition__r.Award__r.DUNSNumber__c;
                progressReport.EIN__c=termSchedule.TermAndCondition__r.Award__r.EIN__c;
                progressReport.FederalGrant__c=termSchedule.TermAndCondition__r.Award__r.FederalGrantAwardIdFAIN__c;
                progressReport.Frequency__c=termSchedule.TermAndCondition__r.Frequency__c;
                progressReport.Status__c='Created';
                progressReport.ReportingFrequency__c=termSchedule.TermAndCondition__r.ReportingFrequency__c;
                progressReport.AssignedTo__c=termSchedule.TermAndCondition__r.Award__r.createdById;
                progressReport.ReportingPeriodStartDate__c = termSchedule.StartDate__c;
                progressReport.ReportingPeriodEndDate__c = termSchedule.EndDate__c;
                progressReport.GrantName__c=termSchedule.TermAndCondition__r.Award__r.Grant__r.Name;
                progressReport.RecipientOrganization__c=termSchedule.TermAndCondition__r.Award__r.Grant__r.InternalOrganization__c;
                progressReport.FederalAgency__c=termSchedule.TermAndCondition__r.Award__r.Grant__r.ExternalOrganization__c;
                progressReport.ReceipientAccountNumber__c=termSchedule.TermAndCondition__r.Award__r.Grant__r.GrantNumber__c;
                progressReport.Title__c=termSchedule.TermAndCondition__r.ReportName__c;  
                progressReport.TermandCondition__c=termSchedule.TermAndCondition__c;
                progressReport.ReportDueDate__c = termSchedule.DueDate__c;
                progressReport.ReportType__c=termSchedule.TermAndCondition__r.Category__c=='Federal Financial Report' ? 'Fiscal' : termSchedule.TermAndCondition__r.Category__c=='Federal Program/Progress Report' ? 'Program' : null;
                progressReport.ProgramApprover__c = termSchedule.TermAndCondition__r.Award__r.POUser__c;
                progressReport.OwnerId = termSchedule.TermAndCondition__r.Award__r.createdById;
                lstReports.add(progressReport);        
        }        
        recordCount=lstReports.size();
        if(lstReports.size()>0){
              insert lstReports;
              EmailTemplate emailTemplate = [Select Id from EmailTemplate where Name = 'GG Create Progress Reports' limit 1];
              for(Integer i = 0; i < lstReports.size(); i++){
                  Map<Id, String[]> recIdToAddressMap = new Map<Id, String[]>();
                  List<String> mailTo = new List<String>();
                  mailTo.add(lstSchedules.get(i).TermAndCondition__r.Award__r.CreatedBy.Email);
                  recIdToAddressMap.put(lstReports.get(i).Id, mailTo);
                   Contact cont = [select id, Email from Contact where email <> null limit 1];
                  AppUtils.sendEmailUsingTemplate(emailTemplate.Id, recIdToAddressMap, cont.Id, false);
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