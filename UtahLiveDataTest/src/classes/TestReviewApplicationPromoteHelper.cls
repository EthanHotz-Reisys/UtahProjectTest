@isTest
private with sharing class TestReviewApplicationPromoteHelper {

	static testMethod void testclickHandler() {
		AnnouncementTriggerHelper.skipTrigger=true;

		ReviewStep__c revStep=TestHelper.getReviewStep(true);
		revStep.RecordType=[SELECT Id,name,DeveloperName FROM RecordType WHERE SobjectType = 'ReviewStep__c' and name='Application' Limit 1];
		//revStep.RecordType.DeveloperName='Application';
		revStep.ReviewStepExpired__c=false;
		//revStep.LastStep__c=false;
		update revStep;
		Map<String,String> urlParams = new Map<String,String>();
		ReviewApplicationPromoteHelper revapppromohelper=new ReviewApplicationPromoteHelper();
		
		Test.startTest();
		//ReviewS
		//ApexPages.currentPage().getParameters().put('Id', revStep.Id);
		//urlParams.put('reviewStepId',revStep.Id);
		//urlParams.put('action','');

		//revapppromohelper.clickHandler();

		test.stopTest();
	}
}