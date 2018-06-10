@isTest
public class TestSpendPlanTrigger {
    static testMethod void method(){
    	GrantTriggerHelper.skipTrigger = true;
    	Grant__c grant = TestHelper.getGrant(true);
        SpendPlan__c sp = new SpendPlan__c(SpendType__c = 'Contracts', Grant__c = grant.Id);
        
        insert sp;
    }

}