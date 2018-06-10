global class RejectPaymentsNotInApproved extends GNT.ApprovalDecisionActionHandler {
	Map<String, Object> resultMap = new Map<String, Object>();
	PageReference pageRef = null;
	global override String execute() {

		if (selectedAction == 'Approve') {

			Id recordId = selectedRecordId;
			system.debug('id is' + recordId);
			Savepoint savestate = Database.setSavepoint();
			PaymentRequest__c payment = [SELECT id,Award__c FROM PaymentRequest__c WHERE id= :recordId];
			Id awardId = payment.Award__c;
			List<PaymentRequest__c> paymentRequestList = [SELECT id,Status__c FROM PaymentRequest__c WHERE Award__c = :awardId AND Id!=:recordId AND Status__c NOT IN ('Approved','Rejected','Paid')];
			try{
				SystemContextMethodsHelper contexthelper = new SystemContextMethodsHelper();
            	contexthelper.rejectPayments(paymentRequestList);
            	return ('Approval in Process.');
            }
            catch(Exception e){
            Database.rollback(savestate);
            system.debug('PaymentREeeeject bug'+e);         
            }
		}
		return ('Approval failed. Contact Admin.');
	}
}