public with sharing class ApprViewCtrl{
    public ID recordId {get;set;}
    public String pageTemplateName {get;set;}
    //public PageReference deleteURL{get;set;}
    
    public ApprViewCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.currentPage().getParameters().get('id');
        System.debug('LEON HERE!!!!');
        pageTemplateName = 'ApprView';
        //deleteURL = null; 
    }
    
    public static string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        //keyValueMap.put('ContactId', ApexPages.currentPage().getParameters().get('id'));
        return JSON.serialize(keyValueMap);
    }
}