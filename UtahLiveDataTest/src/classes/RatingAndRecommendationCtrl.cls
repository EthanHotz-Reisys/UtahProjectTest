public with sharing class RatingAndRecommendationCtrl{
    public ID recordId{get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    public String pageTemplateName {get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    
    public RatingAndRecommendationCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');
         
        Review__c reviewCaller = [SELECT Id,Status__c,name FROM Review__c WHERE id =: recordId];
        
        pageTemplateName = 'RatingAndRecommendation';
        
    }
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();

        return JSON.serialize(keyValueMap);
    }    
}