@isTest
public class TestFundingSourceEdit {

    static testMethod void myUnitTest() {
          UserTriggerHelper.skipTrigger = true;
          User u = TestHelper.getAdminUser(true);
          GrantTriggerHelper.skipTrigger = true;
          AwardTriggerHelper.skipTrigger = true;
          RolesandResponsibilitiesTriggerHelper.skipTrigger = true;
          Grant__c grant = TestHelper.getGrant(true);
          Award__c award = TestHelper.getAwards(grant.id,true);
          grant.CurrentAward__c = award.id;
          update grant;
          System.runAs(u){
             FundingSource__c funsource = TestHelper.getFundingSource(true);
             Test.startTest();
             ApexPages.StandardController sc = new ApexPages.standardController(funsource);
             ApexPages.currentPage().getParameters().put('Id',funsource.id);
             ApexPages.currentPage().getParameters().put('grantId',grant.id);
             ApexPages.currentPage().getParameters().put('RecordType','External');
             FundingSourceEditCtrl ctrl = new FundingSourceEditCtrl(sc);
             ctrl.getKeyValueMap();
             Test.stopTest();
        }
        
    }
     static testMethod void myUnitTest1() {
           UserTriggerHelper.skipTrigger = true;
          User u = TestHelper.getAdminUser(true);
          System.runAs(u){
             FundingSource__c funsource = TestHelper.getFundingSource(true);
             Test.startTest();
             ApexPages.StandardController sc = new ApexPages.standardController(funsource);
             ApexPages.currentPage().getParameters().put('Id',funsource.id);
             ApexPages.currentPage().getParameters().put('RecordType','Internal');
             FundingSourceEditCtrl ctrl = new FundingSourceEditCtrl(sc);
             ctrl.getKeyValueMap();
             Test.stopTest();
        }
        
    }
}