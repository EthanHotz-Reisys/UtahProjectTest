@isTest
private class TestCommunityRegistConfigDetailTrigger {
	
	@isTest static void test_method_one() {
		CommunityRegistrationConfig__c cmr = new CommunityRegistrationConfig__c();
        insert cmr;
		CommunityRegistrationConfigDetail__c c = new CommunityRegistrationConfigDetail__c(CommunityRegistrationConfig__c = cmr.Id);
		insert c;
	}
	
	@isTest static void test_method_two() {
		// Implement test code
	}
	
}