@isTest
private class TestDataTableActionConfigTrigger {
	
	@isTest static void test_method_one() {
		GNT__DataTableConfig__c da = new GNT__DataTableConfig__c(Name = 'test', GNT__Description__c = 'GNT__Description__c');
		insert da;
		GNT__DataTableAction__c d = new GNT__DataTableAction__c(GNT__DataTableConfig__c = da.Id);
		insert d;
	}
	
	@isTest static void test_method_two() {
		// Implement test code
	}
	
}