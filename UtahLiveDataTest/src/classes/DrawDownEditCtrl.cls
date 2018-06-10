/**
* This class is used for drawdown creation 
* @author: Sarat Maahavratayajula
*/
public with sharing class DrawDownEditCtrl {

    public ID recordId{get;set;} 
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    public String pageTemplateName {get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}

    public DrawDownEditCtrl(ApexPages.StandardController stdController) {

        recordId = ApexPages.CurrentPage().getParameters().get('id');
        Id grantId = ApexPages.CurrentPage().getParameters().get('grantId');
        pageTemplateName = 'Draw Down';
         savePage = Page.DrawDownView;
         savePage.getParameters().put('id', recordId);
         if (cancelPage == null && recordId != null) {
            cancelPage = Page.DrawDownView;  
            cancelPage.getParameters().put('id', recordId); 
        }

        listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
        GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Grant__c',grantId,true);
        listDefaultValues.add(dv);
        
    }
     public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('grantId',ApexPages.currentPage().getParameters().get('id'));
        keyValueMap.put('drawId',ApexPages.currentPage().getParameters().get('id')); 
        return JSON.serialize(keyValueMap);
    }
}