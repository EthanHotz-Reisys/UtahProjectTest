/*
    This class has methods to execute methods related to Funding Account Trigger
    **********************************************************
    Audit History
    **********************************************************
    2014-06-19 Manasi Gangal       Created

    **********************************************************
*/


public class FundingAccountTriggerHelper extends GNT.TriggerHelper {
    public static boolean skipTrigger = false;
    public override void processBeforeInsert() {
        if (skipTrigger == false) {
            for (Integer i = 0; i < Trigger.New.size(); i++) {
                FundingAccount__c newFundingAccount = (FundingAccount__c) Trigger.New[i];
                newFundingAccount.AvailableAmount__c = newFundingAccount.AllocatedAmount__c;
            }
            GNT.NameTemplateTriggerHelper.beforeInsert();
        }
    }
    public override void processBeforeUpdate() {
        if (skipTrigger == false) {
            updateStatus();
        }
    }
    public override void processAfterInsert() {
        if (skipTrigger == false) {
            createExternalBudgetCategories((List<FundingAccount__c>)Trigger.New);
            createInternalBudgetCategories((List<FundingAccount__c>)Trigger.New);
        }
    }

    /*Method for Creating External Budget Categories that are at Funding Source level with in same Grant*/
    private void createExternalBudgetCategories(List<FundingAccount__c> faccount) {
        List<FundingAccountBudgetCategory__c> fabclist = new List<FundingAccountBudgetCategory__c>();
        List<Id> listIds = new List<Id>();
        for (FundingAccount__c funaccount : faccount) {
            listIds.add(funaccount.FundingSource__c);
        }
        List<FundingSourceBudgetCategory__c> fundingsourcecatlist = [SELECT Id, Name, FundingSource__c, FundingSourceType__c, AllocatedAmount__c,
                                             BudgetCategory__c, TotalAmountAllocated__c
                                             FROM FundingSourceBudgetCategory__c where FundingSource__c IN :listIds];
        List<BudgetCategoryMapping__c> CategoryMappinglist = [select id, Name, SourceBudgetCategory__c, TargetBudgetCategory__c from BudgetCategoryMapping__c];
        FundingAccountBudgetCategory__c fabc;
        for (FundingAccount__c fa : faccount) {
            for (FundingSourceBudgetCategory__c fsbc : fundingsourcecatlist) {
                for (BudgetCategoryMapping__c catmap : CategoryMappinglist) {
                    if ((fsbc.BudgetCategory__c == catmap.SourceBudgetCategory__c) && (fsbc.FundingSourceType__c != 'State')) {
                        if (fsbc.AllocatedAmount__c != 0 && fsbc.AllocatedAmount__c != null) {
                            fabc = new FundingAccountBudgetCategory__c();
                            fabc.FundingAccount__c  = fa.Id;
                            fabc.ExternalBudgetCategory__c = fsbc.BudgetCategory__c;
                            fabc.InternalBudgetCategory__c = catmap.TargetBudgetCategory__c;
                            fabc.AmountAllocated__c = fsbc.AllocatedAmount__c;
                            fabc.FundingSourceBudgetCategory__c = fsbc.id;
                            fabclist.add(fabc);
                        }
                    }
                }
            }
        }
        if (!fabclist.isEmpty()) insert fabclist;
    }

    /* Method for Creating Internal Budget Categories that are at Funding Source level at Grantor side of application */
    private void createInternalBudgetCategories(List<FundingAccount__c> faccount) {
        List<FundingAccountBudgetCategory__c> fabclist = new List<FundingAccountBudgetCategory__c>();
        List<Id> listIds = new List<Id>();
        for (FundingAccount__c funaccount : faccount) {
            listIds.add(funaccount.FundingSource__c);
        }
        List<FundingSourceBudgetCategory__c> fundingsourcecatlist = [SELECT Id, Name, FundingSource__c, FundingSourceType__c, AllocatedAmount__c, InternalBudgetCategory__c, TotalAmountAllocated__c FROM FundingSourceBudgetCategory__c where FundingSource__c IN :listIds];
        FundingAccountBudgetCategory__c fabc;
        for (FundingAccount__c fa : faccount) {
            for (FundingSourceBudgetCategory__c fsbc : fundingsourcecatlist) {
                if (fsbc.FundingSourceType__c == 'State') {
                    if (fsbc.AllocatedAmount__c != 0 && fsbc.AllocatedAmount__c != null) {
                        fabc = new FundingAccountBudgetCategory__c();
                        fabc.FundingAccount__c  = fa.Id;
                        fabc.InternalBudgetCategory__c = fsbc.InternalBudgetCategory__c;
                        fabc.AmountAllocated__c = fsbc.AllocatedAmount__c;
                        fabc.FundingSourceBudgetCategory__c = fsbc.id;
                        fabclist.add(fabc);
                    }
                }
            }
        }
        if (!fabclist.isEmpty()) insert fabclist;
    }


    /* METHOD TO UPDATE THE STATUS OF THE FUNDING ACCOUNT IF AN ACTIVE FUNDING  ACCOUNT IS UPDATED*/
    private static void updateStatus() {
        for (Integer i = 0; i < Trigger.New.size(); i++) {
            FundingAccount__c oldFundingAccount = (FundingAccount__c) Trigger.Old[i];
            FundingAccount__c newFundingAccount = (FundingAccount__c) Trigger.New[i];

            if (oldFundingAccount.Status__c == 'Active' &&  newFundingAccount.Status__c != 'Active') {
                newFundingAccount.Status__c = 'In Progress';
            }
            if (newFundingAccount.AllocatedAmount__c != oldFundingAccount.AllocatedAmount__c) {
                newFundingAccount.AvailableAmount__c = newFundingAccount.AllocatedAmount__c;
            }
        }
    }

}