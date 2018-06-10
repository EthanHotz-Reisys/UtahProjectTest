public with sharing class ManageQueueUsers{ 
     public  String recordId{get;set;}
    public ManageQueueUsers(ApexPages.StandardController controller) {

    }
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();

        recordId= ApexPages.currentPage().getParameters().get('id');
        keyValueMap.put('recordId',recordId);
        return JSON.serialize(keyValueMap);
     }











}