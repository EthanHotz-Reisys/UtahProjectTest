public with sharing class FAQCtrl {
    
    //Properties
    public ID recordId{get;set;}
    public String recordType {get;set;}
    public KnowledgeArticle__c articleRecord; 
     
    public FAQCtrl(){
        recordId = SFDCEncoder.SFDC_JSENCODE(ApexPages.CurrentPage().getParameters().get('id'));   
       // articleRecord =[Select Id, Question__c, Answer__c from KnowledgeArticle__c where id =: recordId limit 1];
    }
    
     public KnowledgeArticle__c getRecords(){
        if(KnowledgeArticle__c.sObjectType.getDescribe().isAccessible() == true){
            articleRecord =[Select Id, Question__c, Answer__c from KnowledgeArticle__c where id =: recordId limit 1];
        }
        return articleRecord;
    } 
    
    public string getKeyValueMap(){   
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('recordId',SFDCEncoder.SFDC_JSENCODE(ApexPages.currentPage().getParameters().get('id')));      
        return JSON.serialize(keyValueMap);
    }   
}