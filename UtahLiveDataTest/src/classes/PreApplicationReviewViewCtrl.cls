public with sharing class PreApplicationReviewViewCtrl {
    public ID recordId{get;set;} 
    public PageReference savePage {get;set;} 
    public PageReference cancelPage {get;set;}
    public String pageTemplateName {get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
     
    public PreApplicationReviewViewCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');   
      pageTemplateName = 'Pre-Application Review'; 
     
        System.debug('000 >>>>>THE recordId  ID IS <<<<<<'+recordId);    
        savePage = Page.PreApplicationReviewView;  
            
        if (!String.isEmpty(recordId)) {
            cancelPage = Page.PreApplicationReviewView;  
        }

        listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
        Id preapplicationid = ApexPages.CurrentPage().getParameters().get('preapplicationid');
          
        if (preapplicationid != null){                    
            GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'PreApplication__c',preapplicationid,true);
            listDefaultValues.add(dv);    
        }            
    }
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>(); 
        keyValueMap.put('preapplicationid',ApexPages.currentPage().getParameters().get('id'));
        return JSON.serialize(keyValueMap);  
    }
}