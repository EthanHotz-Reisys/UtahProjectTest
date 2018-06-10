public with sharing class AwardFundingAccountViewCtrl {
    public ID recordId{get;set;}
    public PageReference deleteURL{get;set;}
    public String pageTemplateName {get;set;}
    
    public AwardFundingAccountViewCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id'); 
        pageTemplateName = 'AwardFundingAccount';
        deleteURL = null;
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('AwardFundingAccountid',recordId);
        return JSON.serialize(keyValueMap);
    }

}