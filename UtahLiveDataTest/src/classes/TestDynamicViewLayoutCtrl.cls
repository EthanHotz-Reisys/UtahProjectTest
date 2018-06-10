@isTest(SeeAllData = true)
private class TestDynamicViewLayoutCtrl {
	
	@isTest static void test_method_one() {
		GNT__PackageFormConfig__c packageForm = [select Id from GNT__PackageFormConfig__c limit 1];
		ApexPages.CurrentPage().getParameters().put('formPackageId',packageForm.Id);
		DynamicViewLayoutCtrl d = new DynamicViewLayoutCtrl();
		GNT__PageTemplate__c pgTemp = [select name from GNT__PageTemplate__c limit 1];
		ApexPages.CurrentPage().getParameters().put('layoutId',pgTemp.Id);
		DynamicViewLayoutCtrl d1 = new DynamicViewLayoutCtrl();
	}
	
	@isTest static void test_method_two() {
		// Implement test code
	}
	
}