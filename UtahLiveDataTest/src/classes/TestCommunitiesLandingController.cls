@isTest
private with sharing class TestCommunitiesLandingController {

    
      
    @isTest
    static void testforwardToStartPage2() {  
        UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(false);
        u.IsFirstLoginDone__c = true;
        insert u;
        
        System.runAs(u){
        
            AnnouncementTriggerHelper.skipTrigger = true;
            ApplicationTriggerHelper.skipTrigger = true;
            UserTriggerHelper.skipTrigger = true;
            
            Announcement__c ann = TestHelper.getAnnouncement(true);
            Application__c app = TestHelper.getApplication(ann.Id,true);
            PreApplication__c preApp = TestHelper.getPreApplication(true);
            
            GNT__CustomAppPhaseConfig__c customApp = TestHelper.getCustomAppPhaseConfig(false);
            customApp.GNT__CustomAppName__c='StateasGrantee';
            customApp.GNT__Active__c=true;
            customApp.GNT__SelectedByDefault__c =true;
            insert customApp;
            Test.startTest();
            System.currentPageReference().getParameters().put('announcementId',ann.Id);
            System.currentPageReference().getParameters().put('preApplication','No');
            System.currentPageReference().getParameters().put('startURL','/apex/Sample');
            System.currentPageReference().getParameters().put('Id',app.Id);
            ApexPages.currentPage().getHeaders().put('host','Test');
            System.currentPageReference().getParameters().put('username','Test');
            CommunitiesLandingController ctrl = new CommunitiesLandingController();
            ctrl.forwardToStartPage();
            ctrl.warningTitle = 'Warning Test';
            ctrl.warningMessage='Warning Test Message';
            Test.stopTest();
            
        }
    
    }
    
     @isTest
    static void testforwardToStartPage() {  
        UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
        
        System.runAs(u){
        
            AnnouncementTriggerHelper.skipTrigger = true;
            ApplicationTriggerHelper.skipTrigger = true;
            UserTriggerHelper.skipTrigger = true;
            
            Announcement__c ann = TestHelper.getAnnouncement(true);
            Application__c app = TestHelper.getApplication(ann.Id,true);
            PreApplication__c preApp = TestHelper.getPreApplication(true);
    
            
            Test.startTest();
            System.currentPageReference().getParameters().put('announcementId',ann.Id);
            System.currentPageReference().getParameters().put('preApplication','No');
            System.currentPageReference().getParameters().put('startURL','/apex/Sample');
            System.currentPageReference().getParameters().put('Id',app.Id);
            ApexPages.currentPage().getHeaders().put('host','Test');
            System.currentPageReference().getParameters().put('username','Test');
            CommunitiesLandingController ctrl = new CommunitiesLandingController();
            ctrl.forwardToStartPage();
            ctrl.warningTitle = 'Warning Test';
            ctrl.warningMessage='Warning Test Message';
            Test.stopTest();
            
        }
    
    } 
}