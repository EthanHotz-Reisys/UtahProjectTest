public with sharing class PreAwardSubmissionRequestCommentsCtrl{
  
  //Properties
    public ID recordId{get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    
    public Map<String,String> keyValueMap = new Map<String,String>();    
    
    public PreAwardSubmissionRequestCommentsCtrl(ApexPages.StandardController stdController){
                                    
        recordId = ApexPages.CurrentPage().getParameters().get('Id');
        String applicationId = ApexPages.CurrentPage().getParameters().get('applicationId');
        system.debug('recordId---------->>>>>'+recordId);
        savePage = Page.ApplicationView;
        savePage.getParameters().put('Id', applicationId);
        cancelPage = Page.ApplicationView;
        cancelPage.getParameters().put('Id', applicationId);          
    }
    
    public string getKeyValueMap(){
      Map<String,String> keyValueMap = new Map<String,String>();
        String id = ApexPages.currentPage().getParameters().get('id');
        keyValueMap.put('id',id);
          
        return JSON.serialize(keyValueMap);
    }
  
}