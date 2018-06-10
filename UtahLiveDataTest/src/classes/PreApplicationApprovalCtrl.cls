public with sharing class PreApplicationApprovalCtrl {
	public string getKeyValueMap(){
		Map<String,String> keyValueMap = new Map<String,String>();
		keyValueMap.put('announcementId',ApexPages.currentPage().getParameters().get('id'));
		return JSON.serialize(keyValueMap);
  	}
}