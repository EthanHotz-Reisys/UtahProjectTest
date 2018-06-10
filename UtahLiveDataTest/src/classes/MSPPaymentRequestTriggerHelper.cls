global with sharing class MSPPaymentRequestTriggerHelper extends GNT.TriggerHelper{
	public override void processAfterUpdate(){
		shareToLea((List<PaymentRequest__c>)Trigger.new);
	}

	private void shareToLea(List<PaymentRequest__c> paymentRequestList){
		List<PaymentRequest__c> allPrList = [SELECT Id, Status__c, Grant__r.InternalOrganization__c FROM PaymentRequest__c WHERE Id IN :paymentRequestList];
		List<PaymentRequest__c> prList = new List<PaymentRequest__c>();
		for(PaymentRequest__c pr : allPrList){
			if(pr.Status__c == 'Approved'){
				prList.add(pr);
			}
		}

		List<Id> leaIds = new List<Id>();
		for(PaymentRequest__c pr : prList){
			leaIds.add(pr.Grant__r.InternalOrganization__c);
		}

		List<User> leaUsers = [SELECT Id, AccountId FROM User WHERE AccountId IN :leaIds AND IsActive = true];
		Map<String, List<User>> userMap = new Map<String, List<User>>();
		for(User u : leaUsers){
			if(userMap.get(u.AccountId) == null){
				List<User> ul = new List<User>();
				ul.add(u);
				userMap.put(u.AccountId, ul);
			}else{
				userMap.get(u.AccountId).add(u);
			}
		}


        List<PaymentRequest__Share> shareList = new List<PaymentRequest__Share>();
        for (PaymentRequest__c pr : prList) {
            if (pr.Grant__r.InternalOrganization__c != null && userMap.get(pr.Grant__r.InternalOrganization__c) != null) {
            	for(User u : userMap.get(pr.Grant__r.InternalOrganization__c)){
	                PaymentRequest__Share share = new PaymentRequest__Share();
	                share.UserOrGroupId = u.Id;
	                share.AccessLevel = 'Read';
	                share.ParentId = pr.Id;
	                share.RowCause = Schema.PaymentRequest__Share.RowCause.SharetoApplicant__c;
	                shareList.add(share);
            	}
            }
        }
        if (shareList.size() > 0 && Schema.sObjectType.PaymentRequest__Share.isCreateable()) {
            SystemContextMethodsHelper SystemContextMethodsHelper = new SystemContextMethodsHelper();
            SystemContextMethodsHelper.updatePaymentRequestShares(shareList);
        }		
	}
}