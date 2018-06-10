public with sharing class BudgetPeriodEditCtrl {
    public ID recordId{get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    public String pageTemplateName {get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    
    public BudgetPeriodEditCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');   

        pageTemplateName = 'GrantBudgetPeriod';//TODO get template dynamically from sObjectConfig
        
        savePage = Page.BudgetPeriodView;
        savePage.getParameters().put('id', recordId); 
        
        if (!String.isEmpty(recordId)) {
            cancelPage = Page.BudgetPeriodView;
            cancelPage.getParameters().put('id', recordId);   
        }

        listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
        
        Id grantId = ApexPages.CurrentPage().getParameters().get('grantId');
        Id programid = ApexPages.CurrentPage().getParameters().get('programid');
        Id announcementId = ApexPages.CurrentPage().getParameters().get('announcementId');


        system.debug('--announcementId--'+announcementId);
        system.debug('--grantId--'+grantId);
        system.debug('--programid--'+programid);

        if (grantId != null){
            GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Grant__c',grantId,true);
            listDefaultValues.add(dv);
        }
        if (programid != null){
            GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Program__c',programid,true);
            listDefaultValues.add(dv);
        }
        if (announcementId != null){
            GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'FundingOpportunity__c',announcementId,true); 
            listDefaultValues.add(dv);
        }
        
        
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        return JSON.serialize(keyValueMap);
    }
    

}