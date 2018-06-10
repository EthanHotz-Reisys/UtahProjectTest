public with sharing class KeyPerformanceIndicatorEditCtrl {
    //Properties
    public ID recordId{get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    public String pageTemplateName {get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    
    public KeyPerformanceIndicatorEditCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');   
        pageTemplateName = 'Key Performance Indicator';
        
        savePage = Page.KeyPerformanceIndicatorView;
        savePage.getParameters().put('id', recordId);
        
        cancelPage = Page.KeyPerformanceIndicatorView;
        cancelPage .getParameters().put('id', recordId);
        
    }

    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        return JSON.serialize(keyValueMap);
    }
}