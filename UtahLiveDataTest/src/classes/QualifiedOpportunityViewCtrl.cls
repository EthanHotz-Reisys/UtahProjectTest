public with sharing class QualifiedOpportunityViewCtrl {
    
    //Properties Please configure template.
    public  ID recordId{get;set;}
    public  ID programId {get;set;}
    private Boolean rfaParameter;
    public  string templateName {get;set;}
    public  string packageName {get;set;}
    public boolean isExternal {get;set;}
    private String annType ;
    boolean isInternal;
    public QualifiedOpportunityViewCtrl(ApexPages.StandardController stdController){
          system.debug('-----------------------------------------------QualifiedOpportunityViewCtrl -------------------------------');
        recordId = ApexPages.CurrentPage().getParameters().get('id');
        String tmplName = ApexPages.CurrentPage().getParameters().get('templateName');
        User u = [SELECT id,Name,IsExternalUser__c FROM User WHERE Id=:UserInfo.getUserId()];
        
       templateName = 'QualifiedAnnoucementExternalGrantor';
     
        
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();

        String announcementId= ApexPages.currentPage().getParameters().get('announcementId');
     
        
        keyValueMap.put('announcementId',announcementId); 
        keyValueMap.put('programId',programId); 


        return JSON.serialize(keyValueMap);
    }
    public string getListParams(){
        Map<String,List<String>> listParams = new Map<String,List<String>>();
        String announcementid = ApexPages.currentPage().getParameters().get('id');
        if(announcementid != null && announcementid != ''){
            Map<Id,ReviewGroup__c> reviewGroupsMap = new Map<Id,ReviewGroup__c>([SELECT Id FROM ReviewGroup__c WHERE Announcement__c =:announcementid]);
            List<String> reviewGroupIdsList = new List<String>();
            for(Id rgId:reviewGroupsMap.keySet()){
                reviewGroupIdsList.add((String)rgId);    
            }
            listParams.put('reviewGroupIdsList',reviewGroupIdsList);
        }

        return JSON.serialize(listParams);
    }
    
}