public with sharing class DeliverableViewCtrl {
    //Properties
    public ID recordId{get;set;}
    public PageReference deleteURL{get;set;}
    public String pageTemplateName {get;set;}
    
    public DeliverableViewCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id'); 
        pageTemplateName='Award Deliverable';
    } 
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
       
        return JSON.serialize(keyValueMap);
    }

}