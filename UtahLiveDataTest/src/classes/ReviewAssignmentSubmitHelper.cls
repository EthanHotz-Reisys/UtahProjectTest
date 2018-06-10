/**
* Class to handle the update status of a Review Assignment record
* This class will be used on the ReviewAssignmentView page when the reviewer clicks Submit button.
* CHANGE HISTORY
* =============================================================================
* Date          Name            Description
* 05/30/2014    Kunal Shah      Created
* 11/14/2014    Nakul           Updated as per new Review panel changes
* =============================================================================
*/
global with sharing class ReviewAssignmentSubmitHelper extends GNT.DynamicLayoutActionRedirect {
    Boolean IsError = false;
    /*
        METHOD TO UPDATE THE STATUS ON THE REVIEW ASSIGNMENT
    */
    global override PageReference whenClicked() {
        system.debug('--Inside ReviewAssignmentSubmitHelper--');
        Id recordId = apexpages.currentpage().getparameters().get('id');
        System.debug('Current Record Id ================' + recordId);
        Review__c assign = [SELECT ID, Comments__c,BudgetPlannedCosts__c, Application__r.Announcement__r.Program__r.ProgramPathway__c, CompletionAttachment__c, Application__c, application__r.OneStepReviewComments__c,application__r.OneStepReviewCommentsNew__c, Status__c, RecommendationFundStatus__c, Compliant__c, Application__r.ExternalOrganization__c, ReviewStep__c, Application__r.Announcement__r.AwardFloor__c, PreApplication__c, SummaryScore__c, Acknowledgement__c,
                            AcceptanceStatus__c, PanelApplication__r.ReviewPanel__r.ReviewPackage__r.GNT__PageTemplateConfig__r.GNT__EditLayoutConfig__c, Agreement7__c,
                            PanelApplication__r.ReviewPanel__r.ExcludeFromScoring__c, ReviewPanel__r.ReviewStep__c, ReviewPanel__r.ReviewStep__r.StepNumber__c, EligibilityVerified__c,  EligibilityVerifiedComments__c,
                            RFCompleted__c, RFCompletedComments__c, ReqAttachmentUploaded__c, ReqAttachmentUploadedComments__c,  BudgetLimitNotExceeded__c, Application__r.SubstantiallyCompletedDate__c,
                            BudgetLimitNotExceededComments__c, ReviewPanel__r.ReviewStep__r.ReviewFormConfig__r.Name, SubmittedBy__c, ReviewDueDate__c, SubmittedOn__c, RecommendedBudget__c, RequestedBudget__c, ServiceAreaBudgetsProvided__c, ServiceAreaBudgetsProvidedComments__c,   BusinessDocumentsProvided__c,
                            BusinessDocumentProvidedComments__c, OneStepReviewCompletionStatus__c, Application__r.Announcement__r.Program__r.ReviewProcess__c, SubstantiallyCompletedDate__c, ElegibilityPreScreen__c, CompletionPreScreen__c, BudgetPreScreen__c, ScopePreScreen__c, ProgramReqPreScreen__c
                            FROM Review__c WHERE ID = : recordId];
        System.debug(assign.comments__c);
        Id RevStepId = assign.ReviewPanel__r.ReviewStep__c;
        ReviewStep__c revStep = [SELECT ID, Status__c, StepNumber__c FROM ReviewStep__c where id = :RevStepId];
        List<ReviewStepApplication__c> rsaList = [
                    SELECT Id, Name, Decision__c, ReviewerDecision__c, MinimumAwardAmount__c, MaximumAwardAmount__c, RecommendedAmount__c, OneStepReviewCompletionStatus__c
                    FROM ReviewStepApplication__c
                    WHERE Application__c = :assign.Application__c and ReviewStep__c = :assign.ReviewPanel__r.ReviewStep__c];
        ReviewStepApplication__c revStepApp = rsaList[0];

        system.debug('**Inside ReviewAssignmentSubmitHelper--assign--' + assign);

        try {
            if (assign.Application__r.Announcement__r.Program__r.ReviewProcess__c == 'One step review') {
                if (assign.ElegibilityPreScreen__c == null) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please answer questions in Eligibility section.'));
                    IsError = true;
                }
                if (assign.CompletionPreScreen__c == null && assign.CompletionAttachment__c == null) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please answer questions in Completion section.'));
                    IsError = true;
                }
                if (assign.BudgetPreScreen__c == null && assign.BudgetPlannedCosts__c == null) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please answer questions in Budget section.'));
                    IsError = true;
                }
                if (assign.ScopePreScreen__c == null) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please answer questions in Scope section.'));
                    IsError = true;
                }
                if (assign.Application__r.Announcement__r.Program__r.ProgramPathway__c == 'Fed-Competitive'){
                    if (assign.RecommendedBudget__c == null){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter the recommended amount.'));
                        IsError = true;
                    }
                }
                if (assign.ProgramReqPreScreen__c == null) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please answer questions in Program requirements section.'));
                    IsError = true;
                }
                if (revStepApp.OneStepReviewCompletionStatus__c != 'Pending') {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-76500')));
                    IsError = true;
                } else if (assign.OneStepReviewCompletionStatus__c == null) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Review Recommendation must be filed to submit the review'));
                    IsError = true;
                }
                if ((assign.SubstantiallyCompletedDate__c == null && assign.Application__r.SubstantiallyCompletedDate__c == null && assign.Application__r.Announcement__r.Program__r.ProgramPathway__c != 'Fed-Competitive') || (assign.SubstantiallyCompletedDate__c == null && assign.Application__r.Announcement__r.Program__r.ProgramPathway__c == 'Fed-Formula')) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Substantially Completed Date is required for submission'));
                    IsError = true;
                }
            } else {

                if (revStepApp.Decision__c != 'Pending') {
                    // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Review Form can not be submitted'));
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-76500')));
                    IsError = true;
                } else if (assign.EligibilityVerified__c == 'No' && (assign.EligibilityVerifiedComments__c == '' || assign.EligibilityVerifiedComments__c == null)) {
                    // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter Eligibility Comments'));
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-21109')));
                    IsError = true;
                } else if (assign.ServiceAreaBudgetsProvided__c == 'No' && (assign.ServiceAreaBudgetsProvided__c == '' || assign.ServiceAreaBudgetsProvidedComments__c == null)) {
                    // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter Service Area Budgets related Comments'));
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-17804')));
                    IsError = true;
                } else if (assign.ReqAttachmentUploaded__c == 'No' && (assign.ReqAttachmentUploaded__c == '' || assign.ReqAttachmentUploadedComments__c == null)) {
                    // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter Required Attachments related Comments'));
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-32543')));
                    IsError = true;
                } else if (assign.RFCompleted__c == 'No' && (assign.RFCompleted__c == '' || assign.RFCompletedComments__c == null)) {
                    // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter  Required Forms related Comments'));
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-72005')));
                    IsError = true;
                } else if (assign.BudgetLimitNotExceeded__c == 'No' && (assign.BudgetLimitNotExceeded__c == '' || assign.BudgetLimitNotExceededComments__c == null)) {
                    // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter Budget Limit related Comments'));
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-55057')));
                    IsError = true;
                } else if (assign.BusinessDocumentsProvided__c == 'No' && (assign.BusinessDocumentsProvided__c == '' || assign.BusinessDocumentProvidedComments__c == null)) {
                    // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter Business Documents related Comments'));
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-50418')));
                    IsError = true;
                }
                //else if( assign.ReviewPanel__r.ReviewStep__r.StepNumber__c>2 && assign.RecommendedBudget__c < assign.Application__r.Announcement__r.AwardFloor__c){
                //    // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Recommended Amount can not be less than Award Floor Amount'));
                //    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-32472')));
                //    IsError = true;
                //}
                else if ( assign.ReviewPanel__r.ReviewStep__r.StepNumber__c > 2 && assign.RecommendedBudget__c > assign.RequestedBudget__c) {
                    // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Recommended Amount can not be more than Requested Amount'));
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-33204')));
                    IsError = true;
                } else if ( assign.ReviewPanel__r.ReviewStep__r.StepNumber__c > 2 && assign.RecommendedBudget__c == null) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Recommended Amount is mandatory.'));
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-33204')));
                    IsError = true;
                } else if ( assign.ReviewPanel__r.ReviewStep__r.StepNumber__c == 3 && assign.RecommendationFundStatus__c == null) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Recommendation cannot be left empty.'));
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-33204')));
                    IsError = true;
                } else if (assign.Compliant__c == null && assign.ReviewPanel__r.ReviewStep__r.StepNumber__c == 1) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Recommendation is required'));
                    IsError = true;
                }
                if (assign.Agreement7__c == null && assign.ReviewPanel__r.ReviewStep__r.StepNumber__c == 2) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You must complete Acknowledgement before submitting the Review'));
                    IsError = true;
                }
            }


            if (isError == false) {
                if (assign.AcceptanceStatus__c == null) {
                    assign.AcceptanceStatus__c = 'Accepted';
                }
                assign.Status__c = 'Review Completed';
                assign.SubmittedOn__c = System.now();
                assign.SubmittedBy__c = UserInfo.getUserId();
                assign.OwnerId = UserInfo.getUserId();
                update assign;

                if (assign.Application__r.Announcement__r.Program__r.ReviewProcess__c == 'One step review') {
                    if (revStep.StepNumber__c == 1) { //For one step review's status
                        if (assign.OneStepReviewCompletionStatus__c == 'Application Incomplete') {
                            rsaList[0].OneStepReviewCompletionStatus__c = 'Incomplete';
                        } else if (assign.OneStepReviewCompletionStatus__c == 'Application Complete') {
                            rsaList[0].OneStepReviewCompletionStatus__c = 'Complete';
                        } else {
                            rsaList[0].OneStepReviewCompletionStatus__c = 'Rejected';
                        }
                    }
                    revStepApp.RecommendedAmount__c = assign.RecommendedBudget__c;
                    revStepApp.RecommendedFutureAmount__c = 0.00; //Dummy value for now
                } else {
                    if (revStep.StepNumber__c == 1) {
                        if (assign.Compliant__c == 'Compliant') {
                            rsaList[0].ReviewerDecision__c = 'Compliant';
                        } else {
                            rsaList[0].ReviewerDecision__c = 'Non Compliant';
                        }
                    } else if (revStep.StepNumber__c == 3) {
                        if (assign.Compliant__c == 'Recommended') {
                            rsaList[0].ReviewerDecision__c = 'Compliant';
                        } else {
                            rsaList[0].ReviewerDecision__c = 'Non Compliant';
                        }
                    }
                    // Invoking snapshot Api after Management Review Step
                    //SystemContextMethodsHelper SystemContextMethodsHelper = new SystemContextMethodsHelper();
                    //SystemContextMethodsHelper.createSnapshots(assign);
                    //GNT.SnapshotUtils.createSnapshot(assign.Id,assign.ReviewPanel__r.ReviewStep__r.ReviewFormConfig__r.Name,'',null,assign.Application__r.ExternalOrganization__c);
                    // Adding logic for updating min/max recommended amount
                    /*if(revStepApp.MinimumAwardAmount__c==null || revStepApp.MinimumAwardAmount__c==0.0){
                        revStepApp.MinimumAwardAmount__c=assign.RecommendedBudget__c;
                    }
                    else if(revStepApp.MinimumAwardAmount__c> assign.RecommendedBudget__c){
                        revStepApp.MinimumAwardAmount__c=assign.RecommendedBudget__c;
                    }
                    if(revStepApp.MaximumAwardAmount__c==null || revStepApp.MaximumAwardAmount__c==0.0){
                        revStepApp.MaximumAwardAmount__c=assign.RecommendedBudget__c;
                    }
                    else if(revStepApp.MaximumAwardAmount__c<assign.RecommendedBudget__c){
                        revStepApp.MaximumAwardAmount__c=assign.RecommendedBudget__c;
                    }*/
                    revStepApp.RecommendedAmount__c = assign.RecommendedBudget__c;
                    //revStepApp.RecommendedAmount__c = 1000;
                }
                update revStepApp;
                if (assign.Application__r.Announcement__r.Program__r.ReviewProcess__c == 'One step review') {
                    Application__c app = [SELECT Id, OneStepReviewCommentsNew__c, SubstantiallyCompletedDate__c FROM Application__c WHERE Id = :assign.Application__c];
                    app.OneStepReviewCommentsNew__c = assign.Comments__c;
                    System.debug('updating OneStepReviewComments__c');
                    System.debug('OneStepReviewComments__c' + app.OneStepReviewCommentsNew__c);
                    System.debug('reviewcomments' + assign.Comments__c);
                    if (app.SubstantiallyCompletedDate__c == null) {
                        app.SubstantiallyCompletedDate__c = assign.SubstantiallyCompletedDate__c;
                    }
                    ApplicationTriggerHelperUSBE.skipTrigger = true;
                    update app;
                    ApplicationTriggerHelperUSBE.skipTrigger = false;

                }

                if (isError == false) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Review decision submitted successfully.'));
                }
                PageReference pf = new PageReference('/apex/ReviewAssignmentView?id=' + recordId);
                //pf.getParameters().put('id', recordId);
                pf.setRedirect(true);
                return pf;
            } else {
                return null;
            }
        } catch (DMLException e) {
            system.debug('--Inside ReviewAssignmentSubmitHelper-error message---' + e);
            ApexPages.Message errorMsg1 = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
            ApexPages.addMessage(errorMsg1);
            return null;
        }

    }

    @TestVisible
    @future
    Public static void updateReviewStepScore(Id appId, Id reviewStepId, boolean isPreApplication, Decimal totalScore, Id reviewId) {
        String query = 'Select ';
        String reviewQuery = 'Select ';
        If(isPreApplication) {
            query += 'id,TotalScore__c from ReviewStepApplication__c where PreApplication__c =:appId and ReviewStep__c = :reviewStepId';
            reviewQuery += 'id,SummaryScore__c from Review__c where PreApplication__c =:appId and ReviewPanel__r.ReviewStep__c = :reviewStepId ' +
                           ' and Status__c = \'Review Completed\' and Id != : reviewId';
        } else {
            query += 'id,TotalScore__c from ReviewStepApplication__c where Application__c =:appId and ReviewStep__c = :reviewStepId';
            reviewQuery += 'id,SummaryScore__c from Review__c where Application__c =:appId and ReviewPanel__r.ReviewStep__c = :reviewStepId ' +
                           ' and Status__c = \'Review Completed\' and Id != : reviewId';
        }
        List<ReviewStepApplication__c> revStepApp = Database.query(query);
        if (revStepApp != null && revStepApp.size() > 0) {
            if (revStepApp[0].totalScore__c == null ) {
                revStepApp[0].totalScore__c = 0;
            }
            List<Review__c > reviews = Database.query(reviewQuery);
            for (Review__c review : reviews) {
                if (review.SummaryScore__c != null) {
                    revStepApp[0].totalScore__c += review.SummaryScore__c;
                }
            }
            revStepApp[0].totalScore__c += totalScore;
            if (reviews.size() != 0) {
                revStepApp[0].totalScore__c = revStepApp[0].totalScore__c / reviews.size();
            }
        }
        update revStepApp;
    }
    /*Get Field API names of PreApplication/Application whose value will act as scoring factor*/
    Public String getScoringFactorApiNames(List<GNT__PageBlockDetailConfig__c> pageDetail) {
        String fieldNames = '' ;
        for (GNT__PageBlockDetailConfig__c detail : pageDetail) {
            if (!String.isEmpty(detail.GNT__ScoringFactorFieldName__c)) {
                fieldNames += detail.GNT__ScoringFactorFieldName__c + ',';
            }
        }
        fieldNames = fieldNames.removeEnd(',');
        return fieldNames;
    }
}