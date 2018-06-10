public with sharing class ReviewRedirectCtrl{
    
    Boolean reviewLevelAcceptance;
    Id recordId;
    
    public ReviewRedirectCtrl(){
        recordId = ApexPages.CurrentPage().getParameters().get('id');
    }
    
    public PageReference redirect() {
        reviewLevelAcceptance = true;
        PageReference p = null;


        Review__c review = [Select id, AcceptanceStatus__c,status__c, 
            ReviewPanel__r.ReviewStep__r.ReviewLevelAcceptance__c From Review__c where Id = :recordId ];
        
        if(review != null && review.ReviewPanel__r.ReviewStep__r.ReviewLevelAcceptance__c != null){
            reviewLevelAcceptance = review.ReviewPanel__r.ReviewStep__r.ReviewLevelAcceptance__c;
        }
        system.debug('reviewLevelAcceptance ----'+reviewLevelAcceptance);
        if(reviewLevelAcceptance){
            if(review.AcceptanceStatus__c == null){
                p = Page.ReviewAssignmentAcceptance;
                p.getParameters().put('id', recordId);
            }else if(review.AcceptanceStatus__c == 'Accepted'){
                p = Page.ReviewAssignmentEdit;
                p.getParameters().put('id', recordId);
            }else{
                p = Page.reviewassignmentview;
                p.getParameters().put('id', recordId);
            }
        }else{
            if(review.AcceptanceStatus__c == null){
                review.AcceptanceStatus__c = 'Accepted';
                update review;
                p = Page.ReviewAssignmentEdit;
                p.getParameters().put('id', recordId);
            }else if(review.status__c =='Review Completed'){
                p= Page.reviewassignmentview;
                p.getParameters().put('id', recordId);
            }else{
                p = Page.ReviewAssignmentEdit;
                p.getParameters().put('id', recordId);
            }
        }
        return p;
    }
}