/*
    This class has methods to execute methods related to account trigger
    **********************************************************
    Audit History
    **********************************************************
    2014-08-08  Ryan Chadwick           create
    **********************************************************  
*/

public with sharing class AmendmentRequestViewCtrl {
    
    public ID recordId {get;set;}
    public Id parentId {get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    public List <GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    public String pageTemplateName {get;set;}
    public PageReference deleteURL {get; set;}
    AmendmentRequest__c req {get;set;}
    String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
    
    public AmendmentRequestViewCtrl(ApexPages.StandardController stdController) {
        recordId = ApexPages.CurrentPage().getParameters().get('id');
        Id grantId;
        List<AmendmentRequest__c> amendmentrequestlist = new List<AmendmentRequest__c>();
        String recType;
        String spendType;
        String type;
        String grantorOrg;
        if(recordId != null){
            amendmentrequestlist = [select id,name,recordtype.DeveloperName,Award__r.Grant__r.SpendType__c, Type__c, Award__r.GrantorOrganization__c  
                                    FROM AmendmentRequest__c 
                                    WHERE id=:recordId];
            recType = amendmentrequestlist[0].recordtype.DeveloperName;
            spendType = amendmentrequestlist[0].Award__r.Grant__r.SpendType__c;
            type = amendmentrequestlist[0].Type__c;
            grantorOrg = amendmentrequestlist[0].Award__r.GrantorOrganization__c;
        }
        
        if (grantorOrg == 'USBE'){
        	pageTemplateName = 'GrantorFormalAmendmentUSBEBudgetRevision';
        } 
        /*else if (grantorOrg == 'UOVC'){
        	pageTemplateName = 'GrantorAwardAmendment';
        } else{
        	pageTemplateName = 'GrantorAwardAmendment';
        }*/

/*        if(recordId == null && recType == null){
            pageTemplateName = 'New Amendment';
        }*/

        if (appName == 'StateAsGrantee' && recType != null) {
            if(recType == null){
                pageTemplateName = 'New Amendment';
            }

            if(recType == 'FormalAmendments'){
                pageTemplateName = 'Formal Amendment';
            }

            if(recType == 'PriorApproval'){
                pageTemplateName = 'Amendment Prior Approval';
            }   
        }
              
        if(appName == 'StateAsGrantor' || appName == 'Recipient') {
            if(recType == null && appName != 'StateAsGrantee') {
                pageTemplateName = 'GrantorAmendmentRequest';
            }
            
            if(recType == 'FormalAmendments') {
                if(spendType == 'Sub Awards') {
                    if (type == 'Budget Revision' && grantorOrg == 'USBE') {
                        pageTemplateName = 'GrantorFormalAmendmentUSBEBudgetRevision';
                    }
                    else {
                        pageTemplateName = 'GrantorFormalAmendment';
                    }
                }
                else if(spendType == 'ISA') {
                    pageTemplateName = 'GrantorISTVFormalAmendment';
                }
                else if(spendType == 'Internal Spend') {
                    pageTemplateName = 'GrantorIntSpendFormalAmendment';
                }
                else if(spendType == 'Contracts') {
                    pageTemplateName = 'GrantorContractsFormalAmendment';   
                }
            }
            
            if(recType == 'PriorApproval') {
                pageTemplateName = 'GrantorPriorApproval';
            }

            if(recType == 'PeriodicAnnualRenewal') {
                pageTemplateName = 'GrantorPeriodicRenewal';
            }
            if(recType == 'BudgetRevision') {
                pageTemplateName = 'GrantorBudgetRevisionAmendment';
            }
        }

        system.debug('*** Record Type : ' + recType + ' - spendType - ' + spendType);
        system.debug('*** record id ' + recordId);
        system.debug('*** Page Template name : ' + pageTemplateName);

        parentId =  ApexPages.CurrentPage().getParameters().get('parentId');
        listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
        if (parentId != null){
            GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper('Grant__c',parentId,true);
            listDefaultValues.add(dv);            
        }else{
            parentId = grantId;
        }
        
        savePage = Page.AmendmentRequestView;
        if(recordId!=null){
            savePage.getParameters().put('Id', recordId);
            cancelPage = Page.AmendmentRequestView;  
            cancelPage.getParameters().put('Id', recordId);  
        }else{
            cancelPage = Page.GrantView;
            cancelPage.getParameters().put('Id', parentId);                    
        }
        
        List<AmendmentRequest__c> ar = [SELECT Award__c FROM AmendmentRequest__c WHERE Id =: recordId LIMIT 1];
        if(ar.size() > 0) {
            deleteURL = Page.ApplicationView;
            deleteURL.getParameters().put('id', ar[0].Id);
        }
        
    }
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        String amendmentID = ApexPages.currentPage().getParameters().get('id');
        keyValueMap.put('amendmentId',amendmentID);
        keyValueMap.put('recordId',recordId);
        AmendmentRequest__c ar = [SELECT Award__r.Grant__c, Award__c,GrantIntOrgName__c,Award__r.Grant__r.ExternalOrganization__r.Name 
                                        FROM AmendmentRequest__c 
                                        WHERE Id =: amendmentID];
        system.debug(LoggingLevel.INFO, '*** Key value map' + keyValueMap);
        return JSON.serialize(keyValueMap);
    }
    
    // TODO - check for any alternative to Reviewer field with Shah, Temporarily using it

}