public with sharing class LEAPrivateSchoolCtrl{
    public ID recordId {get;set;}
    public String pageTemplateName {get;set;}
    public String savePage{get;set;}
    public String cancelPage{get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    
    public LEAPrivateSchoolCtrl(ApexPages.StandardController stdController){
    
        recordId = ApexPages.CurrentPage().getParameters().get('id');
        pageTemplateName = 'LEAPrivateSchool';

        listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
        
        
        
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        return JSON.serialize(keyValueMap);
    }
    
    

}