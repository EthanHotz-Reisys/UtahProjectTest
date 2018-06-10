@isTest
private class TestProgramFundingAccountActionHandler {

    static testMethod void myUnitTest() {
    /*
        AccountTriggerHelper.skipTrigger = true;
        ProgramTriggerHelper.skipTrigger = true;
        FundingAccountTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
        System.runAs(u) {
            Account acc = TestHelper.getAccount(true);
            Program__c prg = TestHelper.getProgram(acc.Id, true);
            FundingSource__c fundSrc = TestHelper.getFundingSource(true);
            FundingAccount__c fundAcc = TestHelper.getFundingAccount(true,fundSrc.Id);
            ProgramFundingAccount__c pgmfndaccnt = new ProgramFundingAccount__c(Program__c = prg.id,FundingAccount__c = fundAcc.id);
            insert pgmfndaccnt;
            List<String> selectedRecordIds = new List<String>();
            selectedRecordIds.add(fundAcc.id);
            ApexPages.currentPage().getParameters().put('Id', prg.Id);
            Map<String,String> urlParams = new Map<String,String>();
            ProgramFundingAccountsActionHandler pgmfaactionhandler = new ProgramFundingAccountsActionHandler();
            pgmfaactionhandler.selectedRecordIds = selectedRecordIds;
            urlParams.put('parentid',prg.Id);
            pgmfaactionhandler.urlParams = urlParams;
            pgmfaactionhandler.clickHandler();           
        }
    */
    }
}