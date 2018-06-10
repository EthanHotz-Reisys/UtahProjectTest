@isTest
private with sharing class TestApplicationServiceAreaViewCtrl{
    static testMethod void testController() {
          UserTriggerHelper.skipTrigger = true;
          User u = TestHelper.getAdminUser(true);
          Account acct = null;
          
          System.runAs(u){
            AnnouncementTriggerHelper.skipTrigger = true;
            Announcement__c ann = TestHelper.getAnnouncement(true);
            
            ApplicationTriggerHelper.skipTrigger = true;
            Application__c app = TestHelper.getApplication(ann.Id,true);
            ServiceArea__c servArea = TestHelper.getServiceArea(true);
            AnnouncementServiceArea__c annServArea = new AnnouncementServiceArea__c(Announcement__c=ann.Id, ServiceArea__c=servArea.ID);
            ApplicationServiceArea__c appServArea = new ApplicationServiceArea__c(Application__c=app.Id,ServiceArea__c=annServArea.Id);
            insert appServArea;
            
          
         
            Test.startTest();
            ApexPages.StandardController sc = new ApexPages.standardController(appServArea);
            ApexPages.currentPage().getParameters().put('id',appServArea.id);
            ApplicationServiceAreaViewCtrl ctrl = new ApplicationServiceAreaViewCtrl(sc);
            ctrl.getKeyValueMap();         
            Test.stopTest();
        }
        
    }
    
}