public with sharing class ReviewStepTemplateViewCtrl{

    public ID recordId {get;set;}
    public String recordType {get;set;}
    public String packageId {get;set;}
    public String announcementId {get;set;}
    public String programId {get;set;}
    public String pageTemplateName {get;set;}
    
    public ReviewStepTemplateViewCtrl(ApexPages.StandardController stdController) {     
        recordId = ApexPages.CurrentPage().getParameters().get('id');
        ReviewStepTemplate__c rstObj = (ReviewStepTemplate__c)stdController.getRecord();

    List<BusinessPackage__c> bizPkg = [Select Id,Name,PackageConfig__c from BusinessPackage__c where PackageType__c ='App-Review' limit 1];
            if(bizPkg!=null && bizPkg.size()>0){
                packageId=bizPkg[0].PackageConfig__c;
            }
           		pageTemplateName='ReviewStepTemplate';
                programId = ApexPages.CurrentPage().getParameters().get('programid');
                announcementId = ApexPages.CurrentPage().getParameters().get('announcementId');                                   
               if(programId != null){
                 pageTemplateName='ReviewStepTemplate';
                }
                if(announcementId!=null){
                pageTemplateName='ReviewStepTemplateAnn';
                }

        	if(stdController.getId() != null){ // View mode
            	recordType =  Schema.SObjectType.ReviewStepTemplate__c.getRecordTypeInfosById().get(rstObj.RecordTypeId).getName().toLowercase();
		       }
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('reviewStepId',ApexPages.currentPage().getParameters().get('id'));
        keyValueMap.put('recordType',recordType);
        keyValueMap.put('announcementId',announcementId);
        keyValueMap.put('programId',programId);
        return JSON.serialize(keyValueMap);
    }        
}