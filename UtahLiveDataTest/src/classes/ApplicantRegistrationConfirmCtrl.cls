public with sharing class ApplicantRegistrationConfirmCtrl {
  public ID recordId{get;set;}
    public PageReference deleteURL{get;set;}
    public String pageTemplateName {get;set;}
    
 public ApplicantRegistrationConfirmCtrl(ApexPages.StandardController stdController){
       
        recordId = ApexPages.CurrentPage().getParameters().get('id'); 
        pageTemplateName = 'Applicant Confirmation';
        }
    
    
   

}