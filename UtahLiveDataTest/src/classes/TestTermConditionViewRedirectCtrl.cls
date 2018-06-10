@isTest
private with sharing class TestTermConditionViewRedirectCtrl{
    static testMethod void testredirect() {
       
          User u = TestHelper.getAdminUser(true);
          System.runAs(u){
              
              AccountTriggerHelper.skipAll = true;
              TermCondition__c termCond = TestHelper.getTermCondition(true,'Term');

              Test.startTest();
              ApexPages.currentPage().getParameters().put('termConditionId',termCond.id);
              TermConditionViewRedirectCtrl ctrl = new TermConditionViewRedirectCtrl();
              ctrl.redirect();
              Test.stopTest();
          }
        
    }
}