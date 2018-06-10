public with sharing class ReviewStepEditCtrl {
	
	//Properties
	public ID recordId{get;set;}
	public String groupId{get;set;}
	public ReviewStep__c reviewStep{get;set;}
	public ID announcementID{get;set;}
	public String recordType {get;set;}
	public String templateName {get;set;}
	public PageReference savePage {get;set;}
	public PageReference cancelPage {get;set;}
	public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
	
	public ReviewStepEditCtrl(ApexPages.StandardController stdController){
		recordId = ApexPages.CurrentPage().getParameters().get('id');
		groupId = ApexPages.CurrentPage().getParameters().get('groupId');	
		if(recordId != null){
			reviewStep = [SELECT ID,Name,RecordType.DeveloperName,AnnouncementId__c ,ReviewStepLayout__r.Name FROM ReviewStep__c WHERE Id = :recordId];
			recordType = reviewStep.RecordType.DeveloperName;
			templateName = reviewStep.ReviewStepLayout__r.Name;
			announcementID = reviewStep.AnnouncementId__c;
		}
		if(groupId != null) {
			templateName = 'ApplicationReviewStep';
		}
		savePage = Page.ReviewStepView;
		savePage.getParameters().put('id', recordId);
		cancelPage = Page.ReviewStepView;
		cancelPage.getParameters().put('id', recordId);
		populateLayoutDefaultValues(groupId); 
	}
	
	public string getKeyValueMap(){
		Map<String,String> keyValueMap = new Map<String,String>();
		keyValueMap.put('reviewStepId',ApexPages.currentPage().getParameters().get('id'));
		keyValueMap.put('recordTypeName',recordType);
		keyValueMap.put('announcementID',reviewStep.AnnouncementId__c);
		return JSON.serialize(keyValueMap);
  	}
  	
  	/*
        Populate the default values only for a new record
    */
    public void populateLayoutDefaultValues(String groupId) {
        listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
        GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'ReviewGroup__c',groupId,true);
        listDefaultValues.add(dv);
    }
}