public with sharing class FINETProgramEditCtrl{
    public ID recordId{get;set;}
    public String pageTemplateName {get;set;}
    public PageReference savePage{get;set;}
    public PageReference cancelPage{get;set;}
    public List<String> listDefaultValues {get;set;}
  
    
    public FINETProgramEditCtrl(ApexPages.StandardController stdController){
    
        
        recordId = ApexPages.CurrentPage().getParameters().get('id');   
        pageTemplateName = 'FINETProgramEdit';
        
         savePage = Page.FINETProgramView;
        savePage.getParameters().put('id', recordId);
        if (cancelPage == null && recordId != null) {
            cancelPage = Page.FINETProgramView;  
            cancelPage.getParameters().put('id', recordId); 
        }
            
        
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
         keyValueMap.put('finetprogramid',recordId);
        return JSON.serialize(keyValueMap);
    }
    

}