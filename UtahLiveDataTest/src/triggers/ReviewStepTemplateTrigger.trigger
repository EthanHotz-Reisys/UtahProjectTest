trigger ReviewStepTemplateTrigger on ReviewStepTemplate__c (before update, before insert, after insert, after update, after undelete) {
    new ReviewStepTemplateTriggerHelper().process();
}