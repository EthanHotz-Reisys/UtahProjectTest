public with sharing class ReviewPanelTemplateEditCtrl {
    
    //Properties
    public ID recordId{get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    public String recordType {get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    
    public ReviewPanelTemplateEditCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');   
        Id steptemplateId = ApexPages.CurrentPage().getParameters().get('reviewStepId');   
        savePage = Page.ReviewPanelTemplateView;
        savePage.getParameters().put('id', recordId);
        system.debug('--steptemplateId---'+steptemplateId);
        system.debug('--recordId---'+recordId);
        cancelPage = Page.ReviewPanelTemplateView;
        ReviewPanelTemplate__c reviewPanelTemplate = (ReviewPanelTemplate__c)stdController.getRecord();
        if(stdController.getId() != null){ // Edit existing
            recordType =  Schema.SObjectType.reviewPanelTemplate__c.getRecordTypeInfosById().get(reviewPanelTemplate.RecordTypeId).getName().toLowercase();
            listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();            
            cancelPage.getParameters().put('id', recordId);
        }else{    // create New
            recordType = ApexPages.CurrentPage().getParameters().get('recordType').toLowercase();
            system.debug('--recordType---'+recordType);
            if(recordType != null){
                if(recordType == 'pre-application'){
                    reviewPanelTemplate.RecordTypeId = Schema.SObjectType.ReviewPanelTemplate__c.getRecordTypeInfosByName().get('Pre-Application').getRecordTypeId();
                }else if(recordType == 'application'){
                    reviewPanelTemplate.RecordTypeId = Schema.SObjectType.ReviewPanelTemplate__c.getRecordTypeInfosByName().get('Application').getRecordTypeId();
                }                
                listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
                GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper('RecordTypeId',reviewPanelTemplate.RecordTypeId,true);
                listDefaultValues.add(dv);  
                GNT.DynamicLayoutDefaultValueHelper dv1 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'ReviewStepTemplate__c',steptemplateId , true);
                listDefaultValues.add(dv1);
                  
            }
            
            cancelPage.getParameters().put('id', 'recordId');
        }     
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('reviewPanelId',ApexPages.currentPage().getParameters().get('id'));
       // keyValueMap.put('recordType','Application');
        return JSON.serialize(keyValueMap);
    }        
}