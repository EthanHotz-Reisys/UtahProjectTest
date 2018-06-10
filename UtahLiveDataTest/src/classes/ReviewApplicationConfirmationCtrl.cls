public with sharing class ReviewApplicationConfirmationCtrl {

	public ID recordId{get;set;}
    public String flexTableHeader {get;set;}
    public String flexTableName {get;set;}
    public ReviewStep__c reviewStep{get;set;}
    public String templateName{get;set;}
    public String pageHeader{get;set;}
    private List<Id> recordIds;
    
    public ReviewApplicationConfirmationCtrl (){
    	recordId = ApexPages.CurrentPage().getParameters().get('reviewStepId');	
    	String action = ApexPages.CurrentPage().getParameters().get('action');	
		if(recordId != null){
			reviewStep = [SELECT ID, RecordType.DeveloperName, ApprovalConfirmationFlexTableName__r.Name,ApprovalConfirmationFlexTableName__r.GNT__Header__c, RejectionConfirmationFlexTableName__r.Name,RejectionConfirmationFlexTableName__r.GNT__Header__c
						  FROM ReviewStep__c WHERE Id = :recordId];
			if(action.equalsIgnoreCase('promote')){
				flexTableName = reviewStep.ApprovalConfirmationFlexTableName__r.Name;
				flexTableHeader = reviewStep.ApprovalConfirmationFlexTableName__r.GNT__Header__c;
			}else if(action.equalsIgnoreCase('reject')){
				flexTableName = reviewStep.RejectionConfirmationFlexTableName__r.Name;
				flexTableHeader = reviewStep.RejectionConfirmationFlexTableName__r.GNT__Header__c;
			}else if(action.equalsIgnoreCase('finalapprover')){
				flexTableName = reviewStep.ApprovalConfirmationFlexTableName__r.Name;
				flexTableHeader = reviewStep.ApprovalConfirmationFlexTableName__r.GNT__Header__c;
			}
			else if(action.equalsIgnoreCase('promoteemail')){
				flexTableName = reviewStep.ApprovalConfirmationFlexTableName__r.Name;
				flexTableHeader = reviewStep.ApprovalConfirmationFlexTableName__r.GNT__Header__c;
			}
			else if(action.equalsIgnoreCase('rejectemail')){
				flexTableName = reviewStep.RejectionConfirmationFlexTableName__r.Name;
				flexTableHeader = reviewStep.RejectionConfirmationFlexTableName__r.GNT__Header__c;
			}
		}
    }
    
    public string getKeyValueMap(){
		Map<String,String> keyValueMap = new Map<String,String>();
		keyValueMap.put('reviewStepId',recordId);
		return JSON.serialize(keyValueMap);
  	}
  	
  	public string getListParameters(){
  		List<String> recordIds;
        Map<String,Set<String>> listParams = new Map<String,Set<String>>();
        String action = ApexPages.CurrentPage().getParameters().get('action');	
		if(action.equalsIgnoreCase('promote')){
			if(reviewStep.RecordType.DeveloperName == 'Application'){
				recordIds = GNT.RecordIdStorageHelper.getRecordIds('RSApplicationSelectedForPromotion');
			}else{
				recordIds = GNT.RecordIdStorageHelper.getRecordIds('RSPreapplicationSelectedForPromotion');
			}
		}else if(action.equalsIgnoreCase('finalapprover')){
			if(reviewStep.RecordType.DeveloperName == 'Application'){
				recordIds = GNT.RecordIdStorageHelper.getRecordIds('RSApplicationSelectedForFinalApprover');
			}else{
				recordIds = GNT.RecordIdStorageHelper.getRecordIds('RSPreapplicationSelectedForFinalApprover');
			}
		}else if(action.equalsIgnoreCase('reject')){
			if(reviewStep.RecordType.DeveloperName == 'Application'){
				recordIds = GNT.RecordIdStorageHelper.getRecordIds('RSApplicationSelectedForRejection');
			}else{
				recordIds = GNT.RecordIdStorageHelper.getRecordIds('RSPreapplicationSelectedForRejection');
			}
		}
		
		Set<String> recordIdSet = new Set<String>();
		recordIdSet.addAll(recordIds);
        listParams.put('selectedRecords',recordIdSet);
        return JSON.serialize(listParams);
  	}
  	
  	public void clearSelection(){
  	}
}