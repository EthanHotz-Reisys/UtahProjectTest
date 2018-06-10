@isTest
private class TestPreAppSubmissionHelper{
     static testMethod void testWhenClicked() {  
          User u = TestHelper.getAdminUser(true); 
         
          System.runAs(u){
              AppUtils.skipStepReviewTrigger = true;
              ProgramTriggerHelper.skipTrigger=true;
              AnnouncementTriggerHelper.skipTrigger=true;
              ApplicationTriggerHelper.skipTrigger=true;
              ApplicationTriggerHelper.skipTrigger = true;
              GNT__CustomAppConfig__c cac = TestHelper.getCustomAppConfig(false);
              Announcement__c ann = TestHelper.getAnnouncement(false);
              ann.ApplicationCreatedOutside__c = 'Yes';
              insert ann;
              
              Application__c app = TestHelper.getApplication(ann.Id,true);
              PreApplication__c preApp = TestHelper.getPreApplication(false);
              preApp.Announcement__c=ann.Id;
              preApp.RequestedAmount__c=10;
              preApp.AwardFloor__c=20;
              preApp.AwardCeiling__c=5;
              preApp.FormsValidated__c = false;
              insert preApp;

              System.debug('in Test class, the record Id is --->'+preApp.Id);
              System.debug('In Test Class, the outside application --->'+preApp.ApplicationCreatedOutside__c);
              String ns = AppUtils.getNamespacePrefix();
              GNT__PageLayoutConfig__c pageLayoutConfig =  TestHelper.getPageLayoutConfig(true,ns + 'PreApplication__c');
              GNT__TabConfig__c tabConfig =  TestHelper.getTabConfig(pageLayoutConfig.Id,true);
              GNT__PageBlockConfig__c pageBlockConfig =  TestHelper.getPageBlockConfig(tabConfig.Id, true);
              GNT__PageBlockDetailConfig__c pageBlockDetailConfigList = TestHelper.getPageBlockDetailConfig(pageBlockConfig.Id,false); 
           
              if(pageBlockDetailConfigList.GNT__FieldAPIName__c == 'Name') {
                    insert pageBlockDetailConfigList;
              }
            
              GNT__PageLayoutActionConfig__c pageAction = TestHelper.getPageLayoutActionConfig(true,pageLayoutConfig.Id);
              GNT.DynamicLayoutHolder layoutHolder = new GNT.DynamicLayoutHolder(pageLayoutConfig.id, preApp.Id,true);
              
            
              Test.startTest();
              PreAppSubmissionHelper ctrl = new PreAppSubmissionHelper();
              ctrl.layoutHolder = layoutHolder;
              ctrl.whenClicked();
              
              Test.stopTest();
        }
    
   }
   
   
        static testMethod void testWhenClicked2() {  
          User u = TestHelper.getAdminUser(true); 
          
          GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateasGrantee');
          System.runAs(u){
              AppUtils.skipStepReviewTrigger = true;
              ProgramTriggerHelper.skipTrigger=true;
              AnnouncementTriggerHelper.skipTrigger=true;
              ApplicationTriggerHelper.skipTrigger=true;
              ApplicationTriggerHelper.skipTrigger = true;
              ReviewTriggerHelper.skipTrigger = true;
              
              GNT__CustomAppConfig__c cac = TestHelper.getCustomAppConfig(true);
              Announcement__c ann = TestHelper.getAnnouncement(true);
              ann.ApplicationCreatedOutside__c = 'Yes';
              update ann;
              
              Application__c app = TestHelper.getApplication(ann.Id,true);
              PreApplication__c preApp = TestHelper.getPreApplication(true);
              preApp.ProgramApprover__c=u.Id;
              preApp.FormsValidated__c=true;
              preApp.Status__c='Reviewed';
              update preApp;
              
              Review__c rev = new Review__c();
              insert rev;
              
              ApplicationReview__c appReview = new ApplicationReview__c(Application__c = app.Id,PreApplication__c=preApp.Id);
              insert appreview;
              
              GNT__AttachmentExtension__c attach = TestHelper.getAttachmentExtension('APPLICATION FORMS',preApp.Id,true);

              String ns = AppUtils.getNamespacePrefix();
              GNT__PageLayoutConfig__c pageLayoutConfig =  TestHelper.getPageLayoutConfig(true,ns + 'PreApplication__c');
              GNT__TabConfig__c tabConfig =  TestHelper.getTabConfig(pageLayoutConfig.Id,true);
              GNT__PageBlockConfig__c pageBlockConfig =  TestHelper.getPageBlockConfig(tabConfig.Id, true);
              GNT__PageBlockDetailConfig__c pageBlockDetailConfigList = TestHelper.getPageBlockDetailConfig(pageBlockConfig.Id,false); 
           
              if(pageBlockDetailConfigList.GNT__FieldAPIName__c == 'Name') {
                    insert pageBlockDetailConfigList;
              }
            
              GNT__PageLayoutActionConfig__c pageAction = TestHelper.getPageLayoutActionConfig(true,pageLayoutConfig.Id);
              GNT.DynamicLayoutHolder layoutHolder = new GNT.DynamicLayoutHolder(pageLayoutConfig.id, preApp.Id,true);
              
              GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateasGrantee');
              Test.startTest();
              PreAppSubmissionHelper ctrl = new PreAppSubmissionHelper();
              ctrl.layoutHolder = layoutHolder;
              ctrl.whenClicked();
              
              Test.stopTest();
        }
    
   }
   
}