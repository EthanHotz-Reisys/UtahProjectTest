public with sharing class FundingAllocationEditCtrl {
    public ID recordId{get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    public String pageTemplateName {get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    
    public FundingAllocationEditCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');   

        pageTemplateName = 'Funding Allocation Form Config';
        
        savePage = Page.FundingAllocationEdit;
        savePage.getParameters().put('id', recordId); 
        
        if (!String.isEmpty(recordId)) {
            cancelPage = Page.FundingAllocationEdit;
            cancelPage.getParameters().put('id', recordId);   
        }

        listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
        
        Id announcementId = ApexPages.CurrentPage().getParameters().get('announcementId');


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