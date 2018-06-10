/*
	Trigger on  Review User  Object
	**********************************************************
	Audit History
	**********************************************************
	2014-05-01   	   Vinayak Sharma			 Created 
	**********************************************************  
*/

trigger ReviewStepUserTrigger on ReviewStepUser__c (after delete, after insert, after update) {
	System.debug('================START TRIGGER ======================');
    System.debug('================START TRIGGER ======================');
	new ReviewStepUserTriggerHelper().process();
	 System.debug('===============END TRIGGER  =======================');	
	 System.debug('===============END TRIGGER  =======================');	
}