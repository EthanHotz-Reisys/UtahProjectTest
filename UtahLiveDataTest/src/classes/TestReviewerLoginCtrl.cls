@isTest
public with sharing class TestReviewerLoginCtrl {
 
    @isTest
    public static void testAll(){
        UserTriggerHelper.skipTrigger = true;
        user u = TestHelper.getAdminUser(false);
        AnnouncementTriggerHelper.skipTrigger = true ;
        RolesandResponsibilitiesTriggerHelper.skipTrigger = true ;
        List<LoginPageConfig__c> listCustomSetting = new List<LoginPageConfig__c>();
        LoginPageConfig__c loginPage1 = new LoginPageConfig__c(Name='ReviewerLoginPage1',Active__c=true,PageName__c='ReviewerLogin1',UserType__c='Reviewer');
        listCustomSetting.add(loginPage1);      
        insert listCustomSetting;   
        Announcement__c ann = TestHelper.getAnnouncement(true);
        System.currentPageReference().getParameters().put('announcementId',ann.id);
        System.currentPageReference().getParameters().put('preApplication','true');     
   
        system.runAs(u){
            Test.startTest();
           
           ReviewerLoginCtrl ctrl = new ReviewerLoginCtrl();
            PageReference forwardToStart = ctrl.forwardToStartPage();
            Test.stopTest();
            system.assertNotEquals(forwardToStart,null);
        }
    }
    @isTest
    public static void testAll1(){
        UserTriggerHelper.skipTrigger = true;
        user u = TestHelper.getAdminUser(false);
        AnnouncementTriggerHelper.skipTrigger = true ;
        RolesandResponsibilitiesTriggerHelper.skipTrigger = true ;
        List<LoginPageConfig__c> listCustomSetting = new List<LoginPageConfig__c>();
        LoginPageConfig__c loginPage1 = new LoginPageConfig__c(Name='ReviewerLoginPage1',Active__c=true,PageName__c='ReviewerLogin1',UserType__c='Reviewer');
        listCustomSetting.add(loginPage1);      
        insert listCustomSetting;   
        Announcement__c ann = TestHelper.getAnnouncement(true);
       // System.currentPageReference().getParameters().put('announcementId',ann.id);
        System.currentPageReference().getParameters().put('preApplication','true');     
   
        system.runAs(u){
            Test.startTest();
           
           ReviewerLoginCtrl ctrl = new ReviewerLoginCtrl();
            PageReference forwardToStart = ctrl.forwardToStartPage();
            Test.stopTest();
            system.assertNotEquals(forwardToStart,null);
        }
    }
        @isTest
    public static void testAll2(){
        UserTriggerHelper.skipTrigger = true;
        user u = TestHelper.getAdminUser(false);
        AnnouncementTriggerHelper.skipTrigger = true ;
        RolesandResponsibilitiesTriggerHelper.skipTrigger = true ;
        List<LoginPageConfig__c> listCustomSetting = new List<LoginPageConfig__c>();
        LoginPageConfig__c loginPage1 = new LoginPageConfig__c(Name='ReviewerLoginPage1',Active__c=true,PageName__c='ReviewerLogin1',UserType__c='Reviewer');
        listCustomSetting.add(loginPage1);      
        insert listCustomSetting;   
        Announcement__c ann = TestHelper.getAnnouncement(true);
       // System.currentPageReference().getParameters().put('announcementId',ann.id);
        System.currentPageReference().getParameters().put('preApplication','true'); 
         System.currentPageReference().getParameters().put('startURL','https://');    
   
        system.runAs(u){
            Test.startTest();
           
           ReviewerLoginCtrl ctrl = new ReviewerLoginCtrl();
            PageReference forwardToStart = ctrl.forwardToStartPage();
            Test.stopTest();
            system.assertNotEquals(forwardToStart,null);
        }
    }
    
           @isTest
    public static void testAll3(){
        UserTriggerHelper.skipTrigger = true;
        user u = TestHelper.getAdminUser(false);
        AnnouncementTriggerHelper.skipTrigger = true ;
        RolesandResponsibilitiesTriggerHelper.skipTrigger = true ;
        List<LoginPageConfig__c> listCustomSetting = new List<LoginPageConfig__c>();
        LoginPageConfig__c loginPage1 = new LoginPageConfig__c(Name='ReviewerLoginPage1',Active__c=true,PageName__c='ReviewerLogin1',UserType__c='Aplicant');
        listCustomSetting.add(loginPage1);      
        insert listCustomSetting;  
        Announcement__c ann = TestHelper.getAnnouncement(true);
       // System.currentPageReference().getParameters().put('announcementId',ann.id);
        System.currentPageReference().getParameters().put('preApplication','true'); 
         System.currentPageReference().getParameters().put('startURL','https://');    
   
        system.runAs(u){
            Test.startTest();
           
           ReviewerLoginCtrl ctrl = new ReviewerLoginCtrl();
            PageReference forwardToStart = ctrl.forwardToStartPage();
            Test.stopTest();
            // system.assertNotEquals(null,null);
        }
    }
    
}