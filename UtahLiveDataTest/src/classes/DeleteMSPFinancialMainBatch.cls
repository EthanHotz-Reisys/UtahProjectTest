global class DeleteMSPFinancialMainBatch implements Database.Batchable<sObject>, Database.Stateful {
	public String query;
	public FileBatch__c fb;
	public List<String> errors = new List<String>();

	global DeleteMSPFinancialMainBatch(FileBatch__c fb){
		this.fb = fb;
	}

	global Database.QueryLocator start(Database.BatchableContext BC){
		try{
			query='SELECT Id FROM MSPFinancialMain__c WHERE FiscalYear__c = \'' + fb.FiscalYear__c + '\'';
			return Database.getQueryLocator(query);
		}catch(Exception e){
			errors.add(e.getMessage());
			return null;
		}
	}

	global void execute(Database.BatchableContext BC, List<MSPFinancialMain__c> scope){
		Savepoint sp = Database.setSavepoint();
		if(scope == null){
			return;
		}

		try{
			delete scope;
		}catch(Exception e){
			errors.add(e.getMessage());
			Database.rollback(sp);
            return;
		}
	}

	global void finish(Database.BatchableContext BC){
		if(errors.size() == 0){
			fb.Status__c = 'Rejected';
			update fb;
		}
	}

	public class MyException extends Exception{}

}