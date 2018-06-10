/**
    Test class for ReviewGroupViewCtrl
    **********************************************************
    Audit History
    **********************************************************
    4/27/2014   Someone   Created
    4/28/2014   Ryan Chadwick                       modified
    7/24/2015   Aman Oberoi                        modified
    **********************************************************  
*/
@isTest
private with sharing class TestReviewGroupViewCtrl {

    @IsTest(OnInstall=false)
    public static void test_ctrl() {
         User u = TestHelper.getAdminUser(false);
        Contact c = new Contact();
        c.LastName = 'Test';
        c.Email = 'Test@test.com';
        insert c;
        System.runAs(u) {
            AnnouncementTriggerHelper.skipTrigger=true;
          ReviewGroupTriggerHelper.skipTrigger=true;
            Group gp = new Group(Name='test1',Type='Regular');
            insert gp;
            GroupMember gmember = new GroupMember();
            gmember.GroupId = gp.Id;
            gmember.UserOrGroupId = u.Id;
            insert gmember;
            GNT.KeyValueStoreHelper.setTextValue('ExternalUserPublicGroup',gp.Name,true);
            TestHelper.CreateCustomSettings(true);
            ReviewStepTriggerHelper.skipTrigger=true;
            ReviewGroup__c reviewGroup = TestHelper.getReviewGroupAll(true);
            
            System.debug('*****' + reviewGroup.Id + ' ' + reviewGroup.Name + ' ' + reviewGroup.Announcement__c + ' ' + reviewGroup.Announcement__r + ' ' + reviewGroup.Program__c + ' ');
            
            ApplicationTriggerHelper.skipTrigger=true;
            
            ReviewGroup__c revGp = [Select Id, Name,Announcement__c,Announcement__r.Program__c from ReviewGroup__c where Id=:reviewGroup.Id];
            Test.StartTest();
            Id annId = revGp.Announcement__c;
            Application__c app = TestHelper.getGrantorApplication(annId,true);
            ReviewPanelTemplate__c panelTemplate = [SELECT ID,Name,ReviewStepTemplate__c, ReviewPackage__c from ReviewPanelTemplate__c where ReviewStepTemplate__r.Program__c = :revGp.Announcement__r.Program__c ];
            
            ReviewGroup__c reviewGroup2 = new ReviewGroup__c();
            reviewGroup2.Announcement__c = annId;
            reviewGroup2.NumberOfReviewSteps__c= Decimal.valueOf('10.0');
            insert reviewGroup2;
            system.debug('**reviewGroup2** '+ reviewGroup2);
            
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
        ReviewGroupViewCtrl ctrl = new ReviewGroupViewCtrl( new ApexPages.Standardcontroller( reviewGroup ) );
        ctrl.recordId = reviewGroup2.Id;
        ctrl.reviewGrp = reviewGroup2;
        Test.stopTest();

        //assert
        System.assert(ctrl != null);
        System.assertEquals(ctrl.recordId, reviewGroup2.Id);
        }
    }
    
    @IsTest(OnInstall=false)
    public static void test_getKeyValueMap() {

        User u = TestHelper.getAdminUser(false);
        Contact c = new Contact();
        c.LastName = 'Test';
        c.Email = 'Test@test.com';
        insert c;
        
        System.runAs(u) {
        AnnouncementTriggerHelper.skipTrigger=true;
        TestHelper.CreateCustomSettings(true);
        ReviewGroupTriggerHelper.skipTrigger=true;
        ReviewStepTriggerHelper.skipTrigger=true;
        ReviewGroup__c reviewGroup = TestHelper.getReviewGroupAll(true); 
        ApplicationTriggerHelper.skipTrigger=true;        
            ReviewGroup__c revGp = [Select Id, Name,Announcement__c,Announcement__r.Program__c from ReviewGroup__c where id=:reviewGroup.Id];
            Id annId = revGp.Announcement__c;
              Application__c app = TestHelper.getApplication(annId,true);
            ReviewPanelTemplate__c panelTemplate = [SELECT ID,Name,ReviewStepTemplate__c, ReviewPackage__c from ReviewPanelTemplate__c where ReviewStepTemplate__r.Program__c = :revGp.Announcement__r.Program__c ];
    
            system.debug('**reviewGroup** '+ reviewGroup);
           
            ReviewStep__c reviewStep = new ReviewStep__c(ReviewGroup__c = reviewGroup.Id);
            insert reviewStep;
            
            
            ReviewStepApplication__c reviewStepApp = new ReviewStepApplication__c();
            reviewStepApp.ReviewStep__c = reviewStep.id;
            reviewStepApp.Application__c = app.id;
            insert reviewStepApp;
            
            Test.StartTest();
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
        
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('reviewGroupId', reviewGroup.Id);
        keyValueMap.put('announcementId',reviewGroup.Announcement__c);
        
        //act
        
        ApexPages.currentPage().getParameters().put('id',reviewGroup.Id);
        ReviewGroupViewCtrl ctrl = new ReviewGroupViewCtrl( new ApexPages.Standardcontroller( reviewGroup ) );
        ctrl.reviewGrp = reviewGroup;
        String keymapJSON = ctrl.getKeyValueMap();
        Test.stopTest();

        //assert
        System.assertNotEquals(null, JSON.serialize(keyValueMap) );
        }
    }
}