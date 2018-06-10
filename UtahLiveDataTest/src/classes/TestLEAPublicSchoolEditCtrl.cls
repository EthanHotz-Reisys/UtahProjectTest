@isTest
private class TestLEAPublicSchoolEditCtrl {

      static testMethod void myUnitTest() {
      AccountTriggerHelper.skipAll = true;
      Account a= TestHelper.getAccount(true);
      FiscalYear__c year=TestHelper.getFiscalYear(true);
      LEAPublicSchools__c school=TestHelper.getPublicSchool(true,a.id,year.id);
       
        Test.startTest();
            ApexPages.currentPage().getParameters().put('Id',school.Id);
            ApexPages.currentPage().getParameters().put('accountid',a.id);
            ApexPages.StandardController stdController = new ApexPages.StandardController(school);
            LEAPublicSchoolEditCtrl  leaPublicSchoolEdit = new LEAPublicSchoolEditCtrl(stdController);
            leaPublicSchoolEdit.getKeyValueMap();
        Test.stopTest();  
    }
}