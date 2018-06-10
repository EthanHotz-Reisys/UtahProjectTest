public with sharing class ManageReviewViewCtrl {
    
    //Properties
    public ID recordId{get;set;}
    
    public String templateName {get;set;}
    
    public ManageReviewViewCtrl(){
        
    templateName = 'ApplicationReviewTemplate';
            recordId = 'a0D370000014TdhEAE';
        
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        
        return JSON.serialize(keyValueMap);
    }
}