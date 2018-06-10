@isTest
private with sharing class TestReviewerConfirmationHelper{
    static testMethod void testwhenClicked() {
        User u = TestHelper.getAdminUser(true);
        System.runAs(u){
            AnnouncementTriggerHelper.skipTrigger = true;
            ReviewStepTriggerHelper.skipTrigger = true;
            PanelUserTriggerHelper.skipAll = true;
            GNT.TriggerHelper.skipTrigger = true;
            
            Announcement__c ann = TestHelper.getAnnouncement(true);
            ReviewGroup__c reviewGroup = new ReviewGroup__c();
            reviewGroup.Announcement__c = ann.id;
            reviewGroup.NumberOfReviewSteps__c= Decimal.valueOf('2.0');
            insert reviewGroup;

            ReviewStep__c reviewStep = new ReviewStep__c();
            reviewStep.ReviewGroup__c = reviewGroup.id;
            reviewStep.Name = 'Step 1';
            reviewStep.StepNumber__c = 1;
            insert reviewStep;
        
            ReviewPanel__c reviewPanel = new ReviewPanel__c();
            reviewPanel.ReviewStep__c = reviewStep.id;
            reviewPanel.GroupId__c = 'testID';
            reviewPanel.TaskDueDate__c = 'Today + Offset Days';
            reviewPanel.DueDateOffset__c = '4';
            reviewPanel.Sequence__c = 1;
            reviewPanel.AutoAssignsubmittedApplication__c = true;
            reviewPanel.ReviewerAssignNotificationTemplate__c = 'application Approved';
            User newUser = TestHelper.getStandardUser(true);
            reviewPanel.Chair__c = newUser.id;
            insert reviewPanel;
        
            Review__c  r = new Review__c();
            r.ReviewPanel__c = reviewPanel.id;
            r.Status__c = 'Assigned';
            //r.Application__c = app.id;
            insert r; 
            
            Test.startTest();
            ApexPages.currentPage().getParameters().put('id',r.id);
            ReviewerConfirmationHelper ctrl = new ReviewerConfirmationHelper();
            ctrl.whenClicked();
            delete r;
            ctrl.whenClicked();
            Test.stopTest();
        
         }
    }
}