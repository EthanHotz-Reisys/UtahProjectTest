public with sharing class ExternalRegistrationConfirmationCtrl {
  public ID recordId{get;set;}
  public PageReference deleteURL{get;set;}
  public String pageTemplateName {get;set;}
 
   public ExternalRegistrationConfirmationCtrl (ApexPages.StandardController stdController){
       
        recordId = ApexPages.CurrentPage().getParameters().get('id'); 
        String tempLayout= ApexPages.CurrentPage().getParameters().get('tempLayout'); 
        pageTemplateName = 'Applicant Confirmation';
        
}
    
   /* public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('BudgetPeriodid',recordId);
        return JSON.serialize(keyValueMap);
    } */

}