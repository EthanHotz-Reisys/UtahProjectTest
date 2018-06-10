@isTest
public with sharing class TestSiteVisitCloseHelper {
    static testMethod void testController() {
        UserTriggerHelper.skipTrigger=true;
        User u = TestHelper.getAdminUser(true);
        
        System.runAs(u) {
            GrantTriggerHelper.skipTrigger = true;
            AwardTriggerHelper.skipTrigger = true;
            RolesAndResponsibilitiesTriggerHelper.skipTrigger = true;
            AccountTriggerHelper.skipTrigger = true;
            TaskTriggerHelper.skipTrigger=true;
            SiteVisitTriggerHelper.skipTrigger = true;
            SiteVisit__c sv = TestHelper.getSiteVisit(true);

            Test.startTest();
            ApexPages.currentPage().getParameters().put('Id', sv.Id); 
            SiteVisitCloseHelper helper = new SiteVisitCloseHelper();
            helper.whenClicked();
            Test.stopTest();
        }
    }
}