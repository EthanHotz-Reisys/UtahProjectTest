public with Sharing class ApplicationServiceAreaEditCtrl{
    public ID recordId {get; set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    
    public ApplicationServiceAreaEditCtrl(ApexPages.StandardController stdController){
         recordId = ApexPages.currentPage().getParameters().get('id');
         
         savePage = Page.ApplicationServiceAreaView;
        savePage.getParameters().put('id', recordId); 
        
        if (!String.isEmpty(recordId)) {
            cancelPage = Page.ApplicationServiceAreaView;
            cancelPage.getParameters().put('id', recordId);   
        }
         
    }
    
    
    public String getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('id',recordId);
        return JSON.serialize(keyValueMap);
    }
}