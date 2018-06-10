@isTest
private with sharing class TestNotifySiteVisitGrantee{
    static testMethod void testController() {
          
          User u = TestHelper.getAdminUser(true);
          SiteVisit__c siteVisit = null;
          SiteVisitPerson__c siteVisitPerson = null;
          EmailTemplate emailTemp = null;
          Contact ct = null;
          
          System.runAs(u){
             GrantTriggerHelper.skipTrigger = true;
             siteVisit = TestHelper.getSiteVisit(false);
             //Date myDate = Date.newInstance(2016, 12, 18);
             //Time myTime = Time.newInstance(3, 3, 3, 0);
             DateTime dt = DateTime.now();
             siteVisit.VisitEndDateTime__c=dt;
             insert siteVisit;
             
             siteVisit.SiteVisitPersons__c='DavidTest';
             siteVisit.NotifiedRecipientPointofContact__c = false;
             siteVisit.ActivityQuestion1__c = 'Test 1';
             siteVisit.ActivityQuestion3__c ='Test 2';
             siteVisit.TypeofSiteVisit__c = 'Planned';
             siteVisit.SubAwardee__c=u.Id;
             siteVisit.NotificationTemplate__c= 'Test Template';
             update siteVisit;
             
             siteVisitPerson = new SiteVisitPerson__c(SiteVisit__c=siteVisit.Id);
             insert siteVisitPerson;
           
             //emailTemp = new EmailTemplate(DeveloperName='GranteeSiteVisitNotifyEmailTemplate');
             //insert emailTemp;
             
             ct = TestHelper.getContact(true);
          }   
         
        Test.startTest();
        ApexPages.CurrentPage().getParameters().put('id',siteVisit.Id);
        NotifySiteVisitGrantee ctrl = new NotifySiteVisitGrantee();
        ctrl.whenClicked();
        Test.stopTest();
        
    }
    
    static testMethod void testController2() {
          
          User u = TestHelper.getAdminUser(true);
          SiteVisit__c siteVisit = null;
          
          System.runAs(u){
             GrantTriggerHelper.skipTrigger = true;
             siteVisit = TestHelper.getSiteVisit(false);
             //Date myDate = Date.newInstance(2016, 12, 18);
             //Time myTime = Time.newInstance(3, 3, 3, 0);
             DateTime dt = DateTime.now();
             siteVisit.VisitEndDateTime__c=dt;
             insert siteVisit;
          }   
         
        Test.startTest();
        ApexPages.CurrentPage().getParameters().put('id',siteVisit.Id);
        NotifySiteVisitGrantee ctrl = new NotifySiteVisitGrantee();
        ctrl.whenClicked();
        Test.stopTest();
        
    }
    
     static testMethod void testController3() {
          
          User u = TestHelper.getAdminUser(true);
          SiteVisit__c siteVisit = null;
          SiteVisitPerson__c siteVisitPerson = null;

          System.runAs(u){
             GrantTriggerHelper.skipTrigger = true;
             siteVisit = TestHelper.getSiteVisit(false);
             //Date myDate = Date.newInstance(2016, 12, 18);
             //Time myTime = Time.newInstance(3, 3, 3, 0);
             DateTime dt = DateTime.now();
             siteVisit.VisitEndDateTime__c=dt;
             insert siteVisit;
             
             siteVisit.SiteVisitPersons__c='DavidTest';
             update siteVisit;
             
             siteVisitPerson = new SiteVisitPerson__c(SiteVisit__c=siteVisit.Id);
             insert siteVisitPerson;
          }   
         
        Test.startTest();
        ApexPages.CurrentPage().getParameters().put('id',siteVisit.Id);
        NotifySiteVisitGrantee ctrl = new NotifySiteVisitGrantee();
        ctrl.whenClicked();
        Test.stopTest();
        
    }
    
     static testMethod void testController4() {
          
          User u = TestHelper.getAdminUser(true);
          SiteVisit__c siteVisit = null;
          SiteVisitPerson__c siteVisitPerson = null;
          EmailTemplate emailTemp = null;
          Contact ct = null;
          
          System.runAs(u){
             GrantTriggerHelper.skipTrigger = true;
             siteVisit = TestHelper.getSiteVisit(false);
             //Date myDate = Date.newInstance(2016, 12, 18);
             //Time myTime = Time.newInstance(3, 3, 3, 0);
             DateTime dt = DateTime.now();
             siteVisit.VisitEndDateTime__c=dt;
             insert siteVisit;
             
             siteVisit.SiteVisitPersons__c='DavidTest';
             siteVisit.NotifiedRecipientPointofContact__c = false;
             siteVisit.ActivityQuestion1__c = 'Test 1';
             siteVisit.ActivityQuestion3__c ='Test 2';
             siteVisit.TypeofSiteVisit__c = 'Planned';
             siteVisit.NotificationTemplate__c= 'Test Template';
             update siteVisit;
             
             siteVisitPerson = new SiteVisitPerson__c(SiteVisit__c=siteVisit.Id);
             insert siteVisitPerson;
           
             //emailTemp = new EmailTemplate(DeveloperName='GranteeSiteVisitNotifyEmailTemplate');
             //insert emailTemp;
             
             ct = TestHelper.getContact(true);
          }   
         
        Test.startTest();
        ApexPages.CurrentPage().getParameters().put('id',siteVisit.Id);
        NotifySiteVisitGrantee ctrl = new NotifySiteVisitGrantee();
        ctrl.whenClicked();
        Test.stopTest();
        
    }
}