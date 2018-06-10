@isTest
public class TestBudgetCategoryViewCtrl{
    static testMethod void someTest() {
    	 AccountTriggerHelper.skipAll = true;
         Account acc = TestHelper.getAccount(true);      
         ApexPages.StandardController sc = new ApexPages.standardController(acc);
         ApexPages.currentPage().getParameters().put('id',acc.Id);
         BudgetCategoryViewCtrl e = new BudgetCategoryViewCtrl(sc);
         e.getKeyValueMap();
         e.deleteURL=Page.BudgetCategoryView;
    }
     
}