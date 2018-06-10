global with sharing class CreateAmendmentCtrl {

	public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
	public String recordId{get;set;}

	public CreateAmendmentCtrl() {
	recordId = ApexPages.CurrentPage().getParameters().get('id');		
		String awardId = ApexPages.CurrentPage().getParameters().get('awardId');
		listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
		GNT.DynamicLayoutDefaultValueHelper dv1 = new GNT.DynamicLayoutDefaultValueHelper('Award__c',awardId,true);
		listDefaultValues.add(dv1);
		system.debug('Award Id --> ' + awardId);
	}

	@RemoteAction
	global static Map<String,Object> saveAndContinue(String recordTypeid,String award,String purpose,String impact){
		system.debug('Record Type Id --> ' + recordTypeid);
		system.debug('Award --> ' + award);
		system.debug('Purpose --> ' + purpose);
		system.debug('Impact --> ' + impact);
		Map<String,Object> result= new  Map<String,Object>();
		Savepoint sp = Database.setSavepoint();
		try {
			Award__c awardRecord = [Select id,CreatedById,Application__r.IndirectCostPercentage__c from Award__c where id=:award];
			AmendmentRequest__c amendmentRequest = new AmendmentRequest__c();
			amendmentRequest.RecordTypeId = recordTypeid;
			amendmentRequest.Award__c = award;
			amendmentRequest.Purpose__c = purpose;
			amendmentRequest.Impact__c = impact;
			system.debug('-------------------'+awardRecord.Application__r.IndirectCostPercentage__c);
			amendmentRequest.IndirectCostPercentage__c = awardRecord.Application__r.IndirectCostPercentage__c;
			GNT__PageDataHolder__c pageDataHolder = new GNT__PageDataHolder__c(GNT__JSONData1__c= JSON.serialize(amendmentRequest));
			insert  pageDataHolder;
		
		    Id pagedataHolderId = pageDataHolder.Id;           
		    result.put('URL','apex/AmendmentRequestEdit?pageDataHolder='+pagedataHolderId);
		    result.put('Error','');
		    return result;
		}
	    catch(Exception ex) {
	    	result.put('Error',ex.getMessage());
            Database.rollback(sp);
            return result;
	    }
	}
}