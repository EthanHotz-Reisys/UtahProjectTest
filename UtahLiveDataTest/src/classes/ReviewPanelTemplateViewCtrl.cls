public with sharing class ReviewPanelTemplateViewCtrl{

    public ID recordId {get;set;}
    public String recordType {get;set;}
    
    public ReviewPanelTemplateViewCtrl(ApexPages.StandardController stdController) {     
        recordId = ApexPages.CurrentPage().getParameters().get('id');
        system.debug('inside ReviewPanelTemplateViewCtrl--recordId---'+recordId);

        ReviewPanelTemplate__c rstObj = (ReviewPanelTemplate__c)stdController.getRecord();
        if(stdController.getId() != null){ // View mode
            recordType =  Schema.SObjectType.ReviewPanelTemplate__c.getRecordTypeInfosById().get(rstObj.RecordTypeId).getName().toLowercase();
        }
    }
    
    public string getKeyValueMap(){
		Map<String,String> keyValueMap = new Map<String,String>();
		keyValueMap.put('reviewPanelId',ApexPages.currentPage().getParameters().get('id'));
		keyValueMap.put('recordTypeName',recordType);
		return JSON.serialize(keyValueMap);
  	}
}