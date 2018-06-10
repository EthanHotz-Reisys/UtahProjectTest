public with sharing class ApplicationRatingPopUpCtrl{
    
    public String templateName{get;set;}
    private Set<String> recordsIdSet;
    public String applicationName{get;set;} 
    private List<Id> addedRecords =new List<Id>();

    public ApplicationRatingPopUpCtrl(){
       templateName = ApexPages.CurrentPage().getParameters().get('flextable');      
       String rsaId = ApexPages.CurrentPage().getParameters().get('id');
       system.debug('--rsaId--'+rsaId);
       system.debug('--templateName--'+templateName);
       ReviewStepApplication__c rsa = [Select Id, Name, ReviewStep__c, Application__c,Application__r.Name from ReviewStepApplication__c where id=:rsaId];
              system.debug('--rsa--'+rsa);
       Map<Id,Review__c> reviewMap = new Map<Id,Review__c>([Select Id, Name from Review__c where ReviewStep__c=:rsa.ReviewStep__c and Application__c=:rsa.Application__c]);   
        system.debug('--reviewMap --'+reviewMap );
        recordsIdSet = (Set<String>)JSON.deserialize(JSON.serialize(reviewMap.keyset()), Set<String>.class);     
        system.debug('--recordsIdSet--'+recordsIdSet);
        applicationName = rsa.Application__r.Name;
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('parentid',ApexPages.CurrentPage().getParameters().get('parentid'));
        return JSON.serialize(keyValueMap);
    }

     public string getListParameters(){
        Map<String,Set<String>> listParams = new Map<String,Set<String>>();     
        listParams.put('recordsIdSet',recordsIdSet);
        return JSON.serialize(listParams);
      }
}