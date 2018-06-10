trigger ApplicationReviewTrigger on ApplicationReview__c  (before insert,after insert,before update,after update,before delete, after delete) {	
	new ApplicationReviewTriggerHelper().Process();
}