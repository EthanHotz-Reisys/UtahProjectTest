/*
    This class has methods to execute methods related to Award Trigger
    **********************************************************
    Audit History
    **********************************************************
    2015-05-19  Ramu Loke      Created
    **********************************************************
*/


global with sharing class USBEAwardTriggerHelper extends GNT.TriggerHelper {

    global static boolean skipTriggers = false;
    public static boolean skipTrigger = false;
    public static boolean skipfromAmendment = false;
    String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
    public class RolesAndRespUSBEException extends Exception {}


    public override void processBeforeInsert() {
        system.debug('I am before insert>>>>');
        if (skipTrigger == false) {
            SetAwardDetails();
            if (appName == 'StateasGrantor') {
                setGrantIdForAward(trigger.new);
                updateAwardLetterAmendment((List<Award__c>)trigger.new);
            }
            checkForUpdatedIndirectBeforeInsert((List<Award__c>)Trigger.New);
            //copyRolesFromGrant((List<Award__c>)Trigger.New);
            GNT.NameTemplateTriggerHelper.beforeInsert();
        }
    }

    public override void processAfterInsert() {
        if (skipTrigger == false && skipfromAmendment == false && skipTriggers == false) {
            if (appName == 'StateasGrantor') {
                system.debug('App name *************** ' + appName);
                copyApplicationBudgetDetails((List<Award__c>)Trigger.New);
                //createAwardGoalsAndObjectives((List<Award__c>)Trigger.New);
                //copyGOfromApplication((List<Award__c>)Trigger.New);
                //BOD
                //createAwardWBSTasks((List<Award__c>)Trigger.New);
                // Moved update address from process after update to after insert- Charan (05/08/2017)
                updateAddress((List<Award__c>)Trigger.new);
            }
            if (appName == 'StateAsGrantee') {
                //createAwardBudgetCategories((List<Award__c>)Trigger.New);
                createGranteeBudgetCategories((List<Award__c>)Trigger.New);
            }
            //updateAmountInGrant((List<Award__c>)Trigger.new);
            //insertOwnerinRolesandResp();
            //Award Enhancement
            //copyRolesfromAnnouncemnt(Trigger.New);
            copyContactsFromAnnouncement((List<Award__c>)Trigger.New);
            CopyKeyPOCToAwardContacts();
            addRoles((List<Award__c>) Trigger.New);
            //BOD
            //createAwardOutcomes((List<Award__c>)Trigger.New);
            decideTermConditionAction(trigger.new);
            copyReportingRequirements(Trigger.New);
            //createPaymentSchedule(Trigger.new);

            System.debug('MANUALDEBUG >>> entering createEmailAndTaskForBudgetRevision');
            createEmailAndTaskForBudgetRevision((List<Award__c>)Trigger.New); //Checks to only do this on applicable awards is in the method
            System.debug('MANUALDEBUG >>> exiting createEmailAndTaskForBudgetRevision');
        }

        if (skipTrigger == false) {
            if (appName == 'StateasGrantor') {
                updateOtherAwardsStatus((List<Award__c>)Trigger.new);
            }
        }
    }

    public override void processBeforeUpdate() {
        System.debug('MANUALDEBUG >>> appName = ' + appName + ', skipTrigger = ' + skipTrigger + ', skipTriggers = ' + skipTriggers);
        //if (appName == 'StateasGrantor' && skipTrigger == false && skipTriggers == false) {
        if (skipTrigger == false && skipTriggers == false) {
            System.debug('MANUALDEBUG >>> inside processBeforeUpdate');
            reviseBudgetForAllocationChange((List<Award__c>) Trigger.old, (List<Award__c>) Trigger.new);
            waiveAllocationUpdate((List<Award__c>) Trigger.old, (List<Award__c>) Trigger.new);
            updateHideApproveButton((List<Award__c>) Trigger.new);
        }
    }

    public override void processAfterupdate() {
        if (skipTrigger == false && skipfromAmendment == false && skipTriggers == false) {
            UpdateLatestAwardOnGrant(trigger.new);
            //UpdatePreviousAwardOnGrant(trigger.new);
            if (appName == 'StateasGrantee') {
                UpdateRemainingAmountinAwardBC((List<Award__c>)Trigger.New);
            }
            //SM
            //updateAmountInGrant((List<Award__c>)Trigger.new);
            decideTermConditionAction(trigger.new);

            //createProposalForPeopleSoft(trigger.new,(Map<Id,Award__c>)trigger.oldMap);
            UpdateBudgetPeriodonAward(trigger.new);
            UpdateGrantStatus(trigger.new);

            rejectPaymentRequests(Trigger.new);
        }
        if (appName != 'StateasGrantee' && skipTrigger == false) {
            // insertGrantConnector((List<Award__c>)Trigger.new);
            // updateAddress((List<Award__c>)Trigger.new);
            updateGrantBudgetOnAwardIssuance((List<Award__c>)Trigger.new, (Map<Id, Award__c>)Trigger.oldMap);
            updateBudgetRevision((List<Award__c>)Trigger.new);
            updateAwardFinetCodeStatus((List<Award__c>)Trigger.new);
            updateOtherAwardsStatus((List<Award__c>)Trigger.new);
            //EH
            SendTaskNotifications(trigger.new);
        }
    }

    public override void processAfterDelete() {
        updateApplication(Trigger.old);
        updateAmendments(Trigger.old);
        //deleteGrant(Trigger.old);
    }

    //update amount data in grant -- Weike 05/18/2017
    /*
    private void updateAmountInGrant(List<Award__c> awards) {
        Set<Id> grantIds = new Set<Id>();
        for (Award__c award : awards) {
            grantIds.add(award.Grant__c);
        }
        Set<Grant__c> updateGrants = new Set<Grant__c>();
        Map<Id, Grant__c> grantMap = new Map<Id, Grant__c>([Select Id, TotalAdjustedAmount__c, CumulativeAwardedAmount__c from Grant__c where Id IN :grantIds]);
        AggregateResult[] groupedResults = [Select Grant__c, SUM(AwardAmountThisAction__c)sumAmount from Award__c where Grant__c IN :grantMap.keySet() GROUP BY Grant__c];

        for (AggregateResult ar : groupedResults) {
            Grant__c grant = grantMap.get(String.valueOf(ar.get('Grant__c')));
            grant.CumulativeAwardedAmount__c = Integer.valueOf(ar.get('sumAmount'));
            updateGrants.add(grant);
        }

        groupedResults = [Select Grant__c, SUM(AwardAmountThisAction__c)sumAmount from Award__c where Grant__c IN :grantMap.keySet() AND PriorAwardedAmount__c != 0 GROUP BY Grant__c];

        for (AggregateResult ar : groupedResults) {
            Grant__c grant = grantMap.get(String.valueOf(ar.get('Grant__c')));
            grant.TotalAdjustedAmount__c = Integer.valueOf(ar.get('sumAmount'));
        }

        List<Grant__c> updatedGrants = new List<Grant__c>(updateGrants);

        update updatedGrants;
    }
    */
    private void updateAwardLetterAmendment(List<Award__c> AwardsList) {
        Map<Id, List<Award__c>> awardMap = new Map<Id, List<Award__c>>();
        Map<Id, Decimal> grantAmendmentMap = new Map<Id, Decimal>();
        List<Award__c> listAwards = new List<Award__c>();
        for (Award__c award : AwardsList) {
            if (!grantAmendmentMap.containsKey(award.grant__c)) {
                System.debug('MANUAL DEBUG1>>>>>>>' + award.AmendmentSequence__c);
                if (award.grant__r.NumberofAwards__c != null)
                    grantAmendmentMap.put(award.grant__c, award.grant__r.NumberofAwards__c);
                else
                    grantAmendmentMap.put(award.grant__c, 0);

            }
        }

        for (Award__c award : AwardsList) {
            Decimal NewAmendment = grantAmendmentMap.get(award.grant__c);
            System.debug('MANUAL DEBUG2>>>>>>>' + NewAmendment);
            award.AmendmentSequence__c = NewAmendment;
        }
    }
    private void setGrantIdForAward(List<Award__c> newAwardsList) {
        List<Grant__c> grantsList  = new List<Grant__c>();
        List<Id> applicationIdList  = new List<Id>();
        for (Award__c award : newAwardsList) {
            applicationIdList.add(award.Application__c);
        }
        Map<Id, Application__c> applicationMap = new Map<Id, Application__c>([SELECT Id, Name, ExternalOrganization__c, Announcement__r.Program__c,
                CurrentBudgetPeriodStartDate__c, ProjectPeriodEndDate__c, ProjectPeriodStartDate__c,
                CurrentBudgetPeriodEndDate__c, ExternalOrganization__r.Name, Title__c, Announcement__r.ApplicationFinalApprover__c, BudgetNarrative__c, Approver__c, IndirectCostPercentage__c, BudgetAllocation__c
                FROM Application__c WHERE Id IN :applicationIdList]);
        //1. Iterate over all incoming awards
        /*
        for (Award__c award : newAwardsList) {
            /* 2. Check if grant is associated with it
                    If yes, this means that award is issued for already exising grant
                    Else, this award is issued for the first time, so create a grant first.
            */
        /*
        if (award.Grant__c == null) {
            Application__c appForAward = applicationMap.get(award.Application__c);
            Grant__c grant = new Grant__c(
                ExternalOrganization__c = appForAward.ExternalOrganization__c,
                //OrganizationName__c=appForAward.ExternalOrganization__r.Name,
                //OrganizationAddress__c=award.OrganizationAddress__c,
                Program__c = appForAward.Announcement__r.Program__c,
                Application__c = appForAward.Id,
                ProjectPeriodEndDate__c = award.ProjectPeriodEndDate__c,
                ProjectPeriodStartDate__c = award.ProjectPeriodStartDate__c,
                //SupportYear__c = award.SupportYear__c,
                ProjectDirector__c = award.ProjectDirector__c,
                GranteePOC__c = award.GranteePOC__c,
                GrantsContact__c = award.GrantsContact__c,
                ProgramsContact__c = award.ProgramsContact__c,
                ProjectTitle__c = appForAward.Title__c,
                Status__c = 'Active',
                BudgetPeriodStartDate__c = award.BudgetPeriodStartDate__c,
                BudgetPeriodEndDate__c = award.BudgetPeriodEndDate__c);

            grantsList.add(grant);
            applicationIdList.add(award.Application__c);

        }
        }
        try {
        if (Schema.sObjectType.Grant__c.isCreateable() && grantsList.size() > 0) {
            insert grantsList;
        }
        } catch (Exception e) {
        System.debug('error inserting grants==== ' + e.getMessage());
        }
        */
        if (applicationIdList != null && applicationIdList.size() > 0) {
            Map<Id, Grant__c> insertedGrants = new Map<Id, Grant__c>([SELECT Id, Application__c FROM Grant__c WHERE Application__c IN :applicationIdList]);
            Map<Id, Id> applicationIdGrantIdMap = new Map<Id, Id>();
            for (Grant__c grant : insertedGrants.values()) {
                applicationIdGrantIdMap.put(grant.Application__c, grant.Id);
            }
            for (Award__c award : newAwardsList) {
                /*
                if (award.Grant__c == null) {
                    award.Grant__c = applicationIdGrantIdMap.get(award.Application__c);
                    award.Status__c = 'In Progress';
                    Application__c appForAward = applicationMap.get(award.Application__c);
                    award.Approver__c = appForAward.Announcement__r.ApplicationFinalApprover__c;
                    //award.IndirectCostPercentageProposed__c = appForAward.IndirectCostPercentage__c;
                }
                */

                if (award.GrantorOrganization__c == 'USBE' && skipfromAmendment == false) { //Only handle the budget narrative if the grantor org is USBE
                    Application__c applicationForAward = applicationMap.get(award.Application__c); //Get the application involved to sync up the budget narratives
                    award.BudgetNarrativeRead__c = DateTime.now() + ' ' + applicationForAward.BudgetNarrative__c;
                    award.BudgetNarrativeWrite__c = '';
                    //award.BudgetNarrativeWrite__c = applicationForAward.BudgetNarrative__c;
                    award.Approver__c = applicationForAward.Approver__c;
                    award.IndirectCostPercentage__c = applicationForAward.IndirectCostPercentage__c;
                    award.IndirectCostPercentageProposed__c = applicationForAward.IndirectCostPercentage__c;
                    award.AllocatedAmount__c = applicationForAward.BudgetAllocation__c;
                    award.WaiveAllocationStatus__c = 'N/A';
                }
            }
            //checkForUpdatedIndirectBeforeInsert(newAwardsList);
        }
    }

    private void updateHideApproveButton(List<Award__c> awardList) {
        for (Award__c award : awardList) {
            if (award.Status__c == 'Created') {
                award.HideApproveButton__c = false;
            }
        }
    }

    /*Update Grant with Latest Award*/

    private void UpdateLatestAwardOnGrant(List<Award__c> awardList) {
        /*
        Integer i = 0;
        String awardid;
        String awardname;
        String totawardedamount;
        String totobligatedamount;
        String totremainingamount;
        String cumulativeawardedamount;
        List<Id> listIds = new List<Id>();
        for (Award__c childObj : awards) {
            listIds.add(childObj.Grant__c);
        }
        List<Grant__c> result = [select Id, (select Id , name, TotalGrantAwardAmount__c, TotalObligateAmount__c, RemainingObligatedAmount__c, AwardNumber__c, CurrentApprovedBudgetSum__c
                                             from Awards__r where Status__c IN('Being Amended', 'Activated') order by CreatedDate desc)
                                 from Grant__c WHERE ID IN :listIds];
        system.debug('*** result' + result);
        for (Grant__c grant : result) {
            List<Award__c> childAwards = result[0].Awards__r;
            for (Award__c indAward : childAwards) {
                if (i <= childAwards.size()) {
                    awardid = indAward.id;
                    awardname = indAward.Name;
                    cumulativeawardedamount = string.valueof((indAward.CurrentApprovedBudgetSum__c).setScale(2));
                    //totawardedamount = string.valueof(indAward.TotalGrantAwardAmount__c);
                    //totobligatedamount = string.valueof(indAward.TotalObligateAmount__c);
                    //totremainingamount = string.valueof(indAward.RemainingObligatedAmount__c);
                    i = i + 1;
                }
            }
            if (awardid <> null || awardname <> null || totawardedamount <> null || totobligatedamount <> null || totremainingamount <> null || cumulativeawardedamount <> null) {
                grant.LatestAwardId__c = awardid;
                grant.CurrentAward__c = awardid;
                grant.LatestAwardName__c = awardname;
                grant.CumulativeAwardedAmount__c = Decimal.valueOf(cumulativeawardedamount);
                //grant.LatestAwardTotalAwardedAmount__c = Decimal.valueOf(totawardedamount);
                //grant.TotalObligatedAmount__c = Decimal.valueOf(totobligatedamount);
                //grant.TotalRemainingAmount__c = Decimal.valueOf(totremainingamount);
            }
        }

        if (result != null && result.size() > 0) update result;
        */
        List<Id> grantIdList = new List<Id>();

        for (Award__c award : awardList) {
            grantIdList.add(award.Grant__c);
        }

        List<Grant__c> grantList = [SELECT Id, LatestAwardId__c, CurrentAward__c, LatestAwardName__c, CumulativeAwardedAmount__c,
                                    (SELECT Id, Name, CurrentApprovedBudgetSum__c
                                     FROM Awards__r WHERE Status__c = 'Activated' ORDER BY CreatedDate DESC)
                                    FROM Grant__c WHERE ID IN :grantIdList];

        for (Grant__c grant : grantList) {
            List<Award__c> childAwards = grant.Awards__r;
            if (childAwards != null && childAwards.size() != 0) {
                Award__c award = childAwards[0];
                grant.LatestAwardId__c = childAwards[0].Id;
                grant.CurrentAward__c = childAwards[0].Id;
                grant.LatestAwardName__c = childAwards[0].Name;
                grant.CumulativeAwardedAmount__c = Decimal.valueOf(String.valueof((childAwards[0].CurrentApprovedBudgetSum__c).setScale(2)));
            }
        }

        if (grantList != null && grantList.size() > 0) update grantList;
    }

    private void UpdateGrantStatus(List<Award__c> awards) {
        List<Id> listIds = new List<Id>();
        for (Award__c childObj : awards) {
            listIds.add(childObj.Grant__c);
        }
        List<Grant__c> grantslist = [select Id, (select Id, name, Status__c from Awards__r) from Grant__c WHERE ID IN :listIds];
        for (Grant__c grant : grantslist) {
            List<Award__c> childAwards = grantslist[0].Awards__r;
            for (Award__c award : childAwards) {

                if (award.Status__c == 'Rejected')  grant.Status__c = 'Closed/Completed';
            }
        }
        update grantslist;
    }

    private void rejectPaymentRequests(List<Award__c> awardList) {
        Set<Id> awardIds = new Set<Id>();
        Set<Id> paymentIds = new Set<Id>();
        for (Award__c award : awardList) {
            Award__c awardOld = (Award__c) Trigger.OldMap.get(award.Id);
            if (award.CurrentRevisionStatus__c == 'Created' && awardOld.CurrentRevisionStatus__c != 'Created') {
                awardIds.add(award.Id);
            }
        }

        List<PaymentRequest__c> paymentList = [SELECT Id FROM PaymentRequest__c WHERE Award__c IN: awardIds AND Status__c != 'Approved' AND Status__c != 'Paid'];
        for (PaymentRequest__c payment : paymentList) {
            paymentIds.add(payment.Id);
        }

        SystemContextMethodsHelper helper = new SystemContextMethodsHelper();
        helper.closePaymentProcesses(paymentIds);
        for (PaymentRequest__c payment : paymentList) {
            payment.Status__c = 'Rejected';
        }
        update paymentList;
    }

    /*Update Previous Award when Current Award is in Activated*/
    //private void UpdatePreviousAwardOnGrant(List<Award__c> awards) {
    //    List<Id> listIds = new List<Id>();
    //    for (Award__c childObj : awards) {
    //        listIds.add(childObj.Grant__c);
    //    }
    //    List<Award__c> awardlist = [select id, AwardNumber__c, Status__c from Award__c where Grant__c IN:listIds Order by AwardNumber__c DESC];
    //    List<Award__c> previouslist = new List<Award__c>();
    //    for (Award__c awd : awards) {
    //        if (awd.Status__c == 'Activated' && awardlist.size() > 1) {
    //            awardlist[1].Status__c = 'Amended';
    //            previouslist.add(awardlist[1]);
    //        }
    //    }
    //    update previouslist;
    //}

    /*Update Budget Period status on Grant*/

    private void UpdateBudgetPeriodonAward(List<Award__c> awards) {
        /*List<BudgetPeriod__c> budgetperiodlist = new List<BudgetPeriod__c>();
        List<Id> listids = new List<Id>();
        for (Award__c award : awards) {
            listids.add(award.BudgetPeriod__c);
        }
        budgetperiodlist = [SELECT id,Name,Status__c,(SELECT ID,Status__c FROM Awards__r) FROM BudgetPeriod__c WHERE ID IN :listIds];
        for (BudgetPeriod__c budgetperiod : budgetperiodlist){
            List<Award__c> childAwards=budgetperiodlist[0].Awards__r;
            for (Award__c awd: childAwards){
                if(awd.Status__c == 'Activated'){
                budgetperiod.Status__c = 'Active';
              }
           }
        }
        update budgetperiodlist;
        system.debug('****budList'+budgetperiodlist);*/
        Map<Id, Id> awardIdToBudPeriodIdMap = new Map<Id, Id>();
        List<Id> listids = new List<Id>();
        for (Award__c award : awards) {
            listids.add(award.BudgetPeriod__c);
            awardIdToBudPeriodIdMap.put(award.Id, award.BudgetPeriod__c);
        }
        Set<Id> updateIdSet = new Set<Id>();
        List<BudgetPeriod__c> bPeriodUpdateList = new List<BudgetPeriod__c>();
        Map<Id, BudgetPeriod__c> budgetPeriodMap = new Map<Id, BudgetPeriod__c>([SELECT id, Name, Status__c FROM BudgetPeriod__c WHERE ID IN :listIds AND Status__c != 'Active']);
        for (Award__c awd : awards) {
            if (awd.Status__c == 'Activated' && ((Award__c)trigger.oldMap.get(awd.Id)).Status__c != 'Activated') {
                Id bPeriodId = awardIdToBudPeriodIdMap.get(awd.Id);
                if (!updateIdSet.contains(bPeriodId)) {
                    BudgetPeriod__c bPeriod = budgetPeriodMap.get(bPeriodId);
                    //System.debug('THE BUDGET LEON'+bPeriod);
                    //System.debug('THE Budget Period Status'+bPeriod.Status__c);
                    if (bPeriod != null) {
                        bPeriod.Status__c = 'Active';
                        bPeriodUpdateList.add(bPeriod);
                        updateIdSet.add(bPeriodId);
                    }
                }
            }
        }
        if (bPeriodUpdateList.size() > 0) {
            update bPeriodUpdateList;
        }
    }

    //ST - commented the below code(1/3) because it's not being used. 1/2/2018
    /*private void createAwardBudgetCategories(List<Award__c> awards) {
        system.debug('Sarat --> Method Enter');
        Set<Id> GrantIds = new Set<Id>();
        Set<id> appIds   = new Set<Id>();
        Set<Id> budPeriod = new Set<Id>();
        List<AwardBudgetCategory__c> awardBudCatList = new List<AwardBudgetCategory__c>();
        List<BudgetCategory__c>  ExternalBudList;
        List<BudgetCategory__c>  internalBudList;
        List<BudgetCategory__c> constructionList = new List<BudgetCategory__c>();
        List<BudgetCategory__c> nonConstructionList = new List<BudgetCategory__c>();
        List<GrantServiceArea__c> grantserviceareaList;
        List<ApplicationBudgetCategory2__c> appbudcatList;
        List<Application__c> granteeAppBudCatList;
        List<BudgetCategory__c> finalList;
        Map<Id, String> grantBudCatMap = new Map<Id, String>();
        Map<Id, List<BudgetCategory__c>> granteeBudCatMap = new Map<Id, List<BudgetCategory__c>>();

        boolean checkDeepClone = true;
        for (Award__c awd : awards) {
            GrantIds.add(awd.Grant__c);
            budPeriod.add(awd.BudgetPeriod__c);
            // moved these two statements from the below loops
            appIds.add(awd.Application__c);
            if (awd.DeepCloned__c) {
                checkDeepClone = false;
            }
        }*/
    // End of ST comment 1/3
    /*for(Award__c awd:awards){
             appIds.add(awd.Application__c);
         }
     for(Award__c awd : awards) {
         if (awd.DeepCloned__c) {
             checkDeepClone = false;
         }
     }*/
    //ST - Commented the below code (2/3) because it's not being used. 1/2/2018
    /*System.debug('Application Ids -->' + appIds);

    if (checkDeepClone) {
        system.debug('Method entered here' + checkDeepClone);
        ExternalBudList   =     [Select Id, Name, RecordType.Name, Class__c from BudgetCategory__c where RecordType.Name = 'External'];
        internalBudList   =     [Select Id, Name, RecordType.Name from BudgetCategory__c where RecordType.Name = 'Internal'];
        grantserviceareaList =  [Select Id, Name, ServiceArea__c from GrantServiceArea__c where Grant__c in:GrantIds];
        appbudcatList     =     [select id, Name, Amount__c, Application__c, Application__r.AmountThisAction__c, Application__r.RequestedAmount__c,
                                 IsFirstBudgetPeriodRelated__c, BudgetCategory__c from ApplicationBudgetCategory2__c where Application__c in:appIds
                                 and IsFirstBudgetPeriodRelated__c = true];


        if (appName == 'StateasGrantee') {

            // Divides the ExternalBudList into Construction and Non Construction list depending upon the Class of Budget Category
            for (BudgetCategory__c budCat : ExternalBudList) {
                if (budCat.Class__c == 'Construction') {
                    constructionList.add(budCat);
                } else if (budCat.Class__c == 'Non construction') {
                    nonConstructionList.add(budCat);
                }
            }

            finalList = nonConstructionList; // By default, for Grant, Non Construction Categories are added

            // Fetches the type of budget category for an Application
            granteeAppBudCatList = [select id, ConstructionPackageIncluded__c from Application__c where id in:appIds];

            // Creates a Map of Application and List of Associated Budget Categories with it
            for (Application__c app : granteeAppBudCatList) {
                if (app.ConstructionPackageIncluded__c == 'Construction') {
                    granteeBudCatMap.put(app.Id, constructionList);
                } else {
                    granteeBudCatMap.put(app.Id, nonConstructionList);
                }
            }

            for (GrantServiceArea__c grantSA : grantserviceareaList) {
                for (Award__c awd : awards) {
                    if (awd.Application__c == null) {

                        // If the associated grant does not have an application, determine the budget category from TypeOfBudgetCategories__c field
                        // Creates a map of Grant and type of Budget category to be included for all its associated awards

                        for (Grant__c grant : [Select Id, TypeOfBudgetCategories__c FROM Grant__c where Id in:GrantIds ]) {
                            grantBudCatMap.put(grant.Id, grant.TypeOfBudgetCategories__c);
                        }

                        if (!awd.DeepCloned__c) {
                            if (grantBudCatMap.get(awd.Grant__c) == 'Construction') {
                                finalList = constructionList;
                            } else if (grantBudCatMap.get(awd.Grant__c) == 'Construction & Non Construction') {
                                finalList = ExternalBudList;
                            }
                            for (BudgetCategory__c budcat : finalList) {
                                AwardBudgetCategory__c abc = new AwardBudgetCategory__c();
                                abc.Award__c = awd.Id;
                                abc.BudgetCategory__c = budcat.ID;
                                abc.BudgetPeriod__c = awd.BudgetPeriod__c;
                                abc.GrantServiceArea__c = grantSA.Id;
                                awardBudCatList.add(abc);
                            }

                        }
                    } else {
                        if (!awd.DeepCloned__c) {
                            finalList = granteeBudCatMap.get(awd.Application__c);
                            for (BudgetCategory__c budcat : finalList) {
                                AwardBudgetCategory__c abc = new AwardBudgetCategory__c();
                                abc.Award__c = awd.Id;
                                abc.BudgetCategory__c = budcat.ID;
                                abc.BudgetPeriod__c = awd.BudgetPeriod__c;
                                abc.GrantServiceArea__c = grantSA.Id;
                                awardBudCatList.add(abc);
                            }
                        }
                    }
                }
            }
        }

        System.debug('AwardBudCatList -->' + awardBudCatList);*/
    //End of ST comment (2/3)
    /*if (appName == 'StateasGrantor') {
        for (GrantServiceArea__c grantSA : grantserviceareaList) {
            for (Award__c awd : awards) {
                if (awd.Application__c == null) {
                    for (BudgetCategory__c budcat : internalBudList) {
                        AwardBudgetCategory__c abc = new AwardBudgetCategory__c();
                        abc.Award__c = awd.Id;
                        abc.BudgetCategory__c = budcat.ID;
                        abc.BudgetPeriod__c = awd.BudgetPeriod__c;
                        abc.GrantServiceArea__c = grantSA.Id;
                        awardBudCatList.add(abc);
                    }
                } else {
                    for (ApplicationBudgetCategory2__c appbudcat : appbudcatList) {
                        if (appbudcat.Application__c == awd.Application__c) {
                            AwardBudgetCategory__c abc = new AwardBudgetCategory__c();
                            abc.Award__c = awd.Id;
                            abc.BudgetCategory__c = appbudcat.BudgetCategory__c;
                            abc.BudgetPeriod__c = awd.BudgetPeriod__c;
                            if (appbudcat.Amount__c != null && awd.AwardNegotiated__c == false) {
                                abc.Amount1__c = (appbudcat.Application__r.AmountThisAction__c / appbudcat.Application__r.RequestedAmount__c) * appbudcat.Amount__c;
                            } else if (appbudcat.Amount__c != null && awd.AwardNegotiated__c == true) {
                                abc.Amount1__c = appbudcat.Amount__c;
                            }
                            abc.GrantServiceArea__c = grantSA.Id;
                            awardBudCatList.add(abc);
                        }
                    }
                }
            }
        }
    }*/
    //ST - Commenting the below code (3/3) because it's not being used.
    /*if (awardBudCatList.size() > 0) insert awardBudCatList;
    }
    }*/
    // End of ST commenting (3/3)

    //private void copyGOfromApplication(List<Award__c> awards){

    //    List<Id> AppIds = new List<Id>();
    //    Map<Id, Id> awardAppMap = new Map<Id, Id>();
    //    //List<Award__c> awards=[Select Id,Application__c from Award__c];
    //    for (Award__c aw : awards) {
    //                if (aw.Application__c != null) {
    //                    AppIds.add(aw.Application__c);
    //                    awardAppMap.put(aw.Id, aw.Application__c);
    //                }
    //    }
    //    List<GoalObjective__c> parentGoalList = new List<GoalObjective__c>();
    //    List<GoalObjective__c> childGoalList = new List<GoalObjective__c>();
    //    //if (awards[0].Application__c != null) {
    //      //   parentGoalList = [Select Type__c, IsParent__c, ParentGoal__c,Year__c, Title__c, Description__c, Status__c, CombineTextQuestions__c,OldGoalYear__c, Award__c from GoalObjective__c where Application__c in :appIds and IsParent__c = true];
    //        // childGoalList = [Select Type__c, IsParent__c, ParentGoal__c, Title__c, Description__c,Q1__c,Q2__c,Q3__c,Q4__c,AwardQ1__c,AwardQ4__c,AwardQ3__c,AwardQ2__c,QuantitativeNumberMeasures__c,Other__c,ActivitiesAndMethods__c,MeasureEffectiveness__c,Status__c, Award__c from GoalObjective__c where Application__c in :appIds and IsParent__c = false];
    //    //}

    //    Map<Id, Application__c> parentAppMap = new Map<Id, Application__c>([SELECT Id, (SELECT Type__c, IsParent__c, ParentGoal__c,Year__c, Title__c, Description__c, Status__c, CombineTextQuestions__c,OldGoalYear__c, Award__c FROM Goals_Objectives__r WHERE IsParent__c = true) FROM Application__c WHERE Id IN :AppIds]);
    //    Map<Id, Application__c> childAppMap = new Map<Id, Application__c>([SELECT Id, (SELECT Type__c, IsParent__c, ParentGoal__c, Title__c, Description__c,Q1__c,Q2__c,Q3__c,Q4__c,AwardQ1__c,AwardQ4__c,AwardQ3__c,AwardQ2__c,QuantitativeNumberMeasures__c,Other__c,ActivitiesAndMethods__c,MeasureEffectiveness__c,Status__c, Award__c FROM Goals_Objectives__r WHERE IsParent__c = false) FROM Application__c WHERE Id IN :AppIds]);


    //    RecordType recordType = [select Id FROM RecordType where SobjectType = 'GoalObjective__c' and DeveloperName = 'Award'];
    //    List<GoalObjective__c> awardGoalParentList = new List<GoalObjective__c>();
    //    List<GoalObjective__c> awardGaolChildList = new List<GoalObjective__c>();
    //            for (Award__c award : awards) {
    //                for (GoalObjective__c goal : parentAppMap.get(awardAppMap.get(award.Id)).Goals_Objectives__r) {

    //                    GoalObjective__c temp = new GoalObjective__c(
    //                        IsParent__c = true,
    //                        ParentGoal__c = null,
    //                        Title__c = goal.Title__c,
    //                        Description__c = goal.Description__c,
    //                        Status__c = goal.Status__c,
    //                        Award__c = award.Id,
    //                        RecordTypeId = recordType.Id,
    //                        Year__c = goal.Year__c,
    //                        CombineTextQuestions__c = goal.CombineTextQuestions__c,
    //                        OldGoalYear__c = goal.OldGoalYear__c
    //                    );
    //                    awardGoalParentList.add(temp);
    //                    parentGoalList.add(goal);
    //                }
    //            }
    //            insert awardGoalParentList;

    //    Map<Id, Id> parentMap = new Map<id, Id>();
    //    System.debug(awardGoalParentList.size() + '   ' + parentGoalList.size());
    //    for (Integer i = 0; i < awardGoalParentList.size(); i++) {
    //        parentMap.put(parentGoalList.get(i).Id, awardGoalParentList.get(i).Id);
    //    }
    //    for (Award__c award : awards) {
    //        for (GoalObjective__c goal : childAppMap.get(awardAppMap.get(award.Id)).Goals_Objectives__r) {

    //            GoalObjective__c temp = new GoalObjective__c(
    //                IsParent__c = false,
    //                ParentGoal__c = parentMap.get(goal.ParentGoal__c),
    //                Title__c = goal.Title__c,
    //                Q1__c = goal.Q1__c,
    //                Q2__c = goal.Q2__c,
    //                Q3__c = goal.Q3__c,
    //                Q4__c = goal.Q4__c,
    //                QuantitativeNumberMeasures__c = goal.QuantitativeNumberMeasures__c,
    //                Other__c = goal.Other__c,
    //                ActivitiesAndMethods__c = goal.ActivitiesAndMethods__c,
    //                MeasureEffectiveness__c = goal.MeasureEffectiveness__c,
    //                Description__c = goal.Description__c,
    //                Status__c = goal.Status__c,
    //                Award__c = award.Id,
    //                RecordTypeId = recordType.Id
    //            );
    //            awardGaolChildList.add(temp);

    //        }
    //    }
    //    insert awardGaolChildList;
    //    System.debug(awardGaolChildList.size());




    //}







    /*Copy Program Goals&Objectives to Award after inserting Award*/
    //private void createAwardGoalsAndObjectives(List<Award__c> awards) {

    //    List<Id> AppIds = new List<Id>();
    //    List<Id> AnnIds = new List<Id>();
    //    List<Id> ProgramIds = new List<Id>();
    //    List<Id> GrantIds = new List<Id>();

    //    for (Award__c aw : awards) {
    //        if (aw.Application__c != null) {
    //            AppIds.add(aw.Application__c);
    //        } else {
    //            GrantIds.add(aw.Grant__c);
    //        }
    //    }

    //    if (awards[0].Application__c == null) {
    //        List<Grant__c> Grants = [Select Program__c from Grant__c where Id in :Grantids];
    //        for (Grant__c gr : Grants) {
    //            ProgramIds.add(gr.Program__c);
    //        }
    //    } else {
    //        List<Application__c> Apps = [Select Announcement__c from Application__c where Id in :AppIds];
    //        for (Application__c app : Apps) {
    //            AnnIds.add(app.Announcement__c);
    //        }
    //    }

    //    List<GoalObjective__c> parentGoalList = new List<GoalObjective__c>();
    //    List<GoalObjective__c> childGoalList = new List<GoalObjective__c>();

    //    if (awards[0].Application__c != null) {
    //        parentGoalList = [Select Type__c, IsParent__c, ParentGoal__c,Year__c, Title__c, Description__c, Allocated__c, AllocatedAmount__c, ExpenditureAmount__c, Status__c, DueDate__c, Award__c from GoalObjective__c where Application__c in :appIds and IsParent__c = true ];
    //        childGoalList = [Select Type__c, IsParent__c, ParentGoal__c, Title__c, Description__c,Q1__c,Q2__c,Q3__c,Q4__c,AwardQ1__c,AwardQ4__c,AwardQ3__c,AwardQ2__c,QuantitativeNumberMeasures__c,Other__c,ActivitiesAndMethods__c,MeasureEffectiveness__c, Allocated__c, AllocatedAmount__c, ExpenditureAmount__c, Status__c, DueDate__c, Award__c from GoalObjective__c where Application__c in :appIds and IsParent__c = false];
    //    }
    //    //YST - Commented because we are not copying from Program or announcement but from application__c.
    //    //if (awards[0].Application__c == null) {
    //    //    parentGoalList = [Select Type__c, IsParent__c, ParentGoal__c, Title__c, Description__c, Allocated__c, AllocatedAmount__c, ExpenditureAmount__c, Status__c, DueDate__c, Award__c from GoalObjective__c where Program__c in :ProgramIds and IsParent__c = true];
    //    //    childGoalList = [Select Type__c, IsParent__c, ParentGoal__c, Title__c, Description__c, Allocated__c, AllocatedAmount__c, ExpenditureAmount__c, Status__c, DueDate__c, Award__c from GoalObjective__c where Program__c in :ProgramIds and IsParent__c = false];
    //    //}
    //    //else {
    //      //  parentGoalList = [Select Type__c, IsParent__c, ParentGoal__c, Title__c, Description__c, Allocated__c, AllocatedAmount__c, ExpenditureAmount__c, Status__c, DueDate__c, Award__c from GoalObjective__c where Announcement__c in :AnnIds and IsParent__c = true];
    //      //  childGoalList = [Select Type__c, IsParent__c, ParentGoal__c, Title__c, Description__c, Allocated__c, AllocatedAmount__c, ExpenditureAmount__c, Status__c, DueDate__c, Award__c from GoalObjective__c where Announcement__c in :AnnIds and IsParent__c = false];
    //    //}

    //    RecordType recordType = [select Id FROM RecordType where SobjectType = 'GoalObjective__c' and DeveloperName = 'Award'];
    //    List<GoalObjective__c> awardGoalParentList = new List<GoalObjective__c>();
    //    List<GoalObjective__c> awardGaolChildList = new List<GoalObjective__c>();

    //    for (Award__c award : awards) {
    //        for (Integer i = 0; i < parentGoalList.size(); i++) {
    //            GoalObjective__c goal = parentGoalList.get(i);
    //            GoalObjective__c temp = new GoalObjective__c(
    //                IsParent__c = true,
    //                ParentGoal__c = null,
    //                Title__c = goal.Title__c,
    //                Description__c = goal.Description__c,
    //                Allocated__c = goal.Allocated__c,
    //                AllocatedAmount__c = goal.AllocatedAmount__c,
    //                ExpenditureAmount__c = goal.ExpenditureAmount__c,
    //                Status__c = goal.Status__c,
    //                DueDate__c = goal.DueDate__c,
    //                Award__c = award.Id,
    //                RecordTypeId = recordType.Id,
    //                Year__c = goal.Year__c
    //            );
    //            awardGoalParentList.add(temp);
    //        }
    //    }
    //    insert awardGoalParentList;

    //    Map<Id, Id> parentMap = new Map<id, Id>();
    //    for (Integer i = 0; i < awardGoalParentList.size(); i++) {
    //        parentMap.put(parentGoalList.get(i).Id, awardGoalParentList.get(i).Id);
    //    }


    //    for (Award__c award : awards) {
    //        for (Integer i = 0; i < childGoalList.size(); i++) {
    //            GoalObjective__c goal = childGoalList.get(i);
    //            Decimal totalquant = goal.Q1__c+goal.Q2__c+goal.Q3__c+goal.Q4__c;
    //            GoalObjective__c temp = new GoalObjective__c(
    //                IsParent__c = false,
    //                ParentGoal__c = parentMap.get(goal.ParentGoal__c),
    //                Title__c = goal.Title__c,
    //                Q1__c = goal.Q1__c,
    //                Q2__c = goal.Q2__c,
    //                Q3__c = goal.Q3__c,
    //                Q4__c = goal.Q4__c,
    //                TargetedQ__c = 'Q1:' +((goal.Q1__c == null)? 'N/A' : goal.Q1__c.format()) + '<br><br>' + 'Q2:' +((goal.Q2__c == null)? 'N/A' : goal.Q2__c.format()) + '<br><br>' +'Q3:' +((goal.Q3__c == null)? 'N/A' : goal.Q3__c.format()) + '<br><br>' +'Q4:' +((goal.Q4__c == null)? 'N/A' : goal.Q4__c.format()) + '<br><br>' + 'Total Quantitative:'+((totalquant == null)? 'N/A' : totalquant.format()) + '<br><br>',
    //                QuantitativeNumberMeasures__c = goal.QuantitativeNumberMeasures__c,
    //                Other__c = goal.Other__c,
    //                ActivitiesAndMethods__c = goal.ActivitiesAndMethods__c,
    //                MeasureEffectiveness__c = goal.MeasureEffectiveness__c,

    //                Description__c = goal.Description__c,
    //                Allocated__c = goal.Allocated__c,
    //                AllocatedAmount__c = goal.AllocatedAmount__c,
    //                ExpenditureAmount__c = goal.ExpenditureAmount__c,
    //                Status__c = goal.Status__c,
    //                DueDate__c = goal.DueDate__c,
    //                Award__c = award.Id,
    //                RecordTypeId = recordType.Id
    //            );
    //            awardGaolChildList.add(temp);

    //        }
    //    }
    //    insert awardGaolChildList;
    //}
    /*Copy Application WBS to Award after inserting Award*/
    //  - Weike - 04/19/2017
    /*private void createAwardWBSTasks(List<Award__c> awards) {

        List<Id> appIds = new List<Id>();
        for (Award__c aw : awards) {
            if (aw.Application__c != null) {
                appIds.add(aw.Application__c);
            }
        }

        if (appIds.size() == 0) {
            return;
        }

        List<WBSTaskSchedule__c> allWBS = [Select Id, Application__c, Name, OwnerId, Owner.Name, CreatedDate, ProgressIndicator__c, TaskDuration__c, ParentWBSTaskSchedule__c, StartDate__c, WBSNumber__c, Description__c, Milestone__c, Status__c, EndDate__c from WBSTaskSchedule__c where Application__c in :appIds ];
        List<WBSTaskSchedule__c> WBSRoot = new List<WBSTaskSchedule__c>();

        for (Award__c a : awards) {
            for (WBSTaskSchedule__c w : allWBS) {
                if (w.ParentWBSTaskSchedule__c == null && w.Application__c == a.Application__c) {
                    WBSRoot.add(w);
                }
            }
            WBSCreateHelper(WBSRoot, null, allWBS, a.Id);
        }
    }*/
    //AwardWBS Create Helper Method -- Weike 04/20/2017
    /*private void WBSCreateHelper(List<WBSTaskSchedule__c> WBSRoot, Id parentId, List<WBSTaskSchedule__c> allWBS, Id awardId) {

        if (WBSRoot == null || WBSRoot.size() == 0) {
            return;
        }

        List<WBSTaskSchedule__c> newRootList = new List<WBSTaskSchedule__c>();
        for (Integer i = 0; i < WBSRoot.size(); i++) {
            WBSTaskSchedule__c old = WBSRoot.get(i);
            WBSTaskSchedule__c temp = new WBSTaskSchedule__c(
                Name = old.Name,
                OwnerId = old.OwnerId,
                ProgressIndicator__c = old.ProgressIndicator__c,
                TaskDuration__c = old.TaskDuration__c,
                StartDate__c = old.StartDate__c,
                ParentWBSTaskSchedule__c = parentId,
                WBSNumber__c = old.WBSNumber__c,
                Description__c = old.Description__c,
                Milestone__c = old.Milestone__c,
                Status__c = old.Status__c,
                EndDate__c = old.EndDate__c,
                Award__c = awardId
            );
            newRootList.add(temp);
        }
        SystemContextMethodsHelper systemContextMethodsHelper = new SystemContextMethodsHelper();
        systemContextMethodsHelper.insertNewRootList(newRootList);

        Map<Id, Id> oldNewMap = new Map<Id, Id>();
        for (Integer i = 0; i < newRootList.size(); i++) {
            oldNewMap.put(WBSRoot.get(i).Id, newRootList.get(i).Id);
        }

        for (WBSTaskSchedule__c w : WBSRoot) {
            List<WBSTaskSchedule__c> childs = new List<WBSTaskSchedule__c>();
            for (WBSTaskSchedule__c w1 : allWBS) {
                if (w1.ParentWBSTaskSchedule__c == w.Id) {
                    childs.add(w1);
                }
            }
            WBSCreateHelper(childs, oldNewMap.get(w.Id), allWBS, awardId);
        }
    }*/


    /*Copy Program Outcomes to Award after inserting Award*/
// code still should be refactored and tested - sarat - 01/03/2017
    /*private void createAwardOutcomes(List<Award__c> awards) {
        Set<Id> GrantIds = new Set<Id>();
        Set<Id> Programids = new Set<Id>();
        List<KeyOutcome__c> awardoutcomelist = new List<KeyOutcome__c>();
        List<KeyOutcome__c>  programoutcomelist;
        for (Award__c awd : awards) {
            GrantIds.add(awd.Grant__c);
        }
        List<Grant__c> grantlist = [select id, name, Program__c from Grant__c where id IN : GrantIds];
        for (Grant__c grant : grantlist) {
            Programids.add(grant.Program__c);
        }
        programoutcomelist  = [Select Id, Name, KeyPerformanceIndicator__c, KeyPerformanceSubIndicator__c, KeyPerformanceCategory__c,
                               KeyPerformanceSubCategory__c, Orientation__c, Target__c, Unit__c, Program__c from KeyOutcome__c where Program__c IN :Programids];

        // Map<ID,Grant__c> grantMap = new Map<ID,Grant__c>([select Id,Program__c from Grant__c where Id IN :GrantIds]);

        for (Award__c awd : awards) {
            for (Grant__c grant : grantlist) {
                for (KeyOutcome__c outcome : programoutcomelist) {
                    //  Grant__c grant = grantMap.get(outcome.Program__c);
                    if (grant.Program__c == outcome.Program__c) {
                        KeyOutcome__c awardoutcome = new KeyOutcome__c();
                        awardoutcome.Award__c = awd.Id;
                        awardoutcome.KeyPerformanceIndicator__c = outcome.KeyPerformanceIndicator__c;
                        awardoutcome.KeyPerformanceSubIndicator__c = outcome.KeyPerformanceSubIndicator__c;
                        awardoutcome.KeyPerformanceCategory__c = outcome.KeyPerformanceCategory__c;
                        awardoutcome.KeyPerformanceSubCategory__c = outcome.KeyPerformanceSubCategory__c;
                        awardoutcome.Orientation__c = outcome.Orientation__c;
                        awardoutcome.Unit__c = outcome.Unit__c;
                        awardoutcome.Target__c = outcome.Target__c;
                        awardoutcomelist.add(awardoutcome);
                    }
                }
            }
        }
        if (awardoutcomelist.size() > 0) insert awardoutcomelist;
    }*/

    /*Insert RecordType as 'Grantee'*/
    private void SetAwardDetails() {
        Set<Id> GrantIds = new Set<Id>();
        Set<Id> applicationIds = new Set<Id>();
        Map<Id, Application__c> applicationMap = new Map<Id, Application__c>();
        String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
        Id granteeRecordTypeId = Schema.SObjectType.Award__c.getRecordTypeInfosByName().get('Grantee').getRecordTypeId();
        Id grantorRecordTypeId = Schema.SObjectType.Award__c.getRecordTypeInfosByName().get('Grantor').getRecordTypeId();
        //List<RecordType> recordTypeList = [select Id, Name, SobjectType FROM RecordType where SobjectType=:AppUtils.getNamespacePrefix()+'Award__c' and Name='Grantee'];
        //List<RecordType> grantorrecordTypeList = [select Id, Name, SobjectType FROM RecordType where SobjectType=:AppUtils.getNamespacePrefix()+'Award__c' and Name='Grantor'];
        for (Award__c award : (List<Award__c>) Trigger.New) {
            GrantIds.add(award.Grant__c);
            applicationIds.add(award.Application__c);
        }
        System.debug('TEST DEBUGGGGG123 =======================>' + applicationIds);
        List<BudgetPeriod__c> budgetperiod = [select Id, Name, BudgetStartDate__c from BudgetPeriod__c where Grant__c IN:GrantIds ORDER BY BudgetStartDate__c ASC];
        List<Application__c> applications = [SELECT Id, ProposalDescription__c FROM Application__c WHERE Id IN: applicationIds];
        for (Application__c application : applications) {
            applicationMap.put(application.Id, application);
        }

        for (Award__c award : (List<Award__c>) Trigger.New) {
            Application__c application = applicationMap.get(award.Application__c);
            if (appName == 'StateasGrantee') {
                //award.recordTypeId = recordTypeList[0].Id;
                award.recordTypeId = granteeRecordTypeId;
            } else {
                //award.recordTypeId = grantorrecordTypeList[0].Id;
                award.recordTypeId = grantorRecordTypeId;
            }
            if (skipfromAmendment == false) {
                award.Status__c = 'Created';
                System.debug('TEST DEBUGGGGG =======================>' + application.ProposalDescription__c);
                award.GrantAwardDescription__c = application.ProposalDescription__c;
            }

        }

        if (appName != null && appName == 'StateasGrantor') {
            for (Award__c award : (List<Award__c>) Trigger.New) {
                // Sarat - Commented it on 7/9/2016 - Amendment issue - Not allowing the budget period to change
                if (!award.DeepCloned__c) {
                    award.BudgetPeriod__c = budgetperiod[0].ID;
                }
            }
        }
    }

    /* Insert owner of Award in Roles and Responsibility*/

    private void insertOwnerinRolesandResp() {
        String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
        String AwardRecordtype;
        if (appName == 'StateasGrantee') {
            AwardRecordtype = 'Award';
        } else if (appName == 'StateasGrantor' || appName == 'Recipient') {
            AwardRecordtype = 'GrantorAward';
        }
        List<RolesAndResponsibilities__c> listrolesandresp = new List<RolesAndResponsibilities__c>();
        List<RecordType> recordTypeList = [select Id, Name, DeveloperName, SobjectType FROM RecordType where SobjectType = :AppUtils.getNamespacePrefix() + 'RolesAndResponsibilities__c' and DeveloperName = :AwardRecordtype];
        for (Award__c award : (List<Award__c>) Trigger.New) {
            RolesAndResponsibilities__c rresp = new RolesAndResponsibilities__c();
            rresp.Award__c = award.id;
            rresp.Name__c = award.CreatedById;
            //rresp.Role__c = 'Other';
            rresp.BusinessRole__c = 'Owner';
            rresp.recordTypeId = recordTypeList[0].Id;
            listrolesandresp.add(rresp);
        }
        //RolesandResponsibilitiesTriggerHelper.skipTrigger = true;
        if (!listrolesandresp.isempty()) {
            insert listrolesandresp;
        }
    }


    private void copyRolesfromAnnouncemnt(List<Award__c> awards) {
        String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
        String AwardRecordtype;
        if (appName == 'StateasGrantee') {
            AwardRecordtype = 'Award';
        } else if (appName == 'StateasGrantor' || appName == 'Recipient') {
            AwardRecordtype = 'GrantorAward';
        }
        List<RolesAndResponsibilities__c> listrolesandresp = new List<RolesAndResponsibilities__c>();
        RecordType recordType = [select Id, Name, DeveloperName, SobjectType FROM RecordType where SobjectType = :AppUtils.getNamespacePrefix() + 'RolesAndResponsibilities__c' and DeveloperName = :AwardRecordtype];
        Set<Id> annIds = new Set<Id>();
        for (Award__c award : awards) {
            annIds.add(award.Announcement__c);
        }
        system.debug('AnnIds size' + annIds.size());
        List<RolesAndResponsibilities__c> Roles = [SELECT Id, Name__c, Announcement__c, BusinessRole__c, Responsibility__c from RolesAndResponsibilities__c where Announcement__c IN :annIds AND BusinessRole__c IN ('Fiscal Approver', 'Program Approver', 'Site Visit Investigator')];
        List<RolesAndResponsibilities__c> newlist = new List<RolesAndResponsibilities__c>();
        for (Award__c awardroles : awards) {
            for (RolesAndResponsibilities__c annRoles : Roles) {
                if (awardroles.Announcement__c == annRoles.Announcement__c) {
                    RolesAndResponsibilities__c rolesToInsert = new RolesAndResponsibilities__c(
                        Award__c = awardroles.Id,
                        Name__c = annRoles.Name__c,
                        BusinessRole__c = annRoles.BusinessRole__c,
                        UserType__c = annRoles.UserType__c,
                        recordTypeId = recordType.Id
                    );
                    newlist.add(rolesToInsert);
                }
            }
        }
        if (newlist.size() > 0) {
            insert newlist;
        }
    }

    private void updateOtherAwardsStatus(List<Award__c> awards) {
        List<Award__c> activeAwardList = new List<Award__c>();
        List<Id> grantIdList = new List<Id>();
        for (Award__c award : awards) {
            if (award.Status__c == 'Activated') {
                activeAwardList.add(award);
                grantIdList.add(award.Grant__c);
            }
        }

        List<Award__c> amendedAwardList = new List<Award__c>([SELECT Id, Status__c FROM Award__c WHERE Grant__c IN :grantIdList AND Id NOT IN :activeAwardList AND Status__c = 'Activated']);
        for (Award__c awd : amendedAwardList) {
            awd.Status__c = 'Amended';
        }

        update amendedAwardList;
    }
    private void updateAwardFinetCodeStatus(List<Award__c> awards) {
        List<AwardFINETCode__c> afcs = [SELECT Id, Award__r.Status__c, AwardStatus__c FROM AwardFINETCode__c WHERE Award__c IN :awards];
        for (AwardFINETCode__c afc : afcs) {
            afc.AwardStatus__c = afc.Award__r.Status__c;
        }
        update afcs;
    }
    /*Insert KeyPOC from Grant to Award Contact*/

    private void CopyKeyPOCToAwardContacts() {
        if (appName != null && appName == 'StateasGrantor') {
            list<id> grantids = new list<id>();
            list<GrantContact__c> awardcontactlist = new list<GrantContact__c>();
            String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
            for (Award__c award : (List<Award__c>) Trigger.New) {
                grantids.add(award.Grant__c);
            }
            Map<ID, User> usermap = new Map<ID, User>([select id, contactid from User]);
            Map<Id, Grant__c> grants = new Map<Id, Grant__c>([select id, name, GranteePOC__c
                    from Grant__c
                    where id IN:grantids]);

            for (Award__c award : (List<Award__c>) Trigger.New) {
                Grant__c grant = grants.get(award.Grant__c);
                if (!award.DeepCloned__c && grant.GranteePOC__c != null) {
                    User user = usermap.get(grant.GranteePOC__c);
                    GrantContact__c awardcontact = new GrantContact__c();
                    awardcontact.Award__c = award.id;
                    awardcontact.Contact__c = user.contactid;
                    awardcontact.Role__c = 'Recipient/KeyPoc';
                    awardcontactlist.add(awardcontact);
                }
            }
            insert awardcontactlist;
        }
    }
    private void addRoles(List<Award__c> awardList) {
        Set<Id> grantIdSet = new Set<Id>();
        Set<Id> announcementIdSet = new Set<Id>();
        for (Award__c awardIterator : awardList) {
            grantIdSet.add(awardIterator.Grant__c);
            announcementIdSet.add(awardIterator.Announcement__c);
        }
        List<Grant__c> grantList = [SELECT Id, OwnerId FROM Grant__c WHERE Id IN: grantIdSet];
        Map<Id, Id> grantIdMapOwnerId = new Map<Id, Id>();
        for (Grant__c grantIterator : grantList) {
            grantIdMapOwnerId.put(grantIterator.Id, grantIterator.OwnerId);
        }
        //System.debug('MANUALDEBUG >>> grantIdSet: ' + grantIdSet);
        // Fetch roles from Application
        /*
        List<RolesAndResponsibilities__c> grantRolesAndRespList = [
                    SELECT Id, Name__c, Grant__c, BusinessRole__c, Responsibility__c, Agency__c, RecordTypeId, UserType__c
                    FROM RolesAndResponsibilities__c
                    WHERE Grant__c IN: grantIdSet];
        System.debug('MANUALDEBUG >>> grantRolesAndRespList : ' + grantRolesAndRespList);
        */
        List<RolesAndResponsibilities__c> announcementRolesAndRespList = [
                    SELECT Id, Name__c, Announcement__c, BusinessRole__c, Responsibility__c, Agency__c, RecordTypeId, UserType__c
                    FROM RolesAndResponsibilities__c
                    WHERE Announcement__c IN: announcementIdSet];

        List<RolesAndResponsibilities__c> awardRRList = new List<RolesAndResponsibilities__c>();
        for (Award__c awardIterator : awardList) {
            for (RolesAndResponsibilities__c rolesIterator : announcementRolesAndRespList) {
                if (rolesIterator.Announcement__c.equals(awardIterator.Announcement__c)) {
                    RolesAndResponsibilities__c addRole = new RolesAndResponsibilities__c();
                    addRole.Agency__c = rolesIterator.Agency__c;
                    addRole.RecordTypeId = rolesIterator.RecordTypeId;
                    addRole.UserType__c = rolesIterator.UserType__c;
                    addRole.Award__c = awardIterator.Id;
                    addRole.Program__c = awardIterator.ProgramId__c;
                    addRole.BusinessRole__c = rolesIterator.BusinessRole__c;
                    if (rolesIterator.BusinessRole__c == 'Owner') {
                        addRole.Name__c = grantIdMapOwnerId.get(awardIterator.Grant__c);
                    } else {
                        addRole.Name__c = rolesIterator.Name__c;
                    }
                    awardRRList.add(addRole);
                    System.debug('MANUALDEBUG >>> addRole: ' + addRole);
                }
            }
        }
        try {
            System.debug('MANUALDEBUG >>> grantRRList: ' + awardRRList);
            insert awardRRList;
        } catch (Exception e) {
            System.debug('MANUALDEBUG >>> error: ' + e);
        }
    }
    /*
    private void copyRolesFromGrant(List<Award__c> awards){
        List<Id> grantIdList = new List<Id>();
        for (Award__c awardIterator : awards) {
            grantIdList.add(awardIterator.Grant__c);
        }
        List<RolesAndResponsibilities__c> rolesAndRespList = [SELECT Id, Name__c, BusinessRole__c, Grant__c FROM RolesAndResponsibilities__c WHERE Grant__c IN: grantIdList];
        if (rolesAndRespList != null && rolesAndRespList.size() > 0) {
            for (Award__c awardIterator : awards) {
                for (RolesAndResponsibilities__c rolesAndRespIterator : rolesAndRespList) {
                    if (rolesAndRespIterator.Grant__c == awardIterator.Grant__c) {
                        if (rolesAndRespIterator.BusinessRole__c == 'Executive Approver') { awardIterator.ExecutiveApprover__c = rolesAndRespIterator.Name__c; }
                        else if (rolesAndRespIterator.BusinessRole__c == 'Grants Manager') { awardIterator.GrantsManager__c = rolesAndRespIterator.Name__c; }
                        else if (rolesAndRespIterator.BusinessRole__c == 'Payment Approver 1') { awardIterator.PaymentApprover1__c= rolesAndRespIterator.Name__c; }
                        else if (rolesAndRespIterator.BusinessRole__c == 'Payment Approver 2') { awardIterator.PaymentApprover2__c= rolesAndRespIterator.Name__c; }
                        else if (rolesAndRespIterator.BusinessRole__c == 'Payment Approver 3') { awardIterator.PaymentApprover3__c= rolesAndRespIterator.Name__c; }
                        else if (rolesAndRespIterator.BusinessRole__c == 'Payment Approver 4') { awardIterator.PaymentApprover4__c= rolesAndRespIterator.Name__c; }
                    }
                }
            }
        }
    }
    */
    private void copyContactsFromAnnouncement(List<Award__c> awards) {

        List<Id> annIds = new List<Id>();
        List<GrantContact__c> grantContactstoInsert = new List<GrantContact__c>();
        for (Award__c award : awards) {
            annIds.add(award.Announcement__c);
        }
        System.debug('MANUALDEBUG >>> annIds: ' + annIds);
        //List<Announcement__c> announcement = New List<Announcement__c>([SELECT Id,OwnerId,FinancialApprover__c from Announcement__c Where Id IN :annIds LIMIT 1]);
        List<Announcement__c> announcement = [SELECT Id, OwnerId, GrantsManager__c FROM Announcement__c WHERE Id IN :annIds LIMIT 1];
        Contact contact;
        if (announcement != null && announcement.size() > 0) {
            Announcement__c ann = announcement[0];
            //Contact contact = [Select id,Name from Contact where UserReference__c=:ann.FinancialApprover__c limit 1];
            contact = [Select Id, Name FROM Contact where UserReference__c = :ann.GrantsManager__c limit 1];
        } else {
            contact = [Select Id, Name FROM Contact where UserReference__c = :awards[0].GrantsManager__c limit 1];
        }
        for (Award__c award : awards) {
            GrantContact__c grantCont = new GrantContact__c();
            grantCont.Award__c = award.Id;
            grantCont.Contact__c = contact.Id;
            //grantCont.Role__c = 'Fiscal Approver'; //To be modified as needed
            grantCont.Role__c = 'Grants Manager';
            grantContactstoInsert.add(grantCont);
        }
        if (!grantContactstoInsert.isEmpty()) {
            insert grantContactstoInsert;
        }
    }

    //Sets the hasAward field on the application to false if an award is deleted and there are no more
    //awards tied to that application
    private void updateApplication(List<Award__c> awards) {
        Set<Id> oldAppIds = new Set<Id>();
        for (Award__c award : awards) {
            oldAppIds.add(award.Application__c);
        }
        List<Award__c> currentAwards = [SELECT Application__c FROM Award__c WHERE Application__c IN: oldAppIds];
        Set<Id> currentAppIds = new Set<Id>();
        for (Award__c award : currentAwards) {
            currentAppIds.add(award.Application__c);
        }
        List<Id> appsToUpdate = new List<Id>();
        for (Id appId : oldAppIds) {
            if (!currentAppIds.contains(appId)) {
                appsToUpdate.add(appId);
            }
        }
        List<Application__c> apps = [SELECT Id, HasAward__c FROM Application__c WHERE Id IN: appsToUpdate];
        for (Application__c app : apps) {
            app.HasAward__c = false;
        }
        if (apps.size() > 0) {
            update apps;
        }
    }

    public void decideTermConditionAction(List<Award__c> awards) {
        List<Award__c> validAwards = new List<Award__c>();
        Set<Id> grantIds = new Set<Id>();
        Map<Id, Award__c> grantAwardMap = new Map<Id, Award__c>();
        for (Award__c award : awards) {
            if (award.Status__c == 'Activated') {
                validAwards.add(award);
                if (!grantIds.contains(award.Grant__c)) {
                    grantIds.add(award.Grant__c);
                }
                if (!grantAwardMap.containsKey(award.Grant__c)) {
                    grantAwardMap.put(award.Grant__c, award);
                }
            }
        }

        if (validAwards.size() == 0) {
            return;
        }

        List<Award__c> awardsHasTC = new List<Award__c>();
        List<Award__c> awardsHasNoTC = new List<Award__c>();
        List<Grant__c> grants = [SELECT Id, IsTCScheduleCreated__c FROM Grant__c WHERE Id IN :grantIds];
        for (Grant__c grant : grants) {
            if (grant.IsTCScheduleCreated__c == true) {
                awardsHasTC.add(grantAwardMap.get(grant.Id));
            } else {
                awardsHasNoTC.add(grantAwardMap.get(grant.Id));
            }
        }

        if (awardsHasNoTC.size() > 0) {
            prepareProgressReportSiteVisitPaymentSchedule(awardsHasNoTC);
        }
        if (awardsHasTC.size() > 0) {
            moveAllTCToCurrentAward(awardsHasTC);
        }
    }

    public void copyReportingRequirements(List<Award__c> awards) {
        Set<Id> announcementids = new Set<Id>();
        for (Award__c award : awards) {
            announcementids.add(award.Announcement__c);
        }

        String uniqueIdAPIName = 'InternalUniqueID__c';
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        String SobjectApiName = 'TermCondition__c';
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
        String commaSeparatedFields = '';
        for (String fieldName : fieldMap.keyset()) {
            if (!fieldName.equalsIgnorecase(uniqueIdAPIName)) {
                if (commaSeparatedFields == null || commaSeparatedFields == '') {
                    commaSeparatedFields = fieldName;
                } else {
                    commaSeparatedFields = commaSeparatedFields + ', ' + fieldName;
                }
            }
        }
        String idstring = '';
        for (Id recordId : announcementids) {
            if (idstring == '') {
                idstring = 'Announcement__c = \'' + recordId + '\'';
            } else {
                idstring = idstring + ' OR Announcement__c = \'' + recordId + '\'';
            }
        }
        String query = 'select ' + commaSeparatedFields + ' from ' + SobjectApiName + ' where ' + idstring;
        List<TermCondition__c> reqlist = Database.query(query);

        Map<Id, List<TermCondition__c>> reqmap = new Map<Id, List<TermCondition__c>>();
        for (TermCondition__c req : reqlist) {
            List<TermCondition__c> tmp = reqmap.get(req.Announcement__c);
            if (tmp == null) {
                tmp = new List<TermCondition__c>();
            }
            tmp.add(req);
            reqmap.put(req.Announcement__c, tmp);
        }

        List<TermCondition__c> newreqlist = new List<TermCondition__c>();
        for (Award__c award : awards) {
            List<TermCondition__c> reqs = reqmap.get(award.Announcement__c);
            if (reqs != null) {
                for (TermCondition__c req : reqs) {
                    TermCondition__c newreq = req.clone(false);
                    newreq.Award__c = award.Id;
                    newreq.Announcement__c = null;
                    newreqlist.add(newreq);
                }
            }
        }
        insert newreqlist;
    }

    public void createPaymentSchedule(List<Award__c> awards) {
        if (awards[0].USBEPathway__c == 'App12') {
            List<MSPPaymentSchedule__c> paymentschedules = [SELECT Id FROM MSPPaymentSchedule__c WHERE FiscalYear__c = : awards[0].FiscalYear__c];
            if (paymentschedules.size() == 0) {
                CreatePaymentScheduleHelper paymentscheduler = new CreatePaymentScheduleHelper();
                paymentscheduler.createPaymentSchedule(awards[0].FiscalYear__c);
            }
        }
    }

    public void moveAllTCToCurrentAward(List<Award__c> awards) {
        Map<Id, Id> grantAwardMap = new Map<Id, Id>();
        for (Award__c award : awards) {
            if (!grantAwardMap.containsKey(award.Grant__c)) {
                grantAwardMap.put(award.Grant__c, award.Id);
            }
        }
        List<TermCondition__c> tcs = [SELECT Id, Award__c, Award__r.Grant__c FROM TermCondition__c WHERE Award__r.Grant__c IN : grantAwardMap.keySet()];
        /*
        List<PaymentRequest__c> pars = [SELECT Id, Award__c, Award__r.Grant__c FROM PaymentRequest__c WHERE Award__r.Grant__c IN : grantAwardMap.keySet()];
        List<SiteVisit__c> svs = [SELECT Id, Award__c, Award__r.Grant__c FROM SiteVisit__c WHERE Award__r.Grant__c IN : grantAwardMap.keySet()];
        List<ProgressReports__c> prs = [SELECT Id, Award__c, Award__r.Grant__c FROM ProgressReports__c WHERE Award__r.Grant__c IN : grantAwardMap.keySet()];
        */
        for (TermCondition__c tc : tcs) {
            tc.Award__c = grantAwardMap.get(tc.Award__r.Grant__c);
        }
        /*
        for (PaymentRequest__c par : pars) {
            par.Award__c = grantAwardMap.get(par.Award__r.Grant__c);
        }
        for (SiteVisit__c sv : svs) {
            sv.Award__c = grantAwardMap.get(sv.Award__r.Grant__c);
        }
        for (ProgressReports__c pr : prs) {
            pr.Award__c = grantAwardMap.get(pr.Award__r.Grant__c);
        }
        */
        SystemContextMethodsHelper sc = new SystemContextMethodsHelper();
        sc.updateTermConditions(tcs);
        //update pars;
        //update svs;
        //update prs;
    }

    //Weike combine site visit and progress report

    public void prepareProgressReportSiteVisitPaymentSchedule(List<Award__c> awards) {

        Set<Id> awardIds = new Set<Id>();
        Set<Id> grantIds = new Set<Id>();
        List<TermConditionSchedule__c> lstSchedules = new List<TermConditionSchedule__c>();
        ProgressReportsConfig__c progressRptCfg ;
        boolean checkDeepClone = true;

        //Commented by Davinder : The amended Award was not creating any Schedules due to this check. Need to confirm with Ramu
        /*  for(Award__c awd : awards) {
            if (awd.DeepCloned__c == true) {
                checkDeepClone = false;
            }
        }*/

        String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
        if (appName == 'StateAsGrantee') {
            progressRptCfg = ProgressReportsConfig__c.getInstance('Grantee_Reports');
        } else {
            progressRptCfg = ProgressReportsConfig__c.getInstance('Grantor_Reports');
        }

        Integer age = null;
        Integer creationAge = null;


        for (Award__c c : awards) {
            awardIds.add(c.Id);
            if (!grantIds.contains(c.Grant__c)) {
                grantIds.add(c.Grant__c);
            }
        }

        if (checkDeepClone) {
            // List<RecordType> rctTypeList= [select Id from RecordType where Name = 'Progress Report' and SobjectType =:AppUtils.getNamespacePrefix()+'TermConditionSchedule__c' limit 1];
            Map<Id, TermCondition__c> termConditionMap = new Map<Id, TermCondition__c>([Select Id, Title__c , Name, RecordType.Name, Award__c, FixedEndDate__c, Grant__c, CalReportingEndDate__c, CalReportingStartDate__c, ReportName__c, Category__c, Frequency__c , ReportingFrequency__c, SiteVisitDateTime__c, VisitEndDateTime__c, SiteVisitLocation__c, SecondaryLocation__c  from Termcondition__c where Award__c = : awardIds]);
            Id rctTypeListProgressReport = Schema.SObjectType.TermConditionSchedule__c.getRecordTypeInfosByName().get('Progress Report').getRecordTypeId();
            Id rctTypeListSiteVisit = Schema.SObjectType.TermConditionSchedule__c.getRecordTypeInfosByName().get('Site Visit').getRecordTypeId();
            Id rctTypeListPaymentRequest = Schema.SObjectType.TermConditionSchedule__c.getRecordTypeInfosByName().get('Payment Request').getRecordTypeId();

            for (Award__c award : (List<Award__c>) awards) {

                for (TermCondition__c termCondition : termConditionMap.values()) {

                    if (termCondition.Award__c == award.Id) { // This is the TnC for current Award, create progress Report
                        Date startDate = null;
                        Date endDate = null;
                        if (termCondition.RecordType.Name == 'Site Visit') {
                            startDate = (termCondition.SiteVisitDateTime__c).date();
                            endDate = (termCondition.VisitEndDateTime__c).date();
                            age = (Integer)progressRptCfg.VisitDueAge__c;
                            creationAge = (Integer)progressRptCfg.SiteVisitTaskCreationAge__c;
                        } else if (termCondition.RecordType.Name == 'Reporting Requirement' || termCondition.RecordType.Name == 'Payment Request') {
                            startDate = termCondition.CalReportingStartDate__c;
                            endDate = termCondition.CalReportingEndDate__c;
                            age = (Integer)progressRptCfg.ReportDueAge__c;
                            creationAge = (Integer)progressRptCfg.TaskCreationAge__c;
                        }

                        if (termCondition.Frequency__c == 'Fixed') {
                            //Date reportStartDate= termCondition.CalReportingStartDate__c;
                            TermConditionSchedule__c  termSchedule = new TermConditionSchedule__c();
                            termSchedule.TermAndCondition__c = termCondition.Id;
                            termSchedule.ReportStatus__c = 'N/A';

                            if ((termCondition.RecordType.Name == 'Payment Request' || termCondition.RecordType.Name == 'Reporting Requirement') && termCondition.CalReportingStartDate__c != null && termCondition.CalReportingEndDate__c != null) {
                                termSchedule.StartDate__c = termCondition.CalReportingStartDate__c;
                                termSchedule.EndDate__c = termCondition.CalReportingEndDate__c;
                                termSchedule.TaskCreationDate__c = termCondition.CalReportingStartDate__c.addDays(-creationAge);
                                termSchedule.DueDate__c = termCondition.CalReportingEndDate__c.addDays(age);
                                if (termCondition.RecordType.Name == 'Reporting Requirement') {
                                    termSchedule.RecordTypeId = rctTypeListProgressReport;
                                } else {
                                    termSchedule.RecordTypeId = rctTypeListPaymentRequest;
                                }
                            } else if (termCondition.RecordType.Name == 'Site Visit') {
                                termSchedule.RecordTypeId = rctTypeListSiteVisit;
                                termSchedule.TaskCreationDate__c = startDate.addDays(-creationAge);
                                termSchedule.StartDate__c = startDate;
                                termSchedule.EndDate__c = endDate;
                                termSchedule.DueDate__c = endDate.addDays(age);
                            }
                            termSchedule.Status__c = 'Not Started';
                            System.debug('Create Fixed Schedule now ');
                            lstSchedules.add(termSchedule);
                        } else { // It is one of recurring types
                            // calculate the number of months for recurring reports

                            Integer noOfMonths = 0;

                            if (termCondition.RecordType.Name == 'Reporting Requirement' || termCondition.RecordType.Name == 'Payment Request') {
                                noOfMonths = (((termCondition.CalReportingEndDate__c.year()  - termCondition.CalReportingStartDate__c.YEAR() - 1) * 12) + (12 - termCondition.CalReportingStartDate__c.month() + 1) + termCondition.CalReportingEndDate__c.month());
                            } else if (termCondition.RecordType.Name == 'Site Visit') {
                                noOfMonths = startDate.monthsBetween(endDate);
                                if (endDate.day() > startDate.day()) noOfMonths++;
                            }

                            String frequencyType = termCondition.Frequency__c;
                            Integer count;
                            if (frequencyType == 'Monthly')
                                count = noOfMonths ;
                            else if (frequencyType == 'Quarterly')
                                count = noOfMonths / 3 ;
                            else if (frequencyType == 'Semi-Annually')
                                count = noOfMonths / 6 ;
                            else if (frequencyType == 'Annually')
                                count = noOfMonths / 12 ;

                            Date dt1 = null;
                            Date dt2 = null;

                            for (Integer i = 0; i < count ; i++) {
                                TermConditionSchedule__c  termSchedule = new TermConditionSchedule__c();
                                //Date reportStartDate= termCondition.CalReportingStartDate__c;
                                termSchedule.TermAndCondition__c = termCondition.Id;
                                termSchedule.ReportStatus__c = 'N/A';
                                dt1 = getUpdatedReportDate(frequencyType, i, startDate);
                                dt2 = getUpdatedReportDate(frequencyType, i + 1, startDate);
                                termSchedule.EndDate__c = i == count - 1 ? endDate : dt2.addDays(-1);
                                termSchedule.StartDate__c = dt1;
                                termSchedule.Status__c = 'Not Started';
                                termSchedule.TaskCreationDate__c = dt1.addDays(-creationAge);
                                termSchedule.DueDate__c = dt2.addDays(age);
                                if (termCondition.RecordType.Name == 'Reporting Requirement') {
                                    termSchedule.RecordTypeId = rctTypeListProgressReport;
                                } else if (termCondition.RecordType.Name == 'Site Visit') {
                                    termSchedule.RecordTypeId = rctTypeListSiteVisit;
                                } else if (termCondition.RecordType.Name == 'Payment Request') {
                                    termSchedule.RecordTypeId = rctTypeListPaymentRequest;
                                }
                                if (termSchedule.EndDate__c > termSchedule.StartDate__c)
                                    lstSchedules.add(termSchedule);

                            }
                        }
                    } else {
                        if (termCondition.RecordType.Name == 'Reporting Requirement') {
                            System.debug('Progress Report can not be created due to lack of data ');
                        } else if (termCondition.RecordType.Name == 'Site Visit') {
                            System.debug('Site Visit Schedule can not be created due to lack of data ');
                        } else {
                            System.debug('Payment Requests can not be created due to lack of data ');
                        }

                    }
                }// End of for loop (T&C)

            }// End of for loop (awards)

            List<Grant__c> grants = [SELECT Id, IsTCScheduleCreated__c FROM Grant__c WHERE Id IN :grantIds];

            for (Grant__c grant : grants) {
                grant.IsTCScheduleCreated__c = true;
            }

            if (lstSchedules.size() > 0) {
                SystemContextMethodsHelper systemContextMethodsHelper = new SystemContextMethodsHelper();
                systemContextMethodsHelper.insertTermCondSchedules(lstSchedules);
                System.debug('T&C debug');
                System.debug(lstSchedules);
                systemContextMethodsHelper.updateGrants(grants);
            }
            // insert lstSchedules;
        }
    }


    // Davinder's code

    /*
     * This method will create Progress Report Schedule based on following condition
     *   1.  Award is in Activated State
     *   2.  Award has one or more Reporting Requirements(this is a RecordType in Term and Condition Object)
     *
     *   Based on above conditions, one or more Progress Report Schedules will be created.
     *
      */
    /*Moved to combination method - Weike
    public void prepareProgressReportSchedule(List<Award__c> awards){

     Set<Id> awardIds = new Set<Id>();
     List<ProgressReports__c> lstReports= new List<ProgressReports__c>();
     List<TermConditionSchedule__c> lstSchedules = new List<TermConditionSchedule__c>();
     List<TermCondition__c> terms = new List<TermCondition__c>();
     ProgressReportsConfig__c progressRptCfg ;
     boolean checkDeepClone = true;
      */
    //Commented by Davinder : The amended Award was not creating any Schedules due to this check. Need to confirm with Ramu
    /*  for(Award__c awd : awards) {
          if (awd.DeepCloned__c == true) {
              checkDeepClone = false;
          }
      }*/
    /*
    if(checkDeepClone){
      // List<RecordType> rctTypeList= [select Id from RecordType where Name = 'Progress Report' and SobjectType =:AppUtils.getNamespacePrefix()+'TermConditionSchedule__c' limit 1];
        Id rctTypeList = Schema.SObjectType.TermConditionSchedule__c.getRecordTypeInfosByName().get('Progress Report').getRecordTypeId();

       String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
       if(appName=='StateAsGrantee')
          progressRptCfg = ProgressReportsConfig__c.getInstance('Grantee_Reports');
       else
          progressRptCfg = ProgressReportsConfig__c.getInstance('Grantor_Reports');

        Integer prReportAge = (Integer)progressRptCfg.ReportDueAge__c;
        Integer prReportCreationAge = (Integer)progressRptCfg.TaskCreationAge__c;
        for(Award__c c : awards){
          awardIds.add(c.Id);
        }
        Map<Id,TermCondition__c> termConditionMap = new Map<Id,TermCondition__c>([Select Id,Title__c ,Name,RecordType.Name,Award__c, Grant__c,CalReportingEndDate__c,CalReportingStartDate__c,ReportName__c,Category__c,Frequency__c ,ReportingFrequency__c  from Termcondition__c where RecordType.Name IN ('Reporting Requirement') and Award__c =: awardIds]);

         for(Award__c award : (List<Award__c>) awards) {
            Award__c awardold = (Award__c)trigger.oldmap.get(award.id);
            if('Activated'.equals(award.status__c) && ('Approved'.equals(awardold.status__c) || 'Grantee Accepted'.equals(awardold.status__c))) {
                 for(TermCondition__c termCondition : termConditionMap.values()){
                   if(termCondition.Award__c == award.Id && termCondition.CalReportingStartDate__c!=null && termCondition.CalReportingEndDate__c !=null){ // This is the TnC for current Award, create progress Report
                     if(termCondition.Frequency__c=='Fixed'){
                        Date reportStartDate= termCondition.CalReportingStartDate__c;
                        TermConditionSchedule__c  termSchedule = new TermConditionSchedule__c();
                        termSchedule.TermAndCondition__c= termCondition.Id;
                        termSchedule.ReportStatus__c='N/A';
                        termSchedule.StartDate__c =termCondition.CalReportingStartDate__c;
                        termSchedule.TaskCreationDate__c = termCondition.CalReportingEndDate__c.addDays(-prReportCreationAge);
                        termSchedule.RecordTypeId= rctTypeList;
                        termSchedule.EndDate__c = termCondition.CalReportingEndDate__c;
                        termSchedule.DueDate__c = termCondition.CalReportingEndDate__c.addDays(prReportAge);
                        termSchedule.Status__c = 'Not Started';
                        System.debug('Create Fixed Schedule now ');
                        lstSchedules.add(termSchedule);
                     }
                     else{  // It is one of recurring types
                  // calculate the number of months for recurring reports

                         Integer  noOfMonths = (((termCondition.CalReportingEndDate__c.year()  - termCondition.CalReportingStartDate__c.YEAR() - 1) *12) + (12 - termCondition.CalReportingStartDate__c.month() +1) + termCondition.CalReportingEndDate__c.month());
                         String frequencyType=termCondition.Frequency__c;
                         Integer count;
                         if(frequencyType=='Monthly')
                         count = noOfMonths ;
                         else if(frequencyType=='Quarterly')
                         count = noOfMonths/3 ;
                         else if(frequencyType=='Semi-Annually')
                         count = noOfMonths/6 ;
                         else if(frequencyType=='Annually')
                         count = noOfMonths/12 ;
                         Date startDate= termCondition.CalReportingStartDate__c;
                         Date endDate = termCondition.CalReportingEndDate__c;

                         for (Integer i=0;i<count ; i++){
                               TermConditionSchedule__c  termSchedule = new TermConditionSchedule__c();
                               Date reportStartDate= termCondition.CalReportingStartDate__c;
                               termSchedule.TermAndCondition__c= termCondition.Id;
                               termSchedule.ReportStatus__c='N/A';
                               Date dt1 = getUpdatedReportDate(frequencyType,i,startDate);
                               Date dt2 = getUpdatedReportDate(frequencyType,i+1,startDate);
                               termSchedule.TaskCreationDate__c = dt2.addDays(-prReportCreationAge);
                               termSchedule.StartDate__c = i==0?dt1:dt1.addDays(1);
                               termSchedule.RecordTypeId= rctTypeList;
                               termSchedule.EndDate__c = i==count-1?endDate:dt2;
                               termSchedule.DueDate__c = dt2.addDays(prReportAge);
                               termSchedule.Status__c = 'Not Started';
                               if(termSchedule.EndDate__c>termSchedule.StartDate__c)
                               lstSchedules.add(termSchedule);
                           }
                       }
                     }
                    else
                    System.debug('Progress Report can not be created due to lack of data ');
                }// End of for loop (T&C)
            }
         }// End of for loop (awards)
        if(lstSchedules.size()>0){
            SystemContextMethodsHelper systemContextMethodsHelper = new SystemContextMethodsHelper();
            systemContextMethodsHelper.insertTermCondSchedules(lstSchedules);
        }
          // insert lstSchedules;
    }
    }
    */
    //private Date getReportEndDate(String frequencytype, Integer count, Date startdate) {
    //    Integer numberOfDays = Date.daysInMonth(startDate.year(), startDate.month());
    //    Date lastDayOfMonth = Date.newInstance(startDate.year(), startDate.month(), numberOfDays);
    //    Date rptStartDate;
    //    if (frequencytype == 'Monthly') {
    //        rptStartDate = lastDayOfMonth.addmonths(count * 1);
    //    } else if (frequencytype == 'Quarterly') {
    //        rptStartDate = lastDayOfMonth.addmonths(count * 3);
    //    } else if (frequencytype == 'Semi-Annually') {
    //        rptStartDate = lastDayOfMonth.addmonths(count * 6);
    //    } else if (frequencytype == 'Annually') {
    //        rptStartDate = lastDayOfMonth.addmonths(count * 12);
    //    }
    //    return rptStartDate;
    //}

    private Date getUpdatedReportDate(String frequencytype, Integer count, Date startdate) {
        Date rptEndDate;
        if (frequencytype == 'Monthly') {
            rptEndDate = startdate.addmonths(count * 1);
        } else if (frequencytype == 'Quarterly') {
            rptEndDate = startdate.addmonths(count * 3);
        } else if (frequencytype == 'Semi-Annually') {
            rptEndDate = startdate.addmonths(count * 6);
        } else if (frequencytype == 'Annually') {
            rptEndDate = startdate.addmonths(count * 12);
        }
        return rptEndDate;
    }


    //private Date getSiteVisitsReportEndDate(String frequencytype, Integer count, Date startdate) {
    //    Date rptEndDate;
    //    if (frequencytype == 'Monthly') {
    //        rptEndDate = startdate.addmonths(count * 1);
    //    } else if (frequencytype == 'Quarterly') {
    //        rptEndDate = startdate.addmonths(count * 3);
    //    } else if (frequencytype == 'Semi-Annually') {
    //        rptEndDate = startdate.addmonths(count * 6);
    //    } else if (frequencytype == 'Annually') {
    //        rptEndDate = startdate.addmonths(count * 12);
    //    }
    //    return rptEndDate;
    //}

// Prepares Site Visit Schedules
    /*Moved to combination method - Weike
     public void prepareSiteVisitSchedule(List<Award__c> awards){
        ProgressReportsConfig__c progressRptCfg ;

        String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
        if(appName=='StateAsGrantee'){
             progressRptCfg = ProgressReportsConfig__c.getInstance('Grantee_Reports');
        }
       else{
             progressRptCfg = ProgressReportsConfig__c.getInstance('Grantor_Reports');
       }

        Integer sVisitAge = (Integer)progressRptCfg.VisitDueAge__c;
        Integer sVisitTaskCreationAge = (Integer)progressRptCfg.SiteVisitTaskCreationAge__c;
        Set<Id> awardIds = new Set<Id>();
        List<TermConditionSchedule__c> lstSchedules = new List<TermConditionSchedule__c>();
        List<TermCondition__c> terms = new List<TermCondition__c>();
        for(Award__c c : awards){
             awardIds.add(c.Id);
          }

           boolean checkDeepClone = true;
           */
    //Commented by Davinder : The amended Award was not creating any Schedules due to this check. Need to confirm with Ramu
    /* for(Award__c awd : awards) {
         if (awd.DeepCloned__c == true) {
             checkDeepClone = false;
         }
     }  */
    /*
    if(checkDeepClone) {
      Map<Id,TermCondition__c> termConditionMap = new Map<Id,TermCondition__c>([Select Id,Name,Award__c,ReportName__c,Frequency__c,Category__c,FixedEndDate__c,Description__c,ReportingFrequency__c,SiteVisitDateTime__c,VisitEndDateTime__c,SiteVisitLocation__c,SecondaryLocation__c  from Termcondition__c where RecordType.Name IN ('Site Visit') and Award__c =: awardIds]);
     // List<RecordType> rctTypeList= [select Id,Name from RecordType where Name = 'Site Visit' and SobjectType =:AppUtils.getNamespacePrefix()+'TermConditionSchedule__c' limit 1];
        Id rctTypeList = Schema.SObjectType.TermConditionSchedule__c.getRecordTypeInfosByName().get('Site Visit').getRecordTypeId();
         for(Award__c award : (List<Award__c>) awards) {
            Award__c awardold = (Award__c)trigger.oldmap.get(award.id);
            if('Activated'.equals(award.status__c) && ('Approved'.equals(awardold.status__c) || 'Grantee Accepted'.equals(awardold.status__c)))
            {
               for(TermCondition__c termCondition : termConditionMap.values())// Getting list of TnC
                {
                  if(termCondition.Award__c == award.Id ) // This is the TnC for current Award, create schedule
                    {
                      Date visitStartDate= (termCondition.SiteVisitDateTime__c).date();
                      Date visitEndDate= (termCondition.VisitEndDateTime__c).date();
                      if(termCondition.Frequency__c=='Fixed')
                      {
                        TermConditionSchedule__c  termSchedule = new TermConditionSchedule__c();
                        termSchedule.TermAndCondition__c= termCondition.Id;
                        termSchedule.ReportStatus__c='N/A';
                        termSchedule.RecordTypeId= rctTypeList;
                        termSchedule.TaskCreationDate__c = visitStartDate.addDays(sVisitTaskCreationAge);
                        termSchedule.StartDate__c = visitStartDate;
                        termSchedule.EndDate__c = visitEndDate;
                        termSchedule.Status__c = 'Not Started';
                        termSchedule.DueDate__c = visitEndDate.addDays(sVisitAge);
                        lstSchedules.add(termSchedule);
                      }
                      else  // It is one of recurring types
                      {
                           // calculate the number of months for recurring reports
                           //  Integer  noOfMonths = (((visitDate.year()  - visitDate.YEAR() - 1) *12) + (12 - visitDate.month() +1) + visitDate.month());
                          Integer noOfMonths = visitStartDate.monthsBetween(visitEndDate);
                          if (visitEndDate.day() > visitStartDate.day()) noOfMonths++;

                          String frequencyType=termCondition.Frequency__c;
                          Integer count;

                          if(frequencyType=='Monthly')
                          count = noOfMonths ;
                          else if(frequencyType=='Quarterly')
                          count = noOfMonths/3 ;
                          else if(frequencyType=='Semi-Annually')
                          count = noOfMonths/6 ;
                          else if(frequencyType=='Annually')
                          count = noOfMonths/12 ;
                          for (Integer i=0;i<count ; i++)
                           {
                              Date dt1 = getUpdatedReportDate(frequencyType,i,visitStartDate);
                              Date dt2 = getUpdatedReportDate(frequencyType,i+1,visitStartDate);
                              TermConditionSchedule__c  termSchedule = new TermConditionSchedule__c();
                              termSchedule.StartDate__c = i==0?dt1:dt1.addDays(1);
                              termSchedule.RecordTypeId= rctTypeList;
                              termSchedule.EndDate__c = i==count-1?visitEndDate:dt2;
                              termSchedule.DueDate__c = dt2.addDays(sVisitTaskCreationAge);
                              termSchedule.TaskCreationDate__c = dt1.addDays(-sVisitTaskCreationAge);
                              termSchedule.ReportStatus__c='N/A';
                              termSchedule.Status__c = 'Not Started';
                              termSchedule.TermAndCondition__c= termCondition.Id;
                              if(termSchedule.EndDate__c>termSchedule.StartDate__c)
                              lstSchedules.add(termSchedule);
                           }
                      }
                   }
                   else
                    System.debug('Site Visit Schedule can not be created due to lack of data ');
              }// end of for loop (T&C)
            }
        } // end of for loop (Awards)
        if(lstSchedules.size()>0){
            SystemContextMethodsHelper systemContextMethodsHelper = new SystemContextMethodsHelper();
            systemContextMethodsHelper.insertTermCondSchedules(lstSchedules);
        }
         //insert lstSchedules;
    }
    }
    */
//Sets amendments to approved instead of completed if the award is deleted
    private void updateAmendments(List<Award__c> awards) {
        Set<Id> grantIds = new Set<Id>();
        for (Award__c award : awards) {
            grantIds.add(award.Grant__c);
        }
        List<Award__c> oldAwards = [SELECT Id, CreatedDate, Grant__c, Name FROM Award__c WHERE Status__c = 'Issued' AND Grant__c IN: GrantIds];
        Map<Id, Award__c> awardMap = new Map<Id, Award__c>();
        for (Award__c award : oldAwards) {
            if (awardMap.containsKey(award.Grant__c)) {
                if (awardMap.get(award.Grant__c).CreatedDate < award.CreatedDate) {
                    awardMap.remove(award.Grant__c);
                    awardMap.put(award.Grant__c, award);
                }
            } else {
                awardMap.put(award.Grant__c, award);
            }
        }
        Set<Id> awardIds = new Set<Id>();
        for (Award__c award : awardMap.values()) {
            awardIds.add(award.Id);
        }
        List<AmendmentRequest__c> requests = [SELECT Status__c FROM AmendmentRequest__c WHERE Award__c IN: awardIds];
        for (AmendmentRequest__c request : requests) {
            if (request.Status__c == 'Completed') {
                request.Status__c = 'Approved';
            }
        }
        if (requests.size() > 0) {
            update requests;
        }
    }

    //Sets amendments to approved instead of completed if the award is deleted
    //private void deleteGrant(List<Award__c> awards) {
    //    Set<String> grantIds = new Set<String>();
    //    for (Award__c award : awards) {
    //        grantIds.add(award.Grant__c);
    //    }
    //    List<Grant__c> grantsToDelete = new List<Grant__c>();
    //    List<Grant__c> grants = [SELECT Id, (SELECT Id FROM Awards__r) FROM Grant__c WHERE Id IN: grantIds];
    //    for (Grant__c grant : grants) {
    //        if (grant.awards__r.size() == 0) {
    //            grantsToDelete.add(grant);
    //        }
    //    }
    //    if (grantsToDelete.size() > 0) {
    //        delete grantsToDelete;
    //    }
    //}

    /*Added by Ramu to create Payment Requst Schedules in Monitoring When Award is Activated*/
    /*
    public void preparePaymentRequestSchedule(List<Award__c> awards){
       Set<Id> awardIds = new Set<Id>();
       List<TermConditionSchedule__c> lstSchedules = new List<TermConditionSchedule__c>();
       boolean checkDeepClone = true;

       for(Award__c awd : awards) {
           if (awd.DeepCloned__c == true) {
               checkDeepClone = false;
           }
       }

       if(checkDeepClone) {
          // List<RecordType> rctTypeList= [select Id from RecordType where Name = 'Payment Request' and SobjectType =:AppUtils.getNamespacePrefix()+'TermConditionSchedule__c' limit 1];
          Id rctTypeList = Schema.SObjectType.TermConditionSchedule__c.getRecordTypeInfosByName().get('Payment Request').getRecordTypeId();
           List<TermCondition__c> terms = new List<TermCondition__c>();
           for(Award__c awd : awards){
             awardIds.add(awd.Id);
           }
           Map<Id,TermCondition__c> termConditionMap = new Map<Id,TermCondition__c>([Select Id,Title__c ,Name,RecordType.Name,Award__c, Grant__c,CalReportingEndDate__c,CalReportingStartDate__c,ReportName__c,Category__c,Frequency__c ,ReportingFrequency__c  from Termcondition__c where RecordType.Name IN ('Payment Request') and Award__c =: awardIds]);
           for(Award__c award : (List<Award__c>) awards) {
               Award__c awardold = (Award__c)trigger.oldmap.get(award.id);
               if('Activated'.equals(award.status__c) && 'Grantee Accepted'.equals(awardold.status__c)) // no need to check this condition
               {
                   for(TermCondition__c termCondition : termConditionMap.values())// Getting list of TnC
                   {
                       if(termCondition.Award__c == award.Id && termCondition.CalReportingStartDate__c!=null && termCondition.CalReportingEndDate__c !=null){
                       System.debug('Create Payment Requests Schedule  now '+termCondition.Name);
                        if(termCondition.Frequency__c=='Fixed'){
                           TermConditionSchedule__c  termSchedule = new TermConditionSchedule__c();
                           termSchedule.TermAndCondition__c= termCondition.Id;
                           termSchedule.ReportStatus__c='N/A';
                           termSchedule.StartDate__c =termCondition.CalReportingStartDate__c;
                           termSchedule.RecordTypeid= rctTypeList;
                           termSchedule.EndDate__c = termCondition.CalReportingEndDate__c;
                           termSchedule.DueDate__c = termCondition.CalReportingEndDate__c.addDays(7);
                           System.debug('Create Fixed Payment Requests Schedule now ');
                           lstSchedules.add(termSchedule);
                           }
                        else{
                     //calculate the number of months for recurring reports
                        Integer  noOfMonths = (((termCondition.CalReportingEndDate__c.year()  - termCondition.CalReportingStartDate__c.YEAR() - 1) *12) + (12 - termCondition.CalReportingStartDate__c.month() +1) + termCondition.CalReportingEndDate__c.month());
                        String frequencyType=termCondition.Frequency__c;
                        Integer count;
                        if(frequencyType=='Monthly')
                        count = noOfMonths ;
                        else if(frequencyType=='Quarterly')
                        count = noOfMonths/3 ;
                        else if(frequencyType=='Semi-Annually')
                        count = noOfMonths/6 ;
                        else if(frequencyType=='Annually')
                        count = noOfMonths/12 ;
                        system.debug('noOfMonths    '+noOfMonths );
                        system.debug('count    '+count );
                        Date startDate= termCondition.CalReportingStartDate__c;
                        Date endDate = termCondition.CalReportingEndDate__c;
                        for (Integer i=0;i<=count ; i++){
                              system.debug('count in loop  '+i);
                              TermConditionSchedule__c  termSchedule = new TermConditionSchedule__c();
                              termSchedule.TermAndCondition__c= termCondition.Id;
                              termSchedule.ReportStatus__c='N/A';
                              Date dt1 = getReportEndDate(frequencyType,i-1,startDate);
                              Date dt2 = getReportEndDate(frequencyType,i,startDate);
                              termSchedule.StartDate__c = dt1.addDays(1);
                              termSchedule.RecordTypeId= rctTypeList;
                              termSchedule.EndDate__c = dt2;
                              termSchedule.DueDate__c = dt2.addDays(7);
                              System.debug('Create Recurring Payment Requests Schedule now ');
                              lstSchedules.add(termSchedule);
                        }
                     }
                   }
                       else
                       System.debug('Payment Requests can not be created due to lack of data ');
             }
           }
         }
         if(lstSchedules.size()>0){
                 //insert lstSchedules;
               SystemContextMethodsHelper systemContextMethodsHelper = new SystemContextMethodsHelper();
               systemContextMethodsHelper.insertTermCondSchedules(lstSchedules);
       }
    }
    }
    */
    private void UpdateRemainingAmountinAwardBC(List<Award__c> newAwards) {
        List<id> awardids = new List<id>();
        Set<id> grantIds = new Set<Id>();
        Map<Id, String> grantBudCatMap = new Map<Id, String>();
        List<AwardBudgetCategory__c> newawardbudcatlist = new List<AwardBudgetCategory__c>();
        boolean implicit = false;
        Decimal IndirectAmount = 0;
        for (Award__c eachAward : newAwards) {
            if (eachAward.Status__c == 'Approved' && eachAward.IndirectCostRateDecision__c == 'Implicit') {
                awardids.add(eachAward.Id);
                GrantIds.add(eachAward.Grant__c);
            }
        }

        for (Grant__c grant : [Select Id, TypeOfBudgetCategories__c FROM Grant__c where Id in:GrantIds ]) {
            grantBudCatMap.put(grant.Id, grant.TypeOfBudgetCategories__c);
        }
        List<AwardBudgetCategory__c> awdbclist = [Select Id, Award__c, BudgetCategory__c, Amount1__c, BudgetCategoryName__c, RemainingAmount__c from AwardBudgetCategory__c where Award__c in :awardids];
        for (Award__c eachAward : newAwards) {
            if (eachAward.Status__c == 'Approved' && eachAward.IndirectCostRateDecision__c == 'Implicit') {
                implicit = true;
                String budCat = grantBudCatMap.get(eachAward.Grant__c);
                if (budCat.equals('Construction & Non Construction')) {
                    budCat = 'Indirect Cost' + 'Construction';
                } else {
                    budCat = 'Indirect Cost' + budCat;
                }

                for (AwardBudgetCategory__c awdbc : awdbclist) {
                    if (awdbc.BudgetCategoryName__c != GNT.KeyValueStoreHelper.getTextValue(budCat, true) && awdbc.Award__c == eachAward.id) {
                        awdbc.RemainingAmount__c = (awdbc.Amount1__c - ((awdbc.Amount1__c * eachAward.ApprovedIndirectCostRate__c) / 100)).setScale(2);
                        IndirectAmount = (IndirectAmount + ((awdbc.Amount1__c * eachAward.ApprovedIndirectCostRate__c) / 100)).setScale(2);
                        newawardbudcatlist.add(awdbc);
                    }
                }
                if (implicit) {
                    for (AwardBudgetCategory__c awdbc : awdbclist) {
                        if (awdbc.BudgetCategoryName__c == GNT.KeyValueStoreHelper.getTextValue(budCat, true) && awdbc.Award__c == eachAward.id) {
                            awdbc.RemainingAmount__c = IndirectAmount;
                            newawardbudcatlist.add(awdbc);
                        }
                    }
                }
            }
        }
        update newawardbudcatlist;
    }

    /*
    * Insert Grant Connector after update
    * Get parentGrant Info - Award--> FA --> FS --> Fed Grant Info
    */

    //public void insertGrantConnector(List<Award__c> awards) {
    //    // Put FederalGrant__c and State(Sub-Awards) in a Map

    //    Set<Id> awardIds = new Set<Id>();

    //    for (Award__c award : awards) {
    //        if (award.status__c.equals('Activated')) {
    //            awardIds.add(award.Id);
    //        }
    //    }

    //    if (awardIds.size() > 0) {
    //        List<AwardFundingAccount__c> awardFundingAccounts = [select Award__c, FundingAccount__r.FundingSource__r.Grant__c
    //                from AwardFundingAccount__c
    //                where Award__c IN :awardIds];

    //        Map<id, AwardFundingAccount__c> awardMap = new  Map<id, AwardFundingAccount__c>();
    //        for (AwardFundingAccount__c awardFundingAccount : awardFundingAccounts) {
    //            awardMap.put(awardFundingAccount.Award__c, awardFundingAccount);
    //        }

    //        List<GrantConnector__c> grantConnectors = new List<GrantConnector__c>();

    //        for (Award__c award : awards) {
    //            AwardFundingAccount__c awardFundingAccount = awardMap.get(award.Id);
    //            GrantConnector__c grantConnector = new GrantConnector__c();
    //            grantConnector.ChildGrant__c = award.Grant__c;
    //            grantConnector.MasterGrant__c = awardFundingAccount.FundingAccount__r.FundingSource__r.Grant__c;
    //            if (awardFundingAccount.FundingAccount__r.FundingSource__r.Grant__c != null) {
    //                grantConnectors.add(grantConnector);
    //            }
    //        }

    //        for (GrantConnector__c gc : grantconnectors) {
    //            system.debug('*** Child Grant - ' + gc.ChildGrant__c + ' Master Grant  - ' + gc.MasterGrant__c);
    //        }

    //        insert grantconnectors;
    //    }
    //}

    /* Update address if postal code given */

    public void updateAddress(List<Award__c> awards) {


        Set<Id> awardIds = new Set<Id>();
        Set<string> setZip = new Set<string>();

        for (Award__c award : awards) {
            if (award.zipcode__c != null) {
                awardIds.add(award.Id);
            }
        }


        for (Award__c award : awards) {
            if (award.zipcode__c != null) {
                setZip.add(award.zipcode__c);
            }
            system.debug('>>>>>setZip' + setZip);
        }

        if (awardIds.size() > 0) {
            List<USDemographicInfo__c> ListUSDemographicInfo = [select id, name, StateName__c, PrimaryCity__c, County__c,
                                       CongressionalDistrict__c
                                       from USDemographicInfo__c
                                       where Id in:setZip];

            Map<string, USDemographicInfo__c> demographicMap = new  Map<string, USDemographicInfo__c>();
            for (USDemographicInfo__c USDemographicInfo : ListUSDemographicInfo ) {
                demographicMap.put(USDemographicInfo.name, USDemographicInfo);
            }
            system.debug('>>>>>demographicMap' + demographicMap);

            List<Award__c> updateAward = new List<Award__c>();

            List<Award__c> awardZip = [select id, name, zipcode__r.name, County__c, State__c, City__c
                                       from Award__c
                                       where Id IN :awardIds];

            for (Award__c award : awardZip) {
                if (award.zipcode__c != null) {
                    USDemographicInfo__c USDemographicInfo = demographicMap.get(award.zipcode__r.name);
                    system.debug('>>>>>zip' + award.zipcode__r.name);
                    system.debug('>>>>>USDemographicInfo ' + USDemographicInfo);
                    award.County__c = USDemographicInfo.County__c;

                }
                updateAward.add(award);
            }
            update updateAward;


        }
    }

    private void createGranteeBudgetCategories(List<Award__c> awards) {
        system.debug('Inside grantee budget categories -- *** sarat');

        Map<Id, Award__c> awardsList = new Map<Id, Award__c>([select Id, Grant__c, Name, Grant__r.Application__c, Application__c,
                BudgetPeriod__c, Grant__r.Program__r.BuildupFunctionalityNeeded__c, Grant__r.TypeOfBudgetCategories__c , Grant__r.Program__c,
                Grant__r.Application__r.Announcement__r.DetailedBudgetingRequired__c, IndirectCostRateDecision__c
                from Award__c
                where Id IN :awards]);

        List<Id> applicationsIds = new List<Id>();
        Map<Id, Id> awardApplicationMap = new Map<Id, Id>();
        List<Award__c> granteeImplicitExplicitAwards = new List<Award__c>();
        Map<Id, Id> awardGrantMap = new Map<Id, Id>();

        for (Award__c award : awardsList.values()) {
            if (award.Grant__r.Application__c != null) {
                applicationsIds.add(award.Grant__r.Application__c);
                awardApplicationMap.put(award.Id, award.Grant__r.Application__c);
            } else {
                granteeImplicitExplicitAwards.add(award);
                awardGrantMap.put(award.Id, award.Grant__c);
            }
        }

        if (granteeImplicitExplicitAwards.size() > 0) {
            List<BudgetPeriod__c> grantBudgetPeriods = [select Year__c, BudgetStartDate__c, BudgetEndDate__c, Status__c, Modified__c,
                                  Grant__c
                                  from BudgetPeriod__c
                                  where Grant__c IN :awardGrantMap.values()];

            List<GrantServiceArea__c> grantServiceAreas = [select Id, Name, Code__c, ServiceArea__r.Title__c,
                                      AllocationPercentage__c, AmountAllocated__c
                                      from GrantServiceArea__c
                                      where Grant__c IN :awardGrantMap.values()];
            List<BudgetCategory__c>  externalBudgetCategoriesList = [Select Id, Name, RecordType.Name, Class__c
                    from BudgetCategory__c
                    where RecordType.Name = 'External'];


            List<BudgetCategory__c> finalList = new List<BudgetCategory__c>();
            List<BudgetCategory__c> constructionList = new List<BudgetCategory__c>();
            List<BudgetCategory__c> nonConstructionList = new List<BudgetCategory__c>();
            List<AwardBudgetCategory__c> awardBudCatList = new List<AwardBudgetCategory__c>();

            for (BudgetCategory__c budCat : externalBudgetCategoriesList) {
                if (budCat.Class__c == 'Construction') {
                    constructionList.add(budCat);
                } else if (budCat.Class__c == 'Non construction') {
                    nonConstructionList.add(budCat);
                }
            }

            for (GrantServiceArea__c grantSA : grantServiceAreas) {
                for (Award__c awd : granteeImplicitExplicitAwards) {
                    //  If the associated grant does not have an application, determine the budget category from TypeOfBudgetCategories__c field
                    /* Creates a map of Grant and type of Budget category to be included for all its associated awards */

                    if (awd.Grant__r.TypeOfBudgetCategories__c == 'Construction') {
                        finalList = constructionList;
                    } else if (awd.Grant__r.TypeOfBudgetCategories__c == 'Non Construction') {
                        finalList = nonconstructionList;
                    }
                    for (BudgetCategory__c budcat : finalList) {
                        AwardBudgetCategory__c abc = new AwardBudgetCategory__c();
                        abc.Award__c = awd.Id;
                        abc.BudgetCategory__c = budcat.ID;
                        abc.BudgetPeriod__c = awd.BudgetPeriod__c;
                        abc.GrantServiceArea__c = grantSA.Id;
                        awardBudCatList.add(abc);
                    }
                }
            }
            insert awardBudCatList;
        }

        system.debug('Application Ids --> ' + applicationsIds);
        system.debug('Award Application Map size --> ' + awardApplicationMap.size());
        system.debug('Award Application Map --> ' + awardApplicationMap.size());

        if (awardApplicationMap.size() > 0) {
            List<Id> applicationBudgetCategoryIds = new List<Id>();
            Map<Id, List<ApplicationBudgetCategory2__c>> applicationBudgetCategoriesMap =
                new Map<Id, List<ApplicationBudgetCategory2__c>>();
            List<ApplicationBudgetCategory2__c> applicationBudgetCategoriesList =
                [select Id, ServiceArea__c, BudgetCategory__c, Application__c,
                 GrantorAmount__c, GranteeAmount__c, Amount__c, GranteeShare__c, BudgetCategory__r.Name,
                 ServiceArea__r.ServiceAreaLookup__c, BudgetCategory__r.RowNumber__c
                 from ApplicationBudgetCategory2__c
                 where Application__c IN :applicationsIds
                 and BudgetPeriod__r.SequenceNumber__c = 1.0];
            for (ApplicationBudgetCategory2__c app : applicationBudgetCategoriesList) {
                applicationBudgetCategoryIds.add(app.Id);
                if (!applicationBudgetCategoriesMap.containsKey(app.Application__c)) {
                    applicationBudgetCategoriesMap.put(app.Application__c, new List<ApplicationBudgetCategory2__c>());
                }
                applicationBudgetCategoriesMap.get(app.Application__c).add(app);
            }

            Map<Id, List<BuildUpItem__c>> appBudCatToBuildUpMap =
                new Map<Id, List<BuildUpItem__c>>();
            List<BuildUpItem__c> applicationbuildUpItemsList =
                [select Title__c, Narrative__c, StartDate__c, EndDate__c, ApplicationBudgetCategory__r.Application__r.AmountThisAction__c,
                 ApplicationBudgetCategory__r.Application__r.RequestedAmount__c, UnitPrice__c, Quantity__c, UnitofMeasurement__c, OtherCharges__c,
                 TotalDirect__c, AllowableDirect__c , Indirect__c, TotalIndirect__c,
                 GrandTotal__c, GrantorShare__c, GranteeShare__c,
                 ApplicationBudgetCategory__c
                 from BuildUpItem__c
                 where ApplicationBudgetCategory__c IN :applicationBudgetCategoryIds];

            for (BuildUpItem__c buildUpItem : applicationbuildUpItemsList) {
                System.debug('MANUALDEBUG >>> buildUpItem: ' + buildUpItem);
                if (!appBudCatToBuildUpMap.containsKey(buildUpItem.ApplicationBudgetCategory__c)) {
                    appBudCatToBuildUpMap.put(buildUpItem.ApplicationBudgetCategory__c, new List<BuildUpItem__c>());
                }
                appBudCatToBuildUpMap.get(buildUpItem.ApplicationBudgetCategory__c).add(buildUpItem);
            }

            system.debug('Application Build up line items' + appBudCatToBuildUpMap);
            // Service areas - If application then application other wise defalut - check with Ramu

            List<AwardBudgetCategory__c> awardBudgetCategories = new List<AwardBudgetCategory__c>();

            for (Id awardKey : awardApplicationMap.keySet()) {
                Id applicationKey = awardApplicationMap.get(awardKey);
                Award__c award = awardsList.get(awardKey);
                List<ApplicationBudgetCategory2__c> appliationBudgetCategories =
                    applicationBudgetCategoriesMap.get(applicationKey);
                if (appliationBudgetCategories != null) {
                    for (ApplicationBudgetCategory2__c applicationBudgetCategory : appliationBudgetCategories) {
                        AwardBudgetCategory__c awardBudgetCategory = new AwardBudgetCategory__c();
                        awardBudgetCategory.Award__c = awardKey;
                        awardBudgetCategory.ServiceArea__c = applicationBudgetCategory.ServiceArea__r.ServiceAreaLookup__c;
                        awardBudgetCategory.BudgetCategory__c = applicationBudgetCategory.BudgetCategory__c;
                        awardBudgetCategory.GrantorAmount__c = applicationBudgetCategory.GrantorAmount__c;
                        awardBudgetCategory.GranteeAmount__c = applicationBudgetCategory.GranteeAmount__c;
                        awardBudgetCategory.Amount__c = applicationBudgetCategory.Amount__c;
                        awardBudgetCategory.BudgetPeriod__c = award.BudgetPeriod__c;
                        awardBudgetCategory.ClonedFromApplicationBudgetCategory__c = applicationBudgetCategory.Id;

                        awardBudgetCategories.add(awardBudgetCategory);
                    }
                }
            }
            insert awardBudgetCategories;

            List<BuildUpItem__c> awardBuildUpItems = new List<BuildUpItem__c>();

            // compare applicationbudgetcategories to awardbudgetcategories to get buildupitems

            for (Id awardKey : awardApplicationMap.keySet()) {
                Award__c award = awardsList.get(awardKey);
                Id applicationKey = awardApplicationMap.get(awardKey);
                List<ApplicationBudgetCategory2__c> applicationBudgetCategories =
                    applicationBudgetCategoriesMap.get(applicationKey);
                //if(applicationBudgetCategories != null){
                for (ApplicationBudgetCategory2__c applicationBudgetCategory : applicationBudgetCategories) {
                    for (AwardBudgetCategory__c awardBudgetCategory : awardBudgetCategories) {
                        if (awardBudgetCategory.Award__c.equals(awardKey) &&
                                applicationBudgetCategory.BudgetCategory__c.equals(
                                    awardBudgetCategory.BudgetCategory__c) &&
                                applicationBudgetCategory.ServiceArea__r.ServiceAreaLookup__c.equals(
                                    awardBudgetCategory.ServiceArea__c)) {
                            // add only if the key exists in the map
                            List<BuildUpItem__c> appbuildupitems = new List<BuildUpItem__c>();
                            if (appBudCatToBuildUpMap.containsKey(applicationBudgetCategory.Id)) {
                                appbuildupitems = appBudCatToBuildUpMap.get(applicationBudgetCategory.Id);
                            }
                            for (BuildUpItem__c buildUpItem : appbuildupitems) {
                                BuildUpItem__c awardBuildUpItem = new BuildUpItem__c();
                                //Decimal conversionFactor = buildUpItem.ApplicationBudgetCategory__r.Application__r.AmountThisAction__c / buildUpItem.ApplicationBudgetCategory__r.Application__r.RequestedAmount__c;
                                awardBuildUpItem.Title__c = buildUpItem.Title__c;
                                awardBuildUpItem.Narrative__c = buildUpItem.Narrative__c;
                                awardBuildUpItem.StartDate__c = buildUpItem.StartDate__c;
                                awardBuildUpItem.EndDate__c = buildUpItem.EndDate__c;
                                awardBuildUpItem.UnitPrice__c = buildUpItem.UnitPrice__c;
                                awardBuildUpItem.Quantity__c = buildUpItem.Quantity__c;
                                awardBuildUpItem.UnitofMeasurement__c = buildUpItem.UnitofMeasurement__c;
                                awardBuildUpItem.OtherCharges__c = buildUpItem.OtherCharges__c;
                                awardBuildUpItem.AllowableDirect__c = buildUpItem.AllowableDirect__c;
                                awardBuildUpItem.Indirect__c = buildUpItem.Indirect__c;
                                awardBuildUpItem.GrantorShare__c = buildUpItem.GrantorShare__c;
                                awardBuildUpItem.AwardBudgetCategory__c = awardBudgetCategory.Id;

                                awardBuildUpItems.add(awardBuildUpItem);
                            }
                        }
                    }
                }
                //}
            }
            insert awardBuildUpItems;
        }
    }

    /**
    * @author: smahavratayajula
    * This method copies Application Budget Categories and their respective BuildUpItems to
    * AwardBudgetCategories and their respective BuildUpItems
    * DataStructure --> {Award1-{Application1-{AwardBudCat1-{LineItems1,LineItem2..LineItem_N},AwardBudCat2..AwardBudCat_N}}}
    * Conditions -
    * 1. This method should execute for StateasGrantor
    * 2. If (Application exists and buildup functionality required) --> copy applicationbudgetcat's and BuilUpItems
    *       else copy only ApplicationBudgetCategories to AwardBudgetCategories
    * 3. If (Application does not exist) --> Copy Default budget categories
    */

    public void copyApplicationBudgetDetails(List<Award__c> awards) {

        Map<Id, Award__c> awardsList = new Map<Id, Award__c>([select Id, Grant__c, Name, Grant__r.Application__c, Application__c,
                BudgetPeriod__c, GrantorOrganization__c, Grant__r.Program__r.BuildupFunctionalityNeeded__c, Grant__r.Program__c,
                Grant__r.Application__r.Announcement__r.DetailedBudgetingRequired__c, BudgetNarrativeRead__c, Application__r.TotalFederalMatch__c, Application__r.CreatedDate, Application__r.IndirectCostPercentage__c, ProgramBudgetTypeUSBE__c
                from Award__c
                where Id IN :awards]);

        List<Id> applicationsIds = new List<Id>();
        List<Award__c> novelAwards = new List<Award__c>();

        Map<Id, Id> awardApplicationMap = new Map<Id, Id>();
        Map<Id, Map<Id, Id>> awardToGrantToProgramMap = new Map<Id, Map<Id, Id>>();
        Map<Id, Id> awardProgramMap = new Map<Id, Id>();
        Set<Id> programIds = new Set<Id>();

        //JC--------------
        Set<String> grantorOrg = new Set<String>();
        //JC--------------


        for (Award__c award : awardsList.values()) {
            if (award.Grant__r.Application__c != null) {
                applicationsIds.add(award.Grant__r.Application__c);
                awardApplicationMap.put(award.Id, award.Grant__r.Application__c);
            }/* else if (award.Grant__r.Application__c == null) {
                novelAwards.add(award);
            }*/
            else {
                programIds.add(award.Grant__r.Program__c);
                awardProgramMap.put(award.Id, award.Grant__r.Program__c);
            }
            //JC--------------
            grantorOrg.add(award.GrantorOrganization__c);
            //JC--------------
        }
        System.debug('MANUALDEBUG >>> grantorOrg = ' + grantorOrg);

        if (programIds.size() > 0) {
            List<ProgramServiceArea__c> programServiceAreasList = [select Id, Name, Program__c, ServiceArea__c
                    FROM ProgramServiceArea__c
                    where Program__c = :programIds];

            List<ProgramBudgetCategory__c> programBudgetCategoresList = [select Id, Program__c, BudgetCategory__c
                    from ProgramBudgetCategory__c
                    where Program__c = :programIds];
            //Map<Id, List<ProgramServiceArea__c>> programProgramServiceAreaMap = new Map<Id, List<ProgramServiceArea__c>>();
            Set<Id> programWithServiceAreas = new Set<Id>();
            List<Award__c> awardsWithSericeArea = new List<Award__c>();
            List<Award__c> awardsWithNoSericeArea = new List<Award__c>();

            for (ProgramServiceArea__c programServiceArea : programServiceAreasList) {
                programWithServiceAreas.add(programServiceArea.Program__c);
            }

            for (Award__c award : awardsList.values()) {
                if (programWithServiceAreas.contains(award.Grant__r.Program__c)) {
                    awardsWithSericeArea.add(award);
                } else {
                    awardsWithNoSericeArea.add(award);
                }
            }
            System.debug('MANUALDEBUG >>> insertingAwardBudgetCategories from Program');
            insertAwardBudgetCategoriesFromProgramWithSericeArea(awardsWithSericeArea, programServiceAreasList,
                    programBudgetCategoresList, awardProgramMap);
            insertAwardBudgetCategoriesFromProgramWithoutSericeArea(awardsWithNoSericeArea, programBudgetCategoresList,
                    awardProgramMap);
        }

        if (novelAwards.size() > 0) {
            //    insertDefalutAwardBudgetCategories(novelAwards);
        }

        System.debug('MANUALDEBUG >>> Going through application mapping');
        if (awardApplicationMap.size() > 0) {
            List<Id> applicationBudgetCategoryIds = new List<Id>();
            Map<Id, List<ApplicationBudgetCategory2__c>> applicationBudgetCategoriesMap =
                new Map<Id, List<ApplicationBudgetCategory2__c>>();
            List<ApplicationBudgetCategory2__c> applicationBudgetCategoriesList =
                [select Id, ServiceArea__c, BudgetCategory__c, Application__c,
                 GrantorAmount__c, GranteeAmount__c, Amount__c, GranteeShare__c, BudgetCategory__r.Name,
                 ServiceArea__r.ServiceAreaLookup__c, Federal__c, InKind__c, CashMatch__c, BudgetCategory__r.RowNumber__c, AdminCostValue__c
                 from ApplicationBudgetCategory2__c
                 where ((Application__c IN :applicationsIds AND (NOT CatName__c LIKE '%Indirect Costs%')) OR (Application__c IN :applicationsIds and BudgetCategory__r.CategoryName__c = 'Indirect Costs')) AND BudgetCategory__c != null];
            System.debug('Line 2101' + applicationBudgetCategoriesList.size());
            for (ApplicationBudgetCategory2__c app : applicationBudgetCategoriesList) {
                applicationBudgetCategoryIds.add(app.Id);
                if (!applicationBudgetCategoriesMap.containsKey(app.Application__c)) {
                    applicationBudgetCategoriesMap.put(app.Application__c, new List<ApplicationBudgetCategory2__c>());
                }
                applicationBudgetCategoriesMap.get(app.Application__c).add(app);
            }
            System.debug('applicationBudgetCategoriesMap: ' + applicationBudgetCategoriesMap);

            Map<Id, List<BuildUpItem__c>> appBudCatToBuildUpMap =
                new Map<Id, List<BuildUpItem__c>>();
            List<BuildUpItem__c> applicationbuildUpItemsList =
                [select Title__c, Narrative__c, StartDate__c, EndDate__c, ApplicationBudgetCategory__r.Application__r.AmountThisAction__c,
                 ApplicationBudgetCategory__r.Application__r.RequestedAmount__c, UnitPrice__c, Quantity__c, UnitofMeasurement__c, OtherCharges__c,
                 TotalDirect__c, AllowableDirect__c , Indirect__c, TotalIndirect__c, GrandTotal__c, GrantorShare__c, GranteeShare__c, EquipmentDesc__c,
                 EquipmentQuantity__c, EquipmentUnitPrice__c, ApplicationBudgetCategory__c, Name__c, TotalHours__c, RequestedHours__c,
                 HourlyRate__c, MatchType__c, ListBenefitType__c, FBTotalSalary__c, Benefit__c, TravelDestination__c, TravelPurpose__c,
                 TravelTotalMiles__c, TravelMileRate__c, EquipmentVAWAUse__c, CSCType__c, CFTotalHours__c, CFRate__c, RegistrationPerPerson__c,
                 PerDiem__c, HotelFees__c, NumberofDays__c, ExpensesPerPerson__c, NumberAttending__c from BuildUpItem__c
                 where ApplicationBudgetCategory__c IN :applicationBudgetCategoryIds];

            system.debug('applicationbuildUpItemsList:' + applicationbuildUpItemsList);
            for (BuildUpItem__c buildUpItem : applicationbuildUpItemsList) {
                if (!appBudCatToBuildUpMap.containsKey(buildUpItem.ApplicationBudgetCategory__c)) {
                    appBudCatToBuildUpMap.put(buildUpItem.ApplicationBudgetCategory__c, new List<BuildUpItem__c>());
                }
                appBudCatToBuildUpMap.get(buildUpItem.ApplicationBudgetCategory__c).add(buildUpItem);
            }

            system.debug('Application Build up line items' + appBudCatToBuildUpMap);
            // Service areas - If application then application other wise defalut - check with Ramu

            List<AwardBudgetCategory__c> awardBudgetCategories = new List<AwardBudgetCategory__c>();
            //swati:
            List<GrantBudgetCategory__c> grantBudgetCategories = new List<GrantBudgetCategory__c>();

            //JC--------------
            Set<Double> budgetCategoryTypeForOrg = new Set<Double>();
            for (String grantorOrgIter : grantorOrg) {
                budgetCategoryTypeForOrg.add(grantorOrgIter == 'USBE' ? 599 : 213);
            }
            system.debug('budgetCategoryTypeForOrg and applicationsIds ' + budgetCategoryTypeForOrg + ' ' + applicationsIds);
            List<ApplicationBudgetCategory2__c> indirectCosts = [SELECT Id, Amount__c, BudgetAmountUSBE__c, ServiceArea__r.ServiceAreaLookup__c, BudgetCategory__c, BudgetCategory__r.CategoryName__c, Application__c, Application__r.Id, AdminCostValue__c FROM ApplicationBudgetCategory2__c WHERE BudgetCategory__r.RowsNumber__c IN: budgetCategoryTypeForOrg AND Application__r.Id IN: applicationsIds];
            //ApplicationBudgetCategory2__c indirecCosts = [SELECT Id, Amount__c, BudgetAmountUSBE__c, ServiceArea__r.ServiceAreaLookup__c, BudgetCategory__c, BudgetCategory__r.CategoryName__c, Application__c, Application__r.Id, AdminCostValue__c FROM ApplicationBudgetCategory2__c WHERE BudgetCategory__r.CategoryName__c =: budgetCategoryTypeForOrg AND Application__r.Id in: applicationsIds LIMIT 1];
            System.debug('MANUALDEBUG >>> indirectCosts = ' + indirectCosts);
            //JC--------------

            //Create initial budget history if this is for USBE for all applications that we're going through. For each trigger's created award create an initial budget history onto it
            List<AmendmentRequest__c> budgetRevisionHistoryList = new List<AmendmentRequest__c>();
            List<AmendmentRequestBudgetCategory__c> budgetRevisionHistoryCategoryList = new List<AmendmentRequestBudgetCategory__c>();
            Map<Id, AmendmentRequest__c> amendmentRequestMap = new Map<Id, AmendmentRequest__c>();
            Map<Id, AmendmentRequestBudgetCategory__c> amendmentRequestBudgetCatMap = new Map<Id, AmendmentRequestBudgetCategory__c>();

            if (indirectCosts != null) {
                for (Id awardKey : awardApplicationMap.keySet()) {
                    Award__c currentAward = awardsList.get(awardKey);
                    if (currentAward.GrantorOrganization__c == 'USBE') {
                        //Application__c currentApplication = currentAward.Application__c;
                        Boolean percentVarianceOverTen = false;
                        AmendmentRequest__c budgetRevision = new AmendmentRequest__c();
                        budgetRevision.Award__c = awardKey;
                        budgetRevision.Type__c = 'Budget Revision';
                        budgetRevision.ApprovalDate__c = DateTime.now();
                        //budgetRevision.ApprovalDate__c = currentAward.Application__r.CreatedDate; //Modify as need be later
                        budgetRevision.RevisionDate__c = null;
                        //budgetRevision.RevisionDate__c = DateTime.now(); //System.now().format(); //Initial created revision, will set revision date when it is revised
                        budgetRevision.TotalApprovedBudget__c = currentAward.Application__r.TotalFederalMatch__c; //Total approved budget shown in the history table, so it's the sum of the current approved budget
                        budgetRevision.Purpose__c = 'Budget Revision';
                        budgetRevision.Impact__c = 'Budget Revision';
                        budgetRevision.BudgetNarrative__c = currentAward.BudgetNarrativeRead__c; //Save the budget narrative that explains/justifies the approved budget
                        budgetRevision.BudgetNarrativeProposed__c = currentAward.BudgetNarrativeRead__c;
                        budgetRevision.BudgetNarrativeThisRevisionOnly__c = ' ';
                        budgetRevision.Status__c = 'Active';
                        budgetRevision.IndirectCostPercentage__c = currentAward.Application__r.IndirectCostPercentage__c;
                        budgetRevision.RevisionHistoryAwardName__c = currentAward.Name;
                        budgetRevisionHistoryList.add(budgetRevision);
                        amendmentRequestMap.put(awardKey, budgetRevision);
                    }
                }
                AmendmentRequestTriggerHelper.skipTrigger = true;
                insert budgetRevisionHistoryList; //Insert the created AmendmentRequest object
                AmendmentRequestTriggerHelper.skipTrigger = false;
            }
            //JC--------------

            for (Id awardKey : awardApplicationMap.keySet()) {
                Id applicationKey = awardApplicationMap.get(awardKey);
                Award__c award = awardsList.get(awardKey);
                List<ApplicationBudgetCategory2__c> appliationBudgetCategories = applicationBudgetCategoriesMap.get(applicationKey);

                if (appliationBudgetCategories != null) {

                    AmendmentRequest__c budgetRevision;
                    ApplicationBudgetCategory2__c indirecCosts = null;
                    for (ApplicationBudgetCategory2__c abcIterator : indirectCosts) {
                        if (abcIterator.Application__r.Id == applicationKey) { indirecCosts = abcIterator; }
                    }

                    System.debug('Test class debug: ' + award.GrantorOrganization__c + ' ' + indirecCosts);
                    if (award.GrantorOrganization__c == 'USBE' && indirecCosts != null) {

                        //Get the initial budget history item associated with the award
                        budgetRevision = amendmentRequestMap.get(awardKey);

                        //For each Award, add a indirect budget category if it is appropriate
                        AwardBudgetCategory__c dummyIndirectCost = new AwardBudgetCategory__c();
                        dummyIndirectCost.Award__c = awardKey;
                        dummyIndirectCost.ServiceArea__c = indirecCosts.ServiceArea__r.ServiceAreaLookup__c;
                        dummyIndirectCost.BudgetCategory__c = indirecCosts.BudgetCategory__c;
                        dummyIndirectCost.Amount__c = indirecCosts.BudgetAmountUSBE__c;
                        dummyIndirectCost.BudgetPeriod__c = award.BudgetPeriod__c;
                        dummyIndirectCost.ClonedFromApplicationBudgetCategory__c = indirecCosts.id;
                        dummyIndirectCost.CurrentApprovedBudgetAmount__c = indirecCosts.BudgetAmountUSBE__c;
                        dummyIndirectCost.ProposedBudgetRevision__c = indirecCosts.BudgetAmountUSBE__c;
                        dummyIndirectCost.LastGrantorApprovedBudget__c = indirecCosts.BudgetAmountUSBE__c;
                        if (award.ProgramBudgetTypeUSBE__c == 'CTE') {
                            dummyIndirectCost.AdminCostValue__c = indirecCosts.AdminCostValue__c;
                            dummyIndirectCost.AdminCostValueProposed__c = indirecCosts.AdminCostValue__c;
                            dummyIndirectCost.LastGrantorApprovedAdminCost__c = indirecCosts.AdminCostValue__c;
                        }
                        awardBudgetCategories.add(dummyIndirectCost);
                        GrantBudgetCategory__c dummyIndirectCostGrant = new GrantBudgetCategory__c();
                        dummyIndirectCostGrant.Grant__c = award.Grant__c;
                        dummyIndirectCostGrant.ClonedFromApplicationBudgetCategory__c = indirecCosts.id;
                        dummyIndirectCostGrant.BudgetCategory__c = indirecCosts.BudgetCategory__c;
                        dummyIndirectCostGrant.BudgetPeriod__c = award.BudgetPeriod__c;
                        dummyIndirectCostGrant.ProjServiceArea__c = indirecCosts.ServiceArea__r.ServiceAreaLookup__c;
                        dummyIndirectCostGrant.TotalAmount__c = indirecCosts.BudgetAmountUSBE__c;
                        dummyIndirectCostGrant.CurrentApprovedBudgetAmount__c = indirecCosts.BudgetAmountUSBE__c;
                        grantBudgetCategories.add(dummyIndirectCostGrant);
                        AmendmentRequestBudgetCategory__c dummyIndirectCostHistory = new AmendmentRequestBudgetCategory__c();
                        dummyIndirectCostHistory.AmendmentRequest__c = budgetRevision.Id; //AmendmentRequest__c
                        dummyIndirectCostHistory.BudgetCategory__c = indirecCosts.BudgetCategory__c; //BudgetCategory__c
                        dummyIndirectCostHistory.CurrentApprovedBudgetAmount__c = indirecCosts.BudgetAmountUSBE__c; //CurrentApprovedBudgetAmount__c
                        dummyIndirectCostHistory.ProposedBudgetRevision__c = indirecCosts.BudgetAmountUSBE__c; //ProposedBudgetRevision__c
                        dummyIndirectCostHistory.PercentVariance__c = '0%'; //Can't be a variance from itself
                        dummyIndirectCostHistory.PercentVarianceCurrent__c = '0%';
                        if (award.ProgramBudgetTypeUSBE__c == 'CTE') {
                            dummyIndirectCostHistory.AdminCostValue__c = indirecCosts.AdminCostValue__c;
                            dummyIndirectCostHistory.AdminCostValueProposed__c = indirecCosts.AdminCostValue__c;
                        }
                        budgetRevisionHistoryCategoryList.add(dummyIndirectCostHistory);
                        //JC--------------
                    }
                    for (ApplicationBudgetCategory2__c applicationBudgetCategory : appliationBudgetCategories) {
                        AwardBudgetCategory__c awardBudgetCategory = new AwardBudgetCategory__c();
                        awardBudgetCategory.Award__c = awardKey;
                        awardBudgetCategory.ServiceArea__c = applicationBudgetCategory.ServiceArea__r.ServiceAreaLookup__c;
                        awardBudgetCategory.BudgetCategory__c = applicationBudgetCategory.BudgetCategory__c;
                        awardBudgetCategory.GrantorAmount__c = applicationBudgetCategory.GrantorAmount__c;
                        awardBudgetCategory.GranteeAmount__c = applicationBudgetCategory.GranteeAmount__c;
                        awardBudgetCategory.Federal__c = applicationBudgetCategory.Federal__c;
                        awardBudgetCategory.InKind__c = applicationBudgetCategory.InKind__c;
                        awardBudgetCategory.CashMatch__c = applicationBudgetCategory.CashMatch__c;
                        awardBudgetCategory.Amount__c = applicationBudgetCategory.Amount__c;
                        awardBudgetCategory.BudgetPeriod__c = award.BudgetPeriod__c;
                        awardBudgetCategory.ClonedFromApplicationBudgetCategory__c = applicationBudgetCategory.Id;
                        awardBudgetCategory.CurrentApprovedBudgetAmount__c = applicationBudgetCategory.Amount__c;
                        awardBudgetCategory.ProposedBudgetRevision__c = awardBudgetCategory.CurrentApprovedBudgetAmount__c;
                        awardBudgetCategory.LastGrantorApprovedBudget__c = applicationBudgetCategory.Amount__c;
                        if (award.ProgramBudgetTypeUSBE__c == 'CTE') {
                            awardBudgetCategory.AdminCostValue__c = applicationBudgetCategory.AdminCostValue__c;
                            awardBudgetCategory.AdminCostValueProposed__c = applicationBudgetCategory.AdminCostValue__c;
                            awardBudgetCategory.LastGrantorApprovedAdminCost__c = applicationBudgetCategory.AdminCostValue__c;
                        }
                        awardBudgetCategories.add(awardBudgetCategory);
                        ///////swati:
                        GrantBudgetCategory__c grantBudgetCategory = new GrantBudgetCategory__c();
                        grantBudgetCategory.Grant__c = award.Grant__c;
                        grantBudgetCategory.ProjServiceArea__c = applicationBudgetCategory.ServiceArea__r.ServiceAreaLookup__c;
                        grantBudgetCategory.BudgetCategory__c = applicationBudgetCategory.BudgetCategory__c;
                        grantBudgetCategory.GrantorAmount__c = applicationBudgetCategory.GrantorAmount__c;
                        grantBudgetCategory.GranteeAmount__c = applicationBudgetCategory.GranteeAmount__c;
                        grantBudgetCategory.Federal__c = applicationBudgetCategory.Federal__c;
                        grantBudgetCategory.InKind__c = applicationBudgetCategory.InKind__c;
                        grantBudgetCategory.CashMatch__c = applicationBudgetCategory.CashMatch__c;
                        grantBudgetCategory.TotalAmount__c = applicationBudgetCategory.Amount__c;
                        grantBudgetCategory.ClonedFromApplicationBudgetCategory__c = applicationBudgetCategory.Id;
                        grantBudgetCategory.BudgetPeriod__c = award.BudgetPeriod__c;
                        grantBudgetCategory.CurrentApprovedBudgetAmount__c = applicationBudgetCategory.Amount__c;

                        grantBudgetCategories.add(grantBudgetCategory);

                        //JC-----------
                        //If this is USBE, we can go and add the initial budget history
                        if (award.GrantorOrganization__c == 'USBE' && indirecCosts != null) {
                            AmendmentRequestBudgetCategory__c currentARBC = new AmendmentRequestBudgetCategory__c(); //Create AmendmentRequestBudgetCategory__c
                            //currentARBC.AwardBudgetCategory__c = awardBudgetCategory.Id; //Link created AmendmentRequestBudgetCategory__c to the created (and already inserted) AmendmentRequest object
                            currentARBC.AmendmentRequest__c = budgetRevision.Id; //AmendmentRequest__c
                            currentARBC.BudgetCategory__c = applicationBudgetCategory.BudgetCategory__c; //BudgetCategory__c
                            currentARBC.CurrentApprovedBudgetAmount__c = applicationBudgetCategory.Amount__c; //CurrentApprovedBudgetAmount__c
                            currentARBC.ProposedBudgetRevision__c = currentARBC.CurrentApprovedBudgetAmount__c;
                            //currentARBC.ProposedBudgetRevision__c = applicationBudgetCategory.Amount__c; //ProposedBudgetRevision__c
                            currentARBC.PercentVariance__c = '0%'; //Can't be a variance from itself
                            currentARBC.PercentVarianceCurrent__c = '0%';
                            currentARBC.LastGrantorApprovedBudget__c = applicationBudgetCategory.Amount__c;
                            if (award.ProgramBudgetTypeUSBE__c == 'CTE') {
                                currentARBC.AdminCostValue__c = applicationBudgetCategory.AdminCostValue__c;
                                currentARBC.AdminCostValueProposed__c = applicationBudgetCategory.AdminCostValue__c;
                                currentARBC.LastGrantorApprovedAdminCost__c = applicationBudgetCategory.AdminCostValue__c;
                            }
                            budgetRevisionHistoryCategoryList.add(currentARBC);
                            amendmentRequestBudgetCatMap.put(applicationBudgetCategory.Id, currentARBC);
                        }
                    }
                    //JC--------------

                }
            }

            insert budgetRevisionHistoryCategoryList; //Insert the list of created AmendmentRequestBudgetCategory__c
            System.debug('MANUALDEBUG >>> AwardBudgetCategories = ' + awardBudgetCategories);
            System.debug('MANUALDEBUG >>> GrantBudgetCategories = ' + grantBudgetCategories);

            if (grantBudgetCategories.size() > 0) {
                System.debug('MANUALDEBUG >>> Inserting GrantBudgetCategories');

                insert grantBudgetCategories;

                Map<Id, GrantBudgetCategory__c> grantIdToDetailsMap = new Map<Id, GrantBudgetCategory__c>();
                for (GrantBudgetCategory__c gbc : grantBudgetCategories) {
                    grantIdToDetailsMap.put(gbc.ClonedFromApplicationBudgetCategory__c, gbc);
                }
                for (AwardBudgetCategory__c abc : awardBudgetCategories) {
                    GrantBudgetCategory__c gbc = grantIdToDetailsMap.get(abc.ClonedFromApplicationBudgetCategory__c);
                    if (gbc != null) {
                        abc.GrantBudgetCategory__c = gbc.Id;
                    }
                }
                System.debug('MANUALDEBUG >>> Inserting AwardBudgetCategories');

                insert awardBudgetCategories;

            }
            ////////////////swati:
            //insert awardBudgetCategories;

            List<BuildUpItem__c> awardBuildUpItems = new List<BuildUpItem__c>();

            // compare applicationbudgetcategories to awardbudgetcategories to get buildupitems

            for (Id awardKey : awardApplicationMap.keySet()) {
                Award__c award = awardsList.get(awardKey);
                if (award.Application__c != null && award.GrantorOrganization__c == 'USBE') { //This is the build up item logic we're using for USBE
                    AmendmentRequest__c budgetRevision = amendmentRequestMap.get(awardKey); //Get the initial budget history item associated with the award

                    Id applicationKey = awardApplicationMap.get(awardKey);
                    List<ApplicationBudgetCategory2__c> applicationBudgetCategories = applicationBudgetCategoriesMap.get(applicationKey);
                    System.debug('applicationBudgetCategories ' + applicationBudgetCategories);
                    for (ApplicationBudgetCategory2__c applicationBudgetCategory : applicationBudgetCategories) { //Application budget categories for this award
                        for (AwardBudgetCategory__c awardBudgetCategory : awardBudgetCategories) { //Award budget categories for this award
                            if (awardBudgetCategory.Award__c.equals(awardKey) && applicationBudgetCategory.BudgetCategory__c.equals(awardBudgetCategory.BudgetCategory__c) && applicationBudgetCategory.BudgetCategory__r.RowNumber__c == '570') {
                                List<BuildUpItem__c> appbuildupitems = new List<BuildUpItem__c>();
                                if (appBudCatToBuildUpMap.containsKey(applicationBudgetCategory.Id)) {
                                    appbuildupitems = appBudCatToBuildUpMap.get(applicationBudgetCategory.Id);
                                }
                                for (BuildUpItem__c buildUpItemIterator : appbuildupitems) {
                                    for (Integer i = 0; i < 2; i++) {
                                        BuildUpItem__c buildUpItemToInsert = new BuildUpItem__c();
                                        buildUpItemToInsert.AwardBudgetCategory__c = awardBudgetCategory.Id;
                                        buildUpItemToInsert.EquipmentDesc__c = buildUpItemIterator.EquipmentDesc__c;
                                        buildUpItemToInsert.EquipmentQuantity__c = buildUpItemIterator.EquipmentQuantity__c;
                                        buildUpItemToInsert.EquipmentUnitPrice__c = buildUpItemIterator.EquipmentUnitPrice__c;
                                        buildUpItemToInsert.CurrentActiveAwardBudgetBuildup__c = (i == 0) ? 'Active' : 'Created';
                                        awardBuildUpItems.add(buildUpItemToInsert);
                                        //buildUpItemIterator.HideIfRevised__c = true;
                                    }
                                    //Create buildup items for initial revision history
                                    for (Integer i = 0; i < 2; i++) {
                                        BuildUpItem__c buildUpItemHistoryInitial = new BuildUpItem__c();
                                        AmendmentRequestBudgetCategory__c currentARBC = amendmentRequestBudgetCatMap.get(applicationBudgetCategory.Id);
                                        buildUpItemHistoryInitial.AmendmentRequestBudgetCategory__c = currentARBC.Id;
                                        buildUpItemHistoryInitial.EquipmentDesc__c = buildUpItemIterator.EquipmentDesc__c;
                                        buildUpItemHistoryInitial.EquipmentQuantity__c = buildUpItemIterator.EquipmentQuantity__c;
                                        buildUpItemHistoryInitial.EquipmentUnitPrice__c = buildUpItemIterator.EquipmentUnitPrice__c;
                                        buildUpItemHistoryInitial.CurrentActiveAwardBudgetBuildup__c = (i == 0) ? 'Active' : 'Created';
                                        //buildUpItemHistoryInitial.CurrentActiveAwardBudgetBuildup__c = 'Created';
                                        awardBuildUpItems.add(buildUpItemHistoryInitial);
                                    }
                                }
                            }
                        }
                    }
                } else if (award.Application__c != null ) {
                    //else if (award.Application__c != null && award.Grant__r.Application__r.Announcement__r.DetailedBudgetingRequired__c == 'Yes') {
                    Id applicationKey = awardApplicationMap.get(awardKey);
                    List<ApplicationBudgetCategory2__c> applicationBudgetCategories = applicationBudgetCategoriesMap.get(applicationKey);
                    for (ApplicationBudgetCategory2__c applicationBudgetCategory : applicationBudgetCategories) {
                        for (AwardBudgetCategory__c awardBudgetCategory : awardBudgetCategories) {
                            if (awardBudgetCategory.Award__c.equals(awardKey) && applicationBudgetCategory.BudgetCategory__c.equals(awardBudgetCategory.BudgetCategory__c) && applicationBudgetCategory.ServiceArea__r.ServiceAreaLookup__c.equals(awardBudgetCategory.ServiceArea__c)) { // add only if the key exists in the map
                                List<BuildUpItem__c> appbuildupitems = new List<BuildUpItem__c>();
                                if (appBudCatToBuildUpMap.containsKey(applicationBudgetCategory.Id)) {
                                    appbuildupitems = appBudCatToBuildUpMap.get(applicationBudgetCategory.Id);
                                }
                                for (BuildUpItem__c buildUpItem : appbuildupitems) {
                                    BuildUpItem__c awardBuildUpItem = new BuildUpItem__c();
                                    //Decimal conversionFactor = buildUpItem.ApplicationBudgetCategory__r.Application__r.AmountThisAction__c / buildUpItem.ApplicationBudgetCategory__r.Application__r.RequestedAmount__c;
                                    //awardBuildUpItem.Title__c = buildUpItem.Title__c;
                                    //awardBuildUpItem.Narrative__c = buildUpItem.Narrative__c;
                                    //awardBuildUpItem.StartDate__c = buildUpItem.StartDate__c;
                                    //awardBuildUpItem.EndDate__c = buildUpItem.EndDate__c;
                                    //awardBuildUpItem.UnitPrice__c = buildUpItem.UnitPrice__c;
                                    //awardBuildUpItem.Quantity__c = buildUpItem.Quantity__c;
                                    //awardBuildUpItem.UnitofMeasurement__c = buildUpItem.UnitofMeasurement__c;
                                    //awardBuildUpItem.OtherCharges__c = buildUpItem.OtherCharges__c;
                                    //awardBuildUpItem.AllowableDirect__c = buildUpItem.AllowableDirect__c;
                                    //awardBuildUpItem.Indirect__c = buildUpItem.Indirect__c;
                                    if (applicationBudgetCategory.BudgetCategory__r.Name == 'Personnel') {
                                        awardBuildUpItem.Name__c = buildUpItem.Name__c;
                                        awardBuildUpItem.TotalHours__c = buildUpItem.TotalHours__c;
                                        awardBuildUpItem.Title__c = buildUpItem.Title__c;
                                        awardBuildUpItem.RequestedHours__c = buildUpItem.RequestedHours__c;
                                        awardBuildUpItem.HourlyRate__c = buildUpItem.HourlyRate__c;
                                        awardBuildUpItem.MatchType__c = buildUpItem.MatchType__c;
                                    }
                                    if (applicationBudgetCategory.BudgetCategory__r.Name == 'Fringe Benefits') {
                                        awardBuildUpItem.Name__c = buildUpItem.Name__c;
                                        awardBuildUpItem.ListBenefitType__c = buildUpItem.ListBenefitType__c;
                                        awardBuildUpItem.FBTotalSalary__c = buildUpItem.FBTotalSalary__c;
                                        awardBuildUpItem.Benefit__c = buildUpItem.Benefit__c;
                                        awardBuildUpItem.MatchType__c = buildUpItem.MatchType__c;
                                    }
                                    if (applicationBudgetCategory.BudgetCategory__r.Name == 'Travel') {
                                        awardBuildUpItem.TravelDestination__c = buildUpItem.TravelDestination__c;
                                        awardBuildUpItem.TravelPurpose__c = buildUpItem.TravelPurpose__c;
                                        awardBuildUpItem.TravelTotalMiles__c = buildUpItem.TravelTotalMiles__c;
                                        awardBuildUpItem.TravelMileRate__c = buildUpItem.TravelMileRate__c;
                                        awardBuildUpItem.MatchType__c = buildUpItem.MatchType__c;
                                    }
                                    if (applicationBudgetCategory.BudgetCategory__r.Name == 'Equipment') {
                                        awardBuildUpItem.EquipmentDesc__c = buildUpItem.EquipmentDesc__c;
                                        awardBuildUpItem.EquipmentVAWAUse__c = buildUpItem.EquipmentVAWAUse__c;
                                        awardBuildUpItem.EquipmentQuantity__c = buildUpItem.EquipmentQuantity__c;
                                        awardBuildUpItem.EquipmentUnitPrice__c = buildUpItem.EquipmentUnitPrice__c;
                                        awardBuildUpItem.MatchType__c = buildUpItem.MatchType__c;
                                    }
                                    if (applicationBudgetCategory.BudgetCategory__r.Name == 'Supplies') {
                                        awardBuildUpItem.EquipmentDesc__c = buildUpItem.EquipmentDesc__c;
                                        awardBuildUpItem.EquipmentQuantity__c = buildUpItem.EquipmentQuantity__c;
                                        awardBuildUpItem.EquipmentUnitPrice__c = buildUpItem.EquipmentUnitPrice__c;
                                        awardBuildUpItem.MatchType__c = buildUpItem.MatchType__c;
                                    }
                                    if (applicationBudgetCategory.BudgetCategory__r.Name == 'Contracted Fees') {
                                        awardBuildUpItem.CSCType__c = buildUpItem.CSCType__c;
                                        awardBuildUpItem.CFTotalHours__c = buildUpItem.CFTotalHours__c;
                                        awardBuildUpItem.CFRate__c = buildUpItem.CFRate__c;
                                        awardBuildUpItem.MatchType__c = buildUpItem.MatchType__c;
                                    }
                                    if (applicationBudgetCategory.BudgetCategory__r.Name == 'Training') {
                                        awardBuildUpItem.Name__c = buildUpItem.Name__c;
                                        awardBuildUpItem.RegistrationPerPerson__c = buildUpItem.RegistrationPerPerson__c;
                                        awardBuildUpItem.PerDiem__c = buildUpItem.PerDiem__c;
                                        awardBuildUpItem.HotelFees__c = buildUpItem.HotelFees__c;
                                        awardBuildUpItem.NumberofDays__c = buildUpItem.NumberofDays__c;
                                        awardBuildUpItem.NumberAttending__c = buildUpItem.NumberAttending__c;
                                        awardBuildUpItem.MatchType__c = buildUpItem.MatchType__c;
                                    }
                                    if (applicationBudgetCategory.BudgetCategory__r.Name == 'Other') {
                                        awardBuildUpItem.EquipmentDesc__c = buildUpItem.EquipmentDesc__c;
                                        awardBuildUpItem.EquipmentQuantity__c = buildUpItem.EquipmentQuantity__c;
                                        awardBuildUpItem.EquipmentUnitPrice__c = buildUpItem.EquipmentUnitPrice__c;
                                        awardBuildUpItem.MatchType__c = buildUpItem.MatchType__c;
                                    }



                                    //awardBuildUpItem.GrantorShare__c = buildUpItem.GrantorShare__c * conversionFactor.setScale(4);
                                    awardBuildUpItem.AwardBudgetCategory__c = awardBudgetCategory.Id;

                                    awardBuildUpItems.add(awardBuildUpItem);
                                }
                            }
                        }
                    }
                }
            }
            insert awardBuildUpItems;
        }
    }

    private void insertAwardBudgetCategoriesFromProgramWithSericeArea(List<Award__c> awardsWithSericeArea,
            List<ProgramServiceArea__c> programServiceAreasList,
            List<ProgramBudgetCategory__c> programBudgetCategoriesList, Map<Id, Id> awardProgramMap) {

        Map<Id, List<ProgramServiceArea__c>> programProgramServiceAreaMap = new Map<Id, List<ProgramServiceArea__c>>();
        Map<Id, List<ProgramBudgetCategory__c>> programBudgetCategoriesMap = new Map<Id, List<ProgramBudgetCategory__c>>();

        for (ProgramServiceArea__c programServiceArea : programServiceAreasList) {
            if (!programProgramServiceAreaMap.containsKey(programServiceArea.Program__c)) {
                programProgramServiceAreaMap.put(programServiceArea.Program__c, new List<ProgramServiceArea__c>());
            }
            programProgramServiceAreaMap.get(programServiceArea.Program__c).add(programServiceArea);
        }

        for (ProgramBudgetCategory__c programBudgetCategory : programBudgetCategoriesList) {
            if (!programBudgetCategoriesMap.containsKey(programBudgetCategory.Program__c)) {
                programBudgetCategoriesMap.put(programBudgetCategory.Program__c, new List<ProgramBudgetCategory__c>());
            }
            programBudgetCategoriesMap.get(programBudgetCategory.Program__c).add(programBudgetCategory);
        }

        List<AwardBudgetCategory__c> awardBudgetCategories = new List<AwardBudgetCategory__c>();

        for (Award__c award : awardsWithSericeArea) {
            Id programId = awardProgramMap.get(award.Id);
            List<ProgramServiceArea__c> programServiceAreas = programProgramServiceAreaMap.get(programId);
            List<ProgramBudgetCategory__c> programBudgetCategories = programBudgetCategoriesMap.get(programId);
            for (ProgramServiceArea__c programserviceArea : programServiceAreas) {
                for (ProgramBudgetCategory__c programBudgetCategory : programBudgetCategories) {
                    AwardBudgetCategory__c awardBudgetCategory = new AwardBudgetCategory__c();
                    awardBudgetCategory.Award__c = award.Id;
                    awardBudgetCategory.ServiceArea__c = programserviceArea.ServiceArea__c;
                    awardBudgetCategory.BudgetCategory__c = programBudgetCategory.BudgetCategory__c;
                    awardBudgetCategory.GrantorAmount__c = 0.0;
                    awardBudgetCategory.GranteeAmount__c = 0.0;
                    awardBudgetCategory.Amount__c = 0.0;
                    awardBudgetCategory.BudgetPeriod__c = award.BudgetPeriod__c;

                    awardBudgetCategories.add(awardBudgetCategory);
                }
            }
        }

        insert awardBudgetCategories;
    }

    private void insertAwardBudgetCategoriesFromProgramWithoutSericeArea(List<Award__c> awardsWithNoSericeArea,
            List<ProgramBudgetCategory__c> programBudgetCategoriesList, Map<Id, Id> awardProgramMap) {

        List<ServiceArea__c> defaultServiceAreas = [Select id, name, Title__c, Default__c
                from ServiceArea__c
                where Default__c = true];

        Map<Id, List<ProgramBudgetCategory__c>> programBudgetCategoriesMap = new Map<Id, List<ProgramBudgetCategory__c>>();

        for (ProgramBudgetCategory__c programBudgetCategory : programBudgetCategoriesList) {
            if (!programBudgetCategoriesMap.containsKey(programBudgetCategory.Program__c)) {
                programBudgetCategoriesMap.put(programBudgetCategory.Program__c, new List<ProgramBudgetCategory__c>());
            }
            programBudgetCategoriesMap.get(programBudgetCategory.Program__c).add(programBudgetCategory);
        }

        List<AwardBudgetCategory__c> awardBudgetCategories = new List<AwardBudgetCategory__c>();

        for (Award__c award : awardsWithNoSericeArea) {
            Id programId = awardProgramMap.get(award.Id);
            List<ProgramBudgetCategory__c> programBudgetCategories = programBudgetCategoriesMap.get(programId);

            for (ServiceArea__c serviceArea : defaultServiceAreas) {
                for (ProgramBudgetCategory__c programBudgetCategory : programBudgetCategories) {
                    AwardBudgetCategory__c awardBudgetCategory = new AwardBudgetCategory__c();
                    awardBudgetCategory.Award__c = award.Id;
                    awardBudgetCategory.ServiceArea__c = serviceArea.Id;
                    awardBudgetCategory.BudgetCategory__c = programBudgetCategory.BudgetCategory__c;
                    awardBudgetCategory.GrantorAmount__c = 0.0;
                    awardBudgetCategory.GranteeAmount__c = 0.0;
                    awardBudgetCategory.Amount__c = 0.0;
                    awardBudgetCategory.BudgetPeriod__c = award.BudgetPeriod__c;

                    awardBudgetCategories.add(awardBudgetCategory);
                }
            }
        }
        insert awardBudgetCategories;
    }

    //private void insertDefalutAwardBudgetCategories(List<Award__c> novelAwards) {
    //    List<BudgetCategory__c> defaultBudgetCategories = [Select Id, Name, RecordType.Name
    //            from BudgetCategory__c
    //            where RecordType.Name = 'Internal'];
    //    List<ServiceArea__c> lstServiceArea = [Select id, name, Title__c, Default__c
    //                                           from ServiceArea__c
    //                                           where Default__c = true];
    //    List<AwardBudgetCategory__c> awardBudgetCategories = new List<AwardBudgetCategory__c>();
    //    //swati:
    //    List<GrantBudgetCategory__c> grantBudgetCategories = new List<GrantBudgetCategory__c>();
    //    for (Award__c award : novelAwards) {
    //        for (BudgetCategory__c budgetCategory : defaultBudgetCategories) {
    //            for (ServiceArea__c serviceArea : lstServiceArea) {
    //                AwardBudgetCategory__c awardBudgetCategory = new AwardBudgetCategory__c();
    //                awardBudgetCategory.Award__c = award.Id;
    //                awardBudgetCategory.ServiceArea__c = serviceArea.Id;
    //                awardBudgetCategory.BudgetCategory__c = budgetCategory.Id;
    //                awardBudgetCategory.GrantorAmount__c = 0.0;
    //                awardBudgetCategory.GranteeAmount__c = 0.0;
    //                awardBudgetCategory.Amount__c = 0.0;
    //                awardBudgetCategory.BudgetPeriod__c = award.BudgetPeriod__c;

    //                awardBudgetCategories.add(awardBudgetCategory);

    //                ///////swati:
    //                GrantBudgetCategory__c grantBudgetCategory = new GrantBudgetCategory__c();
    //                grantBudgetCategory.Grant__c = award.Grant__c;
    //                grantBudgetCategory.ProjServiceArea__c = serviceArea.Id;
    //                grantBudgetCategory.BudgetCategory__c = budgetCategory.Id;
    //                grantBudgetCategory.GrantorAmount__c = 0.0;
    //                grantBudgetCategory.GranteeAmount__c = 0.0;
    //                grantBudgetCategory.TotalAmount__c = 0.0;
    //                grantBudgetCategory.BudgetPeriod__c = award.BudgetPeriod__c;

    //                grantBudgetCategories.add(grantBudgetCategory);
    //            }
    //        }
    //    }
    //    if (grantBudgetCategories.size() > 0) {
    //        insert grantBudgetCategories;

    //        Map<Id, GrantBudgetCategory__c> grantIdToDetailsMap = new Map<Id, GrantBudgetCategory__c>();
    //        for (GrantBudgetCategory__c gbc : grantBudgetCategories) {
    //            grantIdToDetailsMap.put(gbc.BudgetCategory__c, gbc);
    //        }
    //        for (AwardBudgetCategory__c abc : awardBudgetCategories) {
    //            GrantBudgetCategory__c gbc = grantIdToDetailsMap.get(abc.BudgetCategory__c);
    //            abc.GrantBudgetCategory__c = gbc.Id;
    //        }
    //        insert awardBudgetCategories;
    //    }
    //    ////////////////swati:
    //    // insert awardBudgetCategories;
    //}

    public void updateGrantBudgetOnAwardIssuance(List<Award__c> newAwardList, Map<Id, Award__c> awardMap) {
        Set<Id> awardIds = new Set<Id>();
        for (Award__c aw : newAwardList) {
            if (aw.Status__c == 'Activated' && awardMap.get(aw.Id).Status__c != 'Activated') {
                awardIds.add(aw.Id);
            }
        }
        List<AwardBudgetCategory__c> abcList = [select id, BudgetCategory__c, BudgetPeriod__c, GrantorAmount__c,
                                                GranteeAmount__c, Amount__c, DisallowedAmount__c, GrantBudgetCategory__c
                                                from AwardBudgetCategory__c
                                                where Award__c IN :awardIds];
        List<GrantBudgetCategory__c> updateList = new List<GrantBudgetCategory__c>();
        for (AwardBudgetCategory__c awbc : abcList) {
            GrantBudgetCategory__c gbc = new GrantBudgetCategory__c();
            gbc.Id = awbc.GrantBudgetCategory__c;
            gbc.BudgetCategory__c = awbc.BudgetCategory__c;
            gbc.BudgetPeriod__c = awbc.BudgetPeriod__c;
            gbc.GrantorAmount__c = awbc.GrantorAmount__c;
            gbc.GranteeAmount__c = awbc.GranteeAmount__c;
            gbc.TotalAmount__c = awbc.Amount__c;
            updateList.add(gbc);
        }
        if (updateList.size() > 0) {
            update updateList;
        }
    }


// For PeopleSoft Integration
    /* private void createProposalForPeopleSoft(List<Award__c> newAwards, Map<Id,Award__c> oldAwardsMap) {
       Set<String> awardStages = new Set<String>(getPickListString(Award__c.Status__c.getDescribe()));

       if(awardStages.contains('Activated') && awardStages.contains('Approved')) {
         List<Id> awardIds = new List<Id>();

         for(Award__c eachAward : newAwards) {
           if(eachAward.Status__c == 'Activated' && oldAwardsMap.get(eachAward.Id).Status__c == 'Approved') {
             awardIds.add(eachAward.Id);
           }
         }

         Map<String, List<String>> calloutResponse = new Map<String, List<String>>();
         if(!skipTrigger){
              PeopleSoftIntegrationHelper.createProposalInPeopleSoft(awardIds, true,calloutResponse);
              PeopleSoftIntegrationHelper.createAwardBudgetInPeopleSoft(awardIds, true,calloutResponse);
          }
       }
     }

      public static List<String> getPickListString(Schema.DescribeFieldResult describeField) {
        List<String> result = new List<String>();
          List<Schema.PicklistEntry> picklistEntries = describeField.getPickListValues();

          for(Schema.PicklistEntry opt : picklistEntries) {
              if(opt.isActive()) {
                  result.add(opt.getValue());
              }
          }
          return result;
      }*/


    private void updateBudgetRevision(List<Award__c> awardList) {
        System.debug('MANUALDEBUG >>> Inside updateBudgetRevision ');
        System.debug('MANUALDEBUG >>> Gratnor Org = ' + awardList[0].GrantorOrganization__c);

        List <AwardBudgetCategory__c> awardBudgetCategoryList = [
                    SELECT Id, ProposedBudgetRevision__c, Award__c, Amount__c, BudgetCategory__r.RowNumber__c, Award__r.IndirectCostPercentage__c, Award__r.IndirectCostPercentageProposed__c, Award__r.BudgetRevisionInitiatedByUSBE__c, AdminCostValueProposed__c
                    FROM AwardBudgetCategory__c
                    WHERE Award__c IN: awardList];
        System.debug('MANUALDEBUG >>> awardBudgetCategoryList = ' + awardBudgetCategoryList);

        for (Award__c awardIterator : awardList) {
            if (awardIterator.GrantorOrganization__c == 'USBE' && awardIterator.BudgetRevisionInitiated__c == 'In Progress') {
                for (AwardBudgetCategory__c abcList : awardBudgetCategoryList) {
                    if (abcList.Award__c == awardIterator.Id) {
                        System.debug('MANUALDEBUG >>> abcList cell = ' + abcList);
                        if (abcList.BudgetCategory__r.RowNumber__c == '599') {
                            Decimal totalIndirectVal = 0;
                            Decimal totalAdminIndirect = 0;
                            for (AwardBudgetCategory__c abcList2 : awardBudgetCategoryList) {
                                if (abcList2.BudgetCategory__r.RowNumber__c != '570' && abcList2.BudgetCategory__r.RowNumber__c != '580' && abcList2.BudgetCategory__r.RowNumber__c != '599') {
                                    totalIndirectVal += abcList2.ProposedBudgetRevision__c;
                                    if (awardIterator.ProgramBudgetTypeUSBE__c == 'CTE') {
                                        totalAdminIndirect += abcList2.AdminCostValueProposed__c;
                                    }
                                }
                            }
                            if (abcList.Award__r.BudgetRevisionInitiatedByUSBE__c == 'Indirect Change') {
                                abcList.ProposedBudgetRevision__c = (totalIndirectVal * (abcList.Award__r.IndirectCostPercentageProposed__c / 100)).setScale(2);
                            } else {
                                abcList.ProposedBudgetRevision__c = (totalIndirectVal * (abcList.Award__r.IndirectCostPercentage__c / 100)).setScale(2);
                            }
                            System.debug('MANUALDEBUG >>> updated indirect =  ' + abcList.ProposedBudgetRevision__c);
                            System.debug('MANUALDEBUG >>> totalAdminIndirect = ' + totalAdminIndirect);
                            if (awardIterator.ProgramBudgetTypeUSBE__c == 'CTE') {
                                abcList.AdminCostValueProposed__c = (totalAdminIndirect * (abcList.Award__r.IndirectCostPercentage__c / 100)).setScale(2);
                            }
                        } else {
                            abcList.Amount__c = abcList.ProposedBudgetRevision__c;
                        }
                    }
                }
            }
        }
        System.debug('MANUALDEBUG >>> updated awardBudgetCategoryList = ' + awardBudgetCategoryList);
        AwardBudgetCategoryTriggerHelper.skipTrigger = true;
        update awardBudgetCategoryList;
        AwardBudgetCategoryTriggerHelper.skipTrigger = false;
    }


    private void waiveAllocationUpdate(List<Award__c> oldAwardList, List<Award__c> awardList) {
        System.debug('MANUALDEBUG >>> inside waiveAllocationUpdate');
        List<Id> awardIdList = new List<Id>();
        List<Id> acceptedAllocationChangeAwardIds = new List<Id>();
        Map<Id, Award__c> acceptedAllocIdMapAwardObject = new Map<Id, Award__c>();
        for (Award__c awardIterator : awardList) {
            for (Award__c oldAwardIterator : oldAwardList) {
                //if (awardIterator.Id == oldAwardIterator.Id && oldAwardIterator.AwardedAmount__c != null && oldAwardIterator.AwardedAmount__c != 0 && awardIterator.WaiveAllocationStatus__c == 'Waived') {
                System.debug('MANUALDEBUG >>> checking waiveAllocationUpdate conditions');
                if (awardIterator.Id == oldAwardIterator.Id && awardIterator.WaiveAllocationStatus__c == 'Waived') {
                    awardIterator.ObligatedAwardAmount__c = awardIterator.CurrentAllocatedAmount__c;
                    awardIterator.AllocatedAmount__c = awardIterator.CurrentAllocatedAmount__c;
                    awardIterator.WaiveAllocationStatus__c = 'N/A';//Reset waiving status for the next allocation update
                } else if (awardIterator.Id == oldAwardIterator.Id && awardIterator.WaiveAllocationStatus__c == 'Rejected') {
                    System.debug('MANUALDEBUG >>> waive approval rejected');
                    awardIterator.WaiveAllocationStatus__c = 'N/A';
                    awardIdList.add(awardIterator.Id);
                } else if (awardIterator.Id == oldAwardIterator.Id && awardIterator.WaiveAllocationStatus__c == 'Accepted') {
                    acceptedAllocationChangeAwardIds.add(awardIterator.Id);
                    acceptedAllocIdMapAwardObject.put(awardIterator.Id, awardIterator);
                    awardIdList.add(awardIterator.Id);
                }
            }
        }
        if (!acceptedAllocationChangeAwardIds.isEmpty()) {
            handleLeaInitiatedRevisions(acceptedAllocationChangeAwardIds); //Handle the LEA initiated revisions on the award before taking care of the USBE increased allocation revisions
            for (Id idIterator : acceptedAllocIdMapAwardObject.keySet()) {
                Award__c awardIterator = acceptedAllocIdMapAwardObject.get(idIterator);
                awardIterator.WaiveAllocationStatus__c = 'N/A';
                awardIterator.CurrentRevisionStatus__c = 'Created';
                awardIterator.BudgetRevisionInitiatedByUSBE__c = 'Allocation Change';
                awardIterator.BudgetRevisionInitiated__c = 'In Progress';
            }
        }
        System.debug('MANUALDEBUG >>> awardIdList: ' + awardIdList);
        if (awardIdList.size() > 0) { waiveAllocationRejectedTaskReset(awardIdList); }
    }

    @future
    private static void waiveAllocationRejectedTaskReset(List<Id> awardIdList) { //Handles task resetting for rejecting a waive allocation request and handles the auto budget revision when decreasing allocated amount
        System.debug('MANUALDEBUG >>> awardIdList: ' + awardIdList);
        List<Award__c> awardList = [SELECT Id, Name, GrantorOrganization__c, CurrentRevisionStatus__c, Grant__c, Grant__r.InternalOrganization__c FROM Award__c WHERE Id IN: awardIdList];

        Set<Id> grantIdSet = new Set<Id>();
        for (Award__c awardIterator : awardList) {
            grantIdSet.add(awardIterator.Grant__c);
        }
        List<Grant__c> grantList = [SELECT Id, InternalOrganization__c FROM Grant__c WHERE Id IN: grantIdSet];
        List<Id> leaIdList = new List<Id>();
        for (Grant__c grantIterator : grantList) {
            leaIdList.add(grantIterator.InternalOrganization__c);
        }
        List<User> leaUserList = [
                                     SELECT Id, Email, ProfileName__c, AccountId, ContactId
                                     FROM User
                                     WHERE AccountId IN: leaIdList AND (ProfileName__c = 'SPA' OR ProfileName__c = 'SPI')];
        Map<Id, List<User>> leaIdMapUserList = new Map<Id, List<User>>();
        Map<Id, User> userIdMapUserObj = new Map<Id, User>();
        for (User userIterator : leaUserList) {
            List<User> userList = leaIdMapUserList.get(userIterator.AccountId);
            if (userList == null) {
                userList = new List<User>();
                leaIdMapUserList.put(userIterator.AccountId, userList);
            }
            userList.add(userIterator);
            userIdMapUserObj.put(userIterator.Id, userIterator);
        }
        System.debug('MANUALDEBUG >>> leaUserList: ' + leaUserList);
        System.debug('MANUALDEBUG >>> leaIdMapUserList: ' + leaIdMapUserList); //Maps the LEA account Id to the list of Recipient Users who are associated with that LEA
        System.debug('MANUALDEBUG >>> userIdMapUserObj: ' + userIdMapUserObj);

        AppUtils.TaskEmailWrapper taskEmailer = new AppUtils.TaskEmailWrapper();
        taskEmailer.setUserList(leaUserList);
        taskEmailer.setTaskStartDate(System.TODAY());
        taskEmailer.setTaskEndDate(System.TODAY() + 7);
        taskEmailer.setAccountIdMapUserList(leaIdMapUserList); //leaIdMapUserObjList

        List<Id> waiveAllocationRejectAwardIds = new List<Id>();
        //List<Id> decreasedAllocationAwardIds = new List<Id>();
        for (Award__c awardIterator : awardList) {
            System.debug('MANUALDEBUG >>> awardIterator: ' + awardIterator);
            if (awardIterator.CurrentRevisionStatus__c != 'Created') { //Create task and email to check if they want to accept the change to their allocated amount (so if they want the modification to their budget)
                waiveAllocationRejectAwardIds.add(awardIterator.Id); //Send tasks and emails for 'Accept Or Waive Allocation Amount'
            } 
            //else {
                //decreasedAllocationAwardIds.add(awardIterator.Id); //Send tasks and emails for 'Complete Budget Revision'
            //}
        }
        if (waiveAllocationRejectAwardIds.size() > 0) {
            taskEmailer.setObjectList(waiveAllocationRejectAwardIds);
            //taskEmailer.setEmailTemplateDevName('Award_ready_for_subrecipient_approval'); //Customize with it's own email template when USBE gives us the email template to use
            taskEmailer.setTaskActionName('Accept Or Waive Allocation Amount');
            taskEmailer.setTaskSubject('Accept Or Waive Allocation Amount');
            //String resultMessage = taskEmailer.massSendTaskEmailMapOrg();
            String resultMessage = taskEmailer.massSendTaskMapOrg();
        }
        /*
        if (decreasedAllocationAwardIds.size() > 0) {
            taskEmailer.setObjectList(decreasedAllocationAwardIds);
            taskEmailer.setEmailTemplateDevName('Budget_Revision_Allocation_Changes');
            taskEmailer.setTaskActionName('Complete Budget Revision');
            taskEmailer.setTaskSubject('Complete Budget Revision');
            String resultMessage = taskEmailer.massSendTaskEmailMapOrg();
        }
        */
    }


    private void reviseBudgetForAllocationChange(List<Award__c> oldAwardList, List<Award__c> awardList) {
        Set<Id> grantIdSet = new Set<Id>();
        List<Id> awardIdList = new List<Id>();
        for (Award__c awardIterator : awardList) {
            for (Award__c oldAwardIterator : oldAwardList) {
                if (awardIterator.Id == oldAwardIterator.Id && oldAwardIterator.AllocatedAmount__c != null && oldAwardIterator.AllocatedAmount__c != 0 && (oldAwardIterator.WaiveAllocationStatus__c == 'N/A' || oldAwardIterator.WaiveAllocationStatus__c == null)) {
                    awardIdList.add(awardIterator.Id);
                    grantIdSet.add(awardIterator.Grant__c);
                }
            }
        }
        if (!awardIdList.isEmpty()) { //If the allocation amount has changed
            List<Grant__c> grantList = [SELECT Id, InternalOrganization__c FROM Grant__c WHERE Id IN: grantIdSet];
            List<Id> leaIdList = new List<Id>();
            for (Grant__c grantIterator : grantList) {
                leaIdList.add(grantIterator.InternalOrganization__c);
            }
            List<User> leaUserList = [
                SELECT Id, Email, ProfileName__c, AccountId, ContactId
                FROM User
                WHERE AccountId IN: leaIdList AND (ProfileName__c = 'SPA' OR ProfileName__c = 'SPI')];
            Map<Id, List<User>> leaIdMapUserList = new Map<Id, List<User>>();
            Map<Id, User> userIdMapUserObj = new Map<Id, User>();
            for (User userIterator : leaUserList) {
                List<User> userList = leaIdMapUserList.get(userIterator.AccountId);
                if (userList == null) {
                    userList = new List<User>();
                    leaIdMapUserList.put(userIterator.AccountId, userList);
                }
                userList.add(userIterator);
                userIdMapUserObj.put(userIterator.Id, userIterator);
            }
            System.debug('MANUALDEBUG >>> leaUserList: ' + leaUserList);
            System.debug('MANUALDEBUG >>> leaIdMapUserList: ' + leaIdMapUserList); //Maps the LEA account Id to the list of Recipient Users who are associated with that LEA
            System.debug('MANUALDEBUG >>> userIdMapUserObj: ' + userIdMapUserObj);

            List<GNT.TaskCreationHandler.TaskBulkClass> tasksList = new List<GNT.TaskCreationHandler.TaskBulkClass>();
            //EmailTemplate emailTemplate = [SELECT Id FROM EmailTemplate WHERE Name = 'Award ready for subrecipient approval' LIMIT 1];
            List<Id> decreasedAllocationAwardIds = new List<Id>();
            List<Id> increasedAllocationAwardIds = new List<Id>();
            Map<Id, Award__c> awardIdMapAwardObject = new Map<Id, Award__c>();
            for (Award__c awardIterator : awardList) {
                System.debug('MANUALDEBUG >>> awardIterator: ' + awardIterator);
                for (Award__c oldAwardIterator : oldAwardList) { //Allocation amount changed, thus need to do budget revision and send for USBE approval
                    if (awardIterator.GrantorOrganization__c == 'USBE' && oldAwardIterator.Id == awardIterator.Id && oldAwardIterator.AllocatedAmount__c != awardIterator.AllocatedAmount__c) {
                        awardIterator.CurrentAllocatedAmount__c = oldAwardIterator.AllocatedAmount__c; //Saves the old allocated amount for use if they waive the updated allocated amount
                        //Create task and email to check if they want to accept the change to their allocated amount (so if they want the modification to their budget)
                        if (oldAwardIterator.AllocatedAmount__c > awardIterator.AllocatedAmount__c) { //Decrease in allocated amount
                            awardIdMapAwardObject.put(awardIterator.Id, awardIterator);
                            decreasedAllocationAwardIds.add(awardIterator.Id);
                        } else { //Because we already only going through awards with an allocation change, these have an increase in allocated amount
                            increasedAllocationAwardIds.add(awardIterator.Id); //'Accept Or Waive Allocation Amount'
                        }
                    }
                }
            }
            if (!increasedAllocationAwardIds.isEmpty()) {
                AppUtils.TaskEmailWrapper taskEmailer = new AppUtils.TaskEmailWrapper();
                taskEmailer.setObjectList(increasedAllocationAwardIds);
                taskEmailer.setUserList(leaUserList);
                taskEmailer.setTaskActionName('Accept Or Waive Allocation Amount');
                taskEmailer.setTaskSubject('Accept Or Waive Allocation Amount');
                taskEmailer.setTaskStartDate(System.TODAY());
                taskEmailer.setTaskEndDate(System.TODAY() + 7);
                taskEmailer.setEmailTemplateDevName('Budget_Revision_Allocation_Changes');
                taskEmailer.setAccountIdMapUserList(leaIdMapUserList); //leaIdMapUserObjList
                String resultMessage = taskEmailer.massSendTaskMapOrg();
            }
            if (!decreasedAllocationAwardIds.isEmpty()) {
                handleLeaInitiatedRevisions(decreasedAllocationAwardIds); //Handle the LEA initiated revisions on the award before taking care of the USBE lowered allocation revisions
                for (Id idIterator : awardIdMapAwardObject.keySet()) {
                    Award__c awardIterator = awardIdMapAwardObject.get(idIterator);
                    awardIterator.WaiveAllocationStatus__c = 'Accepted';
                    awardIterator.CurrentRevisionStatus__c = 'Created';
                    awardIterator.BudgetRevisionInitiatedByUSBE__c = 'Allocation Change';
                    awardIterator.BudgetRevisionInitiated__c = 'In Progress';
                    awardIterator.CurrentAllocatedAmount__c = awardIterator.AllocatedAmount__c;
                }
                //waiveAllocationRejectedTaskReset(decreasedAllocationAwardIds); //Because we set the CurrentRevisionStatus__c as created, it goes into the send 'Complete Budget Revision' task part of the if statement
                AppUtils.TaskEmailWrapper taskEmailer = new AppUtils.TaskEmailWrapper();
                taskEmailer.setObjectList(decreasedAllocationAwardIds);
                taskEmailer.setUserList(leaUserList);
                taskEmailer.setTaskActionName('Complete Budget Revision');
                taskEmailer.setTaskSubject('Complete Budget Revision');
                taskEmailer.setTaskStartDate(System.TODAY());
                taskEmailer.setTaskEndDate(System.TODAY() + 7);
                taskEmailer.setEmailTemplateDevName('Budget_Revision_Allocation_Changes');
                taskEmailer.setAccountIdMapUserList(leaIdMapUserList); //leaIdMapUserObjList
                String resultMessage = taskEmailer.massSendTaskMapOrg();
            }
        }
    }


    private void SendTaskNotifications(List<Award__c> awardList) {
        for (Award__c award : awardList) {
            if (award.IsInApprovalProcess__c == true) {
                if (award.FO_Approved__c == true) {
                    GNT.TaskCreationHandler.createTasks(award.POUser__c, award.Id, 'Approve Award', award.Name, null, false, System.TODAY() + 7, 'Award Approval', true);
                }

            }
            if (award.Status__c == 'Approved') {
                //boolean GATaskExists = false;
                List<Task> taskList = [SELECT WhatId, Status, OwnerId FROM Task where WhatId = :award.Id and Status IN ('In Progress', 'Not Started')];
                if (!taskList.isEmpty()) {
                    for (Task t : taskList) {
                        if (t.OwnerId == award.POUser__c || t.OwnerId == award.FOUser__c) {
                            t.Status = 'Completed';
                        }
                        // if (t.OwnerId == award.GrantAdministrator__c) {
                        //     GATaskExists = true;
                        // }
                    }
                    update taskList;
                }
                // if (!GATaskExists) {
                //     System.debug('GAtask');
                //     GNT.TaskCreationHandler.createTasks(award.GrantAdministrator__c, award.Id, 'Approve Award', award.Name, null, false, System.TODAY() + 7, 'Award Approval', true);
                // }
            }
        }
    }


    private void checkForUpdatedIndirectBeforeInsert(List<Award__c> triggerList) {
        System.debug('MANUALDEBUG >>> triggerList: ' + triggerList);

        List<Award__c> awardList = new List<Award__c>();
        List<Id> appIdList = new List<Id>();
        List<Id> programIdList = new List<Id>();
        Map<Id, Id> appIdMapProgramId = new Map<Id, Id>();
        List<Id> leaIdList = new List<Id>();
        Map<Id, Id> appIdMapLeaId = new Map<Id, Id>();
        for (Award__c awardIterator : triggerList) {
            System.debug('MANUALDEBUG >>> awardIterator: ' + awardIterator);
            System.debug('MANUALDEBUG >>> grantorOrg:' + awardIterator.GrantorOrganization__c + ' , application: ' + awardIterator.Application__c + ' , skipfromamendment: ' + skipfromAmendment  + ' , grant: ' + awardIterator.Grant__c);
            if (awardIterator.GrantorOrganization__c == 'USBE' && awardIterator.Application__c != null && skipfromAmendment == false && awardIterator.Grant__c != null) {
                appIdList.add(awardIterator.Application__c);
                awardList.add(awardIterator);
            }
        }
        System.debug('MANUALDEBUG >>> ' + appIdList);
        System.debug('MANUALDEBUG >>> ' + awardList);
        if (awardList.size() > 0) {
            List<Application__c> appList = [SELECT Id, ProgramId__c, ExternalOrganization__c, IndirectCostPercentage__c FROM Application__c WHERE Id IN: appIdList];
            for (Application__c appIterator : appList) {
                programIdList.add(appIterator.ProgramId__c);
                appIdMapProgramId.put(appIterator.Id, appIterator.ProgramId__c);
                leaIdList.add(appIterator.ExternalOrganization__c);
                appIdMapLeaId.put(appIterator.Id, appIterator.ExternalOrganization__c);
            }
            System.debug('MANUALDEBUG >>> programIdList: ' + programIdList);
            System.debug('MANUALDEBUG >>> appIdMapProgramId: ' + appIdMapProgramId);
            System.debug('MANUALDEBUG >>> leaIdList: ' + leaIdList);

            //Map program Id to it's indirect cost type
            List<Program__c> programList = [SELECT Id, Name, USBEIndirectCostRate__c FROM Program__c WHERE Id IN: programIdList];
            System.debug('MANUALDEBUG >>> programList: ' + programList);
            Map<Id, String> programIdMapIndirect = new Map<Id, String>();
            for (Program__c programIterator : programList) {
                System.debug('MANUALDEBUG >>> programIterator: ' + programIterator);
                programIdMapIndirect.put(programIterator.Id, programIterator.USBEIndirectCostRate__c);
            }
            System.debug('MANUALDEBUG >>> programIdMapIndirect: ' + programIdMapIndirect);

            //Create map of LEA to USBELEACostRate__c
            Map<Id, USBELEACostRate__c> leaMapIndirectObject = new Map<Id, USBELEACostRate__c>();
            List<USBELEACostRate__c> leaCostRateList = new List<USBELEACostRate__c>([SELECT Id, Account__c, Year__r.StartDate__c, Year__r.EndDate__c, UnrestrictedIndirectRate__c, RestrictedIndirectRate__c FROM USBELEACostRate__c WHERE Account__c IN: leaIdList]);
            System.debug('MANUALDEBUG >>> leaCostRateList: ' + leaCostRateList);
            for (Award__c awardIterator : awardList) {
                //Indirect cost object where the LEA is among the ones we want to create applications for and is of the fiscal year that the application applies to
                for (Application__c appIterator : appList) {
                    if (awardIterator.Application__c == appIterator.Id) {
                        USBELEACostRate__c mostRecentIndirectObj;
                        for (USBELEACostRate__c costRateObjIterator : leaCostRateList) {
                            //Get the latest indirect cost object that applies for the award duration
                            System.debug('MANUALDEBUG >>> costRateObjIterator: ' + costRateObjIterator);
                            if (costRateObjIterator <> null) {
                                //if (appIterator.ExternalOrganization__c == costRateObjIterator.Account__c && costRateObjIterator.Year__r.StartDate__c <= awardIterator.ProjectPeriodStartDate__c) { //Pull the intial fiscal year of the application and use that to get the indirect object which is of that fiscal year for that LEA
                                System.debug('MANUALDEBUG >>> awardStart: ' + awardIterator.BudgetPeriodStartDates__c + ', awardEnd: ' + awardIterator.BudgetPeriodEndDates__c + ', costRateStart: ' + costRateObjIterator.Year__r.StartDate__c);
                                if (appIterator.ExternalOrganization__c == costRateObjIterator.Account__c && costRateObjIterator.Year__r.StartDate__c <= awardIterator.BudgetPeriodEndDates__c) {
                                    if (mostRecentIndirectObj == null) {
                                        mostRecentIndirectObj = costRateObjIterator;
                                    } else {
                                        if (costRateObjIterator.Year__r.StartDate__c >= mostRecentIndirectObj.Year__r.StartDate__c && costRateObjIterator.Year__r.EndDate__c >= mostRecentIndirectObj.Year__r.EndDate__c) {
                                            mostRecentIndirectObj = costRateObjIterator;
                                        }
                                    }
                                }
                            }
                        }
                        System.debug(mostRecentIndirectObj);
                        if (mostRecentIndirectObj <> null && mostRecentIndirectObj.Account__c <> null ) {
                            System.debug('Debug Account ' + mostRecentIndirectObj);
                            System.debug('Debug Obj ' + mostRecentIndirectObj.Account__c);
                            leaMapIndirectObject.put(mostRecentIndirectObj.Account__c, mostRecentIndirectObj); //Map the indirect object of the right fiscal year to the LEA
                        }
                    }
                }
            }
            System.debug('MANUALDEBUG >>> leaMapIndirectObject: ' + leaMapIndirectObject);
            System.debug('MANUALDEBUG >>> leaCostRateList' + leaCostRateList);

            //List<Award__c> awardIndirectModified = new List<Award__c>();
            //List<Id> awardIndirectModifiedId = new List<Id>();
            //Now go and assign the indirect rate from it's LEA's vendor profile and send the task & email for the budget revision
            for (Award__c awardIterator : awardList) {
                Id programId = appIdMapProgramId.get(awardIterator.Application__c); //Id of the program for the application
                String indirectType = programIdMapIndirect.get(programId); //Restricted or unrestricted
                Id leaId = appIdMapLeaId.get(awardIterator.Application__c); //LEA's Id
                USBELEACostRate__c currentCostRateObj = leaMapIndirectObject.get(leaId); //The indirect object of the application's starting fiscal year for that LEA
                System.debug('MANUALDEBUG >>> awardIterator.Id' + awardIterator.Id + ' programId: ' + programId + ' indirectType: ' + indirectType + ' leaId: ' + leaId + ' currentCostRateObj:' + currentCostRateObj);
                if (currentCostRateObj != null) {
                    if (indirectType == 'Restricted' && currentCostRateObj.RestrictedIndirectRate__c != awardIterator.IndirectCostPercentage__c) {
                        //awardIterator.IndirectCostPercentage__c = currentCostRateObj.RestrictedIndirectRate__c; //Assign it in the standard method
                        awardIterator.IndirectCostPercentageProposed__c = currentCostRateObj.RestrictedIndirectRate__c;
                    } else if (indirectType == 'Unrestricted' && currentCostRateObj.UnrestrictedIndirectRate__c != awardIterator.IndirectCostPercentage__c) {
                        //awardIterator.IndirectCostPercentage__c = currentCostRateObj.UnrestrictedIndirectRate__c;
                        awardIterator.IndirectCostPercentageProposed__c = currentCostRateObj.UnrestrictedIndirectRate__c;
                    }
                    awardIterator.BudgetRevisionInitiated__c = 'In Progress';//Automatically initiate revision for the awards
                    awardIterator.BudgetRevisionInitiatedByUSBE__c = 'Indirect Change';
                    //awardIndirectModified.add(awardIterator);
                }
            }
        }
    }


    private void createEmailAndTaskForBudgetRevision(List<Award__c> triggerList) {
        System.debug('MANUALDEBUG >>> inside of createEmailAndTaskForBudgetRevision');
        List<Id> awardIdList = new List<Id>();
        Set<Id> grantIdSet = new Set<Id>();
        for (Award__c awardIterator : triggerList) {
            if (awardIterator.GrantorOrganization__c == 'USBE' && awardIterator.BudgetRevisionInitiated__c == 'In Progress' && awardIterator.BudgetRevisionInitiatedByUSBE__c == 'Indirect Change') {
                awardIdList.add(awardIterator.Id);
                grantIdSet.add(awardIterator.Grant__c);
            }
        }
        if (awardIdList.size() > 0) {
            List<Grant__c> grantList = [SELECT Id, InternalOrganization__c FROM Grant__c WHERE Id IN: grantIdSet];
            List<Id> leaIdList = new List<Id>();
            for (Grant__c grantIterator : grantList) {
                leaIdList.add(grantIterator.InternalOrganization__c);
            }
            List<User> leaUserList = [
                                         SELECT Id, Email, ProfileName__c, AccountId, ContactId
                                         FROM User
                                         WHERE AccountId IN: leaIdList AND (ProfileName__c = 'SPA' OR ProfileName__c = 'SPI')];
            Map<Id, List<User>> leaIdMapUserList = new Map<Id, List<User>>();
            Map<Id, User> userIdMapUserObj = new Map<Id, User>();
            for (User userIterator : leaUserList) {
                List<User> userList = leaIdMapUserList.get(userIterator.AccountId);
                if (userList == null) {
                    userList = new List<User>();
                    leaIdMapUserList.put(userIterator.AccountId, userList);
                }
                userList.add(userIterator);
                userIdMapUserObj.put(userIterator.Id, userIterator);
            }
            System.debug('MANUALDEBUG >>> leaUserList: ' + leaUserList);
            System.debug('MANUALDEBUG >>> leaIdMapUserList: ' + leaIdMapUserList); //Maps the LEA account Id to the list of Recipient Users who are associated with that LEA
            System.debug('MANUALDEBUG >>> userIdMapUserObj: ' + userIdMapUserObj);
            AppUtils.TaskEmailWrapper taskEmailer = new AppUtils.TaskEmailWrapper();
            taskEmailer.setObjectList(awardIdList);
            taskEmailer.setUserList(leaUserList);
            taskEmailer.setTaskActionName('Complete Budget Revision');
            taskEmailer.setTaskSubject('Complete Budget Revision');
            taskEmailer.setTaskStartDate(System.TODAY());
            taskEmailer.setTaskEndDate(System.TODAY() + 7);
            taskEmailer.setEmailTemplateDevName('Budget_Revision_Indirect_Cost_Rate_Changes');
            taskEmailer.setAccountIdMapUserList(leaIdMapUserList); //leaIdMapUserObjList
            String resultMessage = taskEmailer.massSendTaskEmailMapOrg();
        }
    }


    private void handleLeaInitiatedRevisions(List<Id> applicableAwardIdList) {
        //If there are current LEA initiated budget revisions on those awards, reject them and reset the award so that the USBE budget revision takes precidence
        Set<String> revisionNotInProgressStatusList = new Set<String> {'Not Started', 'Change Requested', 'Rejected', 'Active'};
        //Find all AmendmentRequest__c whose Award__c are in the list of edited Awards and their Status__c is not in Active/Change Requested/Rejected/Revised
        List<AmendmentRequest__c> budgetRevisionList = [
                    SELECT Id, Award__r.BudgetRevisionInitiatedByUSBE__c, Status__c
                    FROM AmendmentRequest__c
                    WHERE Award__c IN: applicableAwardIdList AND Award__r.BudgetRevisionInitiatedByUSBE__c = 'Not Initiated By USBE' AND Status__c NOT IN: revisionNotInProgressStatusList];
        if (!budgetRevisionList.isEmpty()) {
            //If any of the budget revisions are locked due to an approval process
            List<AmendmentRequest__c> lockedBudgetRevisions = new List<AmendmentRequest__c>();
            List<Id> budgetRevisionIdList = new List<Id>();
            for (AmendmentRequest__c amendmentRequestIterator : budgetRevisionList) {
                if (Approval.isLocked(amendmentRequestIterator)) {
                    lockedBudgetRevisions.add(amendmentRequestIterator);
                }
                budgetRevisionIdList.add(amendmentRequestIterator.Id);
            }
            if (lockedBudgetRevisions.size() > 0) { //If there are any who are locked, unlock them
                AmendmentRequestTriggerHelper.skipTrigger = true;
                Approval.UnlockResult[] unlockResultList = Approval.unlock(lockedBudgetRevisions, false);
                AmendmentRequestTriggerHelper.skipTrigger = false;
                for (Approval.UnlockResult unlockResultIterator : unlockResultList) { // Iterate through each returned result
                    if (unlockResultIterator.isSuccess()) { // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully unlocked record with ID: ' + unlockResultIterator.getId());
                    } else { // Operation failed, so get all errors
                        for (Database.Error err : unlockResultIterator.getErrors()) {
                            System.debug('Error has occured with: ' + err.getFields() + ' : ' + err.getStatusCode() + ' : ' + err.getMessage());
                        }
                    }
                }
            }
            //Get approval processes for those LEA budget revision records
            List<ProcessInstanceWorkItem> approvalItemList = [SELECT Id FROM ProcessInstanceWorkItem WHERE ProcessInstance.TargetObjectId IN: budgetRevisionIdList AND ProcessInstance.Status = 'Pending'];
            AmendmentRequestTriggerHelper.skipTrigger = true;
            for (ProcessInstanceWorkItem approvalItem : approvalItemList) {
                Approval.ProcessWorkItemRequest request = new Approval.ProcessWorkItemRequest();
                request.setComments('Rejected Due To Change In Allocated Amount');
                request.setAction('Reject');
                request.setWorkItemId(approvalItem.Id);
                Approval.ProcessResult result = Approval.process(request);
            }
            AmendmentRequestTriggerHelper.skipTrigger = false;
            //Get tasks for those LEA budget revision records
            List<Task> taskList = [SELECT Id FROM Task WHERE WhatId IN: budgetRevisionIdList AND Status != 'Completed'];
            for (Task taskIterator : taskList) {
                taskIterator.Status = 'Completed';
            }
            AmendmentRequestTriggerHelper.skipTrigger = true;
            update taskList;
            AmendmentRequestTriggerHelper.skipTrigger = false;

            for (AmendmentRequest__c budgetRevisionIterator : budgetRevisionList) { //All records are unlocked and are available for modification
                //Close all approval processes and tasks for those LEA budget revision records
                budgetRevisionIterator.Status__c = 'Rejected'; //Set those LEA budget revisions as rejected.
            }
            AmendmentRequestTriggerHelper.skipTrigger = true;
            update budgetRevisionList;
            AmendmentRequestTriggerHelper.skipTrigger = false;

            //We have to handle resetting the award ourselves because this is working right on the Award trigger, bad to call a trigger that will call this trigger again (recursive loop). It calls a skip trigger though

            //Reset award
            for (Award__c awardIterator : (List<Award__c>)Trigger.New) {
                for (Id idIterator : applicableAwardIdList) {
                    if (awardIterator.Id == idIterator) {
                        awardIterator.BudgetNarrativeWrite__c = '';
                        awardIterator.BudgetRevisionInitiated__c = 'Not Started';
                        awardIterator.CurrentRevisionStatus__c = 'Rejected';
                        awardIterator.ApprovedInternally__c = false;
                        awardIterator.PercentVarianceOverTen__c = false;
                        awardIterator.CurrentBudgetRevisionId__c = null;
                        awardIterator.BudgetRevisionInitiatedByUSBE__c = 'Not Initiated By USBE';
                    }
                }
            }
            //resetAwardBudgetCategoriesForUSBERevision(applicableAwardIdList);
        }
        //Now that those LEA budget revisions are rejected, we can modify the awards to initiate the USBE budget revisions (continue with the workflow)
    }

    @future
    private static void resetAwardBudgetCategoriesForUSBERevision(List<Id> applicableAwardIdList) {
        List<AwardBudgetCategory__c> awardBudgetCategoryList = new List<AwardBudgetCategory__c>();
        List<BuildUpItem__c> buildUpItemList = new List<BuildUpItem__c>();
        List<AwardBudgetCategory__c> awardBudgetCategories = new List<AwardBudgetCategory__c>([
                    SELECT Id, Award__c, BudgetCategory__c, CurrentApprovedBudgetAmount__c, ProposedBudgetRevision__c, PercentVariance__c, PercentVarianceText__c, RowNumberFormula__c, AdminCostValue__c, AdminCostValueProposed__c
                    FROM AwardBudgetCategory__c
                    WHERE Award__c IN :applicableAwardIdList AND RowNumberFormula__c != null]);
        for (AwardBudgetCategory__c abcIterator : awardBudgetCategories) { //For (all the award budget categories in the award)
            //Modifications made to award budget category:
            // abcIterator.CurrentApprovedBudgetAmount__c = abcIterator.ProposedBudgetRevision__c; //
            abcIterator.ProposedBudgetRevision__c = abcIterator.CurrentApprovedBudgetAmount__c;  //Default proposed budget gets set to equal the value of the currently active budget (reset the value to pre-revision)
            //abcIterator.PercentVariancePrevious__c = abcIterator.PercentVarianceText__c; //We're keeping the old percent variance value(s)
            //abcIterator.PercentVarianceText__c = abcIterator.PercentVariancePrevious__c;
            abcIterator.AdminCostValueProposed__c = abcIterator.AdminCostValue__c;
            awardBudgetCategoryList.add(abcIterator);
        }
        //Reset the buildup items in the AwardBudgetCategory 570
        List<BuildUpItem__c> currentBuildUpItems = new List<BuildUpItem__c>([
                    SELECT Id, AwardBudgetCategory__c, AwardBudgetCategory__r.Award__c, AwardBudgetCategory__r.BudgetCategory__r.RowNumber__c, CurrentActiveAwardBudgetBuildup__c, EquipmentDesc__c, EquipmentQuantity__c, EquipmentUnitPrice__c
                    FROM BuildUpItem__c
                    WHERE AwardBudgetCategory__r.Award__c IN :applicableAwardIdList AND AwardBudgetCategory__r.BudgetCategory__r.RowNumber__c = '570']);
        //Select the buildup items relevant for for this award's budget categories
        for (BuildUpItem__c buildUpItemIterator : currentBuildUpItems) { //Create new copy of them, but set field to reference the amendment request we created (for search reference)
            if (buildUpItemIterator.CurrentActiveAwardBudgetBuildup__c == 'Active') { //
                //Create a copy set of the current 'created' buildup items which are flagged as 'created' so on the next revision they show up as the default items
                BuildUpItem__c activeBuildUpItem = new BuildUpItem__c();
                activeBuildUpItem.AwardBudgetCategory__c = buildUpItemIterator.AwardBudgetCategory__c;
                activeBuildUpItem.EquipmentDesc__c = buildUpItemIterator.EquipmentDesc__c;
                activeBuildUpItem.EquipmentQuantity__c = buildUpItemIterator.EquipmentQuantity__c;
                activeBuildUpItem.EquipmentUnitPrice__c = buildUpItemIterator.EquipmentUnitPrice__c;
                activeBuildUpItem.CurrentActiveAwardBudgetBuildup__c = 'Created'; //Already have the 'active' buildup items for the next history item, so make the default items
                buildUpItemList.add(activeBuildUpItem);
            } else if (buildUpItemIterator.CurrentActiveAwardBudgetBuildup__c == 'Created') { //
                //Remove all 'created' buildup items and replace them with the old 'active' buildup items (revert to pre-revision) for reference use if the next revision is rejected
                buildUpItemIterator.CurrentActiveAwardBudgetBuildup__c = 'Revised';
                buildUpItemList.add(buildUpItemIterator);
            }
        }
        AmendmentRequestTriggerHelper.skipTrigger = true;
        AwardBudgetCategoryTriggerHelper.skipTrigger = true;
        BuildUpItemTriggerHelper.skipTrigger = true;
        BuildUpItemTriggerHelper.skipfromAmendment = true;
        if (awardBudgetCategoryList.size() > 0) { update awardBudgetCategoryList; }
        if (buildUpItemList.size() > 0) { upsert buildUpItemList; }
        BuildUpItemTriggerHelper.skipTrigger = false;
        BuildUpItemTriggerHelper.skipfromAmendment = false;
        AwardBudgetCategoryTriggerHelper.skipTrigger = false;
        AmendmentRequestTriggerHelper.skipTrigger = false;
    }

}