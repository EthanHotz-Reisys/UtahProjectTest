public with sharing class ReviewStepTemplateEditCtrl {
    
    //Properties
    public ID recordId{get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    public String recordType {get;set;}
    public String packageId {get;set;}
    public String pageTemplateName {get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    
    public ReviewStepTemplateEditCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');   
        savePage = Page.ReviewStepTemplateView;
        savePage.getParameters().put('id', recordId);
        string programId = ApexPages.CurrentPage().getParameters().get('programid');
        string announcementId = ApexPages.CurrentPage().getParameters().get('announcementId');                  
        List<BusinessPackage__c> bizPkg = [Select Id,Name,PackageConfig__c from BusinessPackage__c where PackageType__c ='App-Review' limit 1];
        if(bizPkg!=null && bizPkg.size()>0){
                packageId=bizPkg[0].PackageConfig__c;
            }            
        pageTemplateName='ReviewStepTemplate';        
        ReviewStepTemplate__c reviewStepTemplate = (ReviewStepTemplate__c)stdController.getRecord();                        
        if(stdController.getId() != null){ // Edit existing
            recordType =  Schema.SObjectType.reviewStepTemplate__c.getRecordTypeInfosById().get(reviewStepTemplate.RecordTypeId).getName().toLowercase();
            listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
            cancelPage = Page.ReviewStepTemplateView;
            cancelPage.getParameters().put('id', recordId);
        }else{    // create New
            recordType = ApexPages.CurrentPage().getParameters().get('recordType').toLowercase();
            if(recordType != null){
                if(recordType == 'pre-application'){
                    reviewStepTemplate.RecordTypeId = Schema.SObjectType.ReviewStepTemplate__c.getRecordTypeInfosByName().get('Pre-Application').getRecordTypeId();
                }else if(recordType == 'application'){
                    reviewStepTemplate.RecordTypeId = Schema.SObjectType.ReviewStepTemplate__c.getRecordTypeInfosByName().get('Application').getRecordTypeId();
                }                
                listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
                GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper('RecordTypeId',reviewStepTemplate.RecordTypeId,true);
                listDefaultValues.add(dv);
                if(programId != null){
                    GNT.DynamicLayoutDefaultValueHelper dv1 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Program__c',programId,true);
                    listDefaultValues.add(dv1); 
                    List<AggregateResult> aggResultList = [SELECT COUNT(Id) cnt FROM ReviewStepTemplate__c WHERE Program__c =:programId AND RecordTypeId =:reviewStepTemplate.RecordTypeId GROUP BY Program__c];
	                Integer stepNumber = 1;
	                if(aggResultList != null && aggResultList.size() > 0){
	                    stepNumber = (Integer)aggResultList[0].get('cnt');
	                    stepNumber = stepNumber + 1;
	                }
	                GNT.DynamicLayoutDefaultValueHelper dv2 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'StepNumber__c',stepNumber,true);
	                listDefaultValues.add(dv2);
                    pageTemplateName='ReviewStepTemplate';
                }                  
                if(announcementId != null){
                    GNT.DynamicLayoutDefaultValueHelper dv1 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Announcement__c',announcementId,true);
                    listDefaultValues.add(dv1); 
                    List<AggregateResult> aggResultList = [SELECT COUNT(Id) cnt FROM ReviewStepTemplate__c WHERE Announcement__c =:announcementId AND RecordTypeId =:reviewStepTemplate.RecordTypeId GROUP BY Announcement__c];	               
	                Integer stepNumber = 1;
	                if(aggResultList != null && aggResultList.size() > 0){
	                    stepNumber = (Integer)aggResultList[0].get('cnt');
	                    stepNumber = stepNumber + 1;
	                }
	                GNT.DynamicLayoutDefaultValueHelper dv2 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'StepNumber__c',stepNumber,true);
	                listDefaultValues.add(dv2);
                    pageTemplateName='ReviewStepTemplateAnn';
                }  
            }
            cancelPage = Page.ProgramView;
            cancelPage.getParameters().put('id', 'recordId');
        }      
           if(programId != null){
                 pageTemplateName='ReviewStepTemplate';
                }
           if(announcementId!=null){
                 pageTemplateName='ReviewStepTemplateAnn';
                }
          savePage.getParameters().put('programId', programId);
          savePage.getParameters().put('announcementId', announcementId);
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('reviewStepId',ApexPages.currentPage().getParameters().get('id'));       
        return JSON.serialize(keyValueMap);
    }        
}