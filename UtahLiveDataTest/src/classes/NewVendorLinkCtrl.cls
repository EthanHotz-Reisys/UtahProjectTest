public with sharing class NewVendorLinkCtrl {
    
    public String recordId{get;set;}
    public String ein {get;set;}
    public String pageTemplateName {get;set;}
    public String savePage{get;set;}
    public String cancelPage{get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}

    public NewVendorLinkCtrl(ApexPages.StandardController stdController) {
        recordId = ApexPages.CurrentPage().getParameters().get('id');
        pageTemplateName = 'NewFINETVendorLinkForm';
        
        
         listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
         
          Id accountID = ApexPages.CurrentPage().getParameters().get('accountid');
          ein= ApexPages.CurrentPage().getParameters().get('ein');
          
          
        if (accountID != null){
            GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Account__c',accountID,true);
            listDefaultValues.add(dv);
             
        }
       
        
        
    }

    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>(); 
        keyValueMap.put('ein',ein);
        return JSON.serialize(keyValueMap);
    }
}