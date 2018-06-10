/*
    This class helps to query data related to AmendmentRequestPriorApproval object and 
    returns it to AmendmentRequestPriorApproval.page
    **********************************************************
    Audit History
    **********************************************************
    2016-05-01  Sarat Mahavratayajula
    **********************************************************  
*/

public with sharing class AmendmentRequestPriorApprovalEditCtrl {
    
    public ID recordId {get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    public String pageTemplateName {get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    
    public AmendmentRequestPriorApprovalEditCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');  
        pageTemplateName ='AmendmentRequestPriorApproval';
        savePage = Page.AmendmentRequestPriorApprovalView;
        savePage.getParameters().put('id', recordId); 
        if (!String.isEmpty(recordId)) {
            cancelPage = Page.AmendmentRequestPriorApprovalView;
            cancelPage.getParameters().put('id', recordId);   
        }
        listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
        Id amendmentId = ApexPages.CurrentPage().getParameters().get('amendmentId');
        if (amendmentId != null){
            GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'AmendmentRequest__c',amendmentId,true);
            listDefaultValues.add(dv);
        }
        
    }
    public string getKeyValueMap(){
        //Id amendmentId = ApexPages.CurrentPage().getParameters().get('amendmentId');
        Map<String,String> keyValueMap = new Map<String,String>();
       /* AmendmentRequestPriorApproval__c amdReqPrAp = [select AmendmentRequestName__c from AmendmentRequestPriorApproval__c
                                                         where AmendmentRequest__c = :amendmentId];
        keyValueMap.put('amdName', amdReqPrAp.AmendmentRequestName__c);*/
        return JSON.serialize(keyValueMap);
    }
    
    
}