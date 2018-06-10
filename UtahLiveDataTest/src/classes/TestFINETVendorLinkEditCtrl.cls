@isTest
private class TestFINETVendorLinkEditCtrl {
    @isTest static void test_method_one(){
    
      AccountTriggerHelper.skipAll = true;
        Account a= TestHelper.getAccount(true);
         R_VEND_CUST__c vendor=TestHelper.getR_VEND_CUST(true);
        R_AD__c vendorAdd=TestHelper.getR_AD(true,vendor.Id);
        FINETVendorLink__c vendorLink=TestHelper.getFINETVendorLink(true,a.Id,vendor.Id,vendorAdd.Id);
        
        Test.startTest();
            ApexPages.currentPage().getParameters().put('Id',vendorLink.Id);
            ApexPages.currentPage().getParameters().put('accountid',a.Id);
            ApexPages.StandardController stdController = new ApexPages.StandardController(vendorLink);
            FINETVendorLinkEditCtrl finetVendorLinkEditCtrl  = new FINETVendorLinkEditCtrl(stdController);
            FINETVendorLinkEditCtrl .getKeyValueMap();
        Test.stopTest();
    }
    
}