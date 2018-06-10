trigger ProgramFundingAccountTrigger on ProgramFundingAccount__c (after insert, after delete) {
	new ProgramFundingAccountTriggerHelper().process();
}