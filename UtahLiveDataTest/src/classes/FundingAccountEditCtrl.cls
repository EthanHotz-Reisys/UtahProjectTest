public with sharing class FundingAccountEditCtrl {
    //Properties
    public ID recordId{get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    
    public FundingAccountEditCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');   
        savePage = Page.FundingAccountView;
        savePage.getParameters().put('id', recordId);
        cancelPage = Page.FundingAccountView;
        cancelPage.getParameters().put('id', recordId);
        listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
        
        Id fundingSourceId = ApexPages.CurrentPage().getParameters().get('fundingSourceId');
        if (fundingSourceId != null){
            GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'FundingSource__c',fundingSourceId,true);
            listDefaultValues.add(dv);
        }
    }
    
    /*
        Method to populate the parameters for the FlexTable
    */
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        if(recordId != null){
            keyValueMap.put('fundingAccountId',recordId);
        }
        return JSON.serialize(keyValueMap);
    }
}