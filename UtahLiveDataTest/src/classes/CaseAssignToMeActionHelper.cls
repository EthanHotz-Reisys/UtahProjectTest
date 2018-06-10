global with sharing class CaseAssignToMeActionHelper  extends GNT.DynamicLayoutActionRedirect {
    global override Pagereference whenClicked() {
    	try {
    		String recordId = ApexPages.CurrentPage().getParameters().get('id');
    		Case__c caseObj = [Select Id,OwnerId,Status__c from Case__c where id=:recordId]; 
    		caseObj.OwnerId = UserInfo.getUserId();
    		if(caseObj.Status__c == 'New') {
    			caseObj.Status__c = 'In Progress';
    		}
    		update caseObj;
    		PageReference p = Page.CaseView;
	        p.getParameters().put('id', recordId);
	        p.setRedirect(true);
	        return p;
    	} catch(Exception ex) {
    		ApexPages.Message msg =new Apexpages.Message(ApexPages.Severity.ERROR, ex.getMessage());
    		ApexPages.addmessage(msg);
    		return null;
    	}
    }
}