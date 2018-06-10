public with sharing class CloseoutExtensionCtrl {

    //properties
    public ID recordId{get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    public String pageTemplateName {get;set;}
    public CloseOut__c closeOut{get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    
    public CloseoutExtensionCtrl(ApexPages.StandardController controller) {
        recordId = ApexPages.CurrentPage().getParameters().get('id');
        if(recordId != null){
            Closeout__c closeout = [Select Id, Name,Status__c, Duedate__c from Closeout__c where Id=:recordId];
             pageTemplateName = 'Closeout Extension';                 
        }else{
           pageTemplateName = 'Closeout Extension';            
        }

        savePage = Page.CloseoutRequestView;
        savePage.getParameters().put('id', recordId);
        savePage.getParameters().put('template', pageTemplateName);
        cancelPage = Page.CloseoutRequestView;
        cancelPage.getParameters().put('id', recordId);
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        if(recordId != null){
            keyValueMap.put('closeoutId',recordId);
        }
        return JSON.serialize(keyValueMap);
    }
}