public with sharing class SiteVisitScheduleEditCtrl {

    public ID recordId{get;set;}
    public PageReference savePage {get;set;}    
    
    public SiteVisitScheduleEditCtrl (ApexPages.StandardController controller) {
        recordId = ApexPages.CurrentPage().getParameters().get('id');
        savePage = Page.SiteVisitScheduleView;
        savePage.getParameters().put('id',recordId);
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('siteVisitScheduleId',recordId ); 
        return JSON.serialize(keyValueMap);
    }

}