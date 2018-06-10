@isTest
public class BudgetPeriodViewCtrlTest {
    static testMethod void someTest() {
    	 AccountTriggerHelper.skipAll = true;
         Account acc = TestHelper.getAccount(true);      
         ApexPages.StandardController sc = new ApexPages.standardController(acc);
         ApexPages.currentPage().getParameters().put('id',acc.Id);
         BudgetPeriodViewCtrl e = new BudgetPeriodViewCtrl(sc);
         e.getKeyValueMap();
         e.deleteURL=Page.BudgetPeriodView;
    }
     
}