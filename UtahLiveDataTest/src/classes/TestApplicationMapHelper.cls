@isTest
private with sharing class TestApplicationMapHelper{
    static testMethod void testgetPins() {
       /*
          UserTriggerHelper.skipTrigger = true;
          User u = TestHelper.getAdminUser(true);
          System.runAs(u){
          
              GNT__KeyValueStore__c key= new GNT__KeyValueStore__c(Name='ENTERPRISE',GNT__BooleanValue__c=true);
              AccountTriggerHelper.skipTrigger=true;
              Account acct = TestHelper.getAccount(false);
              acct.ShippingLongitude=10.9;
              acct.ShippingLatitude=11.1;
              insert acct;
              Map<String,String> urlParams = new Map<String,String>();
              
              AnnouncementTriggerHelper.skipTrigger = true;
              ApplicationTriggerHelper.skipTrigger = true;
              Announcement__c announcement = TestHelper.getAnnouncement(true); 
              Application__c app= TestHelper.getApplication(announcement.Id,false);
              app.Status__c='Submitted to Grantor';
              app.ExternalOrganization__c=acct.Id;
              insert app;
        
              urlParams.put('id',app.Id);
              
              Test.startTest();
              ApplicationMapHelper ctrl = new ApplicationMapHelper();
              ctrl.getPins(urlParams);
              Test.stopTest();
          }
        */
    }
    
}