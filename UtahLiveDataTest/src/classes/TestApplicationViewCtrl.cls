@isTest(seealldata=true)
private with sharing class TestApplicationViewCtrl {
    static testMethod void viewTest() {
         UserTriggerHelper.skipTrigger = true;
         User u = TestHelper.getAdminUser(true);
          
         System.runAs(u){
           AnnouncementTriggerHelper.skipTrigger = true;
           Announcement__c ann = TestHelper.getAnnouncement(true);
           
           
           GNT__PageTemplate__c pt = TestHelper.getPageTemplateConfig(true);
           GNT__Package__c pack = TestHelper.getPackage(false, pt);
           pack.name='test';
           pack.GNT__SubmissionType__c = 'Application';
           pack.GNT__LatestVersion__c = true;
           pack.GNT__Status__c = 'Active';
           insert pack;
           
           BusinessPackage__c bp = new BusinessPackage__c();
           bp.PackageConfig__c=pack.Id;
           bp.PackageType__c = 'Application';
           
           bp.FundingOpportunity__c=ann.Id;
           insert bp;
           
           ApplicationTriggerHelper.skipTrigger = true;
           Application__c app = TestHelper.getApplication(ann.Id,true);
           
           Test.startTest();
           ApexPages.CurrentPage().getParameters().put('id',app.Id);
           ApexPages.CurrentPage().getParameters().put('enableSubmit', 'false');
           ApexPages.CurrentPage().getParameters().put('SR', 'test');
           
           ApexPages.StandardController stdController = new ApexPages.StandardController(app);
           ApplicationViewCtrl ctrl = new ApplicationViewCtrl(stdController);
           ctrl.getKeyValueMap();
           Test.stopTest();
         }
    }
}