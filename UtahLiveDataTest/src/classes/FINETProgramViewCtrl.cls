public with sharing class FINETProgramViewCtrl{
    public ID recordId{get;set;}
    public String pageTemplateName {get;set;}
    public static ID recordId1{get;set;}
    
    
    public FINETProgramViewCtrl(ApexPages.StandardController stdController){
    
        
        recordId = ApexPages.CurrentPage().getParameters().get('id');  
        recordId1= recordId; 
        pageTemplateName = 'FINETProgramView';
            
        
    }
    
    public static String getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('finetprogramid',recordId1);
        return JSON.serialize(keyValueMap);
    }
    

}