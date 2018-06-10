@isTest
public class TestFundingSourceViewCtrl {

    static testMethod void myUnitTest1() {
          
          User u = TestHelper.getAdminUser(true);
          System.runAs(u){
          	 FundingSource__c funsource = TestHelper.getFundingSource(true);
          	 funsource.Type__c = 'Federal';
          	 update funsource;
             Test.startTest();
             ApexPages.StandardController sc = new ApexPages.standardController(funsource);
             ApexPages.currentPage().getParameters().put('Id',funsource.id);
             FundingSourceViewCtrl ctrl = new FundingSourceViewCtrl(sc);
             ctrl.getKeyValueMap();
             Test.stopTest();
        }
        
    }
    static testMethod void myUnitTest2() {
          
          User u = TestHelper.getAdminUser(true);
          System.runAs(u){
          	 FundingSource__c funsource = TestHelper.getFundingSource(true);
          	 funsource.Type__c = 'State';
          	 update funsource;
             Test.startTest();
             ApexPages.StandardController sc = new ApexPages.standardController(funsource);
             ApexPages.currentPage().getParameters().put('Id',funsource.id);
             FundingSourceViewCtrl ctrl = new FundingSourceViewCtrl(sc);
             ctrl.getKeyValueMap();
             Test.stopTest();
        }
        
    }
}