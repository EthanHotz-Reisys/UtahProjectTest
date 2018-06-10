@isTest
private class TestReviewPanelTemplateEditCtrl{
   
    @isTest
    private static void testReviewPanelTemplateEditCtrl(){
            User u1 = TestHelper.getAdminuser(false);
            UserTriggerHelper.skipTrigger = true;
            ApplicationTriggerHelper.skipTrigger = true;
            ReviewGroupTriggerHelper.skipTrigger = true;
            ReviewStepTriggerHelper.skipTrigger = true;

            TestHelper.createCustomSettings(true);            
            
            Announcement__c ann = TestHelper.getGrantorAnnouncementAll(true); 
            Application__c app = TestHelper.getGrantorApplication(ann.id,true);
        
            ReviewPanelTemplate__c panelTemplate = [SELECT ID,Name,ReviewStepTemplate__c, ReviewPackage__c from ReviewPanelTemplate__c where ReviewStepTemplate__r.Program__c = :ann.Program__c Limit 1];

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
          //  reviewPanel.Chair__c = u.id;
            insert reviewPanel;
            
            System.runAs(u1){ 
            Test.startTest();
            PanelUser__c panelUser = new PanelUser__c();
            panelUser.Reviewer__c = TestHelper.getPortalUser(true).id;
            panelUser.ReviewPanel__c = reviewPanel.id;       
            insert panelUser;             

            PanelApplication__c panelApplication = new PanelApplication__c();
            panelApplication.Application__c = app.id;
            panelApplication.ReviewPanel__c = reviewPanel.id;
            insert panelApplication;
           
            Review__c review = new Review__c();
            review.Application__c = app.id;
            review.PanelApplication__c = panelApplication.id;
            review.PanelUser__c=panelUser.id;
            review.ReviewPanel__c = reviewPanel.id;
            review.Status__c = 'Review Completed';
            insert review;
            
            reviewPanel = [SELECT Id,Name,ReviewPackage__c,ReviewStep__c  FROM ReviewPanel__c WHERE Id=:review.ReviewPanel__c LIMIT 1];
        
            panelTemplate = [SELECT Id,Name,RecordTypeId from ReviewPanelTemplate__c WHERE ReviewPackage__c=:reviewPanel.ReviewPackage__c LIMIT 1];
        
        
            reviewStep = [SELECT Id,ReviewStepTemplate__c From ReviewStep__c WHERE Id=:reviewPanel.ReviewStep__c LIMIT 1];        
            
            ReviewStepTemplate__c  reviewStepTemplate = new ReviewStepTemplate__c(Id = reviewStep.ReviewStepTemplate__c);
            insert reviewStepTemplate;
            //ReviewStepTemplate__c  reviewStepTemplate= [SELECT Id,Name FROM ReviewStepTemplate__c WHERE Id = :reviewStep.ReviewStepTemplate__c LIMIT 1];
                
            ApexPages.currentPage().getParameters().put('id',panelTemplate.id);
            ApexPages.currentPage().getParameters().put('reviewStepId',reviewStepTemplate.id);
            ApexPages.StandardController stdController = new ApexPages.StandardController(panelTemplate);
            ReviewPanelTemplateEditCtrl ctrl = new ReviewPanelTemplateEditCtrl(stdController);
            String keyValueMap = ctrl.getKeyValueMap();     
            
            system.AssertNotEquals(keyValueMap,null);             
            
            ApexPages.currentPage().getParameters().put('id',null);
            ApexPages.CurrentPage().getParameters().put('recordType','Application');
            ReviewPanelTemplate__c panelTemplateDummy = new ReviewPanelTemplate__c();
            panelTemplateDummy.id = null;                      
            stdController = new ApexPages.StandardController(panelTemplateDummy);                
            ctrl = new ReviewPanelTemplateEditCtrl(stdController);
            keyValueMap = ctrl.getKeyValueMap();  
            
            system.AssertNotEquals(keyValueMap,null); 
            Test.stopTest();
        }
    
    }
    
}