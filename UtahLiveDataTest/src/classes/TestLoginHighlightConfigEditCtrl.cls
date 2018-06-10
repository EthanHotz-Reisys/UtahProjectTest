@isTest
private with sharing class TestLoginHighlightConfigEditCtrl{
    static testMethod void testController() {
       
          User u = TestHelper.getAdminUser(true);
          System.runAs(u){
              
              GNT__Highlight__c highLight = TestHelper.getHighlight(true);
              
              
              Test.startTest();
              ApexPages.StandardController sc = new ApexPages.standardController(highLight);
              ApexPages.currentPage().getParameters().put('id',highLight.id);
              LoginHighlightConfigEditCtrl ctrl = new LoginHighlightConfigEditCtrl(sc);
              Test.stopTest();
          }
        
    }
}