@isTest
private with sharing class TestPreApplicationsApprovalHelper{
    static testMethod void testwhenClicked() {
        User u = TestHelper.getAdminUser(true);
        System.runAs(u){      
              
              AnnouncementTriggerHelper.skipTrigger = true;
              Announcement__c ann = TestHelper.getAnnouncement(true);
              
              Test.startTest();
              ApexPages.currentPage().getParameters().put('id',ann.id);
              PreApplicationsApprovalHelper ctrl = new PreApplicationsApprovalHelper();
              ctrl.whenClicked();
              Test.stopTest();
          }
        
    }
    
    static testMethod void testwhenClicked2() {
        User u = TestHelper.getAdminUser(true);
        System.runAs(u){      
              
              AnnouncementTriggerHelper.skipTrigger = true;
              Announcement__c ann = TestHelper.getAnnouncement(false);
              ann.ProgramApprover__c = u.Id;
              insert ann;
              
              Test.startTest();
              ApexPages.currentPage().getParameters().put('id',ann.id);
              PreApplicationsApprovalHelper ctrl = new PreApplicationsApprovalHelper();
              ctrl.whenClicked();
              Test.stopTest();
          }
        
    }
}