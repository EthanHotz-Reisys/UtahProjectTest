public with sharing class FundingAllocationPlanCtrl {
    public ID recordId{get;set;} 
    public PageReference savePage {get;set;} 
    public PageReference cancelPage {get;set;}
    public String pageTemplateName {get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
     
    public FundingAllocationPlanCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');   
        pageTemplateName = 'Funding Allocation Plan';      

      
    }
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>(); 
      //  keyValueMap.put('preapplicationid',ApexPages.currentPage().getParameters().get('id'));
        return JSON.serialize(keyValueMap);  
    }
}