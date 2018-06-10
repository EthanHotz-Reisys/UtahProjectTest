/*
    This class has methods to execute methods related to account trigger
    **********************************************************
    Audit History
    **********************************************************
    2014-08-08  Ryan Chadwick           create
    2015-08-08  William Moore           update
    2015-09-16  Shrawan Raina           update
    2016-05-06  Sarat Mahavratayajula   Added copyRolesAndResponsibilities,verifyFormalAmendment
    2016-06-23  Sarat Mahavratayajula   Added getNextBudgetPeriodForPeriodicRenewal
    2016-06-28  Sarat Mahavratayajula   Added createAmendmentBudgetCategories2,verifyPeriodicRenewal
    2017-03-05  Sarat Mahavratayajula   Added createAmendmentBudgetCategories3
    2017-03-05  Sarat Mahavratayajula   Added copyBudgetPeriod
    2017-11-05  Sarat Mahavratayajula   Modified copyRolesAndResponsibilities
    **********************************************************
*/


global with sharing class AmendmentRequestTriggerHelper extends GNT.TriggerHelper {

    String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
    global static boolean skipTrigger = false;
    
    //private List<RecordType> amendmentRecordTypes;

    public void AmendmentRequestTriggerHelper() {
        /* amendmentRecordTypes = [select Id, Name, DeveloperName
                                     FROM RecordType
                                     where SobjectType=:AppUtils.getNamespacePrefix()+'AmendmentRequest__c'];*/
    }

    public override void processBeforeInsert() {
        if (skipTrigger == false) {
            verifyFormalAmendment(((List<AmendmentRequest__c>)Trigger.New));
            copyfieldsToAmendment((List<AmendmentRequest__c>)Trigger.New);
            //copyBudgetPeriod method should take care of getNextBudgetPeriodForPeriodicRenewal
            //getNextBudgetPeriodForPeriodicRenewal can be deleted - Check before deleting
            //getNextBudgetPeriodForPeriodicRenewal((List<AmendmentRequest__c>)Trigger.New);
            verifyPeriodicRenewal((List<AmendmentRequest__c>)Trigger.New);
            copyBudgetPeriod((List<AmendmentRequest__c>)Trigger.New);
        }
    }

    public override void processAfterInsert() {
        if (skipTrigger == false) {
            //createAmendmentBudgetCategories((List<AmendmentRequest__c>)Trigger.New);
            copyRolesAndResponsibilities((List<AmendmentRequest__c>)Trigger.New);
            //createAmendmentBudgetCategories2((List<AmendmentRequest__c>)Trigger.New);
            createAmendmentBudgetCategories3((List<AmendmentRequest__c>)Trigger.New);
        }
    }

    public override void processBeforeUpdate() {

    }

    public override void processAfterUpdate() {
        System.debug('MANUALDEBUG >>> skipTrigger = ' + AmendmentRequestTriggerHelper.skipTrigger);
        System.debug('MANUALDEBUG >>> skipTrigger = ' + skipTrigger);
        if (skipTrigger == false) {
            completeBudgetRevisionPostApproval((List<AmendmentRequest__c>)Trigger.New);
        }
    }

    /**
    * @Deprecated - Verify and delete
    */
    //@TestVisible private void createAmendmentBudgetCategories(List<AmendmentRequest__c> amdreq) {
    //    List<AmendmentRequestBudgetCategory__c> budgetlist = new List<AmendmentRequestBudgetCategory__c>();
    //    List<RecordType> recordTypeList = [select Id, Name, SobjectType FROM RecordType where SobjectType = :AppUtils.getNamespacePrefix() + 'AmendmentRequest__c' and Name = 'Formal Amendments'];
    //    List<Id> listIds = new List<Id>();
    //    for (AmendmentRequest__c amendmentrequest : amdreq) {
    //        listIds.add(amendmentrequest.Award__c);
    //    }
    //    List<AwardBudgetCategory__c> awardbudgets = [SELECT Id, Name, Award__c, BudgetCategory__c, Amount1__c FROM AwardBudgetCategory__c where Award__c IN :listIds];
    //    AmendmentRequestBudgetCategory__c abc;
    //    for (AmendmentRequest__c amd : amdreq) {
    //        for (AwardBudgetCategory__c awdbudget : awardbudgets) {
    //            if (amd.Recordtypeid == recordTypeList[0].id) {
    //                abc = new AmendmentRequestBudgetCategory__c();
    //                abc.AmendmentRequest__c = amd.Id;
    //                abc.Name = awdbudget.Name;
    //                abc.CurrentAmount__c = awdbudget.Amount1__c;
    //                abc.BudgetCategory__c = awdbudget.BudgetCategory__c;
    //                budgetlist.add(abc);
    //            }
    //        }
    //    }
    //    if (!budgetlist.isEmpty()) insert budgetlist;
    //}

    private void copyfieldsToAmendment(List<AmendmentRequest__c> amendmentRequests){
        Set<Id> awardIds = new Set<Id>();
        for(AmendmentRequest__c amendmentRequest : amendmentRequests) {
            awardIds.add(amendmentRequest.Award__c);
        }

        List<Award__c> awards = [select Id,name,Grant__r.Application__c,Application__r.IndirectCostPercentage__c,Grant__c  from Award__c  where Id IN :awardIds];
        for(AmendmentRequest__c amendmentRequest : amendmentRequests){
            for(Award__c award : awards){
                if(amendmentRequest.Award__c == award.Id){
                    amendmentRequest.IndirectCostPercentage__c = award.Application__r.IndirectCostPercentage__c;
                }
            }
            
        }
    }

    private void copyBudgetPeriod(List<AmendmentRequest__c> amendmentRequests) {
        system.debug('IN copy Budget Period');

        Set<Id> awardIds = new Set<Id>();
        Map<Id,Id> awardApplicationIdMap = new Map<Id,Id>();

        for(AmendmentRequest__c amendmentRequest : amendmentRequests) {
            awardIds.add(amendmentRequest.Award__c);
        }

        List<Award__c> awards = [select Id,name,Grant__r.Application__c,Grant__c 
                                from Award__c 
                                where Id IN :awardIds];

        for(Award__c award : awards) {
            awardApplicationIdMap.put(award.Id,award.Grant__r.Application__c);
        }

        Map<Id, String> recordTypeMap = new Map<Id, String>();

        List<RecordType> amendmentRecordTypes = [select Id, Name, DeveloperName
                                                FROM RecordType
                                                where SobjectType = :AppUtils.getNamespacePrefix() + 'AmendmentRequest__c'];

        for (RecordType recordType : amendmentRecordTypes) {
            recordTypeMap.put(recordType.Id, recordType.DeveloperName);
        }

        List<Id> formalAmendmentAwardIds = new List<Id>();
        List<Id> periodicAmendmentAwardIds = new List<Id>();
        Set<Id> periodicAmendWhenNoAppAwardIds = new Set<Id>();
        for (AmendmentRequest__c amendmentRequest : amendmentRequests) {
            String recTypeDeveloperName = recordTypeMap.get(amendmentRequest.RecordTypeId);
            if (recTypeDeveloperName.equals('FormalAmendments')) {
                formalAmendmentAwardIds.add(amendmentRequest.Award__c);
            }
            if (recTypeDeveloperName.equals('PeriodicAnnualRenewal')) {
                //Id applicationId = awardApplicationIdMap.get(amendmentRequest.Award__c);
                //if (applicationId == null) {
                    periodicAmendWhenNoAppAwardIds.add(amendmentRequest.Award__c);
                //} else {
                    //periodicAmendmentAwardIds.add(amendmentRequest.Award__c);
                //}
            }

        }
        if (formalAmendmentAwardIds.size() > 0) {
            List<Award__c> amendmentAwards = [select Id, Name, Budgetperiod__c
                                              from Award__c
                                              where Id IN :formalAmendmentAwardIds];

            Map<Id, Id> awardBudgetPeriodMap = new Map<Id, Id>();
            for (Award__c award : amendmentAwards) {
                if (!awardBudgetPeriodMap.containsKey(award.Id)) {
                    awardBudgetPeriodMap.put(award.Id, award.Budgetperiod__c);
                }
            }
            for (AmendmentRequest__c amendmentRequest : amendmentRequests) {
                if (awardBudgetPeriodMap.containsKey(amendmentRequest.Award__c)) {
                    amendmentRequest.AmendmentBudgetPeriod__c = awardBudgetPeriodMap.get(amendmentRequest.Award__c);
                    system.debug('Amendment Budget Period ' + amendmentRequest.AmendmentBudgetPeriod__c);
                }
            }
        }
        system.debug('test awards list size --> ' + periodicAmendWhenNoAppAwardIds.size());
        if (periodicAmendWhenNoAppAwardIds.size() > 0) {
            copyPeriodicAmendmentBPWhenNoApplication(periodicAmendWhenNoAppAwardIds, amendmentRequests);
        }
        if (periodicAmendmentAwardIds.size() > 0) {
            system.debug('In periodic amd --> ');
            Map<Id, Award__c> amendmentAwardsMap = new Map<Id, Award__c>([select Id, Name, ActiveBudgetYear__c,
                    Grant__r.Application__c
                    from Award__c
                    where Id IN :periodicAmendmentAwardIds]);
            Map<Id, Id> awardApplicationMap = new Map<Id,Id>();
            for (Id awardId : amendmentAwardsMap.keySet()) {
                Award__c award = amendmentAwardsMap.get(awardId);
                if (!awardApplicationMap.containsKey(awardId)) {
                    awardApplicationMap.put(awardId, award.Grant__r.Application__c);
                }
            }

            List<Budgetperiod__c> applicationBudgetPeriodsList = [select Id, Application__c,
                                  SequenceNumber__c
                                  from Budgetperiod__c
                                  where Application__c IN :awardApplicationMap.values()];
            Map<Id, List<Integer>> applicationBPSeqNumbersMap = new Map<Id, List<Integer>>();
            Map<Id, List<Budgetperiod__c>> applicationBPsMap = new Map<Id, List<Budgetperiod__c>>();

            for (Budgetperiod__c budgetPeriod : applicationBudgetPeriodsList) {
                if (!applicationBPSeqNumbersMap.containsKey(budgetPeriod.Application__c)) {
                    applicationBPSeqNumbersMap.put(budgetPeriod.Application__c, new List<Integer>());
                    applicationBPsMap.put(budgetPeriod.Application__c, new List<Budgetperiod__c>());
                }
                applicationBPsMap.get(budgetPeriod.Application__c).add(budgetPeriod);
                applicationBPSeqNumbersMap.get(budgetPeriod.Application__c).add(budgetPeriod.SequenceNumber__c.intValue());
            }

            Map<Id, Integer> applicationNextBPMap = new Map<Id, Integer>();
            Map<Id, Id> awardNextBudgetPeriodMap = new Map<Id, Id>();

            for (Id awardKey : amendmentAwardsMap.keySet()) {
                Id applicationId = awardApplicationMap.get(awardKey);
                List<Integer> applicationBPSeqNumbersList = applicationBPSeqNumbersMap.get(applicationId);
                Award__c award = amendmentAwardsMap.get(awardKey);
                Integer awardSequenceNumber = award.ActiveBudgetYear__c.intValue();
                Integer nextBPSequeceNumber = doBinarySearch(applicationBPSeqNumbersList, 0,
                                              applicationBPSeqNumbersList.size() - 1, awardSequenceNumber);
                applicationNextBPMap.put(applicationId, nextBPSequeceNumber);
            }

            for (Id awardKey : amendmentAwardsMap.keySet()) {
                Id applicationId = awardApplicationMap.get(awardKey);
                Integer nextBPSequeceNumber = applicationNextBPMap.get(applicationId);
                List<Budgetperiod__c> budgetPeriods = applicationBPsMap.get(applicationId);
                for (Budgetperiod__c budgetPeriod : budgetPeriods) {
                    if (budgetPeriod.SequenceNumber__c.intValue() == nextBPSequeceNumber) {
                        awardNextBudgetPeriodMap.put(awardKey, budgetPeriod.Id);
                    }
                }
            }

            for (AmendmentRequest__c amendmentRequest : amendmentRequests) {
                if (amendmentAwardsMap.containsKey(amendmentRequest.Award__c)) {
                    amendmentRequest.AmendmentBudgetPeriod__c = awardNextBudgetPeriodMap.get(amendmentRequest.Award__c);
                    system.debug('Amendment Budget Period ' + amendmentRequest.AmendmentBudgetPeriod__c);
                }
            }
        }
    }

    private void copyPeriodicAmendmentBPWhenNoApplication(Set<Id> periodicAmendWhenNoAppAwardIds,
            List<AmendmentRequest__c> amendmentRequests) {

        system.debug('*** sarat testing no Appliation'  );

        Map<Id, Award__c> awardMap = new Map<Id, Award__c>([select Id, Name, ActiveBudgetYear__c,
                Grant__r.Application__c, Grant__c
                from Award__c
                where Id IN :periodicAmendWhenNoAppAwardIds]);
        Map<Id, Id> awardGrantMap = new Map<Id, Id>();
        for (Id awardKey : awardMap.keySet()) {
            Award__c award = awardMap.get(awardKey);
            awardGrantMap.put(awardKey, award.Grant__c);
        }

        system.debug('values -->' + awardGrantMap.values());

        List<BudgetPeriod__c> grantBudgetPeriods = [select Id, SequenceNumber__c, Grant__c
                from Budgetperiod__c
                where Grant__c IN :awardGrantMap.values()];

        Map<Id, Integer> grantBudgetPeriodSequenceNumberMap = new Map<Id, Integer>();
        Map<Id, List<Integer>> budgetPeriodSequenceNumberMap = new Map<Id, List<Integer>>();
        Map<Id, List<BudgetPeriod__c>> grantBudgetPeriodMap = new Map<Id, List<BudgetPeriod__c>>();
        Map<Id, Id> amendmentBudgetPeriod = new Map<Id, Id>();

        for (BudgetPeriod__c budgetPeriod : grantBudgetPeriods) {
            if (!budgetPeriodSequenceNumberMap.containsKey(budgetPeriod.Grant__c)) {
                budgetPeriodSequenceNumberMap.put(budgetPeriod.Grant__c, new List<Integer>());
            }
            budgetPeriodSequenceNumberMap.get(budgetPeriod.Grant__c).add(budgetPeriod.SequenceNumber__c.intValue());
            if (!grantBudgetPeriodMap.containsKey(budgetPeriod.Grant__c)) {
                grantBudgetPeriodMap.put(budgetPeriod.Grant__c, new List<Budgetperiod__c>());
            }
            grantBudgetPeriodMap.get(budgetPeriod.Grant__c).add(budgetPeriod);
        }

        for (Id awardKey : awardGrantMap.keySet()) {
            Award__c award = awardMap.get(awardKey);
            Id grantId = awardGrantMap.get(awardKey);
            List<Integer> grantBPSequenceNumbersList = budgetPeriodSequenceNumberMap.get(grantId);
            Integer awardSequenceNumber = award.ActiveBudgetYear__c.intValue();
            Integer nextBPSequeceNumber = doBinarySearch(grantBPSequenceNumbersList, 0,
                                          grantBPSequenceNumbersList.size() - 1, awardSequenceNumber);
            grantBudgetPeriodSequenceNumberMap.put(grantId, nextBPSequeceNumber);
        }

        for (Id awardkey : awardMap.keySet()) {
            Id grantId = awardGrantMap.get(awardKey);
            Integer nextBPSequeceNumber = grantBudgetPeriodSequenceNumberMap.get(grantId);
            List<Budgetperiod__c> budgetPeriods = grantBudgetPeriodMap.get(grantId);
            for (Budgetperiod__c budgetPeriod : budgetPeriods) {
                if (budgetPeriod.SequenceNumber__c.intValue() == nextBPSequeceNumber) {
                    amendmentBudgetPeriod.put(awardKey, budgetPeriod.Id);
                }
            }
        }

        for (AmendmentRequest__c amendmentRequest : amendmentRequests) {
            if (awardMap.containsKey(amendmentRequest.Award__c)) {
                amendmentRequest.AmendmentBudgetPeriod__c = amendmentBudgetPeriod.get(amendmentRequest.Award__c);
                system.debug('Amendment Budget Period sarat testing --- ' + amendmentRequest.AmendmentBudgetPeriod__c);
            }
        }
    }

    private void createAmendmentBudgetCategories3(List<AmendmentRequest__c> amendmentRequests) {

        system.debug('My method testing *** ');

        Map<Id, AmendmentRequest__c> formalAmendmentAwardMap = new Map<Id, AmendmentRequest__c>();
        Map<Id, AmendmentRequest__c> periodicAmdAwdForAllBPsMap = new Map<Id, AmendmentRequest__c>();
        Map<Id, AmendmentRequest__c> periodicAmdAwdForOneBPMap = new Map<Id, AmendmentRequest__c>();
        Map<Id, AmendmentRequest__c> budgetRevisionAmendmentMap = new Map<Id, AmendmentRequest__c>();
        Map<Id, AmendmentRequest__c> amendmentWithoutApplication = new Map<Id, AmendmentRequest__c>();
        Map<Id, Id> periodicAmdAwdMap = new Map<Id, Id>();

        List<AmendmentRequest__c> amendmentRequestsList = [select Id, name, Award__r.Grant__r.Application__c, RecordTypeId,
                                  Award__r.Grant__r.Application__r.Announcement__r.BudgetingPeriod__c,
                                  Award__r.Budgetperiod__c, Award__c
                                  from AmendmentRequest__c
                                  where Id IN :amendmentRequests];

        Map<Id, String> recordTypeMap = new Map<Id, String>();

        List<RecordType> amendmentRecordTypes = [select Id, Name, DeveloperName
                                                FROM RecordType
                                                where SobjectType = :AppUtils.getNamespacePrefix() + 'AmendmentRequest__c'];

        for (RecordType recordType : amendmentRecordTypes) {
            recordTypeMap.put(recordType.Id, recordType.DeveloperName);
        }

        for (AmendmentRequest__c amendmentRequest : amendmentRequestsList) {
            system.debug('*** rec type id ' + amendmentRequest.RecordTypeId + 'Rec Type Name ' + recordTypeMap.get(amendmentRequest.RecordTypeId));
            String recTypeDeveloperName = recordTypeMap.get(amendmentRequest.RecordTypeId);

            if (recTypeDeveloperName.equals('FormalAmendments')) {
                formalAmendmentAwardMap.put(amendmentRequest.Award__c, amendmentRequest);
            }
            if (recTypeDeveloperName.equals('BudgetRevision')) {
                budgetRevisionAmendmentMap.put(amendmentRequest.Award__c, amendmentRequest);
            }
            if (recTypeDeveloperName.equals('PeriodicAnnualRenewal')) {
                system.debug('Award value --> ' + amendmentRequest.Award__c);
                system.debug('grant value --> ' + amendmentRequest.Award__r.Grant__c);
                system.debug('Application value --> ' + amendmentRequest.Award__r.Grant__r.Application__c);
                periodicAmdAwdMap.put(amendmentRequest.Id, amendmentRequest.Award__c);

                if (amendmentRequest.Award__r.Grant__r.Application__c != null) {
                    if (amendmentRequest.Award__r.Grant__r.Application__r.Announcement__r.BudgetingPeriod__c != null &&
                            amendmentRequest.Award__r.Grant__r.Application__r.Announcement__r.BudgetingPeriod__c.equals('AllBudgetPeriods')) {
                        periodicAmdAwdForAllBPsMap.put(amendmentRequest.Award__c, amendmentRequest);
                    }
                    if (amendmentRequest.Award__r.Grant__r.Application__r.Announcement__r.BudgetingPeriod__c != null &&
                            amendmentRequest.Award__r.Grant__r.Application__r.Announcement__r.BudgetingPeriod__c.equals('OnlyFirstBudgetPeriod')) {
                        periodicAmdAwdForOneBPMap.put(amendmentRequest.Award__c, amendmentRequest);
                    }
                } else {
                    amendmentWithoutApplication.put(amendmentRequest.Award__c, amendmentRequest);
                }
            }
        }
        system.debug('Periodic Map 1 ' + periodicAmdAwdForAllBPsMap.size());
        system.debug('Periodic Map 2 ' + periodicAmdAwdForOneBPMap.size());
        if (formalAmendmentAwardMap.size() > 0) {
            copyFormalAmendmentBudgetCategories(formalAmendmentAwardMap);
        }
        if (budgetRevisionAmendmentMap.size() > 0) {
            copyFormalAmendmentBudgetCategories(budgetRevisionAmendmentMap);
        }
        if (periodicAmdAwdForOneBPMap.size() > 0) {
            copyPeriodicAmendmentOneBPBudgetCategories(periodicAmdAwdForOneBPMap);
        }
        if (periodicAmdAwdForAllBPsMap.size() > 0) {
            copyPeriodicAmendmentMultipleBPBudgetCategories(periodicAmdAwdForAllBPsMap, periodicAmdAwdMap);
        }
        if (amendmentWithoutApplication.size() > 0) {
            copyBudgetCategoryFromAward(amendmentWithoutApplication);
        }
    }


    private void copyBudgetCategoryFromAward(Map<Id, AmendmentRequest__c> amendmentWithoutApplication) {
        List<AwardBudgetCategory__c> abcs = [Select Id, Name, Award__c, BudgetCategory__c,
                                             GrantorAmount__c, GranteeAmount__c, ServiceArea__c, Amount__c
                                             FROM AwardBudgetCategory__c where Award__c IN :amendmentWithoutApplication.keySet()];
        List<AmendmentRequestBudgetCategory__c> arbcs = new List<AmendmentRequestBudgetCategory__c>();
        for (AwardBudgetCategory__c abc : abcs) {
            AmendmentRequest__c amendment = amendmentWithoutApplication.get(abc.Award__c);
            AmendmentRequestBudgetCategory__c temp = new AmendmentRequestBudgetCategory__c(
                Name = abc.Name,
                AmendmentRequest__c = amendment.Id,
                BudgetCategory__c = abc.BudgetCategory__c,
                ServiceArea1__c = abc.ServiceArea__c,
                CurrentAmount__c = 0,
                Adjustment__c = 0,
                GrantorAmount__c = 0,
                GranteeAmount__c = 0,
                Amount__c = 0
            );
            arbcs.add(temp);
        }
        insert arbcs;
    }


    private void copyFormalAmendmentBudgetCategories(Map<Id, AmendmentRequest__c> formalAmendmentAwardMap) {
        List<AmendmentRequestBudgetCategory__c> amendmentRequestBudgetCategories = new List<AmendmentRequestBudgetCategory__c>();
        Set<Id> awardBudgetCategoryIds = new Set<Id>();
        Set<Id> awardIds = formalAmendmentAwardMap.keySet();

        Map<Id, List<AwardBudgetCategory__c>> awardAndAwdBudgetCategoriesMap = new Map<Id, List<AwardBudgetCategory__c>>();

        List<AwardBudgetCategory__c> awardBudgetCategoriesList = [select Id, Name,Federal__c, Award__c,InKind__c,CashMatch__c, BudgetCategory__c,PendingPayment__c,
                                     GrantorAmount__c, ServiceArea__c,YTDReimbursementPaid__c,CurrentApprovedBudgetAmount__c,CashMatchExpenditure__c,InKindExpenditure__c
                                     FROM AwardBudgetCategory__c
                                     where Award__c = :awardIds];

        for (AwardBudgetCategory__c awdBudCat : awardBudgetCategoriesList) {
            awardBudgetCategoryIds.add(awdBudCat.Id);
            if (!awardAndAwdBudgetCategoriesMap.containsKey(awdBudCat.Award__c)) {
                awardAndAwdBudgetCategoriesMap.put(awdBudCat.Award__c, new List<AwardBudgetCategory__c>());
            }
            awardAndAwdBudgetCategoriesMap.get(awdBudCat.Award__c).add(awdBudCat);
        }

        for (Id awardKey : formalAmendmentAwardMap.keySet()) {
            AmendmentRequest__c amendmentRequest = formalAmendmentAwardMap.get(awardKey);
            List<AwardBudgetCategory__c> awardBudgetCategories = awardAndAwdBudgetCategoriesMap.get(awardKey);
            for (AwardBudgetCategory__c awardBudgetCategory : awardBudgetCategories) {
                AmendmentRequestBudgetCategory__c amendmentRequestBudgetCategory =
                    new AmendmentRequestBudgetCategory__c();
                amendmentRequestBudgetCategory.Name = awardBudgetCategory.Name;
                amendmentRequestBudgetCategory.AmendmentRequest__c = amendmentRequest.Id;
                amendmentRequestBudgetCategory.BudgetCategory__c = awardBudgetCategory.BudgetCategory__c;
                amendmentRequestBudgetCategory.CurrentAmount__c = awardBudgetCategory.Federal__c;
                amendmentRequestBudgetCategory.Federal__c = awardBudgetCategory.Federal__c;
                amendmentRequestBudgetCategory.GrantorAmount__c = awardBudgetCategory.GrantorAmount__c;
                amendmentRequestBudgetCategory.ServiceArea1__c = awardBudgetCategory.ServiceArea__c;
                amendmentRequestBudgetCategory.PendingPayment__c = awardBudgetCategory.PendingPayment__c;
                amendmentRequestBudgetCategory.InKindMatch__c = awardBudgetCategory.InKind__c;
                amendmentRequestBudgetCategory.NewInKindMatch__c = awardBudgetCategory.InKind__c;
                amendmentRequestBudgetCategory.CashMatch__c = awardBudgetCategory.CashMatch__c;
                amendmentRequestBudgetCategory.NewCashMatch__c = awardBudgetCategory.CashMatch__c;
                amendmentRequestBudgetCategory.YTDReimbursementPaid__c = awardBudgetCategory.YTDReimbursementPaid__c;
                amendmentRequestBudgetCategory.CurrentApprovedBudgetAmount__c = awardBudgetCategory.CurrentApprovedBudgetAmount__c;
                amendmentRequestBudgetCategory.CashMatchExpenditure__c = awardBudgetCategory.CashMatchExpenditure__c;
                amendmentRequestBudgetCategory.InKindExpenditure__c = awardBudgetCategory.InKindExpenditure__c;

                amendmentRequestBudgetCategories.add(amendmentRequestBudgetCategory);
            }
        }
        insert amendmentRequestBudgetCategories;
        

        List<BuildUpItem__c> amendmentBuildUpItems = new List<BuildUpItem__c>();

        List<BuildUpItem__c> awardBuildUpItemsList = [select Title__c, Narrative__c, StartDate__c, EndDate__c,
                             UnitPrice__c, Quantity__c, UnitofMeasurement__c, OtherCharges__c,
                             TotalDirect__c, AllowableDirect__c , Indirect__c, TotalIndirect__c,
                             GrandTotal__c, GrantorShare__c, GranteeShare__c,Name__c,TotalHours__c,RequestedHours__c,
                             HourlyRate__c,MatchType__c,ListBenefitType__c,FBTotalSalary__c,Benefit__c,TravelDestination__c,
                             TravelPurpose__c,TravelTotalMiles__c,TravelMileRate__c,EquipmentDesc__c,EquipmentVAWAUse__c,
                             EquipmentQuantity__c,EquipmentUnitPrice__c,CSCType__c,CFTotalHours__c,CFRate__c,RegistrationPerPerson__c,
                             PerDiem__c,HotelFees__c,NumberofDays__c,NumberAttending__c,AwardBudgetCategory__c 
                             from BuildUpItem__c
                             where AwardBudgetCategory__c IN :awardBudgetCategoryIds];

        for (AwardBudgetCategory__c awardBudgetCategory : awardBudgetCategoriesList){
            for (AmendmentRequestBudgetCategory__c newAmendmentBudgetCategory : amendmentRequestBudgetCategories){
                if(awardBudgetCategory.BudgetCategory__c.equals(newAmendmentBudgetCategory.BudgetCategory__c)){
                    for(BuildUpItem__c buildUpItem : awardBuildUpItemsList){
                        if(buildUpItem.AwardBudgetCategory__c == awardBudgetCategory.id){
                            BuildUpItem__c amendmentBuildUpItem = new BuildUpItem__c();
                                amendmentBuildUpItem.Name__c = buildUpItem.Name__c;
                                amendmentBuildUpItem.TotalHours__c = buildUpItem.TotalHours__c;
                                amendmentBuildUpItem.Title__c = buildUpItem.Title__c;
                                amendmentBuildUpItem.RequestedHours__c = buildUpItem.RequestedHours__c;
                                amendmentBuildUpItem.HourlyRate__c = buildUpItem.HourlyRate__c;
                                amendmentBuildUpItem.ListBenefitType__c = buildUpItem.ListBenefitType__c;
                                amendmentBuildUpItem.FBTotalSalary__c = buildUpItem.FBTotalSalary__c;
                                amendmentBuildUpItem.Benefit__c = buildUpItem.Benefit__c;
                                amendmentBuildUpItem.MatchType__c = buildUpItem.MatchType__c;
                                amendmentBuildUpItem.TravelDestination__c = buildUpItem.TravelDestination__c;
                                amendmentBuildUpItem.TravelPurpose__c = buildUpItem.TravelPurpose__c;
                                amendmentBuildUpItem.TravelTotalMiles__c = buildUpItem.TravelTotalMiles__c;
                                amendmentBuildUpItem.TravelMileRate__c = buildUpItem.TravelMileRate__c;
                                amendmentBuildUpItem.EquipmentDesc__c = buildUpItem.EquipmentDesc__c;
                                amendmentBuildUpItem.EquipmentVAWAUse__c = buildUpItem.EquipmentVAWAUse__c;
                                amendmentBuildUpItem.EquipmentQuantity__c = buildUpItem.EquipmentQuantity__c;
                                amendmentBuildUpItem.EquipmentUnitPrice__c = buildUpItem.EquipmentUnitPrice__c;
                                amendmentBuildUpItem.CSCType__c = buildUpItem.CSCType__c;
                                amendmentBuildUpItem.CFTotalHours__c =buildUpItem.CFTotalHours__c;
                                amendmentBuildUpItem.CFRate__c = buildUpItem.CFRate__c;
                                amendmentBuildUpItem.RegistrationPerPerson__c = buildUpItem.RegistrationPerPerson__c;
                                amendmentBuildUpItem.PerDiem__c = buildUpItem.PerDiem__c;
                                amendmentBuildUpItem.HotelFees__c = buildUpItem.HotelFees__c;
                                amendmentBuildUpItem.NumberofDays__c = buildUpItem.NumberofDays__c;
                                amendmentBuildUpItem.NumberAttending__c = buildUpItem.NumberAttending__c;
                                amendmentBuildUpItem.EquipmentDesc__c = buildUpItem.EquipmentDesc__c;

                            amendmentBuildUpItem.AmendmentRequestBudgetCategory__c = newAmendmentBudgetCategory.Id;
                            amendmentBuildUpItems.add(amendmentBuildUpItem);
                        }
                        
                    }
                }
            }
        }
        system.debug('Amendment Build UP Items -->' + amendmentBuildUpItems);
        BuildUpItemTriggerHelper.skipfromAmendment=true;
        insert amendmentBuildUpItems;
        BuildUpItemTriggerHelper.skipfromAmendment=false;

        /*
        Map<Id, List<BuildUpItem__c>> awardBuildUpItemsMap = new Map<Id, List<BuildUpItem__c>>();

        if (awardBuildUpItemsList.size() > 0) {
            for (BuildUpItem__c buildUpItem : awardBuildUpItemsList) {
                if (!awardBuildUpItemsMap.containsKey(buildUpItem.AwardBudgetCategory__c)) {
                    awardBuildUpItemsMap.put(buildUpItem.AwardBudgetCategory__c, new List<BuildUpItem__c>());
                }
                awardBuildUpItemsMap.get(buildUpItem.AwardBudgetCategory__c).add(buildUpItem);
            }

            for (Id awardKey : formalAmendmentAwardMap.keySet()) {
                AmendmentRequest__c amendmentRequest = formalAmendmentAwardMap.get(awardKey);
                List<AwardBudgetCategory__c> awardBudgetCategories = awardAndAwdBudgetCategoriesMap.get(awardKey);
                for (AwardBudgetCategory__c awardBudgetcategory : awardBudgetCategories) {
                    for (AmendmentRequestBudgetCategory__c amendmentRequestBudgetCategory : amendmentRequestBudgetCategories) {
                        if (amendmentRequestBudgetCategory.AmendmentRequest__c.equals(amendmentRequest.Id) &&
                                awardBudgetcategory.BudgetCategory__c.equals(
                                    amendmentRequestBudgetCategory.BudgetCategory__c) &&
                                awardBudgetcategory.ServiceArea__c.equals(
                                    amendmentRequestBudgetCategory.ServiceArea1__c)) {
                            List<BuildUpItem__c> awdbuildupitems = new List<BuildUpItem__c>();
                            if (awardBuildUpItemsMap.containsKey(awardBudgetcategory.Id)) {
                                awdbuildupitems = awardBuildUpItemsMap.get(awardBudgetcategory.Id);
                            }
                            for (BuildUpItem__c buildUpItem : awdbuildupitems) {
                                BuildUpItem__c amendmentBuildUpItem = new BuildUpItem__c();
                                if(amendmentRequestBudgetCategory.BudgetCategory__r.Name == 'Personnel'){
                                        amendmentBuildUpItem.Name__c = buildUpItem.Name__c;
                                        amendmentBuildUpItem.TotalHours__c = buildUpItem.TotalHours__c;
                                        amendmentBuildUpItem.Title__c = buildUpItem.Title__c;
                                        amendmentBuildUpItem.RequestedHours__c = buildUpItem.RequestedHours__c;
                                        amendmentBuildUpItem.HourlyRate__c = buildUpItem.HourlyRate__c;
                                        amendmentBuildUpItem.MatchType__c = buildUpItem.MatchType__c;
                                    }
                                    if(amendmentRequestBudgetCategory.BudgetCategory__r.Name == 'Fringe Benefits'){
                                        amendmentBuildUpItem.Name__c = buildUpItem.Name__c;
                                        amendmentBuildUpItem.ListBenefitType__c = buildUpItem.ListBenefitType__c;
                                        amendmentBuildUpItem.FBTotalSalary__c = buildUpItem.FBTotalSalary__c;
                                        amendmentBuildUpItem.Benefit__c = buildUpItem.Benefit__c;
                                        amendmentBuildUpItem.MatchType__c = buildUpItem.MatchType__c;
                                    }
                                    if(amendmentRequestBudgetCategory.BudgetCategory__r.Name == 'Travel'){
                                        amendmentBuildUpItem.TravelDestination__c = buildUpItem.TravelDestination__c;
                                        amendmentBuildUpItem.TravelPurpose__c = buildUpItem.TravelPurpose__c;
                                        amendmentBuildUpItem.TravelTotalMiles__c = buildUpItem.TravelTotalMiles__c;
                                        amendmentBuildUpItem.TravelMileRate__c = buildUpItem.TravelMileRate__c;
                                        amendmentBuildUpItem.MatchType__c = buildUpItem.MatchType__c;
                                    }
                                    if(amendmentRequestBudgetCategory.BudgetCategory__r.Name == 'Equipment'){
                                        amendmentBuildUpItem.EquipmentDesc__c = buildUpItem.EquipmentDesc__c;
                                        amendmentBuildUpItem.EquipmentVAWAUse__c = buildUpItem.EquipmentVAWAUse__c;
                                        amendmentBuildUpItem.EquipmentQuantity__c = buildUpItem.EquipmentQuantity__c;
                                        amendmentBuildUpItem.EquipmentUnitPrice__c = buildUpItem.EquipmentUnitPrice__c;
                                        amendmentBuildUpItem.MatchType__c = buildUpItem.MatchType__c;
                                    }
                                    if(amendmentRequestBudgetCategory.BudgetCategory__r.Name == 'Supplies'){
                                        amendmentBuildUpItem.EquipmentDesc__c = buildUpItem.EquipmentDesc__c;
                                        amendmentBuildUpItem.EquipmentQuantity__c = buildUpItem.EquipmentQuantity__c;
                                        amendmentBuildUpItem.EquipmentUnitPrice__c = buildUpItem.EquipmentUnitPrice__c;
                                        amendmentBuildUpItem.MatchType__c = buildUpItem.MatchType__c;
                                    }
                                    if(amendmentRequestBudgetCategory.BudgetCategory__r.Name == 'Contracted Fees'){
                                        amendmentBuildUpItem.CSCType__c = buildUpItem.CSCType__c;
                                        amendmentBuildUpItem.CFTotalHours__c =buildUpItem.CFTotalHours__c;
                                        amendmentBuildUpItem.CFRate__c = buildUpItem.CFRate__c;
                                        amendmentBuildUpItem.MatchType__c = buildUpItem.MatchType__c;
                                    }
                                    if(amendmentRequestBudgetCategory.BudgetCategory__r.Name == 'Training'){
                                        amendmentBuildUpItem.Name__c = buildUpItem.Name__c;
                                        amendmentBuildUpItem.RegistrationPerPerson__c = buildUpItem.RegistrationPerPerson__c;
                                        amendmentBuildUpItem.PerDiem__c = buildUpItem.PerDiem__c;
                                        amendmentBuildUpItem.HotelFees__c = buildUpItem.HotelFees__c;
                                        amendmentBuildUpItem.NumberofDays__c = buildUpItem.NumberofDays__c;
                                        amendmentBuildUpItem.NumberAttending__c = buildUpItem.NumberAttending__c;
                                        amendmentBuildUpItem.MatchType__c = buildUpItem.MatchType__c;
                                    }
                                    if(amendmentRequestBudgetCategory.BudgetCategory__r.Name == 'Other'){
                                        amendmentBuildUpItem.EquipmentDesc__c = buildUpItem.EquipmentDesc__c;
                                        amendmentBuildUpItem.EquipmentQuantity__c = buildUpItem.EquipmentQuantity__c;
                                        amendmentBuildUpItem.EquipmentUnitPrice__c = buildUpItem.EquipmentUnitPrice__c;
                                        amendmentBuildUpItem.MatchType__c = buildUpItem.MatchType__c;
                                    }
                                amendmentBuildUpItem.AmendmentRequestBudgetCategory__c = amendmentRequestBudgetCategory.Id;

                                amendmentBuildUpItems.add(amendmentBuildUpItem);
                            }
                        }
                    }
                }
            }
            system.debug('Amendment Build UP Items -->' + amendmentBuildUpItems);
            BuildUpItemTriggerHelper.skipfromAmendment=true;
            insert amendmentBuildUpItems;
            BuildUpItemTriggerHelper.skipfromAmendment=false;

        }*/
    }

    private void copyPeriodicAmendmentOneBPBudgetCategories(Map<Id, AmendmentRequest__c> periodicAmdAwdForOneBPMap) {
        List<AmendmentRequestBudgetCategory__c> amendmentRequestBudgetCategories = new List<AmendmentRequestBudgetCategory__c>();
        Set<Id> awardBudgetCategoryIds = new Set<Id>();
        Set<Id> awardIds = periodicAmdAwdForOneBPMap.keySet();

        Map<Id, List<AwardBudgetCategory__c>> awardAndAwdBudgetCategoriesMap = new Map<Id, List<AwardBudgetCategory__c>>();

        List<AwardBudgetCategory__c> awardBudgetCategoriesList = [select Id, Name, Award__c, BudgetCategory__c,
                                     GrantorAmount__c, GranteeAmount__c, ServiceArea__c, Amount__c
                                     FROM AwardBudgetCategory__c
                                     where Award__c = :awardIds];

        for (AwardBudgetCategory__c awdBudCat : awardBudgetCategoriesList) {
            awardBudgetCategoryIds.add(awdBudCat.Id);
            if (!awardAndAwdBudgetCategoriesMap.containsKey(awdBudCat.Award__c)) {
                awardAndAwdBudgetCategoriesMap.put(awdBudCat.Award__c, new List<AwardBudgetCategory__c>());
            }
            awardAndAwdBudgetCategoriesMap.get(awdBudCat.Award__c).add(awdBudCat);
        }

        for (Id awardKey : periodicAmdAwdForOneBPMap.keySet()) {
            AmendmentRequest__c amendmentRequest = periodicAmdAwdForOneBPMap.get(awardKey);
            List<AwardBudgetCategory__c> awardBudgetCategories = awardAndAwdBudgetCategoriesMap.get(awardKey);
            for (AwardBudgetCategory__c awardBudgetCategory : awardBudgetCategories) {
                AmendmentRequestBudgetCategory__c amendmentRequestBudgetCategory =
                    new AmendmentRequestBudgetCategory__c();
                amendmentRequestBudgetCategory.Name = awardBudgetCategory.Name;
                amendmentRequestBudgetCategory.AmendmentRequest__c = amendmentRequest.Id;
                amendmentRequestBudgetCategory.BudgetCategory__c = awardBudgetCategory.BudgetCategory__c;
                amendmentRequestBudgetCategory.CurrentAmount__c = 0.0;
                amendmentRequestBudgetCategory.ServiceArea1__c = awardBudgetCategory.ServiceArea__c;

                amendmentRequestBudgetCategories.add(amendmentRequestBudgetCategory);
            }
        }
        insert amendmentRequestBudgetCategories;
    }

    private void copyPeriodicAmendmentMultipleBPBudgetCategories(Map<Id, AmendmentRequest__c> periodicAmdAwdForAllBPsMap,
            Map<Id, Id> periodicAmdAwdMap) {
        system.debug('*** testing 123 - sarat');

        Set<Id> awardIds = periodicAmdAwdForAllBPsMap.keySet();

        Map<Id, Award__c> awardMap = new Map<Id, Award__c>([select Id, Name, ActiveBudgetYear__c,
                Grant__r.Application__c
                from Award__c
                where Id IN :awardIds]);
        Map<Id, Id> awardApplicationMap = new Map<Id, Id>();

        for (Id awardKey : periodicAmdAwdForAllBPsMap.keySet()) {
            Award__c award = awardMap.get(awardKey);
            awardApplicationMap.put(award.Id, award.Grant__r.Application__c);
        }

        List<Id> applicationIds = awardApplicationMap.values();

        List<Budgetperiod__c> applicationBudgetPeriodsList = [select Id, BudgetPeriodTitle__c, SequenceNumber__c,
                              BudgetPeriod__c, BudgetStartDate__c, BudgetEndDate__c,
                              Application__c
                              from Budgetperiod__c
                              where Application__c IN :applicationIds];

        Map<Id, List<Integer>> applicationBPSeqNumbersMap = new Map<Id, List<Integer>>();
        Map<Id, Budgetperiod__c> applicationBPs = new Map<Id, Budgetperiod__c>();

        for (Budgetperiod__c budgetPeriod : applicationBudgetPeriodsList) {
            if (!applicationBPSeqNumbersMap.containsKey(budgetPeriod.Application__c)) {
                applicationBPSeqNumbersMap.put(budgetPeriod.Application__c, new List<Integer>());
            }
            applicationBPs.put(budgetPeriod.Application__c, budgetPeriod);
            applicationBPSeqNumbersMap.get(budgetPeriod.Application__c).add(budgetPeriod.SequenceNumber__c.intValue());
        }

        Map<Id, Integer> applicationNextBPMap = new Map<Id, Integer>();

        for (Id awardKey : periodicAmdAwdForAllBPsMap.keySet()) {
            Id applicationId = awardApplicationMap.get(awardKey);
            List<Integer> applicationBPSeqNumbersList = applicationBPSeqNumbersMap.get(applicationId);
            Award__c award = awardMap.get(awardKey);
            Integer awardSequenceNumber = award.ActiveBudgetYear__c.intValue();
            Integer nextBPSequeceNumber = doBinarySearch(applicationBPSeqNumbersList, 0,
                                          applicationBPSeqNumbersList.size() - 1, awardSequenceNumber);
            applicationNextBPMap.put(applicationId, nextBPSequeceNumber);
        }

        String query = 'select Id,Name,ServiceArea__c,BudgetCategory__c,Application__c,GrantorAmount__c,GranteeAmount__c,' +
                       'Amount__c,GranteeShare__c,ServiceArea__r.ServiceAreaLookup__c ' +
                       'from ApplicationBudgetCategory2__c';

        String whereCondition;

        for (Id applicationId : applicationNextBPMap.keySet()) {
            if (whereCondition == null) {
                whereCondition = ' Where ';
            } else {
                whereCondition += ' OR ';
            }
            whereCondition += '(Application__c = \'' + applicationId + '\' AND Budgetperiod__r.SequenceNumber__c = ' +
                              applicationNextBPMap.get(applicationId) + ')';
        }

        system.debug('*** whereCondition' + whereCondition);

        List<ApplicationBudgetCategory2__c> applicationBudgetCategoriesList = Database.query(query + whereCondition);
        List<Id> applicationBudgetCategoryIds = new List<Id>();

        Map<Id, List<ApplicationBudgetCategory2__c>> applicationBudgetCategoriesMap =
            new Map<Id, List<ApplicationBudgetCategory2__c>>();
        for (ApplicationBudgetCategory2__c appBudCat : applicationBudgetCategoriesList) {
            applicationBudgetCategoryIds.add(appBudCat.Id);
            if (!applicationBudgetCategoriesMap.containsKey(appBudCat.Application__c)) {
                applicationBudgetCategoriesMap.put(appBudCat.Application__c, new List<ApplicationBudgetCategory2__c>());
            }
            applicationBudgetCategoriesMap.get(appBudCat.Application__c).add(appBudCat);
        }

        List<AmendmentRequestBudgetCategory__c> amendmentRequestBudgetCategories =
            new List<AmendmentRequestBudgetCategory__c>();

        for (Id amendmentKey : periodicAmdAwdMap.keySet()) {
            system.debug('***In for Loop --> 1');
            Id awardKey = periodicAmdAwdMap.get(amendmentKey);
            Id applicationId = awardApplicationMap.get(awardKey);
            List<ApplicationBudgetCategory2__c> applicationBudgetCategories =
                applicationBudgetCategoriesMap.get(applicationId);
            for (ApplicationBudgetCategory2__c applicationBudgetCategory : applicationBudgetCategories) {
                system.debug('***In for Loop --> 2');
                system.debug('***appBudcat.Name' + applicationBudgetCategory.Name);
                AmendmentRequestBudgetCategory__c amendmentRequestBudgetCategory = new AmendmentRequestBudgetCategory__c();

                amendmentRequestBudgetCategory.Name = applicationBudgetCategory.Name;
                amendmentRequestBudgetCategory.AmendmentRequest__c = amendmentKey;
                amendmentRequestBudgetCategory.BudgetCategory__c = applicationBudgetCategory.BudgetCategory__c;
                amendmentRequestBudgetCategory.GrantorAmount__c = applicationBudgetCategory.GrantorAmount__c;
                amendmentRequestBudgetCategory.GranteeAmount__c = applicationBudgetCategory.GranteeAmount__c;
                amendmentRequestBudgetCategory.Amount__c = applicationBudgetCategory.Amount__c;
                amendmentRequestBudgetCategory.ServiceArea1__c = applicationBudgetCategory.ServiceArea__r.ServiceAreaLookup__c;

                amendmentRequestBudgetCategories.add(amendmentRequestBudgetCategory);
            }
        }

        insert amendmentRequestBudgetCategories;

        List<BuildUpItem__c> amendmentBuildUpItems = new List<BuildUpItem__c>();

        Map<Id, List<BuildUpItem__c>> appBudCatToBuildUpMap =
            new Map<Id, List<BuildUpItem__c>>();
        List<BuildUpItem__c> applicationbuildUpItemsList =
            [select Title__c, Narrative__c, StartDate__c, EndDate__c,
             UnitPrice__c, Quantity__c, UnitofMeasurement__c, OtherCharges__c,
             TotalDirect__c, AllowableDirect__c , Indirect__c, TotalIndirect__c,
             GrandTotal__c, GrantorShare__c, GranteeShare__c,
             ApplicationBudgetCategory__c
             from BuildUpItem__c
             where ApplicationBudgetCategory__c IN :applicationBudgetCategoryIds];

        if (applicationbuildUpItemsList.size() > 0) {
            for (BuildUpItem__c buildUpItem : applicationbuildUpItemsList) {
                if (!appBudCatToBuildUpMap.containsKey(buildUpItem.ApplicationBudgetCategory__c)) {
                    appBudCatToBuildUpMap.put(buildUpItem.ApplicationBudgetCategory__c, new List<BuildUpItem__c>());
                }
                appBudCatToBuildUpMap.get(buildUpItem.ApplicationBudgetCategory__c).add(buildUpItem);
            }

            system.debug('Application Build up line items' + appBudCatToBuildUpMap);

            // TODO: Copy Line items only when grid functionality is needed
            for (Id amendmentId : periodicAmdAwdMap.keySet()) {
                Id awardKey = periodicAmdAwdMap.get(amendmentId);
                Id applicationId = awardApplicationMap.get(awardKey);
                List<ApplicationBudgetCategory2__c> applicationBudgetCategories =
                    applicationBudgetCategoriesMap.get(applicationId);
                for (ApplicationBudgetCategory2__c applicationBudgetCategory : applicationBudgetCategories) {
                    for (AmendmentRequestBudgetCategory__c amendmentRequestBudgetCategory : amendmentRequestBudgetCategories) {
                        system.debug('*** test1' + amendmentRequestBudgetCategory.AmendmentRequest__c);
                        system.debug('Test 1' + amendmentRequestBudgetCategory.AmendmentRequest__c.equals(amendmentId));

                        if (amendmentRequestBudgetCategory.AmendmentRequest__c.equals(amendmentId) &&
                                applicationBudgetCategory.BudgetCategory__c.equals(
                                    amendmentRequestBudgetCategory.BudgetCategory__c) &&
                                applicationBudgetCategory.ServiceArea__r.ServiceAreaLookup__c.equals(
                                    amendmentRequestBudgetCategory.ServiceArea1__c)) {
                            // add only if the key exists in the map
                            List<BuildUpItem__c> appbuildupitems = new List<BuildUpItem__c>();
                            if (appBudCatToBuildUpMap.containsKey(applicationBudgetCategory.Id)) {
                                appbuildupitems = appBudCatToBuildUpMap.get(applicationBudgetCategory.Id);
                            }
                            for (BuildUpItem__c buildUpItem : appbuildupitems) {
                                BuildUpItem__c amendmentBuildUpItem = new BuildUpItem__c();
                                amendmentBuildUpItem.Title__c = buildUpItem.Title__c;
                                amendmentBuildUpItem.Narrative__c = buildUpItem.Narrative__c;
                                amendmentBuildUpItem.StartDate__c = buildUpItem.StartDate__c;
                                amendmentBuildUpItem.EndDate__c = buildUpItem.EndDate__c;
                                amendmentBuildUpItem.UnitPrice__c = buildUpItem.UnitPrice__c;
                                amendmentBuildUpItem.Quantity__c = buildUpItem.Quantity__c;
                                amendmentBuildUpItem.UnitofMeasurement__c = buildUpItem.UnitofMeasurement__c;
                                amendmentBuildUpItem.OtherCharges__c = buildUpItem.OtherCharges__c;
                                amendmentBuildUpItem.AllowableDirect__c = buildUpItem.AllowableDirect__c;
                                amendmentBuildUpItem.Indirect__c = buildUpItem.Indirect__c;
                                amendmentBuildUpItem.GrantorShare__c = buildUpItem.GrantorShare__c;
                                amendmentBuildUpItem.AmendmentRequestBudgetCategory__c = amendmentRequestBudgetCategory.Id;

                                amendmentBuildUpItems.add(amendmentBuildUpItem);
                            }
                        }
                    }
                }
            }
            system.debug('Amendment Build UP Items -->' + amendmentBuildUpItems);
            insert amendmentBuildUpItems;
        }
    }

    /*
    * 1. This method verifies if Periodic/Annual Renewal RecordType exists
    * and throws error if the user tries to add more than one
    * 'Periodic/Annual Renewal' Amendment Request
    * 2. Checks the current amendment award's budget end date and throws error if the
    * difference of budgetperiodenddate and today is greater than 60 days
    */
    private void verifyPeriodicRenewal(List<AmendmentRequest__c> amdReq) {
        List<String> recType = new List<String>();
        List<Id> awardIds = new List<Id>();

        for (AmendmentRequest__c amd : amdReq) {
            awardIds.add(amd.Award__c);
        }

        List<Award__c> awd = [select BudgetPeriod__r.BudgetEndDate__c
                              from Award__c
                              where Id = :awardIds];

        List<AmendmentRequest__c> amdRequests = [select RecordType__c
                                                FROM AmendmentRequest__c
                                                where Award__c = :awardIds];

        for (AmendmentRequest__c amd : amdReq) {
            if (amd.RecordType__c.contains('Periodic/Annual Renewal')) {
                /* List<Award__c> awd = [select BudgetPeriod__r.BudgetEndDate__c
                                      from Award__c
                                      where Id = :awardIds];*/
                Date today = system.today();
                Date budgetEndDate = awd[0].BudgetPeriod__r.BudgetEndDate__c;
                system.debug('*** Budget End Date ' + budgetEndDate);
                Integer totalDays = today.daysBetween(budgetEndDate);
                Date earliestDate = budgetEndDate.addDays(-60);

                /*List<AmendmentRequest__c> amdRequests = [select RecordType__c
                                                         FROM AmendmentRequest__c
                                                         where Award__c = :awardIds];*/
                for (AmendmentRequest__c am : amdRequests) {
                    if (totalDays >= 60) {
                        // Added Error config on 04/21/2017 - Charan
                        amd.addError(GNT.ErrorMessageHelper.fetchMessage('P02-GRNTR-85906') + ' ' + earliestDate);
                    }
                    if (am.RecordType__c.contains('Periodic/Annual Renewal')) {
                        // Added Error config on 04/21/2017 - Charan
                        amd.addError(GNT.ErrorMessageHelper.fetchMessage('P02-GRNTR-89994'));
                    }
                }
            }
        }
    }

    /*
    * This method copies Award Budget categories to amendment budget categories for Periodic/Annual Renewal
    * @Deprecated - Verify and delete
    */

    //private void createAmendmentBudgetCategories2(List<AmendmentRequest__c> amdReq) {
    //    List<AmendmentRequestBudgetCategory__c> budgetlist = new List<AmendmentRequestBudgetCategory__c>();
    //    List<Id> awardIds = new List<Id>();
    //    List<String> recType = new List<String>();
    //    boolean checkRecordType = false;
    //    for (AmendmentRequest__c amd : amdreq) {
    //        awardIds.add(amd.Award__c);
    //        recType.add(amd.RecordType__c);
    //    }

    //    if (recType.size() > 0) {
    //        for (String s : recType) {
    //            if (s.contains('Periodic/Annual Renewal')) {
    //                checkRecordType = true;
    //            }
    //        }
    //    }

    //    if (checkRecordType == true) {
    //        List<AwardBudgetCategory__c> awardbudgets = [SELECT Id, Name, Award__c, BudgetCategory__c, Amount1__c
    //                FROM AwardBudgetCategory__c
    //                where Award__c IN :awardIds];
    //        AmendmentRequestBudgetCategory__c abc;
    //        for (AmendmentRequest__c amd : amdreq) {
    //            for (AwardBudgetCategory__c awdbudget : awardbudgets) {
    //                abc = new AmendmentRequestBudgetCategory__c();
    //                abc.AmendmentRequest__c = amd.Id;
    //                abc.Name = awdbudget.Name;
    //                abc.BudgetCategory__c = awdbudget.BudgetCategory__c;
    //                budgetlist.add(abc);
    //            }
    //        }
    //        if (!budgetlist.isEmpty()) insert budgetlist;
    //    }
    //}

    /*
     * This method copies RolesAndResponsibilities from Award whose role
     * equals ProgramApprover and FiscalApprover
     */

    private void copyRolesAndResponsibilities(List<AmendmentRequest__c> amendmentRequests) {
        List<RolesAndResponsibilities__c> amendmentRolesAndResponsibilities = new List<RolesAndResponsibilities__c>();
        List<Id> awardIds = new List<Id>();

        for (AmendmentRequest__c amendmentRequest : amendmentRequests) {
            awardIds.add(amendmentRequest.Award__c);
        }

        List<RolesAndResponsibilities__c> awardRolesAndResponsibilities =
            [select Award__c, Name__c, BusinessRole__c, Responsibility__c, Notify__c
             from RolesAndResponsibilities__c
             where Award__c IN :awardIds];
             //and
             //(BusinessRole__c LIKE '%Program%' OR BusinessRole__c LIKE '%Fiscal%') ];

        Map<Id, List<RolesAndResponsibilities__c>> awardRolesAndResponsibilitiesMap =
            new Map<Id, List<RolesAndResponsibilities__c>>();

        for (RolesAndResponsibilities__c rolesAndResponsibility : awardRolesAndResponsibilities) {
            if (!awardRolesAndResponsibilitiesMap.containsKey(rolesAndResponsibility.Award__c)) {
                awardRolesAndResponsibilitiesMap.put(rolesAndResponsibility.Award__c, new List<RolesAndResponsibilities__c>());
            }
            awardRolesAndResponsibilitiesMap.get(rolesAndResponsibility.Award__c).add(rolesAndResponsibility);
        }

        for (AmendmentRequest__c amendmentRequest : amendmentRequests) {

            if (awardRolesAndResponsibilitiesMap.containsKey(amendmentRequest.Award__c)) {
                List<RolesAndResponsibilities__c> rolesAndResponsibilitiesList =
                    awardRolesAndResponsibilitiesMap.get(amendmentRequest.Award__c);

                if (rolesAndResponsibilitiesList.size() > 0) {
                    for (RolesAndResponsibilities__c rolesAndResponsibility : rolesAndResponsibilitiesList) {
                        RolesAndResponsibilities__c amendmentRolesAndResponsibility = new RolesAndResponsibilities__c();
                        amendmentRolesAndResponsibility.AmendmentRequest__c = amendmentRequest.Id;
                        amendmentRolesAndResponsibility.Name__c = rolesAndResponsibility.Name__c;
                        amendmentRolesAndResponsibility.BusinessRole__c = rolesAndResponsibility.BusinessRole__c;
                        //amendmentRolesAndResponsibility.Role__c = rolesAndResponsibility.Role__c;
                        amendmentRolesAndResponsibility.Responsibility__c = rolesAndResponsibility.Responsibility__c;
                        amendmentRolesAndResponsibility.Notify__c = rolesAndResponsibility.Notify__c;
                        amendmentRolesAndResponsibilities.add(amendmentRolesAndResponsibility);
                    }
                }
            }

        }
        if(amendmentRolesAndResponsibilities!=null){
            SystemContextMethodsHelper systemContextHelper = new SystemContextMethodsHelper();
            systemContextHelper.insertRoles(amendmentRolesAndResponsibilities);
            //insert amendmentRolesAndResponsibilities;
        }
    }

    /*
    * This method gets the next budget period from the grant to create a
    * periodic/Annual Renewal amendment request
    * @Deprecated
    */
    //private void getNextBudgetPeriodForPeriodicRenewal(List<AmendmentRequest__c> amdReqs) {
    //    List<Id> awardIds = new List<Id>();
    //    List<String> recordType = new List<String>();
    //    boolean recordTypeCheck = true;
    //    // TODO : check record type is periodic/annual renewals and execute if the recordtype is periodic - Done
    //    // Implement Map to handle List<Amendment request>
    //    /*
    //    * Scenario : If this method is to handle multiple amendment requests (Bulk), then there should be a way to
    //    * identify the amendment request and it's associated amendment request fields. Like in, if this method is used by a batch job
    //    * E.g - Amdreq1-{1,{amd1,award1,keypoc1}},Amdreq2-{2,{amd2,award2,keypoc2}} - use maps to implement
    //    */
    //    for (AmendmentRequest__c amd : amdReqs) {
    //        awardIds.add(amd.Award__c);
    //        //amendIds.add(amd.Id);
    //        recordType.add(amd.RecordType__c);
    //    }

    //    for (String s : recordType) {
    //        if (s.contains('Periodic/Annual Renewal')) {
    //            recordTypeCheck = false;
    //        }
    //    }

    //    system.debug('*** value of record Type : ' + recordTypeCheck);
    //    if (recordTypeCheck == false) {
    //        system.debug('*** Entered into trigger');
    //        List<Award__c> amendmentsGrant = [select Grant__c
    //                                          from Award__c
    //                                          where Id IN :awardIds];
    //        Id amendmentGrantId = amendmentsGrant[0].Grant__c;

    //        List<AwardBudgetCategory__c> currentawardBudgetCategories = [select Budgetperiod__c
    //                from AwardBudgetCategory__c
    //                where Award__c = :awardIds];
    //        Id currentawardBudgetPeriod = currentawardBudgetCategories[0].Budgetperiod__c;
    //        system.debug('***Current Budget Period' + currentawardBudgetPeriod);

    //        BudgetPeriod__c budgetPeriodSeqNum = [select SequenceNumber__c
    //                                              from Budgetperiod__c
    //                                              where Id = :currentawardBudgetPeriod];

    //        Integer crntAwdBudPerodSeqNum = (budgetPeriodSeqNum.SequenceNumber__c).intValue();
    //        system.debug('Current Award Budget Period Sequence Number : ' + crntAwdBudPerodSeqNum);
    //        Integer nextBdgtPridSeqNum = getNextSequenceNumber(amendmentGrantId, crntAwdBudPerodSeqNum);
    //        system.debug('*** Next Budget Period Sequence Number' + nextBdgtPridSeqNum);

    //        if (nextBdgtPridSeqNum != 0 && nextBdgtPridSeqNum != null) {
    //            BudgetPeriod__c nextBudgetPeriod = [select Budgetperiod__c, SequenceNumber__c, Id
    //                                                from Budgetperiod__c
    //                                                where Grant__c = :amendmentGrantId
    //                                                        and SequenceNumber__c = :nextBdgtPridSeqNum];

    //            system.debug('*** Next Budget Period' + nextBudgetPeriod.Budgetperiod__c);
    //            for (AmendmentRequest__c amd : amdReqs) {
    //                amd.AmendmentBudgetPeriod__c = nextBudgetPeriod.Id;
    //                amd.AmendmentBudgetStartEndDate__c = nextBudgetPeriod.Budgetperiod__c;
    //                amd.BudgetPeriodSequenceNumber__c = nextBudgetPeriod.SequenceNumber__c;
    //            }
    //        }
    //    }
    //}

    /*
    * Gets the Next Sequence Number from the budget period
    */
    //private Integer getNextSequenceNumber(Id amendmentGrantId, Integer crntAwdBudPerodSeqNum) {
    //    List<Budgetperiod__c> grantBudgetPeriods = [select SequenceNumber__c
    //            from Budgetperiod__c
    //            where Grant__c = :amendmentGrantId];

    //    List<Integer> sequenceNumbers = new List<Integer>();
    //    for (Budgetperiod__c bp : grantBudgetPeriods) {
    //        Integer i = (bp.SequenceNumber__c).intValue();
    //        sequenceNumbers.add(i);
    //    }

    //    // fetch the next sequence number from the list
    //    if (sequenceNumbers.size() > 0) {
    //        sequenceNumbers.sort();
    //        Integer nextSequenceNumber = doBinarySearch(sequenceNumbers, 0, sequenceNumbers.size() - 1, crntAwdBudPerodSeqNum);
    //        system.debug('***Next Sequence Number' + nextSequenceNumber);
    //        if (nextSequenceNumber != 0) {
    //            return nextSequenceNumber;
    //        } else return 0;
    //    } else
    //        return 0;

    //}

    /**
    * Perform binary search to return the next element.
    */

    private Integer doBinarySearch(List<Integer> t, Integer start, Integer endValue, Integer find) {

        Integer mid = (start + endValue) / 2;

        if (t.size() == 0) {
            return 0;
        }
        if (start > endValue) {
            return 0;
        }
        if (t.get(mid) == find) {
            if (t.get(t.size() - 1) == find) {
                System.debug('***There is no next Budget period in the award');
                return 0;
            } else {
                return t.get(mid + 1);
            }
        }
        if (t.get(mid) > find) {
            return doBinarySearch(t, start, mid - 1, find);
        } else if (t.get(mid) < find) {
            return doBinarySearch(t, mid + 1, endValue, find);
        } else {
            return 0;
        }
    }

    /**
    * 1.This method throws a validation error when user is trying to create more
    * than one Formal Amendment
    * 2. Copies owner from roles and responsibilities to amendment request
    */
    private void verifyFormalAmendment(List<AmendmentRequest__c> amdReqs) {
        List<Id> awardIds = new List<id>();
        List<String> amds = new List<String>();

        for (AmendmentRequest__c amd : amdReqs) {
            awardIds.add(amd.Award__c);
        }

        // Copy owner
        if (appName == 'StateasGrantee') {

            String firstName = null;
            String lastName = null;
            Boolean flagOtherOwner = false;
            List<String> awardOtherOwner = new List<String>();

            List<RolesAndResponsibilities__c> awardRolesAndResps = [select Name__c, BusinessRole__c
                    from RolesAndResponsibilities__c
                    where Award__c IN :awardIds];

            for (RolesAndResponsibilities__c resp : awardRolesAndResps) {
                if (resp.BusinessRole__c != null) {
                    if (resp.BusinessRole__c.contains('Owner')) {
                        awardOtherOwner.add(resp.Name__c);
                        flagOtherOwner = true;
                    }
                }
            }

            if (awardOtherOwner == null || awardOtherOwner.size() > 1) {
                /*amds.add('An award can contain only one associated Other Owner. Please delete if' +
                   'your award has more than one other owner');*/
                amds.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-86876'));
            }

            if (flagOtherOwner) {
                List<User> u1 = [select FirstName, LastName from User where Id = : awardOtherOwner[0]];
                for (User u2 : u1) {
                    firstName = u2.Firstname;
                    lastName = u2.LastName;
                }
            } else {
                // amds.add('Please verify that Other Owner is present in the awards Roles and Responsibilites');
                amds.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-54536'));
            }

            /*if (amdreqs.size() > 0) {
                for (AmendmentRequest__c amd : amdReqs) {
                    for (String str : amds) {
                        amd.addError(str);
                    }
                }
            }*/

            for (AmendmentRequest__c amd : amdReqs) {
                amd.KeyPersonnel__c = firstName + ' ' + lastName;
            }
        }
        if (appName == 'StateasGrantor') {

            system.debug('*** sarat test entered here ***');

            String firstName = null;
            String lastName = null;

            Contact contactKeyPOC = new Contact();

            List<GrantContact__c> awardContactKeyPOC = [select Role__c, Contact__c
                    from GrantContact__c
                    where Award__c IN :awardIds];

            system.debug('*** contacts***' + awardContactKeyPOC.size());
            System.debug('*****' + awardContactKeyPOC.get(0).Role__c);
            for (GrantContact__c keypoc : awardContactKeyPOC) {
                if (keypoc.Role__c.containsIgnoreCase('KeyPOC')) {
                    contactKeyPOC.Id = keypoc.Contact__c;
                }
            }

            List<Contact> keyPernonnelNames = [select FirstName, LastName
                                               from Contact
                                               where Id = :contactKeyPOC.Id];
            for (Contact keyPernonnelName : keyPernonnelNames) {
                firstName = keyPernonnelName.FirstName;
                lastName = keyPernonnelName.LastName;

                system.debug('*** first name ' + keyPernonnelName.FirstName + ' - ' + keyPernonnelName.LastName);
            }

            for (AmendmentRequest__c amd : amdReqs) {
                if (keyPernonnelNames.size() > 0) {
                    amd.KeyPersonnel__c = firstName + ' ' + lastName;
                } else {
                    // Added Error config on 04/21/2017 - Charan
                    // amd.addError('Please verify that KeyPOC is present in the award');
                    //amd.addError(GNT.ErrorMessageHelper.fetchMessage('P02-GRNTR-90052'));
                }
            }
        }
        // display validation error
        List<AmendmentRequest__c> amndRequest = [SELECT RecordType__c, Status__c
                                                FROM AmendmentRequest__c
                                                where Award__c IN :awardIds and RecordType__c IN ('Formal Amendments')];

        for (AmendmentRequest__c amd : amndRequest) {
            if (amd.RecordType__c == 'Formal Amendments' && amd.Status__c != 'Rejected') {
                for (AmendmentRequest__c am : amdReqs) {
                    if (am.RecordType__c.contains(amd.RecordType__c)) {
                        // Added Error config on 04/21/2017 - Charan
                        // am.addError('You cannot create more than one Formal Amendment Request');
                        am.addError(GNT.ErrorMessageHelper.fetchMessage('P02-GRNTR-64536'));
                    }
                }
            }
        }   
    }
    
    private void createAmendmentBudgetCategories(List<AmendmentRequest__c> amendmentRequestList) {
        Set<Id> awardIds = new Set<Id>();
        for (AmendmentRequest__c amendmentRequest : amendmentRequestList){
            awardIds.add(amendmentRequest.Award__c);
        }
        List<AwardBudgetCategory__c> awardBudgetCategories = [SELECT Id, Award__c, BudgetCategory__c, CurrentApprovedBudgetAmount__c, ProposedBudgetRevision__c, PercentVariance__c, PercentVarianceText__c, PercentVariancePrevious__c,
                                                              RowNumberFormula__c, AdminCostValue__c, AdminCostValueProposed__c, ProjectBudgetPlusAdminCost__c, ProjectBudgetPlusAdminCostProposed__c
                                                              FROM AwardBudgetCategory__c WHERE Award__c IN: awardIds];
        
        Map<Id,List<AwardBudgetCategory__c>> awardBudgetCategoryMap = new Map<Id,List<AwardBudgetCategory__c>>();
        for (AwardBudgetCategory__c abc : awardBudgetCategories){
            List<AwardBudgetCategory__c> tmp = awardBudgetCategoryMap.get(abc.Award__c);
            if (tmp == null){
                tmp = new List<AwardBudgetCategory__c>();
            }
            tmp.add(abc);
            awardBudgetCategoryMap.put(abc.Award__c,tmp);
        }
        
        List<AmendmentRequestBudgetCategory__c> newAmendmentBudgetCategories = new List<AmendmentRequestBudgetCategory__c>();
        for (AmendmentRequest__c amendmentRequest : amendmentRequestList){
            List<AwardBudgetCategory__c> abcs = awardBudgetCategoryMap.get(amendmentRequest.Award__c);
            if (abcs != null){
                for (AwardBudgetCategory__c abc : abcs) {
                    AmendmentRequestBudgetCategory__c currentARBC = new AmendmentRequestBudgetCategory__c();
                    currentARBC.AwardBudgetCategory__c = abc.Id;
                    currentARBC.AmendmentRequest__c = amendmentRequest.Id;
                    currentARBC.BudgetCategory__c = abc.BudgetCategory__c;
                    currentARBC.CurrentApprovedBudgetAmount__c = abc.CurrentApprovedBudgetAmount__c;
                    currentARBC.ProposedBudgetRevision__c = abc.ProposedBudgetRevision__c;
                    currentARBC.PercentVariance__c = abc.PercentVariancePrevious__c;
                    currentARBC.PercentVarianceCurrent__c = abc.PercentVarianceText__c;
                    newAmendmentBudgetCategories.add(currentARBC);                
                }
            }
        }
        insert newAmendmentBudgetCategories;
    }
    
    private void completeBudgetRevisionPostApproval(List<AmendmentRequest__c> amendmentRequestList) {
        //No need to modify the history object, it already 
        //Might need to modify the revision date/approval date stuff, but that's stuff that can wait
        Set<Id> amendmentRequestIds = new Set<Id>();
        List<AmendmentRequest__c> currentAmendmentRequests = new List<AmendmentRequest__c>();
        Set<Id> awardIds = new Set<Id>();       
        
        Set<Id> amendmentRequestIdsRejected = new Set<Id>();
        List<AmendmentRequest__c> currentAmendmentRequestsRejected = new List<AmendmentRequest__c>();
        Set<Id> awardIdsRejected = new Set<Id>();
        
        Set<Id> amendmentRequestIdsInternalApp = new Set<Id>();
        List<AmendmentRequest__c> currentAmendmentRequestsInternalApp = new List<AmendmentRequest__c>();
        Set<Id> awardIdsInternalApp = new Set<Id>();
        
        Set<Id> amendmentRequestIdsChange = new Set<Id>();
        List<AmendmentRequest__c> currentAmendmentRequestsChange = new List<AmendmentRequest__c>();
        Set<Id> awardIdsChange = new Set<Id>();   
        
        for (AmendmentRequest__c amendmentRequestIterator : amendmentRequestList) {
            if (amendmentRequestIterator.Status__c == 'Approved' && amendmentRequestIterator.Type__c == 'Budget Revision') {
                amendmentRequestIds.add(amendmentRequestIterator.Id);
            }
            else if (amendmentRequestIterator.Status__c == 'Rejected' && amendmentRequestIterator.Type__c == 'Budget Revision') {
                amendmentRequestIdsRejected.add(amendmentRequestIterator.Id);
            }
            else if (amendmentRequestIterator.Status__c == 'Approved Internally' && amendmentRequestIterator.Type__c == 'Budget Revision') {
                amendmentRequestIdsInternalApp.add(amendmentRequestIterator.Id);
            }
            else if (amendmentRequestIterator.Status__c == 'Change Requested') {
                amendmentRequestIdsChange.add(amendmentRequestIterator.Id);
            }
        }        
                                
        if (amendmentRequestIds.size() > 0) {
            currentAmendmentRequests = new List<AmendmentRequest__c>([
                SELECT Id, Award__r.Id, Award__r.GrantorOrganization__c, Award__r.Name, RevisionDate__c, Status__c, Type__c, BudgetNarrativeProposed__c 
                FROM AmendmentRequest__c 
                WHERE Id IN :amendmentRequestIds]);
        }        
        if (currentAmendmentRequests.size() > 0) {               
            for (AmendmentRequest__c amendmentRequestIterator : currentAmendmentRequests) { //Goes through all the amendment requests modified in the trigger
                System.debug('MANUALDEBUG >>> award grantor = ' + amendmentRequestIterator.Award__r.GrantorOrganization__c);
                System.debug('MANUALDEBUG >>> award = ' + amendmentRequestIterator.Award__c);
                if (amendmentRequestIterator.Status__c == 'Approved' && amendmentRequestIterator.Type__c == 'Budget Revision' && amendmentRequestIterator.Award__r.GrantorOrganization__c == 'USBE') { //Only if the budget revision request is approved do we update the currently active award budget
                    awardIds.add(amendmentRequestIterator.Award__c);
                }
            }
        }
        
        if (amendmentRequestIdsRejected.size() > 0) {
            currentAmendmentRequestsRejected = new List<AmendmentRequest__c>([
                SELECT Id, Award__r.Id, Award__r.GrantorOrganization__c, RevisionDate__c, Status__c, Type__c 
                FROM AmendmentRequest__c 
                WHERE Id IN :amendmentRequestIdsRejected]); 
        }
        if (currentAmendmentRequestsRejected.size() > 0) {
            for (AmendmentRequest__c amendmentRequestIterator : currentAmendmentRequestsRejected) { //Goes through all the amendment requests modified in the trigger
                System.debug('MANUALDEBUG >>> award grantor = ' + amendmentRequestIterator.Award__r.GrantorOrganization__c);
                System.debug('MANUALDEBUG >>> award = ' + amendmentRequestIterator.Award__c);
                if (amendmentRequestIterator.Status__c == 'Rejected' && amendmentRequestIterator.Type__c == 'Budget Revision' && amendmentRequestIterator.Award__r.GrantorOrganization__c == 'USBE') { //Only if the budget revision request is approved do we update the currently active award budget
                    awardIdsRejected.add(amendmentRequestIterator.Award__c);
                }
            }
        }
        
        if (amendmentRequestIdsInternalApp.size() > 0) {
            currentAmendmentRequestsInternalApp = new List<AmendmentRequest__c>([
                SELECT Id, Award__r.Id, Award__r.GrantorOrganization__c, RevisionDate__c, Status__c, Type__c 
                FROM AmendmentRequest__c 
                WHERE Id IN :amendmentRequestIdsInternalApp]);
        }        
        if (currentAmendmentRequestsInternalApp.size() > 0) {               
            for (AmendmentRequest__c amendmentRequestIterator : currentAmendmentRequestsInternalApp) { //Goes through all the amendment requests modified in the trigger
                System.debug('MANUALDEBUG >>> award grantor = ' + amendmentRequestIterator.Award__r.GrantorOrganization__c);
                System.debug('MANUALDEBUG >>> award = ' + amendmentRequestIterator.Award__c);
                if (amendmentRequestIterator.Status__c == 'Approved Internally' && amendmentRequestIterator.Type__c == 'Budget Revision' && amendmentRequestIterator.Award__r.GrantorOrganization__c == 'USBE') { //Only if the budget revision request is approved do we update the currently active award budget
                    awardIdsInternalApp.add(amendmentRequestIterator.Award__c);
                }
            }
        }
        System.debug('MANUALDEBUG >>> awardIdsInternalApp: ' + awardIdsInternalApp);
        
        if (amendmentRequestIdsChange.size() > 0) {
            currentAmendmentRequestsChange = new List<AmendmentRequest__c>([
                SELECT Id, Award__r.Id, Award__r.GrantorOrganization__c, RevisionDate__c, Status__c, Type__c, BudgetNarrativeProposed__c 
                FROM AmendmentRequest__c 
                WHERE Id IN :amendmentRequestIdsChange]);
        }        
        if (currentAmendmentRequestsChange.size() > 0) {               
            for (AmendmentRequest__c amendmentRequestIterator : currentAmendmentRequestsChange) { //Goes through all the amendment requests modified in the trigger
                System.debug('MANUALDEBUG >>> award grantor = ' + amendmentRequestIterator.Award__r.GrantorOrganization__c);
                System.debug('MANUALDEBUG >>> award = ' + amendmentRequestIterator.Award__c);
                if (amendmentRequestIterator.Status__c == 'Change Requested' && amendmentRequestIterator.Type__c == 'Budget Revision' && amendmentRequestIterator.Award__r.GrantorOrganization__c == 'USBE') { //Sent back with comments
                    awardIdsChange.add(amendmentRequestIterator.Award__c);
                }
            }
        }
        System.debug('MANUALDEBUG >>> amendmentRequestList: ' + amendmentRequestList);
        System.debug('MANUALDEBUG >>> amendmentRequestIdsChange: ' + amendmentRequestIdsChange);
        System.debug('MANUALDEBUG >>> currentAmendmentRequestsChange: ' + currentAmendmentRequestsChange);
        System.debug('MANUALDEBUG >>> awardIdsChange: ' + awardIdsChange);
        
        List<AwardBudgetCategory__c> awardBudgetCategoryList = new List<AwardBudgetCategory__c>();
        List<BuildUpItem__c> buildUpItemList = new List<BuildUpItem__c>();
        List<Award__c> awardList = new List<Award__c>();

        //Reset the award budget for the next revision
        if (awardIds.size() > 0) {
            List<Award__c> currentAward = new List<Award__c>([
                    SELECT Id, Grant__c, CreatedDate, CurrentApprovedBudgetSum__c, ProposedBudgetRevisionSum__c, BudgetRevisionInitiated__c, BudgetNarrativeRead__c, BudgetNarrativeWrite__c, Name, GrantAwardName__c, PercentVarianceOverTen__c, BudgetRevisionInitiatedByUSBE__c  
                    FROM Award__c
                    WHERE Id IN :awardIds]);
            List<AwardBudgetCategory__c> awardBudgetCategories = new List<AwardBudgetCategory__c>([
                SELECT Id, Award__c, BudgetCategory__c, CurrentApprovedBudgetAmount__c, ProposedBudgetRevision__c, PercentVariance__c, PercentVarianceText__c, RowNumberFormula__c, AdminCostValue__c, AdminCostValueProposed__c, YTDReimbursementPaid__c, PendingPayment__c, LastGrantorApprovedBudget__c, LastGrantorApprovedAdminCost__c
                FROM AwardBudgetCategory__c 
                WHERE Award__c IN :awardIds AND RowNumberFormula__c != null]);
            List<BuildUpItem__c> currentBuildUpItems = new List<BuildUpItem__c>([
                SELECT Id, AwardBudgetCategory__c, AwardBudgetCategory__r.Award__c, AwardBudgetCategory__r.BudgetCategory__r.RowNumber__c, CurrentActiveAwardBudgetBuildup__c, EquipmentDesc__c, EquipmentQuantity__c, EquipmentUnitPrice__c  
                FROM BuildUpItem__c 
                WHERE AwardBudgetCategory__r.Award__c IN :awardIds AND AwardBudgetCategory__r.BudgetCategory__r.RowNumber__c = '570']); //Select the buildup items relevant for award's budget categories
            List<Id> grantIdList = new List<Id>();
            List<Award__c> awardListApprovedByUSBE = new List<Award__c>();
            List<Id> awardIdListApprovedByUSBE = new List<Id>();
            List<AwardBudgetCategory__c> abcListApprovedByUSBE = new List<AwardBudgetCategory__c>();
            List<BuildUpItem__c> buildUpItemListApprovedByUSBE = new List<BuildUpItem__c>();
    
            List<Award__c> internallyApprovedAwardList = new List<Award__c>();
            List<AwardBudgetCategory__c> internallyApprovedAbcList = new List<AwardBudgetCategory__c>();
            List<BuildUpItem__c> internallyApprovedBuildUpItemList = new List<BuildUpItem__c>();
    
            for (Award__c awardIterator : currentAward) {
                //if (awardIterator.BudgetRevisionInitiatedByUSBE__c == 'Allocation Change' || awardIterator.BudgetRevisionInitiatedByUSBE__c == 'Indirect Change' || awardIterator.PercentVarianceOverTen__c == true) { //Went through USBE approval, thus need to clone this award and then change this one to amended status
                    awardListApprovedByUSBE.add(awardIterator);
                    awardIdListApprovedByUSBE.add(awardIterator.Id);
                    for (AwardBudgetCategory__c abcIterator : awardBudgetCategories) {
                        if (abcIterator.Award__c == awardIterator.Id) { abcListApprovedByUSBE.add(abcIterator); }
                    }
                    for (BuildUpItem__c buildUpItemIterator : currentBuildUpItems) {
                        if (buildUpItemIterator.AwardBudgetCategory__r.Award__c == awardIterator.Id) { buildUpItemListApprovedByUSBE.add(buildUpItemIterator); }
                    }
                //}
                /*else {
                    internallyApprovedAwardList.add(awardIterator);
                    for (AwardBudgetCategory__c abcIterator : awardBudgetCategories) {
                        if (abcIterator.Award__c == awardIterator.Id) { internallyApprovedAbcList.add(abcIterator); }
                    }
                    for (BuildUpItem__c buildUpItemIterator : currentBuildUpItems) {
                        if (buildUpItemIterator.AwardBudgetCategory__r.Award__c == awardIterator.Id) { internallyApprovedBuildUpItemList.add(buildUpItemIterator); }
                    }
                }*/
                grantIdList.add(awardIterator.Grant__c);
            }
            System.debug('MANUALDEBUG >>> grantIdList: ' + grantIdList);
            Map<String, String> oldAwardNameMapNewAwardName;
            if (awardListApprovedByUSBE.size() > 0) {
                oldAwardNameMapNewAwardName = CloneAwardHelper.deepCloneAwardList(awardIdListApprovedByUSBE, 'Amended', 'Created', abcListApprovedByUSBE, buildUpItemListApprovedByUSBE, currentAmendmentRequests);
            }/*
            if (internallyApprovedAwardList.size() > 0) {
                for (AwardBudgetCategory__c abcIterator : internallyApprovedAbcList) { //For (all the award budget categories in the award)
                    //Modifications made to award budget categories
                    abcIterator.CurrentApprovedBudgetAmount__c = abcIterator.ProposedBudgetRevision__c; //set the CurrentApprovedBudgetAmount to the ProposedBudgetRevision value
                    //abcIterator.ProposedBudgetRevision__c = 0.00;  //set the ProposedBudgetRevision value to 0
                    abcIterator.PercentVariancePrevious__c = abcIterator.PercentVarianceText__c;
                    abcIterator.AdminCostValue__c = abcIterator.AdminCostValueProposed__c;
                    awardBudgetCategoryList.add(abcIterator);
                }
                //Reset the buildup items in the AwardBudgetCategory 570  
                for (BuildUpItem__c buildUpItemIterator : internallyApprovedBuildUpItemList) { //Create new copy of them, but set field to reference the amendment request we created (for search reference later)                         
                    if (buildUpItemIterator.CurrentActiveAwardBudgetBuildup__c == 'Active') { //This revision was approved, so we don't need to roll back the buildup items. Can retire them from view
                        buildUpItemIterator.CurrentActiveAwardBudgetBuildup__c = 'Revised';
                        buildUpItemList.add(buildUpItemIterator);
                    }
                    else if (buildUpItemIterator.CurrentActiveAwardBudgetBuildup__c == 'Created') { //Modifies award budget category's build up item
                        //buildUpItemIterator.CurrentActiveAwardBudgetBuildup__c = 'Active';
                        //buildUpItemList.add(buildUpItemIterator);
    
                        //If it's approved, leave the current 'created' buildup items there to be the default buildups when the revision is next intiated
    
                        //Create a copy set of the current 'created' buildup items which are flagged as 'active' so that if the next revision is rejected it is there for reference to rollback data to
                        BuildUpItem__c activeBuildUpItem = new BuildUpItem__c();
                        activeBuildUpItem.AwardBudgetCategory__c = buildUpItemIterator.AwardBudgetCategory__c;
                        activeBuildUpItem.EquipmentDesc__c = buildUpItemIterator.EquipmentDesc__c;
                        activeBuildUpItem.EquipmentQuantity__c = buildUpItemIterator.EquipmentQuantity__c;
                        activeBuildUpItem.EquipmentUnitPrice__c = buildUpItemIterator.EquipmentUnitPrice__c;
                        activeBuildUpItem.CurrentActiveAwardBudgetBuildup__c = 'Active';
                        buildUpItemList.add(activeBuildUpItem);
                    }      
                } 
                //Modifications to current award  
                for (Award__c awardIterator : internallyApprovedAwardList) {
                    for (AmendmentRequest__c amendmentRequestIterator : currentAmendmentRequests) {
                        if (amendmentRequestIterator.Award__r.Id == awardIterator.Id) {
                            //awardIterator.BudgetNarrativeRead__c = awardIterator.BudgetNarrativeRead__c + '<br><br>' + amendmentRequestIterator.RevisionDate__c + ': ' + awardIterator.BudgetNarrativeWrite__c;
                            awardIterator.BudgetNarrativeRead__c = amendmentRequestIterator.BudgetNarrativeProposed__c;
                        }
                    }
                    //awardIterator.BudgetNarrativeRead__c = awardIterator.BudgetNarrativeRead__c + '<br><br>' + revisionDate + ': ' + awardIterator.BudgetNarrativeWrite__c;
                    awardIterator.BudgetNarrativeWrite__c = ''; 
                    awardIterator.BudgetRevisionInitiated__c = 'Not Started'; //Change to whatever status that we intend to have it set to
                    awardIterator.CurrentRevisionStatus__c = 'Active';
                    awardIterator.ApprovedInternally__c = false;
                    awardIterator.PercentVarianceOverTen__c = false;
                    awardIterator.CurrentBudgetRevisionId__c = null;
                    awardIterator.BudgetRevisionInitiatedByUSBE__c = 'Not Initiated By USBE';
                    awardList.add(awardIterator);
                } 
            }*/
    
            List<AmendmentRequest__c> amendmentRequestUpdateList = new List<AmendmentRequest__c>();         
            //Map<Id, AmendmentRequest__c> awardMapAmendmentRequest = new Map<Id, AmendmentRequest__c>();
            List<AmendmentRequest__c> activeAmendmentRequestList = new List<AmendmentRequest__c>([
                SELECT Id, Award__c, Award__r.Grant__c, Award__r.Name, AwardGrantorOrg__c, Status__c, RevisionDate__c 
                FROM AmendmentRequest__c
                WHERE Status__c = 'Active' AND AwardGrantorOrg__c = 'USBE' AND Award__r.Grant__c IN: grantIdList]);           
            //for (Id awardIterator : awardIds ) {
                for (AmendmentRequest__c amendmentReqIterator : currentAmendmentRequests) {
                    amendmentReqIterator.Status__c = 'Active'; //Set the current amendment request's status to Active
                    amendmentRequestUpdateList.add(amendmentReqIterator);
                    amendmentReqIterator.RevisionHistoryAwardName__c = oldAwardNameMapNewAwardName.get(amendmentReqIterator.Award__r.Name);
                }
                for (AmendmentRequest__c amendmentReqIterator : activeAmendmentRequestList ) {                    
                    amendmentReqIterator.Status__c = 'Revised'; //update the old amendment request to be revised (from active)
                    amendmentReqIterator.RevisionDate__c= DateTime.now();
                    amendmentRequestUpdateList.add(amendmentReqIterator);
                }                   
            //}
            System.debug('MANUALDEBUG >>> activeAmendmentRequestList: ' + activeAmendmentRequestList);
            System.debug('MANUALDEBUG >>> currentAmendmentRequests: ' + currentAmendmentRequests);
            System.debug('MANUALDEBUG >>> amendmentRequestUpdateList: ' + amendmentRequestUpdateList);
            AmendmentRequestTriggerHelper.skipTrigger = true;
            update amendmentRequestUpdateList;
            AmendmentRequestTriggerHelper.skipTrigger = false;                            
        }
        if (awardIdsRejected.size() > 0) {
            //AwardBudgetCategories:           
            List<AwardBudgetCategory__c> awardBudgetCategories = new List<AwardBudgetCategory__c>([
                SELECT Id, Award__c, BudgetCategory__c, CurrentApprovedBudgetAmount__c, ProposedBudgetRevision__c, PercentVariance__c, PercentVarianceText__c, RowNumberFormula__c, AdminCostValue__c, AdminCostValueProposed__c 
                FROM AwardBudgetCategory__c 
                WHERE Award__c IN :awardIdsRejected AND RowNumberFormula__c != null]);
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
                WHERE AwardBudgetCategory__r.Award__c IN :awardIdsRejected AND AwardBudgetCategory__r.BudgetCategory__r.RowNumber__c = '570']); 
            //Select the buildup items relevant for for this award's budget categories
            for (BuildUpItem__c buildUpItemIterator : currentBuildUpItems) { //Create new copy of them, but set field to reference the amendment request we created (for search reference later)                         
                if (buildUpItemIterator.CurrentActiveAwardBudgetBuildup__c == 'Active') { //
                    //Create a copy set of the current 'created' buildup items which are flagged as 'created' so on the next revision they show up as the default items
                    BuildUpItem__c activeBuildUpItem = new BuildUpItem__c();
                    activeBuildUpItem.AwardBudgetCategory__c = buildUpItemIterator.AwardBudgetCategory__c;
                    activeBuildUpItem.EquipmentDesc__c = buildUpItemIterator.EquipmentDesc__c;
                    activeBuildUpItem.EquipmentQuantity__c = buildUpItemIterator.EquipmentQuantity__c;
                    activeBuildUpItem.EquipmentUnitPrice__c = buildUpItemIterator.EquipmentUnitPrice__c;
                    activeBuildUpItem.CurrentActiveAwardBudgetBuildup__c = 'Created'; //Already have the 'active' buildup items for the next history item, so make the default items
                    buildUpItemList.add(activeBuildUpItem);
                }
                else if (buildUpItemIterator.CurrentActiveAwardBudgetBuildup__c == 'Created') { //
                    //Remove all 'created' buildup items and replace them with the old 'active' buildup items (revert to pre-revision) for reference use if the next revision is rejected
                    buildUpItemIterator.CurrentActiveAwardBudgetBuildup__c = 'Revised';
                    buildUpItemList.add(buildUpItemIterator);      
                }      
            }

            //Reset award
            List<Award__c> currentAward = new List<Award__c>([
                SELECT Id, ApprovedInternally__c, PercentVarianceOverTen__c, CurrentBudgetRevisionId__c, BudgetNarrativeWrite__c, BudgetNarrativeRead__c, BudgetRevisionInitiated__c 
                FROM Award__c 
                WHERE Id IN :awardIdsRejected]);
            for (Award__c awardIterator : currentAward) {
                awardIterator.BudgetNarrativeWrite__c = '';
                awardIterator.BudgetRevisionInitiated__c = 'Not Started';
                awardIterator.CurrentRevisionStatus__c = 'Rejected';
                awardIterator.ApprovedInternally__c = false;
                awardIterator.PercentVarianceOverTen__c = false;
                awardIterator.CurrentBudgetRevisionId__c = null;
                awardIterator.BudgetRevisionInitiatedByUSBE__c = 'Not Initiated By USBE';
                awardList.add(awardIterator);
            }
            //update currentAward;
        }
        if (awardIdsInternalApp.size() > 0) {
            System.debug('MANUALDEBUG >>> Award Internally Approved');
            //List<Award__c> awardList = new List<Award__c>();
            List<Award__c> currentAward = new List<Award__c>([SELECT Id, ApprovedInternally__c FROM Award__c WHERE Id IN :awardIdsInternalApp]);
            for (Award__c awardIterator : currentAward) {
                awardIterator.ApprovedInternally__c = true;
                awardIterator.CurrentRevisionStatus__c = 'Approved Internally';
                awardList.add(awardIterator);
            }
            System.debug('MANUALDEBUG >>> currentAward: ' + currentAward);
            //update currentAward;
        }
        if (awardIdsChange.size() > 0) { //Send back for changes
            List<Award__c> currentAwards = new List<Award__c>([
                SELECT Id, ApprovedInternally__c, PercentVarianceOverTen__c, CurrentBudgetRevisionId__c, BudgetNarrativeWrite__c, BudgetNarrativeRead__c, BudgetRevisionInitiated__c, Grant__c, Grant__r.InternalOrganization__c 
                FROM Award__c 
                WHERE Id IN :awardIdsChange]);
            List<Id> sendBackAwardIdList = new List<Id>();
            Set<Id> grantIdSet = new Set<Id>();
            for (Award__c awardIterator : currentAwards) {
                grantIdSet.add(awardIterator.Grant__c);
                sendBackAwardIdList.add(awardIterator.Id);
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
            Map<Id,User> userIdMapUserObj = new Map<Id,User>();
            for (User userIterator : leaUserList) {
                List<User> userList = leaIdMapUserList.get(userIterator.AccountId);
                if(userList == null){
                    userList = new List<User>();
                    leaIdMapUserList.put(userIterator.AccountId, userList);
                }
                userList.add(userIterator);
                userIdMapUserObj.put(userIterator.Id, userIterator);
            }
            System.debug('MANUALDEBUG >>> leaUserList: ' + leaUserList);    
            System.debug('MANUALDEBUG >>> leaIdMapUserList: ' + leaIdMapUserList); //Maps the LEA account Id to the list of Recipient Users who are associated with that LEA
            System.debug('MANUALDEBUG >>> userIdMapUserObj: ' + userIdMapUserObj);
            for (Award__c awardIterator : currentAwards) {
                awardIterator.BudgetRevisionInitiated__c = 'In Progress';
                awardIterator.CurrentRevisionStatus__c = 'Change Requested';
                awardIterator.ApprovedInternally__c = false;
                awardIterator.PercentVarianceOverTen__c = false;
                awardIterator.CurrentBudgetRevisionId__c = null;
                awardList.add(awardIterator);
            }
            AppUtils.TaskEmailWrapper taskEmailer = new AppUtils.TaskEmailWrapper();
            taskEmailer.setObjectList(sendBackAwardIdList);
            taskEmailer.setUserList(leaUserList);
            taskEmailer.setTaskActionName('Complete Budget Revision');
            taskEmailer.setTaskSubject('Complete Budget Revision');
            taskEmailer.setTaskStartDate(System.TODAY());
            taskEmailer.setTaskEndDate(System.TODAY()+7);
            //taskEmailer.setEmailTemplateDevName('Award_ready_for_subrecipient_approval');
            taskEmailer.setAccountIdMapUserList(leaIdMapUserList); //leaIdMapUserObjList
            String resultMessage = taskEmailer.massSendTaskMapOrg(); //They only want tasks, not both tasks and emails
        }
        GrantTriggerHelper.skipTrigger = true;
        AwardBudgetCategoryTriggerHelper.skipTrigger = true;
        USBEAwardTriggerHelper.skipTriggers = true;
        USBEAwardTriggerHelper.skipTrigger = true;
        USBEAwardTriggerHelper.skipfromAmendment = true;
        if (awardBudgetCategoryList.size() > 0) { update awardBudgetCategoryList; }
        if (buildUpItemList.size() > 0) { upsert buildUpItemList; }
        if (awardList.size() > 0) { update awardList; }
        GrantTriggerHelper.skipTrigger = false;
        AwardBudgetCategoryTriggerHelper.skipTrigger = false;
        USBEAwardTriggerHelper.skipTriggers = false;
        USBEAwardTriggerHelper.skipTrigger = false;
        USBEAwardTriggerHelper.skipfromAmendment = false;
    } 
}