public with sharing class AssignUsersToOrgCtrl {
    public String recordId{get;set;}
    public AssignUsersToOrgCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');
    }
    
    public String getKeyValueMap() {
    	Map<String, String> returnMap = new Map<String, String>();
    	Account acc = [select Code__c from Account where Id=:recordId];
    	returnMap.put('deptCode', acc.Code__c);
    	returnMap.put('AcctId', acc.Id);
    	return JSON.serialize(returnMap);
    }
}