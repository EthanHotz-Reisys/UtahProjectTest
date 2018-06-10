@isTest
private with sharing class TestReviewStepApplicationTrigger{
    
    @isTest
    private static void testAll_PreApp(){
        UserTriggerHelper.skipTrigger=true;
        user u = testHelper.getAdminUser(true);
        Contact c = new Contact();
        c.lastName = 'test';
        c.Email = 'Test@test.com';
        insert c;
        system.runAs(u){
            TestHelper.createCustomSettings(true);
            AnnouncementTriggerHelper.SkipTrigger=true;
            ApplicationTriggerHelper.SkipTrigger=true;
            Announcement__c ann = TestHelper.getGrantorAnnouncement(false);
            ann.ApplicationDeadlineWithDateTime__c = System.today() + 1;
            insert ann;
            ApplicationTriggerHelper.skipTrigger = true;
            Application__c app = TestHelper.getGrantorApplication(ann.Id,true);
            PreApplication__c preApp = TestHelper.getPreApplication(false);
            preApp.Status__c = 'In Progess';
            insert preApp;
            
            test.StartTest();
            ReviewGroup__c reviewGrp = new ReviewGroup__c();
            reviewGrp.Announcement__c = ann.Id;
            reviewGrp.NumberOfReviewSteps__c = 10;
            insert reviewGrp;
            
            ReviewStep__c reviewStep = new ReviewStep__c();
            reviewStep.ReviewGroup__c = reviewGrp.id;
            reviewStep.name = 'Step1';
            reviewStep.StepNumber__c = 1;
            reviewStep.ReviewStepTemplate__c = [Select Id From ReviewStepTemplate__c Where Announcement__c = :reviewStep.ReviewGroup__r.Announcement__c Order by StepNumber__c LIMIT 1].Id;
            reviewStep.ReviewScoreReportHeaderField__c='Review Header Test';
            insert reviewStep;

            ReviewStepApplication__c reviewStepApp = new ReviewStepApplication__c();
            reviewStepApp.ReviewStep__c = reviewStep.Id;
            reviewStepApp.Preapplication__c = preApp.Id;
            reviewStepApp.application__c = app.Id;
            reviewStepApp.Status__c = 'Approved';
            insert reviewStepApp;
            reviewStepApp.Status__c = 'Rejected';
            update reviewStepApp;
            test.StopTest();
            delete reviewStepApp;
            //system.assertNotEquals(reviewStepApp,null);
         }
    }
    
    @isTest
    private static void testAll_App(){
        UserTriggerHelper.skipTrigger=true;
        user u = testHelper.getAdminUser(true);
        Contact c = new Contact();
        c.lastName = 'test';
        c.Email = 'Test@test.com';
        insert c;
        system.runAs(u){
            TestHelper.createCustomSettings(true);
         
            AnnouncementTriggerHelper.SkipTrigger=true;
            ApplicationTriggerHelper.SkipTrigger=true;
            Announcement__c ann = TestHelper.getGrantorAnnouncement(false);
            ann.ApplicationDeadlineWithDateTime__c = System.today() + 1;
            insert ann;
            Application__c app = TestHelper.getGrantorApplication(ann.Id,false);
            app.Status__c = 'New';
            insert app;
            
            ReviewGroup__c reviewGrp = new ReviewGroup__c();
            reviewGrp.Announcement__c = ann.Id;
            reviewGrp.NumberOfReviewSteps__c = 10;
            insert reviewGrp;
            
            test.StartTest();
            ReviewStep__c reviewStep = new ReviewStep__c();
            reviewStep.ReviewGroup__c = reviewGrp.id;
            reviewStep.name = 'Step1';
            reviewStep.StepNumber__c = 1;
            reviewStep.ReviewStepTemplate__c = [Select Id From ReviewStepTemplate__c Where Announcement__c = :reviewStep.ReviewGroup__r.Announcement__c Order by StepNumber__c LIMIT 1].Id;
            reviewStep.ReviewScoreReportHeaderField__c='Review Header Test';
            insert reviewStep;
            
            ReviewStepApplication__c reviewStepApp = new ReviewStepApplication__c();
            reviewStepApp.ReviewStep__c = reviewStep.Id;
            reviewStepApp.application__c = app.Id;
            reviewStepApp.Status__c = 'Approved';
            insert reviewStepApp;
            reviewStepApp.Status__c = 'Rejected';
            update reviewStepApp;
            test.StopTest();
            delete reviewStepApp;
            system.assertNotEquals(reviewStepApp,null);
         }
    }
    @isTest
    private static void testUpdateFinalDecision(){
        UserTriggerHelper.skipTrigger=true;
        user u = testHelper.getAdminUser(true);
        Contact c = new Contact();
        c.lastName = 'test';
        c.Email = 'Test@test.com';
        insert c;
        system.runAs(u){
            TestHelper.createCustomSettings(true);           
            AnnouncementTriggerHelper.SkipTrigger=true;
            ApplicationTriggerHelper.SkipTrigger=true;
           
          
            
            Announcement__c ann = TestHelper.getGrantorAnnouncement(false);
            ann.ApplicationDeadlineWithDateTime__c = System.today() + 1;
            insert ann;
            Application__c app = TestHelper.getGrantorApplication(ann.Id,false);
            app.Status__c = 'New';
            insert app;
             test.StartTest();
            ReviewGroup__c reviewGrp = new ReviewGroup__c();
            reviewGrp.Announcement__c = ann.Id;
            reviewGrp.NumberOfReviewSteps__c = 10;
            insert reviewGrp;
            
            ReviewStep__c reviewStep = new ReviewStep__c();
            reviewStep.ReviewGroup__c = reviewGrp.id;
            reviewStep.name = 'Step1';
            reviewStep.StepNumber__c = 1;
            reviewStep.ReviewStepTemplate__c = [Select Id From ReviewStepTemplate__c Where Announcement__c = :reviewStep.ReviewGroup__r.Announcement__c Order by StepNumber__c LIMIT 1].Id;
            reviewStep.ReviewScoreReportHeaderField__c='Review Header Test';
            insert reviewStep;
            ReviewStepApplication__c reviewStepApp = new ReviewStepApplication__c();
            reviewStepApp.ReviewStep__c = reviewStep.Id;
            
            reviewStepApp.application__c = app.Id;
            
            insert reviewStepApp;
            reviewStepApp.Status__c = 'Approved';
            update reviewStepApp;
            
            test.StopTest();
            system.assertNotEquals(reviewStepApp,null);
         }
    }
}