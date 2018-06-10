/*
    This class has methods to execute methods related to account trigger
    **********************************************************
    Audit History
    **********************************************************
    2014-08-08  Ryan Chadwick           create
    **********************************************************  
*/

trigger AmendmentRequestTrigger on AmendmentRequest__c (before insert, before update,after insert, after update) {
    new AmendmentRequestTriggerHelper().process();
}