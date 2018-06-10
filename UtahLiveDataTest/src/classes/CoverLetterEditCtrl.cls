public with sharing class CoverLetterEditCtrl {
    
    public ID recordId{get;set;}
    public String pageTemplateName {get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    
    public CoverLetterEditCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');
        pageTemplateName = ApexPages.CurrentPage().getParameters().get('templateName');   

       
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('CoverLetterId',ApexPages.currentPage().getParameters().get('id'));
        return JSON.serialize(keyValueMap);
    }
}