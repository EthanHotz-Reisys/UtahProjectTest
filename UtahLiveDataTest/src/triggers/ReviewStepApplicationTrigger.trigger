/*
    Trigger for Review Step Application Object
    ***********************************************************
    Audit History
    ***********************************************************
    06/25/2014      Kunal Shah              Created
    *********************************************************** 
*/

trigger ReviewStepApplicationTrigger on ReviewStepApplication__c (
    before insert, 
    before update, 
    before delete, 
    after insert, 
    after update, 
    after delete, 
    after undelete) {

    new ReviewStepApplicationTriggerHelper().process();
        
}