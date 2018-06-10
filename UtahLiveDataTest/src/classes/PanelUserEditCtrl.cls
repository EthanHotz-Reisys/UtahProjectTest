public with sharing class PanelUserEditCtrl {
    public ID recordId {get;set;}
    public String pageTemplateName {get;set;}
    public PageReference deleteURL{get;set;}
     public PageReference savePage {get;set;}
    
    public PanelUserEditCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.currentPage().getParameters().get('id');
        pageTemplateName = 'ReviewerTemplate';
        deleteURL = null; 
        
        savePage = Page.PanelUserView;
        savePage.getParameters().put('id', recordId); 
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('ContactId', ApexPages.currentPage().getParameters().get('id'));
        return JSON.serialize(keyValueMap);
    }
}