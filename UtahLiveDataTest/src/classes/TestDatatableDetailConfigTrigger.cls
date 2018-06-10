@isTest
private class TestDatatableDetailConfigTrigger {
	
	@isTest static void test_method_one() {
		GNT__DataTableDetailConfig__c d = new GNT__DataTableDetailConfig__c();
		insert  d;
	}
	
	@isTest static void test_method_two() {
		GNT__NameTemplateSequence__c c = new GNT__NameTemplateSequence__c(Name = 'test', GNT__ObjectName__c = 'test', GNT__StartSequence__c=12, GNT__Year__c = 2016);
		insert c;
	}
	
}