@isTest
public with sharing class TestAnnRelatedApplicationsViewCtrl {
    static user u;
    private static void setupUser(){
        UserTriggerHelper.skipTrigger = true;
        u = TestHelper.getAdminUserDept(false);
        insert u;
    }
    
  @isTest
   private static void testAll(){
      setupUser();
        System.runAs(u){
             TestHelper.CreateCustomSettings(true);  
            Test.startTest();
            AnnouncementTriggerHelper.skipTrigger=true;
            ApplicationTriggerHelper.skipTrigger=true;
            UserTriggerHelper.skipTrigger = true;
            Announcement__c ann = TestHelper.getAnnouncement(true);
            Application__c app=TestHelper.getApplication(ann.id,true);
            
            ApexPages.CurrentPage().getParameters().put('announcementId', ann.Id);
            
            AnnouncementRelatedApplicationsViewCtrl ctrl = new AnnouncementRelatedApplicationsViewCtrl();
            ctrl.getListParameters();
            Test.stopTest();
        }
    }
}