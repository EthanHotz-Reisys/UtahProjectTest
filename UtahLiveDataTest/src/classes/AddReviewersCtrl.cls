public with sharing class AddReviewersCtrl{
    
    //Properties
   // public String reviewType {get;set;}
    public String revPanelId {get;set;}
    public ID recordId{get;set;}
    public String pageTemplateName {get;set;}
    private Set<String> recordsIdSet;
    public boolean SMEReview {get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    private List<String> userList;
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    public AddReviewersCtrl(ApexPages.StandardController stdController){

         recordId = ApexPages.CurrentPage().getParameters().get('id');
         revPanelId = ApexPages.CurrentPage().getParameters().get('revPanelId');
         String reviewType=ApexPages.CurrentPage().getParameters().get('reviewType'); 
         system.debug('--reviewType-'+reviewType);
         List<PanelUser__c> panelUsers =[Select Id, Name,Reviewer__r.Username, Reviewer__r.name, Reviewer__r.Id from PanelUser__c where ReviewPanel__c=:revPanelId];
         userList=new List<String>();
         SMEReview = false;
         for(PanelUser__c pu : panelUsers){
            userList.add(pu.Reviewer__r.Id);
          }
          Map<Id,User>  userMap = new Map<Id,User> ([Select Id, Name from User where Id Not in :userList]);
          recordsIdSet = (Set<String>)JSON.deserialize(JSON.serialize(userMap.keyset()), Set<String>.class); 
     
     if(reviewType=='Internal'){
        pageTemplateName = 'Add Internal Reviewer';
        
     }
     else if(reviewType=='SME'){
        pageTemplateName = 'Add SME Reviewer';
        SMEReview = true;
     }
     else{
        pageTemplateName = 'Add Internal Reviewer';
     }        
        savePage = Page.ReviewPanelView;
        savePage.getParameters().put('id', recordId); 
        cancelPage = Page.ReviewPanelView;
        cancelPage.getParameters().put('id', recordId); 
        listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
        GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'ReviewPanel__c',revPanelId,true);
        listDefaultValues.add(dv);        
    }
    
    public string getKeyValueMap(){
        Map<String,Object> keyValueMap = new Map<String,Object>();
        keyValueMap.put('userList', userList);
        return JSON.serialize(keyValueMap);
    }
    public string getListParameters(){
        Map<String,Set<String>> listParams = new Map<String,Set<String>>();     
        listParams.put('recordsIdSet',recordsIdSet);
        return JSON.serialize(listParams);
      }
}