@isTest
public class TestFundingSourceSubmissionHelper {

    static testMethod void myUnitTest() {
         User u = new User(Id=UserInfo.getUserId());
         FundingSource__c funsource = null;
         System.runAs(u){
         	funsource = TestHelper.getFundingSource(true);
         	funsource.Status__c = 'Created';
         	funsource.Title__c = 'funding source1';
         	update funsource;
         	FundingAccount__c funaccnt = Testhelper.getFundingAccount(true,funsource.id);
         	FundingSourceBudgetCategory__c fsourcebc = new FundingSourceBudgetCategory__c(Name='fsbc',FundingSource__c=funsource.id);
         	insert fsourcebc;
         }
         Test.startTest();         
         FundingSourceSubmissionHelper Fs = new FundingSourceSubmissionHelper();
         ApexPages.currentPage().getParameters().put('id',funsource.Id);  
         Fs.whenClicked();
         Test.stopTest(); 
    }
    static testMethod void myUnitTest1() {
         User u = new User(Id=UserInfo.getUserId());
         FundingSource__c funsource = null;
         System.runAs(u){
         	funsource = TestHelper.getFundingSource(true);
         	funsource.Status__c = 'Created';
         	funsource.Title__c = 'funding source1';
         	update funsource;
         }
         Test.startTest();         
         FundingSourceSubmissionHelper Fs = new FundingSourceSubmissionHelper();
         ApexPages.currentPage().getParameters().put('id',funsource.Id);  
         Fs.whenClicked();
         Test.stopTest(); 
    }
}