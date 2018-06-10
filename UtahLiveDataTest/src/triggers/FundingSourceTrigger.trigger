trigger FundingSourceTrigger on FundingSource__c (before insert,after insert, after update,after delete,before update) {
    new FundingSourceTriggerHelper().process();
}