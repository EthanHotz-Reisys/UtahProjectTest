@isTest
private class TestDeepCloneAmendmentHelper {

     @isTest static void testWhenClicked1() {
              
        User u = TestHelper.getAdminUser(true);
        RolesandResponsibilitiesTriggerHelper.skipTrigger = true;
        AmendmentRequestTriggerHelper.skipTrigger = true;
        ServiceArea__c serviceArea = TestHelper.getServiceArea(true);
        AnnouncementTriggerHelper.skipTrigger = true;
        //ApplicationTriggerHelper.skipTrigger = true;
        
        TaskTriggerHelper.skipTrigger = true;
        Announcement__c announcement = TestHelper.getAnnouncement(true);
        Application__c application = TestHelper.getApplication(announcement.Id, true);

        Account account1 = TestHelper.getAccount(true);
        Id recTypeIdRec = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Recipient').getRecordTypeId();
        account1.RecordTypeId = recTypeIdRec;
        update account1;

        List<Contact> contacts = new List<Contact>();

        Contact c = new Contact(Firstname='TestName', Lastname='TestLastName',Email='Testemail@email.com', 
                                                Title='Title',Phone ='123-123-1234');
        
        Contact c1 = new Contact(Firstname='Sample1', Lastname='Sample2',Email='Sample2@email.com', 
                                                AccountId=account1.Id,Title='SampleTitle',Phone ='321-321-4321');
              

              contacts.add(c);
              contacts.add(c1);

              insert contacts;
              GrantTriggerHelper.skipTrigger = true;

        Grant__c grant = TestHelper.getGrant(true);

        List<BudgetPeriod__c> budgetPeriods = new List<BudgetPeriod__c>();

        BudgetPeriod__c budgetPeriod1 = new BudgetPeriod__c(BudgetStartDate__c=System.today(),
                                                            BudgetEndDate__c=System.today(),
                                                            SequenceNumber__c=1.0,
                                                            Grant__c=grant.Id);
        

        BudgetPeriod__c budgetPeriod2 = new BudgetPeriod__c(BudgetStartDate__c=System.today(),
                                                            BudgetEndDate__c=System.today(),
                                                            SequenceNumber__c=2.0,
                                                            Grant__c=grant.Id);

        BudgetPeriod__c budgetPeriod = new BudgetPeriod__c(BudgetStartDate__c=System.today(),
                                                                                                   BudgetEndDate__c=System.today(),Grant__c=grant.Id,
                                                                                                   Status__c='Open',Notes__c='test');

        budgetPeriods.add(budgetPeriod1);
        budgetPeriods.add(budgetPeriod2);
        budgetPeriods.add(budgetPeriod);

        insert budgetPeriods;

        AwardTriggerHelper.skipTrigger = true;        

        Award__c awd = TestHelper.getAwards(grant.Id,true);
        awd.TotalObligateAmount__c = 10000.00;
        awd.GrantAwardName__c = 'Test Award Name';
        awd.FederalGrantAwardIdFAIN__c= 'Test';
        awd.CFDANumber__c='Test';
        awd.AwardType__c='New';
        awd.FederalAssistanceType__c='New Test';
        awd.AwardIssueDate__c=system.today();
        awd.BudgetPeriod__c = budgetPeriod.Id;
        awd.IsStateMatchRequired__c = false;
        awd.HaveYouAcceptedTheAward__c = 'yes';
        awd.Application__c  = application.Id;
        awd.AmendmentType__c  = 'Test';
        awd.BudgetPeriodEndDate__c=system.today();
        awd.AmendedPurchaseOrderNumber__c = 'Test';
        awd.AwardedAmountthisAction__c = 5000.00;
        update awd;

        GrantContact__c awardContact = new GrantContact__c(Award__c=awd.Id,Contact__c=c.Id,Role__c='KeyPOC');
        insert awardContact;

        List<AwardBudgetCategory__c> awardBudgetCategories = new List<AwardBudgetCategory__c>();

        List<BudgetCategory__c> budgetCategories = TestHelper.getBudgetCategory(true);

        AwardBudgetCategory__c aBC1 = new AwardBudgetCategory__c(Award__c=awd.Id,
                                                                 BudgetCategory__c=budgetCategories[0].Id,
                                                                 BudgetPeriod__c=budgetPeriod1.Id,
                                                                 Amount1__c=29000.0);
        AwardBudgetCategory__c aBC2 = new AwardBudgetCategory__c(Award__c=awd.Id,
                                                                BudgetCategory__c=budgetCategories[1].Id,
                                                                BudgetPeriod__c=budgetPeriod2.Id,
                                                                Amount1__c= 1000.0);
        awardBudgetCategories.add(aBC1);
        awardBudgetCategories.add(aBC2);

        insert awardBudgetCategories;


        Id recordTypeId1 = TestHelper.getRecordType(Schema.Sobjecttype.AmendmentRequest__c,'Formal Amendments');
        AmendmentRequest__c amendmentRequest1 = new AmendmentRequest__c(RecordTypeId = recordTypeId1,
                                                                        Award__c=awd.Id,
                                                                        Purpose__c='Test Purpose',
                                                                        KeyContactChange__c=false,
                                                                        BudgetPeriodExtension__c=false,
                                                                        NewKeyPOC__c=c1.Id,BudgetPeriodChange__c=false,
                                                                        Impact__c='Test Impact',AmendmentContact__c=c.Id,
                                                                        NoCostExtension__c=true,
                                                                        NewBudgetPeriodEndDate__c=date.newInstance(2016,12,26));
        insert amendmentRequest1;

        Id recTypeId = TestHelper.getRecordType(Schema.SObjectType.RolesAndResponsibilities__c,'Amendment Request');

        List<RolesAndResponsibilities__c> rolesandResponsibilities = new List<RolesAndResponsibilities__c>();

        RolesAndResponsibilities__c rolesAndResponsibility1 = new RolesAndResponsibilities__c(RecordTypeId=recTypeId,
                                                                AmendmentRequest__c=amendmentRequest1.Id,
                                                                Name__c=u.Id,
                                                                BusinessRole__c='Program Approver');
        RolesAndResponsibilities__c rolesAndResponsibility2 = new RolesAndResponsibilities__c(RecordTypeId=recTypeId,
                                                                AmendmentRequest__c=amendmentRequest1.Id,
                                                                Name__c=u.Id,
                                                                BusinessRole__c='Fiscal Approver');
        RolesAndResponsibilities__c rolesAndResponsibility3 = new RolesAndResponsibilities__c(RecordTypeId=recTypeId,
                                                                AmendmentRequest__c=amendmentRequest1.Id,
                                                                Name__c=u.Id,
                                                                BusinessRole__c='Executive Approver');

        rolesandResponsibilities.add(rolesAndResponsibility1);
        rolesandResponsibilities.add(rolesAndResponsibility2);
        rolesandResponsibilities.add(rolesAndResponsibility3);
        RolesandResponsibilitiesTriggerHelper.skipTrigger = true;
        insert rolesandResponsibilities;
        
        Attachment att = new Attachment(Name='TestAttach',Body=Blob.valueOf('Test Attachment'),ParentId=amendmentRequest1.Id);
        insert att;
        Test.startTest();
               ApexPages.currentPage().getParameters().put('Id',amendmentRequest1.Id);

               String ns = AppUtils.getNamespacePrefix();
               GNT__PageLayoutConfig__c pageLayoutConfig =  TestHelper.getPageLayoutConfig(true,'AmendmentRequest__c');
               GNT.DynamicLayoutHolder layoutHolder = new GNT.DynamicLayoutHolder(pageLayoutConfig.id, amendmentRequest1.Id,true);


               DeepCloneAmendmentHelper deepCloneAmendmentHelper = new DeepCloneAmendmentHelper(layoutHolder);
               DeepCloneAmendmentHelper deepCloneAmendmentHelper1 = new DeepCloneAmendmentHelper();
               Apexpages.Standardcontroller sc = new ApexPages.StandardController(amendmentRequest1);
               DeepCloneAmendmentHelper deepCloneAmendmentHelper2 = new DeepCloneAmendmentHelper(sc);
               deepCloneAmendmentHelper.whenClicked();
           Test.stopTest();
       }
       
@isTest static void testWhenClicked2() {
              
              User u = TestHelper.getAdminUser(true);
              RolesandResponsibilitiesTriggerHelper.skipTrigger = true;
              AmendmentRequestTriggerHelper.skipTrigger = true;
        ServiceArea__c serviceArea = TestHelper.getServiceArea(true);
        AnnouncementTriggerHelper.skipTrigger = true;
        ApplicationTriggerHelper.skipTrigger = true;
        TaskTriggerHelper.skipTrigger = true;
        Announcement__c announcement = TestHelper.getAnnouncement(true);
        Application__c application = TestHelper.getApplication(announcement.Id, true);

        Account account1 = TestHelper.getAccount(true);
        Id recTypeIdRec = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Recipient').getRecordTypeId();
        account1.RecordTypeId = recTypeIdRec;
        update account1;

        List<Contact> contacts = new List<Contact>();

        Contact c = new Contact(Firstname='TestName', Lastname='TestLastName',Email='Testemail@email.com', 
                                                Title='Title',Phone ='123-123-1234');

        Contact c1 = new Contact(Firstname='Sample1', Lastname='Sample2',Email='Sample2@email.com', 
                                                AccountId=account1.Id,Title='SampleTitle',Phone ='321-321-4321');

              contacts.add(c);
              contacts.add(c1);

              insert contacts;
              GrantTriggerHelper.skipTrigger = true;

        Grant__c grant = TestHelper.getGrant(true);

        List<BudgetPeriod__c> budgetPeriods = new List<BudgetPeriod__c>();

        BudgetPeriod__c budgetPeriod1 = new BudgetPeriod__c(BudgetStartDate__c=System.today(),
                                                            BudgetEndDate__c=System.today(),
                                                            SequenceNumber__c=1.0,
                                                            Grant__c=grant.Id);
        

        BudgetPeriod__c budgetPeriod2 = new BudgetPeriod__c(BudgetStartDate__c=System.today(),
                                                            BudgetEndDate__c=System.today(),
                                                            SequenceNumber__c=2.0,
                                                            Grant__c=grant.Id);

        BudgetPeriod__c budgetPeriod = new BudgetPeriod__c(BudgetStartDate__c=System.today(),
                                                                                                   BudgetEndDate__c=System.today(),Grant__c=grant.Id,
                                                                                                   Status__c='Open',Notes__c='test');

        budgetPeriods.add(budgetPeriod1);
        budgetPeriods.add(budgetPeriod2);
        budgetPeriods.add(budgetPeriod);

        insert budgetPeriods;

        AwardTriggerHelper.skipTrigger = true;

        Award__c awd = TestHelper.getAwards(grant.Id,true);
        awd.TotalObligateAmount__c = 10000.00;
        awd.GrantAwardName__c = 'Test Award Name';
        awd.FederalGrantAwardIdFAIN__c= 'Test';
        awd.CFDANumber__c='Test';
        awd.AwardType__c='New';
        awd.FederalAssistanceType__c='New Test';
        awd.AwardIssueDate__c=system.today();
        awd.BudgetPeriod__c = budgetPeriod.Id;
        awd.IsStateMatchRequired__c = false;
        awd.HaveYouAcceptedTheAward__c = 'yes';
        awd.Application__c  = application.Id;
        awd.AmendmentType__c  = 'Test';
        awd.BudgetPeriodEndDate__c=system.today();
        awd.AmendedPurchaseOrderNumber__c = 'Test';
        awd.AwardedAmountthisAction__c = 5000.00;
        update awd;

        GrantContact__c awardContact = new GrantContact__c(Award__c=awd.Id,Contact__c=c.Id,Role__c='KeyPOC');
        insert awardContact;

        List<AwardBudgetCategory__c> awardBudgetCategories = new List<AwardBudgetCategory__c>();

        List<BudgetCategory__c> budgetCategories = TestHelper.getBudgetCategory(true);

        AwardBudgetCategory__c aBC1 = new AwardBudgetCategory__c(Award__c=awd.Id,
                                                                 BudgetCategory__c=budgetCategories[0].Id,
                                                                 BudgetPeriod__c=budgetPeriod1.Id,
                                                                 Amount1__c=29000.0);
        AwardBudgetCategory__c aBC2 = new AwardBudgetCategory__c(Award__c=awd.Id,
                                                                BudgetCategory__c=budgetCategories[1].Id,
                                                                BudgetPeriod__c=budgetPeriod2.Id,
                                                                Amount1__c= 1000.0);
        awardBudgetCategories.add(aBC1);
        awardBudgetCategories.add(aBC2);

        insert awardBudgetCategories;


        Id recordTypeId1 = TestHelper.getRecordType(Schema.Sobjecttype.AmendmentRequest__c,'Formal Amendments');
        AmendmentRequest__c amendmentRequest1 = new AmendmentRequest__c(RecordTypeId = recordTypeId1,
                                                                        Award__c=awd.Id,
                                                                        Purpose__c='Test Purpose',
                                                                        KeyContactChange__c=true,
                                                                        BudgetPeriodExtension__c=true,
                                                                        NewKeyPOC__c=c1.Id,BudgetPeriodChange__c=false,
                                                                        Impact__c='Test Impact',AmendmentContact__c=c.Id,
                                                                        NoCostExtension__c=false,ContactChangeDescription__c='Test',
                                                                        NewBudgetPeriodEndDate__c=date.newInstance(2016,12,26));
        insert amendmentRequest1;

        Id recTypeId = TestHelper.getRecordType(Schema.SObjectType.RolesAndResponsibilities__c,'Amendment Request');

        List<RolesAndResponsibilities__c> rolesandResponsibilities = new List<RolesAndResponsibilities__c>();

        RolesAndResponsibilities__c rolesAndResponsibility1 = new RolesAndResponsibilities__c(RecordTypeId=recTypeId,
                                                                AmendmentRequest__c=amendmentRequest1.Id,
                                                                Name__c=u.Id,
                                                                BusinessRole__c='Program Approver');
        RolesAndResponsibilities__c rolesAndResponsibility2 = new RolesAndResponsibilities__c(RecordTypeId=recTypeId,
                                                                AmendmentRequest__c=amendmentRequest1.Id,
                                                                Name__c=u.Id,
                                                                BusinessRole__c='Fiscal Approver');
        RolesAndResponsibilities__c rolesAndResponsibility3 = new RolesAndResponsibilities__c(RecordTypeId=recTypeId,
                                                                AmendmentRequest__c=amendmentRequest1.Id,
                                                                Name__c=u.Id,
                                                                BusinessRole__c='Executive Approver');

        rolesandResponsibilities.add(rolesAndResponsibility1);
        rolesandResponsibilities.add(rolesAndResponsibility2);
        rolesandResponsibilities.add(rolesAndResponsibility3);

        insert rolesandResponsibilities;
        
        Attachment att = new Attachment(Name='TestAttach',Body=Blob.valueOf('Test Attachment'),ParentId=amendmentRequest1.Id);
        insert att;
        Test.startTest();
               ApexPages.currentPage().getParameters().put('Id',amendmentRequest1.Id);

               String ns = AppUtils.getNamespacePrefix();
               GNT__PageLayoutConfig__c pageLayoutConfig =  TestHelper.getPageLayoutConfig(true,'AmendmentRequest__c');
               GNT.DynamicLayoutHolder layoutHolder = new GNT.DynamicLayoutHolder(pageLayoutConfig.id, amendmentRequest1.Id,true);


               DeepCloneAmendmentHelper deepCloneAmendmentHelper = new DeepCloneAmendmentHelper(layoutHolder);
               deepCloneAmendmentHelper.whenClicked();
           Test.stopTest();
       }


    
@isTest static void testAmeToAwdBudCats() {
              User u = TestHelper.getAdminUser(true);
        RolesandResponsibilitiesTriggerHelper.skipTrigger = true;
        AmendmentRequestTriggerHelper.skipTrigger = true;
        ServiceArea__c serviceArea = TestHelper.getServiceArea(true);
        AnnouncementTriggerHelper.skipTrigger = true;
        //ApplicationTriggerHelper.skipTrigger = true;
        
        TaskTriggerHelper.skipTrigger = true;
        Announcement__c announcement = TestHelper.getAnnouncement(true);
        Application__c application = TestHelper.getApplication(announcement.Id, true);

        Account account1 = TestHelper.getAccount(true);
        Id recTypeIdRec = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Recipient').getRecordTypeId();
        account1.RecordTypeId = recTypeIdRec;
        update account1;

        List<Contact> contacts = new List<Contact>();

        Contact c = new Contact(Firstname='TestName', Lastname='TestLastName',Email='Testemail@email.com', 
                                                Title='Title',Phone ='123-123-1234');
        
        Contact c1 = new Contact(Firstname='Sample1', Lastname='Sample2',Email='Sample2@email.com', 
                                                AccountId=account1.Id,Title='SampleTitle',Phone ='321-321-4321');
              

              contacts.add(c);
              contacts.add(c1);

              insert contacts;
              GrantTriggerHelper.skipTrigger = true;

        Grant__c grant = TestHelper.getGrant(true);

        List<BudgetPeriod__c> budgetPeriods = new List<BudgetPeriod__c>();

        BudgetPeriod__c budgetPeriod1 = new BudgetPeriod__c(BudgetStartDate__c=System.today(),
                                                            BudgetEndDate__c=System.today(),
                                                            SequenceNumber__c=1.0,
                                                            Grant__c=grant.Id);
        

        BudgetPeriod__c budgetPeriod2 = new BudgetPeriod__c(BudgetStartDate__c=System.today(),
                                                            BudgetEndDate__c=System.today(),
                                                            SequenceNumber__c=2.0,
                                                            Grant__c=grant.Id);

        BudgetPeriod__c budgetPeriod = new BudgetPeriod__c(BudgetStartDate__c=System.today(),
                                                                                                   BudgetEndDate__c=System.today(),Grant__c=grant.Id,
                                                                                                   Status__c='Open',Notes__c='test');

        budgetPeriods.add(budgetPeriod1);
        budgetPeriods.add(budgetPeriod2);
        budgetPeriods.add(budgetPeriod);

        insert budgetPeriods;

        AwardTriggerHelper.skipTrigger = true;        

        Award__c awd = TestHelper.getAwards(grant.Id,true);
        awd.TotalObligateAmount__c = 10000.00;
        awd.GrantAwardName__c = 'Test Award Name';
        awd.FederalGrantAwardIdFAIN__c= 'Test';
        awd.CFDANumber__c='Test';
        awd.AwardType__c='New';
        awd.FederalAssistanceType__c='New Test';
        awd.AwardIssueDate__c=system.today();
        awd.BudgetPeriod__c = budgetPeriod.Id;
        awd.IsStateMatchRequired__c = false;
        awd.HaveYouAcceptedTheAward__c = 'yes';
        awd.Application__c  = application.Id;
        awd.AmendmentType__c  = 'Test';
        awd.BudgetPeriodEndDate__c=system.today();
        awd.AmendedPurchaseOrderNumber__c = 'Test';
        awd.AwardedAmountthisAction__c = 5000.00;
        update awd;

        GrantContact__c awardContact = new GrantContact__c(Award__c=awd.Id,Contact__c=c.Id,Role__c='KeyPOC');
        insert awardContact;

        List<AwardBudgetCategory__c> awardBudgetCategories = new List<AwardBudgetCategory__c>();

        List<BudgetCategory__c> budgetCategories = TestHelper.getBudgetCategory(true);

        AwardBudgetCategory__c aBC1 = new AwardBudgetCategory__c(Award__c=awd.Id,
                                                                 BudgetCategory__c=budgetCategories[0].Id,
                                                                 BudgetPeriod__c=budgetPeriod1.Id,
                                                                 Amount1__c=29000.0);
        AwardBudgetCategory__c aBC2 = new AwardBudgetCategory__c(Award__c=awd.Id,
                                                                BudgetCategory__c=budgetCategories[1].Id,
                                                                BudgetPeriod__c=budgetPeriod2.Id,
                                                                Amount1__c= 1000.0);
        awardBudgetCategories.add(aBC1);
        awardBudgetCategories.add(aBC2);

        insert awardBudgetCategories;


        Id recordTypeId1 = TestHelper.getRecordType(Schema.Sobjecttype.AmendmentRequest__c,'Periodic/BP Renewal');
        AmendmentRequest__c amendmentRequest1 = new AmendmentRequest__c(RecordTypeId = recordTypeId1,
                                                                        Award__c=awd.Id,
                                                                        Purpose__c='Test Purpose',
                                                                        KeyContactChange__c=false,
                                                                        BudgetPeriodExtension__c=false,
                                                                        NewKeyPOC__c=c1.Id,BudgetPeriodChange__c=false,
                                                                        Impact__c='Test Impact',AmendmentContact__c=c.Id,
                                                                        NoCostExtension__c=true,
                                                                        NewBudgetPeriodEndDate__c=date.newInstance(2016,12,26));
        insert amendmentRequest1;

        Id recTypeId = TestHelper.getRecordType(Schema.SObjectType.RolesAndResponsibilities__c,'Amendment Request');

        List<RolesAndResponsibilities__c> rolesandResponsibilities = new List<RolesAndResponsibilities__c>();

        RolesAndResponsibilities__c rolesAndResponsibility1 = new RolesAndResponsibilities__c(RecordTypeId=recTypeId,
                                                                AmendmentRequest__c=amendmentRequest1.Id,
                                                                Name__c=u.Id,
                                                                BusinessRole__c='Program Approver');
        RolesAndResponsibilities__c rolesAndResponsibility2 = new RolesAndResponsibilities__c(RecordTypeId=recTypeId,
                                                                AmendmentRequest__c=amendmentRequest1.Id,
                                                                Name__c=u.Id,
                                                                BusinessRole__c='Fiscal Approver');
        RolesAndResponsibilities__c rolesAndResponsibility3 = new RolesAndResponsibilities__c(RecordTypeId=recTypeId,
                                                                AmendmentRequest__c=amendmentRequest1.Id,
                                                                Name__c=u.Id,
                                                                BusinessRole__c='Executive Approver');

        rolesandResponsibilities.add(rolesAndResponsibility1);
        rolesandResponsibilities.add(rolesAndResponsibility2);
        rolesandResponsibilities.add(rolesAndResponsibility3);
        RolesandResponsibilitiesTriggerHelper.skipTrigger = true;
        insert rolesandResponsibilities;
        
        Attachment att = new Attachment(Name='TestAttach',Body=Blob.valueOf('Test Attachment'),ParentId=amendmentRequest1.Id);
        insert att;
        Test.startTest();
               ApexPages.currentPage().getParameters().put('Id',amendmentRequest1.Id);

               String ns = AppUtils.getNamespacePrefix();
               GNT__PageLayoutConfig__c pageLayoutConfig =  TestHelper.getPageLayoutConfig(true,'AmendmentRequest__c');
               GNT.DynamicLayoutHolder layoutHolder = new GNT.DynamicLayoutHolder(pageLayoutConfig.id, amendmentRequest1.Id,true);


               DeepCloneAmendmentHelper deepCloneAmendmentHelper = new DeepCloneAmendmentHelper(layoutHolder);
               DeepCloneAmendmentHelper deepCloneAmendmentHelper1 = new DeepCloneAmendmentHelper();
               Apexpages.Standardcontroller sc = new ApexPages.StandardController(amendmentRequest1);
               DeepCloneAmendmentHelper deepCloneAmendmentHelper2 = new DeepCloneAmendmentHelper(sc);
               deepCloneAmendmentHelper.whenClicked();
           Test.stopTest();
       
       }
   }