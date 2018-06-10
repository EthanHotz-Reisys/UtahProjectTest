public with sharing class LEAPrivateSchoolFormEditCtrl{
    public ID recordId{get;set;}
    public String pageTemplateName {get;set;}
    //public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    
    public LEAPrivateSchoolFormEditCtrl(ApexPages.StandardController stdController){
    
        
        recordId = ApexPages.CurrentPage().getParameters().get('id');   
        pageTemplateName = 'LEAPrivateSchoolForm';

        /*
        listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
        
        
          Id accountID = ApexPages.CurrentPage().getParameters().get('accountid');
          
        if (accountID != null){
            GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'LEA1__c',accountID,true);
            listDefaultValues.add(dv);
        }
        */
        
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        return JSON.serialize(keyValueMap);
    }
    

}