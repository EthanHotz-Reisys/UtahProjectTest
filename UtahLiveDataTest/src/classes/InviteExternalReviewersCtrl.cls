public with sharing class InviteExternalReviewersCtrl {
    public String  flexTableHeader {get;set;}
    public String panelId;
    public InviteExternalReviewersCtrl(){
         flexTableHeader  = 'Invited External Reviewers';
         panelId = ApexPages.currentPage().getParameters().get('reviewPanelId');       
    }
    
      public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();   
        keyValueMap.put('reviewPanelId', panelId);    
        return JSON.serialize(keyValueMap);
    }
}