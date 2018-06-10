public with sharing class GranteeContactEditCtrl {
    public ID recordId{get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    public String pageTemplateName {get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    
    public GranteeContactEditCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');
        pageTemplateName = 'Grantee Contact';//TODO get template dynamically from sObjectConfig
            savePage = Page.GranteeContactView;
            savePage.getParameters().put('id', recordId); 
            if (cancelPage == null && recordId != null) {
            cancelPage = Page.GranteeContactView; 
            cancelPage.getParameters().put('id', recordId); 
            } 
            else {
            String retURL = ApexPages.CurrentPage().getParameters().get('retURL');
            if(retURL != null) {
                cancelPage = new PageReference(retURL);    
             }
            }
            String orgId = ApexPages.CurrentPage().getParameters().get('orgid');
            listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
            if(!String.isEmpty(orgId)){
                GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper('AccountId', orgId, true);
                listDefaultValues.add(dv);
            }
        
    }
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('Contactid',ApexPages.currentPage().getParameters().get('id'));
        return JSON.serialize(keyValueMap);
    }    
}