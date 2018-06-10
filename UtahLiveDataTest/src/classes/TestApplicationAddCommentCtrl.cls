@isTest
private with sharing class TestApplicationAddCommentCtrl{
    static testMethod void testController() {

          UserTriggerHelper.skipTrigger = true;
          User u = TestHelper.getAdminUser(true);
          Account acct = null;
          
          System.runAs(u){
            AnnouncementTriggerHelper.skipTrigger = true;
            Announcement__c ann = TestHelper.getAnnouncement(true);
            
            ApplicationTriggerHelper.skipTrigger = true;
            Application__c app = TestHelper.getApplication(ann.Id,true);
            
          
         
            Test.startTest();
            ApexPages.currentPage().getParameters().put('id',app.id);
            ApplicationAddCommentCtrl ctrl = new ApplicationAddCommentCtrl();
            ctrl.btnAddComment();
            ctrl.btnCancel();          
            Test.stopTest();
        }
        
    }
    
    static testMethod void testController2() {
          UserTriggerHelper.skipTrigger = true;
          User u = TestHelper.getAdminUser(true);
          Account acct = null;
          
          System.runAs(u){
            AnnouncementTriggerHelper.skipTrigger = true;
            Announcement__c ann = TestHelper.getAnnouncement(true);
            
            ApplicationTriggerHelper.skipTrigger = true;
            Application__c app = TestHelper.getApplication(ann.Id,true);
            
          
         
            Test.startTest();
            ApplicationAddCommentCtrl ctrl = new ApplicationAddCommentCtrl();
            ctrl.btnAddComment();         
            Test.stopTest();
        }
        
    }
}