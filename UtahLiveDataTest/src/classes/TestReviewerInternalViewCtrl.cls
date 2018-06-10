@isTest
private with sharing class TestReviewerInternalViewCtrl{
    static testMethod void testController() {
        User u = TestHelper.getAdminUser(true);
        System.runAs(u){
            Contact ct = TestHelper.getContact(true);
           
            
            Test.startTest();
            ApexPages.StandardController sc = new ApexPages.standardController(ct);
            ApexPages.currentPage().getParameters().put('id',u.ContactId);
            ReviewerInternalViewCtrl ctrl = new ReviewerInternalViewCtrl(sc);
            ctrl.getKeyValueMap();
            Test.stopTest();
        
         }
    }
}