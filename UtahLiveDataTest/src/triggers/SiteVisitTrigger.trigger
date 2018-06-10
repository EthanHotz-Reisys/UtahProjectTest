trigger SiteVisitTrigger on SiteVisit__c (after insert,before insert,before delete,before update,after update) {
    new SiteVisitTriggerHelper().process();
}