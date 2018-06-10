/*
    Trigger for Business Package Object
    ***********************************************************
    Audit History
    ***********************************************************
    12/14/2015      Davinder Singh             Created
    *********************************************************** 
*/
trigger BusinessPackageTrigger on BusinessPackage__c (before insert, after insert, before update, after update) {
    if( !BusinessPackageTriggerHelper.skipTrigger ){
        new BusinessPackageTriggerHelper().process();
    }
}