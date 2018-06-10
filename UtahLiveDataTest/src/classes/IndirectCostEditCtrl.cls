public with sharing class IndirectCostEditCtrl {
    
    public String recordId{get;set;}
    public String pageTemplateName {get;set;}
    public String savePage{get;set;}
    public String cancelPage{get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}

    public IndirectCostEditCtrl(ApexPages.StandardController stdController) {
        recordId = ApexPages.CurrentPage().getParameters().get('id');
        pageTemplateName = 'IndirectCostRateForm';
        
        
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