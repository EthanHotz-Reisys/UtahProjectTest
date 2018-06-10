global with sharing class PromoteToFDMHelper extends GNT.FlexTableActionHandler {
    global override Map<String, Object> clickHandler() {
        Map<String, Object> resultMap = new Map<String, Object>();
        try {
            Id reviewStepId = urlParams.get('id');
            ReviewStep__c reviewStep = [SELECT Id, ReviewGroup__c, StepNumber__c, ReviewGroup__r.Announcement__r.Program__r.ReviewProcess__c, ReviewGroup__r.Announcement__r.Executive__c, FDMCreated__c FROM ReviewStep__c WHERE Id = :reviewStepId];
            //Checking if the logged in user is Grants Manager business role in Announcement.--> YST
            List<RolesAndResponsibilities__c> roles = [Select Id, Name__c, BusinessRole__c, Responsibility__c from RolesAndResponsibilities__c where Announcement__c = :reviewStep.ReviewGroup__r.Announcement__c AND Name__c != null];
            Set<Id> grantManagerIds = new Set<Id>();
            for (RolesAndResponsibilities__c role : roles) {
                if (role.BusinessRole__c == 'Grants Manager') {
                    grantManagerIds.add(role.Name__c);
                }
            }
            Id loggedInUser = UserInfo.getUserId();
            if (grantManagerIds.contains(loggedInUser)) {
                //YST

                ReviewStep__c nextReviewStep = [SELECT Id, Name, ExecutiveApprover__c, ReviewStepLayout__c FROM ReviewStep__c WHERE StepNumber__c > :reviewStep.StepNumber__c AND ReviewGroup__c = : reviewStep.ReviewGroup__c ORDER BY StepNumber__c LIMIT 1];
                List<ReviewStepApplication__c> rsaList = new List<ReviewStepApplication__c>([SELECT Id, Name, Application__c, Decision__c, TotalScore__c,
                        ApplicationRank__c, NumberOfReviews__c, MinimumAwardAmount__c, Application__r.Announcement__r.Program__r.ProgramPathway__c,
                        MaximumAwardAmount__c, RecommendedAmount__c, ReviewStep__c, Application__r.BudgetAllocation__c,
                        OneStepReviewCompletionStatus__c, Comments__c, PromotedToFDM__c
                        FROM ReviewStepApplication__c WHERE Id IN :selectedRecordIds]);

                List<ReviewStepApplication__c> fdmRsaList = new List<ReviewStepApplication__c>([SELECT Id, Application__c FROM ReviewStepApplication__c WHERE ReviewStep__c = :nextReviewStep.Id]);
                Set<Id> fdmAppIdSet = new Set<Id>();

                for (ReviewStepApplication__c rsa : fdmRsaList) {
                    fdmAppIdSet.add(rsa.Application__c);
                }

                if (rsaList.size() == 0) {
                    resultMap.put('Error', 'Select application that need to be promoted. The Applications can be promoted only once they are Approved');
                    return resultMap;
                }

                for (ReviewStepApplication__c rsa : rsaList) {
                    if (rsa.Decision__c == 'Pending') {
                        resultMap.put('Error', GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-11163'));
                        return resultMap;
                    }
                    if (fdmAppIdSet.contains(rsa.Application__c) || rsa.PromotedToFDM__c == true) {
                        resultMap.put('Error', 'One or several Applications are already in FDM');
                        return resultMap;
                    }
                    if (rsa.Decision__c == 'Rejected') {
                        resultMap.put('Error', 'One or several Applications are rejected, please remove them when promote');
                        return resultMap;
                    }
                }

                Id executiveApprover = reviewStep.ReviewGroup__r.Announcement__r.Executive__c;
                Id reviewGroupId = reviewStep.ReviewGroup__c;

                Set<Id> appIdSet = new Set<Id>();
                for (ReviewStepApplication__c rsa : rsaList) {
                    appIdSet.add(rsa.Application__c);
                }

                List<Review__c> lstReview = [SELECT Id, Application__c, OneStepReviewCompletionStatus__c, RecommendedBudget__c FROM Review__c WHERE ReviewPanel__r.ReviewStep__c = : reviewStepId AND Application__c IN :appIdSet ];
                Map<Id, Review__c> appIdReviewMap = new Map<Id, Review__c>();

                for (Review__c review : lstReview) {
                    appIdReviewMap.put(review.Application__c, review);
                }

                if (reviewStep.ReviewGroup__r.Announcement__r.Program__r.ReviewProcess__c == 'One step review') {
                    CreateFDMHelper cfh = new CreateFDMHelper();
                    cfh.updateOneStepReviewApplicationStatus(lstReview);
                    cfh.calculateRecommendedAmount(reviewStepId);

                    if (reviewStep.FDMCreated__c != 'Yes') {
                        GNT__PageTemplate__c pgTemplate = [SELECT Id, Name FROM GNT__PageTemplate__c WHERE GNT__DisplayName__c = 'FundingDecisionMemoTemplate' LIMIT 1];
                        nextReviewStep.Name = 'Funding Decision Memo';
                        nextReviewStep.ExecutiveApprover__c = executiveApprover;
                        nextReviewStep.ReviewStepLayout__c = pgTemplate.Id;
                        update nextReviewStep;

                        reviewStep.FDMCreated__c = 'Yes';
                        update reviewStep;

                        ReviewGroup__c reviewGroup = [SELECT Id, CurrentReviewStep__c, CurrentReviewStepId__c FROM ReviewGroup__c WHERE Id = :reviewGroupId ];
                        reviewGroup.CurrentReviewStep__c = nextReviewStep.Name;
                        reviewGroup.CurrentReviewStepId__c = nextReviewStep.Id;
                        update reviewGroup;
                    }
                    Set<String> pathways = new Set<String> {'Fed-Formula', 'State-Formula', 'Application 1/12th', 'Lump-Sum-App'};
                    List<ReviewStepApplication__c> newRsaList = new List<ReviewStepApplication__c>();
                    for (ReviewStepApplication__c rsa : rsaList) {
                        ReviewStepApplication__c newRsa = new ReviewStepApplication__c();
                        newRsa.Application__c = rsa.Application__c;
                        newRsa.ReviewStep__c = nextReviewStep.Id;
                        newRsa.ReviewStepName__c = 'Funding Decision Memo';
                        newRsa.Decision__c = rsa.Decision__c;
                        newRsa.TotalScore__c = rsa.TotalScore__c;
                        newRsa.NumberOfReviews__c = rsa.NumberOfReviews__c;
                        newRsa.ApplicationRank__c = rsa.ApplicationRank__c;
                        newRsa.DecidedBy__c = UserInfo.getUserId();
                        newRsa.DecidedOn__c = System.today();
                        newRsa.MinimumAwardAmount__c = rsa.MinimumAwardAmount__c;
                        newRsa.MaximumAwardAmount__c = rsa.MaximumAwardAmount__c;
                        newRsa.RecommendedAmount__c = rsa.RecommendedAmount__c;
                        newRsa.OneStepReviewCompletionStatus__c = rsa.OneStepReviewCompletionStatus__c;
                        newRsa.RecordTypeId = Schema.SobjectType.ReviewStepApplication__c.getRecordTypeInfosByName().get('Application').getRecordTypeId();
                        newRsa.Comments__c = rsa.Comments__c;
                        if (pathways.contains(rsa.Application__r.Announcement__r.Program__r.ProgramPathway__c)) {
                            newRsa.AmountThisAction__c = rsa.Application__r.BudgetAllocation__c;
                            newRsa.RecommendedAmount__c = rsa.Application__r.BudgetAllocation__c;
                        } else {
                            newRsa.RecommendedAmount__c = appIdReviewMap.get(rsa.Application__c).RecommendedBudget__c;
                        }
                        rsa.PromotedToFDM__c = true;
                        newRsaList.add(newRsa);
                    }

                    if (newRsaList.size() > 0) {
                        insert newRsaList;
                        update rsaList;
                    }
                    resultMap.put('Message', 'Successfully moved the application to FDM. ');
                } else {
                    resultMap.put('Error', 'Failed to move the application to FDM. Not in one step review');
                }
            } 
            else {
                resultMap.put('Error', 'Failed to move the application to FDM. You do not have enough privileges to promote the application.');
            }
        } 
        catch (Exception e) {
            resultMap.put('Message', e.getMessage());
        }
        resultMap.put('PageReference', null);
        return resultMap;
    }

}