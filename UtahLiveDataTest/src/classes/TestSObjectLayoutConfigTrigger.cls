@isTest
private class TestSObjectLayoutConfigTrigger {
	
	@isTest static void test_method_one() {
		GNT__SObjectConfig__c s = new GNT__SObjectConfig__c(Name = 'test');
		insert s;
		GNT__SObjectLayoutConfig__c s1 = new GNT__SObjectLayoutConfig__c(GNT__SObjectConfig__c = s.Id);
		insert s1;
	}
	
	@isTest static void test_method_two() {
		// Implement test code
	}
	
}