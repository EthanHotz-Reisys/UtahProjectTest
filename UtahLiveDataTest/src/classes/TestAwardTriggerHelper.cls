@isTest
private class TestAwardTriggerHelper {
    
    @isTest static void testAwardTriggerHelper1() {
         UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
        //Contact c = TestHelper.getcontact(true);

        system.runAs(u){
            AnnouncementTriggerHelper.skipTrigger = true;
            ApplicationtriggerHelper.skiptrigger = true;
            RolesandResponsibilitiesTriggerHelper.skipTrigger = true;
            GranttriggerHelper.skipTrigger = true;
            
            Announcement__c ann = TestHelper.getAnnouncement(true);
            Application__c app = TestHelper.getApplication(ann.Id,true);
            app.AmountThisAction__c = 10000.00;
            update app;

            
            Grant__c grant = new Grant__c();
            grant.ProjectPeriodStartDate__c=Date.newInstance(2015,3,14);
            grant.ProjectPeriodEndDate__c=Date.newInstance(2020,3,14);
            grant.IssueDate__c=Date.newInstance(2015,2,14);
            grant.Program__c=ann.Program__c;
            grant.GranteePOC__c = u.id;
            insert grant;

            List<BudgetPeriod__c> budgetPeriods = new List<BudgetPeriod__c>();
            
            BudgetPeriod__c budPeriod = new BudgetPeriod__c();
            budPeriod.BudgetStartDate__c = grant.ProjectPeriodStartDate__c+7;
            budPeriod.BudgetEndDate__c = grant.ProjectPeriodEndDate__c-7;
            budPeriod.Grant__c = grant.Id;

            budgetPeriods.add(budPeriod);

            BudgetPeriod__c budPeriod1 = new BudgetPeriod__c();
            budPeriod1.BudgetStartDate__c = grant.ProjectPeriodStartDate__c+7;
            budPeriod1.BudgetEndDate__c = grant.ProjectPeriodEndDate__c-7;
            budPeriod1.Grant__c = grant.Id;
            budgetPeriods.add(budPeriod1);

            insert budgetPeriods;           

            GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c', 'StateasGrantor');

            ServiceArea__c serviceArea = new ServiceArea__c();
            serviceArea.Title__c = 'Test';
            insert serviceArea;

            GrantServiceArea__c grantServiceArea = new GrantServiceArea__c();
            grantServiceArea.ServiceArea__c = serviceArea.Id;
            grantServiceArea.Grant__c = grant.Id;
            insert grantServiceArea;

            List<BudgetCategory__c> budgetCategories = TestHelper.getBudgetCategory(true);

            ApplicationBudgetCategory2__c appBudgetCategory2 = new ApplicationBudgetCategory2__c();
            appBudgetCategory2.Amount__c = 2000.00;
            appBudgetCategory2.Application__c = app.Id;
            appBudgetCategory2.IsFirstBudgetPeriodRelated__c = true;
            appBudgetCategory2.BudgetCategory__c = budgetCategories[0].Id;
            insert appBudgetCategory2;

            ProgressReportsConfig__c progressReportsConfig = new ProgressReportsConfig__c();
            progressReportsConfig.Name = 'Grantor_Reports';
            progressReportsConfig.ReportDueAge__c = 8.0;
            progressReportsConfig.TaskCreationAge__c = 8.0;
            progressReportsConfig.SiteVisitTaskCreationAge__c = 8.0;
            progressReportsConfig.VisitDueAge__c = 8.0;

            insert progressReportsConfig;

          BudgetPeriod__c budPeriod2 = new BudgetPeriod__c();
            budPeriod2.BudgetStartDate__c = System.Today() - 7;
            budPeriod2.BudgetEndDate__c = System.today() + 358;
            insert budPeriod2;

            system.debug('*** End Date' + budPeriod2.BudgetEndDate__c);

            Award__c aw  = new Award__c();
            aw.grant__c = grant.Id;
            aw.Name = Math.Random()+'AW12';
            aw.OrganizationName__c = 'Test Org';
            aw.OrganizationAddress__c = 'Test Address';
            aw.FiscalYear__c = '2013';
            aw.SupportYear__c = Decimal.valueOf('2013');
            aw.Status__c = 'Approved';
            aw.Application__c=app.Id;
            aw.Announcement__c=ann.Id;
            aw.AwardedAmountthisAction__c = 10000.00;
            aw.TotalObligateAmount__c = 100000.00;
            aw.BudgetPeriod__c = budPeriod2.Id;
            insert aw;

            system.debug('***Award ' + aw.Id);

            List<TermCondition__c> termConditions = new List<TermCondition__c>();

            Id recordTypeId1 = TestHelper.getRecordType(Schema.Sobjecttype.TermCondition__c,'Reporting Requirement');
            Id recordTypeId2 = TestHelper.getRecordType(Schema.Sobjecttype.TermCondition__c,'Site Visit');
            Id recordTypeId3 = TestHelper.getRecordType(Schema.Sobjecttype.TermCondition__c,'Payment Request');

            Termcondition__c termCondition1 = new TermCondition__c();
            termCondition1.Award__c = aw.Id;
            termCondition1.CalReportingEndDate__c = System.today() + 7;
            termCondition1.CalReportingStartDate__c = system.today() +1;
            termCondition1.ReportName__c = 'Progress 1';
            termCondition1.Category__c = 'Federal Financial Report';
            termCondition1.Frequency__c = 'Fixed';
            termCondition1.RecordTypeId = recordTypeId1;

            termConditions.add(termCondition1);

            Termcondition__c termCondition2 = new TermCondition__c();
            termCondition2.Award__c = aw.Id;
            termCondition2.CalReportingEndDate__c = System.today() + 7;
            termCondition2.CalReportingStartDate__c = system.today() +1;
            termCondition2.ReportName__c = 'Progress 1';
            termCondition2.Category__c = 'Federal Financial Report';
            termCondition2.Frequency__c = 'Monthly';
            termCondition2.RecordTypeId = recordTypeId1;

            termConditions.add(termCondition2);

            TermCondition__c termCondition3 = new TermCondition__c();
            termCondition3.Award__c = aw.Id;
            termCondition3.VisitEndDateTime__c = System.today() + 7;
            termCondition3.SiteVisitDateTime__c = system.today() +1;
            termCondition3.ReportName__c = 'Site Visit 1';
            termCondition3.Category__c = 'Federal Financial Report';
            termCondition3.Frequency__c = 'Monthly';
            termCondition3.SiteVisitLocation__c = 'Test location';
            termCondition3.RecordTypeId = recordTypeId2;
            termConditions.add(termCondition3);

            TermCondition__c termCondition6 = new TermCondition__c();
            termCondition6.Award__c = aw.Id;
            termCondition6.VisitEndDateTime__c = System.today() + 7;
            termCondition6.SiteVisitDateTime__c = system.today() +1;
            termCondition6.ReportName__c = 'Site Visit 1';
            termCondition6.Category__c = 'Federal Financial Report';
            termCondition6.Frequency__c = 'Fixed';
            termCondition6.SiteVisitLocation__c = 'Test location';
            termCondition6.RecordTypeId = recordTypeId2;
            termConditions.add(termCondition6);


            TermCondition__c termCondition4 = new TermCondition__c();
            termCondition4.Award__c = aw.Id;
            termCondition4.CalReportingEndDate__c = System.today() + 7;
            termCondition6.VisitEndDateTime__c = System.today() + 7;
            termCondition4.CalReportingStartDate__c = system.today() +1;
            termCondition4.ReportName__c = 'Site Visit 1';
            termCondition4.Category__c = 'Federal Financial Report';
            termCondition4.Frequency__c = 'Fixed';
            termCondition4.SiteVisitLocation__c = 'Test location';
            termCondition4.RecordTypeId = recordTypeId3;
            termConditions.add(termCondition4);

            TermCondition__c termCondition5 = new TermCondition__c();
            termCondition5.Award__c = aw.Id;
            termCondition5.CalReportingEndDate__c = System.today() + 7;
            termCondition6.VisitEndDateTime__c = System.today() + 7;
            termCondition5.CalReportingStartDate__c = system.today() +1;
            termCondition5.ReportName__c = 'Site Visit 1';
            termCondition5.Category__c = 'Federal Financial Report';
            termCondition5.Frequency__c = 'Fixed';
            termCondition5.SiteVisitLocation__c = 'Test location';
            termCondition5.RecordTypeId = recordTypeId3;
            termConditions.add(termCondition5);

            insert termConditions;
            aw.Status__c = 'Activated';
            update aw;

            system.debug(aw.Id);

            //delete aw;
        }
    }

    @isTest static void testAwardTriggerHelper2() {
        UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
        //Contact c = TestHelper.getcontact(true);

        system.runAs(u){
            AnnouncementTriggerHelper.skipTrigger = true;
            ApplicationtriggerHelper.skiptrigger = true;
            RolesandResponsibilitiesTriggerHelper.skipTrigger = true;
            GranttriggerHelper.skipTrigger = true;
            
            Announcement__c ann = TestHelper.getAnnouncement(true);
            Application__c app = TestHelper.getApplication(ann.Id,true);
            BudgetPeriod__c budPeriod=null;
            Grant__c grant = new Grant__c();
            grant.ProjectPeriodStartDate__c=Date.newInstance(2015,3,14);
            grant.ProjectPeriodEndDate__c=Date.newInstance(2016,3,14);
            grant.IssueDate__c=Date.newInstance(2015,2,14);
            grant.Program__c=ann.Program__c;
            grant.GranteePOC__c = u.id;
            insert grant;
            GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c', 'StateasGrantee');

            ServiceArea__c serviceArea = new ServiceArea__c();
            serviceArea.Title__c = 'Test';
            insert serviceArea;

            GrantServiceArea__c grantServiceArea = new GrantServiceArea__c();
            grantServiceArea.ServiceArea__c = serviceArea.Id;
            grantServiceArea.Grant__c = grant.Id;
            insert grantServiceArea;

            List<BudgetCategory__c> budgetCategories = TestHelper.getBudgetCategory(true);

            ProgressReportsConfig__c progressReportsConfig = new ProgressReportsConfig__c();
            progressReportsConfig.Name = 'Grantee_Reports';
            progressReportsConfig.ReportDueAge__c = 8.0;
            progressReportsConfig.TaskCreationAge__c = 8.0;

            insert progressReportsConfig;

            list<Award__c> awards = new List<Award__c>();

            Award__c aw  = new Award__c();
            aw.grant__c = grant.Id;
            aw.Name = Math.Random()+'AW12';
            aw.OrganizationName__c = 'Test Org';
            aw.OrganizationAddress__c = 'Test Address';
            aw.FiscalYear__c = '2013';
            aw.SupportYear__c = Decimal.valueOf('2013');
            aw.Status__c = 'Activated';
            aw.Application__c=app.Id;
            aw.Announcement__c=ann.Id;
            aw.AwardedAmountthisAction__c = 10000.00;
            aw.TotalObligateAmount__c = 100000.00;

            awards.add(aw);

            Award__c aw1  = new Award__c();
            aw1.grant__c = grant.Id;
            aw1.Name = Math.Random()+'AW12';
            aw1.OrganizationName__c = 'Test Org';
            aw1.OrganizationAddress__c = 'Test Address';
            aw1.FiscalYear__c = '2013';
            aw1.SupportYear__c = Decimal.valueOf('2013');
            aw1.Status__c = 'Issued';
            aw1.Application__c=app.Id;
            aw1.Announcement__c=ann.Id;
            aw1.AwardedAmountthisAction__c = 10000.00;
            aw1.TotalObligateAmount__c = 100000.00;
            awards.add(aw1);
            
            insert awards;
            system.debug('***Award ' + aw.Id);

            Id recordTypeId1 = TestHelper.getRecordType(Schema.Sobjecttype.TermCondition__c,'Reporting Requirement');
            Termcondition__c termCondition = new TermCondition__c();
            termCondition.Award__c = aw.Id;
            termCondition.CalReportingEndDate__c = Date.newInstance(2016,3,14);
            termCondition.CalReportingStartDate__c = Date.newInstance(2015,3,14);
            termCondition.ReportName__c = 'Progress 1';
            termCondition.Category__c = 'Federal Financial Report';
            termCondition.Frequency__c = 'Fixed';
            termCondition.RecordTypeId = recordTypeId1;

            insert termCondition;

            update aw;
            system.debug(aw.id);

            //delete aw;
        }
    }
      
    @isTest static void testAwardTriggerGrantorWithGrant() {
        // For deletion testing to work!!!
        UserTriggerHelper.skipTrigger = true; 
        User u = TestHelper.getAdminUser(true);
        //Contact c = TestHelper.getcontact(true);
        Test.startTest();
        system.runAs(u){
            AnnouncementTriggerHelper.skipTrigger = true;
            ApplicationtriggerHelper.skiptrigger = true;
            RolesandResponsibilitiesTriggerHelper.skipTrigger = true;
            GranttriggerHelper.skipTrigger = true;
            
            Announcement__c ann = TestHelper.getAnnouncement(true);
            Application__c app = TestHelper.getApplication(ann.Id,true);
            BudgetPeriod__c budPeriod=null;
            Grant__c grant = new Grant__c();
            grant.ProjectPeriodStartDate__c=Date.newInstance(2015,3,14);
            grant.ProjectPeriodEndDate__c=Date.newInstance(2016,3,14);
            grant.IssueDate__c=Date.newInstance(2015,2,14);
            grant.Program__c=ann.Program__c;
            grant.GranteePOC__c = u.id;
            insert grant;
            GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c', 'StateasGrantor');

            ServiceArea__c serviceArea = new ServiceArea__c();
            serviceArea.Title__c = 'Test';
            insert serviceArea;

            GrantServiceArea__c grantServiceArea = new GrantServiceArea__c();
            grantServiceArea.ServiceArea__c = serviceArea.Id;
            grantServiceArea.Grant__c = grant.Id;
            insert grantServiceArea;

            List<BudgetCategory__c> budgetCategories = TestHelper.getBudgetCategory(true);

            ProgressReportsConfig__c progressReportsConfig = new ProgressReportsConfig__c();
            progressReportsConfig.Name = 'Grantor_Reports';
            progressReportsConfig.ReportDueAge__c = 8.0;
            progressReportsConfig.TaskCreationAge__c = 8.0;

            insert progressReportsConfig;

            Award__c aw  = new Award__c();
            aw.Grant__c = grant.Id;
            aw.Name = Math.Random()+'AW12';
            aw.OrganizationName__c = 'Test Org';
            aw.OrganizationAddress__c = 'Test Address';
            aw.FiscalYear__c = '2013';
            aw.SupportYear__c = Decimal.valueOf('2013');
            aw.Status__c = 'Activated';
            aw.Application__c=app.Id;
            aw.Announcement__c=ann.Id;
            aw.AwardedAmountthisAction__c = 10000.00;
            aw.TotalObligateAmount__c = 100000.00;
            aw.DeepCloned__c = true;
            insert aw;
            system.debug('***Award ' + aw.Id);
            delete aw;
        }
        Test.stopTest();
    }

    //@isTest static void testAwardTriggerHelperGrantorWithoutGrant() {
    //    // For deletion testing to work!!!
    //    UserTriggerHelper.skipTrigger = true; 
    //    User u = TestHelper.getAdminUser(true);
    //    //Contact c = TestHelper.getcontact(true);
    //    Test.startTest();
    //    system.runAs(u){
    //        AnnouncementTriggerHelper.skipTrigger = true;
    //        ApplicationtriggerHelper.skiptrigger = true;
    //        ServiceAreaTriggerHelper.skiptrigger = true;
    //        RolesandResponsibilitiesTriggerHelper.skipTrigger = true;
    //        GranttriggerHelper.skipTrigger = true;
    //        Announcement__c ann = TestHelper.getAnnouncement(true);
    //        Application__c app = TestHelper.getApplication(ann.Id,true);
    //        //shivankar: Code to increase test coverage; creation of test data which was not there earlier. 
    //        ServiceArea__c sva=TestHelper.getServiceArea(true);
    //        ApplicationServiceArea__c asva=new ApplicationServiceArea__c();
    //        asva.ServiceAreaLookup__c=sva.Id;
    //        asva.Application__c=app.Id;
    //        Insert asva;
    //        List<BudgetCategory__c> budgetcategorycList=TestHelper.getBudgetCategory(false);
    //        BudgetCategory__c bc=budgetcategorycList.get(0);
    //        bc.name='Indirect Costs';
    //        insert bc;
    //        //Insert bc;

    //        ApplicationBudgetCategory2__c abc2=new ApplicationBudgetCategory2__c(Amount__c=123456.0,BudgetAmountUSBE__c=45678.0, BudgetCategory__c=bc.Id,  AdminCostValue__c=111111.0);
    //        abc2.ServiceArea__c=asva.Id;
    //        abc2.Application__c=app.Id;
    //        insert abc2;
    //        system.debug('app id ->>>' + abc2.Application__c);
    //        ApplicationBudgetCategory2__c abc3 = [SELECT Id,BudgetCategory__c,BudgetCategory__r.CategoryName__c FROM ApplicationBudgetCategory2__c WHERE Amount__c = 123456.0 LIMIT 1];
    //        system.debug('category name ->>>' + abc3.BudgetCategory__r.CategoryName__c);

    //        //shivankar
    //        BudgetPeriod__c budPeriod=null;
    //        Grant__c grant = new Grant__c();
    //        grant.ProjectPeriodStartDate__c=Date.newInstance(2015,3,14);
    //        grant.ProjectPeriodEndDate__c=Date.newInstance(2016,3,14);
    //        grant.IssueDate__c=Date.newInstance(2015,2,14);
    //        grant.Program__c=ann.Program__c;
    //        grant.GranteePOC__c = u.id;
    //        insert grant;
    //        GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c', 'StateasGrantor');

    //        ServiceArea__c serviceArea = new ServiceArea__c();
    //        serviceArea.Title__c = 'Test';
    //        insert serviceArea;

    //        GrantServiceArea__c grantServiceArea = new GrantServiceArea__c();
    //        grantServiceArea.ServiceArea__c = serviceArea.Id;
    //        grantServiceArea.Grant__c = grant.Id;
    //        insert grantServiceArea;

    //        List<BudgetCategory__c> budgetCategories = TestHelper.getBudgetCategory(true);

    //        ProgressReportsConfig__c progressReportsConfig = new ProgressReportsConfig__c();
    //        progressReportsConfig.Name = 'Grantor_Reports';
    //        progressReportsConfig.ReportDueAge__c = 8.0;
    //        progressReportsConfig.TaskCreationAge__c = 8.0;

    //        insert progressReportsConfig;

    //        Award__c aw  = new Award__c();
    //        aw.Grant__c = grant.Id;
    //        aw.Name = Math.Random()+'AW12';
    //        aw.OrganizationName__c = 'Test Org';
    //        aw.OrganizationAddress__c = 'Test Address';
    //        aw.FiscalYear__c = '2013';
    //        aw.SupportYear__c = Decimal.valueOf('2013');
    //        aw.Status__c = 'Activated';
    //        aw.Application__c=app.Id;
    //        aw.Announcement__c=ann.Id;
    //        aw.AwardedAmountthisAction__c = 10000.00;
    //        aw.TotalObligateAmount__c = 100000.00;
    //        aw.DeepCloned__c = true;
    //        insert aw;
    //        system.debug('***Award ' + aw.Id);
    //        delete aw;
    //    }
    //    Test.stopTest();
    //}

      @isTest static void testAwardTriggerGranteeWithoutApplicationNCons() {
        // For deletion testing to work!!!
        UserTriggerHelper.skipTrigger = true; 
        User u = TestHelper.getAdminUser(true);
        //Contact c = TestHelper.getcontact(true);
        Test.startTest();
        system.runAs(u){
            AnnouncementTriggerHelper.skipTrigger = true;
            ApplicationtriggerHelper.skiptrigger = true;
            RolesandResponsibilitiesTriggerHelper.skipTrigger = true;
            GranttriggerHelper.skipTrigger = true;
            Announcement__c ann = TestHelper.getAnnouncement(true);
            Application__c app = TestHelper.getApplication(ann.Id,true);
            ann.ConstructionPackageIncluded__c = true;
            BudgetPeriod__c budPeriod= new BudgetPeriod__c();
            insert budPeriod;
            Grant__c grant = new Grant__c();
            grant.ProjectPeriodStartDate__c=Date.newInstance(2015,3,14);
            grant.ProjectPeriodEndDate__c=Date.newInstance(2016,3,14);
            grant.IssueDate__c=Date.newInstance(2015,2,14);
            grant.Program__c=ann.Program__c;
            grant.GranteePOC__c = u.id;
            grant.TypeOfBudgetCategories__c = 'Construction & Non Construction';
            insert grant;
            GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c', 'StateasGrantee');

            ServiceArea__c serviceArea = new ServiceArea__c();
            serviceArea.Title__c = 'Test';
            insert serviceArea;

            GrantServiceArea__c grantServiceArea = new GrantServiceArea__c();
            grantServiceArea.ServiceArea__c = serviceArea.Id;
            grantServiceArea.Grant__c = grant.Id;
            insert grantServiceArea;

            List<BudgetCategory__c> budgetCategories = TestHelper.getBudgetCategory(true);

            ProgressReportsConfig__c progressReportsConfig = new ProgressReportsConfig__c();
            progressReportsConfig.Name = 'Grantee_Reports';
            progressReportsConfig.ReportDueAge__c = 8.0;
            progressReportsConfig.TaskCreationAge__c = 8.0;

            insert progressReportsConfig;

            Award__c aw  = new Award__c();
            aw.Grant__c = grant.Id;
            aw.Name = Math.Random()+'AW12';
            aw.OrganizationName__c = 'Test Org';
            aw.OrganizationAddress__c = 'Test Address';
            aw.FiscalYear__c = '2013';
            aw.SupportYear__c = Decimal.valueOf('2013');
            aw.Status__c = 'Activated';
            aw.Application__c=app.Id;
            aw.Announcement__c=ann.Id;
            aw.AwardedAmountthisAction__c = 10000.00;
            aw.TotalObligateAmount__c = 100000.00;
            aw.DeepCloned__c = false;
            aw.BudgetPeriod__c = budPeriod.Id;
            insert aw;
            update aw;
            system.debug('***Award ' + aw.Id);
            //delete aw;
        }
        Test.stopTest();
    }

   

    @isTest static void testAwardTriggerGranteeWithApplicationCon() {
        // For deletion testing to work!!!
        UserTriggerHelper.skipTrigger = true; 
        User u = TestHelper.getAdminUser(true);
        //Contact c = TestHelper.getcontact(true);
        Test.startTest();
        system.runAs(u){
            AnnouncementTriggerHelper.skipTrigger = true;
            ApplicationtriggerHelper.skiptrigger = true;
            RolesandResponsibilitiesTriggerHelper.skipTrigger = true;
            GranttriggerHelper.skipTrigger = true;

            Announcement__c ann = TestHelper.getAnnouncement(true);
            Application__c app = TestHelper.getApplication(ann.Id,true);
            BudgetPeriod__c budPeriod=null;
            Grant__c grant = new Grant__c();
            grant.ProjectPeriodStartDate__c=Date.newInstance(2015,3,14);
            grant.ProjectPeriodEndDate__c=Date.newInstance(2016,3,14);
            grant.IssueDate__c=Date.newInstance(2015,2,14);
            grant.Program__c=ann.Program__c;
            grant.GranteePOC__c = u.id;
            grant.TypeOfBudgetCategories__c = 'Construction';
            insert grant;
            GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c', 'StateasGrantee');

            ServiceArea__c serviceArea = new ServiceArea__c();
            serviceArea.Title__c = 'Test';
            insert serviceArea;

            GrantServiceArea__c grantServiceArea = new GrantServiceArea__c();
            grantServiceArea.ServiceArea__c = serviceArea.Id;
            grantServiceArea.Grant__c = grant.Id;
            insert grantServiceArea;

            List<BudgetCategory__c> budgetCategories = TestHelper.getBudgetCategory(true);

            ProgressReportsConfig__c progressReportsConfig = new ProgressReportsConfig__c();
            progressReportsConfig.Name = 'Grantee_Reports';
            progressReportsConfig.ReportDueAge__c = 8.0;
            progressReportsConfig.TaskCreationAge__c = 8.0;

            insert progressReportsConfig;

            Award__c aw  = new Award__c();
            aw.Grant__c = grant.Id;
            aw.Name = Math.Random()+'AW12';
            aw.OrganizationName__c = 'Test Org';
            aw.OrganizationAddress__c = 'Test Address';
            aw.FiscalYear__c = '2013';
            aw.SupportYear__c = Decimal.valueOf('2013');
            aw.Status__c = 'Activated';
            aw.Application__c=app.Id;
            aw.Announcement__c=ann.Id;
            aw.AwardedAmountthisAction__c = 10000.00;
            aw.TotalObligateAmount__c = 100000.00;
            aw.DeepCloned__c = false;
            AwardTriggerHelper ath = new AwardTriggerHelper();
            insert aw;
            update aw;
            system.debug('***Award ' + aw.Id);
            //delete aw;
        }
        Test.stopTest();
    }

      @isTest static void testAwardTriggerHelper4() {
        // For deletion testing to work!!!
        UserTriggerHelper.skipTrigger = true; 
        User u = TestHelper.getAdminUser(true);
        //Contact c = TestHelper.getcontact(true);
            Test.startTest();
            system.runAs(u){
                  AnnouncementTriggerHelper.skipTrigger = true;
                  ApplicationtriggerHelper.skiptrigger = true;
                  RolesandResponsibilitiesTriggerHelper.skipTrigger = true;
                  GranttriggerHelper.skipTrigger = true;
                  FundingSourceTriggerhelper.skiptrigger = true;
                  AwardTriggerHelper.skipTrigger = true;
                  Announcement__c ann = TestHelper.getAnnouncement(true);
                  Application__c app = TestHelper.getApplication(ann.Id,true);
                  BudgetPeriod__c budPeriod=null;
                  Grant__c grant = new Grant__c();
                  grant.ProjectPeriodStartDate__c=Date.newInstance(2015,3,14);
                  grant.ProjectPeriodEndDate__c=Date.newInstance(2016,3,14);
                  grant.IssueDate__c=Date.newInstance(2015,2,14);
                  grant.Program__c=ann.Program__c;
                  grant.GranteePOC__c = u.id;
                  insert grant;

                  Grant__c fedgrant1 = new Grant__c();
                  fedgrant1.ProjectPeriodStartDate__c=Date.newInstance(2015,3,14);
                  fedgrant1.ProjectPeriodEndDate__c=Date.newInstance(2016,3,14);
                  fedgrant1.IssueDate__c=Date.newInstance(2015,2,14);
                  fedgrant1.Program__c=ann.Program__c;
                  fedgrant1.GranteePOC__c = u.id;
                  insert fedgrant1;



                  Id recordTypeId7 = TestHelper.getRecordType(Schema.Sobjecttype.FundingSource__c,'Internal');

                  FundingSource__c fundSource1 = new FundingSource__c();
                  fundSource1.Name = 'Test Funding Source 1';
                  fundSource1.Grant__c = fedgrant1.Id;
                  fundSource1.RecordTypeId = recordTypeId7;
                  insert fundSource1;



                  FundingAccount__c fundAccount1 = new FundingAccount__c();
                  fundAccount1.Name = 'Test Funding Account 1';
                  fundAccount1.FundingSource__c = fundSource1.Id;
                  insert fundAccount1;



                  Award__c aw  = new Award__c();
                  aw.Grant__c = grant.Id;
                  aw.Name = Math.Random()+'AW12';
                  aw.OrganizationName__c = 'Test Org';
                  aw.OrganizationAddress__c = 'Test Address';
                  aw.FiscalYear__c = '2013';
                  aw.SupportYear__c = Decimal.valueOf('2013');
                  aw.Status__c = 'Approved';
                  aw.Application__c=app.Id;
                  aw.Announcement__c=ann.Id;
                  aw.AwardedAmountthisAction__c = 10000.00;
                  aw.TotalObligateAmount__c = 100000.00;
                aw.DeepCloned__c = false;
                  insert aw;
                  aw.Status__c = 'Activated';
                  update aw;
                  system.debug('***Award ' + aw.Id);

                  AwardFundingAccount__c awardFundingAccount1 = new AwardFundingAccount__c();
                  awardFundingAccount1.Award__c = aw.Id;
                  awardFundingAccount1.FundingAccount__c = fundAccount1.Id;
                  insert awardFundingAccount1;

                 // AwardFundingAccount__c awardFundingAccount2 = new AwardFundingAccount__c();
                  //awardFundingAccount2.Award__c = aw.Id;
                 // awardFundingAccount2.FundingAccount__c = fundAccount2.Id;
                  //insert awardFundingAccount2;

                  /*List<Award__c> awards = new List<Award__c>();
                  awards.add(aw);
                  insert awards;*/
                  
            }

            Test.stopTest();
      }

       @isTest static void testmethod5() {
        
        UserTriggerHelper.skipTrigger = true; 
        User u = TestHelper.getAdminUser(true);
        //Contact c = TestHelper.getcontact(true);
        Test.startTest();
        system.runAs(u){
            GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c', 'StateasGrantor');

            AnnouncementTriggerHelper.skipTrigger = true;
            ApplicationtriggerHelper.skipTrigger = true;
            RolesandResponsibilitiesTriggerHelper.skipTrigger = true;
            GranttriggerHelper.skipTrigger = true;

            Announcement__c ann = TestHelper.getAnnouncement(true);
            Application__c app = TestHelper.getApplication(ann.Id,true);
            
            BudgetPeriod__c budPeriod=null;
            Grant__c grant = new Grant__c();
            grant.ProjectPeriodStartDate__c=Date.newInstance(2015,3,14);
            grant.ProjectPeriodEndDate__c=Date.newInstance(2016,3,14);
            grant.IssueDate__c=Date.newInstance(2015,2,14);
            grant.Program__c=ann.Program__c;
            grant.GranteePOC__c = u.id;
            grant.TypeOfBudgetCategories__c = 'Construction';
            insert grant;
            
            //ServiceArea__c serviceArea = new ServiceArea__c();
            //serviceArea.Title__c = 'Test';
            //insert serviceArea;

            //GrantServiceArea__c grantServiceArea = new GrantServiceArea__c();
            //grantServiceArea.ServiceArea__c = serviceArea.Id;
            //grantServiceArea.Grant__c = grant.Id;
            //insert grantServiceArea;

            //List<BudgetCategory__c> budgetCategories = TestHelper.getBudgetCategory(true);

            //ProgressReportsConfig__c progressReportsConfig = new ProgressReportsConfig__c();
            //progressReportsConfig.Name = 'Grantee_Reports';
            //progressReportsConfig.ReportDueAge__c = 8.0;
            //progressReportsConfig.TaskCreationAge__c = 8.0;

            //insert progressReportsConfig;
            


            //update gobj;

            Award__c aw  = new Award__c();
            aw.Grant__c = grant.Id;
            aw.Name = Math.Random()+'AW12';
            aw.OrganizationName__c = 'Test Org';
            aw.OrganizationAddress__c = 'Test Address';
            aw.FiscalYear__c = '2013';
            aw.SupportYear__c = Decimal.valueOf('2013');
            aw.Status__c = 'Activated';
            aw.Application__c=app.Id;
            aw.Announcement__c=ann.Id;
            aw.AwardedAmountthisAction__c = 10000.00;
            aw.TotalObligateAmount__c = 100000.00;
            aw.DeepCloned__c = false;
            List<Award__c> awl=new List<Award__c>();
            awl.add(aw);
            insert awl;
            GoalObjective__c gobj=new GoalObjective__c();
            gobj.Application__c=app.Id;
            gobj.Award__c=aw.Id;
            gobj.IsParent__c=true;
            Insert gobj;
            GoalObjective__c gobj1=new GoalObjective__c();
            gobj1.Application__c=app.Id;
            gobj1.Award__c=aw.Id;
             gobj1.IsParent__c=true;
            Insert gobj1;

            update awl;

            
            
           
            system.debug('***Award ' + aw.Id);
            //delete aw;
            //AnnouncementTriggerHelper.skipTrigger = true;
            //ApplicationtriggerHelper.skiptrigger = true;
            //RolesandResponsibilitiesTriggerHelper.skipTrigger = true;
            //GranttriggerHelper.skipTrigger = true;
            //Grant__c g=TestHelper.getGrant(true);
            //List<Award__c> aw=new List<Award__c>();
            //aw.add(TestHelper.getAwards(g.Id,true));
            //AwardTriggerHelper awh=new AwardTriggerHelper();
            //awh.createAwardBudgetCategories(aw);

        }
        Test.stopTest();
    }

       @isTest static void testAwardTriggerHelperSarat() {
        // For deletion testing to work!!!
        UserTriggerHelper.skipTrigger = true; 
        User u = TestHelper.getAdminUser(true);
        Account acct=null;
        //Contact c = TestHelper.getcontact(true);
            system.runAs(u){
                  AnnouncementTriggerHelper.skipTrigger = true;
                  ApplicationtriggerHelper.skiptrigger = true;
                  RolesandResponsibilitiesTriggerHelper.skipTrigger = true;
                  GranttriggerHelper.skipTrigger = true;
                  FundingSourceTriggerhelper.skiptrigger = true;
                  AwardTriggerHelper.skipTrigger = true;                  
                  Announcement__c ann = TestHelper.getAnnouncement(true);
                  Application__c app = TestHelper.getApplication(ann.Id,true);
                  Application__c app1 = TestHelper.getApplication(ann.Id,true);
                  Application__c app2 = TestHelper.getApplication(ann.Id,true);

                  Id budCatRecType = TestHelper.getRecordType(Schema.Sobjecttype.BudgetCategory__c,'Internal');                  

                  BudgetCategory__c budCategory1 = new BudgetCategory__c();
                  budCategory1.RecordTypeId = budCatRecType;
                  budCategory1.Name = 'Budcat1 - Category1';
                  budCategory1.CategoryDescription__c = 'Budcat1 - Category1';
                  budCategory1.RowNumber__c = '302';

                  insert budCategory1;

                  ApplicationBudgetCategory2__c appBudgetCategory1 = new ApplicationBudgetCategory2__c();
                  appBudgetCategory1.Application__c = app.Id;
                  appBudgetCategory1.BudgetCategory__c = budCategory1.Id;

                  insert appBudgetCategory1;

                  List<BuildUpItem__c> appBuildUpItems1 = new List<BuildUpItem__c>();

                  BuildUpItem__c buildUpItem1 = new BuildUpItem__c();
                  buildUpItem1.Title__c = 'AppBudcat1 - lineitem1';
                  buildUpItem1.Quantity__c = 10.0;
                  buildUpItem1.UnitPrice__c = 20.0;
                  buildUpItem1.ApplicationBudgetCategory__c = appBudgetCategory1.Id;

                  appBuildUpItems1.add(buildUpItem1);

                  BuildUpItem__c buildUpItem2 = new BuildUpItem__c();
                  buildUpItem2.Title__c = 'AppBudcat1 - lineitem2';
                  buildUpItem2.Quantity__c = 11.0;
                  buildUpItem2.UnitPrice__c = 20.0;
                  buildUpItem2.ApplicationBudgetCategory__c = appBudgetCategory1.Id;

                  appBuildUpItems1.add(buildUpItem2);

                  BuildUpItem__c buildUpItem3 = new BuildUpItem__c();
                  buildUpItem3.Title__c = 'AppBudcat1 - lineitem3';
                  buildUpItem3.Quantity__c = 12.0;
                  buildUpItem3.UnitPrice__c = 20.0;
                  buildUpItem3.ApplicationBudgetCategory__c = appBudgetCategory1.Id;

                  appBuildUpItems1.add(buildUpItem3);

                  insert appBuildUpItems1;


                //Shivankar: Put this here as the SOQL query limit was being hit and the method was failing. 
                Test.startTest();
           
                  BudgetCategory__c budCategory2 = new BudgetCategory__c();
                  budCategory2.RecordTypeId = budCatRecType;
                  budCategory2.Name = 'Application1 - Category2';
                  budCategory2.CategoryDescription__c = 'Application1 - Category2';
                  budCategory2.RowNumber__c = '302';

                  insert budCategory2;

                  ApplicationBudgetCategory2__c appBudgetCategory2 = new ApplicationBudgetCategory2__c();
                  appBudgetCategory2.Application__c = app.Id;
                  appBudgetCategory2.BudgetCategory__c = budCategory1.Id;

                  insert appBudgetCategory2;

                  List<BuildUpItem__c> appBuildUpItems2 = new List<BuildUpItem__c>();

                  BuildUpItem__c buildUpItem4 = new BuildUpItem__c();
                  buildUpItem4.Title__c = 'AppBudcat1 - lineitem1';
                  buildUpItem4.Quantity__c = 10.0;
                  buildUpItem4.UnitPrice__c = 20.0;
                  buildUpItem4.ApplicationBudgetCategory__c = appBudgetCategory2.Id;

                  appBuildUpItems2.add(buildUpItem4);

                  BuildUpItem__c buildUpItem5 = new BuildUpItem__c();
                  buildUpItem5.Title__c = 'AppBudcat1 - lineitem2';
                  buildUpItem5.Quantity__c = 11.0;
                  buildUpItem5.UnitPrice__c = 20.0;
                  buildUpItem5.ApplicationBudgetCategory__c = appBudgetCategory2.Id;

                  appBuildUpItems2.add(buildUpItem5);

                  BuildUpItem__c buildUpItem6 = new BuildUpItem__c();
                  buildUpItem6.Title__c = 'AppBudcat1 - lineitem3';
                  buildUpItem6.Quantity__c = 12.0;
                  buildUpItem6.UnitPrice__c = 20.0;
                  buildUpItem6.ApplicationBudgetCategory__c = appBudgetCategory2.Id;

                  appBuildUpItems2.add(buildUpItem6);

                  insert appBuildUpItems2;                 

                  Grant__c grant = new Grant__c();
                  grant.ProjectPeriodStartDate__c=Date.newInstance(2017,4,14);
                  grant.ProjectPeriodEndDate__c=Date.newInstance(2018,5,13);
                  grant.IssueDate__c=Date.newInstance(2017,3,14);
                  grant.Program__c=ann.Program__c;
                  grant.GranteePOC__c = u.id;
                  grant.Application__c = app.Id;
                  insert grant;

                  Award__c aw  = new Award__c();
                  aw.Grant__c = grant.Id;
                  aw.Name = Math.Random()+'AW12';
                  aw.OrganizationName__c = 'Test Org';
                  aw.OrganizationAddress__c = 'Test Address';
                  aw.FiscalYear__c = '2013';
                  aw.SupportYear__c = Decimal.valueOf('2013');
                  aw.Status__c = 'Created';
                  //aw.Application__c=app.Id;
                  aw.Announcement__c=ann.Id;
                  aw.AwardedAmountthisAction__c = 10000.00;
                  aw.TotalObligateAmount__c = 100000.00;
                  aw.DeepCloned__c = false;
                  insert aw;
                  /*aw.Status__c = 'Activated';
                  update aw;*/
                  system.debug('***Award ' + aw.Id);
                  //-------------- Award2 -------------------------

                  BudgetCategory__c budCategory3 = new BudgetCategory__c();
                  budCategory3.RecordTypeId = budCatRecType;
                  budCategory3.Name = 'Application2 - Budcat1 - Category1';
                  budCategory3.CategoryDescription__c = 'App2 - Budcat1 - Category1';
                  budCategory3.RowNumber__c = '302';

                  insert budCategory3;

                  ApplicationBudgetCategory2__c appBudgetCategory3 = new ApplicationBudgetCategory2__c();
                  appBudgetCategory3.Application__c = app1.Id;
                  appBudgetCategory3.BudgetCategory__c = budCategory3.Id;

                  insert appBudgetCategory3;

                  List<BuildUpItem__c> appBuildUpItems3 = new List<BuildUpItem__c>();

                  BuildUpItem__c buildUpItem7 = new BuildUpItem__c();
                  buildUpItem7.Title__c = 'App2 Budcat1 - lineitem1';
                  buildUpItem7.Quantity__c = 10.0;
                  buildUpItem7.UnitPrice__c = 20.0;
                  buildUpItem7.ApplicationBudgetCategory__c = appBudgetCategory3.Id;

                  appBuildUpItems3.add(buildUpItem7);

                  BuildUpItem__c buildUpItem8 = new BuildUpItem__c();
                  buildUpItem8.Title__c = 'App2 Budcat1 - lineitem2';
                  buildUpItem8.Quantity__c = 11.0;
                  buildUpItem8.UnitPrice__c = 20.0;
                  buildUpItem8.ApplicationBudgetCategory__c = appBudgetCategory3.Id;

                  appBuildUpItems3.add(buildUpItem8);

                  BuildUpItem__c buildUpItem9 = new BuildUpItem__c();
                  buildUpItem9.Title__c = 'App2 Budcat1 - lineitem3';
                  buildUpItem9.Quantity__c = 12.0;
                  buildUpItem9.UnitPrice__c = 20.0;
                  buildUpItem9.ApplicationBudgetCategory__c = appBudgetCategory3.Id;

                  appBuildUpItems3.add(buildUpItem9);

                  insert appBuildUpItems3;

                  BudgetCategory__c budCategory4 = new BudgetCategory__c();
                  budCategory4.RecordTypeId = budCatRecType;
                  budCategory4.Name = 'Application2 - Category2';
                  budCategory4.CategoryDescription__c = 'Application1 - Category2';
                  budCategory4.RowNumber__c = '302';

                  insert budCategory4;

                  ApplicationBudgetCategory2__c appBudgetCategory4 = new ApplicationBudgetCategory2__c();
                  appBudgetCategory4.Application__c = app1.Id;
                  appBudgetCategory4.BudgetCategory__c = budCategory4.Id;

                  insert appBudgetCategory4;

                  List<BuildUpItem__c> appBuildUpItems4 = new List<BuildUpItem__c>();

                  BuildUpItem__c buildUpItem10 = new BuildUpItem__c();
                  buildUpItem10.Title__c = 'Application2 - lineitem1';
                  buildUpItem10.Quantity__c = 10.0;
                  buildUpItem10.UnitPrice__c = 20.0;
                  buildUpItem10.ApplicationBudgetCategory__c = appBudgetCategory4.Id;

                  appBuildUpItems4.add(buildUpItem10);

                  BuildUpItem__c buildUpItem11 = new BuildUpItem__c();
                  buildUpItem11.Title__c = 'Application2 - lineitem2';
                  buildUpItem11.Quantity__c = 11.0;
                  buildUpItem11.UnitPrice__c = 20.0;
                  buildUpItem11.ApplicationBudgetCategory__c = appBudgetCategory4.Id;

                  appBuildUpItems4.add(buildUpItem11);

                  BuildUpItem__c buildUpItem12 = new BuildUpItem__c();
                  buildUpItem12.Title__c = 'Application2 - lineitem3';
                  buildUpItem12.Quantity__c = 12.0;
                  buildUpItem12.UnitPrice__c = 20.0;
                  buildUpItem12.ApplicationBudgetCategory__c = appBudgetCategory4.Id;

                  appBuildUpItems4.add(buildUpItem12);

                  insert appBuildUpItems4;                 

                  Grant__c grant1 = new Grant__c();
                  grant1.ProjectPeriodStartDate__c=Date.newInstance(2017,4,14);
                  grant1.ProjectPeriodEndDate__c=Date.newInstance(2018,5,13);
                  grant1.IssueDate__c=Date.newInstance(2015,2,14);
                  grant1.Program__c=ann.Program__c;
                  grant1.GranteePOC__c = u.id;
                  grant1.Application__c = app1.Id;
                  insert grant1;

                  Grant__c grant2 = new Grant__c();
                  grant2.ProjectPeriodStartDate__c=Date.newInstance(2017,4,14);
                  grant2.ProjectPeriodEndDate__c=Date.newInstance(2018,5,13);
                  grant2.IssueDate__c=Date.newInstance(2015,2,14);
                  grant2.Program__c=ann.Program__c;
                  grant2.GranteePOC__c = u.id;
                  grant2.Application__c = app2.Id;
                  insert grant2;

                  acct=TestHelper.getAccount(true);
                  Program__c newProgram=TestHelper.getProgram(acct.id,true);

                  Award__c aw1  = new Award__c();
                  aw1.Grant__c = grant1.Id;
                  aw1.Name = Math.Random()+'AW12';
                  aw1.OrganizationName__c = 'Test Org';
                  aw1.OrganizationAddress__c = 'Test Address';
                  aw1.FiscalYear__c = '2013';
                  aw1.SupportYear__c = Decimal.valueOf('2013');
                  aw1.Status__c = 'Created';
                  //aw.Application__c=app.Id;
                  aw1.AwardedAmountthisAction__c = 20000.00;
                    aw.Announcement__c=ann.Id;
                  aw1.TotalObligateAmount__c = 200000.00;
                  aw1.DeepCloned__c = false;
                  insert aw1;
                  /*aw.Status__c = 'Activated';
                  update aw;*/
                  system.debug('***Award ' + aw.Id);
                  //-------------- Award2 -------------------------
/*
                  List<Award__c> awards = new List<Award__c>();

                  awards.add(aw);
                  awards.add(aw1);

                  insert awards;*/

                  Grant__c newGrant=TestHelper.getGrant(true);
                  Award__c newAward=TestHelper.getAwards(newGrant.Id,false);
                  List<Award__c> awardList=new List<Award__c>();
                  awardList.add(newAward);
                  insert awardList;
                  delete awardList;

                  Test.stopTest();
                  
            }

            
      }

    static testMethod void testAwdHelp() {  
        UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
        
        Account acct = null;
        RolesAndResponsibilities__c rolesAndResp1 = null;
        Program__c pgm = null;
        Announcement__c ann= null;
        Application__c app = null;
        ProgressReports__c progRep = null;
        Grant__c grants = null;
        Award__c awards = null;
        Grant__c grants1 = null;
        Award__c awards1 = null;
        TermCondition__c termCond=null;
        PreApplication__c preApp = null;
        SiteVisit__c siteVisit = null;
        RiskAssessment__c riskAsses = null;
        Closeout__c closeOut = null;  
        StrategicPlan__c stratPlan = null;
           
        System.runAs(u){
            AccountTriggerHelper.skipTrigger = true;
            AccountTriggerHelper.skipAll = true;
            ProgramTriggerHelper.skipTrigger = true;
            AnnouncementTriggerHelper.skipTrigger = true;
            ApplicationTriggerHelper.skipTrigger= true;
            GrantTriggerHelper.skipTrigger = true;
            TermConditionTriggerHelper.skipTrigger = true;
            SiteVisitTriggerHelper.skipTrigger = true;
            //AwardTriggerHelper.skipTrigger = true;
            StrategicPlanTriggerHelper.skipTrigger = true;
            GNT__KeyValueStore__c key= new GNT__KeyValueStore__c(Name='ENTERPRISE',GNT__BooleanValue__c=true);
            GNT__KeyValueStore__c key1= new GNT__KeyValueStore__c(Name='R&R Entry Unique',
                                                GNT__IntegerValue__c=1,
                                                GNT__BooleanValue__c=true,
                                                GNT__Admin_Question__c = 'Loren Ipsum',
                                                GNT__Description__c='Email address to send feedback of the customer in real time');
            insert key1;
            Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
            User u1 = new User(Alias = 'admtp', Email='sysAdmin@govbd.dev',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/New_York', UserName='sysAdmin'+Math.random()+'@govbd.dev');
            insert u1;
            acct=TestHelper.getAccount(true);
            ann = TestHelper.getAnnouncement(true);
            ann.PointofContact__c = u.Id;
            ann.Status__c='Approved';
            ann.AnnouncementName__c = 'Sample 1';
            update ann;
            app = TestHelper.getApplication(ann.Id,true);
            
            Test.startTest();
            GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateasGrantee');
            grants = TestHelper.getGrant(true);
            awards = TestHelper.getAwards(grants.Id,false);
            awards.Application__c=app.Id;
            awards.Announcement__c=ann.Id;
            //insert awards;
            List<Award__c> awdList=new List<Award__c>();
            awdList.add(awards);
            insert awdList;
            update awards;
            delete awards;
            /*GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateasGrantee');
            grants1 = TestHelper.getGrant(true);
            awards1 = TestHelper.getAwards(grants.Id,false);
            insert awards1;
            /*List<Award__c> awdList1=new List<Award__c>();
            awdList1.add(awards);
            insert awdList1;*/
            /*update awards1;
            delete awards1;*/
            
            Test.stopTest();
        }
    }   


    //Shivankar: The methods below moved to new class TestUSBEAwardtriggerHelper


     //Shivankar: method to cover methods copyApplicationBudgetDetails() and moveAllTCToCurrentAward()
    // static testMethod void testcopyApplicationBudgetDetails() {  

    //    UserTriggerHelper.skipTrigger = true; 
    //    User u = TestHelper.getAdminUser(true);
    //    Test.startTest();
    //    system.runAs(u){
    //        TermConditionTriggerHelper.skipTrigger=true;
    //        PaymentRequestTriggerHelper.skipTrigger=true;
    //        ProgressReportsTriggerHelper.skipTrigger=true;
    //        SiteVisitTriggerHelper.skipTrigger=true;
    //        AwardBudgetCategoryTriggerHelper.skipTrigger=true;
    //        AnnouncementTriggerHelper.skipTrigger = true;
    //        AccountTriggerhelper.skipTrigger=true;
    //        ApplicationtriggerHelper.skiptrigger = true;
    //        ServiceAreaTriggerHelper.skiptrigger = true;
    //        ProgramTriggerHelper.skipTrigger=true;
    //        RolesandResponsibilitiesTriggerHelper.skipTrigger = true;
    //        GranttriggerHelper.skipTrigger = true;
    //        User u1=TestHelper.getPortalUser(true);
    //        Contact c = TestHelper.getcontact(false);
    //        c.UserReference__c=u1.id;
    //        insert c;
        
            
    //        Account acc=TestHelper.getAccount(false);
    //        acc.name='USBE';
    //        insert acc;

    //        Program__c prog=TestHelper.getProgram(acc.Id,true);
    //        prog.BuildupFunctionalityNeeded__c='Yes';
    //        update prog;

    //        Announcement__c ann = TestHelper.getAnnouncement(prog.id,true);
    //        ann.DetailedBudgetingRequired__c='Yes';
    //        ann.FinancialApprover__c=u1.id;
    //        update ann;

    //        Application__c app = TestHelper.getApplication(ann.Id,true);
    //        app.IndirectCostPercentage__c=5;
    //        app.AmountThisAction__c=1000;
    //        update app;

    //        BudgetPeriod__c budPeriod = new BudgetPeriod__c();
    //        budPeriod.BudgetStartDate__c = System.Today() - 7;
    //        budPeriod.BudgetEndDate__c = System.today() + 358;
    //        insert budPeriod;


    //        ServiceArea__c sva=TestHelper.getServiceArea(true);
    //        ApplicationServiceArea__c asva=new ApplicationServiceArea__c();
    //        asva.ServiceAreaLookup__c=sva.Id;
    //        asva.Application__c=app.Id;
    //        Insert asva;

    //        Id recordTypeId = TestHelper.getRecordType(Schema.Sobjecttype.BudgetCategory__c, 'External');
    //        BudgetCategory__c bc = new BudgetCategory__c(RecordTypeId = recordTypeId,
    //                                        Name='Total Indirect Costs (Applies only to Lines 1-7):',
    //                                        CategoryDescription__c='Total Indirect Costs (Applies only to Lines 1-7):');
    //         insert bc;
           
    //        ApplicationBudgetCategory2__c abc2=new ApplicationBudgetCategory2__c(BudgetCategory__c=bc.id,Amount__c=123456.0,
    //        BudgetAmountUSBE__c=45678.0,IsFirstBudgetPeriodRelated__c = true, AdminCostValue__c=111111.0);
    //        abc2.ServiceArea__c=asva.Id;
    //        abc2.Application__c=app.Id;
    //        insert abc2;

    //        BuildUpItem__c buildUpItem=new BuildUpItem__c(Title__c='test', Narrative__c='test', StartDate__c=System.today(), 
    //            EndDate__c=System.today()+1, ApplicationBudgetCategory__c=abc2.Id,UnitPrice__c=10, Quantity__c=100, 
    //            UnitofMeasurement__c='Gallons', OtherCharges__c=1000,AllowableDirect__c=500 , Indirect__c=10, 
    //            GrantorShare__c=25,EquipmentDesc__c='test description',name__c='test',TotalHours__c=10,RequestedHours__c=10,
    //              HourlyRate__c=10,SourceType__c='Federal',ListBenefitType__c='test',FBTotalSalary__c=1000,Benefit__c =20,
    //              TravelDestination__c='New York',TravelPurpose__c='test',TravelTotalMiles__c=1000,TravelMileRate__c=1000,
    //              EquipmentVAWAUse__c=10,CSCType__c='test',CFTotalHours__c=100,CFRate__c=10,NumberofDays__c=10,
    //              HotelFees__c=1000,PerDiem__c=1000,RegistrationPerPerson__c=100,NumberAttending__c=10);
    //            insert buildUpItem;


           
    //        Grant__c grant = new Grant__c();
    //        grant.GranteePOC__c=u1.Id;
    //        grant.ExternalOrganization__c=acc.Id;
    //        grant.ProjectPeriodStartDate__c=Date.newInstance(2015,3,14);
    //        grant.Application__c=app.Id;
    //        grant.ProjectPeriodEndDate__c=Date.newInstance(2016,3,14);
    //        grant.IssueDate__c=Date.newInstance(2015,2,14);
    //        grant.Program__c=prog.Id;
    //        grant.GranteePOC__c = u.id;
    //        grant.IsTCScheduleCreated__c=true;
    //        insert grant;
    //        GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c', 'StateasGrantor');



         
    //        Award__c aw  = TestHelper.getAwards(grant.Id,false);
    //        aw.Grant__c=grant.Id;
    //        aw.BudgetPeriod__c=budPeriod.Id;
    //        aw.BudgetNarrativeRead__c='test text';
    //        aw.Name = Math.Random()+'AW12';
    //        aw.OrganizationName__c = 'USBE';
    //        aw.OrganizationAddress__c = 'Test Address';
    //        aw.FiscalYear__c = '2013';
    //        aw.SupportYear__c = Decimal.valueOf('2013');
    //        aw.Status__c = 'Activated';
    //        aw.Application__c=app.Id;
    //        aw.AwardedAmountthisAction__c = 10000.00;
    //        aw.TotalObligateAmount__c = 100000.00;
    //        aw.DeepCloned__c = true;
    //        aw.Announcement__c=ann.Id;
    //        insert aw;

    //       //To get coverage for method moveAllTCToCurrentAward() in USBEAwardTriggerhelper class
          
    //        Termcondition__c tnc=TestHelper.getTermCondition(false,'Term');
    //        tnc.Award__c=aw.id;
    //        insert tnc;

    //        PaymentRequest__c pr=TestHelper.getPaymentRequest(false);
    //        pr.Award__c=aw.id;
    //        insert pr;

    //        SiteVisit__c sv = new SiteVisit__c(/*SiteVisitSchedule__c=ss.Id,*/ Status__c='Approved', Grant__c=grant.Id, 
    //        SiteVisitor__c=UserInfo.getUserId(), VisitDateandTime__c=DateTime.now() - 5, VisitEndDateTime__c = DateTime.now());

    //         insert sv;

    //        ProgressReports__c  progrep=new ProgressReports__c();
    //        progrep.Award__c=aw.id;
    //        progrep.TermandCondition__c=tnc.Id;
    //        insert progrep;

    //        update aw;

    //        //To get coverage for method prepareProgressReportSiteVisitPaymentSchedule() in USBEAwardTriggerhelper class
    //        tnc=TestHelper.getTermCondition(true,'Site Visit');
    //        tnc.Frequency__c='Fixed';
    //        update tnc;
    //        grant.IsTCScheduleCreated__c=false;
    //        update grant;
    //        update aw;
            


    //    }
    //    Test.stopTest();
    // } 

    //static testMethod void TestcreateGranteeBudgetCategories(){

    //    UserTriggerHelper.skipTrigger = true; 
    //    User u = TestHelper.getAdminUser(true);
    //    //Contact c = TestHelper.getcontact(true);
    //    Test.startTest();
    //    system.runAs(u){
    //        BuildUpItemTriggerHelper.skiptrigger=true;
    //        TermConditionTriggerHelper.skipTrigger=true;
    //        PaymentRequestTriggerHelper.skipTrigger=true;
    //        ProgressReportsTriggerHelper.skipTrigger=true;
    //        SiteVisitTriggerHelper.skipTrigger=true;
    //        AwardBudgetCategoryTriggerHelper.skipTrigger=true;
    //        AnnouncementTriggerHelper.skipTrigger = true;
    //        AccountTriggerhelper.skipTrigger=true;
    //        ApplicationtriggerHelper.skiptrigger = true;
    //        ServiceAreaTriggerHelper.skiptrigger = true;
    //        ProgramTriggerHelper.skipTrigger=true;
    //        RolesandResponsibilitiesTriggerHelper.skipTrigger = true;
    //        GranttriggerHelper.skipTrigger = true;
    //        User u1=TestHelper.getPortalUser(true);
    //        Contact c = TestHelper.getcontact(false);
    //        c.UserReference__c=u1.id;
    //        insert c;
            
    //        Account acc=TestHelper.getAccount(false);
    //        acc.name='USBE';
    //        insert acc;

    //        Program__c prog=TestHelper.getProgram(acc.Id,true);
    //        prog.BuildupFunctionalityNeeded__c='Yes';
    //        update prog;

    //        Announcement__c ann = TestHelper.getAnnouncement(prog.id,true);
    //        ann.DetailedBudgetingRequired__c='Yes';
    //        ann.FinancialApprover__c=u1.id;
    //        update ann;

    //        Application__c app = TestHelper.getApplication(ann.Id,true);
    //        app.IndirectCostPercentage__c=5;
    //        app.AmountThisAction__c=1000;
    //        update app;

    //        BudgetPeriod__c budPeriod = new BudgetPeriod__c();
    //        budPeriod.BudgetStartDate__c = System.Today() - 7;
    //        budPeriod.BudgetEndDate__c = System.today() + 358;
    //        budPeriod.SequenceNumber__c = 1.0;

    //        insert budPeriod;

    //        ServiceArea__c sva=TestHelper.getServiceArea(true);
    //        ApplicationServiceArea__c asva=new ApplicationServiceArea__c();
    //        asva.ServiceAreaLookup__c=sva.Id;
    //        asva.Application__c=app.Id;
    //        Insert asva;

    //        Id recordTypeId = TestHelper.getRecordType(Schema.Sobjecttype.BudgetCategory__c, 'External');
    //        BudgetCategory__c bc = new BudgetCategory__c(RecordTypeId = recordTypeId,Class__c = 'Construction',
    //                                        Name='Total Indirect Costs (Applies only to Lines 1-7):',
    //                                        CategoryDescription__c='Total Indirect Costs (Applies only to Lines 1-7):');
    //         insert bc;
           
    //        ApplicationBudgetCategory2__c abc2=new ApplicationBudgetCategory2__c(BudgetCategory__c=bc.id,Amount__c=123456.0,
    //        BudgetAmountUSBE__c=45678.0,IsFirstBudgetPeriodRelated__c = true, AdminCostValue__c=111111.0);
    //        abc2.BudgetPeriod__c=budPeriod.Id;
    //        abc2.ServiceArea__c=asva.Id;
    //        abc2.Application__c=app.Id;
    //        insert abc2;

    //        BuildUpItem__c buildUpItem=new BuildUpItem__c(Title__c='test', Narrative__c='test', StartDate__c=System.today(), 
    //            EndDate__c=System.today()+1, ApplicationBudgetCategory__c=abc2.Id,UnitPrice__c=10, Quantity__c=100, 
    //            UnitofMeasurement__c='Gallons', OtherCharges__c=1000,AllowableDirect__c=500 , Indirect__c=10, 
    //            GrantorShare__c=25,EquipmentDesc__c='test description',name__c='test',TotalHours__c=10,RequestedHours__c=10,
    //              HourlyRate__c=10,SourceType__c='Federal',ListBenefitType__c='test',FBTotalSalary__c=1000,Benefit__c =20,
    //              TravelDestination__c='New York',TravelPurpose__c='test',TravelTotalMiles__c=1000,TravelMileRate__c=1000,
    //              EquipmentVAWAUse__c=10,CSCType__c='test',CFTotalHours__c=100,CFRate__c=10,NumberofDays__c=10,
    //              HotelFees__c=1000,PerDiem__c=1000,RegistrationPerPerson__c=100,NumberAttending__c=10);
    //            insert buildUpItem;


           
    //        Grant__c grant = new Grant__c();
    //        grant.GranteePOC__c=u1.Id;
    //        grant.ExternalOrganization__c=acc.Id;
    //        grant.ProjectPeriodStartDate__c=Date.newInstance(2015,3,14);
    //        grant.Application__c=app.Id;
    //        grant.ProjectPeriodEndDate__c=Date.newInstance(2016,3,14);
    //        grant.IssueDate__c=Date.newInstance(2015,2,14);
    //        grant.Program__c=prog.Id;
    //        grant.GranteePOC__c = u.id;
    //        grant.IsTCScheduleCreated__c=true;
    //        insert grant;
    //        GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c', 'StateasGrantee');



         
    //        Award__c aw  = TestHelper.getAwards(grant.Id,false);
    //        aw.Grant__c=grant.Id;
    //        aw.BudgetPeriod__c=budPeriod.Id;
    //        aw.BudgetNarrativeRead__c='test text';
    //        aw.Name = Math.Random()+'AW12';
    //        aw.OrganizationName__c = 'USBE';
    //        aw.OrganizationAddress__c = 'Test Address';
    //        aw.FiscalYear__c = '2013';
    //        aw.SupportYear__c = Decimal.valueOf('2013');
    //        aw.Status__c = 'Activated';
    //        aw.Application__c=app.Id;
    //        aw.AwardedAmountthisAction__c = 10000.00;
    //        aw.TotalObligateAmount__c = 100000.00;
    //        aw.DeepCloned__c = true;
    //        aw.Announcement__c=ann.Id;
    //        insert aw;

    //        Termcondition__c tnc=TestHelper.getTermCondition(false,'Term');
    //        tnc.Award__c=aw.id;
    //        insert tnc;

    //        PaymentRequest__c pr=TestHelper.getPaymentRequest(false);
    //        pr.Award__c=aw.id;
    //        insert pr;

    //        SiteVisit__c sv = new SiteVisit__c(/*SiteVisitSchedule__c=ss.Id,*/ Status__c='Approved', Grant__c=grant.Id, 
    //        SiteVisitor__c=UserInfo.getUserId(), VisitDateandTime__c=DateTime.now() - 5, VisitEndDateTime__c = DateTime.now());

    //         insert sv;

    //        ProgressReports__c  progrep=new ProgressReports__c();
    //        progrep.Award__c=aw.id;
    //        progrep.TermandCondition__c=tnc.Id;
    //        insert progrep;


    //        update aw;


    //        grant.Application__c=null;
    //        grant.TypeOfBudgetCategories__c = 'Construction';
    //        update grant;

    //        GrantServiceArea__c grantServiceArea = new GrantServiceArea__c();
    //        grantServiceArea.ServiceArea__c = sva.Id;
    //        grantServiceArea.Grant__c = grant.Id;
    //        insert grantServiceArea;


    //        grant.Application__c=null;
    //        update grant;
    //        Award__c aw1  = TestHelper.getAwards(grant.Id,false);
    //        aw1.Grant__c=grant.Id;
    //        aw1.BudgetPeriod__c=budPeriod.Id;
    //        aw1.BudgetNarrativeRead__c='test text';
    //        aw1.Name = Math.Random()+'AW12';
    //        aw1.OrganizationName__c = 'USBE';
    //        aw1.OrganizationAddress__c = 'Test Address';
    //        aw1.FiscalYear__c = '2013';
    //        aw1.SupportYear__c = Decimal.valueOf('2013');
    //        aw1.Status__c = 'Activated';
    //        aw1.AwardedAmountthisAction__c = 10000.00;
    //        aw1.TotalObligateAmount__c = 100000.00;
    //        aw1.DeepCloned__c = true;
    //        aw1.Announcement__c=ann.Id;
    //        insert aw1;
    //    }
    //    Test.stopTest();

    // }

    // static testMethod void TestAwardDeletion(){

    //    UserTriggerHelper.skipTrigger = true; 
    //    User u = TestHelper.getAdminUser(true);
    //    //Contact c = TestHelper.getcontact(true);
    //    Test.startTest();
    //    system.runAs(u){
    //        BuildUpItemTriggerHelper.skiptrigger=true;
    //        TermConditionTriggerHelper.skipTrigger=true;
    //        PaymentRequestTriggerHelper.skipTrigger=true;
    //        ProgressReportsTriggerHelper.skipTrigger=true;
    //        SiteVisitTriggerHelper.skipTrigger=true;
    //        AwardBudgetCategoryTriggerHelper.skipTrigger=true;
    //        AnnouncementTriggerHelper.skipTrigger = true;
    //        AccountTriggerhelper.skipTrigger=true;
    //        ApplicationtriggerHelper.skiptrigger = true;
    //        ServiceAreaTriggerHelper.skiptrigger = true;
    //        ProgramTriggerHelper.skipTrigger=true;
    //        RolesandResponsibilitiesTriggerHelper.skipTrigger = true;
    //        GranttriggerHelper.skipTrigger = true;
    //        User u1=TestHelper.getPortalUser(true);
    //        Contact c = TestHelper.getcontact(false);
    //        c.UserReference__c=u1.id;
    //        insert c;
            
    //        Account acc=TestHelper.getAccount(false);
    //        acc.name='USBE';
    //        insert acc;

    //        Program__c prog=TestHelper.getProgram(acc.Id,true);
    //        prog.BuildupFunctionalityNeeded__c='Yes';
    //        update prog;

    //        Announcement__c ann = TestHelper.getAnnouncement(prog.id,true);
    //        ann.DetailedBudgetingRequired__c='Yes';
    //        ann.FinancialApprover__c=u1.id;
    //        update ann;

    //        Application__c app = TestHelper.getApplication(ann.Id,true);
    //        app.IndirectCostPercentage__c=5;
    //        app.AmountThisAction__c=1000;
    //        update app;

    //        BudgetPeriod__c budPeriod = new BudgetPeriod__c();
    //        budPeriod.BudgetStartDate__c = System.Today() - 7;
    //        budPeriod.BudgetEndDate__c = System.today() + 358;
    //        budPeriod.SequenceNumber__c = 1.0;

    //        insert budPeriod;

    //        ServiceArea__c sva=TestHelper.getServiceArea(true);
    //        ApplicationServiceArea__c asva=new ApplicationServiceArea__c();
    //        asva.ServiceAreaLookup__c=sva.Id;
    //        asva.Application__c=app.Id;
    //        Insert asva;

    //        Id recordTypeId = TestHelper.getRecordType(Schema.Sobjecttype.BudgetCategory__c, 'External');
    //        BudgetCategory__c bc = new BudgetCategory__c(RecordTypeId = recordTypeId,Class__c = 'Construction',
    //                                        Name='Total Indirect Costs (Applies only to Lines 1-7):',
    //                                        CategoryDescription__c='Total Indirect Costs (Applies only to Lines 1-7):');
    //         insert bc;
           
    //        ApplicationBudgetCategory2__c abc2=new ApplicationBudgetCategory2__c(BudgetCategory__c=bc.id,Amount__c=123456.0,
    //        BudgetAmountUSBE__c=45678.0,IsFirstBudgetPeriodRelated__c = true, AdminCostValue__c=111111.0);
    //        abc2.BudgetPeriod__c=budPeriod.Id;
    //        abc2.ServiceArea__c=asva.Id;
    //        abc2.Application__c=app.Id;
    //        insert abc2;

    //        BuildUpItem__c buildUpItem=new BuildUpItem__c(Title__c='test', Narrative__c='test', StartDate__c=System.today(), 
    //            EndDate__c=System.today()+1, ApplicationBudgetCategory__c=abc2.Id,UnitPrice__c=10, Quantity__c=100, 
    //            UnitofMeasurement__c='Gallons', OtherCharges__c=1000,AllowableDirect__c=500 , Indirect__c=10, 
    //            GrantorShare__c=25,EquipmentDesc__c='test description',name__c='test',TotalHours__c=10,RequestedHours__c=10,
    //              HourlyRate__c=10,SourceType__c='Federal',ListBenefitType__c='test',FBTotalSalary__c=1000,Benefit__c =20,
    //              TravelDestination__c='New York',TravelPurpose__c='test',TravelTotalMiles__c=1000,TravelMileRate__c=1000,
    //              EquipmentVAWAUse__c=10,CSCType__c='test',CFTotalHours__c=100,CFRate__c=10,NumberofDays__c=10,
    //              HotelFees__c=1000,PerDiem__c=1000,RegistrationPerPerson__c=100,NumberAttending__c=10);
    //            insert buildUpItem;


           
    //        Grant__c grant = new Grant__c();
    //        grant.GranteePOC__c=u1.Id;
    //        grant.ExternalOrganization__c=acc.Id;
    //        grant.ProjectPeriodStartDate__c=Date.newInstance(2015,3,14);
    //        grant.Application__c=app.Id;
    //        grant.ProjectPeriodEndDate__c=Date.newInstance(2016,3,14);
    //        grant.IssueDate__c=Date.newInstance(2015,2,14);
    //        grant.Program__c=prog.Id;
    //        grant.GranteePOC__c = u.id;
    //        grant.IsTCScheduleCreated__c=true;
    //        insert grant;
    //        GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c', 'StateasGrantee');



         
    //        Award__c aw  = TestHelper.getAwards(grant.Id,false);
    //        aw.Grant__c=grant.Id;
    //        aw.BudgetPeriod__c=budPeriod.Id;
    //        aw.BudgetNarrativeRead__c='test text';
    //        aw.Name = Math.Random()+'AW12';
    //        aw.OrganizationName__c = 'USBE';
    //        aw.OrganizationAddress__c = 'Test Address';
    //        aw.FiscalYear__c = '2013';
    //        aw.SupportYear__c = Decimal.valueOf('2013');
    //        aw.Status__c = 'Activated';
    //        aw.Application__c=app.Id;
    //        aw.AwardedAmountthisAction__c = 10000.00;
    //        aw.TotalObligateAmount__c = 100000.00;
    //        aw.DeepCloned__c = true;
    //        aw.Announcement__c=ann.Id;
    //        insert aw;

    //        delete aw;



    //        Award__c aw1  = TestHelper.getAwards(grant.Id,false);
    //        aw1.Grant__c=grant.Id;
    //        aw1.BudgetPeriod__c=budPeriod.Id;
    //        aw1.BudgetNarrativeRead__c='test text';  
    //        aw1.Name = Math.Random()+'AW12';
    //        aw1.OrganizationName__c = 'USBE';
    //        aw1.OrganizationAddress__c = 'Test Address';
    //        aw1.FiscalYear__c = '2013';
    //        aw1.SupportYear__c = Decimal.valueOf('2013');
    //        aw1.Status__c = 'Issued';
    //        aw1.Application__c=app.Id;
    //        aw1.AwardedAmountthisAction__c = 10000.00;
    //        aw1.TotalObligateAmount__c = 100000.00;
    //        aw1.DeepCloned__c = true;
    //        aw1.Announcement__c=ann.Id;
    //        insert aw1;

    //        AmendmentRequest__c amreq=new AmendmentRequest__c(Status__c='Completed',Impact__c='test',Purpose__c='test',Award__c=aw1.id);
    //        insert amreq;
    //        //test 

    //        delete aw1;

    //    }
    //    Test.stopTest();

    // }
    // //static testMethod void TestprepareProgressReportSiteVisitPaymentSchedule(){}
    //static testMethod void TestinsertAwardBudgetCategoriesFromProgramWithSericeArea(){

    //    UserTriggerHelper.skipTrigger = true; 
    //    User u = TestHelper.getAdminUser(true);
    //    //Contact c = TestHelper.getcontact(true);
    //    Test.startTest();
    //    system.runAs(u){
    //        BuildUpItemTriggerHelper.skiptrigger=true;
    //        TermConditionTriggerHelper.skipTrigger=true;
    //        PaymentRequestTriggerHelper.skipTrigger=true;
    //        ProgressReportsTriggerHelper.skipTrigger=true;
    //        SiteVisitTriggerHelper.skipTrigger=true;
    //        AwardBudgetCategoryTriggerHelper.skipTrigger=true;
    //        AnnouncementTriggerHelper.skipTrigger = true;
    //        AccountTriggerhelper.skipTrigger=true;
    //        ApplicationtriggerHelper.skiptrigger = true;
    //        ServiceAreaTriggerHelper.skiptrigger = true;
    //        ProgramTriggerHelper.skipTrigger=true;
    //        RolesandResponsibilitiesTriggerHelper.skipTrigger = true;
    //        GranttriggerHelper.skipTrigger = true;
    //        User u1=TestHelper.getPortalUser(true);
    //        Contact c = TestHelper.getcontact(false);
    //        c.UserReference__c=u1.id;
    //        insert c;
            
    //        Account acc=TestHelper.getAccount(false);
    //        acc.name='USBE';
    //        insert acc;

    //        Program__c prog=TestHelper.getProgram(acc.Id,true);
    //        prog.BuildupFunctionalityNeeded__c='Yes';
    //        update prog;

    //        Announcement__c ann = TestHelper.getAnnouncement(prog.id,true);
    //        ann.DetailedBudgetingRequired__c='Yes';
    //        ann.FinancialApprover__c=u1.id;
    //        update ann;

    //        Application__c app = TestHelper.getApplication(ann.Id,true);
    //        app.IndirectCostPercentage__c=5;
    //        app.AmountThisAction__c=1000;
    //        update app;

    //        BudgetPeriod__c budPeriod = new BudgetPeriod__c();
    //        budPeriod.BudgetStartDate__c = System.Today() - 7;
    //        budPeriod.BudgetEndDate__c = System.today() + 358;
    //        budPeriod.SequenceNumber__c = 1.0;

    //        insert budPeriod;

    //        ServiceArea__c sva=TestHelper.getServiceArea(true);
    //        ApplicationServiceArea__c asva=new ApplicationServiceArea__c();
    //        asva.ServiceAreaLookup__c=sva.Id;
    //        asva.Application__c=app.Id;
    //        Insert asva;




    //        Id recordTypeId = TestHelper.getRecordType(Schema.Sobjecttype.BudgetCategory__c, 'External');
    //        BudgetCategory__c bc = new BudgetCategory__c(RecordTypeId = recordTypeId,Class__c = 'Construction',
    //                                        Name='Total Indirect Costs (Applies only to Lines 1-7):',
    //                                        CategoryDescription__c='Total Indirect Costs (Applies only to Lines 1-7):');
    //         insert bc;
           
    //        ProgramServiceArea__c programServiceArea = new ProgramServiceArea__c( Program__c=prog.Id, ServiceArea__c=sva.Id);
    //        ProgramBudgetCategory__c programBudgetCategory = new ProgramBudgetCategory__c(Program__c=prog.id, BudgetCategory__c=bc.id); 
    //        insert programServiceArea;
    //        insert programBudgetCategory;

    //        ApplicationBudgetCategory2__c abc2=new ApplicationBudgetCategory2__c(BudgetCategory__c=bc.id,Amount__c=123456.0,
    //        BudgetAmountUSBE__c=45678.0,IsFirstBudgetPeriodRelated__c = true, AdminCostValue__c=111111.0);
    //        abc2.BudgetPeriod__c=budPeriod.Id;
    //        abc2.ServiceArea__c=asva.Id;
    //        abc2.Application__c=app.Id;
    //        insert abc2;

    //        BuildUpItem__c buildUpItem=new BuildUpItem__c(Title__c='test', Narrative__c='test', StartDate__c=System.today(), 
    //            EndDate__c=System.today()+1, ApplicationBudgetCategory__c=abc2.Id,UnitPrice__c=10, Quantity__c=100, 
    //            UnitofMeasurement__c='Gallons', OtherCharges__c=1000,AllowableDirect__c=500 , Indirect__c=10, 
    //            GrantorShare__c=25,EquipmentDesc__c='test description',name__c='test',TotalHours__c=10,RequestedHours__c=10,
    //              HourlyRate__c=10,SourceType__c='Federal',ListBenefitType__c='test',FBTotalSalary__c=1000,Benefit__c =20,
    //              TravelDestination__c='New York',TravelPurpose__c='test',TravelTotalMiles__c=1000,TravelMileRate__c=1000,
    //              EquipmentVAWAUse__c=10,CSCType__c='test',CFTotalHours__c=100,CFRate__c=10,NumberofDays__c=10,
    //              HotelFees__c=1000,PerDiem__c=1000,RegistrationPerPerson__c=100,NumberAttending__c=10);
    //            insert buildUpItem;


           
    //        Grant__c grant = new Grant__c();
    //        grant.GranteePOC__c=u1.Id;
    //        grant.ExternalOrganization__c=acc.Id;
    //        grant.ProjectPeriodStartDate__c=Date.newInstance(2015,3,14);
    //        grant.Application__c=app.Id;
    //        grant.ProjectPeriodEndDate__c=Date.newInstance(2016,3,14);
    //        grant.IssueDate__c=Date.newInstance(2015,2,14);
    //        grant.Program__c=prog.Id;
    //        grant.GranteePOC__c = u.id;
    //        grant.IsTCScheduleCreated__c=true;
    //        insert grant;
    //        GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c', 'StateasGrantor');


    //        grant.Application__c=null;
    //        grant.TypeOfBudgetCategories__c = 'Construction';
    //        update grant;

    //        GrantServiceArea__c grantServiceArea = new GrantServiceArea__c();
    //        grantServiceArea.ServiceArea__c = sva.Id;
    //        grantServiceArea.Grant__c = grant.Id;
    //        insert grantServiceArea;

    //        //For covering updateAddress() method in USBEAwardTriggerHelper class
    //        USDemographicInfo__c USDemographicInfo = new USDemographicInfo__c(StateName__c='test', PrimaryCity__c='test', County__c='test',
    //                                   CongressionalDistrict__c='test');
    //        insert USDemographicInfo;


    //        Award__c aw1  = TestHelper.getAwards(grant.Id,false);
    //        aw1.zipcode__c=USDemographicInfo.Id;
    //        aw1.Application__c=app.Id;
    //        aw1.Grant__c=grant.Id;
    //        aw1.BudgetPeriod__c=budPeriod.Id;
    //        aw1.BudgetNarrativeRead__c='test text';
    //        aw1.Name = Math.Random()+'AW12';
    //        aw1.OrganizationName__c = 'USBE';
    //        aw1.OrganizationAddress__c = 'Test Address';
    //        aw1.FiscalYear__c = '2013';
    //        aw1.SupportYear__c = Decimal.valueOf('2013');
    //        aw1.Status__c = 'Activated';
    //        aw1.AwardedAmountthisAction__c = 10000.00;
    //        aw1.TotalObligateAmount__c = 100000.00;
    //        aw1.DeepCloned__c = true;
    //        aw1.Announcement__c=ann.id;
    //        insert aw1;
    //    }
    //    Test.stopTest();

    // }

}