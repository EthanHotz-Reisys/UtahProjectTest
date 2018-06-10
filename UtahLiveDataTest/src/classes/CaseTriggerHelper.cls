public without sharing class CaseTriggerHelper extends GNT.TriggerHelper{
    public static Boolean skipTrigger = false;
    public override void processBeforeInsert() {
        if(skipTrigger == false){
        	String tier1QueueName = GNT.KeyValueStoreHelper.getTextValue('TS_Tier1QueueName', true);
            List<Group> tier1Groups = [Select Id, Name from Group where Name=:tier1QueueName and Type='Queue' Limit 1];
            if(tier1Groups.size() == 0) {
            	throw new CustomExceptions.RequiredException('No Queue found for given name:' + tier1QueueName + '. Please contact System administrator.');
            }                            
        	for(Case__c caseObj : (List<Case__c>) Trigger.New) {
        		caseObj.OwnerId=tier1Groups[0].Id;
        		//in case of create status should be new 
        		if(caseObj.Status__c == null) {
        			caseObj.Status__c = 'New';
        		}
        		if(caseObj.RelatedRecordId__c != null) {
        			caseObj.ObjectType__c = String.valueOf(((Id)caseObj.RelatedRecordId__c).getSobjectType());
        		}
        		if(caseObj.ReportedBy__c == null) {
        			caseObj.ReportedBy__c = Userinfo.getUserId();
        		}
        	}
        }
    }
    
    public override void processAfterUpdate() {
         if(skipTrigger == false){	
            shareRecords();
        }
    
    }
    
    public override void processAfterInsert() {
         if(skipTrigger == false){	
            shareRecords();
        	for(Case__c caseObj : (List<Case__c>) Trigger.New) {
    	    	sendCreateMail(caseObj.Id);
        	}
        }
    }
    
    // refactor method to check if record is already shared.
    private void shareRecords() {
    	List<Case__Share> caseShareList = new List<Case__Share>();
    	for(Case__c caseObj : (List<Case__c>) Trigger.New) {
    		Set<String> userListToShare = new Set<String>();
    		//userListToShare.add(caseObj.OwnerId);
    		userListToShare.add(caseObj.ReportedBy__c);
    		userListToShare.add(caseObj.CreatedById);
    		caseShareList.addAll(createShareRecords( userListToShare, caseObj.Id));
    	}
    	Database.insert( caseShareList, false);
    }
    
    private List<Case__Share> createShareRecords(Set<String> userIds, Id caseId) {
    	List<Case__Share> caseShares = new List<Case__Share>();
    	for(String userId : userIds) {
    		System.debug('userId:' + userId);
    		caseShares.add(new Case__Share(ParentId=caseId, UserOrGroupId=userId, AccessLevel='Edit'));
    	}
    	return caseShares;
    }
    
    @future
    public static void sendCreateMail(String caseId) {
    	Case__c caseObj = [select id,CreatedBy.Email, Owner.Email, ReportedBy__r.Email from Case__c where Id=:caseId];
    	Map<Id, String[]> recIdToAddressMap = new Map<Id, String[]>();
 		String[] userEmails = new List<String>();
 		/*if(caseObj.CreatedBy.Email != null) {
	 		userEmails.add(caseObj.CreatedBy.Email);
 		}
 		if(caseObj.Owner.Email != null) {
	 		userEmails.add(caseObj.Owner.Email);
 		}*/
 		if(caseObj.ReportedBy__r.Email != null) {
	 		userEmails.add(caseObj.ReportedBy__r.Email);
 		}
 		recIdToAddressMap.put(caseId, userEmails);
    	EmailTemplate emailTemaple = [select id from EmailTemplate where Name='GovGrants_CC_Email_CaseCreation'];
    	Contact con = [select id from Contact limit 1];
		AppUtils.sendEmailUsingTemplate(emailTemaple.Id, recIdToAddressMap, String.valueOf(con.Id), true);
		
		recIdToAddressMap = new Map<Id, String[]>();
 		userEmails.add(caseObj.Owner.Email);
 		recIdToAddressMap.put(caseId, userEmails);
		emailTemaple = [select id from EmailTemplate where Name='GovGrants_CO_Email_CaseCreation'];
		AppUtils.sendEmailUsingTemplate(emailTemaple.Id, recIdToAddressMap, String.valueOf(con.Id), true);
    }
}