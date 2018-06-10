@isTest
private class TestIndirectCostEditCtrl {
    @isTest static void test_method_one(){
        AccountTriggerHelper.skipAll = true;
        USBELEACostRateTriggerHelper.skipTrigger=true;
        Account a= TestHelper.getAccount(true);
        USBELEACostRate__c usb=TestHelper.getUSBELEACostRate(true,a.id);
        System.debug(a.Name);
        Test.startTest();
            ApexPages.currentPage().getParameters().put('Id',usb.Id);
            ApexPages.currentPage().getParameters().put('accountid',a.Id);
            ApexPages.StandardController stdController = new ApexPages.StandardController(usb);
            IndirectCostEditCtrl indirectCostEditCtrl = new IndirectCostEditCtrl(stdController);
            IndirectCostEditCtrl.getKeyValueMap();
        Test.stopTest();
    }
    
}