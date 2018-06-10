@isTest
private class TestDrawdownTrigger {
	
	@isTest static void test_method_one() {
		DrawdownTriggerHelper.skipTrigger = true;
		AwardTriggerHelper.skipTrigger = true;
		GrantTriggerHelper.skipTrigger = true;
		Grant__c g = TestHelper.getGrant(true);
		Drawdown__c d = new Drawdown__c(Grant__c = g.Id);
		insert d;
	}
	
	@isTest static void test_method_two() {
		// Implement test code
	}
	
}