global with sharing class CreatePaymentWaiver extends GNT.FlexTableActionHandler{
    
    public class TestException extends Exception {}
    
    global override Map<String,Object> clickHandler(){
        Savepoint sp = Database.setSavepoint();
        List<String> errors = new List<String>();
        Map<String,Object> resultMap = new Map<String,Object>();
        try{
        	String awardId = urlParams.get('id');
            Award__c awd = [select id,FOUser__c,SpendType__c,Grant__c,POUser__c,Grant__r.GranteePOC__c,Grant__r.GrantNumber__c,Grant__r.Program__r.PaymentRequestSetting__c,Grant__r.ProjectPeriodStartDate__c,Grant__r.ProjectPeriodEndDate__c,
         	      Grant__r.InternalOrganization__r.Id,Grant__r.ExternalOrgName__c,Approver__c from Award__c where id=:awardId];
         	List<PaymentRequest__c> pendingpayreq = [SELECT Id FROM PaymentRequest__c WHERE Award__c =: awd.Id AND (Status__c = 'Submitted for Approval' OR Status__c = 'Submitted to Grantor' OR Status__c = 'Internally Approved')];
         	List<PaymentRequest__c> pendingwaiver = [SELECT Id FROM PaymentRequest__c WHERE Award__c =: awd.Id AND Type__c = 'Waiver'];
         	
         	if (pendingpayreq.size() > 0) {
         		errors.add('A Waiver cannot be processed until all pending Payment Requests have been reviewed by USBE.');
         	}
         	if (pendingwaiver.size() > 0) {
         		errors.add('An existing waiver already exists for this award.');
         	}
            if (errors.size() > 0) {
                for(String error: errors){
                    resultMap.put('Error', error);
                }
            }
            else{
	         	PaymentRequest__c payreq = new PaymentRequest__c();
	         	payreq.Grant__c = awd.Grant__c;
	         	payreq.Award__c = awd.Id;
	         	payreq.Type__c = 'Waiver';
	         	payreq.Title__c = 'Waiver';
	         	payreq.Approver__c = awd.Approver__c;
	         	payreq.FiscalOfficer__c = awd.FOUser__c;
	         	payreq.ProgramManager__c = awd.POUser__c;
	         	payreq.Applicant__c = awd.Grant__r.GranteePOC__c;
	         	payreq.RecipientsAccountNumber__c = awd.Grant__r.GrantNumber__c;
	         	payreq.PaymentRequestSetting__c = awd.Grant__r.Program__r.PaymentRequestSetting__c;
	         	payreq.BillingStartDate__c = awd.Grant__r.ProjectPeriodStartDate__c;
	         	payreq.BillingEndDate__c = awd.Grant__r.ProjectPeriodEndDate__c;
	         	payreq.ExternalOrgName__c = awd.Grant__r.ExternalOrgName__c;
	         	insert payreq;
	            
	            PageReference p = Page.PaymentRequestView;
	            p.getParameters().put('id', payreq.Id);
	            p.setRedirect(true);
	            String pageUrl = p.getUrl();
	            resultMap.put('PageReference', new PageReference(pageUrl));
	            return resultMap;
            }
            return resultMap;
        }
        catch(Exception e){
            Database.rollback(sp);
            resultMap.put('Message', e.getMessage());
            return resultMap;
        }
    }
}