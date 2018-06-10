/*
* Test class for AmendmentRequestTriggerHelper 
* @author: Sarat Mahavratayajula  2016-07-05   
*/
@isTest
public class TestAmendmentRequestTriggerHelper {
    
    /*@isTest
    public static void testCreateAmendmentBudgetCategories() {

        UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
        GrantTriggerHelper.skipTrigger = true;
        UserTriggerHelper.skipTrigger = true;
        RolesandResponsibilitiesTriggerHelper.skipTrigger=true;
        ServiceArea__c serviceArea = TestHelper.getServiceArea(true);
        Grant__c grant = TestHelper.getGrant(false);
        grant.ProjectPeriodStartDate__c=date.newInstance(2014,05,26);
        grant.ProjectPeriodEndDate__c= date.newInstance(2018,05,26);
        insert grant;
        AwardTriggerHelper.skipTrigger = true;
        Award__c awd = TestHelper.getAwards(grant.Id,true);

        List<BudgetPeriod__c> budgetPeriods = new List<BudgetPeriod__c>();

        /* BudgetPeriod__c budgetPeriod1 = new BudgetPeriod__c(BudgetStartDate__c=date.newInstance(2016,05,26),
                                                            BudgetEndDate__c=date.newInstance(2016,09,02),
                                                            SequenceNumber__c=1.0,
                                                            Grant__c=grant.Id); */
        

        /*BudgetPeriod__c budgetPeriod2 = new BudgetPeriod__c(BudgetStartDate__c=date.newInstance(2016,09,03),
                                                            BudgetEndDate__c=date.newInstance(2017,05,02),
                                                            SequenceNumber__c=2.0,
                                                            Grant__c=grant.Id);

        //budgetPeriods.add(budgetPeriod1);
        budgetPeriods.add(budgetPeriod2);

        insert budgetPeriods;

        awd.BudgetPeriod__c = budgetPeriods[0].Id;
        update awd;

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
        
        List<BudgetCategory__c> budgetCategories = TestHelper.getBudgetCategory(true);
        
        List<AwardBudgetCategory__c> awardBudgetCategories = new List<AwardBudgetCategory__c>();


         AwardBudgetCategory__c aBC1 = new AwardBudgetCategory__c(Award__c=awd.Id,
                                                                 BudgetCategory__c=budgetCategories[0].Id,
                                                                 BudgetPeriod__c=budgetPeriod1.Id,
                                                                 Amount1__c=29000.0);  
        AwardBudgetCategory__c aBC2 = new AwardBudgetCategory__c(Award__c=awd.Id,
                                                                BudgetCategory__c=budgetCategories[1].Id,
                                                                BudgetPeriod__c=budgetPeriod2.Id,
                                                                Amount1__c= 1000.0);
        //awardBudgetCategories.add(aBC1);
        awardBudgetCategories.add(aBC2);

        insert awardBudgetCategories;
        System.runAs(u) {
            Id recordTypeId1 = TestHelper.getRecordType(Schema.Sobjecttype.AmendmentRequest__c,'Formal Amendments');
            AmendmentRequest__c amendmentRequest1 = new AmendmentRequest__c(RecordTypeId = recordTypeId1,
                                                                            Award__c=awd.Id,
                                                                            Purpose__c='Test Purpose',
                                                                            Impact__c='Test Impact');
            //Id recordTypeId2 = TestHelper.getRecordType(Schema.Sobjecttype.AmendmentRequest__c,'Periodic/Annual Renewal');
            //AmendmentRequest__c amendmentRequest2 = new AmendmentRequest__c(RecordTypeId = recordTypeId2,
            //                                                                Award__c=awd.Id,
            //                                                                Purpose__c='Test Purpose',
            //                                                                Impact__c='Test Impact');

            List<AmendmentRequest__c> amendmentRequests = new List<AmendmentRequest__c>();
            amendmentRequests.add(amendmentRequest1);
            //amendmentRequests.add(amendmentRequest2);

            insert amendmentRequests;
            AmendmentRequest__c amendmentRequest2 = new AmendmentRequest__c(RecordTypeId = 'BudgetRevision',
                                                                            Award__c=awd.Id,
                                                                            Purpose__c='Test Purpose',
                                                                            Impact__c='Test Impact');

            List<AmendmentRequest__c> amendmentRequests2 = new List<AmendmentRequest__c>();
            amendmentRequests.add(amendmentRequest2);
            insert amendmentRequests2;
            AmendmentRequest__c amendmentRequest3 = new AmendmentRequest__c(RecordTypeId = 'PeriodicAnnualRenewal',
                                                                            Award__c=awd.Id,
                                                                            Purpose__c='Test Purpose',
                                                                            Impact__c='Test Impact');

            List<AmendmentRequest__c> amendmentRequests3 = new List<AmendmentRequest__c>();
            amendmentRequests.add(amendmentRequest3);
            insert amendmentRequests3;

            AmendmentRequestTriggerHelper amendmentRequestTriggerHelper = new AmendmentRequestTriggerHelper();     
        }      
    }*/

    @isTest
    public static void testCreateAmendmentBudgetCategories1() {
        UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
        Test.startTest();
        system.runAs(u){
        AnnouncementTriggerHelper.skipTrigger = true;
        ApplicationtriggerHelper.skiptrigger = true;
        RolesandResponsibilitiesTriggerHelper.skipTrigger = true;
        GranttriggerHelper.skipTrigger = true;
        RolesandResponsibilitiesTriggerHelper.skipTrigger=true;
        ServiceArea__c serviceArea = TestHelper.getServiceArea(true);
        Grant__c grant = TestHelper.getGrant(false);
        grant.ProjectPeriodStartDate__c=date.newInstance(2014,05,26);
        grant.ProjectPeriodEndDate__c= date.newInstance(2018,05,26);
        grant.IssueDate__c=Date.newInstance(2014,4,14);
        insert grant;
        AwardTriggerHelper.skipTrigger = true;
        Award__c awd = TestHelper.getAwards(grant.Id,true);

        List<BudgetPeriod__c> budgetPeriods = new List<BudgetPeriod__c>();

        BudgetPeriod__c budgetPeriod1 = new BudgetPeriod__c(BudgetStartDate__c=date.newInstance(2016,05,26),
                                                            BudgetEndDate__c=date.newInstance(2016,09,02),
                                                            SequenceNumber__c=1.0,
                                                            Grant__c=grant.Id); 
        

        BudgetPeriod__c budgetPeriod2 = new BudgetPeriod__c(BudgetStartDate__c=date.newInstance(2016,09,03),
                                                            BudgetEndDate__c=date.newInstance(2017,05,02),
                                                            SequenceNumber__c=2.0,
                                                            Grant__c=grant.Id);

        //budgetPeriods.add(budgetPeriod1);
        budgetPeriods.add(budgetPeriod2);

        insert budgetPeriods;

        awd.BudgetPeriod__c = budgetPeriods[0].Id;
        update awd;

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
        
        List<BudgetCategory__c> budgetCategories = TestHelper.getBudgetCategory(true);
        
        List<AwardBudgetCategory__c> awardBudgetCategories = new List<AwardBudgetCategory__c>();


         AwardBudgetCategory__c aBC1 = new AwardBudgetCategory__c(Award__c=awd.Id,
                                                                 BudgetCategory__c=budgetCategories[0].Id,
                                                                 BudgetPeriod__c=budgetPeriod1.Id,
                                                                 Amount1__c=29000.0);  
        AwardBudgetCategory__c aBC2 = new AwardBudgetCategory__c(Award__c=awd.Id,
                                                                BudgetCategory__c=budgetCategories[1].Id,
                                                                BudgetPeriod__c=budgetPeriod2.Id,
                                                                Amount1__c= 1000.0);
        //awardBudgetCategories.add(aBC1);
        awardBudgetCategories.add(aBC2);

        insert awardBudgetCategories;

         Id recordTypeId1 = TestHelper.getRecordType(Schema.Sobjecttype.AmendmentRequest__c,'Formal Amendments');
            AmendmentRequest__c amendmentRequest1 = new AmendmentRequest__c(RecordTypeId = recordTypeId1,
                                                                            Award__c=awd.Id,
                                                                            Purpose__c='Test Purpose',
                                                                            Impact__c='Test Impact');
            /*Id recordTypeId2 = TestHelper.getRecordType(Schema.Sobjecttype.AmendmentRequest__c,'Periodic/Annual Renewal');
            AmendmentRequest__c amendmentRequest2 = new AmendmentRequest__c(RecordTypeId = recordTypeId2,
                                                                            Award__c=awd.Id,
                                                                            Purpose__c='Test Purpose',
                                                                            Impact__c='Test Impact');*/

            List<AmendmentRequest__c> amendmentRequests = new List<AmendmentRequest__c>();
            amendmentRequests.add(amendmentRequest1);
            //amendmentRequests.add(amendmentRequest2);

            insert amendmentRequests;
            /*AmendmentRequest__c amendmentRequest2 = new AmendmentRequest__c(RecordTypeId = 'BudgetRevision',
                                                                            Award__c=awd.Id,
                                                                            Purpose__c='Test Purpose',
                                                                            Impact__c='Test Impact');

            List<AmendmentRequest__c> amendmentRequests2 = new List<AmendmentRequest__c>();
            amendmentRequests.add(amendmentRequest2);
            insert amendmentRequests2;
            AmendmentRequest__c amendmentRequest3 = new AmendmentRequest__c(RecordTypeId = 'PeriodicAnnualRenewal',
                                                                            Award__c=awd.Id,
                                                                            Purpose__c='Test Purpose',
                                                                            Impact__c='Test Impact');

            List<AmendmentRequest__c> amendmentRequests3 = new List<AmendmentRequest__c>();
            amendmentRequests.add(amendmentRequest3);
            insert amendmentRequests3;*/

        }
        Test.stopTest();

    }
     @isTest
    public static void testCreateAmendmentBudgetCategories2() {
        UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
        GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateasGrantee');
        Test.startTest();
        system.runAs(u){
        AnnouncementTriggerHelper.skipTrigger = true;
        ApplicationtriggerHelper.skiptrigger = true;
        RolesandResponsibilitiesTriggerHelper.skipTrigger = true;
        GranttriggerHelper.skipTrigger = true;
        RolesandResponsibilitiesTriggerHelper.skipTrigger=true;
        Announcement__c ann = TestHelper.getAnnouncement(true);
        Application__c app=TestHelper.getApplication(ann.Id,true);
        system.debug('Application Id from test -->' + app.Id);
        ServiceArea__c serviceArea = TestHelper.getServiceArea(true);
        //Grant__c grant = TestHelper.getGrant(false);
        Grant__c grant = new Grant__c();
        grant.ProjectPeriodStartDate__c=date.newInstance(2014,05,26);
        grant.ProjectPeriodEndDate__c= date.newInstance(2018,05,26);
        grant.IssueDate__c=Date.newInstance(2014,4,14);
        grant.Application__c=app.Id;
        insert grant;
         system.debug('Grant Application -->' +grant.Application__c);
        AwardTriggerHelper.skipTrigger = true;
        Award__c awd = TestHelper.getAwards(grant.Id,true);
        Award__c test = [Select Grant__r.Application__c from Award__c where Id = :awd.Id];
        system.debug('$$$' + test.Grant__r.Application__c);
         system.debug('Award Application -->' + awd.Grant__c);
        system.debug('Award Application -->' + awd.Grant__r.Application__c);

        List<BudgetPeriod__c> budgetPeriods = new List<BudgetPeriod__c>();

        BudgetPeriod__c budgetPeriod1 = new BudgetPeriod__c(BudgetStartDate__c=date.newInstance(2016,05,26),
                                                            BudgetEndDate__c=date.newInstance(2016,09,02),
                                                            SequenceNumber__c=1.0,
                                                            Grant__c=grant.Id); 
        

        BudgetPeriod__c budgetPeriod2 = new BudgetPeriod__c(BudgetStartDate__c=date.newInstance(2016,09,03),
                                                            BudgetEndDate__c=date.newInstance(2017,05,02),
                                                            SequenceNumber__c=2.0,
                                                            Grant__c=grant.Id);

        //budgetPeriods.add(budgetPeriod1);
        budgetPeriods.add(budgetPeriod2);

        insert budgetPeriods;

        awd.BudgetPeriod__c = budgetPeriods[0].Id;
        update awd;

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
        
        List<BudgetCategory__c> budgetCategories = TestHelper.getBudgetCategory(true);
        
        List<AwardBudgetCategory__c> awardBudgetCategories = new List<AwardBudgetCategory__c>();


         AwardBudgetCategory__c aBC1 = new AwardBudgetCategory__c(Award__c=awd.Id,
                                                                 BudgetCategory__c=budgetCategories[0].Id,
                                                                 BudgetPeriod__c=budgetPeriod1.Id,
                                                                 Amount1__c=29000.0);  
        AwardBudgetCategory__c aBC2 = new AwardBudgetCategory__c(Award__c=awd.Id,
                                                                BudgetCategory__c=budgetCategories[1].Id,
                                                                BudgetPeriod__c=budgetPeriod2.Id,
                                                                Amount1__c= 1000.0);
        awardBudgetCategories.add(aBC2);
        insert awardBudgetCategories;
        Id recordTypeId2 = TestHelper.getRecordType(Schema.Sobjecttype.AmendmentRequest__c,'Periodic/BP Renewal');
        AmendmentRequest__c amendmentRequest2 = new AmendmentRequest__c(RecordTypeId = recordTypeId2,
                                                                        Award__c=awd.Id,
                                                                        Purpose__c='Test Purpose',
                                                                        Impact__c='Test Impact');
        List<AmendmentRequest__c> amendmentRequests = new List<AmendmentRequest__c>();
        amendmentRequests.add(amendmentRequest2);

        system.debug('Amendment Grant -->' + amendmentRequest2.Award__r.Grant__c);
        system.debug('Amendment Award -->' + amendmentRequest2.Award__c);
        system.debug('Amendment Application -->' + amendmentRequest2.Award__r.Grant__r.Application__c);
        insert amendmentRequests;
        //update amendmentRequests;
        }
        Test.stopTest();

    }

    @isTest
    public static void testCreateAmendmentBudgetCategories3() {
        UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
        Test.startTest();
        system.runAs(u){
        AnnouncementTriggerHelper.skipTrigger = true;
        ApplicationtriggerHelper.skiptrigger = true;
        RolesandResponsibilitiesTriggerHelper.skipTrigger = true;
        GranttriggerHelper.skipTrigger = true;
        RolesandResponsibilitiesTriggerHelper.skipTrigger=true;
        ServiceArea__c serviceArea = TestHelper.getServiceArea(true);
        Grant__c grant = TestHelper.getGrant(false);
        grant.ProjectPeriodStartDate__c=date.newInstance(2014,05,26);
        grant.ProjectPeriodEndDate__c= date.newInstance(2018,05,26);
        grant.IssueDate__c=Date.newInstance(2014,4,14);
        insert grant;
        AwardTriggerHelper.skipTrigger = true;
        Award__c awd = TestHelper.getAwards(grant.Id,true);

        List<BudgetPeriod__c> budgetPeriods = new List<BudgetPeriod__c>();

        BudgetPeriod__c budgetPeriod1 = new BudgetPeriod__c(BudgetStartDate__c=date.newInstance(2016,05,26),
                                                            BudgetEndDate__c=date.newInstance(2016,09,02),
                                                            SequenceNumber__c=1.0,
                                                            Grant__c=grant.Id); 
        

        BudgetPeriod__c budgetPeriod2 = new BudgetPeriod__c(BudgetStartDate__c=date.newInstance(2016,09,03),
                                                            BudgetEndDate__c=date.newInstance(2017,05,02),
                                                            SequenceNumber__c=2.0,
                                                            Grant__c=grant.Id);

        //budgetPeriods.add(budgetPeriod1);
        budgetPeriods.add(budgetPeriod2);

        insert budgetPeriods;

        awd.BudgetPeriod__c = budgetPeriods[0].Id;
        update awd;

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
        
        List<BudgetCategory__c> budgetCategories = TestHelper.getBudgetCategory(true);
        
        List<AwardBudgetCategory__c> awardBudgetCategories = new List<AwardBudgetCategory__c>();


         AwardBudgetCategory__c aBC1 = new AwardBudgetCategory__c(Award__c=awd.Id,
                                                                 BudgetCategory__c=budgetCategories[0].Id,
                                                                 BudgetPeriod__c=budgetPeriod1.Id,
                                                                 Amount1__c=29000.0);  
        AwardBudgetCategory__c aBC2 = new AwardBudgetCategory__c(Award__c=awd.Id,
                                                                BudgetCategory__c=budgetCategories[1].Id,
                                                                BudgetPeriod__c=budgetPeriod2.Id,
                                                                Amount1__c= 1000.0);
        awardBudgetCategories.add(aBC2);
        insert awardBudgetCategories;
        Id recordTypeId3 = TestHelper.getRecordType(Schema.Sobjecttype.AmendmentRequest__c,'Budget Revision');
        AmendmentRequest__c amendmentRequest3 = new AmendmentRequest__c(RecordTypeId = recordTypeId3,
                                                                            Award__c=awd.Id,
                                                                            Purpose__c='Test Purpose',
                                                                            Impact__c='Test Impact');
        List<AmendmentRequest__c> amendmentRequests = new List<AmendmentRequest__c>();
        amendmentRequests.add(amendmentRequest3);
        insert amendmentRequests;
        update amendmentRequests;
        }
        Test.stopTest();

    }
    @isTest
    public static void testCreateAmendmentBudgetCategories4() {
        UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
        GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateasGrantee');
        Test.startTest();
        system.runAs(u){
        AnnouncementTriggerHelper.skipTrigger = true;
        ApplicationtriggerHelper.skiptrigger = true;
        RolesandResponsibilitiesTriggerHelper.skipTrigger = true;
        GranttriggerHelper.skipTrigger = true;
        RolesandResponsibilitiesTriggerHelper.skipTrigger=true;
        ServiceArea__c serviceArea = TestHelper.getServiceArea(true);
        //Grant__c grant = TestHelper.getGrant(false);
        Grant__c grant = new Grant__c();
        grant.ProjectPeriodStartDate__c=date.newInstance(2014,05,26);
        grant.ProjectPeriodEndDate__c= date.newInstance(2018,05,26);
        grant.IssueDate__c=Date.newInstance(2014,4,14);
        insert grant;
        AwardTriggerHelper.skipTrigger = true;
        Award__c awd = TestHelper.getAwards(grant.Id,true);
        Award__c test = [Select Grant__r.Application__c from Award__c where Id = :awd.Id];
        List<BudgetPeriod__c> budgetPeriods = new List<BudgetPeriod__c>();

        BudgetPeriod__c budgetPeriod1 = new BudgetPeriod__c(BudgetStartDate__c=date.newInstance(2016,05,26),
                                                            BudgetEndDate__c=date.newInstance(2016,09,02),
                                                            SequenceNumber__c=1.0,
                                                            Grant__c=grant.Id); 
        

        BudgetPeriod__c budgetPeriod2 = new BudgetPeriod__c(BudgetStartDate__c=date.newInstance(2016,09,03),
                                                            BudgetEndDate__c=date.newInstance(2017,05,02),
                                                            SequenceNumber__c=2.0,
                                                            Grant__c=grant.Id);

        //budgetPeriods.add(budgetPeriod1);
        budgetPeriods.add(budgetPeriod2);

        insert budgetPeriods;

        awd.BudgetPeriod__c = budgetPeriods[0].Id;
        update awd;

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
        
        List<BudgetCategory__c> budgetCategories = TestHelper.getBudgetCategory(true);
        
        List<AwardBudgetCategory__c> awardBudgetCategories = new List<AwardBudgetCategory__c>();


         AwardBudgetCategory__c aBC1 = new AwardBudgetCategory__c(Award__c=awd.Id,
                                                                 BudgetCategory__c=budgetCategories[0].Id,
                                                                 BudgetPeriod__c=budgetPeriod1.Id,
                                                                 Amount1__c=29000.0);  
        AwardBudgetCategory__c aBC2 = new AwardBudgetCategory__c(Award__c=awd.Id,
                                                                BudgetCategory__c=budgetCategories[1].Id,
                                                                BudgetPeriod__c=budgetPeriod2.Id,
                                                                Amount1__c= 1000.0);
        awardBudgetCategories.add(aBC2);
        insert awardBudgetCategories;
        Id recordTypeId2 = TestHelper.getRecordType(Schema.Sobjecttype.AmendmentRequest__c,'Periodic/BP Renewal');
        AmendmentRequest__c amendmentRequest2 = new AmendmentRequest__c(RecordTypeId = recordTypeId2,
                                                                        Award__c=awd.Id,
                                                                        Purpose__c='Test Purpose',
                                                                        Impact__c='Test Impact');
        List<AmendmentRequest__c> amendmentRequests = new List<AmendmentRequest__c>();
        amendmentRequests.add(amendmentRequest2);
        insert amendmentRequests;
        //update amendmentRequests;
        }
        Test.stopTest();

    }

}