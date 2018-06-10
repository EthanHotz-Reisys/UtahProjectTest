public with sharing class AwardBudgetCategoryEditCtrl {
    public ID recordId{get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    public String pageTemplateName {get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    public AwardBudgetCategoryEditCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');   
         //system.debug('Record Id is :'+recordId);
        pageTemplateName = 'AwardBudgetCategory';
        savePage = Page.AwardBudgetCategoryView;
        savePage.getParameters().put('id', recordId); 
       
        if (!String.isEmpty(recordId)) {
            cancelPage = Page.AwardBudgetCategoryView;
            cancelPage.getParameters().put('id', recordId);    
        }
        listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
        Id awardId = ApexPages.CurrentPage().getParameters().get('awardId');
        if (awardId != null){
            GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Award__c',awardId,true);
            listDefaultValues.add(dv);
        }
    }
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        return JSON.serialize(keyValueMap);
    }
}