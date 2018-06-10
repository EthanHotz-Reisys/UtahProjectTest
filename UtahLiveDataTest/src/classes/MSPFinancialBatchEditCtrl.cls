public with sharing class MSPFinancialBatchEditCtrl {
    
    public String recordId{get;set;}
    public String pageTemplateName {get;set;}
    public PageReference savePage{get;set;}
    public String cancelPage{get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}

    public MSPFinancialBatchEditCtrl(ApexPages.StandardController stdController) {
        recordId = ApexPages.CurrentPage().getParameters().get('id');
        pageTemplateName = 'FileBatchEdit';
        Id MSPRecordTypeId = Schema.SObjectType.FileBatch__c.getRecordTypeInfosByName().get('Fed Formula').getRecordTypeId();
        listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
        GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper('RecordTypeId',MSPRecordTypeId,true);
        listDefaultValues.add(dv);
    }

    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>(); 
        return JSON.serialize(keyValueMap);
    }
}