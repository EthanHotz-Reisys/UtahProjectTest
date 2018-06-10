public with sharing class CloseoutInventoryViewCtrl {
    public ID recordId{get;set;}
    public ID closeoutId{get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    public String pageTemplateName {get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    
    public CloseoutInventoryViewCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');   
        
        closeoutId = ApexPages.CurrentPage().getParameters().get('closeoutId');   
        pageTemplateName = 'CloseoutInventory';
        system.debug('**recordId '+recordId );
        system.debug('**closeoutId '+closeoutId);
        
        savePage = Page.CloseoutInventoryEdit;
     //   savePage.getParameters().put('id', recordId); 
        if(recordId != null){
        cancelPage = Page.CloseoutInventoryEdit;
     //   cancelPage.getParameters().put('id', recordId);  
        }
        else{
        listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
        
        if (closeoutId != null){
            GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Closeout__c',closeoutId,true);
       //     listDefaultValues.add(dv);
        } 
        }       
       
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
         if(recordId != null){
            keyValueMap.put('id',ApexPages.currentPage().getParameters().get('id'));
        }
         if(closeoutId!= null){
            keyValueMap.put('closeOutId',ApexPages.currentPage().getParameters().get('closeoutId'));
        }
        return JSON.serialize(keyValueMap);
    }
}