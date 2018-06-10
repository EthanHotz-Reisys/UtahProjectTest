@isTest
private with sharing class TestReviewPanelTriggerHelper {

    private static Review__c review;
    private static  ReviewPanel__c rPanel;
    private static  Application__c app;
    private static ReviewStep__c reviewStep;    

    private static void setup(Boolean create){   
        UserTriggerHelper.skipTrigger=true; 
        ReviewStepTriggerHelper.SkipTrigger=true;
        AppUtils.skipStepReviewTrigger = true;              
        Testhelper.createCustomSettings(true);             
        review = TestHelper.getReview(create);  
        rPanel = [Select Id, AnnoucementId__c, ReviewStep__c, ReviewPackage__c From ReviewPanel__c Where Id = : review.ReviewPanel__c];            
    }

   /* @isTest
    private static void testMethodSetGroupId(){
        UserTriggerHelper.skipTrigger=true;
        User u = TestHelper.getAdminUser(false);
        System.runAs(u){     
            Test.startTest();
            setup(true);
            
            Group testGroup = new Group(Name = 'Queue', Type = 'Queue');
            insert testGroup;
            
            rPanel.GroupName__c = 'Queue';
            update rPanel;
            Test.stopTest();
        }
    }
    
    @isTest
    private static void testUpdateMethod(){        
        UserTriggerHelper.skipTrigger=true;
        User u = TestHelper.getAdminUser(false);       
        System.runAs(u){    
            Test.startTest();    
            setup(true);      
            rPanel.Chair__c = TestHelper.getStandardPlatformUser(true).Id;
            update rPanel;
            Test.stopTest();
        }
    }*/

}