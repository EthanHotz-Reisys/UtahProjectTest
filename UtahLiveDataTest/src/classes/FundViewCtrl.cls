public with sharing class FundViewCtrl{
    public ID recordId {get;set;}
    public String pageTemplateName {get;set;}
    //public PageReference deleteURL{get;set;}
    
    public FundViewCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.currentPage().getParameters().get('id');
        pageTemplateName = 'FundView';
        //deleteURL = null; 
    }
    
    public static string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        //keyValueMap.put('ContactId', ApexPages.currentPage().getParameters().get('id'));
        return JSON.serialize(keyValueMap);
    }
}