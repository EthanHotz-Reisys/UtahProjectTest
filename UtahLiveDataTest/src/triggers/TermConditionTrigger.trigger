/*
   Trigger for TermCondition Object
  ***********************************************************
  Audit History
  ***********************************************************
  05/19/2014    Nakul Kadam             Created
  *********************************************************** 
*/
trigger TermConditionTrigger on TermCondition__c (before insert, before update, after insert, after update) {
  new TermConditionTriggerHelper().process();
}