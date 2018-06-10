@isTest
public class GrantEditCtrlTest {
    static testMethod void someTest() {
         Account acc =null;
         Announcement__c ann=null;
         Application__c app = null;
         List<User> userlist = new List<User>();
         
         ProgramTriggerHelper.skipTrigger=true;
         GNT.TriggerHelper.skipTrigger=true;
         RolesAndResponsibilitiesTriggerHelper.skipTrigger=true;
         AnnouncementTriggerHelper.skipTrigger=true;
         AccountTriggerHelper.skipTrigger=true;
             
         GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateasGrantee');
         userlist = [Select GNT__OrganizationId__c from User where Id =:UserInfo.getUserId()];
         AccountTriggerHelper.skipTrigger = true;
         acc = TestHelper.getAccount(true);
         userlist[0].GNT__OrganizationId__c = acc.id;
         update userlist;
             
         ann=TestHelper.getAnnouncement(true);
         app=TestHelper.getApplication(ann.Id,true);
         
         Grant__c grnts = new Grant__c();
         grnts.ProjectPeriodStartDate__c=Date.newInstance(2015,3,14);
         grnts.ProjectPeriodEndDate__c=Date.newInstance(2016,3,14);
         grnts.IssueDate__c=Date.newInstance(2014,3,14);
         grnts.SpendType__c = 'Sub Awards';
         insert grnts;
         Test.startTest();
         
         //ApexPages.currentPage().getParameters().put('id',acc.Id);
         ApexPages.currentPage().getParameters().put('id',grnts.Id);
         ApexPages.currentPage().getParameters().put('applicationid',app.Id);
         ApexPages.StandardController sc = new ApexPages.standardController(acc);
         GrantEditCtrl e = new GrantEditCtrl(sc);
         e.getKeyValueMap();
         Test.stopTest();
    }
    
    static testMethod void someTest2() {
         Account acc =null;
         Announcement__c ann=null;
         Application__c app = null;
         List<User> userlist = new List<User>();
         
         ProgramTriggerHelper.skipTrigger=true;
         GNT.TriggerHelper.skipTrigger=true;
         RolesAndResponsibilitiesTriggerHelper.skipTrigger=true;
         AnnouncementTriggerHelper.skipTrigger=true;
         AccountTriggerHelper.skipTrigger=true;
             
         GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateasGrantor');
         userlist = [Select GNT__OrganizationId__c from User where Id =:UserInfo.getUserId()];
         AccountTriggerHelper.skipTrigger = true;
         acc = TestHelper.getAccount(true);
         userlist[0].GNT__OrganizationId__c = acc.id;
         update userlist;
             
         ann=TestHelper.getAnnouncement(true);
         app=TestHelper.getApplication(ann.Id,true);
         GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateasGrantor');
         
         Grant__c grnts = new Grant__c();
         grnts.ProjectPeriodStartDate__c=Date.newInstance(2015,3,14);
         grnts.ProjectPeriodEndDate__c=Date.newInstance(2016,3,14);
         grnts.IssueDate__c=Date.newInstance(2014,3,14);
         grnts.SpendType__c = 'Contracts';
         insert grnts;
         
         Test.startTest();
         
         //ApexPages.currentPage().getParameters().put('id',acc.Id);
         ApexPages.currentPage().getParameters().put('id',grnts.Id);
         ApexPages.currentPage().getParameters().put('applicationid',app.Id);
         ApexPages.StandardController sc = new ApexPages.standardController(acc);
         GrantEditCtrl e = new GrantEditCtrl(sc);
         Test.stopTest();
    }
     
}