public with sharing class RecipientOpportunityCtrl {
	
	Id accountId=null;
	
	public RecipientOpportunityCtrl(){
		User userObj = [Select Contact.AccountId From User where Id =:UserInfo.getUserId()];
        if(userObj.Contact.AccountId != null){
        	accountId = [Select id from Account where Id =: userObj.Contact.AccountId].Id;	
        }
        
	}
	
	public String getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('accountId', accountId);
        return JSON.serialize(keyValueMap);        
    }

}