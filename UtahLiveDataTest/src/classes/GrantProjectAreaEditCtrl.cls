public with sharing class GrantProjectAreaEditCtrl {
    public ID recordId{get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    public String pageTemplateName {get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    
    public GrantProjectAreaEditCtrl(ApexPages.StandardController stdController){
    
        
        recordId = ApexPages.CurrentPage().getParameters().get('id');   
        pageTemplateName = 'GrantProjectArea';//TODO get template dynamically from sObjectConfig
        
        savePage = Page.GrantProjectAreaView;
        savePage.getParameters().put('id', recordId); 
        
        if (!String.isEmpty(recordId)) {
           
            cancelPage = Page.GrantProjectAreaView;
            cancelPage.getParameters().put('id', recordId);   
        }

        listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
        
        Id grantId = ApexPages.CurrentPage().getParameters().get('grantId');
        if (grantId != null){
            GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Grant__c',grantId,true);
            listDefaultValues.add(dv);
        }
        
        
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        return JSON.serialize(keyValueMap);
    }
    

}