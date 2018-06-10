public with sharing class ReviewStepApplicationViewCtrl {
    //Properties
    public ID recordId{get;set;}
    public  string templateName {get;set;}
    
    public ReviewStepApplicationViewCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');  
        String type = ApexPages.CurrentPage().getParameters().get('type');
        if(type!=null && type=='RejectedApp'){
            templateName = 'ReviewStepApplication_RejectedApp';
        }
        else{
            templateName = 'ReviewStepApplication';
        } 
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('reviewStepApplicationId',ApexPages.currentPage().getParameters().get('id'));
        return JSON.serialize(keyValueMap);
    }
}