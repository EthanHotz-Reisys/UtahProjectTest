@isTest
private with sharing class TestSubmissionRequestViewRedirectCtrl{
    static testMethod void testRedirect() {
          Account acct = null;
          UserTriggerHelper.skipTrigger=true;
          User u = TestHelper.getAdminUser(true);
          
          System.runAs(u){
            AnnouncementTriggerHelper.skipTrigger = true;
            ApplicationTriggerHelper.skipTrigger = true;
            
            Announcement__c ann = TestHelper.getAnnouncement(true);
            Application__c app = TestHelper.getApplication(ann.Id,false);
            app.ProjectOfficer__c = u.Id;
            app.GrantMonitor__c=u.Id;
          
            insert app;
            
            ChangeRequest__c changeReq = new ChangeRequest__c(Application__c = app.Id);
            changeReq.Status__c='Initiated';
            insert changeReq;
            
            Test.startTest();
            ApexPages.currentPage().getParameters().put('id',changeReq.id);
            SubmissionRequestViewRedirectCtrl ctrl = new SubmissionRequestViewRedirectCtrl();
            ctrl.redirect();
            Test.stopTest();
        
         }
        
    }
    
       static testMethod void testRedirect2() {
          Account acct = null;
          UserTriggerHelper.skipTrigger=true;
          User u = TestHelper.getAdminUser(true);
          
          System.runAs(u){
            AnnouncementTriggerHelper.skipTrigger = true;
            ApplicationTriggerHelper.skipTrigger = true;
            
            Announcement__c ann = TestHelper.getAnnouncement(true);
            Application__c app = TestHelper.getApplication(ann.Id,false);
            app.ProjectOfficer__c = u.Id;
            insert app;
            
            ChangeRequest__c changeReq = new ChangeRequest__c(Application__c = app.Id);
            changeReq.Status__c='Submitted By Applicant';
            insert changeReq;
            
            Test.startTest();
            ApexPages.currentPage().getParameters().put('id',changeReq.id);
            SubmissionRequestViewRedirectCtrl ctrl = new SubmissionRequestViewRedirectCtrl();
            ctrl.redirect();
            app.GrantMonitor__c=u.Id;
            app.ProjectOfficer__c = null;
            update app;
            ctrl.redirect();
            app.DataEvaluator__c=u.Id;
            app.GrantMonitor__c=null;
            app.ProjectOfficer__c = null;
            update app;
            ctrl.redirect();
            Test.stopTest();
        
         }
        
    }

}