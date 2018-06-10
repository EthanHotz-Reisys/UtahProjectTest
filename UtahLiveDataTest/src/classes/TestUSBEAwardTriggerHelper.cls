@isTest
private class TestUSBEAwardTriggerHelper {

 //Shivankar: method to cover methods copyApplicationBudgetDetails() and moveAllTCToCurrentAward()
     static testMethod void testcopyApplicationBudgetDetails() {  
/*
        UserTriggerHelper.skipTrigger = true; 
        User u = TestHelper.getAdminUser(true);
        Test.startTest();
        system.runAs(u){
            TermConditionTriggerHelper.skipTrigger=true;
            PaymentRequestTriggerHelper.skipTrigger=true;
            ProgressReportsTriggerHelper.skipTrigger=true;
            SiteVisitTriggerHelper.skipTrigger=true;
            AwardBudgetCategoryTriggerHelper.skipTrigger=true;
            AnnouncementTriggerHelper.skipTrigger = true;
            AccountTriggerhelper.skipTrigger=true;
            ApplicationtriggerHelper.skiptrigger = true;
            ServiceAreaTriggerHelper.skiptrigger = true;
            ProgramTriggerHelper.skipTrigger=true;
            RolesandResponsibilitiesTriggerHelper.skipTrigger = true;
            GranttriggerHelper.skipTrigger = true;
            User u1=TestHelper.getPortalUser(true);
            Contact c = TestHelper.getcontact(false);
            c.UserReference__c=u1.id;
            insert c;
        
            
            Account acc=TestHelper.getAccount(false);
            acc.name='USBE';
            insert acc;

            Program__c prog=TestHelper.getProgram(acc.Id,true);
            prog.BuildupFunctionalityNeeded__c='Yes';
            update prog;

            Announcement__c ann = TestHelper.getAnnouncement(prog.id,true);
            ann.DetailedBudgetingRequired__c='Yes';
            ann.FinancialApprover__c=u1.id;
            update ann;

            Application__c app = TestHelper.getApplication(ann.Id,true);
            app.IndirectCostPercentage__c=5;
            app.AmountThisAction__c=1000;
            update app;

            BudgetPeriod__c budPeriod = new BudgetPeriod__c();
            budPeriod.BudgetStartDate__c = System.Today() - 7;
            budPeriod.BudgetEndDate__c = System.today() + 358;
            insert budPeriod;


            ServiceArea__c sva=TestHelper.getServiceArea(true);
            ApplicationServiceArea__c asva=new ApplicationServiceArea__c();
            asva.ServiceAreaLookup__c=sva.Id;
            asva.Application__c=app.Id;
            Insert asva;

            Id recordTypeId = TestHelper.getRecordType(Schema.Sobjecttype.BudgetCategory__c, 'External');
            BudgetCategory__c bc = new BudgetCategory__c(RecordTypeId = recordTypeId,
                                            Name='Total Indirect Costs (Applies to Lines 1-7):',
                                            CategoryDescription__c='Total Indirect Costs (Applies to Lines 1-7):');
             insert bc;
           
            ApplicationBudgetCategory2__c abc2=new ApplicationBudgetCategory2__c(BudgetCategory__c=bc.id,Amount__c=123456.0,
            BudgetAmountUSBE__c=45678.0,IsFirstBudgetPeriodRelated__c = true, AdminCostValue__c=111111.0);
            abc2.ServiceArea__c=asva.Id;
            abc2.Application__c=app.Id;
            insert abc2;

            BuildUpItem__c buildUpItem=new BuildUpItem__c(Title__c='test', Narrative__c='test', StartDate__c=System.today(), 
                EndDate__c=System.today()+1, ApplicationBudgetCategory__c=abc2.Id,UnitPrice__c=10, Quantity__c=100, 
                UnitofMeasurement__c='Gallons', OtherCharges__c=1000,AllowableDirect__c=500 , Indirect__c=10, 
                GrantorShare__c=25,EquipmentDesc__c='test description',name__c='test',TotalHours__c=10,RequestedHours__c=10,
                  HourlyRate__c=10,SourceType__c='Federal',ListBenefitType__c='test',FBTotalSalary__c=1000,Benefit__c =20,
                  TravelDestination__c='New York',TravelPurpose__c='test',TravelTotalMiles__c=1000,TravelMileRate__c=1000,
                  EquipmentVAWAUse__c=10,CSCType__c='test',CFTotalHours__c=100,CFRate__c=10,NumberofDays__c=10,
                  HotelFees__c=1000,PerDiem__c=1000,RegistrationPerPerson__c=100,NumberAttending__c=10);
                insert buildUpItem;


           
            Grant__c grant = new Grant__c();
            grant.GranteePOC__c=u1.Id;
            grant.ExternalOrganization__c=acc.Id;
            grant.ProjectPeriodStartDate__c=Date.newInstance(2015,3,14);
            grant.Application__c=app.Id;
            grant.ProjectPeriodEndDate__c=Date.newInstance(2016,3,14);
            grant.IssueDate__c=Date.newInstance(2015,2,14);
            grant.Program__c=prog.Id;
            grant.GranteePOC__c = u.id;
            grant.IsTCScheduleCreated__c=true;
            insert grant;
            GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c', 'StateasGrantor');


             RolesAndResponsibilities__c rolesAndResponsibilities = new RolesAndResponsibilities__c(Announcement__c=ann.id,Program__c = prog.Id,
                                                                        BusinessRole__c='Fiscal Approver');
             insert rolesAndResponsibilities;
         
            Award__c aw  = TestHelper.getAwards(grant.Id,false);
            aw.Grant__c=grant.Id;
            aw.BudgetPeriod__c=budPeriod.Id;
            aw.BudgetNarrativeRead__c='test text';
            aw.Name = Math.Random()+'AW12';
            aw.OrganizationName__c = 'USBE';
            aw.OrganizationAddress__c = 'Test Address';
            aw.FiscalYear__c = '2013';
            aw.SupportYear__c = Decimal.valueOf('2013');
            aw.Status__c = 'Activated';
            aw.Application__c=app.Id;
            aw.AwardedAmountthisAction__c = 10000.00;
            aw.TotalObligateAmount__c = 100000.00;
            aw.DeepCloned__c = true;
            aw.Announcement__c=ann.Id;
            insert aw;

           //To get coverage for method moveAllTCToCurrentAward() in USBEAwardTriggerhelper class
          
            Termcondition__c tnc=TestHelper.getTermCondition(false,'Term');
            tnc.Award__c=aw.id;
            insert tnc;

            PaymentRequest__c pr=TestHelper.getPaymentRequest(false);
            pr.Award__c=aw.id;
            insert pr;

            SiteVisit__c sv = new SiteVisit__c(Status__c='Approved', Grant__c=grant.Id, 
            SiteVisitor__c=UserInfo.getUserId(), VisitDateandTime__c=DateTime.now() - 5, VisitEndDateTime__c = DateTime.now());

              insert sv;

            ProgressReports__c  progrep=new ProgressReports__c();
            progrep.Award__c=aw.id;
            progrep.TermandCondition__c=tnc.Id;
            insert progrep;

            //GrantContact__c gc=new GrantContact__c(Award__c=aw.id,Contact__c=c.id,);
            //insert gc;
           
            //List<Id> awardList=new List<Id>();
            //awardList.add(aw.id);
            //insert awardList;

            //USBEAwardTriggerHelper.waiveAllocationRejectedTaskReset(awardList);


            update aw;

            //To get coverage for method prepareProgressReportSiteVisitPaymentSchedule() in USBEAwardTriggerhelper class
            tnc=TestHelper.getTermCondition(true,'Site Visit');
            tnc.Frequency__c='Fixed';
            update tnc;
            grant.IsTCScheduleCreated__c=false;
            update grant;
            update aw;
            


        }
        Test.stopTest();
        */
     } 

    static testMethod void TestcreateGranteeBudgetCategories(){
/*
        UserTriggerHelper.skipTrigger = true; 
        User u = TestHelper.getAdminUser(true);
        //Contact c = TestHelper.getcontact(true);
        Test.startTest();
        system.runAs(u){
            BuildUpItemTriggerHelper.skiptrigger=true;
            TermConditionTriggerHelper.skipTrigger=true;
            PaymentRequestTriggerHelper.skipTrigger=true;
            ProgressReportsTriggerHelper.skipTrigger=true;
            SiteVisitTriggerHelper.skipTrigger=true;
            AwardBudgetCategoryTriggerHelper.skipTrigger=true;
            AnnouncementTriggerHelper.skipTrigger = true;
            AccountTriggerhelper.skipTrigger=true;
            ApplicationtriggerHelper.skiptrigger = true;
            ServiceAreaTriggerHelper.skiptrigger = true;
            ProgramTriggerHelper.skipTrigger=true;
            RolesandResponsibilitiesTriggerHelper.skipTrigger = true;
            GranttriggerHelper.skipTrigger = true;
            User u1=TestHelper.getPortalUser(true);
            Contact c = TestHelper.getcontact(false);
            c.UserReference__c=u1.id;
            insert c;
            
            Account acc=TestHelper.getAccount(false);
            acc.name='USBE';
            insert acc;

            Program__c prog=TestHelper.getProgram(acc.Id,true);
            prog.BuildupFunctionalityNeeded__c='Yes';
            update prog;

            Announcement__c ann = TestHelper.getAnnouncement(prog.id,true);
            ann.DetailedBudgetingRequired__c='Yes';
            ann.FinancialApprover__c=u1.id;
            update ann;

            Application__c app = TestHelper.getApplication(ann.Id,true);
            app.IndirectCostPercentage__c=5;
            app.AmountThisAction__c=1000;
            update app;

            BudgetPeriod__c budPeriod = new BudgetPeriod__c();
            budPeriod.BudgetStartDate__c = System.Today() - 7;
            budPeriod.BudgetEndDate__c = System.today() + 358;
            budPeriod.SequenceNumber__c = 1.0;

            insert budPeriod;

            ServiceArea__c sva=TestHelper.getServiceArea(true);
            ApplicationServiceArea__c asva=new ApplicationServiceArea__c();
            asva.ServiceAreaLookup__c=sva.Id;
            asva.Application__c=app.Id;
            Insert asva;

            Id recordTypeId = TestHelper.getRecordType(Schema.Sobjecttype.BudgetCategory__c, 'External');
            BudgetCategory__c bc = new BudgetCategory__c(RecordTypeId = recordTypeId,Class__c = 'Construction',
                                            Name='Total Indirect Costs (Applies to Lines 1-7):',
                                            CategoryDescription__c='Total Indirect Costs (Applies to Lines 1-7):');
             insert bc;
           
            ApplicationBudgetCategory2__c abc2=new ApplicationBudgetCategory2__c(BudgetCategory__c=bc.id,Amount__c=123456.0,
            BudgetAmountUSBE__c=45678.0,IsFirstBudgetPeriodRelated__c = true, AdminCostValue__c=111111.0);
            abc2.BudgetPeriod__c=budPeriod.Id;
            abc2.ServiceArea__c=asva.Id;
            abc2.Application__c=app.Id;
            insert abc2;

            BuildUpItem__c buildUpItem=new BuildUpItem__c(Title__c='test', Narrative__c='test', StartDate__c=System.today(), 
                EndDate__c=System.today()+1, ApplicationBudgetCategory__c=abc2.Id,UnitPrice__c=10, Quantity__c=100, 
                UnitofMeasurement__c='Gallons', OtherCharges__c=1000,AllowableDirect__c=500 , Indirect__c=10, 
                GrantorShare__c=25,EquipmentDesc__c='test description',name__c='test',TotalHours__c=10,RequestedHours__c=10,
                  HourlyRate__c=10,SourceType__c='Federal',ListBenefitType__c='test',FBTotalSalary__c=1000,Benefit__c =20,
                  TravelDestination__c='New York',TravelPurpose__c='test',TravelTotalMiles__c=1000,TravelMileRate__c=1000,
                  EquipmentVAWAUse__c=10,CSCType__c='test',CFTotalHours__c=100,CFRate__c=10,NumberofDays__c=10,
                  HotelFees__c=1000,PerDiem__c=1000,RegistrationPerPerson__c=100,NumberAttending__c=10);
                insert buildUpItem;


           
            Grant__c grant = new Grant__c();
            grant.GranteePOC__c=u1.Id;
            grant.ExternalOrganization__c=acc.Id;
            grant.ProjectPeriodStartDate__c=Date.newInstance(2015,3,14);
            grant.Application__c=app.Id;
            grant.ProjectPeriodEndDate__c=Date.newInstance(2016,3,14);
            grant.IssueDate__c=Date.newInstance(2015,2,14);
            grant.Program__c=prog.Id;
            grant.GranteePOC__c = u.id;
            grant.IsTCScheduleCreated__c=true;
            insert grant;
            GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c', 'StateasGrantee');



         
            Award__c aw  = TestHelper.getAwards(grant.Id,false);
            aw.Grant__c=grant.Id;
            aw.BudgetPeriod__c=budPeriod.Id;
            aw.BudgetNarrativeRead__c='test text';
            aw.Name = Math.Random()+'AW12';
            aw.OrganizationName__c = 'USBE';
            aw.OrganizationAddress__c = 'Test Address';
            aw.FiscalYear__c = '2013';
            aw.SupportYear__c = Decimal.valueOf('2013');
            aw.Status__c = 'Activated';
            aw.Application__c=app.Id;
            aw.AwardedAmountthisAction__c = 10000.00;
            aw.TotalObligateAmount__c = 100000.00;
            aw.DeepCloned__c = true;
            aw.Announcement__c=ann.Id;
            insert aw;

            Termcondition__c tnc=TestHelper.getTermCondition(false,'Term');
            tnc.Award__c=aw.id;
            insert tnc;

            PaymentRequest__c pr=TestHelper.getPaymentRequest(false);
            pr.Award__c=aw.id;
            insert pr;

            SiteVisit__c sv = new SiteVisit__c(Status__c='Approved', Grant__c=grant.Id, 
            SiteVisitor__c=UserInfo.getUserId(), VisitDateandTime__c=DateTime.now() - 5, VisitEndDateTime__c = DateTime.now());

             insert sv;

            ProgressReports__c  progrep=new ProgressReports__c();
            progrep.Award__c=aw.id;
            progrep.TermandCondition__c=tnc.Id;
            insert progrep;

            aw.Status__c = 'Approved';
            aw.IndirectCostRateDecision__c = 'Implicit';


            update aw;


            grant.Application__c=null;
            grant.TypeOfBudgetCategories__c = 'Construction';
            update grant;

            GrantServiceArea__c grantServiceArea = new GrantServiceArea__c();
            grantServiceArea.ServiceArea__c = sva.Id;
            grantServiceArea.Grant__c = grant.Id;
            insert grantServiceArea;


            grant.Application__c=null;
            update grant;
            Award__c aw1  = TestHelper.getAwards(grant.Id,false);
            aw1.Grant__c=grant.Id;
            aw1.BudgetPeriod__c=budPeriod.Id;
            aw1.BudgetNarrativeRead__c='test text';
            aw1.Name = Math.Random()+'AW12';
            aw1.OrganizationName__c = 'USBE';
            aw1.OrganizationAddress__c = 'Test Address';
            aw1.FiscalYear__c = '2013';
            aw1.SupportYear__c = Decimal.valueOf('2013');
            aw1.Status__c = 'Activated';
            aw1.AwardedAmountthisAction__c = 10000.00;
            aw1.TotalObligateAmount__c = 100000.00;
            aw1.DeepCloned__c = true;
            aw1.Announcement__c=ann.Id;
            insert aw1;
        }
        Test.stopTest();
*/
     }

     static testMethod void TestAwardDeletion(){
/*
        UserTriggerHelper.skipTrigger = true; 
        User u = TestHelper.getAdminUser(true);
        //Contact c = TestHelper.getcontact(true);
        Test.startTest();
        system.runAs(u){
            BuildUpItemTriggerHelper.skiptrigger=true;
            TermConditionTriggerHelper.skipTrigger=true;
            PaymentRequestTriggerHelper.skipTrigger=true;
            ProgressReportsTriggerHelper.skipTrigger=true;
            SiteVisitTriggerHelper.skipTrigger=true;
            AwardBudgetCategoryTriggerHelper.skipTrigger=true;
            AnnouncementTriggerHelper.skipTrigger = true;
            AccountTriggerhelper.skipTrigger=true;
            ApplicationtriggerHelper.skiptrigger = true;
            ServiceAreaTriggerHelper.skiptrigger = true;
            ProgramTriggerHelper.skipTrigger=true;
            RolesandResponsibilitiesTriggerHelper.skipTrigger = true;
            GranttriggerHelper.skipTrigger = true;
            User u1=TestHelper.getPortalUser(true);
            Contact c = TestHelper.getcontact(false);
            c.UserReference__c=u1.id;
            insert c;
            
            Account acc=TestHelper.getAccount(false);
            acc.name='USBE';
            insert acc;

            Program__c prog=TestHelper.getProgram(acc.Id,true);
            prog.BuildupFunctionalityNeeded__c='Yes';
            update prog;

            Announcement__c ann = TestHelper.getAnnouncement(prog.id,true);
            ann.DetailedBudgetingRequired__c='Yes';
            ann.FinancialApprover__c=u1.id;
            update ann;

            Application__c app = TestHelper.getApplication(ann.Id,true);
            app.IndirectCostPercentage__c=5;
            app.AmountThisAction__c=1000;
            update app;

            BudgetPeriod__c budPeriod = new BudgetPeriod__c();
            budPeriod.BudgetStartDate__c = System.Today() - 7;
            budPeriod.BudgetEndDate__c = System.today() + 358;
            budPeriod.SequenceNumber__c = 1.0;

            insert budPeriod;

            ServiceArea__c sva=TestHelper.getServiceArea(true);
            ApplicationServiceArea__c asva=new ApplicationServiceArea__c();
            asva.ServiceAreaLookup__c=sva.Id;
            asva.Application__c=app.Id;
            Insert asva;

            Id recordTypeId = TestHelper.getRecordType(Schema.Sobjecttype.BudgetCategory__c, 'External');
            BudgetCategory__c bc = new BudgetCategory__c(RecordTypeId = recordTypeId,Class__c = 'Construction',
                                            Name='Total Indirect Costs (Applies to Lines 1-7):',
                                            CategoryDescription__c='Total Indirect Costs (Applies to Lines 1-7):');
             insert bc;
           
            ApplicationBudgetCategory2__c abc2=new ApplicationBudgetCategory2__c(BudgetCategory__c=bc.id,Amount__c=123456.0,
            BudgetAmountUSBE__c=45678.0,IsFirstBudgetPeriodRelated__c = true, AdminCostValue__c=111111.0);
            abc2.BudgetPeriod__c=budPeriod.Id;
            abc2.ServiceArea__c=asva.Id;
            abc2.Application__c=app.Id;
            insert abc2;

            BuildUpItem__c buildUpItem=new BuildUpItem__c(Title__c='test', Narrative__c='test', StartDate__c=System.today(), 
                EndDate__c=System.today()+1, ApplicationBudgetCategory__c=abc2.Id,UnitPrice__c=10, Quantity__c=100, 
                UnitofMeasurement__c='Gallons', OtherCharges__c=1000,AllowableDirect__c=500 , Indirect__c=10, 
                GrantorShare__c=25,EquipmentDesc__c='test description',name__c='test',TotalHours__c=10,RequestedHours__c=10,
                  HourlyRate__c=10,SourceType__c='Federal',ListBenefitType__c='test',FBTotalSalary__c=1000,Benefit__c =20,
                  TravelDestination__c='New York',TravelPurpose__c='test',TravelTotalMiles__c=1000,TravelMileRate__c=1000,
                  EquipmentVAWAUse__c=10,CSCType__c='test',CFTotalHours__c=100,CFRate__c=10,NumberofDays__c=10,
                  HotelFees__c=1000,PerDiem__c=1000,RegistrationPerPerson__c=100,NumberAttending__c=10);
                insert buildUpItem;


           
            Grant__c grant = new Grant__c();
            grant.GranteePOC__c=u1.Id;
            grant.ExternalOrganization__c=acc.Id;
            grant.ProjectPeriodStartDate__c=Date.newInstance(2015,3,14);
            grant.Application__c=app.Id;
            grant.ProjectPeriodEndDate__c=Date.newInstance(2016,3,14);
            grant.IssueDate__c=Date.newInstance(2015,2,14);
            grant.Program__c=prog.Id;
            grant.GranteePOC__c = u.id;
            grant.IsTCScheduleCreated__c=true;
            insert grant;
            GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c', 'StateasGrantee');



         
            Award__c aw  = TestHelper.getAwards(grant.Id,false);
            aw.Grant__c=grant.Id;
            aw.BudgetPeriod__c=budPeriod.Id;
            aw.BudgetNarrativeRead__c='test text';
            aw.Name = Math.Random()+'AW12';
            aw.OrganizationName__c = 'USBE';
            aw.OrganizationAddress__c = 'Test Address';
            aw.FiscalYear__c = '2013';
            aw.SupportYear__c = Decimal.valueOf('2013');
            aw.Status__c = 'Activated';
            aw.Application__c=app.Id;
            aw.AwardedAmountthisAction__c = 10000.00;
            aw.TotalObligateAmount__c = 100000.00;
            aw.DeepCloned__c = true;
            aw.Announcement__c=ann.Id;
            insert aw;

            delete aw;



            Award__c aw1  = TestHelper.getAwards(grant.Id,false);
            aw1.Grant__c=grant.Id;
            aw1.BudgetPeriod__c=budPeriod.Id;
            aw1.BudgetNarrativeRead__c='test text';  
            aw1.Name = Math.Random()+'AW12';
            aw1.OrganizationName__c = 'USBE';
            aw1.OrganizationAddress__c = 'Test Address';
            aw1.FiscalYear__c = '2013';
            aw1.SupportYear__c = Decimal.valueOf('2013');
            aw1.Status__c = 'Issued';
            aw1.Application__c=app.Id;
            aw1.AwardedAmountthisAction__c = 10000.00;
            aw1.TotalObligateAmount__c = 100000.00;
            aw1.DeepCloned__c = true;
            aw1.Announcement__c=ann.Id;
            insert aw1;

            AmendmentRequest__c amreq=new AmendmentRequest__c(Status__c='Completed',Impact__c='test',Purpose__c='test',Award__c=aw1.id);
            insert amreq;
            //test 

            delete aw1;

        }
        Test.stopTest();
*/
     }
     
     static testMethod void TestinsertAwardBudgetCategoriesFromProgramWithSericeArea(){
/*
        UserTriggerHelper.skipTrigger = true; 
        User u = TestHelper.getAdminUser(true);
        //Contact c = TestHelper.getcontact(true);
        Test.startTest();
        system.runAs(u){
            BuildUpItemTriggerHelper.skiptrigger=true;
            TermConditionTriggerHelper.skipTrigger=true;
            PaymentRequestTriggerHelper.skipTrigger=true;
            ProgressReportsTriggerHelper.skipTrigger=true;
            SiteVisitTriggerHelper.skipTrigger=true;
            AwardBudgetCategoryTriggerHelper.skipTrigger=true;
            AnnouncementTriggerHelper.skipTrigger = true;
            AccountTriggerhelper.skipTrigger=true;
            ApplicationtriggerHelper.skiptrigger = true;
            ServiceAreaTriggerHelper.skiptrigger = true;
            ProgramTriggerHelper.skipTrigger=true;
            RolesandResponsibilitiesTriggerHelper.skipTrigger = true;
            GranttriggerHelper.skipTrigger = true;
            User u1=TestHelper.getPortalUser(true);
            Contact c = TestHelper.getcontact(false);
            c.UserReference__c=u1.id;
            insert c;
            
            Account acc=TestHelper.getAccount(false);
            acc.name='USBE';
            insert acc;

            Program__c prog=TestHelper.getProgram(acc.Id,true);
            prog.BuildupFunctionalityNeeded__c='Yes';
            update prog;

            Announcement__c ann = TestHelper.getAnnouncement(prog.id,true);
            ann.DetailedBudgetingRequired__c='Yes';
            ann.FinancialApprover__c=u1.id;
            update ann;

            Application__c app = TestHelper.getApplication(ann.Id,true);
            app.IndirectCostPercentage__c=5;
            app.AmountThisAction__c=1000;
            update app;

            BudgetPeriod__c budPeriod = new BudgetPeriod__c();
            budPeriod.BudgetStartDate__c = System.Today() - 7;
            budPeriod.BudgetEndDate__c = System.today() + 358;
            budPeriod.SequenceNumber__c = 1.0;

            insert budPeriod;

            ServiceArea__c sva=TestHelper.getServiceArea(true);
            ApplicationServiceArea__c asva=new ApplicationServiceArea__c();
            asva.ServiceAreaLookup__c=sva.Id;
            asva.Application__c=app.Id;
            Insert asva;




            Id recordTypeId = TestHelper.getRecordType(Schema.Sobjecttype.BudgetCategory__c, 'External');
            BudgetCategory__c bc = new BudgetCategory__c(RecordTypeId = recordTypeId,Class__c = 'Construction',
                                            Name='Total Indirect Costs (Applies to Lines 1-7):',
                                            CategoryDescription__c='Total Indirect Costs (Applies to Lines 1-7):');
             insert bc;
           
            ProgramServiceArea__c programServiceArea = new ProgramServiceArea__c( Program__c=prog.Id, ServiceArea__c=sva.Id);
            ProgramBudgetCategory__c programBudgetCategory = new ProgramBudgetCategory__c(Program__c=prog.id, BudgetCategory__c=bc.id); 
            insert programServiceArea;
            insert programBudgetCategory;

            ApplicationBudgetCategory2__c abc2=new ApplicationBudgetCategory2__c(BudgetCategory__c=bc.id,Amount__c=123456.0,
            BudgetAmountUSBE__c=45678.0,IsFirstBudgetPeriodRelated__c = true, AdminCostValue__c=111111.0);
            abc2.BudgetPeriod__c=budPeriod.Id;
            abc2.ServiceArea__c=asva.Id;
            abc2.Application__c=app.Id;
            insert abc2;

            BuildUpItem__c buildUpItem=new BuildUpItem__c(Title__c='test', Narrative__c='test', StartDate__c=System.today(), 
                EndDate__c=System.today()+1, ApplicationBudgetCategory__c=abc2.Id,UnitPrice__c=10, Quantity__c=100, 
                UnitofMeasurement__c='Gallons', OtherCharges__c=1000,AllowableDirect__c=500 , Indirect__c=10, 
                GrantorShare__c=25,EquipmentDesc__c='test description',name__c='test',TotalHours__c=10,RequestedHours__c=10,
                  HourlyRate__c=10,SourceType__c='Federal',ListBenefitType__c='test',FBTotalSalary__c=1000,Benefit__c =20,
                  TravelDestination__c='New York',TravelPurpose__c='test',TravelTotalMiles__c=1000,TravelMileRate__c=1000,
                  EquipmentVAWAUse__c=10,CSCType__c='test',CFTotalHours__c=100,CFRate__c=10,NumberofDays__c=10,
                  HotelFees__c=1000,PerDiem__c=1000,RegistrationPerPerson__c=100,NumberAttending__c=10);
                insert buildUpItem;


           
            Grant__c grant = new Grant__c();
            grant.GranteePOC__c=u1.Id;
            grant.ExternalOrganization__c=acc.Id;
            grant.ProjectPeriodStartDate__c=Date.newInstance(2015,3,14);
            grant.Application__c=app.Id;
            grant.ProjectPeriodEndDate__c=Date.newInstance(2016,3,14);
            grant.IssueDate__c=Date.newInstance(2015,2,14);
            grant.Program__c=prog.Id;
            grant.GranteePOC__c = u.id;
            grant.IsTCScheduleCreated__c=true;
            insert grant;
            GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c', 'StateasGrantor');


            grant.Application__c=null;
            grant.TypeOfBudgetCategories__c = 'Construction';
            update grant;

            GrantServiceArea__c grantServiceArea = new GrantServiceArea__c();
            grantServiceArea.ServiceArea__c = sva.Id;
            grantServiceArea.Grant__c = grant.Id;
            insert grantServiceArea;

            //For covering updateAddress() method in USBEAwardTriggerHelper class
            USDemographicInfo__c USDemographicInfo = new USDemographicInfo__c(StateName__c='test', PrimaryCity__c='test', County__c='test',
                                       CongressionalDistrict__c='test');
            insert USDemographicInfo;


            Award__c aw1  = TestHelper.getAwards(grant.Id,false);
            aw1.zipcode__c=USDemographicInfo.Id;
            aw1.Application__c=app.Id;
            aw1.Grant__c=grant.Id;
            aw1.BudgetPeriod__c=budPeriod.Id;
            aw1.BudgetNarrativeRead__c='test text';
            aw1.Name = Math.Random()+'AW12';
            aw1.OrganizationName__c = 'USBE';
            aw1.OrganizationAddress__c = 'Test Address';
            aw1.FiscalYear__c = '2013';
            aw1.SupportYear__c = Decimal.valueOf('2013');
            aw1.Status__c = 'Activated';
            aw1.AwardedAmountthisAction__c = 10000.00;
            aw1.TotalObligateAmount__c = 100000.00;
            aw1.DeepCloned__c = true;
            aw1.Announcement__c=ann.id;
            insert aw1;
        }
        Test.stopTest();
*/
     }

static testMethod void TestreviseBudgetForAllocationChange(){
/*
        UserTriggerHelper.skipTrigger = true; 
        User u = TestHelper.getAdminUser(true);
        //Contact c = TestHelper.getcontact(true);
        Test.startTest();
        system.runAs(u){
            BuildUpItemTriggerHelper.skiptrigger=true;
            TermConditionTriggerHelper.skipTrigger=true;
            PaymentRequestTriggerHelper.skipTrigger=true;
            ProgressReportsTriggerHelper.skipTrigger=true;
            SiteVisitTriggerHelper.skipTrigger=true;
            AwardBudgetCategoryTriggerHelper.skipTrigger=true;
            AnnouncementTriggerHelper.skipTrigger = true;
            AccountTriggerhelper.skipTrigger=true;
            ApplicationtriggerHelper.skiptrigger = true;
            ServiceAreaTriggerHelper.skiptrigger = true;
            ProgramTriggerHelper.skipTrigger=true;
            RolesandResponsibilitiesTriggerHelper.skipTrigger = true;
            GranttriggerHelper.skipTrigger = true;
            GrantContactTriggerHelper.skipTrigger = true;
            User u1=TestHelper.getPortalUser(true);
            Contact c = TestHelper.getcontact(false);
            c.UserReference__c=u1.id;
            insert c;
            
            Account acc=TestHelper.getAccount(false);
            acc.name='USBE';
            insert acc;

            Program__c prog=TestHelper.getProgram(acc.Id,true);
            prog.BuildupFunctionalityNeeded__c='Yes';
            update prog;

            Announcement__c ann = TestHelper.getAnnouncement(prog.id,true);
            ann.DetailedBudgetingRequired__c='Yes';
            ann.FinancialApprover__c=u1.id;
            update ann;

            Application__c app = TestHelper.getApplication(ann.Id,true);
            app.IndirectCostPercentage__c=5;
            app.AmountThisAction__c=1000;
            update app;

            BudgetPeriod__c budPeriod = new BudgetPeriod__c();
            budPeriod.BudgetStartDate__c = System.Today() - 7;
            budPeriod.BudgetEndDate__c = System.today() + 358;
            budPeriod.SequenceNumber__c = 1.0;

            insert budPeriod;

            ServiceArea__c sva=TestHelper.getServiceArea(true);
            ApplicationServiceArea__c asva=new ApplicationServiceArea__c();
            asva.ServiceAreaLookup__c=sva.Id;
            asva.Application__c=app.Id;
            Insert asva;




            Id recordTypeId = TestHelper.getRecordType(Schema.Sobjecttype.BudgetCategory__c, 'External');
            BudgetCategory__c bc = new BudgetCategory__c(RecordTypeId = recordTypeId,Class__c = 'Construction',
                                            Name='Total Indirect Costs (Applies to Lines 1-7):',
                                            CategoryDescription__c='Total Indirect Costs (Applies to Lines 1-7):');
             insert bc;
           
            ProgramServiceArea__c programServiceArea = new ProgramServiceArea__c( Program__c=prog.Id, ServiceArea__c=sva.Id);
            ProgramBudgetCategory__c programBudgetCategory = new ProgramBudgetCategory__c(Program__c=prog.id, BudgetCategory__c=bc.id); 
            insert programServiceArea;
            insert programBudgetCategory;

            ApplicationBudgetCategory2__c abc2=new ApplicationBudgetCategory2__c(BudgetCategory__c=bc.id,Amount__c=123456.0,
            BudgetAmountUSBE__c=45678.0,IsFirstBudgetPeriodRelated__c = true, AdminCostValue__c=111111.0);
            abc2.BudgetPeriod__c=budPeriod.Id;
            abc2.ServiceArea__c=asva.Id;
            abc2.Application__c=app.Id;
            insert abc2;

            BuildUpItem__c buildUpItem=new BuildUpItem__c(Title__c='test', Narrative__c='test', StartDate__c=System.today(), 
                EndDate__c=System.today()+1, ApplicationBudgetCategory__c=abc2.Id,UnitPrice__c=10, Quantity__c=100, 
                UnitofMeasurement__c='Gallons', OtherCharges__c=1000,AllowableDirect__c=500 , Indirect__c=10, 
                GrantorShare__c=25,EquipmentDesc__c='test description',name__c='test',TotalHours__c=10,RequestedHours__c=10,
                  HourlyRate__c=10,SourceType__c='Federal',ListBenefitType__c='test',FBTotalSalary__c=1000,Benefit__c =20,
                  TravelDestination__c='New York',TravelPurpose__c='test',TravelTotalMiles__c=1000,TravelMileRate__c=1000,
                  EquipmentVAWAUse__c=10,CSCType__c='test',CFTotalHours__c=100,CFRate__c=10,NumberofDays__c=10,
                  HotelFees__c=1000,PerDiem__c=1000,RegistrationPerPerson__c=100,NumberAttending__c=10);
                insert buildUpItem;


           
            Grant__c grant = new Grant__c();
            grant.GranteePOC__c=u1.Id;
            grant.ExternalOrganization__c=acc.Id;
            grant.ProjectPeriodStartDate__c=Date.newInstance(2015,3,14);
            grant.Application__c=app.Id;
            grant.ProjectPeriodEndDate__c=Date.newInstance(2016,3,14);
            grant.IssueDate__c=Date.newInstance(2015,2,14);
            grant.Program__c=prog.Id;
            grant.GranteePOC__c = u.id;
            grant.IsTCScheduleCreated__c=true;
            insert grant;
            GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c', 'StateasGrantor');


            grant.Application__c=null;
            grant.TypeOfBudgetCategories__c = 'Construction';
            update grant;

            GrantServiceArea__c grantServiceArea = new GrantServiceArea__c();
            grantServiceArea.ServiceArea__c = sva.Id;
            grantServiceArea.Grant__c = grant.Id;
            insert grantServiceArea;

            //For covering updateAddress() method in USBEAwardTriggerHelper class
            USDemographicInfo__c USDemographicInfo = new USDemographicInfo__c(StateName__c='test', PrimaryCity__c='test', County__c='test',
                                       CongressionalDistrict__c='test');
            insert USDemographicInfo;



             

            Award__c aw1  = TestHelper.getAwards(grant.Id,false);
            aw1.zipcode__c=USDemographicInfo.Id;
            aw1.Application__c=app.Id;
            aw1.Grant__c=grant.Id;
            aw1.BudgetPeriod__c=budPeriod.Id;
            aw1.BudgetNarrativeRead__c='test text';
            aw1.Name = Math.Random()+'AW12';
            aw1.OrganizationName__c = 'USBE';
            aw1.OrganizationAddress__c = 'Test Address';
            aw1.FiscalYear__c = '2013';
            aw1.SupportYear__c = Decimal.valueOf('2013');
            aw1.Status__c = 'Activated';
            aw1.AwardedAmountthisAction__c = 10000.00;
            aw1.TotalObligateAmount__c = 100000.00;
            aw1.DeepCloned__c = true;
            aw1.Announcement__c=ann.id;
            aw1.ObligatedAwardAmount__c=1000;
            //aw1.AwardedAmount__c=1000;
            aw1.WaiveAllocationStatus__c='N/A';
            insert aw1;



            GrantContact__c gc=new GrantContact__c(Award__c=aw1.id,Contact__c=c.id);
            insert gc;

            update aw1;

        }
        Test.stopTest();
*/
     }


    //Incomplete method: Due to issue with lookup field of user object in method createEmailAndTaskForBudgetRevision
    //
     static testMethod void TestcreateEmailAndTaskForBudgetRevision(){
/*
        UserTriggerHelper.skipTrigger = true; 
        User u = TestHelper.getAdminUser(true);
        //Contact c = TestHelper.getcontact(true);
        Test.startTest();
        system.runAs(u){
            BuildUpItemTriggerHelper.skiptrigger=true;
            TermConditionTriggerHelper.skipTrigger=true;
            PaymentRequestTriggerHelper.skipTrigger=true;
            ProgressReportsTriggerHelper.skipTrigger=true;
            SiteVisitTriggerHelper.skipTrigger=true;
            AwardBudgetCategoryTriggerHelper.skipTrigger=true;
            AnnouncementTriggerHelper.skipTrigger = true;
            AccountTriggerhelper.skipTrigger=true;
            ApplicationtriggerHelper.skiptrigger = true;
            ServiceAreaTriggerHelper.skiptrigger = true;
            ProgramTriggerHelper.skipTrigger=true;
            RolesandResponsibilitiesTriggerHelper.skipTrigger = true;
            GranttriggerHelper.skipTrigger = true;
            GrantContactTriggerHelper.skipTrigger = true;
            
            Account acc=TestHelper.getAccount(false);
            acc.name='USBE';
            insert acc;

            
            Contact c = TestHelper.getcontact(false);
            c.AccountId=acc.id;
           // c.UserReference__c=
            insert c;


           User u1=TestHelper.getPortalUser(true);

            
            //u1.ContactId=c.id;
            //update u1;
           

            c.UserReference__c=u1.id;
            update c;
           

            Program__c prog=TestHelper.getProgram(acc.Id,true);
            prog.BuildupFunctionalityNeeded__c='Yes';
            update prog;

            Announcement__c ann = TestHelper.getAnnouncement(prog.id,true);
            ann.DetailedBudgetingRequired__c='Yes';
            ann.FinancialApprover__c=u1.id;
            update ann;

            Application__c app = TestHelper.getApplication(ann.Id,true);
            app.IndirectCostPercentage__c=5;
            app.AmountThisAction__c=1000;
            update app;

            BudgetPeriod__c budPeriod = new BudgetPeriod__c();
            budPeriod.BudgetStartDate__c = System.Today() - 7;
            budPeriod.BudgetEndDate__c = System.today() + 358;
            budPeriod.SequenceNumber__c = 1.0;

            insert budPeriod;

            ServiceArea__c sva=TestHelper.getServiceArea(true);
            ApplicationServiceArea__c asva=new ApplicationServiceArea__c();
            asva.ServiceAreaLookup__c=sva.Id;
            asva.Application__c=app.Id;
            Insert asva;




            Id recordTypeId = TestHelper.getRecordType(Schema.Sobjecttype.BudgetCategory__c, 'External');
            BudgetCategory__c bc = new BudgetCategory__c(RecordTypeId = recordTypeId,Class__c = 'Construction',
                                            Name='Total Indirect Costs (Applies to Lines 1-7):',
                                            CategoryDescription__c='Total Indirect Costs (Applies to Lines 1-7):');
             insert bc;
           
            ProgramServiceArea__c programServiceArea = new ProgramServiceArea__c( Program__c=prog.Id, ServiceArea__c=sva.Id);
            ProgramBudgetCategory__c programBudgetCategory = new ProgramBudgetCategory__c(Program__c=prog.id, BudgetCategory__c=bc.id); 
            insert programServiceArea;
            insert programBudgetCategory;

            ApplicationBudgetCategory2__c abc2=new ApplicationBudgetCategory2__c(BudgetCategory__c=bc.id,Amount__c=123456.0,
            BudgetAmountUSBE__c=45678.0,IsFirstBudgetPeriodRelated__c = true, AdminCostValue__c=111111.0);
            abc2.BudgetPeriod__c=budPeriod.Id;
            abc2.ServiceArea__c=asva.Id;
            abc2.Application__c=app.Id;
            insert abc2;

            BuildUpItem__c buildUpItem=new BuildUpItem__c(Title__c='test', Narrative__c='test', StartDate__c=System.today(), 
                EndDate__c=System.today()+1, ApplicationBudgetCategory__c=abc2.Id,UnitPrice__c=10, Quantity__c=100, 
                UnitofMeasurement__c='Gallons', OtherCharges__c=1000,AllowableDirect__c=500 , Indirect__c=10, 
                GrantorShare__c=25,EquipmentDesc__c='test description',name__c='test',TotalHours__c=10,RequestedHours__c=10,
                  HourlyRate__c=10,SourceType__c='Federal',ListBenefitType__c='test',FBTotalSalary__c=1000,Benefit__c =20,
                  TravelDestination__c='New York',TravelPurpose__c='test',TravelTotalMiles__c=1000,TravelMileRate__c=1000,
                  EquipmentVAWAUse__c=10,CSCType__c='test',CFTotalHours__c=100,CFRate__c=10,NumberofDays__c=10,
                  HotelFees__c=1000,PerDiem__c=1000,RegistrationPerPerson__c=100,NumberAttending__c=10);
                insert buildUpItem;


           
            Grant__c grant = new Grant__c();
            grant.GranteePOC__c=u1.Id;
            grant.ExternalOrganization__c=acc.Id;
            grant.ProjectPeriodStartDate__c=Date.newInstance(2015,3,14);
            grant.Application__c=app.Id;
            grant.ProjectPeriodEndDate__c=Date.newInstance(2016,3,14);
            grant.IssueDate__c=Date.newInstance(2015,2,14);
            grant.Program__c=prog.Id;
            grant.GranteePOC__c = u.id;
            grant.IsTCScheduleCreated__c=true;
            insert grant;
            GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c', 'StateasGrantor');


            grant.Application__c=null;
            grant.TypeOfBudgetCategories__c = 'Construction';
            update grant;

            GrantServiceArea__c grantServiceArea = new GrantServiceArea__c();
            grantServiceArea.ServiceArea__c = sva.Id;
            grantServiceArea.Grant__c = grant.Id;
            insert grantServiceArea;

            //For covering updateAddress() method in USBEAwardTriggerHelper class
            USDemographicInfo__c USDemographicInfo = new USDemographicInfo__c(StateName__c='test', PrimaryCity__c='test', County__c='test',
                                       CongressionalDistrict__c='test');
            insert USDemographicInfo;




            Award__c aw1  = TestHelper.getAwards(grant.Id,false);
            aw1.zipcode__c=USDemographicInfo.Id;
            aw1.Application__c=app.Id;
            aw1.Grant__c=grant.Id;
            aw1.BudgetPeriod__c=budPeriod.Id;
            aw1.BudgetNarrativeRead__c='test text';
            aw1.Name = Math.Random()+'AW12';
            aw1.OrganizationName__c = 'USBE';
            aw1.OrganizationAddress__c = 'Test Address';
            aw1.FiscalYear__c = '2013';
            aw1.SupportYear__c = Decimal.valueOf('2013');
            aw1.Status__c = 'Activated';
            aw1.AwardedAmountthisAction__c = 10000.00;
            aw1.TotalObligateAmount__c = 100000.00;
            aw1.DeepCloned__c = true;
            aw1.Announcement__c=ann.id;
            aw1.ObligatedAwardAmount__c=1000;
            //aw1.BudgetRevisionInitiated__c ='In Progress';
            //aw1.BudgetRevisionInitiatedByUSBE__c='Indirect Change';
            //aw1.WaiveAllocationStatus__c='N/A';
             insert aw1;

            //GrantContact__c gc=new GrantContact__c(Award__c=aw1.id,Contact__c=u1.ContactId);
            //insert gc;
             
            //GNT__TaskConfig__c tc=TestHelper.getTaskConfig('Complete Budget Revision',true);
             //Task task=new Task(GNT__TaskConfigId__c=tc.id,GNT__TaskAction__c='Complete Budget Revision');
             //insert task;
            // insert aw1;
           

        }
        Test.stopTest();
*/
     }


}