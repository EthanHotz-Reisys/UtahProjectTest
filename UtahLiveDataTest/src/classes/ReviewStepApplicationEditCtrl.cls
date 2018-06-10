public with sharing class ReviewStepApplicationEditCtrl {
    //Properties
    public ID recordId{get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    public  string templateName {get;set;}
    
    public ReviewStepApplicationEditCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');   
        
         savePage = Page.ReviewStepApplicationView;
        savePage.getParameters().put('id', recordId);
        if(recordId != null){
            cancelPage = Page.ReviewStepApplicationView;
            cancelPage.getParameters().put('id', recordId);
            
        }


          String type = ApexPages.CurrentPage().getParameters().get('type');
        if(type!=null && type=='RejectedApp')
         {
         templateName = 'ReviewStepApplication_RejectedApp';
         }
         else
         {
         templateName = 'ReviewStepApplication';
         } 
    
  
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('reviewStepApplicationId',ApexPages.currentPage().getParameters().get('id'));
        return JSON.serialize(keyValueMap);
    }
}