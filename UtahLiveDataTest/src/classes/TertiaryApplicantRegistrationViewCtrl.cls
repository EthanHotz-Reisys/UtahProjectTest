public with sharing class TertiaryApplicantRegistrationViewCtrl {
    public ID recordId{get;set;}
    public PageReference deleteURL{get;set;}
    public String pageTemplateName {get;set;}
 
   
    
    
    public TertiaryApplicantRegistrationViewCtrl(ApexPages.StandardController stdController){
       recordId = ApexPages.CurrentPage().getParameters().get('id'); 
       String tempLayout= ApexPages.CurrentPage().getParameters().get('tempLayout'); 
        pageTemplateName = 'Tertiary Confirmation';
       
    }
    
  

}