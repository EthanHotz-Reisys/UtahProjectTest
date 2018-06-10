public with sharing class AdditionalUserViewCtrl {
    public ID recordId {get;set;}
    public String pageTemplateName {get;set;}
    public PageReference deleteURL{get;set;}
    public ID orgId{get;set;}
    
    public AdditionalUserViewCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.currentPage().getParameters().get('id');
        system.debug('recordIDinhere '+recordId);
        Contact contact = [Select id,keycontact__c,userreference__r.organization__c from contact where id=:recordId];
        orgId=contact.UserReference__r.organization__c;
        pageTemplateName = 'AdditionalUser';
        deleteURL = null; 
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('ContactId', ApexPages.currentPage().getParameters().get('id'));
        keyValueMap.put('orgId',orgId);
        return JSON.serialize(keyValueMap);
    }
}