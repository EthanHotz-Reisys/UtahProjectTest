public with sharing class AwardInternalApproverEditCtrl{
    public ID recordId{get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    public String pageTemplateName {get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    
    Award__c awd;
    public AwardInternalApproverEditCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');     
        awd = [SELECT Id, Grant__c, Grant__r.InternalOrganization__c FROM Award__c WHERE Id=:recordId]; 
         
        savePage = Page.AwardView;
        savePage.getParameters().put('id', recordId);
           
        pageTemplateName = 'AwardInternalApproverEdit';        
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('id', recordId);
        keyValueMap.put('AccountId', awd.Grant__r.InternalOrganization__c);
        return JSON.serialize(keyValueMap);
    }    
}