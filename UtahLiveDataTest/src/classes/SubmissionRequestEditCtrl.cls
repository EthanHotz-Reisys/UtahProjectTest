global with sharing class SubmissionRequestEditCtrl extends GNT.MasterCtrl {
    
    //Properties
    public ID recordId{get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}    
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    public String ns{get;set;}
    
    public SubmissionRequestEditCtrl (ApexPages.StandardController stdController){
        System.debug('Inside..SubmissionRequestEditCtrl..');
        recordId = ApexPages.CurrentPage().getParameters().get('id');  
        Id appId = ApexPages.CurrentPage().getParameters().get('applicationid'); 
        ns = AppUtils.getNamespacePrefix();  
        If(appId == null){
           ChangeRequest__c changeReq = [select id, status__c, Application__c from ChangeRequest__c 
                                         where id=:recordId Limit 1]; 
            appId = changeReq.Application__c;
        }
        //ChangeRequest__c changeReq = [select id, status__c from ChangeRequest__c where id=:recordId];
        savePage = Page.SubmissionRequestView;      
        savePage.getParameters().put('id', recordId);
        savePage.getParameters().put('applicationid', appId);
        cancelPage = new PageReference('/apex/'+ns+'ApplicationView?id='+appId);
        system.debug('**appId**'+appId);
        //cancelPage.getParameters().put('id', appId);
        listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
        if (appId != null){
            GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Application__c',appId,true);
            listDefaultValues.add(dv);
        }
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('id',recordId);
        Id recTypeIdApp = Schema.SObjectType.ReviewStepTemplate__c.getRecordTypeInfosByName().get('Application').getRecordTypeId();
        keyValueMap.put('recTypeAppId',(String)recTypeIdApp);
        return JSON.serialize(keyValueMap);
    }
}