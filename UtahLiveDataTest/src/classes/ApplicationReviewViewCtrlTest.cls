@isTest
public class ApplicationReviewViewCtrlTest {
    static testMethod void someTest() {
        ApplicationReview__c appReview= null;
        Application__c app= null;
        Announcement__c ann= null;
        UserTriggerHelper.skipTrigger = true;
        
        User u = TestHelper.getAdminUser(true);
        
        System.runAs(u){
        
            GrantTriggerHelper.skipTrigger=true;
            
            RolesandResponsibilitiesTriggerHelper.skipTrigger=true;
            AnnouncementTriggerHelper.skipTrigger=true;
            PreApplicationTriggerHelper.skipTrigger = true;
            ApplicationTriggerHelper.skipTrigger= true;
            AwardTriggerHelper.skipTrigger = true;
            
            appReview = new ApplicationReview__c();
            insert appReview;
            
            ann = TestHelper.getAnnouncement(true);
            app = TestHelper.getApplication(ann.Id,true);
        }
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.standardController(appReview);
        ApexPages.currentPage().getParameters().put('id',appReview.id);
        ApexPages.CurrentPage().getParameters().put('applicationid',app.id);
        ApplicationReviewViewCtrl e = new ApplicationReviewViewCtrl(sc);
        e.getKeyValueMap();
        Test.stopTest();
    }
}