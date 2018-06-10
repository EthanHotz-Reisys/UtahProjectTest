/**
    Test class for ReviewGroupEditCtrl
    **********************************************************
    Audit History
    **********************************************************
    4/27/2014   Someone   Created
    4/28/2014   Ryan Chadwick                   modified
    **********************************************************  
*/
@isTest
private with sharing class TestReviewGroupEditCtrl {

    @IsTest(OnInstall=false)
    public static void test_ctrl(){
        AnnouncementTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(false); 
        Contact c = new Contact();
        c.LastName = 'Test';
        c.Email = 'Test@test.com';
        insert c;
        
        System.runAs(u) {
            Group gp = new Group(Name='test1',Type='Regular');
            insert gp;
            GroupMember gmember = new GroupMember();
            gmember.GroupId = gp.Id;
            gmember.UserOrGroupId = u.Id;
            insert gmember;
            TestHelper.CreateCustomSettings(true);
            GNT.KeyValueStoreHelper.setTextValue('ExternalUserPublicGroup',gp.Name,true);

            Announcement__c ann = TestHelper.getGrantorAnnouncementAll(true); 
            ApplicationTriggerHelper.skipTrigger = true;
            ReviewStepTriggerHelper.skipTrigger=true;
            Test.StartTest();
            Application__c app = TestHelper.getGrantorApplication(ann.id,true);
        
            ReviewPanelTemplate__c panelTemplate = [SELECT ID,Name,ReviewStepTemplate__c, ReviewPackage__c from ReviewPanelTemplate__c where ReviewStepTemplate__r.Program__c = :ann.Program__c ];
    
            ReviewGroup__c reviewGroup = new ReviewGroup__c();
            reviewGroup.Announcement__c = ann.id;
            reviewGroup.NumberOfReviewSteps__c= Decimal.valueOf('10.0');
            insert reviewGroup;
            ReviewGroup__c reviewGroup2 = new ReviewGroup__c();
            reviewGroup2.Announcement__c = ann.id;
            reviewGroup2.NumberOfReviewSteps__c= Decimal.valueOf('10.0');
            insert reviewGroup2;
            
            ReviewStep__c reviewStep = new ReviewStep__c(ReviewGroup__c = reviewGroup.Id);
            //ReviewStep__c reviewStep = [Select Id From ReviewStep__c Where ReviewGroup__c = :reviewGroup.Id];
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
            reviewPanel.Chair__c = u.id;
            insert reviewPanel;
    
            PanelUser__c panelUser = new PanelUser__c();
            panelUser.Reviewer__c = TestHelper.getPortalUser(true).id;
            panelUser.ReviewPanel__c = reviewPanel.id;       
            insert panelUser; 
    
            PanelApplication__c panelApplication = new PanelApplication__c();
            panelApplication.Application__c = app.id;
            panelApplication.ReviewPanel__c = reviewPanel.id;
            insert panelApplication;
    
            ReviewTriggerHelper.skipTrigger = true;
            Review__c review = new Review__c();
            review.Application__c = app.id;
            review.PanelApplication__c = panelApplication.id;
            review.PanelUser__c=panelUser.id;
            review.ReviewPanel__c = reviewPanel.id;
            review.Status__c = 'Review Completed';
            insert review;
        
        //act
        
        ApexPages.currentPage().getParameters().put('id',reviewGroup.Id);
        ReviewGroupEditCtrl ctrl = new ReviewGroupEditCtrl( new ApexPages.Standardcontroller(reviewGroup) );
        ctrl.recordId = reviewGroup2.Id;
        Test.stopTest();
        
        //assert
        System.assert(ctrl != null);
        System.assertEquals(ctrl.recordId, reviewGroup2.Id);
        }
    }
    
    @IsTest(OnInstall=false)
    public static void test_getKeyValueMap(){
        User u = TestHelper.getAdminUser(false);
        Contact c = new Contact();
        c.LastName = 'Test';
        c.Email = 'Test@test.com';
        insert c;
        
        System.runAs(u) {
            AnnouncementTriggerHelper.skipTrigger = true;
            TestHelper.CreateCustomSettings(true);
            Announcement__c ann = TestHelper.getGrantorAnnouncementAll(true); 
            ApplicationTriggerHelper.skipTrigger = true;
            ReviewStepTriggerHelper.skipTrigger=true;
            Application__c app = TestHelper.getGrantorApplication(ann.id,true);
        
            ReviewPanelTemplate__c panelTemplate = [SELECT ID,Name,ReviewStepTemplate__c, ReviewPackage__c from ReviewPanelTemplate__c where ReviewStepTemplate__r.Program__c = :ann.Program__c ];
    
            ReviewGroup__c reviewGroup = new ReviewGroup__c();
            reviewGroup.Announcement__c = ann.id;
            reviewGroup.NumberOfReviewSteps__c= Decimal.valueOf('10.0');
            Test.StartTest();
            insert reviewGroup;    
           
            ReviewStep__c reviewStep = new ReviewStep__c(ReviewGroup__c = reviewGroup.Id);
            //ReviewStep__c reviewStep = [Select Id From ReviewStep__c Where ReviewGroup__c = :reviewGroup.Id];
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
            reviewPanel.Chair__c = u.id;
            insert reviewPanel;
    
            PanelUser__c panelUser = new PanelUser__c();
            panelUser.Reviewer__c = TestHelper.getPortalUser(true).id;
            panelUser.ReviewPanel__c = reviewPanel.id;       
            insert panelUser; 
    
            PanelApplication__c panelApplication = new PanelApplication__c();
            panelApplication.Application__c = app.id;
            panelApplication.ReviewPanel__c = reviewPanel.id;
            insert panelApplication;
    
            ReviewTriggerHelper.skipTrigger = true;
            Review__c review = new Review__c();
            review.Application__c = app.id;
            review.PanelApplication__c = panelApplication.id;
            review.PanelUser__c=panelUser.id;
            review.ReviewPanel__c = reviewPanel.id;
            review.Status__c = 'Review Completed';
            insert review;
        
        //act
        
        ApexPages.currentPage().getParameters().put('id',reviewGroup.Id);
        ReviewGroupEditCtrl ctrl = new ReviewGroupEditCtrl( new ApexPages.Standardcontroller(reviewGroup) );
        Test.stopTest();
        
        //assert
        System.assert(ctrl != null);
        System.assert(ctrl.getKeyValueMap() != null);
        }
    }
}