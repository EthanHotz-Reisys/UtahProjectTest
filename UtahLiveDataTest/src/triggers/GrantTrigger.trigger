trigger GrantTrigger on Grant__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
	
	List<Grant__c> UOVCGrants = new List<Grant__c>();
	List<Grant__c> USBEMSPGrants = new List<Grant__c>();
	if(Trigger.isInsert){
		for(Grant__c grant : Trigger.new){
			if(grant.USBEPathway__c == 'MSP' || grant.USBEPathway__c == 'LSNA'){
				USBEMSPGrants.add(grant);
			}else{
				UOVCGrants.add(grant);
			}
		}
	}else{
		for(Grant__c grant : Trigger.old){
			if(grant.USBEPathway__c == 'MSP' || grant.USBEPathway__c == 'LSNA'){
				USBEMSPGrants.add(grant);
			}else{
				UOVCGrants.add(grant);
			}
		}
	}

	if(UOVCGrants.size() > 0){
		new GrantTriggerHelper().process();
	}else if(USBEMSPGrants.size() > 0){
		new MSPGrantTriggerHelper().process();
	}else{
		
	}
	
}