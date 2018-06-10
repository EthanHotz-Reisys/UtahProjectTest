@isTest
private with sharing class TestReviewStepTemplateEditCtrl{
    @isTest
    private static void testReviewStepTemplateEditCtrl(){
        UserTriggerHelper.skipTrigger=true;
        User u=TestHelper.getAdminUser(true);
        System.runAs(u){
            ReviewStepTemplate__c rst = new ReviewStepTemplate__c();
            rst.DefaultStep__c=true;
            rst.CustomAppName__c='StateasGrantor';
            rst.Description__c='Step 1';
            rst.StepNumber__c=1;
            insert rst;
            TestHelper.CreateCustomSettings(true);
            Test.startTest();
             Account acc = new Account();
            acc.Name = 'test'+system.currentTimeMillis();
            acc.status__c = 'Active';
            GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateAsGrantor');
            GNT__PageLayoutConfig__c pageLayoutConfig =  TestHelper.getPageLayoutConfig(true);
            TestHelper.ggsTempPack1_PageTemplate(true,pageLayoutConfig);
            Program__c program = TestHelper.getGrantorProgram(acc.id,false);
            program.status__c = 'Active';
            insert program;
            ReviewStepTemplate__c template = TestHelper.getReviewStepTemplate(program.Id, true, 'Application');
            ApexPages.CurrentPage().getParameters().put('id',template.id);            
            ApexPages.StandardController stdController = new ApexPages.StandardController(template);
            ReviewStepTemplateEditCtrl rstec=new ReviewStepTemplateEditCtrl(stdController);
            rstec.getKeyValueMap();
            Test.stopTest();
            System.assert(rstec.recordId == template.id);
        }
       
    } 
    
     @isTest
    private static void testReviewStepTemplateEditCtrl1(){
        UserTriggerHelper.skipTrigger=true;
        User u=TestHelper.getAdminUser(true);
        System.runAs(u){
           ReviewStepTemplate__c rst = new ReviewStepTemplate__c();
            rst.DefaultStep__c=true;
            rst.CustomAppName__c='StateasGrantor';
            rst.Description__c='Step 1';
            rst.StepNumber__c=1;
            insert rst;
            TestHelper.CreateCustomSettings(true);
            Test.startTest();
             Account acc = new Account();
            acc.Name = 'test'+system.currentTimeMillis();
            acc.status__c = 'Active';
            GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateAsGrantor');
            GNT__PageLayoutConfig__c pageLayoutConfig =  TestHelper.getPageLayoutConfig(true);
            TestHelper.ggsTempPack1_PageTemplate(true,pageLayoutConfig);
            Program__c program = TestHelper.getGrantorProgram(acc.id,false);
            program.status__c = 'Active';
            insert program;
           // Announcement__c ann=TestHelper.getGrantorAnnouncement(true);
            ReviewStepTemplate__c template = TestHelper.getReviewStepTemplate(program.Id, false, 'Application');
            ApexPages.CurrentPage().getParameters().put('recordType','Application');
            ApexPages.CurrentPage().getParameters().put('id',template.id);  
            ApexPages.CurrentPage().getParameters().put('programid',program.id);
           // ApexPages.CurrentPage().getParameters().put('announcementId',ann.id);          
            ApexPages.StandardController stdController = new ApexPages.StandardController(template );
            ReviewStepTemplateEditCtrl rstec=new ReviewStepTemplateEditCtrl(stdController);
            system.assertNotEquals(rstec.getKeyValueMap(),null);
            Test.stopTest();
        }
    } 
    
     @isTest
    private static void testReviewStepTemplateEditCtrlForPreApplication(){
        UserTriggerHelper.skipTrigger=true;
        User u=TestHelper.getAdminUser(true);
        System.runAs(u){
            ReviewStepTemplate__c rst = new ReviewStepTemplate__c();
            rst.DefaultStep__c=true;
            rst.CustomAppName__c='StateasGrantor';
            rst.Description__c='Step 1';
            rst.StepNumber__c=1;
            insert rst;
            TestHelper.CreateCustomSettings(true);
            Test.startTest();
             Account acc = new Account();
            acc.Name = 'test'+system.currentTimeMillis();
            acc.status__c = 'Active';
            GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateAsGrantor');
            GNT__PageLayoutConfig__c pageLayoutConfig =  TestHelper.getPageLayoutConfig(true);
            TestHelper.ggsTempPack1_PageTemplate(true,pageLayoutConfig);
            Program__c program = TestHelper.getGrantorProgram(acc.id,false);
            program.status__c = 'Active';
            insert program;
            ReviewStepTemplate__c template = TestHelper.getReviewStepTemplate(program.Id, false, 'Application');
            ApexPages.CurrentPage().getParameters().put('recordType','Pre-application');
            ApexPages.CurrentPage().getParameters().put('id',template.id);            
            ApexPages.StandardController stdController = new ApexPages.StandardController(template);
            ReviewStepTemplateEditCtrl rstec=new ReviewStepTemplateEditCtrl(stdController);
            system.assertNotEquals(rstec.getKeyValueMap(),null);
            Test.stopTest();
       }
    }
}