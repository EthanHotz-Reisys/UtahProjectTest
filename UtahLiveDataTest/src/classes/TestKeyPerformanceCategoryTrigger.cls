@isTest
private class TestKeyPerformanceCategoryTrigger {
	
	@isTest static void test_method_one() {
		KeyPerformanceCategory__c k = new KeyPerformanceCategory__c();
		insert k;
	}
	
	@isTest static void test_method_two() {
		// Implement test code
	}
	
}