public with sharing class FINETVendorLinkEditCtrl{
    public ID recordId{get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    public String pageTemplateName {get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    
    public FINETVendorLinkEditCtrl(ApexPages.StandardController stdController){
    
        
        recordId = ApexPages.CurrentPage().getParameters().get('id');   
        pageTemplateName = 'FINETVendorLinkEdit';//TODO get template dynamically from sObjectConfig
        
        //savePage = Page.GrantProjectAreaView;
        //savePage.getParameters().put('id', recordId); 
        
       // if (!String.isEmpty(recordId)) {
           
            //cancelPage = Page.GrantProjectAreaView;
            //cancelPage.getParameters().put('id', recordId);   
        //}

        listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
        
        
          Id accountID = ApexPages.CurrentPage().getParameters().get('accountid');
          
        if (accountID != null){
            GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Account__c',accountID,true);
            listDefaultValues.add(dv);
        }
        
        
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        return JSON.serialize(keyValueMap);
    }
    

}