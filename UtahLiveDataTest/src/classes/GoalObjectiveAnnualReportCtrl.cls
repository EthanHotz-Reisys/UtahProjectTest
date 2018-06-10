public with sharing class GoalObjectiveAnnualReportCtrl{
    
    public String templateName{get;set;}
    public ID recordId{get;set;}
    private String announcementId;
   
    public GoalObjectiveAnnualReportCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');
        system.debug('id in url is ' +recordId);
       //Award__c award = [Select Application__r.Announcement__c from Award__c where id=:recordId];
       announcementId = ApexPages.CurrentPage().getParameters().get('id');
       system.debug('announcementId is ' +announcementId);
    }
    
    public string getKeyValueMap(){
        Map<String,Object> keyValueMap = new Map<String,Object>();
        //system.debug('awardId is ' +ApexPages.CurrentPage().getParameters().get('awardId'));
        //keyValueMap.put('awardId',ApexPages.CurrentPage().getParameters().get('awardId'));
        keyValueMap.put('recordId',recordId);
        //keyValueMap.put('parentId',recordId);
        keyValueMap.put('id',announcementId);
        return JSON.serialize(keyValueMap);
    }
}