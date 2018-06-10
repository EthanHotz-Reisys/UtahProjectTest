public with sharing class TeamingPartnerViewCtrl {
	public ID recordId{get;set;}
    public PageReference deleteURL{get;set;}
    public String pageTemplateName {get;set;}
    
    public TeamingPartnerViewCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id'); 
        pageTemplateName ='TeamingPartner';//TODO get template dynamically from sObjectConfig
        deleteURL = null;
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('teamingpartnerid',recordId);
        return JSON.serialize(keyValueMap);
    }

}