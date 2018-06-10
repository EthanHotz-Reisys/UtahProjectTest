public with sharing class AwardBudgetCategoryViewCtrl {
    public ID recordId{get;set;}
    public PageReference deleteURL{get;set;}
    public String pageTemplateName {get;set;}
    
    public AwardBudgetCategoryViewCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id'); 
        pageTemplateName = 'AwardBudgetCategory';
        deleteURL = null;
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('Awardbudcatid',recordId);
        return JSON.serialize(keyValueMap);
    }

}