@isTest
private with sharing class TestAnnouncementRelatedAppViewCtrl{
    static testMethod void testController() {

          UserTriggerHelper.skipTrigger = true;
          User u = TestHelper.getAdminUser(true);
          
          Account acct = null;
          
          System.runAs(u){
            AnnouncementTriggerHelper.skipTrigger = true;
            UserTriggerHelper.skipTrigger = true;
            Announcement__c ann = TestHelper.getAnnouncement(true);
            
            ApplicationTriggerHelper.skipTrigger = true;
            Application__c app = TestHelper.getApplication(ann.Id,true);
            
          
         
            Test.startTest();
            ApexPages.currentPage().getParameters().put('announcementId',ann.id);
            AnnouncementRelatedApplicationsViewCtrl ctrl = new AnnouncementRelatedApplicationsViewCtrl();
            ctrl.getListParameters();
            ctrl.flexTableHeader = 'Test Table';
            delete app;
            //AnnouncementRelatedApplicationsViewCtrl ctrl1 = new AnnouncementRelatedApplicationsViewCtrl();
            Test.stopTest();
        }
        
    }
}