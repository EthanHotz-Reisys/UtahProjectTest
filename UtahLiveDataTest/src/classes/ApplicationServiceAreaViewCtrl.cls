public with sharing class ApplicationServiceAreaViewCtrl{
    public Id recordId {get; set;}
    
    public ApplicationServiceAreaViewCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');
    }
    
    public String getKeyValueMap(){
         Map<String,String> keyValueMap = new Map<String,String>();
         keyValueMap.put('id',recordId );
         return JSON.serialize(keyValueMap);
    }
    
}