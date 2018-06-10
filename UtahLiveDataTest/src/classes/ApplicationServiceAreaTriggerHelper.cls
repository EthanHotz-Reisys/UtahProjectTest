global with sharing class ApplicationServiceAreaTriggerHelper extends GNT.TriggerHelper {
    global override void processAfterInsert() {
    //    addBudgetCategories(Trigger.new);
    }
    global override void processAfterDelete() {
        deleteBudgetCategories(Trigger.oldMap.keySet());
    }
    // commented out because method is not used in the processAfterInsert at the time of changes(6/16/17)-Charan
    /*private static void addBudgetCategories(List<ApplicationServiceArea__c> asas) {
        List<ApplicationBudgetCategory2__c> abcs = new List<ApplicationBudgetCategory2__c>();
        ApplicationBudgetCategory2__c abc;
        List<BudgetCategory__c> bcs = [SELECT Id FROM BudgetCategory__c];
        for(ApplicationServiceArea__c asa: asas) {
            for(BudgetCategory__c bc: bcs) {
                abc = new ApplicationBudgetCategory2__c();
                abc.ServiceArea__c = asa.Id;
                abc.BudgetCategory__c = bc.Id;
                abc.Application__c = asa.Application__c;
                abc.RequestedAmount__c = 0;
                abcs.add(abc);
            }
        }
        if(abcs.size() > 0) {
            insert abcs;
        }
    }
*/    private static void deleteBudgetCategories(Set<Id> asas) {
        List<ApplicationBudgetCategory2__c> abcs = [SELECT Id FROM ApplicationBudgetCategory2__c WHERE ServiceArea__c IN: asas];
        delete abcs;
    }
}