public with sharing class ApplicationReviewViewCtrl {
    
    //Properties
    public ID recordId{get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    public String pageTemplateName {get;set;}
    public String type {get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    
    public ApplicationReviewViewCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');    
        type = ApexPages.CurrentPage().getParameters().get('type');
        if(type == 'FOA'){
            pageTemplateName = 'LeadEvaluation';
        }else{
            pageTemplateName = 'Review';  
        }
       //TODO get template dynamically from sObjectConfig
          
        savePage = Page.ApplicationReviewView;
        savePage.getParameters().put('id', recordId); 
        
        if (!String.isEmpty(recordId)) { 
            cancelPage = Page.ApplicationReviewView; 
            cancelPage.getParameters().put('id', recordId);   
        }

        listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
        
        Id applicationid = ApexPages.CurrentPage().getParameters().get('applicationid'); 
        if (applicationid != null){  
            
            GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'ApplicationReview__c',applicationid,true);
            listDefaultValues.add(dv);  
        }         
    } 

     public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('applicationid',ApexPages.currentPage().getParameters().get('id'));
        return JSON.serialize(keyValueMap);
    } 
}