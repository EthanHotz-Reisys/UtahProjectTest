/*
    11/13/2014    Nakul     Created
*/
trigger ReviewPanelTrigger on ReviewPanel__c (before insert, after insert, before update, after update) {
    new ReviewPanelTriggerHelper().process();
}