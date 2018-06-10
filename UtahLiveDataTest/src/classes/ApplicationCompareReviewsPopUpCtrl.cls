public with sharing class ApplicationCompareReviewsPopUpCtrl{
    
    public String templateName{get;set;}
    private Set<String> recordsIdSet;
    public String applicationName{get;set;} 

    public ApplicationCompareReviewsPopUpCtrl(){
       templateName = ApexPages.CurrentPage().getParameters().get('flextable');      
       String rsaId = ApexPages.CurrentPage().getParameters().get('id');      
       System.debug('MANUALDEBUG rsaId:'+rsaId);
       System.debug('MANUALDEBUG templateName:'+templateName);
      
       applicationName = ApexPages.CurrentPage().getParameters().get('appId');       
       Map<Id, Review__c> reviewMap = new Map<Id, Review__c>([SELECT ApplicationID__c,Application__r.Name,Id,Name,Recommendation__c,SMETotalPoints__c,Comments__c,SubmittedOn__c FROM Review__c WHERE ReviewStep__r.Name = 'SME Review' AND ApplicationID__c =: applicationName]);
       recordsIdSet = (Set<String>)JSON.deserialize(JSON.serialize(reviewMap.keyset()), Set<String>.class);    
       System.debug('MANUALDEBUG ReviewMap: '+reviewMap );
       System.debug('MANUALDEBUG RecordsIdSet: '+recordsIdSet);
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