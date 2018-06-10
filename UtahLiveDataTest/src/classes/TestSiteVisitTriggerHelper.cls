/**
* SiteVisitTriggerHelper
* @author: Sarat Mahavratayajula
*/
@isTest
private with sharing class TestSiteVisitTriggerHelper {
                        
    @isTest static void someTest()
      {
        UserTriggerHelper.skipTrigger=true;
        user u = TestHelper.getAdminUser(true);
        system.runAs(u) {
            // skip unwanted triggers
            AnnouncementTriggerHelper.skipTrigger = true;
            ApplicationtriggerHelper.skiptrigger = true;
            RolesandResponsibilitiesTriggerHelper.skipTrigger = true;
            GranttriggerHelper.skipTrigger = true;
            AwardTriggerHelper.skipTrigger = true;

            Announcement__c ann = TestHelper.getAnnouncement(true);
            Application__c app = TestHelper.getApplication(ann.Id,true);

            Grant__c grant = new Grant__c(ProjectPeriodStartDate__c=Date.newInstance(2015,3,14),
                                          ProjectPeriodEndDate__c=Date.newInstance(2016,3,14),
                                          IssueDate__c=Date.newInstance(2015,2,14),
                                          Program__c=ann.Program__c,GranteePOC__c = u.id);
            insert grant;

            Award__c awd = TestHelper.getAwards(grant.Id,true);

            Id recTypeId = TestHelper.getRecordType(Schema.SObjectType.RolesAndResponsibilities__c,'Award');

            List<RolesAndResponsibilities__c> rolesandResponsibilities = new List<RolesAndResponsibilities__c>();

            RolesAndResponsibilities__c rolesAndResponsibility1 = new RolesAndResponsibilities__c(RecordTypeId=recTypeId,
                                                                    Award__c=awd.Id,
                                                                    Name__c=u.Id,
                                                                    BusinessRole__c='Program Approver');
            RolesAndResponsibilities__c rolesAndResponsibility2 = new RolesAndResponsibilities__c(RecordTypeId=recTypeId,
                                                                    Award__c=awd.Id,
                                                                    Name__c=u.Id,
                                                                    BusinessRole__c='Fiscal Approver');

            rolesandResponsibilities.add(rolesAndResponsibility1);
            rolesandResponsibilities.add(rolesAndResponsibility2);

            insert rolesandResponsibilities;

            //Id recordTypeId = TestHelper.getRecordType(Schema.SObjectType.ActiveAppName__c,'StateasGrantor');
            GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c', 'StateasGrantor');
            SiteVisit__c siteVisit = new SiteVisit__c(VisitDateandTime__c=System.today() + 1,   
                                    VisitEndDateTime__c = system.today() + 60,Recommendation__c = 'test',
                                    ProgramRating__c = 'test',Status__c='Planned',Award__c=awd.Id);
            insert siteVisit;

            siteVisit.ProgramRating__c = 'test 1';
            update siteVisit;

            Test.startTest();
                SiteVisitTriggerHelper SiteVisitTriggerHelper = new SiteVisitTriggerHelper();
            Test.stopTest();
        }                    
    }  
    @isTest static void someTest1()
      {
        UserTriggerHelper.skipTrigger=true;
        user u = TestHelper.getAdminUser(true);
        system.runAs(u) {
            // skip unwanted triggers
            AnnouncementTriggerHelper.skipTrigger = true;
            ApplicationtriggerHelper.skiptrigger = true;
            RolesandResponsibilitiesTriggerHelper.skipTrigger = true;
            GranttriggerHelper.skipTrigger = true;
            AwardTriggerHelper.skipTrigger = true;

            Announcement__c ann = TestHelper.getAnnouncement(true);
            Application__c app = TestHelper.getApplication(ann.Id,true);

            Grant__c grant = new Grant__c(ProjectPeriodStartDate__c=Date.newInstance(2015,3,14),
                                          ProjectPeriodEndDate__c=Date.newInstance(2016,3,14),
                                          IssueDate__c=Date.newInstance(2015,2,14),
                                          Program__c=ann.Program__c,GranteePOC__c = u.id);
            insert grant;

            Award__c awd = TestHelper.getAwards(grant.Id,true);

            Id recTypeId = TestHelper.getRecordType(Schema.SObjectType.RolesAndResponsibilities__c,'Award');

            List<RolesAndResponsibilities__c> rolesandResponsibilities = new List<RolesAndResponsibilities__c>();

            RolesAndResponsibilities__c rolesAndResponsibility1 = new RolesAndResponsibilities__c(RecordTypeId=recTypeId,
                                                                    Award__c=awd.Id,
                                                                    Name__c=u.Id,
                                                                    BusinessRole__c='Program Approver');
            RolesAndResponsibilities__c rolesAndResponsibility2 = new RolesAndResponsibilities__c(RecordTypeId=recTypeId,
                                                                    Award__c=awd.Id,
                                                                    Name__c=u.Id,
                                                                    BusinessRole__c='Fiscal Approver');

            rolesandResponsibilities.add(rolesAndResponsibility1);
            rolesandResponsibilities.add(rolesAndResponsibility2);

            insert rolesandResponsibilities;

            //Id recordTypeId = TestHelper.getRecordType(Schema.SObjectType.ActiveAppName__c,'StateasGrantor');
            GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c', 'StateasGrantee');
            SiteVisit__c siteVisit = new SiteVisit__c(VisitDateandTime__c=System.today() + 1,   
                                    VisitEndDateTime__c = system.today() + 60,Recommendation__c = 'test',
                                    ProgramRating__c = 'test',Status__c='Planned',Award__c=awd.Id);
            insert siteVisit;

            siteVisit.ProgramRating__c = 'test 1';
            siteVisit.Status__c = 'Submitted to Grantor';
            update siteVisit;

            Test.startTest();
                SiteVisitTriggerHelper SiteVisitTriggerHelper = new SiteVisitTriggerHelper();
            Test.stopTest();
        }                    
    }                      
}