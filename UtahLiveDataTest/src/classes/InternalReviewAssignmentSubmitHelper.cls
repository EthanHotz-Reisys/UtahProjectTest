global with sharing class InternalReviewAssignmentSubmitHelper extends GNT.DynamicLayoutActionRedirect{
    
    /*
        METHOD TO UPDATE THE STATUS ON THE REVIEW ASSIGNMENT
    */
    global override PageReference whenClicked(){
        Sobject record = layoutHolder.getPrimarySObject();
        
        Sobject sobjectRec;
        Id recordId = (Id)record.get('Id');
        Decimal totalScore = 0.0;
        
        Review__c assign = [SELECT ID, Status__c,Application__c,PreApplication__c,SummaryScore__c,
                            AcceptanceStatus__c,PanelApplication__r.ReviewPanel__r.ReviewPackage__r.GNT__PageTemplateConfig__r.GNT__EditLayoutConfig__c,
                            PanelApplication__r.ReviewPanel__r.ExcludeFromScoring__c,ReviewPanel__r.ReviewStep__c,AdditionalInformationNeeded__c,
                            PreDecisionSiteVisitRequired__c,SupplementalSubmissionRequired__c,Recommendation__c,RecommendedBudget__c
                             FROM Review__c WHERE ID = : recordId];
        
        try{
           
            if(assign.AcceptanceStatus__c == null){
                assign.AcceptanceStatus__c = 'Accepted';
            }
            
            assign.Status__c = 'Review Completed';
           
            assign.OwnerId = UserInfo.getUserId();
            
            
            update assign;
            
        }
        catch(DMLException e){
            ApexPages.Message errorMsg1 = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
            ApexPages.addMessage(errorMsg1);
            return null;
        }
        Boolean additionalReqResult = validateInternalFormAdditionalRequests(assign);
        Boolean reccomendationResult = validateInternalFormRecommendation(assign);
        if(additionalReqResult && reccomendationResult){
            PageReference p = Page.reviewassignmentview;
            p.getParameters().put('id', recordId);
            p.setRedirect(true);
            return p;
        }else
            return null;
        
    }
    
     private boolean validateInternalFormAdditionalRequests(Review__c assign){
         if(assign.AdditionalInformationNeeded__c != null && assign.AdditionalInformationNeeded__c=='Yes'){
             if(assign.PreDecisionSiteVisitRequired__c == null || assign.SupplementalSubmissionRequired__c == null){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.InternalReviewFormAdditionalRequestError);
                ApexPages.addMessage(myMsg);
                return false;
             }else
                 return true;
         }
         return true;
    }
     
    private boolean validateInternalFormRecommendation(Review__c assign){
        System.debug('assign.Recommendation__c-->>>'+assign.Recommendation__c);
        if(assign.Recommendation__c == 'Recommended'){
            System.debug('assign.RecommendedBudget__c-->>>'+assign.RecommendedBudget__c);
            if(assign.RecommendedBudget__c == null){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.InternalReviewFormRecommendationError);
                ApexPages.addMessage(myMsg);
                return false;
            }else
               return true;
        }
        return true;  
    }
}