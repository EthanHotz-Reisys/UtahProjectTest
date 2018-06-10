@isTest
public class TestAwardFundingAccountEditCtrl{
    static testMethod void someTest() {
    
        User u = TestHelper.getAdminUser(true);
        AwardFundingAccount__c awardFundAcc = null;
        Grant__c grant = null;
        Award__c awards = null;
        FundingSource__c fundSource = null;
        FundingAccount__c fundAcc = null;
        
        System.runAs(u){
        
            GrantTriggerHelper.skipTrigger = true;
            AwardTriggerHelper.skipTrigger = true;
            GNT.TriggerHelper.skipTrigger = true;
            
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
        ApexPages.CurrentPage().getParameters().put('awardId',awards.id);
        AwardFundingAccountEditCtrl e = new AwardFundingAccountEditCtrl(sc);
        e.getKeyValueMap();
        Test.stopTest();
    }
}