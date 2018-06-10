/*
	All trigger logic on Review Step User Object
	**********************************************************
	Audit History
	**********************************************************
	2014-05-01		Vinayak Sharma		 Created 
	**********************************************************  
*/

public with sharing class ReviewStepUserTriggerHelper extends GNT.TriggerHelper {
	
	public override void processAfterInsert(){
		countNumberOfReviewers(Trigger.new);
	}
	
	public override void processAfterUpdate(){
		countNumberOfReviewers(Trigger.new); 
	} 
	
	public override void processAfterDelete(){
	} 
	
	private void countNumberOfReviewers(List<ReviewStepUser__c> lstUsers){
		
		// Select list of the review step users with step review  of the incoming user who is added to the project  
		List<ReviewStepUser__c> lstReviewStepUsers = [Select Id,ReviewStep__c,Reviewer__c  from ReviewStepUser__c where Id in : lstUsers];
		
		Set<String> reviewStepsSet = new Set<String>();
		
		for(ReviewStepUser__c stepReview  :lstReviewStepUsers){
			reviewStepsSet.add(stepReview.ReviewStep__c);			
		}
		  
		List<ReviewStep__c> lstReviewSteps = [Select Id,NumberOfAssignedReviewers__c from ReviewStep__c where Id in : reviewStepsSet];   
								 		
	    Map<String, Set<String>> userIdMap = new Map<String, Set<String>>();  //key->Step Review id, value->set of user id      
	    
	    for(ReviewStepUser__c reviewStep: lstReviewStepUsers){
			Set<String> innerList = userIdmap.get(reviewStep.ReviewStep__c);  
			if(innerList == null){  	
				innerList = new Set<String>(); 	    					
				userIdMap.put(reviewStep.ReviewStep__c,innerList);		  								     	
			} 
	    	 innerList.add(reviewStep.Reviewer__c);  	  
	    }
	    
	    List<ReviewStep__c> updateReviewStepLst = new List<ReviewStep__c>();
	     
	    for(String reviewId :  userIdMap.keyset()){	    	 
	    	 Set<String> reviewers = userIdMap.get(reviewId);	    	 
	    	 
	    	 updateReviewStepLst.add(new ReviewStep__c( Id =reviewId, NumberOfAssignedReviewers__c = reviewers.size()));	    	  
	    } 
	    update updateReviewStepLst;      
	    	
	}

}