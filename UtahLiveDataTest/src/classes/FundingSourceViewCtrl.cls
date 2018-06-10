public with sharing class FundingSourceViewCtrl {
    //Properties
    public ID recordId{get;set;}
    public String pageTemplateName {get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    
    public FundingSourceViewCtrl(ApexPages.StandardController stdController){
       recordId = ApexPages.CurrentPage().getParameters().get('id');
        FundingSource__c funsource = [select Id,Name,Type__c from FundingSource__c where Id=:recordId];
        if(funsource.Type__c != null && (funsource.Type__c == 'Federal' || funsource.Type__c == 'NGO')){
          pageTemplateName = 'FundingSource';
        }else{
          pageTemplateName = 'GrantorFundingSource';
        }            
        savePage = Page.FundingSourceView;
        savePage.getParameters().put('id', recordId);
        cancelPage = Page.FundingSourceView;
        cancelPage.getParameters().put('id', recordId); 
    }
    
    /*
        Method to populate the parameters for the FlexTable
    */
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        if(recordId != null){
            keyValueMap.put('fundingSourceId',recordId);
        }
        return JSON.serialize(keyValueMap);
    }
}