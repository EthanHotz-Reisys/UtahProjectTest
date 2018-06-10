public with sharing class ApplicationBudgetPrintCtrl{
    
    //Properties
    public ID recordId{get;set;}
    public PageReference deleteURL{get;set;}
    public String pageTemplateName {get;set;}
    public String packageId {get;set;}
    private Announcement__c announcementObj;
    private Application__c applicationObj;
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    public ID organizationId {get;set;}
    public ID AnnId{get;set;}
    public ID parentId{get;set;}
     
    
    public ApplicationBudgetPrintCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id'); 
        parentId=recordId;
        //applicationObj = [SELECT Id,ExternalOrganization__c,Approver__c, Announcement__c,OwnerId,Announcement__r.AnnouncementName__c, GrantorOrganizationName__c  FROM Application__c WHERE Id =:recordId LIMIT 1];
     
  }
    
    public string getKeyValueMap(){
        
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('parentid',ApexPages.currentPage().getParameters().get('id'));
        keyValueMap.put('applicationid',ApexPages.currentPage().getParameters().get('id'));
        keyValueMap.put('AnnId',AnnId);
        return JSON.serialize(keyValueMap);
    }
}