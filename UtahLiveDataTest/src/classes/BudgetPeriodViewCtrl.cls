public with sharing class BudgetPeriodViewCtrl {
    public ID recordId{get;set;}
    public PageReference deleteURL{get;set;}
    public String pageTemplateName {get;set;}
    
    public BudgetPeriodViewCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id'); 
        pageTemplateName = 'GrantBudgetPeriod';//TODO get template dynamically from sObjectConfig
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('BudgetPeriodid',recordId);
        return JSON.serialize(keyValueMap);
    }

}