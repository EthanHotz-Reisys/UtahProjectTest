public with sharing class ReviewPanelUserTemplateViewCtrl{
    
    public ID recordId {get;set;}
    
     public ReviewPanelUserTemplateViewCtrl(ApexPages.StandardController stdController) {     
        recordId = ApexPages.CurrentPage().getParameters().get('id');
     }
     
     public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('reviewPanelUserId',ApexPages.currentPage().getParameters().get('id'));
        return JSON.serialize(keyValueMap);
    }
}