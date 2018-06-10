@isTest
private with sharing class TestApplicationRejectionHelper{
    static testMethod void testWhenClicked() {
          
          UserTriggerHelper.skipTrigger = true;
          User u = TestHelper.getAdminUser(true);
          System.runAs(u){
          
              List<String> IdSet = new List<String>();
              AnnouncementTriggerHelper.skipTrigger = true;
              ApplicationTriggerHelper.skipTrigger = true;
              UserTriggerHelper.skipTrigger = true;
              
              Announcement__c announcement = TestHelper.getAnnouncement(true); 
              Application__c app= TestHelper.getApplication(announcement.Id,false);
              app.Status__c='Submitted to Grantor';
              insert app;
        
              
              
              Test.startTest();
              ApexPages.currentPage().getParameters().put('id',app.Id);
              ApplicationRejectionHelper ctrl = new ApplicationRejectionHelper();
              ctrl.whenClicked();
              Test.stopTest();
          }
        
    }
    
    static testMethod void testWhenClicked2() {
       
          UserTriggerHelper.skipTrigger = true;
          User u = TestHelper.getAdminUser(true);
          GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateasGrantor');
          System.runAs(u){

              Test.startTest();
              ApexPages.currentPage().getParameters().put('id',null);
              ApplicationRejectionHelper ctrl = new ApplicationRejectionHelper();
              ctrl.whenClicked();
              Test.stopTest();
          }
        
    }
    
}