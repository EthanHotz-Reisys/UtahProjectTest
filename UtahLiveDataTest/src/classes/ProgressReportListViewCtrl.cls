public with sharing class ProgressReportListViewCtrl {
	
	
	public ProgressReportListViewCtrl() {
	}

	public string getKeyValueMap(){
         Map<String,String> keyValueMap = new Map<String,String>();
           String grantId = ApexPages.currentPage().getParameters().get('grantId');
           keyValueMap.put('grantId',grantId);
           return JSON.serialize(keyValueMap);
    }
}