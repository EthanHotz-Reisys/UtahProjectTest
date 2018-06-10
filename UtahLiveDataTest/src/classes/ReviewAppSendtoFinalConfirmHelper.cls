global with sharing class ReviewAppSendtoFinalConfirmHelper extends GNT.FlexTableActionHandler {
    
    global override Map<String,Object> clickHandler(){
        Map<String,Object> resultMap = new Map<String,Object>();
        String ns = AppUtils.getNamespacePrefix(); 
        Id reviewStepId = urlParams.get('id');
        ReviewStep__c reviewStep = [SELECT ID, RecordType.DeveloperName FROM ReviewStep__c WHERE Id = :reviewStepId];
        
        // Clean up any existing records
        if(reviewStep.RecordType.DeveloperName == 'Application'){
         GNT.RecordIdStorageHelper.deleteRecordIds('RSApplicationSelectedForFinalApprover');
        }else{
         GNT.RecordIdStorageHelper.deleteRecordIds('RSPreapplicationSelectedForFinalApprover');
        }
		// Create new entries in Record Id Storage class
        if(reviewStep.RecordType.DeveloperName == 'Application'){
            GNT.RecordIdStorageHelper.setRecordIds(selectedRecordIds, 'RSApplicationSelectedForFinalApprover');
        }else{
            GNT.RecordIdStorageHelper.setRecordIds(selectedRecordIds, 'RSPreapplicationSelectedForFinalApprover');
        }

        String PageReferenceURL = '/apex/'+ns+'ReviewApplicationConfirmation?reviewStepId='+reviewStepId+'&action=finalapprover';
        resultMap.put('PageReference',PageReferenceURL);
        return resultMap;        
    }    
}