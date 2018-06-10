public with sharing class ReviewerInternalViewCtrl {
    public ID recordId {get;set;}
    public String pageTemplateName {get;set;}
    public ID userId {get;set;}
    public PageReference deleteURL{get;set;}
    
    public ReviewerInternalViewCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.currentPage().getParameters().get('id');
         if(recordId == null){
          User loggedInUser = [Select ContactId From User Where id = :UserInfo.getUserId()];
          recordId = loggedInUser.ContactId;
        }
        User userObj=[Select Id, Name from User where ContactId=:recordId Limit 1];
        if(userObj!=null){
        userId=userObj.Id;
        }        
        pageTemplateName = 'ContactViewForExternalReviewer';
        deleteURL = null; 
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('ContactId', ApexPages.currentPage().getParameters().get('id'));
        if(userId!=null){
        keyValueMap.put('userId', userId);
        }
        return JSON.serialize(keyValueMap);
    }
}