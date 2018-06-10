/*
    All trigger logic on Review Step Object
    **********************************************************
    Audit History
    **********************************************************
    17/04/2014         Kunal Shah            Created
    05/06/2014         Vineeth               Added allowUniqueReviewSteps method
    05/12/2014         Vineeth               Added CreateTaskForFinalApprover method
    12-Nov-2014        Prem Pal              Updated to add review panel templates
    **********************************************************
*/
public with sharing class ReviewStepTriggerHelper extends GNT.TriggerHelper {
    public static boolean skipTrigger = false;
    public override void processBeforeInsert() {
        if (skipTrigger == false) {
            allowUniqueReviewSteps(Trigger.New);
        }
    }

    public override void processAfterInsert() {
        if (skipTrigger == false) {
            createReviewPanels(Trigger.New);
            copyAppPreAppFromParentForStep1(Trigger.New);
        }
    }


    public override void processAfterUpdate() {
        if (skipTrigger == false) {
            UpdateFDMStatus();
        }
    }


    /*
        Method: allowUniqueReviewSteps
        Purpose: Prevents duplicate Review Steps be added to the same Review Group. Duplicate means that review steps should have unique step numbers.
    */
    private void allowUniqueReviewSteps(List<ReviewStep__c> reviewStepList) {

        //Set to store the list of Review Group Ids from incoming review steps
        Set<Id> reviewStepGroupIds = new Set<Id>();

        //Iterate over all incoming review steps and get their corresponding review group ids. Add those ids to the set.
        for (ReviewStep__c reviewStepInstance : reviewStepList) {
            reviewStepGroupIds.add(reviewStepInstance.ReviewGroup__c);
        }


        //Declare a Map (Key -> Review Group Id, Value -> Set of Review Step Numbers associated to the Group)
        Map<Id, Set<decimal>> reviewGroupStepMap = new Map<Id, Set<decimal>>();

        //Insert - If Trigger.new add the Review Step only if review step number does not already exists for that Group.

        for (ReviewStep__c reviewStepInstance : reviewStepList) {

            Set<decimal> reviewStepNumberSet = reviewGroupStepMap.get(reviewStepInstance.ReviewGroup__c);
            if (reviewStepNumberSet == null) {
                reviewStepNumberSet = new Set<Decimal>();
            }

            //If the same Step Number exists in the Group dont insert
            if (reviewStepNumberSet != null && reviewStepNumberSet.contains(reviewStepInstance.StepNumber__c)) {
                //reviewStepInstance.addError('Duplicate Review Step for the same Review Group not Allowed.');
                reviewStepInstance.addError(GNT.ErrorMessageHelper.fetchMessage('M01-GRNTR-82385'));
            }
            reviewStepNumberSet.add(reviewStepInstance.StepNumber__c);
            reviewGroupStepMap.put(reviewStepInstance.ReviewGroup__c, reviewStepNumberSet);


        }

    }
    /*
        Method:  createReviewPanels
        Purpose: Insert review panel templates for review steps
    */
    private void createReviewPanels(List<ReviewStep__c> reviewStepList) {

        Set<Id> reviewStepTemplateIdsSet = new Set<Id>();
        for (ReviewStep__c reviewStepInstance : reviewStepList) {
            reviewStepTemplateIdsSet.add(reviewStepInstance.ReviewStepTemplate__c);
        }

        //Fetch all review step templates
        Map<Id, ReviewStepTemplate__c> rstMap = new Map<Id, ReviewStepTemplate__c>([SELECT Id, Name, RecordTypeId,
                (SELECT Id, GroupId__c, GroupName__c, RecordTypeId, Chair__c, AutoAssignSubmittedApplication__c,
                 Sequence__c, ReviewPackage__c, Name, IsDefaultPanel__c, Description__c , UserType__c , PanelLayout__c, Purpose__c,
                 ExcludeFromScoring__c, EndDate__c, ReviewStepTemplate__r.StepNumber__c, TaskDueDate__c, DueDateOffset__c, ReviewerAssignNotificationTemplate__c
                 FROM ReviewStepTemplate__c.Review_Panel_Templates__r)
                FROM ReviewStepTemplate__c
                WHERE Id IN :reviewStepTemplateIdsSet]);

        //Get the record type ids for Review Step
        Id rsRecTypeIdApp = Schema.SObjectType.ReviewStep__c.getRecordTypeInfosByName().get('Application').getRecordTypeId();
        Id rsRecTypeIdPreApp = Schema.SObjectType.ReviewStep__c.getRecordTypeInfosByName().get('Pre-Application').getRecordTypeId();

        //Get the record type ids for Review Panel Template
        Id rptRecTypeIdApp = Schema.SObjectType.ReviewPanelTemplate__c.getRecordTypeInfosByName().get('Application').getRecordTypeId();
        Id rptRecTypeIdPreApp = Schema.SObjectType.ReviewPanelTemplate__c.getRecordTypeInfosByName().get('Pre-Application').getRecordTypeId();

        //Get the record type ids for Review Panel Template
        Id rpRecTypeIdApp = Schema.SObjectType.ReviewPanel__c.getRecordTypeInfosByName().get('Application').getRecordTypeId();
        Id rpRecTypeIdPreApp = Schema.SObjectType.ReviewPanel__c.getRecordTypeInfosByName().get('Pre-Application').getRecordTypeId();

        List<ReviewPanel__c> rpList = new List<ReviewPanel__c>();
        for (ReviewStep__c reviewStepInstance : reviewStepList) {
            ReviewStepTemplate__c rst = rstMap.get(reviewStepInstance.ReviewStepTemplate__c);
            if (rst != null && rst.Review_Panel_Templates__r != null) {
                List<ReviewPanelTemplate__c> rptList = rst.Review_Panel_Templates__r;

                for (ReviewPanelTemplate__c rpt : rptList) {
                    ReviewPanel__c reviewPanel = new ReviewPanel__c();
                    Boolean createReviewPanel = false;

                    if (reviewStepInstance.RecordTypeId == rsRecTypeIdApp && rpt.RecordTypeId == rptRecTypeIdApp) {
                        reviewPanel.RecordTypeId =  rpRecTypeIdApp;
                        createReviewPanel = true;
                    } else if (reviewStepInstance.RecordTypeId == rsRecTypeIdPreApp && rpt.RecordTypeId == rptRecTypeIdPreApp) {
                        reviewPanel.RecordTypeId =  rpRecTypeIdPreApp;
                        createReviewPanel = true;
                    }
                    if (createReviewPanel == true) {
                        reviewPanel.ReviewStep__c = reviewStepInstance.id;
                        reviewPanel.Chair__c = rpt.Chair__c;
                        reviewPanel.GroupId__c = rpt.GroupId__c;
                        reviewPanel.GroupName__c = rpt.GroupName__c;
                        reviewPanel.Sequence__c = rpt.Sequence__c;
                        reviewPanel.IsDefaultPanel__c = rpt.IsDefaultPanel__c;
                        reviewPanel.ReviewPackage__c = rpt.ReviewPackage__c;
                        reviewPanel.AutoAssignSubmittedApplication__c = rpt.AutoAssignSubmittedApplication__c;
                        reviewPanel.PanelName__c = rpt.Name;
                        reviewPanel.UserType__c = rpt.UserType__c;
                        reviewPanel.purpose__c = rpt.Description__c;
                        // reviewPanel.ReviewFormConfig__c = rpt.ReviewFormConfig__c;
                        reviewPanel.ReviewPanelTemplate__c = rpt.Id;
                        reviewPanel.PanelLayout__c = rpt.PanelLayout__c;
                        reviewPanel.ExcludeFromScoring__c = rpt.ExcludeFromScoring__c;
                        reviewPanel.TaskDueDate__c = rpt.TaskDueDate__c;
                        reviewPanel.DueDateOffset__c = rpt.DueDateOffset__c;
                        if (rpt.ReviewStepTemplate__r.StepNumber__c == 1)
                            reviewPanel.EndDate__c = rpt.EndDate__c;
                        //  reviewPanel.Purpose__c = rpt.Purpose__c;
                        reviewPanel.ReviewerAssignNotificationTemplate__c = rpt.ReviewerAssignNotificationTemplate__c;
                        rpList.add(reviewPanel);
                    }
                }
            }
        }
        //Insert the new Review Step panels
        if (rpList.size() > 0) {
            insert rpList;
        }
    }

    /*
        Method: copyAppPreAppFromParentForStep1
        Purpose: To copy all the applications and pre-applications from respective group to the 1st step &
                    Insert Review Step Application record for each application
    */
    public void copyAppPreAppFromParentForStep1(List<ReviewStep__c> newReviewStepList) {

        System.debug('**copyAppPreAppFromParentForStep1..');

        //Declare 2 review steps, one for record type Application & one for Pre-Application
        List<ReviewStep__c> rsAppList = new List<ReviewStep__c>();
        List<ReviewStep__c> rsPreAppList = new List<ReviewStep__c>();

        Set<Id> rsAppAnnouncementsSet = new Set<Id>();
        Set<Id> rsPreAppAnnouncementSet = new Set<Id>();

        Id rsAppRecTypeId = Schema.SObjectType.ReviewStep__c.getRecordTypeInfosByName().get('Application').getRecordTypeId();

        Id rsPreAppRecTypeId = Schema.SObjectType.ReviewStep__c.getRecordTypeInfosByName().get('Pre-Application').getRecordTypeId();

        Map<Id, ReviewStep__c> rsMap = new Map<Id, ReviewStep__c>([SELECT Id, ReviewGroup__r.Announcement__r.Program__r.ReviewProcess__c FROM ReviewStep__c WHERE Id IN :newReviewStepList]);

        //From incoming list get the Review Step with step number 1(one for record type Application & one for Pre-Application)
        for (ReviewStep__c rs : newReviewStepList) {
            if (rsMap.get(rs.Id).ReviewGroup__r.Announcement__r.Program__r.ReviewProcess__c != 'One step review') {
                if (rs.StepNumber__c == 1 && rs.RecordTypeId == rsAppRecTypeId) {
                    rsAppList.add(rs);
                    rsAppAnnouncementsSet.add(rs.AnnouncementId__c);
                } else if (rs.StepNumber__c == 1 && rs.RecordTypeId == rsPreAppRecTypeId) {
                    rsPreAppList.add(rs);
                    rsPreAppAnnouncementSet.add(rs.AnnouncementId__c);
                }
            }
        }
        //Declare a holder for Review Step Applications
        List<ReviewStepApplication__c> stepApplications = new List<ReviewStepApplication__c>();
        system.debug('rsAppAnnouncementsSet----' + rsAppAnnouncementsSet);
        system.debug('rsAppList----' + rsAppList);
        //Process Applications
        // Removing check on Submittedon field. It was breaking the flow -- AND SubmittedOn__c != null
        List<Application__c> announcementApps = new List<Application__c>();
        Id appRecTypeId = Schema.SObjectType.ReviewStepApplication__c.getRecordTypeInfosByName().get('Application').getRecordTypeId();
        if (rsAppList.size() > 0) {
            for (Application__c app : [SELECT ID, Announcement__c, SubmittedOn__c, Status__c
                                       FROM Application__c
                                       WHERE Announcement__c IN: rsAppAnnouncementsSet AND SubmittedOn__c != null and Status__c = 'Review Initiated']) {

                for (ReviewStep__c rsApp : rsAppList) {
                    if (rsApp.AnnouncementId__c == app.Announcement__c) {
                        stepApplications.add(new ReviewStepApplication__c(ReviewStep__c = rsApp.Id, Application__c = app.Id, RecordTypeId = appRecTypeId));
                    }
                }
            }
        }

        //Process Pre-Applications
        List<PreApplication__c> announcementPreApps = new List<PreApplication__c>();
        Id preAppRecTypeId = Schema.SObjectType.ReviewStepApplication__c.getRecordTypeInfosByName().get('Pre-Application').getRecordTypeId();

        if (rsPreAppList.size() > 0) {
            for (PreApplication__c preapp : [SELECT ID, Announcement__c, SubmittedOn__c
                                             FROM PreApplication__c
                                             WHERE Announcement__c IN : rsPreAppAnnouncementSet AND SubmittedOn__c != null]) {
                for (ReviewStep__c rsPreApp : rsPreAppList) {
                    if (rsPreApp.AnnouncementId__c == preapp.Announcement__c) {
                        stepApplications.add(new ReviewStepApplication__c(ReviewStep__c = rsPreApp.Id, PreApplication__c = preapp.Id, RecordTypeId = preAppRecTypeId));
                    }
                }
            }
        }


        System.debug('stepApplications----' + stepApplications);
        if (stepApplications.size() > 0) {
            insert stepApplications;
        }
    }

    /*
        METHOD TO UPDATE STATUS OF THE REVIEW STEP
    */
    /*
    private void updateStatus(){
        for(ReviewStep__c step : (List<ReviewStep__c>)Trigger.New){
            //Status = Complete
            if(step.NumberOfApplications__c > 0 && step.NumberOfPendingReviews__c == 0 && step.NumberOfUnassignedApplications__c == 0){
                step.Status__c = 'Complete';
            } else if (step.Status__c != 'Complete' && (step.NumberOfApplications__c > 0 || step.NumberOfReviewers__c > 0)){
                step.Status__c = 'In Progress';
            }
        }
    } */

    /*
       METHOD TO UPDATE STATUS OF THE REVIEW GROUP
    */

    private void updateFDMStatus() {
        system.debug('---updateFDMStatus---');
        Boolean completeFlag = false;
        Id annId;
        Id grpId, revStepId;
        Set<String> pathways = new Set<String>{'Fed-Formula', 'State-Formula', 'Application 1/12th', 'Lump-Sum-App', 'Fed-Competitive'};
        for (ReviewStep__c step : (List<ReviewStep__c>)Trigger.New) {
            //Status = Complete
            system.debug('--step--' + step);
            if (step.Name == 'Funding Decision Memo' && step.LastStep__c == true && step.ReviewApprovalStatus__c == 'Approved' && step.OrganizationName__c == 'UOVC') {
                completeFlag = true;
                revStepId = step.Id;
                break;
            } else if (step.Name == 'Funding Decision Memo'  && step.OrganizationName__c == 'USBE' && !pathways.contains(step.ProgramPathway__c)) {
                completeFlag = true;
                revStepId = step.Id;
                break;
            }
        }
        if (completeFlag) {
            ReviewStep__c revStepObj = [Select Id, Name, ReviewGroup__r.Id, ReviewGroup__r.Announcement__r.Id from ReviewStep__c where id = :revStepId];
            grpId = revStepObj.ReviewGroup__r.Id;
            annId = revStepObj.ReviewGroup__r.Announcement__r.Id;
            ReviewGroup__c revGrp = [Select Id, Name, Status__c from ReviewGroup__c where id = :grpId];
            revGrp.status__c = 'Completed';
            update revGrp;
            List<ReviewStepApplication__c> rsaList = [Select Id, Name from ReviewStepApplication__c where ReviewStep__c = :revStepId and Decision__c = 'Approved'];

            //Announcement__c ann = [Select Id, Name, ApplicationsReviewStatus__c,  from Announcement__c  where id =:annId];
            Announcement__c ann = [Select Id, Name, ApplicationsReviewStatus__c, CurrentReviewStepApprovalStatus__c from Announcement__c  where id = :annId];
            ann.CurrentReviewStepApprovalStatus__c = 'Approved';//FDM Approved so update the status of that in the Announcement
            ann.ApplicationsReviewStatus__c = 'Completed';
            ann.NoOfWinners__c = rsaList != null ? rsaList.size() : 0;
            update ann;

        }
    }
}