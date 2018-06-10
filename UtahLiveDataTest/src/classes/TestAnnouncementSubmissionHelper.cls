/**
 * Copyright REI Systems 2014 - 2016 
 * Test class for AnnouncementSubmissionHelper
 * Test the functionality that the given Announcement can be submitted successfully for approval
 * Positive Test case -
 * Negative Test case -   
 */
@isTest(seealldata =  false)
private with sharing class TestAnnouncementSubmissionHelper {

      static testMethod void testWhenClicked() {  
       Announcement__c ann=null;
       ReviewStepTemplate__c review = null;
       BusinessPackage__c businessPack = null;
       UserTriggerHelper.skipTrigger = true;
       User u = new User(Id=UserInfo.getUserId());
        
        System.runAs(u){
            GNT__KeyValueStore__c key= new GNT__KeyValueStore__c(Name='ENTERPRISE',GNT__BooleanValue__c=true);
            AnnouncementTriggerHelper.skipTrigger=true;
            ann=TestHelper.getGrantorAnnouncement(true);
           
            
            GNT.TriggerHelper.skipTrigger=true;
            RolesAndResponsibilitiesTriggerHelper.skipTrigger=true;
            
            ServiceArea__c serviceArea = TestHelper.getServiceArea(true);
 
            List<RolesAndResponsibilities__c> rolesAndResp = new List<RolesAndResponsibilities__c>();          
              
            RolesAndResponsibilities__c rolesAndResponsibilities2 = new RolesAndResponsibilities__c(Announcement__c = ann.Id,
                                                                            BusinessRole__c='Key POC',Name__c = ann.ProgramApprover__c);  
            RolesAndResponsibilities__c rolesAndResponsibilities3 = new RolesAndResponsibilities__c(Announcement__c = ann.Id,
                                                                            BusinessRole__c='Program Approver',Name__c = ann.ProgramApprover__c);
                                                                            

            rolesAndResp.add(rolesAndResponsibilities2);
            rolesAndResp.add(rolesAndResponsibilities3);
            insert rolesAndResp;
      
            Test.setCurrentPageReference(new PageReference('Page.AnnouncementView'));        
        }
        
        Test.startTest();
        AnnouncementSubmissionHelper annHelper = new AnnouncementSubmissionHelper();
        ApexPages.currentPage().getParameters().put('id', ann.Id);
        annHelper.whenClicked();
        Test.stopTest();
        
    }  
        
    
    static testMethod void testWhenClicked2() {  
       Account acct = null;
       Announcement__c ann=null;
       UserTriggerHelper.skipTrigger = true;
       User u = new User(Id=UserInfo.getUserId());
        
        System.runAs(u){
            GNT__KeyValueStore__c key= new GNT__KeyValueStore__c(Name='ENTERPRISE',GNT__BooleanValue__c=true);
                   
            AnnouncementTriggerHelper.skipTrigger=true;
            GNT.TriggerHelper.skipTrigger=true;
            RolesAndResponsibilitiesTriggerHelper.skipTrigger=true; 
            ann=TestHelper.getGrantorAnnouncement(true);
        }
        
        Test.startTest();
        AnnouncementSubmissionHelper annHelper = new AnnouncementSubmissionHelper();
        ApexPages.currentPage().getParameters().put('id', ann.Id);
        annHelper.whenClicked();
        Test.stopTest();
        
    }  
}