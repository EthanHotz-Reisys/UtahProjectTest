public with sharing class PaymentRequestBudgetPrintCtrl{
    
    //Properties
    public ID recordId{get;set;}
    public PageReference deleteURL{get;set;}
    public String pageTemplateName {get;set;}
    public String packageId {get;set;}
     public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
     public ID parentId{get;set;}
     public ID payId{get;set;}
     
    
    public PaymentRequestBudgetPrintCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id'); 
        parentId = recordId;
        
  }
    
    public string getKeyValueMap(){
        
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('parentid',ApexPages.currentPage().getParameters().get('id'));
        keyValueMap.put('payId',ApexPages.currentPage().getParameters().get('id'));
        return JSON.serialize(keyValueMap);
    }
}