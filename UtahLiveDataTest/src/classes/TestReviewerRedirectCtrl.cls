@isTest
private with sharing class TestReviewerRedirectCtrl{
    static testMethod void testredirect() {
        User u = TestHelper.getAdminUser(true);
        System.runAs(u){
            
            Test.startTest();
            ApexPages.currentPage().getParameters().put('t','unique token');
            ReviewerRedirectCtrl ctrl = new ReviewerRedirectCtrl();
            ctrl.redirect();
            Test.stopTest();
        
         }
    }
}