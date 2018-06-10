@isTest
private with sharing class TestReviewAppSendtoFinalConfirmHelper{
    static testMethod void testclickHandler() {
        User u = TestHelper.getAdminUser(true);
        System.runAs(u){
            AnnouncementTriggerHelper.skipTrigger = true;
            ReviewStepTriggerHelper.skipTrigger = true;
            PanelUserTriggerHelper.skipAll = true;
            GNT.TriggerHelper.skipTrigger = true;
            List<String> IdSet = new List<String>();
            
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
        
            
            IdSet.add(reviewStep.Id);
            
            Test.startTest();
            ReviewAppSendtoFinalConfirmHelper ctrl = new ReviewAppSendtoFinalConfirmHelper();
            ctrl.urlParams.put('id',reviewStep.Id);
            ctrl.selectedRecordIds = IdSet;
            ctrl.clickHandler();
            Test.stopTest();
        
         }
    }
}