public with sharing class POCBatchController {
    
    public String flexGridName {get;set;}
    public String recordId{get;set;}
    public String packageId{get;set;}
    public String currentAccount{get;set;}
     
    public POCBatchController() {
        flexGridName = 'POC_FinancialBatchGrid';
        String currentUserId = UserInfo.getUserId();
        User currentUser = [SELECT Id, AccountNameFormulaField__c FROM User WHERE Id = :currentUserId];
        currentAccount = currentUser.AccountNameFormulaField__c;
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        return JSON.serialize(keyValueMap);
    }
}