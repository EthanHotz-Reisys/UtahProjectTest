@isTest
private class TestViewPaymentTermCondition {
	
	@isTest static void test_method_one() {
		PageReference pageRef = Page.TermConditionView;
		Test.setCurrentPage(pageRef);
		GrantTriggerHelper.skipTrigger = true;
		Grant__c grant = TestHelper.getGrant(true);
		TermCondition__c tc = new TermCondition__c();
		insert tc;
		ApexPages.currentPage().getParameters().put('grantId', grant.Id);
		ApexPages.currentPage().getParameters().put('gId', tc.Id);
		ViewPaymentTermConditionHandler v = new ViewPaymentTermConditionHandler();
		v.clickHandler();
	}
	
	@isTest static void test_method_two() {
		// Implement test code
	}
	
}