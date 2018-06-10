@isTest
private class TestReviewAssignmentViewCtrl {
     
     @isTest static void test_method_one() {
     User u = TestHelper.getAdminUser(true);
        System.runAs(u) {
     AccountTriggerHelper.skipTrigger=true;
     GrantTriggerHelper.skipTrigger=true;
     AwardTriggerHelper.skipTrigger=true;
     RolesAndResponsibilitiesTriggerHelper.skipTrigger=true;
     ReviewTriggerHelper.skipTrigger = true;
     Review__c rev = new Review__c();
     insert rev;
     Test.startTest();
     ApexPages.currentPage().getParameters().put('Id',rev.Id);
         
     ApexPages.StandardController sc = new ApexPages.standardController(rev);
     ReviewAssignmentViewCtrl pr= new ReviewAssignmentViewCtrl(sc); 
     pr.getKeyValueMap();
     pr.calculate(1);
     pr.calculate1(1);
     Test.stopTest(); 
     
    }
    }

}