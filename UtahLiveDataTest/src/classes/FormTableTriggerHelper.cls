public with sharing class FormTableTriggerHelper extends GNT.TriggerHelper{
	
	public override void processAfterUpdate() {
         updateSMETotalScore(Trigger.new);
    }

    private void updateSMETotalScore(List<FormTable__c> ftList){
    	List<FormTable__c> validFormTable = new List<FormTable__c>();
    	for(FormTable__c f : ftList){
    		if(f.ReviewStepName__c == 'SME Review'){
    			validFormTable.add(f);
    		}
    	}

    	if(validFormTable.size() == 0){
    		return;
    	}

    	Set<Id> reviewIds = new Set<Id>();
    	for(FormTable__c f : validFormTable){
    		if(!reviewIds.contains(f.Review__c)){
    			reviewIds.add(f.Review__c);
    		}
    	}

    	Map<Id, Review__c> reviewIdMap = new Map<Id, Review__c>([Select Id, SMETotalPoints__c from Review__c where Id IN :reviewIds]);
    	AggregateResult[] aggs = [Select SUM(AwardedPoints__c) totalScore, Review__c reviewId from FormTable__c where Review__c IN :reviewIds Group By Review__c];

    	for(AggregateResult agg : aggs){
    		Review__c temp = reviewIdMap.get(String.valueOf(agg.get('reviewId')));
    		temp.SMETotalPoints__c = (Decimal)agg.get('totalScore');
    	}

    	update reviewIdMap.values();
    }
}