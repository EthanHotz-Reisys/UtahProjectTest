trigger FundingAccountTrigger on FundingAccount__c (before update, before insert,after insert) {
    new FundingAccountTriggerHelper().process();
}