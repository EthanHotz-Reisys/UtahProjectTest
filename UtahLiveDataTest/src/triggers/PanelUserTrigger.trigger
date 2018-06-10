/*
11/13/2014    Nakul     Created
*/
trigger PanelUserTrigger on PanelUser__c (after insert, before delete,after delete,before insert) {
    new PanelUserTriggerHelper().process();
}