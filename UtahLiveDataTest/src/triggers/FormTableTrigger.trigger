trigger FormTableTrigger on FormTable__c (after update) {
	new FormTableTriggerHelper().process();
}