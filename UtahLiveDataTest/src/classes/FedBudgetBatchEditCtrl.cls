public with sharing class FedBudgetBatchEditCtrl{
    public String recordId{get;set;}
    public String pageTemplateName {get;set;}
    public String savePage{get;set;}
    public String cancelPage{get;set;}
    public String budgetType{get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}

    public FedBudgetBatchEditCtrl(ApexPages.StandardController stdController) {
        recordId = ApexPages.CurrentPage().getParameters().get('id');
        pageTemplateName = 'FedBudgetBatchEdit';
        budgetType = ApexPages.CurrentPage().getParameters().get('type');
        listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
        GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper('Type__c','FED',true);
        listDefaultValues.add(dv);

    }

    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>(); 
        return JSON.serialize(keyValueMap);
    }
}