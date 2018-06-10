public with sharing class DebarRecipientCtrl {
    public ID recordId{get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    public String pageTemplateName {get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    
    public DebarRecipientCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');
         Account recipient = [SELECT Id,Status__c,name FROM Account WHERE id =: recordId];
        pageTemplateName = 'Debar Recipient';//TODO get template dynamically from sObjectConfig
      // GNT.TaskCreationHandler.createApprovalProcessTasks(recordId , 'Approve Debarment of Recipient', recipient.name, null, null, recipient.Name, true);
      // savePage = Page.OrganizationView;
      // savePage.getParameters().put('id', recordId); 
       
    }
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
      //  keyValueMap.put('Contactid',ApexPages.currentPage().getParameters().get('id'));
        return JSON.serialize(keyValueMap);
    }    
}