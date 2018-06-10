global class MSPPaymentCreationBatch implements Database.Batchable<sObject>, Database.Stateful {
	public String query;
	public MSPPaymentSchedule__c MSPPaymentSchedule;
	public List<String> errors = new List<String>();
	public Integer previousPaymentScheduleCount;

	global MSPPaymentCreationBatch(MSPPaymentSchedule__c MSPPaymentSchedule){
		this.MSPPaymentSchedule = MSPPaymentSchedule;
		System.debug('***' + MSPPaymentSchedule.ScheduleDate__c);
		System.debug('***' + MSPPaymentSchedule.FiscalYear__c);
		previousPaymentScheduleCount = [SELECT COUNT() FROM MSPPaymentSchedule__c WHERE ScheduleDate__c < :MSPPaymentSchedule.ScheduleDate__c AND FiscalYear__c = :MSPPaymentSchedule.FiscalYear__c AND Pathway__c =: MSPPaymentSchedule.Pathway__c];
	
	}

	global Database.QueryLocator start(Database.BatchableContext BC){
		try{
			System.debug('Start');
			query='SELECT Id, TotalActiveAwardAmount__c, USBEPathway__c, NumberofAwards__c, (SELECT Id FROM Awards__r WHERE Status__c = \'Activated\') FROM Grant__c WHERE USBEPathway__c = \'' + MSPPaymentSchedule.Pathway__c + '\' AND FiscalYear__c = \'' + MSPPaymentSchedule.FiscalYear__c + '\'';
			//query='SELECT Id, PaymentCount__c, PaymentSum__c, CatchUpSum__c, TotalActiveAwardAmount__c FROM MSPGrant__c WHERE FiscalYear__c = \'' + MSPPaymentSchedule.FiscalYear__c + '\'';
			return Database.getQueryLocator(query);
		}catch(Exception e){
			errors.add(e.getMessage());
			System.debug('Start**' + e.getMessage());
			return null;
		}
	}

	global void execute(Database.BatchableContext BC, List<Grant__c> scope){
		Savepoint sp = Database.setSavepoint();

		if(scope == null){
			return;
		}

		try{
			AggregateResult[] aggs = [SELECT COUNT(Id) paymentCount, SUM(PaymentAmount__c) paymentSum, SUM(CatchUp__c) catchUpSum, Grant__c grantId FROM PaymentRequest__c WHERE Grant__c IN :scope GROUP BY Grant__c];
			Map<String, Decimal> paymentSumMap = new Map<String, Decimal>();
			Map<String, Decimal> catchUpSumMap = new Map<String, Decimal>();
			for(AggregateResult agg : aggs){
				paymentSumMap.put(String.valueOf(agg.get('grantId')), (Decimal)agg.get('paymentSum'));
				catchUpSumMap.put(String.valueOf(agg.get('grantId')), (Decimal)agg.get('catchUpSum'));
			}
			
			List<PaymentRequest__c> newmps = new List<PaymentRequest__c>();
			for(Grant__c mg : scope){

				Decimal paymentAmount = 0;
				Decimal catchUp = 0;

				if(previousPaymentScheduleCount == 0){
					paymentAmount = mg.TotalActiveAwardAmount__c / 12;
				}else{
					Decimal originalTotal = mg.TotalActiveAwardAmount__c / 12 * previousPaymentScheduleCount;
					Decimal paymentSum = paymentSumMap.get(mg.Id) == null ? 0 : paymentSumMap.get(mg.Id);
					Decimal catchUpSum = catchUpSumMap.get(mg.Id) == null ? 0 : catchUpSumMap.get(mg.Id);
					if(originalTotal > paymentSum + catchUpSum){
						catchUp = originalTotal - paymentSum - catchUpSum;
						paymentAmount = mg.TotalActiveAwardAmount__c / 12;
					}else{
						paymentAmount = (mg.TotalActiveAwardAmount__c - paymentSum - catchUpSum) / (12 - previousPaymentScheduleCount);
					}
				}

				PaymentRequest__c temp = new PaymentRequest__c(
					Grant__c = mg.Id,
					MSPPaymentSchedule__c = MSPPaymentSchedule.Id,
					//PaymentOrder__c = mg.PaymentCount__c + 1,
					PaymentAmount__c = paymentAmount.setScale(2),
					CatchUp__c = catchup.setScale(2),
					USBEPathway__c = mg.USBEPathway__c,
					AwardVersionNumber__c = mg.NumberofAwards__c,
					Award__c = mg.Awards__r[0].Id
				);
				if(temp.CatchUp__c < 0.02){
					temp.PaymentAmount__c = temp.PaymentAmount__c + temp.CatchUp__c;
					temp.CatchUp__c = 0;
				}
				newmps.add(temp);
			} 

			insert newmps;

			if(previousPaymentScheduleCount == 11){
				Map<Id, PaymentRequest__c> grantIdPaymentMap = new Map<Id, PaymentRequest__c>();
				for(PaymentRequest__c pr : newmps){
					grantIdPaymentMap.put(pr.Grant__c, pr);
				}
				AggregateResult[] finalAggs = [SELECT COUNT(Id) paymentCount, SUM(PaymentAmount__c) paymentSum, SUM(CatchUp__c) catchUpSum, Grant__c grantId FROM PaymentRequest__c WHERE Grant__c IN :scope GROUP BY Grant__c];
				Map<String, Decimal> finalPaymentSumMap = new Map<String, Decimal>();
				Map<String, Decimal> finalCatchUpSumMap = new Map<String, Decimal>();				
				for(AggregateResult agg : finalAggs){
					finalPaymentSumMap.put(String.valueOf(agg.get('grantId')), (Decimal)agg.get('paymentSum'));
					finalCatchUpSumMap.put(String.valueOf(agg.get('grantId')), (Decimal)agg.get('catchUpSum'));
				}
				for(Grant__c mg : scope){
					if(mg.TotalActiveAwardAmount__c > finalPaymentSumMap.get(mg.Id) + finalCatchUpSumMap.get(mg.Id)){
						grantIdPaymentMap.get(mg.Id).PaymentAmount__c = grantIdPaymentMap.get(mg.Id).PaymentAmount__c + mg.TotalActiveAwardAmount__c - finalPaymentSumMap.get(mg.Id) - finalCatchUpSumMap.get(mg.Id);
					}
				}
				update newmps;
			}
			//payment finet linking
			Map<Id, Id> awardPaymentIdMap = new Map<Id, Id>();
			for(PaymentRequest__c pr : newmps){
				awardPaymentIdMap.put(pr.Award__c, pr.Id);
			}

			//AggregateResult[] paymentFinetAggs = [SELECT COUNT(Id) finetPaymentCount, SUM(OneTwelvePaymentAmount__c) finetPaymentSum, SUM(OneTwelveCatchUpAmount__c) finetCatchUpSum, AwardFINETCode__r.MSPUniqueKeyFormula__c awardFinetKey FROM PaymentFINETCode__c WHERE AwardFINETCode__r.Award__c IN :awardPaymentIdMap.keySet() GROUP BY AwardFINETCode__r.MSPUniqueKeyFormula__c];
			
			List<PaymentFINETCode__c> paidFinetPaymentList = [SELECT Id, OneTwelvePaymentAmount__c, OneTwelveCatchUpAmount__c, AwardFINETCode__r.MSPUniqueKeyFormula__c FROM PaymentFINETCode__c WHERE AwardFINETCode__r.Award__r.Grant__c IN :scope];

			List<AwardFINETCode__c> realScope = [SELECT Id, Amount__c, Award__c, MSPUniqueKeyFormula__c FROM AwardFINETCode__c WHERE Award__c IN :awardPaymentIdMap.keySet()];

			Map<String, Decimal> finetPaymentSumMap = new Map<String, Decimal>();
			Map<String, Decimal> finetCatchUpSumMap = new Map<String, Decimal>();


			for(PaymentFINETCode__c pfc : paidFinetPaymentList){
				if(finetPaymentSumMap.get(pfc.AwardFINETCode__r.MSPUniqueKeyFormula__c) == null){
					finetPaymentSumMap.put(pfc.AwardFINETCode__r.MSPUniqueKeyFormula__c, 0);
				}
				finetPaymentSumMap.put(pfc.AwardFINETCode__r.MSPUniqueKeyFormula__c, finetPaymentSumMap.get(pfc.AwardFINETCode__r.MSPUniqueKeyFormula__c) + pfc.OneTwelvePaymentAmount__c);
				
				if(finetCatchUpSumMap.get(pfc.AwardFINETCode__r.MSPUniqueKeyFormula__c) == null){
					finetCatchUpSumMap.put(pfc.AwardFINETCode__r.MSPUniqueKeyFormula__c, 0);
				}
				finetCatchUpSumMap.put(pfc.AwardFINETCode__r.MSPUniqueKeyFormula__c, finetCatchUpSumMap.get(pfc.AwardFINETCode__r.MSPUniqueKeyFormula__c) + pfc.OneTwelveCatchUpAmount__c);			
			}

			List<PaymentFINETCode__c> newPfc = new List<PaymentFINETCode__c>();
			for(AwardFINETCode__c afc : realScope){
				Decimal paymentAmount = 0;
				Decimal catchUp = 0;

				if(previousPaymentScheduleCount == 0){
					paymentAmount = afc.Amount__c / 12;
				}else{
					Decimal originalTotal = afc.Amount__c / 12 * previousPaymentScheduleCount;
					Decimal paymentSum = finetPaymentSumMap.get(afc.MSPUniqueKeyFormula__c) == null ? 0 : finetPaymentSumMap.get(afc.MSPUniqueKeyFormula__c);
					Decimal catchUpSum = finetCatchUpSumMap.get(afc.MSPUniqueKeyFormula__c) == null ? 0 : finetCatchUpSumMap.get(afc.MSPUniqueKeyFormula__c);
					if(originalTotal > paymentSum + catchUpSum){
						catchUp = originalTotal - paymentSum - catchUpSum;
						paymentAmount = afc.Amount__c / 12;
					}else{
						paymentAmount = (afc.Amount__c - paymentSum - catchUpSum) / (12 - previousPaymentScheduleCount);
					}
				}

				PaymentFINETCode__c temp = new PaymentFINETCode__c(
					AwardFINETCode__c = afc.Id,
					PaymentRequest__c = awardPaymentIdMap.get(afc.Award__c),
					OneTwelvePaymentAmount__c = paymentAmount.setScale(2),
					OneTwelveCatchUpAmount__c = catchup.setScale(2),
					RequestedAmount__c = paymentAmount.setScale(2) + catchup.setScale(2),
					Amount__c = afc.Amount__c
				);
				if(temp.OneTwelveCatchUpAmount__c < 0.02){
					temp.OneTwelvePaymentAmount__c = temp.OneTwelvePaymentAmount__c + temp.OneTwelveCatchUpAmount__c;
					temp.OneTwelveCatchUpAmount__c = 0;
				}
				newPfc.add(temp);				
			}

			insert newPfc;

			if(previousPaymentScheduleCount == 11){
				List<PaymentFINETCode__c> newPfcList = [SELECT Id, AwardFINETCode__r.MSPUniqueKeyFormula__c, OneTwelvePaymentAmount__c, OneTwelveCatchUpAmount__c FROM PaymentFINETCode__c WHERE Id IN :newPfc];
				List<PaymentFINETCode__c> finalPaidFinetPaymentList = [SELECT Id, OneTwelvePaymentAmount__c, OneTwelveCatchUpAmount__c, AwardFINETCode__r.MSPUniqueKeyFormula__c FROM PaymentFINETCode__c WHERE AwardFINETCode__r.Award__r.Grant__c IN :scope];
				
				Map<String, PaymentFINETCode__c> afcIdFinetPaymentMap = new Map<String, PaymentFINETCode__c>();

				Map<String, Decimal> finalPaymentSumMap = new Map<String, Decimal>();
				Map<String, Decimal> finalCatchUpSumMap = new Map<String, Decimal>();

				for(PaymentFINETCode__c pfc : newPfcList){
					afcIdFinetPaymentMap.put(pfc.AwardFINETCode__r.MSPUniqueKeyFormula__c, pfc);
				}

				for(PaymentFINETCode__c pfc : finalPaidFinetPaymentList){
					if(finalPaymentSumMap.get(pfc.AwardFINETCode__r.MSPUniqueKeyFormula__c) == null){
						finalPaymentSumMap.put(pfc.AwardFINETCode__r.MSPUniqueKeyFormula__c, 0);
					}
					finalPaymentSumMap.put(pfc.AwardFINETCode__r.MSPUniqueKeyFormula__c, finalPaymentSumMap.get(pfc.AwardFINETCode__r.MSPUniqueKeyFormula__c) + pfc.OneTwelvePaymentAmount__c);
					
					if(finalCatchUpSumMap.get(pfc.AwardFINETCode__r.MSPUniqueKeyFormula__c) == null){
						finalCatchUpSumMap.put(pfc.AwardFINETCode__r.MSPUniqueKeyFormula__c, 0);
					}
					finalCatchUpSumMap.put(pfc.AwardFINETCode__r.MSPUniqueKeyFormula__c, finalCatchUpSumMap.get(pfc.AwardFINETCode__r.MSPUniqueKeyFormula__c) + pfc.OneTwelveCatchUpAmount__c);	
				}

				//AggregateResult[] finalAggs = [SELECT COUNT(Id) finetPaymentCount, SUM(OneTwelvePaymentAmount__c) finetPaymentSum, SUM(OneTwelveCatchUpAmount__c) finetCatchUpSum, AwardFINETCode__c awardFinetId FROM PaymentFINETCode__c WHERE AwardFINETCode__r.Award__c IN :awardPaymentIdMap.keySet() GROUP BY AwardFINETCode__c];
				/*
				for(AggregateResult agg : finalAggs){
					finalPaymentSumMap.put(String.valueOf(agg.get('awardFinetId')), (Decimal)agg.get('finetPaymentSum'));
					finalCatchUpSumMap.put(String.valueOf(agg.get('awardFinetId')), (Decimal)agg.get('finetCatchUpSum'));
				}
				*/
				for(AwardFINETCode__c afc : realScope){
					if(afc.Amount__c > finalPaymentSumMap.get(afc.MSPUniqueKeyFormula__c) + finalCatchUpSumMap.get(afc.MSPUniqueKeyFormula__c)){
						afcIdFinetPaymentMap.get(afc.MSPUniqueKeyFormula__c).OneTwelvePaymentAmount__c = afcIdFinetPaymentMap.get(afc.MSPUniqueKeyFormula__c).OneTwelvePaymentAmount__c + afc.Amount__c - finalPaymentSumMap.get(afc.MSPUniqueKeyFormula__c) - finalCatchUpSumMap.get(afc.MSPUniqueKeyFormula__c);
						afcIdFinetPaymentMap.get(afc.MSPUniqueKeyFormula__c).RequestedAmount__c = afcIdFinetPaymentMap.get(afc.MSPUniqueKeyFormula__c).OneTwelvePaymentAmount__c + afcIdFinetPaymentMap.get(afc.MSPUniqueKeyFormula__c).OneTwelveCatchUpAmount__c;
					}
				}
				update newPfc;
			}


		}catch(Exception e){
			errors.add(e.getMessage());
			Database.rollback(sp);
            return;
		}
	}

	global void finish(Database.BatchableContext BC){
		if(errors.size() == 0){
			MSPPaymentSchedule__c currentmps = [SELECT Id, Status__c, FirstApprover__c, ScheduleDate__c FROM MSPPaymentSchedule__c WHERE Id = :MSPPaymentSchedule.Id];
			currentmps.Status__c = 'Payment Requests Created';
			update currentmps;

			List<Task> firstApprovalTask = GNT.TaskCreationHandler.createTasks(currentmps.FirstApprover__c,
	            currentmps.Id,'MSP Payment First Approval',
	            String.valueOf(currentmps.ScheduleDate__c) + ' MSP Payments First Approval', null, false, null,
	            'Approval', String.valueOf(currentmps.ScheduleDate__c) + ' MSP Payments First Approval', false
	        );

	        if(firstApprovalTask != null && firstApprovalTask.size() > 0) {
	            insert firstApprovalTask[0];
	        }

		}
	}

	public class MyException extends Exception{}

}