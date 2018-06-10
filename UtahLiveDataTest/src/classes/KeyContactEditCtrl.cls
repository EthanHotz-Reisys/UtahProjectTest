public with sharing class KeyContactEditCtrl{
    public ID recordId{get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    public String pageTemplateName {get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    public KeyContactEditCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');  
        RecordType recordType;
        String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
        if(appName != null && appName == 'StateasGrantor'){ 
            pageTemplateName = 'GrantorKeyContact';
            recordType = [Select Id,DeveloperName from RecordType where DeveloperName =:'Grantor' and sObjectType =: AppUtils.getNamespacePrefix()+'KeyContacts__c'];
    
            
        }
        if(appName != null && appName == 'StateasGrantee'){
          pageTemplateName = 'GranteeKeyContact';
          recordType = [Select Id,DeveloperName from RecordType where DeveloperName =:'Grantee' and sObjectType =: AppUtils.getNamespacePrefix()+'KeyContacts__c'];
    
        }
        savePage = Page.KeyContactView;
        savePage.getParameters().put('id', recordId); 
        if (!String.isEmpty(recordId)) {
            cancelPage = Page.KeyContactView;
            cancelPage.getParameters().put('id', recordId);   
        }
        listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
        Id applicationId= ApexPages.CurrentPage().getParameters().get('applicationId');
        if (applicationId!= null){
            GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Application__c',applicationId,true);
            GNT.DynamicLayoutDefaultValueHelper dv1 = new GNT.DynamicLayoutDefaultValueHelper('RecordTypeId',recordType.Id,true);
            GNT.DynamicLayoutDefaultValueHelper dv2 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'TypeOfPhase__c','Application',true);
            listDefaultValues.add(dv);
            listDefaultValues.add(dv1);
            listDefaultValues.add(dv2);
        }
    }
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        return JSON.serialize(keyValueMap);
    }

}