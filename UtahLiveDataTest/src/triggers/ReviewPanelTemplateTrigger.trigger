/*
    11/17/2014    Nakul     Created
*/
trigger ReviewPanelTemplateTrigger on ReviewPanelTemplate__c (before insert, after insert, before update) {
    new ReviewPanelTemplateTriggerHelper().process();
}