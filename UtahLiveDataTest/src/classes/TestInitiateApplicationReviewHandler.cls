@isTest
private with sharing class TestInitiateApplicationReviewHandler{
    static testMethod void testclickHandler() {
       /*
          User u = TestHelper.getAdminUser(true);
          System.runAs(u){
              
              List<string> IdSet = new List<String>();
              GNT__KeyValueStore__c key= new GNT__KeyValueStore__c(Name='ENTERPRISE',GNT__BooleanValue__c=true);
              AccountTriggerHelper.skipTrigger=true;
              ProgramTriggerHelper.skipTrigger = true;
              ReviewTriggerHelper.skipTrigger = true;
              
              Account acct = TestHelper.getAccount(true);
              
              AnnouncementTriggerHelper.skipTrigger = true;
              Announcement__c ann = TestHelper.getAnnouncement(true);
              Program__c pgm = TestHelper.getProgram(acct.Id,true);
              ReviewStepTemplate__c revStepTemp = TestHelper.getReviewStepTemplate(pgm.Id,false,'Application');
              revStepTemp.Announcement__c=ann.Id;
              revStepTemp.StepNumber__c=2;
              insert revStepTemp;
              
              ReviewPanelTemplate__c revPanelTemp = TestHelper.getReviewPanelTemplate(revStepTemp.Id,'Application',false);
              insert revPanelTemp;
              IdSet.add(ann.Id);
              
              Test.startTest();
              InitiateApplicationReviewHandler ctrl = new InitiateApplicationReviewHandler();
              ctrl.clickHandler();
              ctrl.selectedRecordIds=IdSet;
              ctrl.clickHandler();
              Test.stopTest();
          }
       */ 
    }
}