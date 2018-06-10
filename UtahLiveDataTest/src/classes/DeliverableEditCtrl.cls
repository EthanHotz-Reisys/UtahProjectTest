public with sharing class DeliverableEditCtrl {
    //Properties
    public ID recordId{get;set;}
    public PageReference deleteURL{get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    public String awardId='';
    public transient List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    public String pageTemplateName {get;set;}
    
    public DeliverableEditCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id'); 
        awardId= ApexPages.CurrentPage().getParameters().get('awardId'); 
        pageTemplateName='Award Deliverable';
        listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
        
        savePage = Page.DeliverableView;
        savePage.getParameters().put('id', recordId);
        
        if(awardId!=null){
        GNT.DynamicLayoutDefaultValueHelper dv1 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Award__c',awardId,true);
        listDefaultValues.add(dv1);        
        }
        
        if (!String.isEmpty(recordId)) {
            cancelPage = Page.DeliverableView;
            cancelPage.getParameters().put('id', recordId);   
        }
        
        
    } 
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();        
        return JSON.serialize(keyValueMap);
    }

}