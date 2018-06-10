public with sharing class InternalUserRegistrationViewCtrl {
    public Id recordId {get; set;}
    public String pageTemplateName {get;set;}
    public InternalUserRegistrationViewCtrl(ApexPages.StandardController stdController) {
        recordId = ApexPages.CurrentPage().getParameters().get('id');
        UserRegistration__c userReg = [Select Id, Name,RecordType.DeveloperName from UserRegistration__c 
             where id =:recordId Limit 1];
        if(userReg.RecordType.Developername == 'Applicant'){
            pageTemplateName = 'GrantorUserRegistrationForm';
        } else if(userReg.RecordType.Developername == 'Reviewer'){
            pageTemplateName = 'InternalReviewerView';
        } else if (userreg.RecordType.Developername == 'IndApplicant'){
             pageTemplateName = 'InternalIndApplicantView';  
        }else if (userreg.RecordType.Developername == 'AdditionalApplicant' || userreg.RecordType.Developername == 'AdditionalApplicantSecondary' ){
             pageTemplateName = 'Add Applicant Profile';  
        } 
    }
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('userregid',ApexPages.currentPage().getParameters().get('id'));
    
        return JSON.serialize(keyValueMap);
    }
       
}