public with sharing class BudgetNarrativeCtrl{
    public ID recordId{get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    public String pageTemplateName {get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    
    public BudgetNarrativeCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');     
        
        savePage = Page.AwardView;
        savePage.getParameters().put('id', recordId);
           
        pageTemplateName = 'BudgetNarrative';        
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('id', recordId);
        return JSON.serialize(keyValueMap);
    }    
}