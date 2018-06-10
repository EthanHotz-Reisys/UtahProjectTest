@isTest
private with sharing class TestApplicationApproval{

    static testMethod void testExecute() {

        USBEAnnouncementTriggerHelper.skipTrigger=true;
        ApplicationTriggerHelperUSBE.skipTrigger=true;
        ApplicationTriggerHelper.skipTrigger=true;
        User u = TestHelper.getAdminUser(true);
        
        Announcement__c ann=TestHelper.getAnnouncement(false);
        ann.ApplicationsReviewStatus__c='In Progress';
        insert ann;
        
        Application__c app=TestHelper.getApplication(ann.id,false);
        app.PrimaryApplicant__c=u.id;
        insert app;
        
        Task tsk=TestHelper.getTask(false);
        tsk.WhatId=app.id;
        tsk.OwnerId=u.Id;
        tsk.Status='In Progress';
        insert tsk;

        ApplicationApproval appapproval=new ApplicationApproval();  
        appapproval.selectedRecordId=app.ID;
        appapproval.selectedAction='Approve';
       

        System.runAs(u){
            Test.startTest();  
            appapproval.execute();
            appapproval.selectedAction='Reject';
            appapproval.execute();
            Test.stopTest();
        }

    }
    
  }