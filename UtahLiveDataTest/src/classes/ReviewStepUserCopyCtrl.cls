/**
* Controller class to copy the ReviewStepUsers from Previous Step to Next step
*
* CHANGE HISTORY
*================================================================ 
* 05/02/2014	Kunal Shah		      Created 
*================================================================
*/
public with sharing class ReviewStepUserCopyCtrl {
	
	public Id reviewStepId {get;set;}
	public ReviewStep__c reviewStep {get;set;}
	public List<ReviewStepUser__c> oldStepUsers {get;set;}
	public List<ReviewStepUser__c> newStepUsers {get;set;}
	
	public ReviewStepUserCopyCtrl() {
	}
	
	/*
		METHOD TO GET ALL THE REVIEWERS IN THE PREVIOUS STEP
	*/
	public void getOldStepUsers(){							
	}
	
	/*
		METHOD TO COPY ALL THE STEP USERS FROM PREVIOUS STEP TO CURRENT STEP 
	*/
	public PageReference copyUsersToNextStep(){

		return null;
	}
	
	/*
        METHOD TO CANCEL COPYING REVIEWERS
    */ 
    public PageReference Cancel(){

        return null;
    }
	
}