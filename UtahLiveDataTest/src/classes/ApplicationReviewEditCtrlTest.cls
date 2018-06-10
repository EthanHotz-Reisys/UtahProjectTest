@isTest
public class ApplicationReviewEditCtrlTest {
    static testMethod void someTest() {
        ApplicationReview__c appReview= null;
        Application__c app= null;
        Grant__c grant= null;
        Award__c awards= null;
        Announcement__c ann= null;
        PreApplication__c preApp = null;
        UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
        
        System.runAs(u){
        
            GrantTriggerHelper.skipTrigger=true;
            
            RolesandResponsibilitiesTriggerHelper.skipTrigger=true;
            AnnouncementTriggerHelper.skipTrigger=true;
            PreApplicationTriggerHelper.skipTrigger = true;
            ApplicationTriggerHelper.skipTrigger= true;
            AwardTriggerHelper.skipTrigger = true;
            UserTriggerHelper.skipTrigger = true;
            appReview = new ApplicationReview__c();
            insert appReview;
            
            ann = TestHelper.getAnnouncement(true);
            app = TestHelper.getApplication(ann.Id,true);
            preApp = TestHelper.getPreApplication(true);
            grant = TestHelper.getGrant(true);
            awards= TestHelper.getAwards(grant.Id,true);
        }
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.standardController(appReview);
        ApexPages.currentPage().getParameters().put('id',appReview.id);
        ApexPages.CurrentPage().getParameters().put('applicationid',app.id);
        ApexPages.CurrentPage().getParameters().put('awardId',awards.id);
        ApexPages.CurrentPage().getParameters().put('announcementId',ann.id);
        ApexPages.CurrentPage().getParameters().put('preapplicationId',preApp.id);
        ApplicationReviewEditCtrl e = new ApplicationReviewEditCtrl(sc);
        e.getKeyValueMap();
        Test.stopTest();
    }
}