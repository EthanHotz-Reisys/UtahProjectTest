@isTest
private class TestCreateFDMHelper {

    static testMethod void myUnitTest() {
        User u = TestHelper.getAdminUser(true);
        AnnouncementTriggerHelper.skipTrigger = true; 
        PanelUserTriggerHelper.skipAll = true;
        ProgramTriggerHelper.skipTrigger = true;
        ApplicationTriggerHelper.skipTrigger = true;
        ReviewStepTemplateTriggerHelper.skipTrigger = true;
        ReviewGroupTriggerHelper.skipTrigger = true;
        UserTriggerHelper.skipTrigger = true;
        system.runAs(u){
        
            TestHelper.createCustomSettings(true);
            ReviewStep__c revstep = TestHelper.getReviewStep(false);
            revstep.SDDNotified__c = false;
            revstep.StepNumber__c=3;
            insert revstep;
            ReviewStep__c revstep1 = TestHelper.getReviewStep(false);
            revstep1.ReviewGroup__c = revstep.ReviewGroup__c;
            revstep1.SDDNotified__c = false;
            revstep1.StepNumber__c=4;
            insert revstep1;
            Announcement__c ann = TestHelper.getAnnouncement(true);
            
              
            ReviewPanelTemplate__c panelTemplate = [SELECT ID,Name,ReviewStepTemplate__c, ReviewPackage__c from ReviewPanelTemplate__c where ReviewStepTemplate__r.Program__c = :ann.Program__c Limit 1];
            
            GNT__PageTemplate__c pgTmp = TestHelper.getPageTemplateConfig(true);
            pgTmp.GNT__DisplayName__c='FundingDecisionMemoTemplate';
            pgTmp.Name='FundingDecisionMemoTemplate';
            update pgTmp;

            ReviewStepUser__c reviewStepUser = new ReviewStepUser__c();
            reviewStepUser.ReviewStep__c = revstep.id;
            reviewStepUser.Reviewer__c=UserInfo.getUserId();
            insert reviewStepUser;
            
            Application__c app = TestHelper.getApplication(ann.id,true);
    
    
            ReviewPanel__c reviewPanel = new ReviewPanel__c();
            reviewPanel.ReviewStep__c = revstep.id;
            reviewPanel.ReviewPackage__c = panelTemplate.ReviewPackage__c;
            reviewPanel.GroupId__c = 'testID';
            reviewPanel.Sequence__c = 1;
            insert reviewPanel;
    
            PanelUser__c panelUser = new PanelUser__c();
            panelUser.Reviewer__c = TestHelper.getPortalUser(true).id;
            panelUser.ReviewPanel__c = reviewPanel.id;       
            insert panelUser; 
    
            PanelApplication__c panelApplication = new PanelApplication__c();
            panelApplication.Application__c = app.id;
            panelApplication.ReviewPanel__c = reviewPanel.id;
            insert panelApplication;
    
            ReviewStepApplication__c reviewStepApp = new ReviewStepApplication__c();
            reviewStepApp.ReviewStep__c = revstep.Id;
            reviewStepApp.application__c = app.Id;
            reviewStepApp.Status__c = 'Approved';
            reviewStepApp.Decision__c = 'Approved';
            insert reviewStepApp;
    
            Review__c review = new Review__c();
            review.Application__c = app.id;
            review.PanelApplication__c = panelApplication.id;
            review.PanelUser__c=panelUser.id;
            review.ReviewPanel__c = reviewPanel.id;
            review.Status__c = 'Review Completed';
            review.ReviewStep__c=revstep.Id;
            review.RecommendedBudget__c = 99;
            review.Recommendation__c='Recommended';
            insert review;            
            
            test.starttest();
            CreateFDMHelper fdmhelper = new CreateFDMHelper();
            ApexPages.currentPage().getParameters().put('id',revstep.Id); 
            fdmhelper.whenClicked();             
            test.stoptest();
        }
    }
}