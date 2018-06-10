public with sharing class ApplicationReviewEditCtrl {
        
    //Properties
    public ID recordId{get;set;}
    public String type {get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    public String pageTemplateName {get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    
    public ApplicationReviewEditCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');
        type = ApexPages.CurrentPage().getParameters().get('type');
        if(type == 'FOA'){
            pageTemplateName = 'LeadEvaluation';
        }else{
            pageTemplateName = 'Review';  
        }
        savePage = Page.ApplicationReviewView; 
        savePage.getParameters().put('id', recordId); 
              
        if (!String.isEmpty(recordId)) { 
            cancelPage = Page.ApplicationReviewView;  
            cancelPage.getParameters().put('id', recordId);   
        }

        listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
        
        Id applicationid = ApexPages.CurrentPage().getParameters().get('applicationid');
        Id awardId = ApexPages.CurrentPage().getParameters().get('awardId');
        Id announcementId = ApexPages.CurrentPage().getParameters().get('announcementId');
        Id preapplicationId = ApexPages.CurrentPage().getParameters().get('preapplicationid');
        Id FOAId =  ApexPages.CurrentPage().getParameters().get('FOAId');
        if (applicationid != null){  
            //TODO get template dynamically from sObjectConfig
            GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Application__c',applicationid,true);
            listDefaultValues.add(dv);  
        }  
        if (awardId != null){  
            //TODO get template dynamically from sObjectConfig
            GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Award__c',awardId,true);
            listDefaultValues.add(dv);  
        } 
        if (announcementId != null){  
            //TODO get template dynamically from sObjectConfig
            GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'FundingOpportunity__c',announcementId,true);
            listDefaultValues.add(dv);  
        }   
         if (preapplicationId != null){  
            //TODO get template dynamically from sObjectConfig
            GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'PreApplication__c',preapplicationId,true);
            listDefaultValues.add(dv);  
        }
        if (FOAId != null){  
            //TODO get template dynamically from sObjectConfig
            GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'FOALead__c',FOAId,true);
            listDefaultValues.add(dv);  
        }   
  
    } 
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('applicationid',ApexPages.currentPage().getParameters().get('id'));
        System.debug('The keyValueMap is '+keyValueMap);
        return JSON.serialize(keyValueMap);
    }

}