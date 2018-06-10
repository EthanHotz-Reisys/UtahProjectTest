public with sharing class LEAPublicSchoolCtrl{
    public ID recordId{get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    public String pageTemplateName {get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    
    public LEAPublicSchoolCtrl(ApexPages.StandardController stdController){
    
        
        recordId = ApexPages.CurrentPage().getParameters().get('id');   
        pageTemplateName = 'LEA Public Schools';//TODO get template dynamically from sObjectConfig
        
        //savePage = Page.GrantProjectAreaView;
        //savePage.getParameters().put('id', recordId); 
        
       // if (!String.isEmpty(recordId)) {
           
            //cancelPage = Page.GrantProjectAreaView;
            //cancelPage.getParameters().put('id', recordId);   
        //}

        listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
        
        
          Id accountID = ApexPages.CurrentPage().getParameters().get('accountid');
          
        if (accountID != null){
            GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'LEA1__c',accountID,true);
            listDefaultValues.add(dv);
        }
        
        
    }
    
    public static string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        return JSON.serialize(keyValueMap);
    }
    

}