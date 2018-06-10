public with sharing class SiteVisitScheduleViewCtrl {
    
    
    //Properties
    public ID recordId{get;set;}
        
    public SiteVisitScheduleViewCtrl (ApexPages.StandardController controller) {
        recordId = ApexPages.CurrentPage().getParameters().get('id');
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('siteVisitScheduleId',recordId ); 
        return JSON.serialize(keyValueMap);
    }

}