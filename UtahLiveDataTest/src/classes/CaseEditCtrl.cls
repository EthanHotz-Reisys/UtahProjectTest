/*
  <Purpose of this class>    
    *******************************************************************************************************************
    Audit History
    ********************************************************************************************************************
    2017-04-01  Shah Kadirmohideen  Code Reviewed
    **********************************************************************************************************************  
*/ 
public with sharing class CaseEditCtrl {
    
    //Properties
    public ID recordId{get;set;}
    public String recordType {get;set;}
    public PageReference savePage {get;set;}
    public String pageTemplateName {get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    public PageReference cancelPage {get;set;}
   
    public CaseEditCtrl(ApexPages.StandardController stdController) {
        recordId = ApexPages.CurrentPage().getParameters().get('id');   
        String relatedRecordId = ApexPages.CurrentPage().getParameters().get('relatedRecordId');   
        savePage = Page.CaseView;
        savePage.getParameters().put('id', recordId);  

        if(recordId==null) {          // Create Context
	        pageTemplateName='CreateCase-custom';
	        listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
	        GNT.DynamicLayoutDefaultValueHelper dv1 = new GNT.DynamicLayoutDefaultValueHelper('ReportedBy__c',UserInfo.getUserId(),true);
	        listDefaultValues.add(dv1);
	        dv1 = new GNT.DynamicLayoutDefaultValueHelper('Status__c', 'New', true);
	        listDefaultValues.add(dv1);
	        dv1 = new GNT.DynamicLayoutDefaultValueHelper('Origin__c', 'Web', true);
	        listDefaultValues.add(dv1);
	        if(!String.isEmpty(relatedRecordId)) {
	        	GNT.DynamicLayoutDefaultValueHelper relatedRecId = new GNT.DynamicLayoutDefaultValueHelper('RelatedRecordId__c', relatedRecordId, true);
	        	listDefaultValues.add(relatedRecId);
	        }
        } else {  //Editing a record
        	pageTemplateName='CaseTechSupport-Custom';
        }
    }
    
    public string getKeyValueMap() {
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('recordId', recordId);      
        return JSON.serialize(keyValueMap);
    }
}