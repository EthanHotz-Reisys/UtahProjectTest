/*
	Trigger on Review Step Object
	**********************************************************
	Audit History
	**********************************************************
	2014-04-17		   Kunal Shah			 Created 
	**********************************************************  
*/

trigger ReviewStepTrigger on ReviewStep__c (after delete, after insert, after update, 
before delete, before insert, before update) {
	new ReviewStepTriggerHelper().process();
}