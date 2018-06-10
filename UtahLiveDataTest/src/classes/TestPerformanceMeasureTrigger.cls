@isTest
private class TestPerformanceMeasureTrigger {
	
	@isTest static void test_method_one() {
		PerformanceMeasureTriggerHelper.skipTrigger = true;
		GoalObjectiveTriggerHelper.skipTrigger = true;
		GoalObjective__c g = new GoalObjective__c();
		insert g;



		PerformanceMeasure__c p = new PerformanceMeasure__c(Objective__c = g.Id);
		insert p;
	}
	
	@isTest static void test_method_two() {
		// Implement test code
	}
	
}