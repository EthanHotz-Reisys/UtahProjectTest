@isTest
private class TestGoalObjectiveTriggerHelper {
    
    @isTest static void test_method_one() {
    /*
        AccountTriggerHelper.skipTrigger = true;
        ProgramTriggerHelper.skipTrigger = true;
        Account account = TestHelper.getAccount(true);
        Program__c program = TestHelper.getProgram(account.Id, true);
        GoalObjective__c g = new GoalObjective__c(Program__c = program.Id);
        insert g;
        */
    }
    
    @isTest static void test_method_two() {
        GrantTriggerHelper.skipTrigger = true;
        AwardTriggerHelper.skipTrigger = true;
        Grant__c grant = TestHelper.getGrant(true);
        Award__c award = new Award__c();
        award.grant__c = grant.Id;
        award.Name = Math.Random()+'AW12';
        award.OrganizationName__c = 'Test Org';
        award.OrganizationAddress__c = 'Test Address';
        award.FiscalYear__c = '2013';
        award.SupportYear__c = Decimal.valueOf('2013');
        award.Status__c = 'Issued';
        award.AwardedAmountthisAction__c = 156.15;
        award.PriorAwardedAmount__c = 465.46;
        insert award;
        award = [Select PriorAwardedAmount__c, AwardedAmountthisAction__c, TotalGrantAwardAmount__c from Award__c where Id = :award.Id ];
        update award;
        GoalObjective__c gParent = new GoalObjective__c(isParent__c = true,Award__c = award.Id,ExpenditureAmount__c = 12315.12,AllocatedAmount__c = 1231561.12, Allocated__c = 50.32);
        insert gParent;
        
        gParent = [Select Type__c from GoalObjective__c where Id = :gParent.Id];
        
        gParent.Allocated__c = 12.15;
        GoalObjectiveTriggerHelper.skipTrigger = false;
        update gParent;


    }
    @isTest static void test_method_three() {
        GrantTriggerHelper.skipTrigger = true;
        AwardTriggerHelper.skipTrigger = true;
        Grant__c grant = TestHelper.getGrant(true);
        Award__c award = new Award__c();
        award.grant__c = grant.Id;
        award.Name = Math.Random()+'AW12';
        award.OrganizationName__c = 'Test Org';
        award.OrganizationAddress__c = 'Test Address';
        award.FiscalYear__c = '2013';
        award.SupportYear__c = Decimal.valueOf('2013');
        award.Status__c = 'Issued';
        award.AwardedAmountthisAction__c = 156.15;
        award.PriorAwardedAmount__c = 465.46;
        insert award;
        award = [Select PriorAwardedAmount__c, AwardedAmountthisAction__c, TotalGrantAwardAmount__c from Award__c where Id = :award.Id ];
        update award;
        GoalObjective__c gParent = new GoalObjective__c(isParent__c = true,Award__c = award.Id,ExpenditureAmount__c = 12315.12,AllocatedAmount__c = 1231561.12, Allocated__c = 5.32);
        insert gParent;
        GoalObjective__c gChild = new GoalObjective__c(ParentGoal__c = gParent.Id, isParent__c = false,Award__c = award.Id,ExpenditureAmount__c = 16515156.12,AllocatedAmount__c = 123123.12, Allocated__c = 50.32);
        GoalObjectiveTriggerHelper.skipTrigger = false;
        insert gChild;
        gParent = [Select Type__c from GoalObjective__c where Id = :gParent.Id];
        gChild = [Select Type__c from GoalObjective__c where Id = :gChild.Id];
        gParent.Allocated__c = 23.15;
        gChild.Allocated__c = 12.12;
        GoalObjectiveTriggerHelper.skipTrigger = false;
        update gParent;
        GoalObjectiveTriggerHelper.skipTrigger = false;
        update gChild;
    }
    
}