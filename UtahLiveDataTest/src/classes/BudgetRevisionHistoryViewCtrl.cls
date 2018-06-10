public with sharing class BudgetRevisionHistoryViewCtrl{
    public ID recordId{get;set;}
    public ID lineItemId{get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    public String pageTemplateName {get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    
    public BudgetRevisionHistoryViewCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');
         
        AmendmentRequest__c thisBudgetHistory = [SELECT Id, Name FROM AmendmentRequest__c WHERE id =: recordId];
        
        //List<AmendmentRequestBudgetCategory__c> budgetRevisionList = [SELECT Id,BudgetCategory__c, BudgetCategory__r.RowNumber__c FROM AmendmentRequestBudgetCategory__c WHERE Id =: recordId];
        AmendmentRequestBudgetCategory__c budgetRevisionBuildUpCategory = [SELECT Id, AmendmentRequest__c, BudgetCategory__c, BudgetCategory__r.RowNumber__c FROM AmendmentRequestBudgetCategory__c WHERE AmendmentRequest__c =: recordId AND BudgetCategory__r.RowNumber__c = '570'];
        lineItemId = budgetRevisionBuildUpCategory.Id;
        //for (AmendmentRequestBudgetCategory__c iterator : budgetRevisionList ) {
            //if (iterator.BudgetCategory__r.RowNumber__c == '570') {
                //lineItemId = iterator.Id;
            //}
        //}
        
        pageTemplateName = 'BudgetRevisionHistoryView';
        
    }
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('recordId', recordId);
        keyValueMap.put('lineItemId', lineItemId);
        keyValueMap.put('pageTemplatename', pageTemplateName);
        return JSON.serialize(keyValueMap);
    }    
}