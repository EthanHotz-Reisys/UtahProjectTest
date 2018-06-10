public with sharing class ApplicationPhaseListViewCtrl {
	public String currentAccount{get;set;}
	public ApplicationPhaseListViewCtrl() {
        String currentUserId = UserInfo.getUserId();
        User currentUser = [SELECT Id, AccountNameFormulaField__c FROM User WHERE Id = :currentUserId];
        currentAccount = currentUser.AccountNameFormulaField__c;		
	}

    public string getKeyValueMap(){
	    Map<String,String> keyValueMap = new Map<String,String>();
	    return JSON.serialize(keyValueMap);
    }
}