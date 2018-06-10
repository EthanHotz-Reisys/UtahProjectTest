/**
* CLASS TO SEND PROPOSALS TO REVIEWERS
* OBJECT USED: REVIEWASSIGNMENT
*
* CHANGE HISTORY
*================================================================ 
* 05/05/2014    Kunal Shah            Created
* 05/05/2014    Vineeth Shetty            Created 
* 9/9/2014 		Nakul Kadam			Added updateReviewAssignmentShare
* 11/18/2014 		Nakul				Updated code for Review Panels
*================================================================
*/
public with sharing class ReviewAssignmentsSendCtrl {
    
    public Id reviewStepId {get;set;}
    public ReviewStep__c reviewStep {get;set;}
    public List<ProposalWrapper> lstProposalWrapper {get;set;}
    
    public ReviewAssignmentsSendCtrl(){
        
    }
    
    /*
        METHOD TO FIND ALL ASSIGNMENTS FOR A REVIEW STEP
    */
    public void getProposals(){
        //List<Id> proposalsSent = findSentProposals();
        
    }
    
    /*
        METHOD TO FIND ALL PROPOSALS WHICH ARE ALREADY SENT FOR REVIEW
    */ 
    public List<Id> findSentProposals(){
        
        return null;
    } 
    
    private void updateReviewAssignmentShare(List<Id> revIds){
    	
    }
    
    /*
        METHOD TO SEND PROPOSALS TO REVIEWERS
    */
    public PageReference sendProposals(){
          
        return null;
    }
    
    /*
        METHOD TO CANCEL SENDING PROPOSALS FOR REVIEW
    */ 
    public PageReference Cancel(){
        
        return null;
    }
    
    /*INNER CLASS*/
    private class ProposalWrapper{
        
    }
}