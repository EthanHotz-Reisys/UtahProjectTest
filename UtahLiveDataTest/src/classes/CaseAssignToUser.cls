global with sharing class CaseAssignToUser extends GNT.FlexTableActionHandler{
    global override Map<String, Object> clickHandler() {
    	Map<String, Object> resultMap = new Map<String, Object>();
    	if(selectedRecordIds.size() == 0) {
    		resultMap.put('Message','Please select one record.');	
    	} else {
    		String caseId = urlParams.get('caseId');
    		Case__c caseObj = [Select Id,OwnerId,Status__c from Case__c where id=:caseId]; 
    		caseObj.OwnerId = selectedRecordIds.get(0);
    		if(caseObj.Status__c == 'New') {
    			caseObj.Status__c = 'In Progress';
    		}
    		update caseObj;
    		//resultMap.put('Message','Case Assigned successfully.');
            resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-53060'));
    	}
    	
    	return resultMap;
    }
}