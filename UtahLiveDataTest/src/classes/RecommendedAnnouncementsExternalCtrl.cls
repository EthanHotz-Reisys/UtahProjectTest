public with sharing class RecommendedAnnouncementsExternalCtrl {
	public RecommendedAnnouncementsExternalCtrl(){
		
    }
    
	public string getKeyValueMap(){
		Map<String,String> keyValueMap = new Map<String,String>();
		List<User> UserList = [Select Id, ApplicantType__c From User where Id = :UserInfo.getUserId() LIMIT 1];
		keyValueMap.put('ExternalApplicantType', UserList.get(0).ApplicantType__c);
		return JSON.serialize(keyValueMap);
    }
}