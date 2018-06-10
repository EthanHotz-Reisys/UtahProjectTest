public class MSPFinancialBatchTriggerHelper extends GNT.TriggerHelper{

	public override void processBeforeInsert() {
		validAmendment((List<MSPFinancialBatch__c>)Trigger.new);
		validCreate((List<MSPFinancialBatch__c>)Trigger.new);
	}


	public override void processAfterUpdate() {
		createApprovalTask((List<MSPFinancialBatch__c>)Trigger.new);
	}

	private void validAmendment(List<MSPFinancialBatch__c> batchList){
		List<MSPFinancialBatch__c> amendBatches = new List<MSPFinancialBatch__c>();
		for(MSPFinancialBatch__c mfb: batchList){
			if(mfb.Type__c == 'Amend'){
				amendBatches.add(mfb);
			}
		}

		Set<String> fiscalYears = new Set<String>();
		for(MSPFinancialBatch__c mfb : amendBatches){
			if(!fiscalYears.contains(mfb.FiscalYear__c)){
				fiscalYears.add(mfb.FiscalYear__c);
			}
		}

		AggregateResult[] mfbCounts = [SELECT COUNT(Id) mfbCount FROM MSPFinancialBatch__c WHERE Status__c = 'Active' AND FiscalYear__c IN :fiscalYears GROUP BY FiscalYear__c];
		if(mfbCounts.size() != fiscalYears.size()){
			for(MSPFinancialBatch__c mfb : amendBatches){
				mfb.addError('At Least One Create Batch Should be Active Before Amend for This Fiscal Year');
			}
		}
	}

	private void validCreate(List<MSPFinancialBatch__c> batchList){
		List<MSPFinancialBatch__c> createBatches = new List<MSPFinancialBatch__c>();
		for(MSPFinancialBatch__c mfb : batchList){
			if(mfb.Type__c == 'Create'){
				createBatches.add(mfb);
			}
		}
		System.debug('***' + createBatches);
		Set<String> fiscalYears = new Set<String>();
		for(MSPFinancialBatch__c mfb : createBatches){
			if(!fiscalYears.contains(mfb.FiscalYear__c)){
				fiscalYears.add(mfb.FiscalYear__c);
			}
		}
		System.debug('***' + fiscalYears);
		AggregateResult[] mfbCounts = [SELECT COUNT(Id) mfbCount FROM MSPFinancialBatch__c WHERE Status__c IN ('Active','Approved') AND FiscalYear__c IN :fiscalYears GROUP BY FiscalYear__c];
		System.debug('***' + mfbCounts);
		if(mfbCounts.size() > 0){
			for(MSPFinancialBatch__c mfb : createBatches){
				mfb.addError('A batch is already approved or active for this fiscal year, cannot create another create batch');
			}
		}
	}

	private void createApprovalTask(List<MSPFinancialBatch__c> batchList){

		List<MSPFinancialBatch__c> validBatch = new List<MSPFinancialBatch__c>();
		Map<Id, MSPFinancialBatch__c> batchOldMap = (Map<Id, MSPFinancialBatch__c>)Trigger.oldMap;

		for(MSPFinancialBatch__c mfb : batchList){
			if(mfb.Status__c == 'Processed' && batchOldMap.get(mfb.Id).Status__c == 'Uploaded'){
				validBatch.add(mfb);
			}
		}

		if(validBatch.size() == 0){
			return;
		}

		List<Task> batchApprovalTasks = new List<Task>();
		
		for(MSPFinancialBatch__c mfb : validBatch){			
			List<Task> batchApprovalTask = GNT.TaskCreationHandler.createTasks(mfb.Batchapprover__c,
	            mfb.Id,'MSP Batch Approval',
	            mfb.FiscalYear__c + ' ' + mfb.Type__c, null, false, null,
	            'Approval', mfb.FiscalYear__c + ' ' + mfb.Type__c, false
	        );

	        if(batchApprovalTask != null && batchApprovalTask.size() > 0) {
	            batchApprovalTasks.add(batchApprovalTask[0]);
	        }
	    }
	    
	    insert batchApprovalTasks;
	}
}