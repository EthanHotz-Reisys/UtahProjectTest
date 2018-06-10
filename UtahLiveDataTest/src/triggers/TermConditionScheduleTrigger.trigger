/*
   Trigger for TermConditionSchedule Object
  ***********************************************************
  Audit History
  ***********************************************************
  03/03/2015    Nishit Babaria             Created
  *********************************************************** 
*/
trigger TermConditionScheduleTrigger on TermConditionSchedule__c (before insert, before update) {
  new TermConditionScheduleTriggerHelper().process();
}