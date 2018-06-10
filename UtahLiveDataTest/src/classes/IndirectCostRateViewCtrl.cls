public with sharing class IndirectCostRateViewCtrl {

    public ID recordId {get;set;}
    public String templateName{get;set;} 
    public PageReference cancelPage {get;set;}
    
    public IndirectCostRateViewCtrl(ApexPages.StandardController stdController) {
        recordId = ApexPages.CurrentPage().getParameters().get('id');
        templateName = 'IndirectCostRateView';
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('Id', recordId);
        return JSON.serialize(keyValueMap);
    }
}