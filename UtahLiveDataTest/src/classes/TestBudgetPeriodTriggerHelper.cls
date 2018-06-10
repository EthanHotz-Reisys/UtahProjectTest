@isTest
public with sharing class TestBudgetPeriodTriggerHelper {
    @isTest
    static void UpdateDeleteTest() {
    /*
        UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);

        System.runAs(u) {
            AccountTriggerHelper.skipTrigger = true;
            Account testAccount = TestHelper.getAccount(true);
            ProgramTriggerHelper.skipTrigger = true;
            Program__c program = TestHelper.getProgram(testAccount.Id,true);

            AnnouncementTriggerHelper.skipTrigger = true;
            Announcement__c announcement = TestHelper.getAnnouncement(program.Id,true);

            BudgetPeriod__c budgetPeriod = new BudgetPeriod__c(
                Program__c = program.Id,
                FundingOpportunity__c = announcement.Id
            );
            insert budgetPeriod;

            FundingOpportunityBudgetCategory__c fobc = new FundingOpportunityBudgetCategory__c(
                FundingOpportunity__c = announcement.Id,
                BudgetPeriod__c = budgetPeriod.Id
            );
            insert fobc;

            Test.startTest();
            budgetPeriod.Notes__c = 'Test'; //Update test
            update budgetPeriod;
            delete budgetPeriod; //Delete test
            Test.stopTest();
        }
        */
    }
}