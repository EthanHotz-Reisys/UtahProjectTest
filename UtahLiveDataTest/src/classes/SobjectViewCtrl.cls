public with sharing class SobjectViewCtrl{
    public SobjectViewCtrl(ApexPages.StandardController stdController){
    
    }

    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('id',ApexPages.CurrentPage().getParameters().get('id') );
        return JSON.serialize(keyValueMap);
    }  



}