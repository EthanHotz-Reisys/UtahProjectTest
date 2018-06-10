/*
    This class handles the auto Assignement of Panel Applications to Group 
    and auto population of ReviewStepApplication__c when a panel Application record is inserted.
    ***********************************************************
    Audit History
    ***********************************************************
    11/13/2014      Nakul         Created
    *********************************************************** 
*/
public without sharing class PanelApplicationTriggerHelper extends GNT.TriggerHelper{
    
    
    public override void processAfterInsert() {
        autoAssignSubmittedApplication();
    }
    
    public override void processBeforeInsert() {
       // updateDecisionStatus();
        // TODO - update the status of Panel Applications
    }
    
    public override void processBeforeDelete(){
        validateDelete();
    }

    private void validateDelete(){
        Set<Id> pAppsId = new Set<Id>();
        Set<Id> eligiblepAppsId = new Set<Id>();
        
        Map<Id, Review__c> panelAppReviews = new Map<Id, Review__c>([
            SELECT id,PanelApplication__c,Status__c FROM Review__c 
            WHERE PanelApplication__c in :trigger.oldMap.keySet() 
            AND Status__c IN ('Sent For Review','Review Completed','Review In Progress') AND Application__r.GrantorOrganizationName__c NOT IN ('USBE', 'SYSTEM')]);
        
        for(Review__c rev : panelAppReviews.values()) {
            pAppsId.add(rev.PanelApplication__c);
        }
        for(PanelApplication__c panApp : (List<PanelApplication__c>)trigger.oldMap.values()) {
            if(!pAppsId.contains(panApp.Id)) {
                eligiblepAppsId.add(panApp.Id);
            }else{
                //panApp.addError('The selected Application cannot be Removed since the Review might be in progress.');
                panApp.addError(GNT.ErrorMessageHelper.fetchMessage('M01-GRNTR-85612'));
            }
        }
        if(eligiblepAppsId.size() > 0){
            deleteAssociatedAssignedReviews(eligiblepAppsId);
        }
    }

    private void deleteAssociatedAssignedReviews(Set<Id> pAppsId) {
        List<Review__c> reviews = [select id,PanelApplication__c,Status__c from Review__c where PanelApplication__c in :pAppsId AND Status__c = 'Assigned'];
        system.debug('reviewstrigg: '+reviews);
        if(reviews.size() > 0) {
            delete reviews;
        }
    }
    
    /*private void updateDecisionStatus(){
        
        
        Id revStepId = panelAppLst[0].ReviewPanel__r.ReviewStep__c;
        List<PanelApplication__c> panelAppsLst = trigger.new;
        system.debug('review step id is '+revStepId);
        for(PanelApplication__c panApp : panelAppsLst){
        	List<ReviewStep__c> revStep = [SELECT Id,Status__c,StepNumber__c FROM ReviewStep__c WHERE id =:revStepId];
            	if(revStep[0].StepNumber__c == 2 && revStep[0].Status__c != 'In Progress'){
                    system.debug('Inside rev Step loop' +revStep[0].Status__c);
                	panApp.addError('Please initiate the review before adding the applications.');
            	}
        }
    }*/
    /* This method is used to Auto assign the Panel Applications to the Group id set in the Review Panel
    */
    private void autoAssignSubmittedApplication(){
        List<PanelApplication__c> panelAppLst = [Select Id, RecordTypeId, ReviewPanel__c, ReviewPanel__r.AutoAssignSubmittedApplication__c,
                                                 ReviewPanel__r.ReviewStep__c, ReviewPanel__r.GroupId__c , 
                                                 Application__c, PreApplication__c From PanelApplication__c Where Id IN : trigger.newMap.keySet()];        
        
        List<PanelApplication__c> eligiblePanelAppList = new List<PanelApplication__c>();
        // PAnel App eligible for Auto Assignment
        /*for(PanelApplication__c pApp : panelAppLst){
        Id revStepId = pApp.ReviewPanel__r.ReviewStep__c;
        List<ReviewStep__c> revStep = [SELECT Id,Status__c,StepNumber__c FROM ReviewStep__c WHERE id =:revStepId];
             if(revStep[0].StepNumber__c == 2 && revStep[0].Status__c != 'In Progress'){
       
            }
        }*/
        Id revStepId = panelAppLst[0].ReviewPanel__r.ReviewStep__c;
        //List<ReviewStep__c> revStep = [SELECT Id,Status__c,StepNumber__c FROM ReviewStep__c WHERE id =:revStepId];
        //system.debug('review Step status is ' + revStep[0].Status__c);
        System.debug('Panel Auto Assign is ---->'+panelAppLst[0].ReviewPanel__r.AutoAssignSubmittedApplication__c);
         System.debug('Panel Group Id is ---->'+panelAppLst[0].ReviewPanel__r.GroupId__c);
        /*for(PanelApplication__c panelApps : (List<PanelApplication__c>)trigger.oldMap.values()){
            if(revStep[0].StepNumber__c == 2 && revStep[0].Status__c != 'In Progress'){
                //panelApps.addError('Please initiate the review before adding the applications.');
            }
        }*/
        for(PanelApplication__c pApp : panelAppLst){                        
            if(pApp.ReviewPanel__r.AutoAssignSubmittedApplication__c != null && pApp.ReviewPanel__r.AutoAssignSubmittedApplication__c && pApp.ReviewPanel__r.GroupId__c != null ){
                eligiblePanelAppList.add(pApp);
            }
        }
        
        Id rpAppRecTypeId = Schema.SObjectType.PanelApplication__c.getRecordTypeInfosByName().get('Application').getRecordTypeId();
        Id rpPreAppRecTypeId = Schema.SObjectType.PanelApplication__c.getRecordTypeInfosByName().get('Pre-Application').getRecordTypeId();
        
        // create review records
        List<Review__c> reviewInsertList = new List<Review__c>();
        for(PanelApplication__c panelApp : eligiblePanelAppList){
            Review__c review = new Review__c();
            if(panelApp.RecordTypeId == rpAppRecTypeId){
                review.Application__c = panelApp.Application__c;
            }else if(panelApp.RecordTypeId == rpPreAppRecTypeId){
                review.PreApplication__c = panelApp.PreApplication__c;
            }
            review.PanelApplication__c = panelApp.Id;
            review.ReviewPanel__c = panelApp.ReviewPanel__c;
            review.OwnerId = panelApp.ReviewPanel__r.GroupId__c;
            reviewInsertList.add(review);
        }        
        if(reviewInsertList.size() > 0){
            insert reviewInsertList;
        }
    }
    
}