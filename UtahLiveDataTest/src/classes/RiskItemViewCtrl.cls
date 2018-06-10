public with sharing class RiskItemViewCtrl {
    public ID recordId{get;set;}
    public String templateName {get;set;}
    
    public RiskItemViewCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');

      
        templateName='Risk Item Config';
 
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        String riskItemID = ApexPages.currentPage().getParameters().get('id');
        keyValueMap.put('riskItemID',riskItemID);        
        return JSON.serialize(keyValueMap);
    }
}