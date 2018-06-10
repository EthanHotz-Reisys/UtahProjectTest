@isTest
private with sharing class TestIntegrationDetailCtrl{
    static testMethod void testController() {
       
          User u = TestHelper.getAdminUser(true);
          System.runAs(u){
              
              IntegrationHeader__c intHead = new IntegrationHeader__c();
              insert intHead;
              
              IntegrationDetail__c intDetail = new IntegrationDetail__c();
              intDetail.IntegrationHeader__c=intHead.Id;
              intDetail.Process_Response__c='Success';
              insert intDetail;
              
              Test.startTest();
              ApexPages.StandardController sc = new ApexPages.standardController(intDetail);
              ApexPages.currentPage().getParameters().put('id',intDetail.id);
              ApexPages.currentPage().getParameters().put('templateName','Test Template');
              IntegrationDetailCtrl ctrl = new IntegrationDetailCtrl(sc);
              ctrl.deleteURL=new PageReference('myPage.TestPage');
              ctrl.getKeyValueMap();
              Test.stopTest();
          }
        
    }
}