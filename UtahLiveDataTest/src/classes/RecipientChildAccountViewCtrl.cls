public with sharing class RecipientChildAccountViewCtrl {
    public ID recordId{get;set;}
    public String recordTypeId {get;set;}
     public ID userID {get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    public String pageTemplateName {get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    
    public RecipientChildAccountViewCtrl(ApexPages.StandardController stdController){
        //Contact con = (Contact) stdController.getRecord();
        recordId = ApexPages.CurrentPage().getParameters().get('Id');
        listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
        pageTemplateName = 'RecipientChildAccount';
     
        } 
            
       
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
       // keyValueMap.put('ContactId', ApexPages.currentPage().getParameters().get('Id'));
        return JSON.serialize(keyValueMap);
    }

}