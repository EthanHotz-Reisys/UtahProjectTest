@isTest(seealldata=true)
private with sharing class TestApplicationReviewTriggerHelper{

    static testMethod void testApplicationReviewTrigg(){
    
        UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
        Application__c app = null;
        ApplicationReview__c appReview = null;
        Announcement__c ann= null;
        PreApplication__c preApp = null;
        
        System.runAs(u){
              ApplicationTriggerHelper.skipTrigger = true;
              AnnouncementTriggerHelper.skipTrigger = true;
              
              ann = TestHelper.getAnnouncement(true);
              app = TestHelper.getApplication(ann.Id,true);
              app.Status__c='Reviewed';
              update app;
              
              preApp = TestHelper.getPreApplication(true);
              preApp.Status__c='Reviewed';
              update preApp;
              
              appReview = new ApplicationReview__c(Application__c=app.Id);
              appReview.PreApplication__c=preApp.Id;
              insert appReview;
              appReview.FundingOpportunity__c= ann.Id;
              appReview.ReviewComments__c='Great Work';
              update appReview;
              
              delete appReview;
        }
    }
    
    
    static testMethod void testApplicationReviewTrigg2(){
    
        UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
        Application__c app = null;
        ApplicationReview__c appReview = null;
        Announcement__c ann= null;
        PreApplication__c preApp = null;
        GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateasGrantor');
        
        System.runAs(u){
              ApplicationTriggerHelper.skipTrigger = true;
              AnnouncementTriggerHelper.skipTrigger = true;
              
              ann = TestHelper.getAnnouncement(true);
              GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateasGrantor');
              app = TestHelper.getApplication(ann.Id,true);
              app.Status__c='Internally Reviewed';
              update app;
              GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateasGrantor');
              preApp = TestHelper.getPreApplication(true);
              GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateasGrantor');
              appReview = new ApplicationReview__c(Application__c=app.Id);
              appReview.PreApplication__c=preApp.Id;
              insert appReview;
              GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateasGrantor');
              appReview.ReviewComments__c='looks good';
              update appReview;
        }
    }
}