@isTest
private with sharing class TestReviewPanelUserTemplateViewCtrl{
    static testMethod void testController() {
    /*
        UserTriggerHelper.skipTrigger=true;
        User u = TestHelper.getAdminUser(true);
        System.runAs(u){
            GNT__KeyValueStore__c key= new GNT__KeyValueStore__c(Name='ENTERPRISE',GNT__BooleanValue__c=true);
            AccountTriggerHelper.skipTrigger=true;
            AnnouncementTriggerHelper.skipTrigger = true;
            ProgramTriggerHelper.skipTrigger = true;
            
            Account acct = TestHelper.getAccount(true);
            Program__c pgm = TestHelper.getProgram(acct.Id,true);
            Announcement__c announcement = TestHelper.getAnnouncement(true);
            //ReviewStepTemplate__c revStepTemplate = TestHelper.getReviewStepTemplate(pgm.Id,true,'Application');
            
            ReviewPanelTemplate__c panelTemplate = [SELECT ID,Name,ReviewStepTemplate__c, ReviewPackage__c from ReviewPanelTemplate__c where ReviewStepTemplate__r.Program__c = :announcement.Program__c];
            PanelUserTemplate__c panelUser = TestHelper.getPanelUserTemplate(panelTemplate.Id,true);
            
            Test.startTest();
            ApexPages.StandardController sc = new ApexPages.standardController(panelUser);
            ApexPages.currentPage().getParameters().put('id',panelUser.id);
            ReviewPanelUserTemplateViewCtrl ctrl = new ReviewPanelUserTemplateViewCtrl(sc);
            ctrl.getKeyValueMap();
            Test.stopTest();
        
         }
         
         */
    }
}