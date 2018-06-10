/**
* CLASS TO ASSIGN REVIEWERS TO APPLICATIONS
* OBJECT USED: REVIEWASSIGNMENT
*
* CHANGE HISTORY
*================================================================ 
* 04/30/2014    Kunal Shah            Created 
*================================================================
*/

public with sharing class ReviewAssignmentAddCtrl {
    
    //PROPERTIES
    public Id reviewStepApplicationId {get;set;}  
    public List<ReviewAssignmentWrapper> lstReviewStepAssignmentUsersWrapper {get;set;}
    public ReviewStepApplication__c reviewStepApplication {get;set;}
    public Boolean useReviewPanelsForReiewAssignment{get;set;}
    
    public ReviewAssignmentAddCtrl(){
    }
    
    /*
        METHOD TO FIND ALL ACTIVE USERS IN THE ORG
    */
    public void getUsers(){
    }
    
    /*
		METHOD TO FIND ALL USERS WHO ARE ALREADY ADDED TO A REVIEW STEP APPLICATION
	*/	
	public List<Id> findAddedUsers(){
		return null;
	}
    
    /*
        METHOD TO ADD REVIEWERS TO A REVIEW STEP (OBJECT: ReviewAssignment__c)
    */
    public PageReference addToReviewStepApplication(){
         
        return null;   
    }
    
    /*
        METHOD TO CANCEL ADDING A REVIEWER TO REVIEW STEP
    */ 
    public PageReference Cancel(){
        
        return null;
    }
    
    /*INNER CLASS*/
    private class ReviewAssignmentWrapper{
        
    }
}