public with sharing class GrantContactEditCtrl {
    public ID recordId{get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    public String pageTemplateName {get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    private id orgid;
    public GrantContactEditCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');  
        String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
        if(appName != null && appName == 'StateasGrantor'){ 
            pageTemplateName = 'GrantContact';
        }
        if(appName != null && appName == 'StateasGrantee'){
        	pageTemplateName = 'GranteeGrantContact';
        }
        savePage = Page.GrantContactView;
        savePage.getParameters().put('id', recordId); 
        if (!String.isEmpty(recordId)) {
            cancelPage = Page.GrantContactView;
            cancelPage.getParameters().put('id', recordId);   
        }
        listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
        Id awardId = ApexPages.CurrentPage().getParameters().get('awardId');
        Award__c awd = [select id,name,Grant__r.InternalOrganization__c from Award__c where id=:awardId];
        orgid = awd.Grant__r.InternalOrganization__c;
        if (awardId != null){
            GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Award__c',awardId,true);
            listDefaultValues.add(dv);
        }
    }
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('orgid',orgid);
        return JSON.serialize(keyValueMap);
    }

}