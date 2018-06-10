public with sharing class FOLevelPostAwardTemplateAssignmentCtrl{
  
  //Properties
    public ID recordId{get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    
    public Map<String,String> keyValueMap = new Map<String,String>();
    
    public FOLevelPostAwardTemplateAssignmentCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');   

        savePage = Page.AnnouncementView;
        savePage.getParameters().put('Id', recordId);
        cancelPage = Page.AnnouncementView;
        cancelPage.getParameters().put('Id', recordId);                                    
    }
    
    public string getKeyValueMap(){
      Map<String,String> keyValueMap = new Map<String,String>();
        String id = ApexPages.currentPage().getParameters().get('id');
        keyValueMap.put('id',id);
        return JSON.serialize(keyValueMap);
    }

}