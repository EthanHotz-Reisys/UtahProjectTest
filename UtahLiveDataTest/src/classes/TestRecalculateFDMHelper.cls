@isTest
private with sharing class TestRecalculateFDMHelper{
    static testMethod void testClickHandler() {
       
          User u = TestHelper.getAdminUser(true);
          GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateasGrantor');
           
          System.runAs(u){
              AnnouncementTriggerHelper.skipTrigger = true;
              ApplicationTriggerHelper.skipTrigger = true;
              
              Announcement__c ann = TestHelper.getAnnouncement(false);
              ann.ObligatedAmount__c = 1;
              insert ann;
              Application__c app =TestHelper.getApplication(ann.Id,true);
              List<BudgetCategory__c> budCat = TestHelper.getBudgetCategory(true);
              ApplicationBudgetCategory2__c appBudCat = new ApplicationBudgetCategory2__c(Application__c=app.Id,BudgetCategory__c=budCat[0].Id);
              insert appBudCat;
              appBudCat.Amount__c = 5.1;
              appBudCat.IsFirstBudgetPeriodRelated__c=true;
              update appBudCat;

            
            //  System.debug('app Bud Cat is -->'+appBudCat.Amount__c);
             // System.Debug('Application Amount is ---->'+app.RequestedAmount__c);
              ReviewGroup__c reviewGroup = new ReviewGroup__c();
              reviewGroup.Announcement__c = ann.id;
              reviewGroup.NumberOfReviewSteps__c= Decimal.valueOf('2.0');
              insert reviewGroup;

              ReviewStep__c reviewStep = new ReviewStep__c();
              reviewStep.ReviewGroup__c = reviewGroup.id;
              reviewStep.Name = 'Step 1';
              reviewStep.StepNumber__c = 1;
              insert reviewStep;
              
              GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateasGrantor');
              ReviewStepApplication__c revStepApp = new ReviewStepApplication__c();
              revStepApp.ReviewStep__c = reviewStep.Id;
              insert revStepApp;
              //revStepApp.RecommendedAmount__c=0.5;
              update revStepApp;

              GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateasGrantor');
              Test.startTest();
              RecalculateFDMHelper ctrl = new RecalculateFDMHelper();
              ctrl.urlParams.put('id',reviewStep.id);
              ctrl.clickHandler();
              ann.ObligatedAmount__c = 50;
              update ann;
              ctrl.clickHandler();
              Test.stopTest();
          }
        
    }
}