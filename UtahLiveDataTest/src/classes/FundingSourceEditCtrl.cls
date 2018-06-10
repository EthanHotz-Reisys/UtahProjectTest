public with sharing class FundingSourceEditCtrl {
    //Properties
    public ID recordId{get;set;}
    public String pageTemplateName {get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    public FundingSourceEditCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');
        String recType = ApexPages.CurrentPage().getParameters().get('RecordType');
        pageTemplateName = 'FundingSource';
        RecordType recordType;
        if(recType != null && recType == 'External'){
          pageTemplateName = 'FundingSource';
        }else{
          pageTemplateName = 'GrantorFundingSource';
        }
        if( recType!=null )        
        recordType = [Select Id,DeveloperName from RecordType where DeveloperName =:recType and sObjectType =: AppUtils.getNamespacePrefix()+'FundingSource__c'];
        savePage = Page.FundingSourceView;
        savePage.getParameters().put('id', recordId);
        if (cancelPage == null && recordId != null){
        cancelPage = Page.FundingSourceView;
        cancelPage.getParameters().put('id', recordId);
        } else {
            String retURL = ApexPages.CurrentPage().getParameters().get('retURL');
            if(retURL != null) {
                cancelPage = new PageReference(retURL);    
            }
        }  
        listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>(); 
        grant__c grantobj;
        Award__c awardobj;
        Id grantId = ApexPages.CurrentPage().getParameters().get('grantId');
        if (grantId != null){
            grantObj = [SELECT ID,Program__c,CurrentAward__c FROM Grant__c WHERE ID = : grantId];
            awardobj = [SELECT ID,BudgetPeriod__r.BudgetStartDate__c,BudgetPeriod__r.BudgetEndDate__c from Award__c where ID=:grantObj.CurrentAward__c];
            GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Grant__c',grantId,true);
            listDefaultValues.add(dv);
            GNT.DynamicLayoutDefaultValueHelper dv1 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Program__c',grantObj.Program__c,true);
            listDefaultValues.add(dv1);
            GNT.DynamicLayoutDefaultValueHelper dv3 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'StartDate__c',awardobj.BudgetPeriod__r.BudgetStartDate__c,true);
            listDefaultValues.add(dv3);
            GNT.DynamicLayoutDefaultValueHelper dv4 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'EndDate__c',awardobj.BudgetPeriod__r.BudgetEndDate__c,true);
            listDefaultValues.add(dv4);
        }
        if(recType != null){
        GNT.DynamicLayoutDefaultValueHelper dv2 = new GNT.DynamicLayoutDefaultValueHelper('RecordTypeId',recordType.Id,true);
        listDefaultValues.add(dv2);
        }
    }
    
    /*
        Method to populate the parameters for the FlexTable
    */
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>(); 
        if(recordId != null){
            keyValueMap.put('fundingSourceId',recordId);
        }
        return JSON.serialize(keyValueMap);
    }
}