@isTest
public class TestAwardFundingAccountViewCtrl{
    static testMethod void someTest() {
        UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
        AwardFundingAccount__c awardFundAcc = null;
        Grant__c grant = null;
        Award__c awards = null;
        FundingSource__c fundSource = null;
        FundingAccount__c fundAcc = null;
        
        System.runAs(u){
        
            GrantTriggerHelper.skipTrigger = true;
            AwardTriggerHelper.skipTrigger = true;
            
            grant = TestHelper.getGrant(true);
            awards = TestHelper.getAwards(grant.Id,true);
            fundSource = TestHelper.getFundingSource(true);
            fundAcc = TestHelper.getFundingAccount(true, fundSource.Id);
            awardFundAcc = new AwardFundingAccount__c(Award__c=awards.Id,FundingAccount__c=fundAcc.Id);
            insert awardFundAcc;
        }
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.standardController(awardFundAcc);
        ApexPages.currentPage().getParameters().put('id',awardFundAcc.id);
        AwardFundingAccountViewCtrl e = new AwardFundingAccountViewCtrl(sc);
        e.getKeyValueMap();
        Test.stopTest();
    }
}