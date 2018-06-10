@isTest
private class TestGoalEditCtrl {
    
    @isTest static void test_method_one() {
    /*
        Test.startTest();
        PageReference pageRef = Page.GoalEdit;
        Test.setCurrentPage(pageRef);

        
        GrantTriggerHelper.skipTrigger = true;
        AwardTriggerHelper.skipTrigger = true;
        AccountTriggerHelper.skipTrigger = true;
        ProgramTriggerHelper.skipTrigger = true;
        GoalObjectiveTriggerHelper.skipTrigger = true;

        Account account = TestHelper.getAccount(true);
        Program__c program = TestHelper.getProgram(account.Id, true);

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
        GoalObjective__c gParent = new GoalObjective__c(isParent__c = true,Award__r = award,ExpenditureAmount__c = 12315.12,AllocatedAmount__c = 1231561.12, Allocated__c = 50.32);
        insert gParent;
        GoalObjective__c gChild = new GoalObjective__c(ParentGoal__r = gParent, isParent__c = false,Award__r = award,ExpenditureAmount__c = 16515156.12,AllocatedAmount__c = 123123.12, Allocated__c = 50.32);
        //insert gChild;
        //gParent.Allocated__c = 12.15;
        //gChild.Allocated__c = 12.12;
        //update gParent;
        //update gChild;
        ApexPages.currentPage().getParameters().put('id', null);
        ApexPages.currentPage().getParameters().put('awardId',award.Id);

        ApexPages.currentPage().getParameters().put('programid', program.Id);
        ApexPages.currentPage().getParameters().put('isParent', 'Yes');
        ApexPages.currentPage().getParameters().put('goalId', gParent.Id);
        ApexPages.currentPage().getParameters().put('type', 'AwardGoal');

        ApexPages.StandardController stdController = new ApexPages.StandardController(gChild);

        GoalEditCtrl g = new GoalEditCtrl(stdController);
        g.getKeyValueMap();
        Test.stopTest();
*/
    }
    
    @isTest static void test_method_two() {
    /*
        Test.startTest();
        PageReference pageRef = Page.GoalEdit;
        Test.setCurrentPage(pageRef);

        
        GrantTriggerHelper.skipTrigger = true;
        AwardTriggerHelper.skipTrigger = true;
        AccountTriggerHelper.skipTrigger = true;
        ProgramTriggerHelper.skipTrigger = true;
        GoalObjectiveTriggerHelper.skipTrigger = true;

        Account account = TestHelper.getAccount(true);
        Program__c program = TestHelper.getProgram(account.Id, true);

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
        GoalObjective__c gParent = new GoalObjective__c(isParent__c = true,Award__r = award,ExpenditureAmount__c = 12315.12,AllocatedAmount__c = 1231561.12, Allocated__c = 50.32);
        insert gParent;
        GoalObjective__c gChild = new GoalObjective__c(ParentGoal__r = gParent, isParent__c = false,Award__r = award,ExpenditureAmount__c = 16515156.12,AllocatedAmount__c = 123123.12, Allocated__c = 50.32);
        //insert gChild;
        //gParent.Allocated__c = 12.15;
        //gChild.Allocated__c = 12.12;
        //update gParent;
        //update gChild;
        ApexPages.currentPage().getParameters().put('id', null);
        ApexPages.currentPage().getParameters().put('awardId',null);

        ApexPages.currentPage().getParameters().put('programid', program.Id);
        ApexPages.currentPage().getParameters().put('isParent', 'Yes');
        ApexPages.currentPage().getParameters().put('goalId', gParent.Id);
        ApexPages.currentPage().getParameters().put('type', 'AwardObjective');

        ApexPages.StandardController stdController = new ApexPages.StandardController(gChild);
        GoalEditCtrl g = new GoalEditCtrl(stdController);
        g.getKeyValueMap();
        Test.stopTest();
        */
    }
    @isTest static void test_method_three() {
    /*
        Test.startTest();
        PageReference pageRef = Page.GoalEdit;
        Test.setCurrentPage(pageRef);

        
        GrantTriggerHelper.skipTrigger = true;
        AwardTriggerHelper.skipTrigger = true;
        AccountTriggerHelper.skipTrigger = true;
        ProgramTriggerHelper.skipTrigger = true;
        GoalObjectiveTriggerHelper.skipTrigger = true;

        Account account = TestHelper.getAccount(true);
        Program__c program = TestHelper.getProgram(account.Id, true);

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
        GoalObjective__c gParent = new GoalObjective__c(isParent__c = true,Award__r = award,ExpenditureAmount__c = 12315.12,AllocatedAmount__c = 1231561.12, Allocated__c = 50.32);
        insert gParent;
        GoalObjective__c gChild = new GoalObjective__c(ParentGoal__r = gParent, isParent__c = false,Award__r = award,ExpenditureAmount__c = 16515156.12,AllocatedAmount__c = 123123.12, Allocated__c = 50.32);
        //insert gChild;
        //gParent.Allocated__c = 12.15;
        //gChild.Allocated__c = 12.12;
        //update gParent;
        //update gChild;
        ApexPages.currentPage().getParameters().put('id', gParent.Id);
        ApexPages.currentPage().getParameters().put('awardId',null);

        ApexPages.currentPage().getParameters().put('programid', program.Id);
        ApexPages.currentPage().getParameters().put('isParent', 'Yes');
        ApexPages.currentPage().getParameters().put('goalId', gParent.Id);
        ApexPages.currentPage().getParameters().put('type', 'ProgramGoal');

        ApexPages.StandardController stdController = new ApexPages.StandardController(gChild);
        GoalEditCtrl g = new GoalEditCtrl(stdController);
        g.getKeyValueMap();
        Test.stopTest();
        */
    }
    @isTest static void test_method_four() {
    /*
        Test.startTest();
        PageReference pageRef = Page.GoalEdit;
        Test.setCurrentPage(pageRef);

        
        GrantTriggerHelper.skipTrigger = true;
        AwardTriggerHelper.skipTrigger = true;
        AccountTriggerHelper.skipTrigger = true;
        ProgramTriggerHelper.skipTrigger = true;
        GoalObjectiveTriggerHelper.skipTrigger = true;

        Account account = TestHelper.getAccount(true);
        Program__c program = TestHelper.getProgram(account.Id, true);

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
        GoalObjective__c gParent = new GoalObjective__c(isParent__c = true,Award__r = award,ExpenditureAmount__c = 12315.12,AllocatedAmount__c = 1231561.12, Allocated__c = 50.32);
        insert gParent;
        GoalObjective__c gChild = new GoalObjective__c(ParentGoal__r = gParent, isParent__c = false,Award__r = award,ExpenditureAmount__c = 16515156.12,AllocatedAmount__c = 123123.12, Allocated__c = 50.32);
        //insert gChild;
        //gParent.Allocated__c = 12.15;
        //gChild.Allocated__c = 12.12;
        //update gParent;
        //update gChild;
        ApexPages.currentPage().getParameters().put('id', null);
        ApexPages.currentPage().getParameters().put('awardId',null);

        ApexPages.currentPage().getParameters().put('programid', program.Id);
        ApexPages.currentPage().getParameters().put('isParent', 'Yes');
        ApexPages.currentPage().getParameters().put('goalId', gParent.Id);
        ApexPages.currentPage().getParameters().put('type', 'ProgramObjective');

        ApexPages.StandardController stdController = new ApexPages.StandardController(gChild);
       
        GoalEditCtrl g = new GoalEditCtrl(stdController);
        g.getKeyValueMap();
        Test.stopTest();
        */
    }
    
}