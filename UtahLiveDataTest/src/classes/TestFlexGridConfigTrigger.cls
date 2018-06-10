@isTest
private class TestFlexGridConfigTrigger {
	
	@isTest static void test_method_one() {
		GNT__FlexGridConfig__c f = new GNT__FlexGridConfig__c(Name = 'test');
		insert f;
	}
	
	@isTest static void test_method_two() {
		// Implement test code
	}
	
}