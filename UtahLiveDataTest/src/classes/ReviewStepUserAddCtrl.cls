/**
* Controller class for the Adding Reviewers to a Review Step
*
* CHANGE HISTORY
*================================================================ 
* 04/30/2014	Kunal Shah		      Created 
*================================================================
*/

public with sharing class ReviewStepUserAddCtrl {
	
	//PROPERTIES
	public Id reviewStepId {get;set;}  
    public List<ReviewStepUsersWrapper> lstReviewStepUsersWrapper {get;set;}
    public ReviewStep__c reviewStep {get;set;}
	
	public ReviewStepUserAddCtrl(){

	}
	
	/*
		METHOD TO FIND ALL ACTIVE USERS IN THE ORG
	*/
	public void getUsers(){

	}
	
	/*
		METHOD TO FIND ALL USERS WHO ARE ALREADY ADDED TO A REVIEW STEP
	*/	
	public List<Id> findAddedUsers(){

		return null;
	}
	
	/*
		METHOD TO ADD REVIEWERS TO A REVIEW STEP (OBJECT: REVIEWSTEPUSER__C)
	*/
	public PageReference addToReviewStep(){

        return null;
    }
    
    /*
    	METHOD TO CANCEL ADDING A REVIEWER TO REVIEW STEP
    */ 
    public PageReference Cancel(){

        return null;    }
  	
	/*INNER CLASS*/
    private class ReviewStepUsersWrapper{
 
    }
}