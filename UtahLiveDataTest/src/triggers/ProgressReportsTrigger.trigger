trigger ProgressReportsTrigger on ProgressReports__c (before insert,after insert,after update,before update,after delete,before delete) {
 
 new ProgressReportsTriggerHelper().process();
}