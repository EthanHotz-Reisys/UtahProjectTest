global with sharing class CaseCloseActionHelper extends GNT.DynamicLayoutActionRedirect {
    global override Pagereference whenClicked() {
		try {
			Map<String, SObject> recordMp= layoutHolder.recordMap;
			Case__c caseObj = (Case__c) recordMp.get('Case__c');
        	caseObj.Status__c='Closed';
        	caseObj.DetailedComments__c='Closed by the Requester';
        	Update caseObj;
        	//ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.INFO,'The case has been closed' );
            ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.INFO,GNT.ErrorMessageHelper.fetchMessage('P17-GRNTE-80225'));
        	ApexPages.addmessage(msg);
         	Pagereference pg = new Pagereference('/apex/FlexTableView?flexTableName=ExternalCaseDetails');
	        pg.setRedirect(true);
	        return pg;
        } catch(Exception e) {
        	ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.ERROR, e.getMessage() );
        	ApexPages.addmessage(msg);
        	return null;
        }
    }
    
}