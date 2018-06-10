public without sharing class CommunityUserRegApproveCtrl {
    
    public String recordId{get;set;}
    public String templateName{get;set;}
    public Id recordTypeForApplicant;
    public Id recordTypeForReviewer;
    public Id currentRecordType;
    
    public CommunityUserRegApproveCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.currentPage().getParameters().get('id');
        recordTypeForApplicant = Schema.SObjectType.UserRegistration__c.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
        recordTypeForReviewer = Schema.SObjectType.UserRegistration__c.getRecordTypeInfosByName().get('Reviewer').getRecordTypeId();
        if(recordId != null){
            UserRegistration__c record = [SELECT Id,Name,RecordTypeId FROM UserRegistration__c WHERE Id = :recordId];           
            if(record != null){
                currentRecordType = record.RecordTypeId;
                if(currentRecordType != null){
                    if(currentRecordType == recordTypeForReviewer){
                        templateName = 'UserRegistrationForReviewers';
                    }else if(currentRecordType == recordTypeForApplicant){
                        templateName = 'UserRegistration';
                    }
                }else{
                    templateName = 'UserRegistration';
                }
            }           
        }
    }

}