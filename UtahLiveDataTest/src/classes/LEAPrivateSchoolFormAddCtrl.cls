public with sharing class LEAPrivateSchoolFormAddCtrl{
    public ID recordId{get;set;}
    public String pageTemplateName {get;set;}
    public ID applicationID {get;set;}
    public String savePage{get;set;}
    public String cancelPage{get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    
    public LEAPrivateSchoolFormAddCtrl(ApexPages.StandardController stdController){
    
        
        recordId = ApexPages.CurrentPage().getParameters().get('id');   
        pageTemplateName = 'LEAAddSchool';
        applicationID = ApexPages.CurrentPage().getParameters().get('applicationId');

        
        listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
        
        
          
        if (applicationID != null){
            GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Application__c',applicationID,true);
            listDefaultValues.add(dv);
        }
        
        
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        return JSON.serialize(keyValueMap);
    }
    

}