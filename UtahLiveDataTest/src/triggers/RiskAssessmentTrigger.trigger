trigger RiskAssessmentTrigger on RiskAssessment__c (after insert, after update, before insert, 
before update) {
new RiskAssessmentTriggerHelper().process();
}