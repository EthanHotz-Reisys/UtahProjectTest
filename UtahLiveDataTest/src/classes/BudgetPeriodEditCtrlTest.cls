@isTest
public class BudgetPeriodEditCtrlTest {
    static testMethod void someTest() {
    	 AccountTriggerHelper.skipAll = true;
         Account acc = TestHelper.getAccount(true);      
         ApexPages.StandardController sc = new ApexPages.standardController(acc);
         ApexPages.currentPage().getParameters().put('id',acc.Id);
         ApexPages.CurrentPage().getParameters().put('grantId',acc.Id);
         ApexPages.CurrentPage().getParameters().put('programid',acc.Id);
         ApexPages.CurrentPage().getParameters().put('announcementId',acc.Id);
         BudgetPeriodEditCtrl e = new BudgetPeriodEditCtrl(sc);
         e.getKeyValueMap();
    }
     
}