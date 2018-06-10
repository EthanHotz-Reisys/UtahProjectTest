/**
* @author: Sarat Mahavratayajula. 2016-08-02
*/
@isTest
private class TestGranteeContactViewCtrl {
	
	@isTest static void test_method_one() {
		Contact c = TestHelper.getcontact(true);
		Test.startTest();
			ApexPages.currentPage().getParameters().put('Id',c.Id);
			ApexPages.StandardController stdController = new ApexPages.StandardController(c);
			GranteeContactViewCtrl granteeContactEditCtrl = new GranteeContactViewCtrl(stdController);
			granteeContactEditCtrl.getKeyValueMap();
		Test.stopTest();
	}	
}