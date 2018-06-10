/*
    Trigger on Review Group Object
    **********************************************************
    Audit History
    **********************************************************
    2014-05-05      Ryan Chadwick               created 
    **********************************************************  
*/

 trigger ReviewGroupTrigger on ReviewGroup__c (before insert , after insert, before update,after update, 
    before delete, after delete) {

    new ReviewGroupTriggerHelper().process();
}