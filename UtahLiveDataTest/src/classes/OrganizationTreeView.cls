/*
    <Purpose of this class>    
    *******************************************************************************************************************
    Audit History
    ********************************************************************************************************************
    2017-04-01  Shah Kadirmohideen  Code Reviewed
    **********************************************************************************************************************  
*/ 
public with sharing class OrganizationTreeView {

    public OrganizationTreeView(){
        
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        String recordType = ApexPages.currentPage().getParameters().get('rt');
        if(!String.isEmpty(recordType)){
            keyValueMap.put('recordType',recordType);
            keyValueMap.put('orgType','Federal');
        }else{
            keyValueMap.put('recordType','Internal');
            keyValueMap.put('orgType','State');
        }
        return JSON.serialize(keyValueMap);
    }
    
}