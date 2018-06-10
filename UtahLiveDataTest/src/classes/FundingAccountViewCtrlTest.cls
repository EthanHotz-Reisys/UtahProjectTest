@isTest
public class FundingAccountViewCtrlTest {
    static testMethod void someTest() {
        
        FundingSource__c fundSource = null;
        FundingAccount__c fundAcc = null;
        
        fundSource = TestHelper.getFundingsource(true);
        fundAcc = TestHelper.getFundingAccount(true,fundSource.Id);     
         
         Test.startTest();
         ApexPages.StandardController sc = new ApexPages.standardController(fundAcc);
         ApexPages.currentPage().getParameters().put('id',fundAcc.Id);
         //ApexPages.currentPage().getParameters().put('fundingSourceId',fundSource.Id);
         FundingAccountViewCtrl e = new FundingAccountViewCtrl(sc);
         e.getKeyValueMap();
         Test.stopTest();
    }

}