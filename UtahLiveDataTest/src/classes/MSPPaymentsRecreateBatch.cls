global class MSPPaymentsRecreateBatch implements Database.Batchable<sObject>, Database.Stateful {
	public String query;
	public MSPPaymentSchedule__c MSPPaymentSchedule;
	public List<String> errors = new List<String>();

	global MSPPaymentsRecreateBatch(MSPPaymentSchedule__c MSPPaymentSchedule){
		this.MSPPaymentSchedule = MSPPaymentSchedule;
	}

	global Database.QueryLocator start(Database.BatchableContext BC){
		try{
			query='SELECT Id FROM PaymentRequest__c WHERE MSPPaymentSchedule__c = \'' + MSPPaymentSchedule.Id + '\'';
			return Database.getQueryLocator(query);
		}catch(Exception e){
			errors.add(e.getMessage());
			return null;
		}
	}

	global void execute(Database.BatchableContext BC, List<PaymentRequest__c> scope){
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
			List<Task> ts = [SELECT Id FROM Task WHERE WhatId = :MSPPaymentSchedule.Id];
			delete ts;
			Database.executeBatch(new MSPPaymentCreationBatch(MSPPaymentSchedule), 200);
		}
	}

	public class MyException extends Exception{}

}