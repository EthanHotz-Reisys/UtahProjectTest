public with sharing class ReviewPanelEditCtrl {
    
    //Properties
    public ID recordId{get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    public String recordType {get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    public String templateName{get;set;}
    
    public ReviewPanelEditCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');   
        Id steptemplateId = ApexPages.CurrentPage().getParameters().get('reviewStepId'); 
        System.debug('recordId--->>>'+recordId);  
        System.debug('steptemplateId--->>>'+steptemplateId);  
        
        savePage = Page.ReviewStepView;
        savePage.getParameters().put('id', steptemplateId);
        
        ReviewPanel__c reviewPanel = (ReviewPanel__c)stdController.getRecord();
                        
        if(stdController.getId() != null){ // Edit existing
            reviewPanel = [select id,Name, ReviewStep__c, RecordTypeId,PanelLayout__r.Name from ReviewPanel__c where id =: recordId limit 1];
            templateName = reviewPanel.PanelLayout__r.Name;
            recordType =  Schema.SObjectType.ReviewPanel__c.getRecordTypeInfosById().get(reviewPanel.RecordTypeId).getName().toLowercase();
            
            String backtostep = ApexPages.CurrentPage().getParameters().get('backtostep');   
            if (!String.isEmpty(backtostep)) {
                savePage = Page.ReviewStepView;
                savePage.getParameters().put('id', reviewPanel.ReviewStep__c);
                cancelPage = Page.ReviewStepView;
                cancelPage.getParameters().put('id', reviewPanel.ReviewStep__c);
            }
            else{
                savePage = Page.ReviewPanelView;
                savePage.getParameters().put('id', recordId);
                cancelPage = Page.ReviewPanelView;
                cancelPage.getParameters().put('id', recordId);  
            }
        }else{    // create New
            recordType = ApexPages.CurrentPage().getParameters().get('recordType').toLowercase();
            if(recordType != null){
                ReviewStep__c revStep = [Select ReviewPackage__c, UserType__c From ReviewStep__c Where Id = :steptemplateId LIMIT 1];
                
                if(recordType == 'preapplication'){
                    reviewPanel.RecordTypeId = Schema.SObjectType.ReviewPanel__c.getRecordTypeInfosByName().get('Pre-Application').getRecordTypeId();
                    templateName = 'Review Panel Pre-Application';
                }else if(recordType == 'application'){
                    reviewPanel.RecordTypeId = Schema.SObjectType.ReviewPanel__c.getRecordTypeInfosByName().get('Application').getRecordTypeId();
                    templateName = 'Review Panel Application Template';
                  //  templateName = 'Review Panel Application';
                }
                listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
                GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper('RecordTypeId',reviewPanel.RecordTypeId,true);
                listDefaultValues.add(dv); 
                 
                GNT.DynamicLayoutDefaultValueHelper dv1 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'ReviewStep__c',steptemplateId , true);
              //  GNT.DynamicLayoutDefaultValueHelper dv1 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'ReviewStepTemplate__c',steptemplateId , true);
                listDefaultValues.add(dv1);
                
                Id templateId = [Select id From GNT__PageTemplate__c where Name = :templateName LIMIT 1].Id;
                GNT.DynamicLayoutDefaultValueHelper dv2 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'PanelLayout__c',templateId , true);
                listDefaultValues.add(dv2);
                
                GNT.DynamicLayoutDefaultValueHelper dv3 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'ReviewPackage__c',revStep.ReviewPackage__c , true);
                listDefaultValues.add(dv3);
                
                GNT.DynamicLayoutDefaultValueHelper dv4 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'UserType__c',revStep.UserType__c , true);
                listDefaultValues.add(dv4);
            }
            cancelPage = Page.ReviewStepView;
            cancelPage.getParameters().put('id', steptemplateId);
        }        
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('reviewStepId',ApexPages.currentPage().getParameters().get('id'));
        keyValueMap.put('recordType',ApexPages.currentPage().getParameters().get('recordType'));
        return JSON.serialize(keyValueMap);
    }        
}