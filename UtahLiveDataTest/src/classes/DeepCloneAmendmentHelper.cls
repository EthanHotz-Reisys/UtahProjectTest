/**
* This class is triggered when Formal Amendment Request is email approved
* and internal user initiates Award cloning from the Amendment Request
*
* @Author: Sarat Mahavratayajula
*/
global with sharing class DeepCloneAmendmentHelper extends GNT.DynamicLayoutActionRedirect {

    private AmendmentRequest__c currentAmendRequest;
    private Award__c oldAward;
    private List<AwardBudgetCategory__c> awardbudgetCategories = new List<AwardBudgetCategory__c>();
    private Grant__c amendmentRequestGrant;
    //private Id recordId = layoutHolder.getPrimarySObject().Id;
    Id recordId;
    //private List<RecordType> amendmentRecordTypes;
    public DeepCloneAmendmentHelper() {
        /* amendmentRecordTypes = [select Id, Name, DeveloperName
                                 FROM RecordType
                                 where SobjectType = :AppUtils.getNamespacePrefix() + 'AmendmentRequest__c'];*/
    }

    public DeepCloneAmendmentHelper(GNT.DynamicLayoutHolder layoutHolder) {
        this.layoutHolder = layoutHolder;
    }

    public DeepCloneAmendmentHelper(ApexPages.StandardController controller) {
        currentAmendRequest = (AmendmentRequest__c)controller.getRecord();
        /*amendmentRecordTypes = [select Id, Name, DeveloperName
                                 FROM RecordType
                                 where SobjectType = :AppUtils.getNamespacePrefix() + 'AmendmentRequest__c'];*/
    }

    global override PageReference whenClicked() {
        Savepoint sp = Database.setSavepoint();
        recordId = layoutHolder.getPrimarySObject().Id;
        GrantTriggerHelper.skipTrigger = true;
        AwardtriggerHelper.skipfromAmendment = true;
        BuildUpItemTriggerHelper.skipfromAmendment = true;
        Award__c newAward;
        try {

            Map<Id, String> recordTypeMap = new Map<Id, String>();

            List<RecordType> amendmentRecordTypes = [select Id, Name, DeveloperName
                                                    FROM RecordType
                                                    where SobjectType = :AppUtils.getNamespacePrefix() + 'AmendmentRequest__c'];

            for (RecordType recordType : amendmentRecordTypes) {
                recordTypeMap.put(recordType.Id, recordType.DeveloperName);
            }


            currentAmendRequest = [select Award__c, BudgetPeriodExtension__c, KeyPOCLookUp__c, KeyContactChange__c,NewGranteePOC__c,
                                   AmendmentRequest__c.NoCostExtension__c, BudgetPeriodChange__c,
                                   NewBudgetPeriodEndDate__c, NewKeyPOC__c, Award__r.BudgetPeriod__c,Award__r.Grant__c,
                                   AmendmentBudgetPeriod__c, RecordTypeId, PriorAwardedAmount__c,AmendAwardCount__c
                                   from AmendmentRequest__c
                                   where Id = :recordId];
            Grant__c grant = [Select id,GranteePOC__c,ProjectPeriodEndDate__c from Grant__c where id=:currentAmendRequest.Award__r.Grant__c];


            oldAward = [SELECT Name, DeepCloned__c,PendingPayment__c,YTDRemainingAmount__c,YTDReimbursementPaid__c,IndirectCostPercentageProposed__c, Grant__c, TotalObligateAmount__c, GrantAwardName__c, FederalGrantAwardIdFAIN__c,
                        CFDANumber__c, Grant__r.ExternalOrganization__c, Grant__r.FederalProgram__c, AwardType__c,
                        FederalAssistanceType__c, AwardIssueDate__c, PriorAwardedAmount__c,Q1DueDate__c,Q2DueDate__c,Q3DueDate__c,Q4DueDate__c,
                        IsStateMatchRequired__c, StateMatchDueDate__c, Grant__r.Program__c,FOUser__c,
                        Grant__r.InternalOrganization__c, HaveYouAcceptedTheAward__c, DUNSNumber__c,GranteePOC__c,ProjectTitle__c,
                        Application__c, AmendmentType__c, BudgetPeriod__c,ApplicationPOC__c,ProjectPeriodStartDate__c,ProjectPeriodEndDate__c,
                        AmendedPurchaseOrderNumber__c, AreTCspartofNGAAttachments__c, AwardedAmountthisAction__c,
                        GrantAwardDescription__c, Addressline1__c, Addressline2__c, City__c, County__c,
                        State__c, Zip4__c, Country__c, ActiveBudgetYear__c
                        FROM Award__c
                        WHERE Id = :currentAmendRequest.Award__c];
            oldAward.DeepCloned__c = true;
            oldAward.Status__c = 'Amended';
            update oldAward;

            currentAmendRequest.AmendAwardCount__c = currentAmendRequest.AmendAwardCount__c + 1;
            AmendmentRequestTriggerHelper.skipTrigger = true;
            update currentAmendRequest;
            AmendmentRequestTriggerHelper.skipTrigger = false;

            String amendmentRecordTypeDeveloperName = recordTypeMap.get(currentAmendRequest.RecordTypeId);
            newAward = oldAward.clone(false);
            //if (oldAward.PriorAwardedAmount__c != null) {
            //    newAward.PriorAwardedAmount__c = oldAward.PriorAwardedAmount__c + oldAward.AwardedAmountthisAction__c;
            //}

            
                       
            newAward.AwardType__c = 'Amendment';
            newAward.Application__c = oldAward.Application__c;
            if (amendmentRecordTypeDeveloperName.equals('PeriodicAnnualRenewal')) {
                system.debug('In periodic amendment --> ');
                AggregateResult[] groupedResults = [SELECT SUM(GrantorAmount__c)adjustSum FROM AmendmentRequestBudgetCategory__c where AmendmentRequest__c = :currentAmendRequest.Id];
                newAward.ObligatedAwardAmount__c = Integer.valueOf(groupedResults[0].get('adjustSum'));
                newAward.PriorAwardedAmount__c = 0;
                newAward.ActiveBudgetYear__c = oldAward.ActiveBudgetYear__c + 1;
                newAward.BudgetPeriod__c = currentAmendRequest.AmendmentBudgetPeriod__c;
                insert newAward;

                copyAmdBudCatsToAwdBudCats(newAward.Id,currentAmendRequest.AmendmentBudgetPeriod__c);
            }
            
            if (amendmentRecordTypeDeveloperName.equals('FormalAmendments')) {
                AggregateResult[] groupedResults = [SELECT SUM(Federal__c)adjustSum FROM AmendmentRequestBudgetCategory__c where AmendmentRequest__c = :currentAmendRequest.Id];
                newAward.PriorAwardedAmount__c = currentAmendRequest.PriorAwardedAmount__c;
                newAward.Status__c='Activated';
                newAward.ObligatedAwardAmount__c = Double.valueOf(groupedResults[0].get('adjustSum'));
                if(currentAmendRequest.KeyContactChange__c){
                    newAward.GranteePOC__c = currentAmendRequest.NewGranteePOC__c;
                    grant.GranteePOC__c = currentAmendRequest.NewGranteePOC__c;
                } 
                if (!currentAmendRequest.NoCostExtension__c && !currentAmendRequest.BudgetPeriodChange__c) {
                    SystemContextMethodsHelper syscontextHelper = new SystemContextMethodsHelper();
                    syscontextHelper.insertAwardAmend(newAward);
                    update grant;
                    new GNT.EmailFeeder().TargetObjectID(grant.GranteePOC__c).template('AmendmentAwardActivated').contextRecordId(oldAward.Id).send();
                    new GNT.EmailFeeder().TargetObjectID(oldAward.FOUser__c).template('AmendmentApprovalEmailToFA').contextRecordId(currentAmendRequest.Id).send();
                    //insert newAward;
                    system.debug('*** sarat test 1' + newAward.Id);
                }
                // Need to research more on implications of this flag
                newAward.DeepCloned__c = true;
                BudgetPeriod__c grantBudgetperiod = new BudgetPeriod__c();
                // Insert new budget period in the grant if
                if (currentAmendRequest.NoCostExtension__c || currentAmendRequest.BudgetPeriodChange__c) {
                    List<AwardBudgetCategory__c> awardBudgetCategory = [select Id, BudgetPeriod__c, BudgetCategory__c
                            from AwardBudgetCategory__c
                            where Award__c = :oldAward.Id];

                    BudgetPeriod__c oldBudgetperiod = [SELECT BudgetStartDate__c, Grant__c, Notes__c, SupportYear__c, Name
                                                       FROM BudgetPeriod__c
                                                       where Id = :awardBudgetCategory[0].BudgetPeriod__c];
                    List<BudgetPeriod__c> budgetPeriodsList = new List<BudgetPeriod__c>();
                    grant.ProjectPeriodEndDate__c = currentAmendRequest.NewBudgetPeriodEndDate__c;
                    update grant;
                    new GNT.EmailFeeder().TargetObjectID(grant.GranteePOC__c).template('AmendmentAwardActivated').contextRecordId(oldAward.Id).send();
                    new GNT.EmailFeeder().TargetObjectID(oldAward.FOUser__c).template('AmendmentApprovalEmailToFA').contextRecordId(currentAmendRequest.Id).send();
                    oldBudgetperiod.Status__c = 'Closed';
                    budgetPeriodsList.add(oldBudgetperiod);
                    grantBudgetperiod.Grant__c = oldBudgetperiod.Grant__c;
                    grantBudgetperiod.Status__c = 'Active';
                    grantBudgetperiod.Modified__c = true;
                    //grantBudgetperiod.Name = oldBudgetperiod.Name;
                    grantBudgetperiod.SupportYear__c = oldBudgetperiod.SupportYear__c;
                    grantBudgetperiod.BudgetStartDate__c = oldBudgetperiod.BudgetStartDate__c;
                    grantBudgetperiod.Notes__c = oldBudgetperiod.Notes__c;
                    grantBudgetperiod.BudgetEndDate__c = currentAmendRequest.NewBudgetPeriodEndDate__c;
                    budgetPeriodsList.add(grantBudgetperiod);
                    upsert budgetPeriodsList;
                    newAward.BudgetPeriod__c = grantBudgetperiod.Id;
                    newAward.ProjectPeriodStartDate__c = grant.ProjectPeriodStartDate__c;
                    newAward.ProjectPeriodEndDate__c = grant.ProjectPeriodEndDate__c;
                    SystemContextMethodsHelper syscontextHelper = new SystemContextMethodsHelper();
                    syscontextHelper.insertAwardAmend(newAward);
                    //insert newAward;
                    system.debug('*** sarat test 2' + newAward.Id);
                }

                List<GrantContact__c> awardContactList = new List<GrantContact__c>();
                Contact newKeyPoc;

                if (!currentAmendRequest.KeyContactChange__c) {
                    for (GrantContact__c gc : [SELECT Contact__c, Type__c, Role__c, Organization__c, Email__c, Phone__c
                                               FROM GrantContact__c
                                               WHERE Award__c = :oldAward.Id]) {
                        GrantContact__c newGrantContact = gc.clone(false);
                        newGrantContact.Award__c = newAward.Id;
                        awardContactList.add(newGrantContact);
                    }
                } else {
                    for (GrantContact__c gc : [SELECT Contact__c, Type__c, Role__c, Organization__c, Email__c, Phone__c
                                               FROM GrantContact__c
                                               WHERE (Award__c = :oldAward.Id and Role__c <> 'KeyPOC')]) {
                        GrantContact__c newGrantContact = gc.clone(false);
                        newGrantContact.Award__c = newAward.Id;
                        awardContactList.add(newGrantContact);
                    }
                    // Add NewKeyPoc to AwardContact List
                    GrantContact__c addNewKeyPoc = new GrantContact__c();
                    addNewKeyPoc.Role__c = 'KeyPOC';
                    addNewKeyPoc.Award__c = newAward.Id;
                    addNewKeyPoc.Contact__c = currentAmendRequest.NewKeyPOC__c;
                    awardContactList.add(addNewKeyPoc);

                }
                GrantContactTriggerHelper.skipTrigger = true;
                insert awardContactList;


                if (currentAmendRequest.BudgetPeriodExtension__c == true || currentAmendRequest.BudgetPeriodChange__c == true) {
                    if(currentAmendRequest.NewBudgetPeriodEndDate__c != null){
                        BudgetPeriod__c bdToUpdate = [Select BudgetEndDate__c from BudgetPeriod__c where Id = :oldAward.BudgetPeriod__c];
                        bdToUpdate.BudgetEndDate__c = currentAmendRequest.NewBudgetPeriodEndDate__c;
                        update bdToUpdate;
                        copyAmdBudCatsToAwdBudCats(newAward.Id, currentAmendRequest.AmendmentBudgetPeriod__c);
                    }else if (currentAmendRequest.NewBudgetPeriodEndDate__c == null) {
                        system.debug('*** In the method');
                        copyAmdBudCatsToAwdBudCats(newAward.Id, currentAmendRequest.AmendmentBudgetPeriod__c);            
                    }
                } else {
                    copyPreviousAwdBudCatsToNewAwdBudCats(currentAmendRequest.Award__c, newAward.Id, currentAmendRequest.AmendmentBudgetPeriod__c);
                }
            }


            //Update Pending Progress Report to the new Award
            List<ProgressReports__c> progreportlist = new List<ProgressReports__c>();
            for ( ProgressReports__c progrpt : [select id, name, Status__c, Award__c from ProgressReports__c where Award__c = :oldAward.Id and Status__c IN
                                                ('Created', 'Submitted for Approval', 'Submitted to Grantor')]) {
                progrpt.Award__c = newAward.Id;
                progreportlist.add(progrpt);
            }
            if (!progreportlist.isEmpty()) {
                ProgressReportsTriggerHelper.skipTrigger = true;
                update progreportlist;
            }
            //Update Pending Site Visits to the new Award
            List<SiteVisit__c> sitevisitlist = new List<SiteVisit__c>();
            for (SiteVisit__c sitevisit : [select id, name, Status__c, Award__c from SiteVisit__c where Award__c = :oldAward.Id and Status__c IN
                                           ('Created', 'Planned', 'Visited', 'Report Submitted')]) {
                sitevisit.Award__c = newAward.Id;
                sitevisitlist.add(sitevisit);
            }
            if (!sitevisitlist.isEmpty()) {
                SiteVisitTriggerHelper.skipTrigger = true;
                update sitevisitlist;
            }

            //Update Pending Payment requests to the new Award
            List<PaymentRequest__c> paymentrequestlist = new List<PaymentRequest__c>();
            for (PaymentRequest__c paymentrequest : [select id, name, Status__c, Award__c from PaymentRequest__c where Award__c = :oldAward.Id and Status__c IN
                    ('Created', 'Submitted to Grantor')]) {
                paymentrequest.Award__c = newAward.Id;
                paymentrequestlist.add(paymentrequest);
            }
            if (!paymentrequestlist.isEmpty()) {
                PaymentRequestTriggerHelper.skipTrigger = true;
                update paymentrequestlist;
            }
            //Update Pending Goals to the new Award
            List<GoalObjective__c> goalslist = new List<GoalObjective__c>();
            for (GoalObjective__c goals : [select id, name, Status__c, Award__c from GoalObjective__c where Award__c = :oldAward.Id]) {
                goals.Award__c = newAward.Id;
                goalslist.add(goals);
            }
            if (!goalslist.isEmpty()) {
                GoalObjectiveTriggerHelper.skipTrigger = true;
                update goalslist;
            }
            //Update Deliverables to the new Award
            List<Deliverable__c> deliverablelist = new List<Deliverable__c>();
            for (Deliverable__c deliverables : [select id, name, Status__c, Award__c from Deliverable__c where Award__c = :oldAward.Id]) {
                deliverables.Award__c = newAward.Id;
                deliverablelist.add(deliverables);
            }
            if (!deliverablelist.isEmpty()) update deliverablelist;
            //Update WBS to the new Award
            List<WBSTaskSchedule__c> wbslist = new List<WBSTaskSchedule__c>();
            for (WBSTaskSchedule__c wbs : [select id, name, Award__c from WBSTaskSchedule__c where Award__c = :oldAward.Id]) {
                wbs.Award__c = newAward.Id;
                wbslist.add(wbs);
            }
            if (!wbslist.isEmpty()) update wbslist;
            //update amendmentRequestGrant;
            // Insert Roles and Responsibilities
            List<RolesAndResponsibilities__c> rolesandresplist = new List<RolesAndResponsibilities__c>();
            for (RolesAndResponsibilities__c rolesandresp : [select Name__c, BusinessRole__c, Responsibility__c
                    From RolesAndResponsibilities__c
                    where Award__c = :oldAward.Id]) {
                RolesAndResponsibilities__c newawdrresp = rolesandresp.clone(false);
                newawdrresp.Award__c = newAward.Id;
                rolesandresplist.add(newawdrresp);
            }
            insert rolesandresplist;
            system.debug('***Roles and responsibilites inserted');
            // Insert Award Funding Account
            List<AwardFundingAccount__c> awardFundingAccounts = new List<AwardFundingAccount__c>();
            for (AwardFundingAccount__c awardFundingAccount : [select FundingAccount__c, FundingAccount__r.Title__c,
                    FundingAccount__r.FundingSource__r.Type__c,
                    FundingAccount__r.FundingSource__r.Grant__r.ExternalOrganization__c,
                    FundingAccount__r.FundingSource__r.ReferenceNumber__c,
                    FundingAccount__r.SumOfBudgetCategories__c, CommittedAmount__c
                    from AwardFundingAccount__c
                    where Award__c = :oldAward.Id]) {
                AwardFundingAccount__c newAwardFundingAccount =  awardFundingAccount.clone(false);
                newAwardFundingAccount.Award__c = newAward.Id;
                awardFundingAccounts.add(newAwardFundingAccount);
            }
            insert awardFundingAccounts;

            List<RecordType> termconditions = [select Id, DeveloperName
                                               from RecordType
                                               where SobjectType = 'TermCondition__c'];
            Id siteVisit;
            Id termsAndCondition;
            Id reportingRequirement;
            Id paymentRequest;

            for (RecordType rt : termconditions) {
                if (rt.DeveloperName.contains('SiteVisit')) {
                    siteVisit = rt.Id;
                }
                if (rt.DeveloperName.contains('Term')) {
                    termsAndCondition = rt.Id;
                }
                if (rt.DeveloperName.contains('ReportingRequirement')) {
                    reportingRequirement = rt.Id;
                }
                if (rt.DeveloperName.contains('PaymentRequest')) {
                    paymentRequest = rt.Id;
                }

            }

            List<TermCondition__c> TermConditionlist = new List<TermCondition__c>();
            for (TermCondition__c TermCondition : [select Name, Title__c, Description__c, EffectiveFrom__c, Recordtypeid, CalReportingStartDate__c,
                                                   CalReportingEndDate__c, ReportName__c, Category__c, WillAgencywithholdFundsifnotSubmit__c,
                                                   AmountWithheld__c, ReportingFrequency__c, Frequency__c, ReportingPeriod__c, DueDateDays__c,
                                                   VisitEndDateTime__c, SiteVisitDateTime__c
                                                   from TermCondition__c
                                                   where Award__c = :oldAward.Id and
                                                           (recordtypeid = :termsAndCondition or
                                                                   (recordtypeid = :siteVisit and VisitEndDateTime__c >= TODAY) or
                                                                   (recordtypeid = :reportingRequirement and CalReportingEndDate__c >= TODAY) or
                                                                   (recordtypeid = :paymentRequest and CalReportingEndDate__c >= TODAY))]) {
                TermCondition__c newawdtc = TermCondition.clone(false);
                newawdtc.Award__c = newAward.Id;
                TermConditionlist.add(newawdtc);
            }
            //insert TermConditionlist;
            List<KeyOutcome__c> keyoutcomelist = new List<KeyOutcome__c>();
            for (KeyOutcome__c keyoutcome : [select Name, KeyPerformanceCategory__c, KeyPerformanceIndicator__c, Target__c
                                             from KeyOutcome__c
                                             where Award__c = :oldAward.Id]) {
                KeyOutcome__c newawdko = keyoutcome.clone(false);
                newawdko.Award__c = newAward.Id;
                keyoutcomelist.add(newawdko);
            }
            insert keyoutcomelist;
            system.debug('***key outcomes inserted');

        } catch (Exception ex) {
            Database.rollback(sp);
            ApexPages.addMessages(ex);
            return null;
        }
        return new PageReference('/apex/AwardView?id=' + newAward.id);
    }

    public void copyAmdBudCatsToAwdBudCats(Id newAwardId, Id budgetPeriod) {
        List<AwardBudgetCategory__c> awardBudgetCategories = new List<AwardBudgetCategory__c>();
        List<AmendmentRequestBudgetCategory__c> amendmentBudgetcategories = [select BudgetCategory__c, ServiceArea1__c,Federal__c,InKindMatch__c,CashMatch__c,
                                                GrantorAmount__c, GranteeAmount__c,BudgetCategory__r.Name,PendingPayment__c,YTDReimbursementPaid__c,CurrentApprovedBudgetAmount__c,CashMatchExpenditure__c,InKindExpenditure__c,
                                                Amount__c
                                                from AmendmentRequestBudgetCategory__c
                                                where AmendmentRequest__c = :recordId];

        List<Id> amemndmentBudgetCategoryIds = new List<Id>();

        for (AmendmentRequestBudgetCategory__c amendBudgetcategory : amendmentBudgetcategories) {
            amemndmentBudgetCategoryIds.add(amendBudgetcategory.Id);
        }

        for (AmendmentRequestBudgetCategory__c newAmendBudgetCategory : amendmentBudgetcategories) {
            AwardBudgetCategory__c awardbudgetCategory = new AwardBudgetCategory__c();
            awardbudgetCategory.Award__c = newAwardId;
            awardbudgetCategory.ServiceArea__c = newAmendBudgetCategory.ServiceArea1__c;
            awardbudgetCategory.BudgetCategory__c = newAmendBudgetCategory.BudgetCategory__c;
            awardbudgetCategory.GrantorAmount__c = newAmendBudgetCategory.GrantorAmount__c;
            awardbudgetCategory.GranteeAmount__c = newAmendBudgetCategory.GranteeAmount__c;
            awardbudgetCategory.Amount__c = newAmendBudgetCategory.Amount__c;
            awardBudgetCategory.Federal__c = newAmendBudgetCategory.Federal__c;
            awardBudgetCategory.InKind__c = newAmendBudgetCategory.InKindMatch__c;
            awardBudgetCategory.CashMatch__c = newAmendBudgetCategory.CashMatch__c;
            awardBudgetCategory.PendingPayment__c = newAmendBudgetCategory.PendingPayment__c;
            awardBudgetCategory.YTDReimbursementPaid__c = newAmendBudgetCategory.YTDReimbursementPaid__c;
            awardBudgetCategory.CurrentApprovedBudgetAmount__c = newAmendBudgetCategory.CurrentApprovedBudgetAmount__c;
            awardBudgetCategory.CashMatchExpenditure__c = newAmendBudgetCategory.CashMatchExpenditure__c;
            awardBudgetCategory.InKindExpenditure__c = newAmendBudgetCategory.InKindExpenditure__c;
            awardbudgetCategory.BudgetPeriod__c = budgetPeriod;
            awardBudgetCategories.add(awardbudgetCategory);
        }
        insert awardBudgetCategories;

        system.debug('award Budget Categories --> ' + awardBudgetCategories.size());

        List<BuildUpItem__c> amendmentBuildUpItems = [select Title__c, Narrative__c, StartDate__c, EndDate__c,Name__c,
                             UnitPrice__c, Quantity__c, UnitofMeasurement__c, OtherCharges__c,
                             TotalDirect__c, AllowableDirect__c , Indirect__c, TotalIndirect__c,
                             GrandTotal__c, GrantorShare__c, GranteeShare__c,TotalHours__c,RequestedHours__c,
                             HourlyRate__c,MatchType__c,ListBenefitType__c,FBTotalSalary__c,Benefit__c,TravelDestination__c,
                             TravelPurpose__c,TravelTotalMiles__c,TravelMileRate__c,EquipmentDesc__c,EquipmentVAWAUse__c,
                             EquipmentQuantity__c,EquipmentUnitPrice__c,CSCType__c,CFTotalHours__c,CFRate__c,RegistrationPerPerson__c,
                             PerDiem__c,HotelFees__c,NumberofDays__c,NumberAttending__c,
                             AmendmentRequestBudgetCategory__c
                             from BuildUpItem__c
                             where AmendmentRequestBudgetCategory__c IN :amemndmentBudgetCategoryIds];

        Map<Id, List<BuildUpItem__c>> amendmentBuildUpItemsMap = new Map<Id, List<BuildUpItem__c>>();

        for (BuildUpItem__c amendmentBuildUpItem : amendmentBuildUpItems) {
            if (!amendmentBuildUpItemsMap.containsKey(amendmentBuildUpItem.AmendmentRequestBudgetCategory__c)) {
                amendmentBuildUpItemsMap.put(amendmentBuildUpItem.AmendmentRequestBudgetCategory__c,
                                             new List<BuildUpItem__c>());
            }
            amendmentBuildUpItemsMap.get(amendmentBuildUpItem.AmendmentRequestBudgetCategory__c).add(amendmentBuildUpItem);
        }
        // check to see if the null values exist in the map
        system.debug('Amendment request map --> ' + amendmentBuildUpItemsMap);

        if (amendmentBuildUpItems.size() > 0) {
            List<BuildUpItem__c> awardBuildUpItems = new List<BuildUpItem__c>();

            system.debug('*** here ---> ');
//&&
                            //amendmentBudgetcategory.ServiceArea1__c.equals(
                            //    awardBudgetCategory.ServiceArea__c)
            for (AmendmentRequestBudgetCategory__c amendmentBudgetcategory : amendmentBudgetcategories) {
                for (AwardBudgetCategory__c awardBudgetCategory : awardBudgetCategories) {
                    if (amendmentBudgetcategory.BudgetCategory__c.equals(
                                awardBudgetCategory.BudgetCategory__c) ) {
                        List<BuildUpItem__c> awdbuildupitems = new List<BuildUpItem__c>();
                        system.debug('value exists--> ' + amendmentBuildUpItemsMap.containsKey(amendmentBudgetcategory.Id));
                        system.debug('value --> ' + amendmentBuildUpItemsMap.get(amendmentBudgetcategory.Id));
                        if (amendmentBuildUpItemsMap.containsKey(amendmentBudgetcategory.Id)) {
                            awdbuildupitems = amendmentBuildUpItemsMap.get(amendmentBudgetcategory.Id);
                        }
                        system.debug('Award Build Up Items Size' + awdbuildupitems.size());
                        system.debug('Award Build Up Items --> ' + awdbuildupitems.size());
                        for (BuildUpItem__c amendmentBuildUpItem : awdbuildupitems) {
                            BuildUpItem__c awardBuildUpItem = new BuildUpItem__c();
                            //awardBuildUpItem.Title__c = amendmentBuildUpItem.Title__c;
                            //awardBuildUpItem.Narrative__c = amendmentBuildUpItem.Narrative__c;
                            //awardBuildUpItem.StartDate__c = amendmentBuildUpItem.StartDate__c;
                            //awardBuildUpItem.EndDate__c = amendmentBuildUpItem.EndDate__c;
                            //awardBuildUpItem.UnitPrice__c = amendmentBuildUpItem.UnitPrice__c;
                            //awardBuildUpItem.Quantity__c = amendmentBuildUpItem.Quantity__c;
                            //awardBuildUpItem.UnitofMeasurement__c = amendmentBuildUpItem.UnitofMeasurement__c;
                            //awardBuildUpItem.OtherCharges__c = amendmentBuildUpItem.OtherCharges__c;
                            //awardBuildUpItem.AllowableDirect__c = amendmentBuildUpItem.AllowableDirect__c;
                            //awardBuildUpItem.Indirect__c = amendmentBuildUpItem.Indirect__c;
                            //awardBuildUpItem.GrantorShare__c = amendmentBuildUpItem.GrantorShare__c;
                            //awardBuildUpItem.AwardBudgetCategory__c = awardBudgetCategory.Id;

                            //awardBuildUpItems.add(awardBuildUpItem);
                            if(amendmentBudgetcategory.BudgetCategory__r.Name == 'Personnel'){
                                        awardBuildUpItem.Name__c = amendmentBuildUpItem.Name__c;
                                        awardBuildUpItem.TotalHours__c = amendmentBuildUpItem.TotalHours__c;
                                        awardBuildUpItem.Title__c = amendmentBuildUpItem.Title__c;
                                        awardBuildUpItem.RequestedHours__c = amendmentBuildUpItem.RequestedHours__c;
                                        awardBuildUpItem.HourlyRate__c = amendmentBuildUpItem.HourlyRate__c;
                                        awardBuildUpItem.MatchType__c = amendmentBuildUpItem.MatchType__c;
                                    }
                                    if(amendmentBudgetcategory.BudgetCategory__r.Name == 'Fringe Benefits'){
                                        awardBuildUpItem.Name__c = amendmentBuildUpItem.Name__c;
                                        awardBuildUpItem.ListBenefitType__c = amendmentBuildUpItem.ListBenefitType__c;
                                        awardBuildUpItem.FBTotalSalary__c = amendmentBuildUpItem.FBTotalSalary__c;
                                        awardBuildUpItem.Benefit__c = amendmentBuildUpItem.Benefit__c;
                                        awardBuildUpItem.MatchType__c = amendmentBuildUpItem.MatchType__c;
                                    }
                                    if(amendmentBudgetcategory.BudgetCategory__r.Name == 'Travel'){
                                        awardBuildUpItem.TravelDestination__c = amendmentBuildUpItem.TravelDestination__c;
                                        awardBuildUpItem.TravelPurpose__c = amendmentBuildUpItem.TravelPurpose__c;
                                        awardBuildUpItem.TravelTotalMiles__c = amendmentBuildUpItem.TravelTotalMiles__c;
                                        awardBuildUpItem.TravelMileRate__c = amendmentBuildUpItem.TravelMileRate__c;
                                        awardBuildUpItem.MatchType__c = amendmentBuildUpItem.MatchType__c;
                                    }
                                    if(amendmentBudgetcategory.BudgetCategory__r.Name == 'Equipment'){
                                        awardBuildUpItem.EquipmentDesc__c = amendmentBuildUpItem.EquipmentDesc__c;
                                        awardBuildUpItem.EquipmentVAWAUse__c = amendmentBuildUpItem.EquipmentVAWAUse__c;
                                        awardBuildUpItem.EquipmentQuantity__c = amendmentBuildUpItem.EquipmentQuantity__c;
                                        awardBuildUpItem.EquipmentUnitPrice__c = amendmentBuildUpItem.EquipmentUnitPrice__c;
                                        awardBuildUpItem.MatchType__c = amendmentBuildUpItem.MatchType__c;
                                    }
                                    if(amendmentBudgetcategory.BudgetCategory__r.Name == 'Supplies'){
                                        awardBuildUpItem.EquipmentDesc__c = amendmentBuildUpItem.EquipmentDesc__c;
                                        awardBuildUpItem.EquipmentQuantity__c = amendmentBuildUpItem.EquipmentQuantity__c;
                                        awardBuildUpItem.EquipmentUnitPrice__c = amendmentBuildUpItem.EquipmentUnitPrice__c;
                                        awardBuildUpItem.MatchType__c = amendmentBuildUpItem.MatchType__c;
                                    }
                                    if(amendmentBudgetcategory.BudgetCategory__r.Name == 'Contracted Fees'){
                                        awardBuildUpItem.CSCType__c = amendmentBuildUpItem.CSCType__c;
                                        awardBuildUpItem.CFTotalHours__c =amendmentBuildUpItem.CFTotalHours__c;
                                        awardBuildUpItem.CFRate__c = amendmentBuildUpItem.CFRate__c;
                                        awardBuildUpItem.MatchType__c = amendmentBuildUpItem.MatchType__c;
                                    }
                                    if(amendmentBudgetcategory.BudgetCategory__r.Name == 'Training'){
                                        awardBuildUpItem.Name__c = amendmentBuildUpItem.Name__c;
                                        awardBuildUpItem.RegistrationPerPerson__c = amendmentBuildUpItem.RegistrationPerPerson__c;
                                        awardBuildUpItem.PerDiem__c = amendmentBuildUpItem.PerDiem__c;
                                        awardBuildUpItem.HotelFees__c = amendmentBuildUpItem.HotelFees__c;
                                        awardBuildUpItem.NumberofDays__c = amendmentBuildUpItem.NumberofDays__c;
                                        awardBuildUpItem.NumberAttending__c = amendmentBuildUpItem.NumberAttending__c;
                                        awardBuildUpItem.MatchType__c = amendmentBuildUpItem.MatchType__c;
                                    }
                                    if(amendmentBudgetcategory.BudgetCategory__r.Name == 'Other'){
                                        awardBuildUpItem.EquipmentDesc__c = amendmentBuildUpItem.EquipmentDesc__c;
                                        awardBuildUpItem.EquipmentQuantity__c = amendmentBuildUpItem.EquipmentQuantity__c;
                                        awardBuildUpItem.EquipmentUnitPrice__c = amendmentBuildUpItem.EquipmentUnitPrice__c;
                                        awardBuildUpItem.MatchType__c = amendmentBuildUpItem.MatchType__c;
                                    }
                                awardBuildUpItem.AwardBudgetCategory__c = awardBudgetCategory.Id;

                                awardBuildUpItems.add(awardBuildUpItem);
                        }
                    }
                }
            }
            insert awardBuildUpItems;
        }
    }
    
    public void copyPreviousAwdBudCatsToNewAwdBudCats(Id oldAwardId, Id newAwardId, Id budgetPeriod) {
        List<AwardBudgetCategory__c> categorylist = new List<AwardBudgetCategory__c>();
        List<AwardBudgetCategory__c> oldAwardBudgetCategories = [select ServiceArea__c, BudgetCategory__c, GrantorAmount__c,Federal__c,InKind__c,CashMatch__c,
                                                GranteeAmount__c, Amount__c,PendingPayment__c,YTDReimbursementPaid__c,CurrentApprovedBudgetAmount__c,CashMatchExpenditure__c,InKindExpenditure__c
                                                from AwardBudgetCategory__c
                                                where Award__c = :oldAwardId];
        for (AwardBudgetCategory__c awardcat : oldAwardBudgetCategories) {
            awardcat.BudgetPeriod__c = budgetPeriod;
            AwardBudgetCategory__c newawdbc = awardcat.clone(false,true);
            newawdbc.Award__c = newAwardId;
            categorylist.add(newawdbc);
        }
        insert categorylist;
        List<BuildUpItem__c> newAwardBuildUpItemtoInsert = new List<BuildUpItem__c>();
        List<BuildUpItem__c> oldAwardBuildUpItems = [select Name__c,AwardBudgetCategory__c,Title__c, Narrative__c, StartDate__c, EndDate__c,
                     UnitPrice__c, Quantity__c, UnitofMeasurement__c, OtherCharges__c,
                     TotalDirect__c, AllowableDirect__c , Indirect__c, TotalIndirect__c,
                     GrandTotal__c, GrantorShare__c, GranteeShare__c,TotalHours__c,RequestedHours__c,
                     HourlyRate__c,MatchType__c,ListBenefitType__c,FBTotalSalary__c,Benefit__c,TravelDestination__c,
                     TravelPurpose__c,TravelTotalMiles__c,TravelMileRate__c,EquipmentDesc__c,EquipmentVAWAUse__c,
                     EquipmentQuantity__c,EquipmentUnitPrice__c,CSCType__c,CFTotalHours__c,CFRate__c,RegistrationPerPerson__c,
                     PerDiem__c,HotelFees__c,NumberofDays__c,NumberAttending__c 
                     from BuildUpItem__c
                     where AwardBudgetCategory__c IN :oldAwardBudgetCategories];
        Map<Id, List<BuildUpItem__c>> oldAwardBuildUpItemsMap = new Map<Id, List<BuildUpItem__c>>();
        for (BuildUpItem__c oldAwardBuildUpItem : oldAwardBuildUpItems) {
            if (!oldAwardBuildUpItemsMap.containsKey(oldAwardBuildUpItem.AwardBudgetCategory__c)) {
                oldAwardBuildUpItemsMap.put(oldAwardBuildUpItem.AwardBudgetCategory__c,
                                     new List<BuildUpItem__c>());
            }
        oldAwardBuildUpItemsMap.get(oldAwardBuildUpItem.AwardBudgetCategory__c).add(oldAwardBuildUpItem);
        }

        for (AwardBudgetCategory__c awardBudgetCategory : oldAwardBudgetCategories){
            for (AwardBudgetCategory__c newAwardBudgetCategory : categorylist){
                if(awardBudgetCategory.BudgetCategory__c.equals(newAwardBudgetCategory.BudgetCategory__c)){
                    List<BuildUpItem__c> awdbuildupitems = new List<BuildUpItem__c>();
                    if (oldAwardBuildUpItemsMap.containsKey(awardBudgetCategory.Id)) {
                        awdbuildupitems = oldAwardBuildUpItemsMap.get(awardBudgetCategory.Id);
                    }
                    for(BuildUpItem__c buildUpItem : awdbuildupitems){
                        BuildUpItem__c newAwardBuildUpItem = buildUpItem.clone(false);
                        newAwardBuildUpItem.AwardBudgetCategory__c = newAwardBudgetCategory.Id;
                        newAwardBuildUpItemtoInsert.add(newAwardBuildUpItem);
                    }
                }
            }
        }
        insert newAwardBuildUpItemtoInsert;
    }
}