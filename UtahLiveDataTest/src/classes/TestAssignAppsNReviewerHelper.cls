@isTest
private with sharing class TestAssignAppsNReviewerHelper {
    @IsTest
    public static void testHelper() {      
        User u1 = TestHelper.getAdminuser(false);
        UserTriggerHelper.skipTrigger = true;
        ApplicationTriggerHelper.skipTrigger = true;
        TestHelper.createCustomSettings(true);     
        ReviewTriggerHelper.skipTrigger = true;
        TestHelper.getContact(true); 
        ReviewStepTriggerHelper.skipTrigger = true;
        ReviewGroupTriggerHelper.skipTrigger = true;
        List<String> selectedRecordIds = new List<String>();
        Announcement__c ann = TestHelper.getGrantorAnnouncementAll(true); 
        Application__c app = TestHelper.getGrantorApplication(ann.id,true);
      
        ReviewPanelTemplate__c panelTemplate = [SELECT ID,Name,ReviewStepTemplate__c, ReviewPackage__c from ReviewPanelTemplate__c where ReviewStepTemplate__r.Program__c = :ann.Program__c ];

        ReviewGroup__c reviewGroup = new ReviewGroup__c();
        reviewGroup.Announcement__c = ann.id;
        reviewGroup.NumberOfReviewSteps__c= Decimal.valueOf('1.0');
        insert reviewGroup;
       

        ReviewStep__c reviewStep = new ReviewStep__c(ReviewGroup__c = reviewGroup.Id);
        insert reviewStep;

        ReviewStepApplication__c reviewStepApp = new ReviewStepApplication__c();
        reviewStepApp.ReviewStep__c = reviewStep.id;
        reviewStepApp.Application__c = app.id;
        insert reviewStepApp;
        
        ReviewStepUser__c reviewStepUser = new ReviewStepUser__c();
        reviewStepUser.ReviewStep__c = reviewStep.id;
        reviewStepUser.Reviewer__c=UserInfo.getUserId();
        insert reviewStepUser;

        ReviewPanel__c reviewPanel = new ReviewPanel__c();
        reviewPanel.ReviewStep__c = reviewStep.id;
        reviewPanel.ReviewPackage__c = panelTemplate.ReviewPackage__c;
        reviewPanel.GroupId__c = 'testID';
        reviewPanel.GroupName__c='testGroupName';
        reviewPanel.Sequence__c = 1;
        User u = TestHelper.getAdminUser(true);
        reviewPanel.Chair__c = u.id;
        
        Test.startTest(); 
        insert reviewPanel;
        
        System.runAs(u1){ 
        PanelUser__c panelUser = new PanelUser__c();
        panelUser.Reviewer__c = TestHelper.getPortalUser(true).id;
        panelUser.ReviewPanel__c = reviewPanel.id;       
        insert panelUser; 
         
        
        
        PanelApplication__c panelApplication = new PanelApplication__c();
        panelApplication.Application__c = app.id;
        panelApplication.ReviewPanel__c = reviewPanel.id;
        insert panelApplication;
        selectedRecordIds.add(panelApplication.Id); 
       
        Review__c review = new Review__c();
        review.Application__c = app.id;
        review.PanelApplication__c = panelApplication.id;
        review.ReviewStep__c=reviewStep.id;
        review.PanelUser__c=panelUser.id;
        review.ReviewPanel__c = reviewPanel.id;
        review.Status__c = 'Review Completed';
        insert review;       
        
        //arrange
        Test.setCurrentPageReference(new PageReference('Page.ReviewPanelView')); 
        
        //act
        
        AssignAppsAndNotifyReviewerHelper annHelper = new AssignAppsAndNotifyReviewerHelper();
        annHelper.urlparams.put('panelId',reviewPanel.Id);
        annHelper.urlparams.put('id',panelUser.Id);
        annHelper.urlparams.put('tabName','Applications'); 
        annHelper.selectedRecordIds = selectedRecordIds;  
        annHelper.clickHandler();
        Test.stopTest();     
        }
    }
    
   
}