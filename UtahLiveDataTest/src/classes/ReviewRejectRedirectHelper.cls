global with sharing class ReviewRejectRedirectHelper extends GNT.FlexTableActionHandler {

    global override Map<String, Object> clickHandler() {
        Map<String, Object> resultMap = new Map<String, Object>();
        String ns = AppUtils.getNamespacePrefix();
        Id reviewStepId = urlParams.get('id');
        System.debug('**reviewStepId**' + reviewStepId);
        String appTitle = '';
        Boolean completedRSA = false;
        List<ReviewStepApplication__c> selectedReviewStepApps = [SELECT Id, Decision__c, IsOGMPromoted__c, Application__r.Id , Application__r.Name
                FROM ReviewStepApplication__c
                WHERE Id IN :selectedRecordIds
                LIMIT 1];
        ReviewStep__c reviewStep = [Select Id, Name, OGMNotifiedOfRejections__c, NoofApplicationsPending__c, NoRemainingApps__c, StepNumber__c, ReviewGroup__c, LastStep__c, ReviewStepExpired__c,
                                    RecordType.Name, RecordType.DeveloperName
                                    from ReviewStep__c where Id = : reviewStepId];

        if (selectedRecordIds == null || selectedRecordIds.isEmpty()) {
            // resultMap.put('Message','Please select the Applications to Reject');
            resultMap.put('Message', GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-77606'));
            return resultMap;
        }
        if (selectedReviewStepApps.size() > 1 ) {
            //resultMap.put('Message','Please select only 1 application to be Rejected!');
            resultMap.put('Message', GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-73813'));
        }

        List<Review__c> revList = [Select Id, Name, ReviewStep__c, Application__c, Status__c from Review__c where ReviewStep__c = :reviewStepId and Status__c = 'Review Completed' and Recommendation__c IN('Recommended', 'Not Recommended')];
        List<ReviewStepApplication__c> rsaList = [Select Id, Name, application__c, ReviewStep__c from ReviewStepApplication__c where ReviewStep__c = :reviewStepId and Id IN :selectedRecordIds];

        for (Review__c rev : revList) {
            for (ReviewStepApplication__c rsa : rsaList) {
                if (rev.Application__c == rsa.Application__c)
                    completedRSA = true;
            }
        }

        if (!completedRSA) {
            //resultMap.put('Message','The selected application(s) must have been reviewed before deciding on approval status');
            resultMap.put('Message', GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-13063'));
            return resultMap;
        }

        if (reviewStep.OGMNotifiedOfRejections__c == false || selectedReviewStepApps[0].IsOGMPromoted__c == true) {
            if (selectedReviewStepApps.size() > 0) {
                ReviewStepApplication__c rsa = selectedReviewStepApps[0];
                if (rsa.Decision__c == 'Pending' || rsa.Decision__c == 'Approved') {
                    String PageReferenceURL = '/apex/' + ns + 'ReviewStepApplicationCommentsEdit?id=' + selectedReviewStepApps[0].Id + '&reviewStepId=' + reviewStep.Id;
                    resultMap.put('PageReference', PageReferenceURL);
                } else if (rsa.Decision__c == 'Rejected') {
                    String msg = 'This application is already Rejected';
                    resultMap.put('Message', msg);
                    return resultMap;
                }
            }
        } else if (reviewStep.OGMNotifiedOfRejections__c == true && selectedReviewStepApps[0].IsOGMPromoted__c == false) {
            //resultMap.put('Message','OGM has been notified already, you cannot modify the decisions now.');
            resultMap.put('Message', GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-10927'));
        }


        Set<Id> appIdList = new Set<Id>();
        Integer prevStep, nextStep;
        Integer currentStep = Integer.valueOf(reviewStep.StepNumber__c);
        if (currentStep != 1)
            prevStep = currentStep - 1;
        if (currentStep != 3)
            nextStep = currentStep + 1;
        ReviewStep__c prevRevStep, nextRevStep, mgmtStep;
        List<ReviewStep__c> prevReviewSteps = [SELECT Id, Name, Status__c, ReviewGroup__c FROM ReviewStep__c WHERE StepNumber__c = :prevStep AND ReviewGroup__c = :reviewStep.ReviewGroup__c Order by StepNumber__c LIMIT 1];
        List<ReviewStep__c> nextReviewSteps = [SELECT Id, Name, Status__c, ReviewGroup__c, NoofApplicationsPending__c FROM ReviewStep__c WHERE StepNumber__c = :nextStep AND ReviewGroup__c = :reviewStep.ReviewGroup__c ORDER BY StepNumber__c LIMIT 1];
        List<ReviewStep__c> mgmtReviewStep = [SELECT id, Name, Status__c, ReviewGroup__C, NoofApplicationsPending__c FROM ReviewStep__c WHERE StepNumber__c = 3 AND ReviewGroup__c = :reviewStep.ReviewGroup__c ORDER BY StepNumber__c LIMIT 1];

        if (nextReviewSteps.size() > 0)
            nextRevStep = nextReviewSteps.get(0);
        if (prevReviewSteps.size() > 0)
            prevRevStep = prevReviewSteps.get(0);
        if (mgmtReviewStep.size() > 0)
            mgmtStep = mgmtReviewStep.get(0);

        List<ReviewStepApplication__c> lstPromotedApps = new List<ReviewStepApplication__c>();
        if (selectedReviewStepApps != null) {
            for (ReviewStepApplication__c app : selectedReviewStepApps) {
                if (app.Decision__c != 'Rejected') {
                    system.debug('appPromoted: ' + app);

                    appIdList.add(app.Application__r.Id);
                    app.Status__c = 'Rejected';
                    app.Decision__c = 'Rejected';
                    app.ReviewStepAppFinalDecision__c = True;
                    app.DecidedOn__c = System.now();
                    app.DecidedBy__c = UserInfo.getUserId();
                    if (reviewStep.RecordType.Name == 'Application') {
                        appTitle = app.Application__r.Name;
                    } else {
                        appTitle = app.PreApplication__r.Name;
                    }

                }
                lstPromotedApps.add(app);

            }
        }

        if (lstPromotedApps.size() > 0) {
            upsert lstPromotedApps;
            ReviewStep__c reviewsStep = [Select Id, Name, OGMNotifiedOfRejections__c, NoofApplicationsPending__c, NoRemainingApps__c, StepNumber__c, ReviewGroup__c, LastStep__c, ReviewStepExpired__c,
                                         RecordType.Name, RecordType.DeveloperName
                                         from ReviewStep__c where Id = : reviewStepId];
            if (reviewStep.StepNumber__c == 1 && reviewsStep.NoRemainingApps__c == 0) {
                reviewStep.Status__c = 'Completed';
                update reviewStep;
                if (nextRevStep != null && nextRevStep.NoofApplicationsPending__c == 0) {
                    nextRevStep.Status__c = 'Completed';
                    update nextRevStep;
                }
                if (mgmtStep != null && mgmtStep.NoofApplicationsPending__c == 0) {
                    mgmtStep.Status__c = 'Completed';
                    update mgmtStep;
                }
            } else if (reviewStep.StepNumber__c == 2  && reviewsStep.NoRemainingApps__c == 0 && prevRevStep.Status__c == 'Completed') {
                reviewStep.Status__c = 'Completed';
                update reviewStep;
                if (nextRevStep.NoofApplicationsPending__c == 0) {
                    nextRevStep.Status__c = 'Completed';
                    update nextRevStep;
                }
            }

            else if (reviewStep.StepNumber__c == 3 && reviewsStep.NoofApplicationsPending__c == 0 && prevRevStep.Status__c == 'Completed') {
                reviewStep.Status__c = 'Completed';
                update reviewStep;
            }

            List<Application__c> appList = [Select Id, LastReviewDecision__c, LastReviewStep__c from Application__c where Id IN :appIdList];
            List<Application__c> newList = new List<Application__c>();
            for (Application__c app : appList) {
                app.LastReviewDecision__c = 'Rejected';
                app.LastReviewStep__c = reviewStep.Name;
                newList.add(app);
            }
            if (newList.size() > 0)
                update appList;

            //resultMap.put('Message','Application Rejected Successfully!');
            resultMap.put('Message', GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-86006'));

        }

        return resultMap;
    }
}