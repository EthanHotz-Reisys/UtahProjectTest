/**
* @author: Sarat Mahavratayajula. 2016-08-02
*/
@isTest
private class TestGranteeContactEditCtrl {
	
	@isTest static void test_method_one() {
		Contact c = TestHelper.getcontact(true);
		Test.startTest();
			ApexPages.currentPage().getParameters().put('Id',c.Id);
			ApexPages.StandardController stdController = new ApexPages.StandardController(c);
			GranteeContactEditCtrl granteeContactEditCtrl = new GranteeContactEditCtrl(stdController);
			granteeContactEditCtrl.getKeyValueMap();
		Test.stopTest();
	}	
	@isTest static void test_method_two() {
		Contact c = TestHelper.getcontact(true);
		Test.startTest();
			ApexPages.StandardController stdController = new ApexPages.StandardController(c);
			GranteeContactEditCtrl granteeContactEditCtrl = new GranteeContactEditCtrl(stdController);			
		Test.stopTest();
	}
}