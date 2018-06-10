@isTest
private class TestAwardFundingAccountsActionHandler {

    static testMethod void myUnitTest() {
        
        GrantTriggerHelper.skipTrigger = true;
        AwardTriggerHelper.skipTrigger = true;
        FundingAccountTriggerHelper.skipTrigger = true;
        UserTriggerHelper.skipTrigger = true; 
        User u = TestHelper.getAdminUser(true);
        System.runAs(u) {
            Grant__c grant = TestHelper.getGrant(true);
            Award__c award= TestHelper.getAwards(grant.Id,true);
            FundingSource__c fundSrc = TestHelper.getFundingSource(true);
            FundingAccount__c fundAcc = TestHelper.getFundingAccount(true,fundSrc.Id);
            AwardFundingAccount__c awdfndaccnt = new AwardFundingAccount__c(Award__c = award.id,FundingAccount__c = fundAcc.id);
            insert awdfndaccnt;
            List<String> selectedRecordIds = new List<String>();
            selectedRecordIds.add(fundAcc.id);
            ApexPages.currentPage().getParameters().put('Id', award.Id);
            PageReference p = Page.StrategicPlanView;
            Map<String,String> urlParams = new Map<String,String>();
            AwardFundingAccountsActionHandler awardfaactionhandler = new AwardFundingAccountsActionHandler();
            awardfaactionhandler.selectedRecordIds = selectedRecordIds;
            urlParams.put('awardId',award.Id);
            awardfaactionhandler.urlParams = urlParams;
            awardfaactionhandler.clickHandler();           
        }
    }
}