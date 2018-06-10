/**
* @author: Sarat Mahavratayajula 2016-21-07
*/
@isTest
public class TestApplicationTriggerHelper {
    
        static testMethod void testApplicationTrigger2(){
        
         UserTriggerHelper.skipTrigger = true;
         User u3 = TestHelper.getAdminUser(true); 
         ServiceArea__c serviceArea = null;
        // AnnouncementServiceArea__c annServiceArea=null;
         BudgetPeriod__c budPeriod = null;
         Application__c app = null;
      
         System.runAs(u3){   
            Test.startTest();
            ProgramTriggerHelper.skipTrigger=true;
            //GNT.TriggerHelper.skipTrigger=true;
            RolesAndResponsibilitiesTriggerHelper.skipTrigger=true;
            AnnouncementTriggerHelper.skipTrigger = true;
            TaskTriggerHelper.skipTrigger = true;
            ReviewPanelTriggerHelper.skipTrigger = true;
            Announcement__c ann = TestHelper.getAnnouncement(true);

            BudgetCategory__c bc = new BudgetCategory__c(Name = 'Indirect Costs', CategoryDescription__c = 'Indirect Costs', RowNumber__c = '213', RowsNumber__c = 213);
            insert bc;

            AnnouncementServiceArea__c annServiceArea = new AnnouncementServiceArea__c(Announcement__c = ann.Id);
            insert annServiceArea;

            serviceArea = new ServiceArea__c(Title__c='Application Project Area',Default__c = true);
            insert serviceArea;

            BudgetPeriod__c budgetPeriod = new BudgetPeriod__c(FundingOpportunity__c=ann.Id);
            insert budgetperiod;

            FundingOpportunityBudgetCategory__c funOporBudCat = new FundingOpportunityBudgetCategory__c(FundingOpportunity__c=ann.Id);
            insert funOporBudCat;

            //Application__c app = TestHelper.getApplication(ann.Id,true);
            GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateasGrantor');
            Account acct=TestHelper.getAccount(true);
            app = new Application__c();
            app.Announcement__c = ann.Id;
            app.Name = 'APP-001';
            app.ApplicationType__c = 'TBD';
            app.ExternalOrganization__c=acct.id;
            app.ProjectDirector__c = u3.Id;
            app.FedBizOps__c=u3.id;
            GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateasGrantor');
            List<Application__c> lst=new List<Application__c>();
            lst.add(app);
            insert lst;

            app.Status__c='Submitted';
            app.ChangeRequestStatus__c='Change Request Accepted';
            GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateasGrantor');
            update app;

            budPeriod = new BudgetPeriod__c(FundingOpportunity__c=app.Announcement__c);
            budPeriod.SupportYear__c='1992';
            budPeriod.BudgetEndDate__c= Date.newInstance(2018,05,18);
            budPeriod.BudgetStartDate__c=Date.newInstance(1992,05,16);
            budPeriod.Status__c='Open';
            budPeriod.SequenceNumber__c=1.0;
            insert budPeriod;

            }
             
             GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateasGrantor');
             GNT.UserPreferenceHelper.setStringValue('ProfileName__c','Applicant');
             ApplicationTriggerHelper appTrigHelp = new ApplicationTriggerHelper();
             Test.stopTest();                
    }

    @isTest
    static void sometest2() {
    /*
        // Skip unwanted triggers
        ProgramTriggerHelper.skipTrigger=true;
        AnnouncementTriggerHelper.skipTrigger = true;
        TaskTriggerHelper.skipTrigger=true;
        AccountTriggerHelper.skipTrigger=true;
        RolesandResponsibilitiesTriggerHelper.skipTrigger = true;
        UserTriggerHelper.skipTrigger = true;
        User u3 = TestHelper.getAdminUser(true);

        System.runAs(u3){
            
            Account account=TestHelper.getAccount(true);
            Contact contact = new Contact(Firstname='FirstName1', Lastname='LastNam1e',Email='email1@email.com', 
                                            Title='Title',Phone ='123-123-1234',Account=account);
            insert contact;
            Announcement__c ann = TestHelper.getAnnouncement(true);
            //ann.ApplicationDeadlineWithDateTime__c = datetime.newInstance(2018,06,15,20,00,00);
           
            
           //  update ann;

            AnnouncementServiceArea__c annServiceArea = new AnnouncementServiceArea__c(Announcement__c = ann.Id);
            insert annServiceArea;


            ServiceArea__c serviceArea = new ServiceArea__c(Default__c=true);
            insert serviceArea;

            RolesAndResponsibilities__c rolesAndResponsibilities = new RolesAndResponsibilities__c();
            rolesAndResponsibilities.BusinessRole__c= 'Owner';
            rolesAndResponsibilities.Announcement__c = ann.Id;
            insert rolesAndResponsibilities;

            BudgetPeriod__c budgetPeriod = new BudgetPeriod__c(FundingOpportunity__c=ann.Id);
            insert budgetperiod;
            //Shivankar: Putting the start test here to deal with SOQL query limit being hit. 
            Test.startTest();
            FundingOpportunityBudgetCategory__c funOporBudCat = new FundingOpportunityBudgetCategory__c(FundingOpportunity__c=ann.Id);
            insert funOporBudCat;

            Application__c app = new Application__c(Announcement__c = ann.Id, Name = 'APP-001',ApplicationType__c = 'Continuation',
                                     ExternalOrganization__c = account.Id,Status__c='Submitted', ApplicationDeadlineWithDateTime__c = DateTime.now() +  30);
            List<Application__c> lst=new List<Application__c>();
            lst.add(app);
            insert lst;

            app.Status__c='Submitted to Grantor';
            app.ChangeRequestStatus__c='Change Request Accepted';
            GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateasGrantee');
            GNT.UserPreferenceHelper.setStringValue('ProfileName__c','Applicant');
            update app;

            
                GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateasGrantee');
                GNT.UserPreferenceHelper.setStringValue('ProfileName__c','Applicant');
                ApplicationTriggerHelper applicationTriggerHelper = new ApplicationTriggerHelper();
                //Announcement__c ann=TestHelper.getAnnouncement(true);
            Application__c app2=TestHelper.getApplication(ann.id,true);
                
                //insert lst;
                Test.stopTest();
                delete lst;
            
            GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateasGrantee');
            delete app2;
        }
        */
    } 

}