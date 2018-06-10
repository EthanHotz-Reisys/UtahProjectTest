public with sharing class BudgetCategoryViewCtrl {
    public ID recordId{get;set;}
    public PageReference deleteURL{get;set;}
    public String pageTemplateName {get;set;}
    
    public BudgetCategoryViewCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id'); 
        pageTemplateName = 'GrantBudgetCategory';
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('BudgetCategoryid',recordId);
        return JSON.serialize(keyValueMap);
    }

}