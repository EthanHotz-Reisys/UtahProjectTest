public with sharing class PrintGoalsAndObjCtrl{
    
    public String templateName{get;set;}
    public ID recordId{get;set;}
    private String announcementId;
   
    public PrintGoalsAndObjCtrl(ApexPages.StandardController stdController){
    	recordId = ApexPages.CurrentPage().getParameters().get('awardId');
       Award__c award = [Select Application__r.Announcement__c from Award__c where id=:recordId];
       announcementId = award.Application__r.Announcement__c;
       system.debug('announcementId is ' +announcementId);
    }
    
    public string getKeyValueMap(){
        Map<String,Object> keyValueMap = new Map<String,Object>();
        system.debug('awardId is ' +ApexPages.CurrentPage().getParameters().get('awardId'));
        keyValueMap.put('awardId',ApexPages.CurrentPage().getParameters().get('awardId'));
        keyValueMap.put('recordId',recordId);
        keyValueMap.put('announcementId',announcementId);
        return JSON.serialize(keyValueMap);
    }
}