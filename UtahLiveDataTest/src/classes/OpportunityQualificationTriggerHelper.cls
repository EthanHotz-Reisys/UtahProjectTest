/*
    All code for Trigger on OpportunityQualification  Object
    ***********************************************************
    Audit History
    ***********************************************************
    May-23-2017      Davinder Singh         Created
    *********************************************************** 
*/
global with sharing class OpportunityQualificationTriggerHelper extends GNT.TriggerHelper {
    global override void processAfterInsert() {
        SystemContextMethodsHelper.shareOpportunityToExternalUser(Trigger.New);
    }
}