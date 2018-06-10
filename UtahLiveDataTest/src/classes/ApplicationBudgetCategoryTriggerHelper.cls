global with sharing class ApplicationBudgetCategoryTriggerHelper extends GNT.TriggerHelper {
    
    private String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');  
    global static boolean skipTrigger = false;

    /*
    global override void processBeforeUpdate() {
        if (!skipTrigger) {
            UpdateApplicationBudgetIndirect(Trigger.new);
        }
    }
    */

    
    global override void processAfterUpdate() {
        if (!skipTrigger) {
            UpdateApplicationBudgetIndirect(Trigger.new);
        }
    }
    
    

    private void UpdateApplicationBudgetIndirect(List<ApplicationBudgetCategory2__c> appBudgetCat) {   
        
        Set<Id> appBudgetCatIds = new Set<Id>();
        for (ApplicationBudgetCategory2__c appBudgetCatIterator : appBudgetCat) {
            appBudgetCatIds.add(appBudgetCatIterator.Application__c);           
        }

        List<Application__c> appList = [
            SELECT Id, GrantorOrganizationName__c, TotalIndirectCost__c, IndirectCostPercentage__c, ProgramBudgetTypeUSBE__c, BudgetAllocation__c 
            FROM Application__c
            WHERE Id IN: appBudgetCatIds];

        List<ApplicationBudgetCategory2__c> lst = [
                SELECT Id, BudgetCategory__r.RowNumber__c, Application__c, BudgetAmountUSBE__c, AdminCostValue__c,ProjectBudgetPlusAdminCost__c  
                FROM ApplicationBudgetCategory2__c 
                WHERE Application__c IN: appBudgetCatIds];

        System.debug('MANUALDEBUG >>> triggernew = ' + appBudgetCat);
        System.debug('MANUALDEBUG >>> appIds = ' + appBudgetCatIds);        
        
        for (Application__c currentApplication : appList) {
            if (currentApplication.GrantorOrganizationName__c == 'USBE') {
                Decimal totalIndirectCost = 0;
                Decimal totalAdminIndirect = 0;
                for (ApplicationBudgetCategory2__c abc: lst) {
                    if (abc.BudgetCategory__r.RowNumber__c != '570' && abc.BudgetCategory__r.RowNumber__c != '580' && abc.BudgetCategory__r.RowNumber__c != '599') {
                        totalIndirectCost += abc.BudgetAmountUSBE__c;
                        if (currentApplication.ProgramBudgetTypeUSBE__c == 'CTE') {
                            totalAdminIndirect += abc.AdminCostValue__c;
                            
                        }    
                    }
                }
                currentApplication.TotalIndirectCost__c = (totalIndirectCost * (currentApplication.IndirectCostPercentage__c / 100)).setScale(2);
                if (currentApplication.ProgramBudgetTypeUSBE__c == 'CTE') {
                    currentApplication.TotalAdminCost__c = (totalAdminIndirect * (currentApplication.IndirectCostPercentage__c / 100)).setScale(2);
                }
                System.debug('MANUALDEBUG---totalIndirectCost = ' + currentApplication.TotalIndirectCost__c);    
            }
        }
        update appList;
    }
}