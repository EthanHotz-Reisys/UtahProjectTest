public with sharing class ReviewerRegistrationViewCtrl{
  public ID recordId{get;set;}
    public PageReference deleteURL{get;set;}
    public String pageTemplateName {get;set;}
    public boolean dummy4{get;set;}
   
    
    
    public ReviewerRegistrationViewCtrl(ApexPages.StandardController stdController){
        dummy4 = false;
        recordId = ApexPages.CurrentPage().getParameters().get('id'); 
        String tempLayout= ApexPages.CurrentPage().getParameters().get('tempLayout'); 
       
        
        if(tempLayout <> null){
        
            if(tempLayout == '1'){
               // pageTemplateName = 'Applicant Org Detail';
                pageTemplateName = 'External Reviewer COI';
               
            }
            if(tempLayout == '2'){
                pageTemplateName = 'Applicant Profile Detail';
            }
              if(tempLayout == '3'){
                pageTemplateName = 'Applicant Confirmation';
            }
            
           
        }
        else{
            pageTemplateName = 'External Reviewer Edit';//TODO get template dynamically from sObjectConfig
        }
    }
    
   /* public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('BudgetPeriodid',recordId);
        return JSON.serialize(keyValueMap);
    } */

}