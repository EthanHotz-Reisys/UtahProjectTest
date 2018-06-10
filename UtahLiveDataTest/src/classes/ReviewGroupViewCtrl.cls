public with sharing class ReviewGroupViewCtrl {
    
    //Properties
    public ID recordId{get;set;}
    public ReviewGroup__c reviewGrp{get;set;}
    public String recordType {get;set;}
    public String templateName {get;set;}
    
    public ReviewGroupViewCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');   
        Id announcementId = ApexPages.CurrentPage().getParameters().get('announcementid');   
        system.debug('---recordId ---'+recordId );
         system.debug('---announcementId ---'+announcementId );
         
        If(announcementId!=null)
        {
        reviewGrp = [SELECT ID,Name,Announcement__c,RecordType.Name FROM ReviewGroup__c WHERE Announcement__c = :announcementId];
        recordId =reviewGrp.Id;
        }
        if(recordId != null){
            reviewGrp = [SELECT ID,Name,Announcement__c,RecordType.Name FROM ReviewGroup__c WHERE Id = :recordId];
            recordType = reviewGrp.RecordType.Name;
            if(recordType != null && recordType == 'Application') {
                templateName = 'ApplicationReviewGroup';
            } else if(recordType != null && recordType == 'Pre-Application') {
                templateName = 'PreapplicationReviewGroup';
            }
        }
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('reviewGroupId',recordId);
        keyValueMap.put('announcementId',reviewGrp.Announcement__c);
        Id reviewStepRecordTypeId;
        if(recordType=='Application'){
            reviewStepRecordTypeId = Schema.SObjectType.ReviewStep__c.getRecordTypeInfosByName().get('Application').getRecordTypeId();            
        }else if(recordType=='Pre-Application'){
            reviewStepRecordTypeId = Schema.SObjectType.ReviewStep__c.getRecordTypeInfosByName().get('Pre-Application').getRecordTypeId();
        }
        keyValueMap.put('recordTypeId',reviewStepRecordTypeId);
        return JSON.serialize(keyValueMap);
    }
}