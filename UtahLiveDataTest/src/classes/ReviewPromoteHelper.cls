global with sharing class ReviewPromoteHelper extends GNT.FlexTableActionHandler {
    private Map<String, Object> resultMap;
    global override Map<String, Object> clickHandler() {
        resultMap = new Map<String, Object>();
        String ns = AppUtils.getNamespacePrefix();
        Id reviewStepId = urlParams.get('id');
        String action = urlParams.get('action');
        Boolean allowOGMPromotion = false;
        Boolean allowPMPromotion = true;
        Boolean ogmPromotedRSA = false;
        Boolean completedRSA = false;

        if (selectedRecordIds == null || selectedRecordIds.isEmpty()) {
            // resultMap.put('Message','Please select the Applications to Approve');
            resultMap.put('Message', GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-15062'));
            return resultMap;
        }
        System.debug('reviewStepId**' + reviewStepId);
        System.debug('selectedRecordIds**' + selectedRecordIds);

        // GET THE CURRENT REVIEW STEP
        ReviewStep__c reviewStep = [Select Id, Name, OGMNotifiedOfRejections__c, NoofApplicationsPending__c, StepNumber__c, ReviewGroup__c, LastStep__c, ReviewStepExpired__c, ProgramPathway__c,
                                    RecordType.Name, Status__c, RecordType.DeveloperName, ReviewGroup__r.Announcement__r.AnnouncementType__c, ReviewGroup__r.Announcement__r.Program__r.ReviewProcess__c
                                    from ReviewStep__c where Id = : reviewStepId];

        //Commented By Sai Teja 09/29/2017
        /*if(reviewStep.Status__c !='In Progress') {
            //resultMap.put('Message','Applications can not be approved/promoted to Next Review Step');
             resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-60671'));
            return resultMap;
        } */

        //List<Review__c> revList = [Select Id, Name, ReviewStep__c,Application__c,Status__c from Review__c where ReviewStep__c=:reviewStepId and Status__c='Review Completed' and Recommendation__c NOT IN('Recommended','Not Recommended')];
        List<ReviewStepApplication__c> rsaList = [Select Id, Name, application__c, ReviewerDecision__c, ReviewStep__c, OneStepReviewCompletionStatus__c, PromotedToFDM__c from ReviewStepApplication__c where ReviewStep__c = :reviewStepId and Id IN :selectedRecordIds];
        Set<Id> appList1 = new Set<Id>();
        Set<Id> appList2 = new Set<Id>();
        /*for(Review__c rev : revList){
            appList1.add(rev.Application__c);
        }*/
        System.debug('rsaList--------------------->' + rsaList);
        for (ReviewStepApplication__c rsa : rsaList) {
            if (reviewStep.Name == 'Pre-Screen Review' || reviewStep.Name == 'Management Review') {
                if (reviewStep.ReviewGroup__r.Announcement__r.Program__r.ReviewProcess__c != null && reviewStep.ReviewGroup__r.Announcement__r.Program__r.ReviewProcess__c == 'One step review') {
                    if (rsa.OneStepReviewCompletionStatus__c == null || rsa.OneStepReviewCompletionStatus__c == '' || rsa.OneStepReviewCompletionStatus__c == 'Pending') {
                        resultMap.put('Message', 'Cannot approve Review Pending applications.');
                        return resultMap;
                    }
                    else if (rsa.PromotedToFDM__c == true) { //Cannot approve an application that is already in FDM state
                        resultMap.put('Message', 'Cannot approve applications that have already been promoted to FDM');
                        return resultMap;
                    }
                } else if (rsa.ReviewerDecision__c == 'Non Compliant' || rsa.ReviewerDecision__c == '' || rsa.ReviewerDecision__c == null) {
                    resultMap.put('Message', 'Cannot approve Non-Compliant or Review Pending applications.');
                    return resultMap;
                }
            }
            appList2.add(rsa.Application__c);
        }
        System.debug('*appList2*' + appList2);
        //List<Review__c> revList1 = [Select Id, Name, ReviewStep__c,Application__c,Status__c from Review__c where ReviewStep__c=:reviewStepId and Status__c='Review Completed' and Application__c IN :appList2 ];
        //System.debug('*revList1*'+revList1);

        List<Application__c> apps = [Select Id, (Select Id, Application__c from Reviews__r where ReviewStep__c = :reviewStepId and Status__c = 'Review Completed') from Application__c where Id IN :appList2];
        System.debug('apps--------------------->' + apps);
        for (Application__c app : apps) {
            if (app.Reviews__r.size() == 0) {
                //resultMap.put('Message','The selected application(s) must have been reviewed before deciding on approval status');
                resultMap.put('Message', GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-13063'));
                return resultMap;
            }
        }

        //AggregateResult[] aggs = [Select COUNT(Id) num, Application__c from Review__c where ReviewStep__c=:reviewStepId and Status__c='Review Completed' and Application__c IN :appList2 Group By Application__c];

        //for(AggregateResult agg : aggs){
        //    if(agg.get('num') == 0){
        //        //resultMap.put('Message','The selected application(s) must have been reviewed before deciding on approval status');
        //        resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-13063'));
        //        return resultMap;
        //    }
        //}

        //if(revList1!=null && revList1.size()<1){
        //     //resultMap.put('Message','The selected application(s) must have been reviewed before deciding on approval status');
        //     resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-13063'));
        //    return resultMap;
        //}

        if (reviewStep.OGMNotifiedOfRejections__c == true) {
            List<ReviewStepApplication__c> selectedReviewStepApps = [SELECT Id, Name, ReviewStep__c, IsOGMPromoted__c, Decision__c
                    FROM ReviewStepApplication__c
                    WHERE Id IN :selectedRecordIds
                    LIMIT :GNT.AppUtils.SOQL_LIMIT];
            if (selectedReviewStepApps.size() > 0) {
                if (selectedReviewStepApps[0].IsOGMPromoted__c == true) {
                    ogmPromotedRSA = true;
                }
            }
            List<GroupMember> groupMemberList = [SELECT GroupId, Id, UserOrGroupId FROM GroupMember where Group.DeveloperName = 'OGM' and Group.Type = 'Queue'];
            for (GroupMember groupMemberUser : groupMemberList) {
                system.debug(groupMemberUser.UserOrGroupId + ' ---- ' + UserInfo.getUserId());
                if (groupMemberUser.UserOrGroupId == UserInfo.getUserId()) {
                    allowOGMPromotion = true;
                }
            }

        }
        if (allowPMPromotion == true) {
            Id targetObjectId ;
            Map<Id, Id> appOwnerIdToAppIdMap = new Map<Id, Id>();
            Id nextReviewStepId;
            Integer currentStep = Integer.valueOf(reviewStep.StepNumber__c);
            Integer nextStep, prevStep ;
            ReviewStep__c prevRevStep;
            // Sole Source applications - skip External review step
            if (currentStep == 1 && !String.isEmpty(reviewStep.ReviewGroup__r.Announcement__r.AnnouncementType__c ) && String.valueOf(reviewStep.ReviewGroup__r.Announcement__r.AnnouncementType__c).equalsIgnoreCase('sole source/directed')) {
                nextStep = currentStep + 2;
            } else {
                nextStep = currentStep + 1;
                if (currentStep != 1)
                    prevStep = currentStep - 1;
            }
            try {
                List<ReviewStep__c> nextReviewSteps = [SELECT Id, Name, ReviewGroup__c FROM ReviewStep__c
                                                       WHERE StepNumber__c >= : nextStep
                                                       AND ReviewGroup__c = : reviewStep.ReviewGroup__c
                                                               Order by StepNumber__c LIMIT 1 ];
                List<ReviewStep__c> prevReviewSteps = [SELECT Id, Name, Status__c, ReviewGroup__c FROM ReviewStep__c WHERE StepNumber__c = :prevStep AND ReviewGroup__c = :reviewStep.ReviewGroup__c Order by StepNumber__c LIMIT 1];
                if (prevReviewSteps.size() > 0)
                    prevRevStep = prevReviewSteps.get(0);
                List<ReviewStepApplication__c> selectedReviewStepApps = [SELECT Id, Name, ReviewStep__c, RecordType.Name, Decision__c, DecidedOn__c,
                                               application__r.Id, Application__r.Name,
                                               Status__c, Application__r.Announcement__r.Owner.Email, PreApplication__c, PreApplication__r.Announcement__r.Owner.Email, PreApplication__r.Name
                                               FROM ReviewStepApplication__c
                                               WHERE Id IN :selectedRecordIds AND Decision__c != 'Approved'
                                               LIMIT :GNT.AppUtils.SOQL_LIMIT]; // AND Status__c = 'Promoted'
                //CHECK IF THE NEXT STEP EXISTS
                if (nextReviewSteps.size() > 0) {

                    Id reviewApplications;
                    nextReviewStepId = nextReviewSteps.get(0).Id;
                    //GET THE CURRENTLY SELECTED REVIEW STEP APPLICATIONS

                    String appTitle = '';
                    Set<Id> appIdList = new Set<Id>();
                    List<ReviewStepApplication__c> lstPromotedApps = new List<ReviewStepApplication__c>();
                    List<ReviewStepApplication__c> lstPromApps = new List<ReviewStepApplication__c>();
                    Map<Id, String[]> recIdToAddressMap = new Map<Id, String[]> ();
                    if (nextReviewStepId != null && selectedReviewStepApps != null) {
                        for (ReviewStepApplication__c app : selectedReviewStepApps) {
                            if (app.Decision__c != 'Approved') {
                                if (allowOGMPromotion == true) {
                                    ReviewStepApplication__c promotedApp = new ReviewStepApplication__c();
                                    String[] toAddresses = new String[] {};
                                    if (reviewStep.RecordType.Name == 'Application') {
                                        promotedApp.Application__c = app.Application__c;
                                        promotedApp.RecordTypeId = Schema.SobjectType.ReviewStepApplication__c.getRecordTypeInfosByName().get('Application').getRecordTypeId();
                                        promotedApp.IsOGMPromoted__c = true;
                                        toAddresses.add(app.Application__r.Announcement__r.Owner.Email);
                                    } else {
                                        promotedApp.PreApplication__c = app.PreApplication__c;
                                        promotedApp.RecordTypeId = Schema.SobjectType.ReviewStepApplication__c.getRecordTypeInfosByName().get('Pre-Application').getRecordTypeId();
                                        toAddresses.add(app.PreApplication__r.Announcement__r.Owner.Email);
                                    }
                                    promotedApp.ReviewStep__c = nextReviewStepId;
                                    lstPromotedApps.add(promotedApp);
                                    recIdToAddressMap.put(app.Id, toAddresses);
                                }
                                app.Status__c = 'Approved';
                                app.Decision__c = 'Approved';
                                appIdList.add(app.Application__r.Id);
                                app.DecidedOn__c = System.now();
                                app.DecidedBy__c = UserInfo.getUserId();
                                if (reviewStep.RecordType.Name == 'Application') {
                                    appTitle = app.Application__r.Name;
                                } else {
                                    appTitle = app.PreApplication__r.Name;
                                }
                            }
                            lstPromotedApps.add(app);
                            lstPromApps.add(app);
                        }
                    }
                    // update old RSA to Promoted and create new RSA for next Review Step
                    Set<String> pathways = new Set<String>{'Fed-Formula', 'State-Formula', 'Application 1/12th', 'Lump-Sum-App', 'Fed-Competitive'};
                    if (lstPromotedApps.size() > 0) {
                        upsert lstPromotedApps;
                        ReviewStep__c reviewsStep = [Select Id, Name, OGMNotifiedOfRejections__c, NoofApplicationsPending__c, StepNumber__c, ReviewGroup__c, LastStep__c, ReviewStepExpired__c,
                                                     RecordType.Name, Status__c, RecordType.DeveloperName, ReviewGroup__r.Announcement__r.AnnouncementType__c
                                                     from ReviewStep__c where Id = : reviewStepId];

                        if (reviewStep.StepNumber__c == 3 && reviewsStep.NoofApplicationsPending__c == 0 && prevRevStep.Status__c == 'Completed') {
                            reviewStep.Status__c = 'Completed';
                            update reviewStep;
                        } else if (!pathways.contains(reviewStep.ProgramPathway__c) && reviewStep.ReviewGroup__r.Announcement__r.Program__r.ReviewProcess__c == 'One step review' && reviewsStep.NoofApplicationsPending__c == 0) {
                            reviewStep.Status__c = 'Completed';
                            update reviewStep;
                        }
                        List<Application__c> appList = [Select Id, LastReviewDecision__c, LastReviewStep__c from Application__c where Id IN :appIdList];
                        List<Application__c> newList = new List<Application__c>();
                        for (Application__c app : appList) {
                            app.LastReviewDecision__c = 'Approved';
                            app.LastReviewStep__c = reviewStep.Name;
                            newList.add(app);
                        }
                        if (newList.size() > 0)
                            update appList;
                        List<EmailTemplate> emailTemplate = [Select id From EmailTemplate Where DeveloperName = 'NotifyPMOnOGMPromotionOfRejectedApps' Limit 1];
                        Contact cont = [select id, Email from Contact where email <> null limit 1];
                        //AppUtils.sendEmailUsingTemplate(emailTemplate[0].Id, recIdToAddressMap, cont.Id, false);
                        if (reviewStep.RecordType.Name == 'Application') {
                            if (selectedRecordIds.size() > 0) {
                                //  PageReference p = Page.ReviewStepView;
                                //  p.getParameters().put('id', reviewStepId);
                                // p.setRedirect(true);
                                //resultMap.put('PageReference',p);
                                // resultMap.put('Message', 'Selected Applications Approved Successfully!');
                                resultMap.put('Message', GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-45310'));
                                return resultMap;
                            } else  {
                                PageReference p = Page.ReviewStepView;
                                p.getParameters().put('id', reviewStepId);
                                p.setRedirect(true);
                                resultMap.put('PageReference', p);
                                resultMap.put('Message', 'Application ' + appTitle + ' Approved Successfully!');
                                return resultMap;
                            }
                        } else {
                            resultMap.put('Message', 'Pre-Application ' + appTitle + ' Approved Successfully!');
                        }
                    } else if (lstPromotedApps.size() == 0) {
                        // resultMap.put('Message','Applications are already in approved state');
                        resultMap.put('Message', GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-56188'));
                    } else {
                        if (reviewStep.RecordType.Name == 'Application') {
                            //resultMap.put('Message','This application is already approved!');
                            resultMap.put('Message', GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-26090'));
                        } else {
                            //resultMap.put('Message','This pre-application is already approved!');
                            resultMap.put('Message', GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-17917'));
                        }
                        return resultMap;
                    }
                } else if (reviewStep.LastStep__c) { //ELSE CHECK IF THE CURRENTSTEP IS THE LAST STEP IN THE REVIEW GROUP
                    //resultMap.put('Message','This is the last step in the group. You cannot create more steps.');
                    resultMap.put('Message', GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-70436'));
                }
            } catch (DMLException e) {
                resultMap.put('Message', 'Error : ' + e.getMessage());
                return resultMap;
            }
        }
        return resultMap;
    }
}