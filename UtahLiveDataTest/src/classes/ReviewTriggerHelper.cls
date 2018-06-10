/*
    Trigger Helper class for Review Object
    ***********************************************************
    Audit History
    ***********************************************************
    11/12/2014      Nakul         Created
    ***********************************************************
*/
public without sharing class ReviewTriggerHelper extends GNT.TriggerHelper {
    public static Boolean skipFuture = false;
    public static Boolean skipTrigger = false;
    public override void processBeforeInsert() {
        if (!skipTrigger) {
            GNT.NameTemplateTriggerHelper.beforeInsert();
            updateOwner();
            updateCompliantInSME(Trigger.new);
            updateCompliantInManagementRev(Trigger.new);
            copyFieldValues();
            updateRecommendedAmountFourPathway((List<Review__c>)Trigger.new);
            initializeReviewComments(Trigger.new);
            
        }
    }
    public override void processAfterInsert() {
        if (!skipTrigger) {
            if (skipFuture == false) {
                shareReviewGroupWithReviewer(trigger.newMap.keySet());
                updateReviewStatusHTML(trigger.newMap.keySet(), false, false);
            }
            createTasksforReviewers();
            //sendEmailstoReviewers(Trigger.new);
            UpdateNoofReviews(Trigger.new);
            grantAccesstoPM();
            updateNoOfApplicationsPerReviewer(trigger.new);
            insertTableItem(Trigger.new);
        }
    }
    public override void processBeforeUpdate() {
        if (!skipTrigger) {
            Map<Id, String> oldReviewsStatusChanged = new Map<Id, String>();
            Set<Id> newReviews = new Set<Id>();
            for (Review__c review : (Review__c[])trigger.new) {
                Review__c oldReview = (Review__c)Trigger.oldMap.get(review.Id);
                oldReviewsStatusChanged.put(oldReview.Id, oldReview.Status__c);
                newReviews.add(review.Id);
            }
            updateOneStepComments(Trigger.New);
            updateCompliantInSME(Trigger.new);
            updateCompliantInManagementRev(Trigger.new);
            changeToInProgress();
            calculateScoreForCompletedReviews();
            closeTasks();
            updateRecommendedAmountFourPathway((List<Review__c>)Trigger.new);
        }
    }
    public override void processAfterUpdate() {
        if (!skipTrigger) {
            if (skipFuture == false) {
                updateReviewStatusHTML(trigger.newMap.keySet(), false, true);
            }
            calculateReviewStepScore();
            UpdateNoofReviews(Trigger.new);
            copyManagementComments(Trigger.new);
            //updateCorrectionsChangeReq(Trigger.new);
            //updateOverallCommentsChangeReq(Trigger.new);
            //UpdateSuggestionsChangeReq(Trigger.new);
            //UpdateQuestions(Trigger.new);
        }
    }
    public override void processBeforeDelete() {
        if (!skipTrigger) {
            updateReviewStatusHTML(trigger.oldMap.keySet(), true, false);
            updateApplicationsReviewersCount(trigger.oldMap.keySet());
        }
    }
    /*
        In case manual review assignment -- Set the owner of the review record = panel user
        In case of Auto Assignment -- the owner of the review record is set to group id in PanelApplicationTriggerHelper, no need to handle it here
    */

    private void updateCompliantInSME(List<Review__c> revList) {
        for (Review__c rev : revList) {
            if (rev.ReviewStepNameFormula__c == 'SME Review' && rev.Recommendation__c == 'Recommended' && rev.Compliant__c != 'Review Declined') {
                rev.Compliant__c = 'Recommended';
            } else if (rev.ReviewStepNameFormula__c == 'SME Review' && rev.Recommendation__c == 'Not Recommended' && rev.Compliant__c != 'Review Declined') {
                rev.Compliant__c = 'Non-Recommended';
            } else if (rev.ReviewStepNameFormula__c == 'SME Review' && rev.Recommendation__c == null && rev.Compliant__c != 'Review Declined') {
                rev.Compliant__c = null;
            }
        }
    }

    private void updateCompliantInManagementRev(List<Review__c> revLst) {
        for (Review__c rev : revLst) {
            if (rev.ReviewStepNameFormula__c == 'Management Review' && (rev.RecommendationFundStatus__c == 'Fund' || rev.RecommendationFundStatus__c == 'Fund If' ) && rev.Compliant__c != 'Review Declined') {
                rev.Compliant__c = 'Recommended';
            } else if (rev.ReviewStepNameFormula__c == 'Management Review' && rev.RecommendationFundStatus__c == 'No Fund' && rev.Compliant__c != 'Review Declined') {
                rev.Compliant__c = 'Non-Recommended';
            } else if (rev.ReviewStepNameFormula__c == 'Management Review' && rev.RecommendationFundStatus__c == null && rev.Compliant__c != 'Review Declined') {
                rev.Compliant__c = null;
            }
        }
    }

    private void updateOwner() {
        List<Id> panelUserId = new List<Id>();
        for (Review__c review : (List<Review__c>) trigger.new) {
            if (review.PanelUser__c != null) {
                panelUserId.add(review.PanelUser__c);
            }
        }

        Map<Id, PanelUser__c> panelUserMap = new Map<id, PanelUser__c>([Select Id, Reviewer__c FRom PanelUser__c Where Id IN : panelUserId]);

        for (Review__c review : (List<Review__c>) trigger.new) {
            Id ownerId = review.ownerId;
            if (ownerId.getSobjectType() == Schema.SobjectType.User.getSobjectType()) {
                if (panelUserMap.size() > 0) {
                    review.OwnerId = panelUserMap.get(review.PanelUser__c).Reviewer__c;
                }
            } else {
                review.Status__c = 'Sent for Review';
            }
        }
    }

    private void insertTableItem(List<Review__c> reviews) {
        System.debug('Enter Insert table item');
        List<Review__c> SMEReviews = new List<Review__c>();
        for (Review__c r : reviews) {
            if (r.ReviewStepName__c == 'SME Review') {
                SMEReviews.add(r);
            }
        }
        System.debug('Enter Insert table item' + SMEReviews.size());
        if (SMEReviews.size() == 0) {
            return;
        }

        List<String> nameList = new List<String>();
        nameList.add('Can you identify the Project Focus/Purpose of the Grant?;10;ProgramPurpose');
        //--------------------------------------------
        nameList.add('VOCA info provided & realistic?;5;RequiredVOCAInformation');
        nameList.add('Do the projections merit the request?;5;RequiredVOCAInformation');
        //--------------------------------------------
        nameList.add('VOCA info provided & realistic?;5;SpecialRequiredVOCAInformation');
        nameList.add('Do the projections merit the request?;5;SpecialRequiredVOCAInformation');
        //--------------------------------------------
        nameList.add('VOCA info provided & realistic?;5;RequiredVOCAInformationOngoing');
        nameList.add('Do the projections merit the increase?;5;RequiredVOCAInformationOngoing');
        //--------------------------------------------
        nameList.add('Answered with realistic projections?;5;RequiredVAWAInformation');
        nameList.add('Are the responses carried through to the goals and objectives?;5;RequiredVAWAInformation');
        //---------------------------------------------
        nameList.add('Is budget reasonable & efficient?;3;BudgetMatch');
        nameList.add('Are volunteers used / hourly rate reasonable?;2;BudgetMatch');
        //---------------------------------------------
        nameList.add('Is budget/match reasonable & efficient?;10;VocaBudgetMatch');
        nameList.add('Are volunteers used / hourly rate reasonable?;1;VocaBudgetMatch');
        nameList.add('Are the costs allowable under VOCA guidelines?;4;VocaBudgetMatch');
        //---------------------------------------------
        nameList.add('Is budget/match reasonable & efficient?;5;VocaBudgetMatchSpecial');
        nameList.add('Are volunteers used / hourly rate reasonable?;1;VocaBudgetMatchSpecial');
        nameList.add('Are the costs allowable under VOCA guidelines?;4;VocaBudgetMatchSpecial');
        nameList.add('Are there explanations for each budget category;5;VocaBudgetMatchSpecial');
        //---------------------------------------------
        nameList.add('Is budget/match reasonable & efficient?;10;VocaBudgetMatchOngoing');
        nameList.add('Are the costs allowable under VOCA guidelines?;5;VocaBudgetMatchOngoing');
        //-----------------------------------------------
        nameList.add('Were any and all supplanting concerns sufficiently addressed?;2;ProgramComparison');
        nameList.add('VOCA/SASP funded personnel listed?;1;ProgramComparison');
        nameList.add('Additional resources listed?;1;ProgramComparison');
        nameList.add('Is a current fiscal budget submitted?;1;ProgramComparison');
        //----------------------------------------------
        nameList.add('Were any and all supplanting concerns sufficiently addressed?;2;VocaProgramComparison');
        nameList.add('Equipment summary completed/signed?;1;VocaProgramComparison');
        nameList.add('Additional resources listed?;1;VocaProgramComparison');
        nameList.add('Is a current fiscal budget submitted?;1;VocaProgramComparison');
        //----------------------------------------------
        nameList.add('Equipment summary completed/signed?;2;VocaProgramComparisonSpecial');
        nameList.add('Additional resources listed?;2;VocaProgramComparisonSpecial');
        nameList.add('Is a current fiscal budget submitted?;1;VocaProgramComparisonSpecial');
        //----------------------------------------------
        nameList.add('Were any and all supplanting concerns sufficiently addressed?;10;VocaProgramComparisonOngoing');
        //----------------------------------------------
        nameList.add('Present an overall description of problem – clearly paint picture of problem?;5;StatementOfProblem');
        nameList.add('Geographical area described?;2;StatementOfProblem');
        nameList.add('Nature & scope of problem in their service area – NOT agency problem?;3;StatementOfProblem');
        nameList.add('Victim needs in the area – NOT agency needs?;3;StatementOfProblem');
        nameList.add('Statement of problem supported by current stats & info?;3;StatementOfProblem');
        nameList.add('Targeted population identified?;2;StatementOfProblem');
        nameList.add('Detailed plan to address problem described?;2;StatementOfProblem');
        //----------------------------------------------
        nameList.add('Present an overall description of problem – clearly paint picture of problem?;5;VocaStatementOfProblem');
        nameList.add('Geographical area described?;3;VocaStatementOfProblem');
        nameList.add('Nature & scope of problem in their service area – NOT agency problem?;3;VocaStatementOfProblem');
        nameList.add('Victim needs in the area – NOT agency needs?;3;VocaStatementOfProblem');
        nameList.add('Statement of problem supported by current stats & info?;3;VocaStatementOfProblem');
        nameList.add('Targeted population identified?;3;VocaStatementOfProblem');
        //----------------------------------------------
        nameList.add('Present an overall description of problem – clearly paint picture of problem?;5;VocaStatementOfProblemSpecial');
        nameList.add('Geographical area described?;3;VocaStatementOfProblemSpecial');
        nameList.add('Nature & scope of problem in their service area – NOT agency problem?;3;VocaStatementOfProblemSpecial');
        nameList.add('Victim needs in the area – NOT agency needs?;3;VocaStatementOfProblemSpecial');
        nameList.add('Statement of problem supported by current stats & info?;3;VocaStatementOfProblemSpecial');
        nameList.add('Targeted population identified?;3;VocaStatementOfProblemSpecial');
        //-----------------------------------------------
        nameList.add('Has the applicant clearly presented a need that merits the increase?;10;VocaStatementOfProblemOngoing');
        nameList.add('Does the need fall under the priority areas that were listed in the RFP?;10;VocaStatementOfProblemOngoing');
        //-----------------------------------------------
        nameList.add('Are goals understandable / do they address the needs identified in the Statement of Problem/Need?;5;ProgramPlan');
        nameList.add('Do the objectives help meet the identified goals?;2;ProgramPlan');
        nameList.add('Are goals and objectives measurable? Are objectives realistic & attainable?;2;ProgramPlan');
        nameList.add('Are the quantitative numbers included – is it clear what the numbers measure?;2;ProgramPlan');
        nameList.add('Are the activities really activities?;2;ProgramPlan');
        nameList.add('Does the monitor section monitor and evaluation?;2;ProgramPlan');
        nameList.add('Is the time line realistic?;2;ProgramPlan');
        nameList.add('Has the collaboration project been identified, collaborative partners and roles identified?;8;ProgramPlan');
        nameList.add('3 collaboration letters attached, dated, signed, on letterhead?;3;ProgramPlan');
        nameList.add('Has the system or target population for the project been identified?;2;ProgramPlan');
        //-----------------------------------------------
        nameList.add('Are goals understandable / do they address the needs identified?;5;VocaProgramPlan');
        nameList.add('Do the objectives help meet the identified goals?;2;VocaProgramPlan');
        nameList.add('Are goals and objectives measurable? Are objectives realistic & attainable?;2;VocaProgramPlan');
        nameList.add('Are the quantitative numbers included – is it clear what the numbers measure?;2;VocaProgramPlan');
        nameList.add('Are the activities really activities?;2;VocaProgramPlan');
        nameList.add('Does the monitor section monitor and evaluation?;2;VocaProgramPlan');
        nameList.add('Is the time line realistic?;2;VocaProgramPlan');
        nameList.add('Are there enough goals and objectives to effectively implement the grant funded project? Is it well thought-out? Is it cost effective?;8;VocaProgramPlan');
        //--------------------------------------------------
        nameList.add('Are goals understandable / do they address the needs identified?;5;VocaProgramPlanSpecial');
        nameList.add('Do the objectives help meet the identified goals?;2;VocaProgramPlanSpecial');
        nameList.add('Are goals and objectives measurable? Are objectives realistic & attainable?;2;VocaProgramPlanSpecial');
        nameList.add('Are the quantitative numbers included – is it clear what the numbers measure?;2;VocaProgramPlanSpecial');
        nameList.add('Are the activities really activities?;2;VocaProgramPlanSpecial');
        nameList.add('Does the monitor section monitor and evaluation?;2;VocaProgramPlanSpecial');
        nameList.add('Is the time line realistic?;2;VocaProgramPlanSpecial');
        nameList.add('Are there enough goals and objectives to effectively implement the grant funded project? Is it well thought-out? Is it cost effective?;8;VocaProgramPlanSpecial');
        //--------------------------------------------------
        nameList.add('Are goals understandable / do they address the needs identified?;10;VocaProgramPlanOngoing');
        nameList.add('Do the objectives help meet the identified goals?;3;VocaProgramPlanOngoing');
        nameList.add('Are goals and objectives measurable?;2;VocaProgramPlanOngoing');
        nameList.add('Do the additional goals/objectives merit the amount of the increase? Is it well thought-out? Is it cost effective?;10;VocaProgramPlanOngoing');
        //--------------------------------------------------
        nameList.add('Names of individual collecting stats listed? Agency ability to collect, report data?;1;StatisticsReport');
        nameList.add('Data collected and compiled appropriately?;1;StatisticsReport');
        nameList.add('Previous year goals/obj reported?;1;StatisticsReport');
        nameList.add('Significant program accomplishments?;1;StatisticsReport');
        nameList.add('Has program effectiveness been addressed?;1;StatisticsReport');
        //--------------------------------------------------
        nameList.add('Names of individual collecting stats listed? Agency ability to collect, report data?;1;VocaStatisticsReport');
        nameList.add('Data collected and compiled appropriately?;1;VocaStatisticsReport');
        nameList.add('Duplication concerns/justifications?;1;VocaStatisticsReport');
        nameList.add('How does program complement other services?;1;VocaStatisticsReport');
        nameList.add('3 support letters-from identified programs?;1;VocaStatisticsReport');
        //----------------------------------------------------
        nameList.add('Names of individual collecting stats listed? Agency ability to collect, report data?;1;VocaStatisticsReportSpecial');
        nameList.add('Data collected and compiled appropriately?;1;VocaStatisticsReportSpecial');
        nameList.add('Duplication concerns/justifications?;1;VocaStatisticsReportSpecial');
        nameList.add('How does program complement other services?;1;VocaStatisticsReportSpecial');
        nameList.add('3 support letters-from identified programs?;1;VocaStatisticsReportSpecial');
        //----------------------------------------------------
        nameList.add('Program history, growth, types of victim services offered, agency significant accomplishments?;2;ProjectAdministration');
        nameList.add('How well do they describe the project director’s and the staff’s ability to implement the VOCA program? Fiscal controls?;1;ProjectAdministration');
        nameList.add('Is there an org chart w/ names & title? Does org chart specify grant funded position?;1;ProjectAdministration');
        nameList.add('Are there position titles & job descriptions for each VAWA funded position? Are there volunteer job descriptions?;1;ProjectAdministration');
        //----------------------------------------------------
        nameList.add('Program history, growth, types of victim services offered, agency significant accomplishments?;2;VocaProjectAdministration');
        nameList.add('How well do they describe the project director’s and the staff’s ability to implement the VOCA program? Fiscal controls?;1;VocaProjectAdministration');
        nameList.add('Is there an org chart w/ names & title? Does org chart specify grant funded position?;1;VocaProjectAdministration');
        nameList.add('Are there position titles & job descriptions for each VAWA funded position? Are there volunteer job descriptions?;1;VocaProjectAdministration');
        //-------------------------------------------------------
        nameList.add('Program history, growth, types of victim services offered, agency significant accomplishments?;2;VocaProjectAdministrationSpecial');
        nameList.add('How well do they describe the project director’s and the staff’s ability to implement the VOCA program? Fiscal controls?;1;VocaProjectAdministrationSpecial');
        nameList.add('Is there an org chart w/ names & title? Does org chart specify grant funded position?;1;VocaProjectAdministrationSpecial');
        nameList.add('Are there position titles & job descriptions for each VAWA funded position? Are there volunteer job descriptions?;1;VocaProjectAdministrationSpecial');
        //-------------------------------------------------------
        nameList.add('Are all forms completed and signed by the authorized official?;5;VocaEEOP');
        //-------------------------------------------------------
        nameList.add('Are all forms completed and signed by the authorized official?;5;VocaEEOPSpecial');
        nameList.add('Is there a no turn away policy submitted?;5;VocaEEOPSpecial');
        //-------------------------------------------------------
        nameList.add('The final 10 points are to be awarded at your discretion. Please consider overall grant quality and/or any items that were not addressed above. Please include your comments in the section below:;10;StrengthWeakness');
        //-------------------------------------------------------
        nameList.add('The final 10 points are to be awarded at your discretion. Please consider overall grant quality and/or any items that were not addressed above. Please include your comments in the section below:;10;VocaStrengthWeakness');
        //-------------------------------------------------------
        nameList.add('The final 10 points are to be awarded at your discretion. Please consider overall grant quality and/or any items that were not addressed above. Please include your comments in the section below:;10;VocaStrengthWeaknessSpecial');
        //-------------------------------------------------------
        nameList.add('The final 20 points are to be awarded at your discretion. Please consider overall grant quality and/or any items that were not addressed above. Please include your comments in the section below:;20;VocaStrengthWeaknessOngoing');


        List<FormTable__c> result = new List<FormTable__c>();
        for (Review__c r : SMEReviews) {
            for (String temp : nameList) {
                String[] nameTable = temp.split(';');
                FormTable__c ft = new FormTable__c(Name__c = nameTable[0], PossiblePoints__c = Integer.valueOf(nameTable[1]), TableName__c = nameTable[2], Review__c = r.Id);
                result.add(ft);
            }
        }
        insert result;
    }

// Give Access to PM if he does not have access
    private void grantAccesstoPM() {
        List<Id> appId = new List<Id>();
        List<Id> reviewId = new List<Id>();
        List<Id> annList = new List<Id>();
        for (Review__c review : (List<Review__c>) trigger.new) {
            appId.add(review.Application__c);
            reviewId.add(review.Id);
        }

        List<Review__c> reviewList = [Select Id, Name, Application__c, Application__r.Announcement__c from Review__c where Application__c IN :appId and Id IN :reviewId];

        for (Review__c review : reviewList) {
            annList.add(review.Application__r.Announcement__c);
        }
        List<Review__Share> reviewShares = new List<Review__Share>();
        List<RolesAndResponsibilities__c> rrList = [Select Id, Name__c  from RolesAndResponsibilities__c where Announcement__c IN :annList AND Name__c != null];
        List<Id> userList = new List<Id>();
        for (RolesAndResponsibilities__c rr : rrList) {
            userList.add(rr.name__c);
        }

        for (Review__c review : (List<Review__c>) trigger.new) {
            for (Id userid : userList) {
                if (review.OwnerId != userid) {
                    Review__Share share = new Review__Share();
                    share.ParentId = review.Id;
                    share.UserOrGroupId = userid;
                    share.AccessLevel = 'edit';
                    share.RowCause = Schema.Review__Share.RowCause.SharetoAnnouncementReviewerAndApprover__c;
                    reviewShares.add(share);
                }
            }

        }

        if (reviewShares.size() > 0) {
            SystemContextMethodsHelper SystemContextMethodsHelper = new SystemContextMethodsHelper();
            SystemContextMethodsHelper.insertReviewShare(reviewShares);
        }
    }

    /**
        This method is used to copy all the field values from SRC to TARGET as mentioned in the RecordCopyConfig__c
        for all the lookups on Review__c object.
    */
    private void copyFieldValues() {
        Map<Id, List<Sobject>> appIdToSobjectMap = new Map<Id, List<Sobject>>();
        Map<Id, List<Sobject>> preappIdToSobjectMap = new Map<Id, List<Sobject>>();
        Map<Id, List<Sobject>> panelAppIdToSobjectMap = new Map<Id, List<Sobject>>();
        Map<Id, List<Sobject>> panelUserIdToSobjectMap = new Map<Id, List<Sobject>>();
        Map<Id, List<Sobject>> reviewerIdToSobjectMap = new Map<Id, List<Sobject>>();
        Map<Id, List<Sobject>> revPanelIdToSobjectMap = new Map<Id, List<Sobject>>();

        for (Review__c rev : (List<Review__c>)trigger.new) {
            if (rev.Application__c != null) {
                List<Sobject> newList = appIdToSobjectMap.get(rev.Application__c);
                if (newList == null) {
                    newList = new List<Sobject>();
                }
                newList.add(rev);
                appIdToSobjectMap.put(rev.Application__c, newList);
                rev.IsApplicationContext__c = true;
            }
            if (rev.PreApplication__c != null) {
                List<Sobject> newList = preappIdToSobjectMap.get(rev.PreApplication__c);
                if (newList == null) {
                    newList = new List<Sobject>();
                }
                newList.add(rev);
                preappIdToSobjectMap.put(rev.PreApplication__c, newList);
                rev.IsPreApplicationContext__c = true;
            }
            if (rev.PanelApplication__c != null) {
                List<Sobject> newList = panelAppIdToSobjectMap.get(rev.PanelApplication__c);
                if (newList == null) {
                    newList = new List<Sobject>();
                }
                newList.add(rev);
                panelAppIdToSobjectMap.put(rev.PanelApplication__c, newList);
            }
            if (rev.PanelUser__c != null) {
                List<Sobject> newList = panelUserIdToSobjectMap.get(rev.PanelUser__c);
                if (newList == null) {
                    newList = new List<Sobject>();
                }
                newList.add(rev);
                panelUserIdToSobjectMap.put(rev.PanelUser__c, newList);
            }
            if (rev.ownerId != null) {
                List<Sobject> newList = reviewerIdToSobjectMap.get(rev.ownerId);
                if (newList == null) {
                    newList = new List<Sobject>();
                }
                newList.add(rev);
                reviewerIdToSobjectMap.put(rev.ownerId, newList);
            }
            if (rev.ReviewPanel__c != null) {
                List<Sobject> newList = revPanelIdToSobjectMap.get(rev.ReviewPanel__c);
                if (newList == null) {
                    newList = new List<Sobject>();
                }
                newList.add(rev);
                revPanelIdToSobjectMap.put(rev.ReviewPanel__c, newList);
            }
        }
        if (appIdToSobjectMap != null && appIdToSobjectMap.size() > 0) {
            GNT.AppUtils.copyRecords(AppUtils.getNameSpacePrefix() + 'Application__c', AppUtils.getNameSpacePrefix() + 'Review__c', appIdToSobjectMap, false);
        }
        if (preappIdToSobjectMap != null && preappIdToSobjectMap.size() > 0) {
            GNT.AppUtils.copyRecords(AppUtils.getNameSpacePrefix() + 'PreApplication__c', AppUtils.getNameSpacePrefix() + 'Review__c', preappIdToSobjectMap, false);
        }
        if (panelAppIdToSobjectMap != null && panelAppIdToSobjectMap.size() > 0) {
            GNT.AppUtils.copyRecords(AppUtils.getNameSpacePrefix() + 'PanelApplication__c', AppUtils.getNameSpacePrefix() + 'Review__c', panelAppIdToSobjectMap, false);
        }
        if (panelUserIdToSobjectMap != null && panelUserIdToSobjectMap.size() > 0) {
            GNT.AppUtils.copyRecords(AppUtils.getNameSpacePrefix() + 'PanelUser__c', AppUtils.getNameSpacePrefix() + 'Review__c', panelUserIdToSobjectMap, false);
        }
        if (reviewerIdToSobjectMap != null && reviewerIdToSobjectMap.size() > 0) {
            GNT.AppUtils.copyRecords('User', AppUtils.getNameSpacePrefix() + 'Review__c', reviewerIdToSobjectMap, false);
        }
        if (revPanelIdToSobjectMap != null && revPanelIdToSobjectMap.size() > 0) {
            GNT.AppUtils.copyRecords(AppUtils.getNameSpacePrefix() + 'ReviewPanel__c', AppUtils.getNameSpacePrefix() + 'Review__c', revPanelIdToSobjectMap, false);
        }

        Set<Id> panelIds = new Set<Id>();
        for (Review__c review : (List<Review__c>) Trigger.New) {
            panelIds.add(review.ReviewPanel__c);
        }

        Map<Id, ReviewPanel__c> panelMap = new Map<Id, ReviewPanel__c>([Select Id, PanelName__c,
                ReviewStep__r.Name from ReviewPanel__c where Id in :panelIds]);
        for (Review__c review : (List<Review__c>) Trigger.New) {
            ReviewPanel__c panel = panelMap.get(review.ReviewPanel__c);
            review.ReviewPanelName__c = panel.PanelName__c;
            review.ReviewStepName__c = panel.ReviewStep__r.Name;
        }
    }
    @future
    private static void shareReviewGroupWithReviewer(Set<Id> revIdSet) {
        /*List<Review__c> reviewList = [Select Id, ownerId, ReviewPanel__r.ReviewStep__r.ReviewGroup__c from Review__c Where Id IN : revIdSet];

        Map<Id, Id> revIdToQueueIdMap = new Map<Id, Id>();
        Map<Id, Id> revIdToOwnerUserMap = new Map<Id, Id>();
        Map<Id, Set<Id>> grpIdToMemberMap = new Map<Id, Set<Id>>();
        Map<Id, Id> revIdToReviewGroupMap = new Map<Id, Id>();
        for(Review__c rev : reviewList){
            Id ownerId = rev.ownerId;
            if(ownerId.getSobjectType() != Schema.SobjectType.User.getSobjectType()){
                revIdToReviewGroupMap.put(rev.Id, rev.ReviewPanel__r.ReviewStep__r.ReviewGroup__c);
                revIdToQueueIdMap.put(rev.Id, ownerId);
            }else{
                revIdToReviewGroupMap.put(rev.Id, rev.ReviewPanel__r.ReviewStep__r.ReviewGroup__c);
                revIdToOwnerUserMap.put(rev.Id, ownerId);
            }
        }
        List<ReviewGroup__Share> rgShareList = new List<ReviewGroup__Share>();

        if(revIdToQueueIdMap.size() > 0){
            Map<Id, Group> groupMap = new Map<Id, Group>([Select DeveloperName, Id From Group where Id IN :revIdToQueueIdMap.values()]);
            List<GroupMember> groupMembers = [SELECT GroupId,Id,UserOrGroupId FROM GroupMember Where GroupId IN : groupMap.keySet()];
            for(GroupMember grpMember : groupMembers){
                Set<Id> memberSet = grpIdToMemberMap.get(grpMember.GroupId);
                if(memberSet == null){
                    memberSet = new Set<Id>();
                }
                memberSet.add(grpMember.UserOrGroupId);
                grpIdToMemberMap.put(grpMember.GroupId, memberSet);
            }

            for(Id revId : revIdToQueueIdMap.keySet()){
                Id queueId = revIdToQueueIdMap.get(revId);
                Set<Id> memberSet = grpIdToMemberMap.get(queueId);
                for(Id memberId : memberSet){
                    ReviewGroup__Share rgShare = new ReviewGroup__Share();
                    rgShare.ParentId = revIdToReviewGroupMap.get(revId );
                    rgShare.UserOrGroupId = memberId;
                    rgShare.AccessLevel = 'edit';
                    rgShareList.add(rgShare);
                }
            }
        }
        for(Id revId : revIdToOwnerUserMap.keySet()){

            ReviewGroup__Share rgShare = new ReviewGroup__Share();
            rgShare.ParentId = revIdToReviewGroupMap.get(revId);
            rgShare.UserOrGroupId = revIdToOwnerUserMap.get(revId);
            rgShare.AccessLevel = 'edit';
            rgShareList.add(rgShare);
        }
        if(rgShareList.size() > 0){
            SystemContextMethodsHelper scHelper = new SystemContextMethodsHelper();
            scHelper.insertReviewGroupShare(rgShareList);
        } */
    }
    public static void updateReviewStatusHTML(Set<Id> reviewIds, Boolean isDelete, Boolean isUpdate) {
        Map<Id, String> appIdToJsonMap = new Map<Id, String>();
        List<Id> revStepIdList = new List<Id>();
        List<Id> appPreAppIdList = new List<Id>();

        List<Review__c> reviewList = [Select Id, ReviewPanel__r.ReviewStep__c, PanelUser__r.Reviewer__r.Name,
                                      ReviewPanel__r.GroupName__c, PreApplication__c, Application__c, Status__c, ReviewPanel__r.ReviewStep__r.ReviewGroup__r.Announcement__r.Program__r.ReviewProcess__c
                                      From Review__c Where Id IN : reviewIds];

        for (Review__c review : reviewList) {
            Id appId;
            Boolean updateFlag = false;
            if (review.Application__c != null) {
                appId = review.Application__c;
            } else {
                appId = review.PreApplication__c;
            }
            if (review.Status__c == 'Review Completed') {
                updateFlag = true;
            } else {
                updateFlag = false;
            }
            String revStatusJSON = review.Id + ':' + review.Status__c + '#';
            String jsonString = appIdToJsonMap.get(appId);
            if (!String.isEmpty(jsonString)) {
                jsonString += revStatusJSON;
            } else {
                jsonString = revStatusJSON;
            }
            if (isUpdate && ((Map<Id, Review__c>)Trigger.oldMap).get(review.Id).PanelApplication__c != null) {
                if (updateFlag) {
                    appIdToJsonMap.put(appId, jsonString);
                    revStepIdList.add(review.ReviewPanel__r.ReviewStep__c);
                    appPreAppIdList.add(appId);
                }
            } else {
                appIdToJsonMap.put(appId, jsonString);
                revStepIdList.add(review.ReviewPanel__r.ReviewStep__c);
                appPreAppIdList.add(appId);
            }
        }
        system.debug('appIdToJsonMap ---' + appIdToJsonMap);
        updateReviewStatusOnStepApplication(revStepIdList, appPreAppIdList, appIdToJsonMap, isDelete);
    }
    /*
        Create tasks for reviewer user / group
    */
    private void createTasksforReviewers() {
        List<Task> taskList = new List<Task>();
        Map<Id, Task> revIdToTaskMap = new Map<Id, Task>();
        Map<Id, Id> revIdToOwnerIdMap = new Map<Id, Id>();
        Map<Id, Id> reviewIdToTaskList = new Map<Id, Id>();
        Map<Id, Set<Id>> grpIdToMemberMap = new Map<Id, Set<Id>>();

        for (Review__c review : (List<Review__c>) trigger.new) {
            Id ownerId = review.ownerId;
            if (ownerId.getSobjectType() != Schema.SobjectType.User.getSobjectType()) {
                revIdToOwnerIdMap.put(review.Id, ownerId);
            }
        }

        Map<Id, Group> groupMap = new Map<Id, Group>([Select DeveloperName, Id
                From Group where Id IN :revIdToOwnerIdMap.values()]);

        List<GroupMember> groupMembers = [SELECT GroupId, Id, UserOrGroupId FROM GroupMember Where GroupId IN : groupMap.keySet()];

        for (GroupMember grpMember : groupMembers) {
            Set<Id> memberSet = grpIdToMemberMap.get(grpMember.GroupId);
            if (memberSet == null) {
                memberSet = new Set<Id>();
            }
            memberSet.add(grpMember.UserOrGroupId);
            grpIdToMemberMap.put(grpMember.GroupId, memberSet);
        }

        List<Application__Share> appshareList = new List<Application__Share>();
        List<PreApplication__Share> preappshareList = new List<PreApplication__Share>();
        Map<Id, List<Sobject>> srcIdToTargetSobjectsMap = new Map<Id, List<Sobject>>();

        // Query to fetch relationship fields
        List<Review__c> reviewList = [Select Id, ownerId, Name, Application__r.Title__c, PreApplication__r.Title__c,
                                      ReviewPanel__r.AutoAssignsubmittedApplication__c, ReviewPanel__r.Chair__c, Application__r.OwnerId,
                                      ReviewPanel__r.TaskDueDate__c, ReviewPanel__r.DueDateOffset__c, ReviewPanel__r.EndDate__c
                                      From Review__c Where Id IN : trigger.newMap.keySet()];

        for (Review__c review : reviewList) {
            Id ownId = review.ownerId;  // If the review owner is Queue then only create task for Group i.e. Assign reviews to Group
            /* if(ownId.getSobjectType() != Schema.SobjectType.User.getSobjectType()){
                 if(review.ReviewPanel__r.AutoAssignsubmittedApplication__c != null && review.ReviewPanel__r.AutoAssignsubmittedApplication__c == true){
                     Id grpId = revIdToOwnerIdMap.get(review.Id);
                     Set<Id> grpMemberSet = grpIdToMemberMap.get(grpId);
                     Date dueDate = getDueDate(review.ReviewPanel__r.TaskDueDate__c, review.ReviewPanel__r.DueDateOffset__c, review.ReviewPanel__r.EndDate__c);
                     taskList = new List<Task>();
                     for(Id memberId : grpMemberSet){
                         Task taskRec = new Task();
                         if(review.Application__c != null){
                             //taskRec = GNT.TaskCreationHandler.createTasks(memberId, review.Id, 'Review Application', review.Application__r.Title__c, null, false, dueDate, 'Review', false).get(0);
                             taskRec = GNT.TaskCreationHandler.createTasks(memberId, review.Id, 'Review Application', review.Application__r.Title__c, null, false, dueDate, 'Review', review.Name, false).get(0);
                             Application__Share appShare = getAppShare(review.Application__c, memberId);
                             appshareList.add(appShare);
                         }else if(review.PreApplication__c != null){
                             //taskRec = GNT.TaskCreationHandler.createTasks(memberId, review.Id, 'Review Pre-Application', review.PreApplication__r.Title__c, null, false, dueDate, 'Review', false).get(0);
                             taskRec = GNT.TaskCreationHandler.createTasks(memberId, review.Id, 'Review Pre-Application', review.PreApplication__r.Title__c, null, false, dueDate, 'Review', review.Name, false).get(0);
                             PreApplication__Share preappShare = getPreAppShare(review.PreApplication__c, memberId);
                             preappshareList.add(preappShare);
                         }
                         taskRec.GNT__GroupName__c = groupMap.get(revIdToOwnerIdMap.get(review.Id)).DeveloperName;
                         taskRec.GNT__GroupId__c = revIdToOwnerIdMap.get(review.Id);
                         taskList.add(taskRec);
                     }
                     srcIdToTargetSobjectsMap.put(review.id,taskList);
                 }
             }*/
        }
        //  List<Task> tasks = GNT.AppUtils.copyRecords(GNT.AppUtils.getNamespacePrefix()+'Review__c','Task',srcIdToTargetSobjectsMap,false);
        // Share review record with Panel's Chair
        List<Review__Share> reviewShareList = new List<Review__Share>();

        for (Review__c review : reviewList) {
            if (review.Application__c != null) {
                // Share with Reviewer
                if (review.OwnerId.getSobjectType() == Schema.SobjectType.User.getSobjectType()) {
                    if (review.Application__r.OwnerId != review.OwnerId) {
                        Application__Share appShare2 = getAppShare(review.Application__c, review.OwnerId);
                        appshareList.add(appShare2);
                    }
                }
            } else if (review.PreApplication__c != null) {
                // Share with Reviewer
                if (review.OwnerId.getSobjectType() == Schema.SobjectType.User.getSobjectType()) {
                    PreApplication__Share appShare2 = getPreAppShare(review.PreApplication__c, review.OwnerId);
                    preappshareList.add(appShare2);
                }
            }
        }
        SystemContextMethodsHelper helper = new SystemContextMethodsHelper();
        if (reviewShareList.size() > 0) {
            helper.insertReviewShare(reviewShareList);
        }

        if (appshareList.size() > 0) {
            helper.insertApplicationShare(appshareList);
        }
        if (preappshareList.size() > 0) {
            helper.insertPreApplicationShare(preappshareList);
        }
        /*
        if(tasks.size() > 0){
            insert tasks;
            List<Id> taskIds = new List<Id>();
            for (Task task: tasks) {
                taskIds.add(task.Id);
            }
            populateGroupTaskMapping(taskIds);
        } */
    }
    
    private void sendEmailstoReviewers(List<Review__c> reviewList){
        List<Id> reviewIds = new List<Id>();
        List<Id> panelUserIds = new List<Id>();
        List<Id> userIds = new List<Id>();
        for (Review__c review : reviewList){
            reviewIds.add(review.Id);
            panelUserIds.add(review.PanelUser__c);
        }
        
        List<PanelUser__c> panelUserList = [SELECT Id,Reviewer__c FROM PanelUser__c WHERE Id IN: panelUserIds];
        for (PanelUser__c panelUser : panelUserList){
            userIds.add(panelUser.Reviewer__c);
        }

        List<User> usersList = [SELECT Id, Email, AccountId, ContactId FROM User WHERE Id IN: userIds];
        Map<Id, List<User>> accountIdMapUserList = new Map<Id, List<User>>();
        for (User userIterator : usersList) {
            List<User> userList = accountIdMapUserList.get(userIterator.AccountId);
            if (userList == null) {
                userList = new List<User>();
                accountIdMapUserList.put(userIterator.AccountId, userList);
            }
            userList.add(userIterator);
        }
        AppUtils.TaskEmailWrapper taskEmailer = new AppUtils.TaskEmailWrapper();
        taskEmailer.setObjectList(reviewIds);
        taskEmailer.setUserList(usersList);
        taskEmailer.setAccountIdMapUserList(accountIdMapUserList);
        taskEmailer.setEmailTemplateDevName('Review_Initiated');
        String resultMessage = taskEmailer.massSendEmailMapOrg();
    }
    
    private void UpdateNoofReviews(List<Review__c> lstApplicationReview) {
        system.debug('--inside UpdateNoofReviews---');
        Set<Id> revStepIds = new Set<Id>();
        for (Review__c appRev : lstApplicationReview) {
            if (appRev.ReviewStep__c != null) {
                revStepIds.add(appRev.ReviewStep__c);
            }
        }

        system.debug('--inside UpdateNoofReviews-  revStepIds--' + revStepIds);

        List<ReviewStep__c> annsToRollup = new List<ReviewStep__c>();
        for (AggregateResult ar : [SELECT ReviewStep__c RSId, Count(id) ReviewCount
                                   FROM Review__c
                                   WHERE ReviewStep__c in: revStepIds
                                   GROUP BY ReviewStep__c]) {
            ReviewStep__c a = new ReviewStep__c();
            a.Id = (Id) ar.get('RSId');
            a.NoOfReviews__c = (Integer) ar.get('ReviewCount');
            annsToRollup.add(a);
        }
        update annsToRollup;




        List<ReviewStep__c> rsRollup = new List<ReviewStep__c>();
        for (AggregateResult ar1 : [SELECT ReviewStep__c RSId, Count(id) ReviewCount FROM Review__c WHERE ReviewStep__c in: revStepIds AND (Compliant__c = 'Compliant' OR Compliant__c = 'Non-Compliant') AND Status__c IN ('Review Completed') AND (ReviewAcceptanceStatus__c = 'Accepted' OR ReviewAcceptanceStatus__c = 'Declined') GROUP BY ReviewStep__c]) {
            ReviewStep__c a = new ReviewStep__c();
            a.Id = (Id) ar1.get('RSId');
            a.NoOfCompletedReviews__c = (Integer) ar1.get('ReviewCount');
            rsRollup.add(a);
        }
        update rsRollup;

    }

    private void updateRecommendedAmountFourPathway(List<Review__c> reviewList){
        List<Id> appIdList = new List<Id>();
        for(Review__c review : reviewList){
            appIdList.add(review.Application__c);
        }
        Map<Id, Application__c> appIdMap = new Map<Id, Application__c>([SELECT Id, Announcement__r.Program__r.ProgramPathway__c, BudgetAllocation__c FROM Application__c WHERE Id IN :appIdList]);
        Set<String> pathways = new Set<String>{'Fed-Formula', 'State-Formula', 'Application 1/12th', 'Lump-Sum-App'};
        for(Review__c review : reviewList){
            if(pathways.contains(appIdMap.get(review.Application__c).Announcement__r.Program__r.ProgramPathway__c)){
                review.RecommendedBudget__c = appIdMap.get(review.Application__c).BudgetAllocation__c;
            }
        }
    }

    private void copyManagementComments(List<Review__c> ReviewComments) {
        Set<Id> AppIds = new Set<Id>();
        for (Review__c revs : ReviewComments) {
            if (revs.Application__c != null) {
                AppIds.add(revs.Application__c);
            }
        }
        Map<Id, Application__c> App = new Map<Id, Application__c>([SELECT Id, GrantorOrganizationName__c  FROM Application__c WHERE Id in :AppIds]);
        for (Review__c rev : ReviewComments) {
            if (App.get(rev.Application__c).GrantorOrganizationName__c == 'UOVC') {
                App.get(rev.Application__c).ManagementOverallComs__c = 'Required Revisions : ' + rev.CorrectionsComments__c + '<br><br>Overall Comments: ' + rev.OverallsComments__c + '<br><br>Questions: ' + rev.QuestionsComments__c + '<br><br>Suggestions: ' + rev.SuggestionsComments__c;
            }
        }
        update App.values();
    }
    //private void updateCorrectionsChangeReq(List<Review__c> correctionReview){
    //    Set<Id> AppIds = new Set<id>();
    //    Map<Id, String> RevCorrecs = new Map<Id, String>();
    //    for(Review__c rev : correctionReview){
    //        if(rev.Application__c!=null){
    //            RevCorrecs.put(rev.Application__c,rev.CorrectionsComments__c);
    //        }
    //    }
    //    AppIds = RevCorrecs.keySet();
    //    Map<Id,Application__c> App = new Map<Id,Application__c>([SELECT Id, ManagementCorrections__c FROM Application__c WHERE Id in :AppIds]);
    //    for(Id AppId : AppIds){
    //        App.get(AppId).ManagementCorrections__c = RevCorrecs.get(AppId);
    //    }
    //    update App.values();
    //}

    //private void testchange(List<Review__c> correctionReview){
    //    Set<Id> AppIds = new Set<id>();
    //    Map<Id, String> RevCorrecs = new Map<Id, String>();
    //    for(Review__c rev : correctionReview){
    //        if(rev.Application__c!=null){
    //            RevCorrecs.put(rev.Application__c,rev.CorrectionsComments__c);
    //        }
    //    }
    //    AppIds = RevCorrecs.keySet();
    //    Map<Id,Application__c> App = new Map<Id,Application__c>([SELECT Id, ManagementCorrections__c FROM Application__c WHERE Id in :AppIds]);
    //    for(Id AppId : AppIds){
    //        App.get(AppId).ManagementCorrections__c = RevCorrecs.get(AppId);
    //    }
    //    update App.values();
    //}

    //private void updateOverallCommentsChangeReq(List<Review__c> overallComments){
    //    Set<Id> AppIds = new Set<id>();
    //    Map<Id,String> RevOverallComs = new Map<Id,String>();
    //    for(Review__c rev : overallComments){
    //        if(rev.Application__c!=null){
    //            RevOverallComs.put(rev.Application__c, rev.OverallsComments__c);
    //        }
    //    }
    //    AppIds = RevOverallComs.keyset();
    //    Map<Id,Application__c> App = new Map<Id,Application__c>([SELECT Id, ManagementOverallComs__c FROM Application__c WHERE Id in :AppIds]);
    //    for(Id AppId : AppIds){
    //        App.get(AppId).ManagementOverallComs__c = RevOverallComs.get(AppId);
    //    }
    //    update App.values();
    //}

    //private void UpdateSuggestionsChangeReq(List<Review__c> suggestions){
    //    Set<Id> AppIds = new Set<id>();
    //    Map<Id,String> RevSuggestions = new Map<Id,String>();
    //    for(Review__c rev : suggestions){
    //        if(rev.Application__c!=null){
    //            RevSuggestions.put(rev.Application__c, rev.SuggestionsComments__c);
    //        }
    //    }
    //    AppIds = RevSuggestions.keyset();
    //    Map<Id,Application__c> App = new Map<Id,Application__c>([SELECT Id, ManagementSuggestions__c FROM Application__c WHERE Id in :AppIds]);
    //    for(Id AppId : AppIds){
    //        App.get(AppId).ManagementSuggestions__c = RevSuggestions.get(AppId);
    //    }
    //    update App.values();
    //}

    //private void UpdateQuestions(List<Review__c> questions){
    //    Set<Id> AppIds = new Set<id>();
    //    Map<Id,String> Revquestions = new Map<Id,String>();
    //    for(Review__c rev : questions){
    //        if(rev.Application__c!=null){
    //            Revquestions.put(rev.Application__c, rev.QuestionsComments__c);
    //        }
    //    }
    //    AppIds = Revquestions.keyset();
    //    Map<Id,Application__c> App = new Map<Id,Application__c>([SELECT Id, ManagementQuestions__c FROM Application__c WHERE Id in :AppIds]);
    //    for(Id AppId : AppIds){
    //        App.get(AppId).ManagementQuestions__c = Revquestions.get(AppId);
    //    }
    //    update App.values();
    //}

    private void updateNoOfApplicationsPerReviewer(List<Review__c> reviews) {
        Set<Id> panelUserIds = new Set<Id>();
        Set<Id> panelAppIds = new Set<Id>();
        Map<Id, PanelUser__c> panelUsersMap = new Map<Id, PanelUser__c>();
        Map<Id, PanelApplication__c> panelAppsMap = new Map<Id, PanelApplication__c>();
        if (reviews.size() > 0) {
            for (Review__c review : reviews) {
                panelUserIds.add(review.PanelUser__c);
                panelAppIds.add(review.PanelApplication__c);
            }
        }
        Map<Id, PanelUser__c> panelUsers = new Map<Id, PanelUser__c>([select id, NoOfApplicationsAssigned__c from PanelUser__c where id in : panelUserIds]);
        Map<Id, PanelApplication__c> panelApplications = new Map<Id, PanelApplication__c>([select id, NoOfReviewersAssigned__c from PanelApplication__c where id in : panelAppIds]);
        for (Review__c rev : reviews) {
            if (panelUsers.keySet().contains(rev.PanelUser__c)) {
                PanelUser__c pUser = panelUsers.get(rev.PanelUser__c);
                if (pUser.NoOfApplicationsAssigned__c == null) {
                    pUser.NoOfApplicationsAssigned__c = 1;
                } else {
                    pUser.NoOfApplicationsAssigned__c = pUser.NoOfApplicationsAssigned__c + 1;
                }
            }
            if (panelApplications.keySet().contains(rev.PanelApplication__c)) {
                PanelApplication__c pApp = panelApplications.get(rev.PanelApplication__c);
                if (pApp.NoOfReviewersAssigned__c == null) {
                    pApp.NoOfReviewersAssigned__c = 1;
                } else {
                    pApp.NoOfReviewersAssigned__c = pApp.NoOfReviewersAssigned__c + 1;
                }
            }
        }
        update panelUsers.values();
        update panelApplications.values();
    }
    private Date getDueDate(String taskDueDate, String dueDateOffset, Date endDate) {
        Date dueDate;
        if (!String.isEmpty(taskDueDate) && taskDueDate == 'Today + Offset Days') {
            if (!String.isEmpty(dueDateOffset)) {
                dueDate = Date.today();
                dueDate = dueDate.addDays(Integer.valueOf(dueDateOffset));
            }
        } else {
            if (endDate != null) {
                dueDate = endDate;
            }
        }
        return dueDate;
    }
    private Application__Share getAppShare(Id appId, Id UserId) {
        Application__Share appshare = new Application__Share();
        appshare.ParentId = appId;
        appshare.UserOrGroupId = UserId;
        appshare.AccessLevel = 'edit';
        appshare.Rowcause = Schema.Application__Share.RowCause.SharetoReviewStepReviewers__c;
        return appshare;
    }
    private PreApplication__Share getPreAppShare(Id preAppId, Id UserId) {
        PreApplication__Share preappshare = new PreApplication__Share();
        preappshare.ParentId = preAppId;
        preappshare.UserOrGroupId = UserId;
        preappshare.AccessLevel = 'read';
        preappshare.RowCause = Schema.PreApplication__Share.RowCause.Sharing_for_Review__c;
        return preappshare;
    }
    //method is not used. commenting out to cover test code coverage(6/16/17)-charan
    /*private void populateGroupTaskMapping(List<Id> taskIdList){
        List<Task> taskList = [Select Id, WhatId From Task Where Id IN : taskIdList];
        Map<Id, Set<Id>> revIdToTaskIdMap = new Map<Id, Set<Id>>();
        Map<Id, Id> taskIdToRevId = new Map<Id, Id>();
        List<GroupTaskMapping__c> fldMappingList = new List<GroupTaskMapping__c>();

        for(Task taskRec : taskList){
            Set<Id> taskId = revIdToTaskIdMap.get(taskRec.WhatId);
            if(taskId == null){
                taskId = new Set<Id>();
            }
            taskId.add(taskRec.Id);
            revIdToTaskIdMap.put(taskRec.WhatId, taskId);
        }
        for(Id reviewId : revIdToTaskIdMap.keySet()){
            Set<Id> taskIdSet = revIdToTaskIdMap.get(reviewId);
            for(Id taskId : taskIdSet){
                GroupTaskMapping__c fldMapping = new GroupTaskMapping__c();
                fldMapping.Name = taskId;
                fldMapping.ParentRecordId__c = reviewId;
                fldMappingList.add(fldMapping);
            }
        }
        if(fldMappingList.size() > 0){
            insert fldMappingList;
        }
    }*/
    /* Update the Review Status on RSA obejct */
    @future
    public static void updateReviewStatusOnStepApplication(List<Id> revStepIdList, List<Id> appPreAppIdList, Map<Id, String> appIdToJsonMap, Boolean isDelete) {
        Map<Id, String> revIdToStatus = new Map<Id, String>();
        Map<Id, String> revIdToRecommendation = new Map<Id, String>();
        Map<Id, String> revIdToReviewer = new Map<Id, String>();
        Set<Id> reviewIdSet = new Set<Id>();
        Map<Id, Id> revIdToStepAppIdMap = new Map<Id, Id>();
        Map<Id, String> stepAppIdToHTMLMap = new Map<Id, String>();

        List<ReviewStepApplication__c> rsaList = [Select id, ReviewStatus__c, ReviewStatusJsonString__c, Application__c, PreApplication__c
                From ReviewStepApplication__c
                Where ReviewStep__c IN : revStepIdList
                AND (Application__c IN : appPreAppIdList OR PreApplication__c IN : appPreAppIdList) FOR UPDATE];

        for (ReviewStepApplication__c rsa : rsaList) {
            String revStatusJSON = '';
            if (rsa.Application__c != null) {
                revStatusJSON = appIdToJsonMap.get(rsa.Application__c);
            } else {
                revStatusJSON = appIdToJsonMap.get(rsa.PreApplication__c);
            }
            system.debug('rsa.ReviewStatusJsonString__c ---' + rsa.ReviewStatusJsonString__c);
            if (rsa.ReviewStatusJsonString__c != null) {
                rsa.ReviewStatusJsonString__c = generateJSON(rsa.ReviewStatusJsonString__c, revStatusJSON, isDelete);
            } else {
                rsa.ReviewStatusJsonString__c = revStatusJSON;
            }
            system.debug('rsa.ReviewStatusJsonString__c ---' + rsa.ReviewStatusJsonString__c);
            Set<Id> revIdSet = getAllReviewIds(rsa.ReviewStatusJsonString__c);
            for (Id revId : revIdSet) {
                revIdToStepAppIdMap.put(revId, rsa.Id);
            }
            reviewIdSet.addAll(revIdSet);
        }
        system.debug('**reviewIdSet**' + reviewIdSet);
        List<Review__c> allReviewsList = [Select Id, Compliant__c, Recommendation__c, Status__c, Reviewer__r.Name, PanelUser__r.Reviewer__r.Name, ReviewPanel__r.GroupName__c, OwnerId, Owner.Name, Application__r.Announcement__r.Program__r.ReviewProcess__c, OneStepReviewCompletionStatus__c
                                          From Review__c
                                          Where Id IN : reviewIdSet];

        for (Review__c review : allReviewsList) {
            system.debug('**review**' + review);
            revIdToStatus.put(review.Id, review.Status__c);
            if (review.Application__r.Announcement__r.Program__r.ReviewProcess__c != null && review.Application__r.Announcement__r.Program__r.ReviewProcess__c == 'One step review') {
                revIdToRecommendation.put(review.Id, review.OneStepReviewCompletionStatus__c);
            } else {
                revIdToRecommendation.put(review.Id, review.Compliant__c);
            }
            if (review.PanelUser__r.Reviewer__r.Name != null) {
                revIdToReviewer.put(review.Id, review.PanelUser__r.Reviewer__r.Name);
            } else if (review.ownerId != null) {
                revIdToReviewer.put(review.Id, review.Owner.Name);
            } else if (review.ReviewPanel__r.GroupName__c != null) {
                revIdToReviewer.put(review.Id, review.ReviewPanel__r.GroupName__c);
            } else {
                revIdToReviewer.put(review.Id, '');
            }
        }

        stepAppIdToHTMLMap = generateHTML(reviewIdSet, revIdToStatus, revIdToRecommendation, revIdToReviewer, revIdToStepAppIdMap, stepAppIdToHTMLMap);
        system.debug('stepAppIdToHTMLMap---' + stepAppIdToHTMLMap);
        for (ReviewStepApplication__c rsa : rsaList) {
            rsa.ReviewStatus__c = stepAppIdToHTMLMap.get(rsa.Id);
        }
        if (rsaList.size() > 0) {
            update rsaList;
        }
    }
    /*
        This method is used to generate the HTML content based on the updated status of the reviews
    */
    private static String generateJSON(String oldJson, String newJson, Boolean isDelete) {
        system.debug('oldJson --' + oldJson);
        system.debug('newJson --' + newJson);
        String finalJSON = '';
        Boolean found, alreadyProcessed;
        List<String> recordsProcessedList = new List<String>();
        List<String> oldTokensList = oldJson.split('#');    // a1RG0000004WHx3MAG:Sent for Review#a1RG0000004WHx2MAG:Sent for Review#
        List<String> newTokensList = newJson.split('#');    // a1RG0000004WHx3MAG:In Progress#
        for (String oldTok : oldTokensList) {
            List<String> oldToken = oldTok.split(':');
            found = false;
            for (String tok : newTokensList) {
                List<String> newToken = tok.split(':');
                if (newToken[0] == oldToken[0]) {
                    found = true;
                    if (!isDelete) {
                        finalJSON += newToken[0] + ':' + newToken[1] + '#';
                    }
                    break;
                }
            }
            if (!found) {
                finalJSON += oldToken[0] + ':' + oldToken[1] + '#';
            }
            recordsProcessedList.add(oldToken[0]);
        }
        for (String newTok : newTokensList) { // ID2, ID3
            List<String> newToken = newTok.split(':');
            alreadyProcessed = false;
            for (String recProcessed : recordsProcessedList) { // ID1, ID2
                if (recProcessed == newToken[0]) {
                    alreadyProcessed = true;
                    break;
                }
            }
            if (!alreadyProcessed) {
                finalJSON += newToken[0] + ':' + newToken[1] + '#';
            }
        }

        return finalJSON;
    }
    private static Set<Id> getAllReviewIds(String revJSON) {
        Set<Id> revIdSet = new Set<Id>();
        if (!String.isEmpty(revJSON)) {
            List<String> tokenList = revJSON.split('#');
            for (String token : tokenList) {
                List<String> tok = token.split(':');
                revIdSet.add(tok[0]);
            }
        }
        return revIdSet;
    }
    private static Map<Id, String> generateHTML(Set<Id> reviewIdSet, Map<Id, String> revIdToStatus, Map<Id, String> revIdToRecommendation, Map<Id, String> revIdToReviewer, Map<Id, Id> revIdToStepAppIdMap, Map<Id, String> stepAppIdToHTMLMap) {
        for (Id revId : reviewIdSet) {
            String status = revIdToStatus.get(revId);
            String revRecommendation = revIdToRecommendation.get(revId);
            String reviewerName = revIdToReviewer.get(revId);
            String tooltip = '', colorValue = '', iconCSSName = '', reviewDecision = '';
            String revCompleted = revIdToStatus.get(revId);
            system.debug('status---' + status);
            system.debug('revRecommendation---' + revRecommendation);
            system.debug('reviewerName---' + reviewerName);

            if (!String.isEmpty(revRecommendation) && revCompleted == 'Review Completed') {
                if (revRecommendation.equalsIgnoreCase('Eligible') || revRecommendation.equalsIgnoreCase('Compliant') || revRecommendation.equals('Recommended')) {
                    colorValue = 'green';
                    iconCSSName = 'iconCompleted';
                    reviewDecision = 'Compliant';
                } else if (revRecommendation.equalsIgnoreCase('Ineligible') || revRecommendation.equalsIgnoreCase('Non-Compliant') || revRecommendation.equals('Non-Recommended')) {
                    colorValue = 'red';
                    iconCSSName = 'iconRejected';
                    reviewDecision = 'Non-Compliant';
                } else if (revRecommendation.equalsIgnoreCase('Review Declined') || revRecommendation.equalsIgnoreCase('Recommended with Reservation')) {
                    colorValue = 'yellow';
                    iconCSSName = 'iconUncertain';
                    reviewDecision = 'Declined';
                } else if (revRecommendation.equalsIgnoreCase('None') || revRecommendation.equalsIgnoreCase('Not Reviewed')) {
                    colorValue = 'gray';
                    iconCSSName = 'iconNotStarted';
                    reviewDecision = 'Not Started';
                    //      tooltip = reviewerName + ': ' + status ;
                }
                //The complete/incomplete/rejected are used for the 1-Step review process workflow
                else if (revRecommendation.equalsIgnoreCase('Application Complete') || revRecommendation.equalsIgnoreCase('Application Incomplete')) {
                    colorValue = 'green';
                    iconCSSName = 'iconCompleted';
                    reviewDecision = revRecommendation;
                    //reviewDecision = 'Complete';
                } else if (revRecommendation.equalsIgnoreCase('Rejected') || revRecommendation.equalsIgnoreCase('Application Rejected')) {
                    colorValue = 'red';
                    iconCSSName = 'iconRejected';
                    reviewDecision = revRecommendation;
                }
                tooltip = reviewerName + ': ' + status + ' - ' + revRecommendation;
            } else {
                colorValue = 'gray';
                iconCSSName = 'iconNotStarted';
                reviewDecision = 'Not Started';
                tooltip = reviewerName + ': ' + status ;
            }
            // reviewer name: status - recommendation
            // String tempHTML = '<a onclick=\"window.open(\'/apex/'+AppUtils.getNameSpacePrefix()+'ReviewAssignmentModalView?id='+revId+'\',\'Review View\',\'scrollbars=1,height=800px,width=900px\',\'_blank\')\" title=\"'+tooltip+'\"><span class=\"glyphicon glyphicon-user '+iconCSSName+'\" ></span></a>&nbsp;';
            //String tempHTML = '<a onclick=\"window.open(\'/apex/'+AppUtils.getNameSpacePrefix()+'ReviewAssignmentModalView?id='+revId+'\',\'Review View\',\'scrollbars=1,height=800px,width=900px\',\'_blank\')\" title=\"'+tooltip+'\"><i class=\"fa fa-question\" aria-hidden=\"true\" ></i></a>&nbsp;';
            String tempHTML;
            if (reviewDecision == 'Declined') {
                tempHTML = '<a onclick=\"window.open(\'/apex/' + AppUtils.getNameSpacePrefix() + 'ReviewerConfirmationView?id=' + revId + '\',\'Review View\',\'scrollbars=1,height=800px,width=900px\',\'_blank\')\" title=\"' + tooltip + '\">';
            } else {
                tempHTML = '<a onclick=\"window.open(\'/apex/' + AppUtils.getNameSpacePrefix() + 'ReviewAssignmentModalView?id=' + revId + '\',\'Review View\',\'scrollbars=1,height=800px,width=900px\',\'_blank\')\" title=\"' + tooltip + '\">';
            }

            if (reviewDecision == 'Compliant' || reviewDecision == 'Application Complete') {
                tempHTML = tempHTML + '<i class=\"fa fa-thumbs-up\" aria-hidden=\"true\" ></i></a>&nbsp;';
            } else if (reviewDecision == 'Non-Compliant' || reviewDecision == 'Application Rejected'  || reviewDecision == 'Application Incomplete' || reviewDecision == 'Rejected') {
                tempHTML = tempHTML + '<i class=\"fa fa-thumbs-down\" aria-hidden=\"true\" ></i></a>&nbsp;';
            } else if (reviewDecision == 'Declined') {
                tempHTML = tempHTML + '<i class=\"fa fa-ban\" aria-hidden=\"true\" ></i></a>&nbsp;';
            } else {
                tempHTML = tempHTML + '<i class=\"fa fa-question\" aria-hidden=\"true\" ></i></a>&nbsp;';
            }

            Id stpeAppId = revIdToStepAppIdMap.get(revId);
            String iconHTML = stepAppIdToHTMLMap.get(stpeAppId);
            if (!String.isEmpty(iconHTML)) {
                iconHTML += tempHTML;
            } else {
                iconHTML = tempHTML;
            }
            stepAppIdToHTMLMap.put(stpeAppId, iconHTML);
        }
        return stepAppIdToHTMLMap;
    }
    private void calculateScoreForCompletedReviews() {
        system.debug('--calculateScoreForCompletedReviews--');
        Map<Id, Review__c> oldReviews = (Map<Id, Review__c>)trigger.oldMap;
        Map<Id, Review__c> newReviews = (Map<Id, Review__c>)trigger.newMap;
        Map<Id, Review__c> updatedReviews = new Map<Id, Review__c>();
        for (Review__c review : newReviews.values() ) {
            system.debug('--calculateScoreForCompletedReviews--review --' + review );
            // We will only consider the scoring from reviews where reviewer did a review and not declined it
            if (review.status__c == 'Review Completed' && review.ReviewAcceptanceStatus__c == 'Accepted') {
                updatedReviews.put(review.id, review);
            }
        }
        if (updatedReviews.size() > 0) {
            calculateTotalScore(updatedReviews);
        }
    }
    //When a reviewer starts the review, the status should be changed to 'Review In Progress'
    private void changeToInProgress() {
        for (Review__c review : (List<Review__c>) trigger.new) {
            Review__c oldReview = (Review__c) Trigger.OldMap.get(review.Id);
            if (review.Status__c == 'Assigned' && oldReview.Status__c == 'Assigned') {
                review.Status__c = 'Review In Progress';
            }
            if (review.Status__c == 'Sent for Review' && oldReview.Status__c == 'Sent for Review') {
                review.Status__c = 'Review In Progress';
            }
        }
    }
    /*
        Mark the task completed when the Review gets completed or when review is declined
    */
    private void closeTasks() {
        List<Review__c> reviewsList = new List<Review__c>();
        for (Review__c review : (List<Review__c>) trigger.new) {

            Review__c oldReview = (Review__c) trigger.oldMap.get(review.Id);
            Boolean closeTask = false;

            if ((oldReview.AcceptanceStatus__c != 'Declined Without Conflict' && review.AcceptanceStatus__c == 'Declined Without Conflict')) {
                review.Status__c = 'Declined Without Conflict';
                closeTask = true;
            } else if (oldReview.AcceptanceStatus__c != 'Declined Due To Conflict' && review.AcceptanceStatus__c == 'Declined Due To Conflict') {
                review.Status__c = 'Declined Due To Conflict';
                closeTask = true;
            } else if (oldReview.AcceptanceStatus__c != 'Accepted' && review.AcceptanceStatus__c == 'Accepted' && review.Status__c != 'Review Completed' ) {
                review.Status__c = 'Review In Progress';
            }
            if (oldReview.Status__c != 'Review Completed' && review.Status__c == 'Review Completed') {
                closeTask = true;
            }
            if (closeTask) {
                reviewsList.add(review);
            }
        }
        if (reviewsList.size() > 0) {
            closeTasks(reviewsList);
        }
    }
    private  void calculateTotalScore(Map<Id, Review__c> reviewMap) {
        system.debug('--calculateTotalScore--' + reviewMap);
        Map<Id, Review__c> reviews = new Map<Id, Review__c>([SELECT PanelApplication__r.ReviewPanel__r.ExcludeFromScoring__c, ReviewPanel__r.ReviewStep__c,
                PanelApplication__r.ReviewPanel__r.ReviewPackage__r.GNT__PageTemplateConfig__r.GNT__EditLayoutConfig__c
                FROM Review__c WHERE ID in :reviewMap.keySet()]);
        Map<Id, Id> reviewpageLayoutIds = new Map<Id, Id>();
        for (Review__c review : reviews.values()) {
            if (review.PanelApplication__r.ReviewPanel__r.ExcludeFromScoring__c == false) {
                reviewpageLayoutIds.put(review.Id, review.PanelApplication__r.ReviewPanel__r.ReviewPackage__r.GNT__PageTemplateConfig__r.GNT__EditLayoutConfig__c);
            }
        }
        if (reviewpageLayoutIds != null && reviewpageLayoutIds.size() > 0) {
            Map<Id, GNT__PageBlockDetailConfig__c> pageBlockDetail = new Map<Id, GNT__PageBlockDetailConfig__c>([select id, GNT__FieldAPIName__c, GNT__PageLayoutId__c, GNT__ScoringFactorFieldName__c from GNT__PageBlockDetailConfig__c
                    where  GNT__PageLayoutId__c in: reviewpageLayoutIds.values() and GNT__IsScoringQuestion__c = true AND GNT__IsActive__c = true]);
            if (pageBlockDetail != null && pageBlockDetail.size() > 0) {
                Map<Id, List<GNT__PageBlockDetailConfig__c>> layoutDetailIdMap = new Map<Id, List<GNT__PageBlockDetailConfig__c>>();
                //Map of Page LayoutIds and the corresponding detail records
                for (GNT__PageBlockDetailConfig__c pbd : pageBlockDetail.values()) {
                    List<GNT__PageBlockDetailConfig__c> pbDetails = layoutDetailIdMap.get(pbd.GNT__PageLayoutId__c);
                    if (pbDetails == null) {
                        pbDetails = new List<GNT__PageBlockDetailConfig__c>();
                    }
                    pbDetails.add(pbd);
                    layoutDetailIdMap.put(pbd.GNT__PageLayoutId__c, pbDetails);
                }
                for (Review__c review : reviewMap.values()) {
                    Id pageLayoutId = reviewpageLayoutIds.get(review.id);
                    List<GNT__PageBlockDetailConfig__c> pageBlock = layoutDetailIdMap.get(pageLayoutId);
                    Decimal total = 0;
                    Decimal score = 0.0;
                    Decimal weightageFactor = 1.0;
                    if (pageBlock != null) {
                        for (GNT__PageBlockDetailConfig__c detail : pageBlock) {
                            try {
                                if (!String.isEmpty(detail.GNT__ScoringFactorFieldName__c)) {
                                    try {
                                        weightageFactor = Integer.valueOf(detail.GNT__ScoringFactorFieldName__c);
                                    } catch (Exception e) {
                                        weightageFactor = (decimal)review.get(detail.GNT__ScoringFactorFieldName__c);
                                    }
                                } else {
                                    weightageFactor = 1.0;
                                }
                                if (String.valueOf(review.get(detail.GNT__FieldAPIName__c)) != null) {
                                    score = weightageFactor * GNT.AppUtils.getNumericValueFromString(String.valueOf(review.get(detail.GNT__FieldAPIName__c)));
                                } else {
                                    score = 0.0;
                                }
                            } catch (Exception e) {
                                score = 0.0;
                            }
                            total += score;
                        }
                        review.summaryScore__c = total;
                    }
                }
            }
        }
    }
    /*
        Mark the review task as completed
    */
    public void closeTasks(List<Review__c> reviews) {
        Map<Id, Id> revIdtoOwnerId = new Map<Id, Id>();
        for (Review__c rev : reviews) {
            revIdtoOwnerId.put(rev.id, rev.ownerId);
        }
        List<Task> taskList = [SELECT id, Ownerid, Status, Whatid FROM
                               Task where Status  in ('Not Started', 'In Progress') AND Type = 'Review'
                                       AND Whatid = :revIdtoOwnerId.keySet() AND OwnerId = :revIdtoOwnerId.values()];

        for (Task task : taskList) {
            task.status = 'Completed';
        }
        update taskList;
    }
    private void calculateReviewStepScore() {
        Map<Id, Review__c> oldReviews = (Map<Id, Review__c>)trigger.oldMap;
        Map<Id, Review__c> newReviews = (Map<Id, Review__c>)trigger.newMap;
        Map<Id, Integer> reviewScore = new Map<Id, Integer>();
        system.debug('---calculateReviewStepScore---');
        User currentUser = [SELECT Id, AccountNameFormulaField__c FROM User WHERE Id = :UserInfo.getUserId()];
        for (Review__c review : oldReviews.values() ) {
            system.debug('---calculateReviewStepScore-1001--' + newReviews.get(review.id).status__c);
            system.debug('---calculateReviewStepScore-1221--' + newReviews.get(review.id).summaryScore__c);
            system.debug('---calculateReviewStepScore-1331--' + review.SummaryScore__c);
            // if(newReviews.get(review.id).status__c == 'Review Completed' && newReviews.get(review.id).summaryScore__c != review.SummaryScore__c ){
            if (newReviews.get(review.id).status__c == 'Review Completed' && currentUser.AccountNameFormulaField__c != 'USBE') {

                if (review.rating__c != null)
                    reviewScore.put(review.id, Integer.ValueOf(review.rating__c));
                else
                    reviewScore.put(review.id, 0);
                system.debug('---calculateReviewStepScore-111--');
            }
        }
        system.debug('---calculateReviewStepScore-222---reviewScore---' + reviewScore);
        if (reviewScore != null && reviewScore.size () > 0) {
            updateReviewStepScore(trigger.newMap.keySet(), reviewScore);
        }
    }
    @future
    private static void updateReviewStepScore(Set<Id> reviewIds, Map<Id, Integer> reviewScore) {
        system.debug('---updateReviewStepScore-22234--reviewScore---' + reviewScore);
        Map<Id, Decimal> reviewStepTotal = new Map<Id, Decimal>();
        Set<Id> appPreAppIds = new Set<Id>();
        Set<Id> reviewStepids = new Set<Id>();
        Map<Id, List<Review__c>> appIdToRevIdList = new Map<Id, List<Review__c>>();


        List<Review__c> reviews = [select Application__c, PreApplication__c, SummaryScore__c, Rating__c,
                                   ReviewPanel__r.ReviewStep__c from Review__c where id in :reviewIds ];

        for (Review__c review : reviews) {
            if (!reviewStepids.contains(review.ReviewPanel__r.ReviewStep__c)) {
                reviewStepids.add(review.ReviewPanel__r.ReviewStep__c);
            }
            if (review.Application__c != null) {
                appPreAppIds.add(review.Application__c);
            } else {
                appPreAppIds.add(review.PreApplication__c);
            }
        }

        List<Review__c> rLst = [Select Application__c, PreApplication__c, SummaryScore__c, Rating__c, Status__c, ReviewAcceptanceStatus__c, ReviewPanel__r.ReviewStep__c, SMETotalPoints__c from Review__c where ReviewStep__c IN :reviewStepids AND (Application__c in :appPreAppIds OR PreApplication__c in :appPreAppIds)];
        //List<Review__c> rLstSME = [Select Application__c,PreApplication__c,SummaryScore__c,Rating__c,Status__c,ReviewAcceptanceStatus__c, ReviewPanel__r.ReviewStep__c, SMETotalPoints__c from Review__c where ReviewStep__r.Name = 'SME Review' AND (Application__c in :appPreAppIds OR PreApplication__c in :appPreAppIds)];
        //List<ReviewStepApplication__c> reviewStepAppSME = [SELECT Id, TotalScore__c, ReviewStepNameFormula__c FROM ReviewStepApplication__c WHERE ReviewStepNameFormula__c = 'SME Review' AND (Application__c in :appPreAppIds OR PreApplication__c in :appPreAppIds)];
        for (Review__c review : rLst) {
            system.debug('---updateReviewStepScore-1232--review ---' + review );
            if (review.Application__c != null) {
                List<Review__c> revId = appIdToRevIdList.get(review.Application__c);
                if (revId == null) {
                    revId = new List<Review__c>();
                }
                revId.add(review);
                appIdToRevIdList.put(review.Application__c, revId);
            } else {
                List<Review__c> revId = appIdToRevIdList.get(review.PreApplication__c);
                if (revId == null) {
                    revId = new List<Review__c>();
                }
                revId.add(review);
                appIdToRevIdList.put(review.PreApplication__c, revId);
            }
        }
        if (reviewStepids.size() > 0) {
            String query = 'Select ';
            query += 'id,TotalScore__c,ReviewStep__c,Application__c,PreApplication__c,ReviewStepNameFormula__c,NumberOfReviews__c from ReviewStepApplication__c where ReviewStep__c = :reviewStepids and (Application__c in :appPreAppIds OR PreApplication__c in :appPreAppIds) FOR UPDATE';
            List<ReviewStepApplication__c> revStepApp = Database.query(query);
            //List<ReviewStepApplication__c> updatedRevStepApp = new List<ReviewStepApplication__c>();
            Decimal Score = 0;
            if (revStepApp.size() > 0) {
                for (ReviewStepApplication__c revStep : revStepApp) {
                    system.debug('---updateReviewStepScore-12332--revStep ---' + revStep );
                    if (revStep.ReviewStepNameFormula__c == 'SME Review' ) {
                        revStep.totalScore__c = 0;
                    }
                    List<Review__c> revList = new List<Review__c>();
                    if (revStep.Application__c != null) {
                        revList = appIdToRevIdList.get(revStep.Application__c);
                    } else {
                        revList = appIdToRevIdList.get(revStep.PreApplication__c);
                    }
                    //Decimal total = 0;
                    for (Review__c rev : revList ) {
                        system.debug('---updateReviewStepScore-12332--rev ---' + rev );
                        Integer oldScore = reviewScore.get(rev.id);
                        if (rev.Rating__c != null) {
                            if (oldScore == null) {
                                oldScore = 0;
                            }
                            system.debug('------revStep.totalScore__c--' + revStep.totalScore__c);
                            system.debug('--oldScore--' + oldScore);
                            system.debug('--rev.Rating__c---' + rev.Rating__c);
                            if (rev.Status__c == 'Review Completed' && rev.ReviewAcceptanceStatus__c == 'Accepted') {
                                if (revStep.ReviewStepNameFormula__c == 'SME Review' && rev.SMETotalPoints__c != null ) {
                                    revStep.totalScore__c = revStep.totalScore__c + (Decimal)rev.SMETotalPoints__c;
                                    //total += rev.SMETotalPoints__c ;
                                }
                                //else{
                                //revStep.totalScore__c = revStep.totalScore__c + Integer.valueOf(rev.Rating__c);
                                //total += rev.SMETotalPoints__c ;
                                //}
                            }
                            //revStep.totalScore__c -=oldScore;
                            // total=revStep.SumTotal__c;
                        }
                    }
                    //revStep.TotalScore__c = total;
                }
                system.debug('---revStepApp---after scoring---' + revStepApp);
                update revStepApp;


                //Update the fields required for the Average Score in the Management Review step to sync up right with the SME Review's Average Score
                /*List<ReviewStepApplication__c> reviewStepAppSME = [SELECT Id, TotalScore__c, NumberOfReviews__c, ReviewStepNameFormula__c FROM ReviewStepApplication__c WHERE ReviewStepNameFormula__c = 'SME Review' AND (Application__c in :appPreAppIds OR PreApplication__c in :appPreAppIds)];
                List<ReviewStepApplication__c> reviewStepAppMReview = [SELECT Id, TotalScore__c, NumberOfSMEReviews__c, ReviewStepNameFormula__c FROM ReviewStepApplication__c WHERE ReviewStepNameFormula__c = 'Management Review' AND (Application__c in :appPreAppIds OR PreApplication__c in :appPreAppIds)];
                System.debug('MANUALDEBUG >> reviewStepAppSME: ' + reviewStepAppSME);
                System.debug('MANUALDEBUG >> reviewStepAppMReview: ' + reviewStepAppMReview);
                if (reviewStepAppMReview != null) {
                    for (ReviewStepApplication__c managementReviewIterator : reviewStepAppMReview) {
                        managementReviewIterator.TotalScore__c = reviewStepAppSME[0].TotalScore__c;
                        managementReviewIterator.NumberOfSMEReviews__c = reviewStepAppSME[0].NumberOfReviews__c;
                    }
                }
                update reviewStepAppMReview;*/


                List<ReviewStepApplication__c> rsaList = [Select ApplicationRank__c, Application__c, PreApplication__c, ReviewStep__c, TotalScore__c, NumberOfReviews__c From ReviewStepApplication__c
                        Where Id IN : revStepApp Order by TotalScore__c DESC NULLS LAST];
                Integer rankCounter = 1;
                Set<Id> appIdSet = new Set<Id>();
                Set<Id> preAppIdSet = new Set<Id>();
                Set<Id> revStepIdSet = new Set<Id>();

                system.debug('--- rsaList---' + rsaList);

                for (ReviewStepApplication__c rsa : rsaList) {
                    if (rsa.Application__c != null) {
                        appIdSet.add(rsa.Application__c);
                    } else {
                        preAppIdSet.add(rsa.PreApplication__c);
                    }
                    revStepIdSet.add(rsa.ReviewStep__c);
                }

                List<Review__c> revList = [Select id, ReviewPanel__r.ReviewStep__c, Application__c, PreApplication__c, ReviewAcceptanceStatus__c, Status__c From Review__c where ReviewPanel__r.ReviewStep__c
                                           IN : revStepIdSet and
                                           (Application__c in :appIdSet OR
                                            PreApplication__c in :preAppIdSet)];

                Map<Id, Integer> rsaIdToReviewCount = new Map<Id, Integer>();
                system.debug('---revList---' + revList);
                for (ReviewStepApplication__c rsa : rsaList) {
                    Integer revCount = 0;

                    for (Review__c rev : revList) {
                        if (rev.ReviewPanel__r.ReviewStep__c == rsa.ReviewStep__c) {
                            if (rev.Application__c == rsa.Application__c) {
                                if (rev.Status__c == 'Review Completed' && rev.ReviewAcceptanceStatus__c == 'Accepted') {
                                    revCount++;
                                    rsaIdToReviewCount.put(rsa.Id, revCount);
                                } else {
                                    rsaIdToReviewCount.put(rsa.Id, revCount);
                                }
                            } else if (rev.PreApplication__c == rsa.PreApplication__c) {
                                if (rev.Status__c == 'Review Completed' && rev.ReviewAcceptanceStatus__c == 'Accepted') {
                                    revCount++;
                                    rsaIdToReviewCount.put(rsa.Id, revCount);
                                } else {
                                    rsaIdToReviewCount.put(rsa.Id, revCount);
                                }
                            }
                        }
                    }
                }

                system.debug('---revStepApp---rsaIdToReviewCount--' + rsaIdToReviewCount);



                List<ReviewStepApplication__c> newRsaList1 = [Select ApplicationRank__c, Application__c, PreApplication__c, ReviewStep__c, TotalScore__c, AverageScore__c, NumberOfReviews__c From ReviewStepApplication__c
                        Where ReviewStep__c IN : revStepIdSet Order by TotalScore__c DESC NULLS LAST];

                if (newRsaList1.size() > 0) {
                    for (ReviewStepApplication__c rsa : newRsaList1) {
                        if (rsaIdToReviewCount.get(rsa.Id) != null) {

                            rsa.NumberOfReviews__c = rsaIdToReviewCount.get(rsa.Id);
                            System.debug('------------' + rsa.NumberOfReviews__c);
                        }
                    }
                    update newRsaList1;
                }

                system.debug('**Application Ranking Formula**');

                List<ReviewStepApplication__c> newRsaList = [Select ApplicationRank__c, Application__c, Application__r.RequestedAmount__c, Application__r.Announcement__r.AwardFloor__c, ReviewStep__r.StepNumber__c, PreApplication__c, ReviewStep__c, TotalScore__c, AverageScore__c, NumberOfReviews__c From ReviewStepApplication__c
                        Where ReviewStep__c IN : revStepIdSet Order by AverageScore__c DESC NULLS LAST];

                system.debug('--newRsaList--' + newRsaList);
                List<Application__c> appList = new List<Application__c>();
                if (newRsaList.size() > 0) {
                    ReviewStepApplication__c oldRsa;
                    for (ReviewStepApplication__c rsa : newRsaList) {
                        system.debug('--rsa--' + rsa);

                        if ( oldRsa != null && oldRsa.AverageScore__c != rsa.AverageScore__c) {
                            rankCounter = rankCounter + 1;
                            system.debug('--rankCounter--' + rankCounter);
                        }
                        rsa.ApplicationRank__c = rankCounter;
                        /*    if(rsaIdToReviewCount.get(rsa.Id)!=null)
                            rsa.NumberOfReviews__c = rsaIdToReviewCount.get(rsa.Id);
                        */
                        oldRsa = rsa;
                        system.debug('--rsa.NumberOfReviews__c--' + rsa.NumberOfReviews__c);
                        system.debug('--rsa.ApplicationRank__c--' + rsa.ApplicationRank__c);
                        system.debug('--rsa.totalScore__c-' + rsa.totalScore__c);
                        system.debug('--rsa.averageScore__c-' + rsa.averageScore__c);
                        Application__c app = new Application__c(Id = rsa.Application__c);
                        app.ApplicationRank__c = rsa.ApplicationRank__c;
                        app.TotalScore__c = rsa.TotalScore__c;
                        app.NumberOfReviews__c = rsa.NumberOfReviews__c;
                        if (rsa.NumberOfReviews__c != null && rsa.NumberOfReviews__c > 0 && rsa.totalScore__c != null && rsa.totalScore__c > 0) {
                            app.AverageScore__c = rsa.totalScore__c / rsa.NumberOfReviews__c;
                        }
                        if (rsa.ReviewStep__r.StepNumber__c == 2 && rsa.AverageScore__c != null && rsa.AverageScore__c > 0) {
                            //app.SMERecAmount__c=Math.max((rsa.AverageScore__c/10)*rsa.Application__r.RequestedAmount__c,rsa.Application__r.Announcement__r.AwardFloor__c);
                            app.SMERecAmount__c = (rsa.AverageScore__c / 10) * rsa.Application__r.RequestedAmount__c;
                        } else if (rsa.ReviewStep__r.StepNumber__c == 3) {

                        }

                        appList.add(app);
                        system.debug('--app rating etc--' + app);


                    }


                    update newRsaList;
                    update appList;
                }
            }
        }
    }
    private void initializeReviewComments(List <Review__c> ReviewList){
        for (Review__c review : ReviewList){
            review.Comments__c = '';
        }
    }
    private void updateApplicationsReviewersCount(Set<Id> reviewIds) {
        List<Review__c> reviews = [select Id, PanelUser__c, PanelUser__r.NoOfApplicationsAssigned__c, PanelApplication__c, PanelApplication__r.NoOfReviewersAssigned__c FROM Review__c where Id in: reviewIds];
        Map<Id, Integer> panelUsersCountMap = new Map<Id, Integer>();
        Map<Id, Integer> panelApplicationsCountMap = new Map<Id, Integer>();
        for (Review__c review : reviews) {
            panelUsersCountMap.put(review.PanelUser__c, Integer.valueOf(review.PanelUser__r.NoOfApplicationsAssigned__c));
            panelApplicationsCountMap.put(review.PanelApplication__c, Integer.valueOf(review.PanelApplication__r.NoOfReviewersAssigned__c));
        }
        for (Review__c review : reviews) {
            if (panelUsersCountMap.keyset().contains(review.PanelUser__c)) {
                panelUsersCountMap.put(review.PanelUser__c, panelUsersCountMap.get(review.PanelUser__c) - 1);
            }
            if (panelApplicationsCountMap.keySet().contains(review.PanelApplication__c)) {
                panelApplicationsCountMap.put(review.PanelApplication__c, panelApplicationsCountMap.get(review.PanelApplication__c) - 1);
            }
        }
        system.debug('panelUsersCountMap: ' + panelUsersCountMap);
        system.debug('panelAppsCountMap: ' + panelApplicationsCountMap);
        List<PanelUser__c> panelUsers = new List<PanelUser__c>();
        List<PanelApplication__c> panelApplications = new List<PanelApplication__c>();
        for (Id panelUserId : panelUsersCountMap.keySet()) {
            PanelUser__c pUser = new PanelUser__c(id = panelUserId, NoOfApplicationsAssigned__c = panelUsersCountMap.get(panelUserId));
            panelUsers.add(pUser);
        }
        for (Id panelApplicationId : panelApplicationsCountMap.keySet()) {
            PanelApplication__c pApp = new PanelApplication__c(id = panelApplicationId, NoOfReviewersAssigned__c = panelApplicationsCountMap.get(panelApplicationId));
            panelApplications.add(pApp);
        }
        update panelUsers;
        update panelApplications;
    }
    public override void processAfterDelete() {
        if (!skipTrigger) {
            if (skipFuture == false) {
                deleteReviewTask(trigger.oldMap.keySet());
            }
        }
        UpdateNoofReviews(Trigger.old);
    }
    /* Delete task associated with the Review */
    private void deleteReviewTask(Set<Id> reviewId) {
        List<Task> taskList = [select id from Task where WhatId in : reviewId AND Type = 'Review'];
        delete taskList;
    }


    private void updateOneStepComments(List<Review__c> triggerList) {
        Set<Id> AppIds = new Set<id>();
        for (Review__c reviewIterator : triggerList) {
            AppIds.add(reviewIterator.Application__c);
        }
        Map<Id, Application__c> App = new Map<Id, Application__c>([SELECT Id, GrantorOrganizationName__c FROM Application__c WHERE Id in :AppIds]);
        Map<Id, String> appIdMapComment = new Map<Id, String>();
        for (Review__c reviewIterator : triggerList) {
            //If USBE application
            if (App.get(reviewIterator.Application__c).GrantorOrganizationName__c == 'USBE' && reviewIterator.ReviewStepNameFormula__c == 'Pre-Screen Review') {
                if (reviewIterator.Application__c != null) {
                    reviewIterator.AggregatedPreScreenCommentsUSBE__c = 'Elegibility Comments: ' + reviewIterator.ElegibilityPreScreenComments__c + '<br><br>Application Completion Comments: ' + reviewIterator.CompletionPreScreenComments__c + '<br><br>Attachments Comments: ' + reviewIterator.CompletionAttachmentComments__c + '<br><br>Budget Comments: ' + reviewIterator.BudgetPreScreenComments__c + '<br><br>Planned Costs Comments: ' + reviewIterator.BudgetPlannedCostsComments__c + '<br><br>Program Scope Comments: ' + reviewIterator.ScopePreScreenComments__c + '<br><br>Program Requirements Comments: ' + reviewIterator.ProgramReqPreScreenComments__c;
                    // + '<br><br>Overall Application Completion Comments: ' + reviewIterator.Comments__c;

                    App.get(reviewIterator.Application__c).AggregatedPreScreenCommentsUSBE__c = reviewIterator.AggregatedPreScreenCommentsUSBE__c;
                    if (String.valueof(reviewIterator.AggregatedPreScreenCommentsUSBE__c).length()>32768){
                        reviewIterator.addError('Maximum comments size exceded.');
                    }
                }
            }
        }
        update App.values();
    }

}