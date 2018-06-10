public with sharing class SF425FormEditCtrl {
    
    public ID recordId{get;set;}
    public String pageTemplateName {get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    //public Form__c fobj {get;set;}
    
    public SF425FormEditCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');
        pageTemplateName = ApexPages.CurrentPage().getParameters().get('templateName'); 
        //fobj.TemplateName__c=pageTemplateName;
        savePage = Page.SF425FormView;
        savePage.getParameters().put('id', recordId);
        System.debug('recordIdforBudgetis : ' + recordId);

        savePage.getParameters().put('templateName',pageTemplateName);
        cancelPage = Page.SF425FormView;
        cancelPage.getParameters().put('id', recordId);
        cancelPage.getParameters().put('templateName',pageTemplateName);
       
    }
    
   
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('SF425FormId',ApexPages.currentPage().getParameters().get('id'));
        keyValueMap.put('SF425FormTemplate',ApexPages.currentPage().getParameters().get('templateName'));
        return JSON.serialize(keyValueMap);
    }
}