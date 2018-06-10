public with sharing class FundingAccountViewCtrl {
    //Properties
    public ID recordId{get;set;}
    
    public FundingAccountViewCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');   
    }
    
    /*
        Method to populate the parameters for the FlexTable
    */
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        if(recordId != null){
            keyValueMap.put('fundingAccountId',recordId);
        }
        return JSON.serialize(keyValueMap);
    }
}