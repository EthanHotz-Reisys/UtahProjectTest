/*
    Trigger for Review Object
    ***********************************************************
    Audit History
    ***********************************************************
    11/12/2014      Nakul         Created
    *********************************************************** 
*/

trigger ReviewTrigger on Review__c (before insert,after insert, after delete, before update, after update, before delete) {
    new ReviewTriggerHelper().process();
}