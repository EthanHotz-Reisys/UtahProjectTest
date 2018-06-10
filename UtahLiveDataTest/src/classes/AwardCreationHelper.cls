/*

    **********************************************************
    1/7/2016  Davinder Singh       Created
    **********************************************************
*/

//Handles award creation from an application.
global with sharing class AwardCreationHelper extends GNT.FlexTableActionHandler {
    public class FinetProgramDataException extends Exception {}
    global AwardCreationHelper() {}
    Map<String, Object> resultMap = new Map<String, Object>();
    Id revStepId;
    Decimal recAmount, futureAmount, finalAmountNegotiated;
    ReviewStep__c revStep;
    Static boolean finetError = false;
    public override Map<String, Object> clickHandler() {
        revStepId = urlParams.get('id');
        System.debug('***revStepId ***' + revStepId );
        Savepoint sp = Database.setSavePoint();
        try {
            revStep = [Select Id, Name, ReviewGroup__r.Announcement__r.OrganizationName__c, ReviewApprovalStatus__c, ReviewGroup__c, ReviewGroup__r.Announcement__c, GrantCode__c, ReviewGroup__r.Announcement__r.Program__r.ProgramPathway__c, ReviewGroup__r.Announcement__r.Program__c from ReviewStep__c where Id = :revStepId];
            
            if(revStep.ReviewApprovalStatus__c!='Approved' && revStep.ReviewGroup__r.Announcement__r.OrganizationName__c != 'USBE'){
                //resultMap.put('Message','FDM must be approved');
                resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-06518'));
                return resultMap;
            }
            
            List<ReviewStepApplication__c> applList = [Select Id, Name, Application__c, Application__r.AwardDecisionStatus__c, RecommendedAmount__c, RecommendedFutureAmount__c, RequestedBudget__c, RequestedAmount__c, AmountThisAction__c, Application__r.GrantorOrganizationName__c, AllocationPercentage__c from ReviewStepApplication__c where Id IN: selectedRecordIds ];
            if (applList[0].Application__r.GrantorOrganizationName__c == 'UOVC'){
            for (ReviewStepApplication__c rsa : applList) {
                system.debug('Requestd amount is ' + rsa.RequestedAmount__c + ' and Award this action is ' + rsa.AmountThisAction__c);
                if (rsa.RequestedBudget__c != rsa.AmountThisAction__c) {
                    resultMap.put('Message', 'Award can be created only when "Requested amount" is same as "Amount this action ". Please create Revision if amount is unequal');
                    return resultMap;
                }
            }
            }
            
            Integer applistcount = [Select count() from ReviewStepApplication__c where ReviewStep__c = : revStepId
                                    and Application__r.AwardDecisionStatus__c = 'Award Created'];
            if (applistcount == 0 && (revStep.GrantCode__c == null || String.isEmpty(revStep.GrantCode__c))) {
                //resultMap.put('Message','Grant abbreviation field mandatory for creation of first award.');
                resultMap.put('Message', GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-38680'));
                return resultMap;
            }

            if(applList[0].AmountThisAction__c == null){
                resultMap.put('Message', 'Amount this action is required for award creation');
                return resultMap;                
            }

            if(applList[0].AllocationPercentage__c == null){
                resultMap.put('Message', 'Calculation is required for award creation');
                return resultMap;                
            }
           /*  if (applList[0].Application__r.GrantorOrganizationName__c == 'UOVC') {
                if (applList[0].RequestedBudget__c != applList[0].AmountThisAction__c){
                resultMap.put('Message', 'The requested amount should be equal to amount this action. ');
                }
            } */

            if (applList[0].Application__r.GrantorOrganizationName__c == 'USBE') {
                Boolean isUploadProgramUSBE = false;
                Set<String> businessRolesToCheck;
                if (revStep.ReviewGroup__r.Announcement__r.Program__r.ProgramPathway__c.equals('MSP') || revStep.ReviewGroup__r.Announcement__r.Program__r.ProgramPathway__c.equals('Lump-Sum-No-App')) {
                    businessRolesToCheck = new Set<String> {'Award Approver 1', 'Award Approver 2', 'Payment Approver 1', 'Payment Approver 2'};
                } else {
                    businessRolesToCheck = new Set<String> {'Award Approver 1', 'Award Approver 2', 'Payment Approver 1', 'Payment Approver 2', 'Payment Approver 3', 'Payment Approver 4'};
                }
                List<RolesAndResponsibilities__c> rolesAndRespList = [SELECT Id, BusinessRole__c, Program__c FROM RolesAndResponsibilities__c WHERE Program__c = : revStep.ReviewGroup__r.Announcement__r.Program__c AND Name__c != null];
                Set<String> businessRolesInRoles = new Set<String>();
                for (RolesAndResponsibilities__c rolesAndRespIterator : rolesAndRespList) {
                    if (businessRolesToCheck.contains(rolesAndRespIterator.BusinessRole__c)) {
                        businessRolesToCheck.remove(rolesAndRespIterator.BusinessRole__c);
                    }
                }
                if (businessRolesToCheck.size() > 0) {
                    resultMap.put('Message', 'In order to create an Award, the roles table in the Program must also contain ' + businessRolesToCheck);
                    return resultMap;
                }
            }

            System.debug('appList: ' + applList);
            if (applList != null && applList.size() > 0) {
                ReviewStepApplication__c ap = applList[0];
                recAmount = ap.RecommendedAmount__c;
                finalAmountNegotiated = ap.AmountThisAction__c;
                futureAmount = ap.RecommendedFutureAmount__c;
                if (ap.Application__r.AwardDecisionStatus__c == 'Award Created') {
                    //resultMap.put('Message','Award is already created for selected application.');
                    resultMap.put('Message', GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-22608'));
                    return resultMap;
                } else if (ap.Application__r.AwardDecisionStatus__c == 'Revision Initiated' || ap.Application__r.AwardDecisionStatus__c == 'Revision Completed') {
                    //resultMap.put('Message','Selected Application is under Negotiation process');
                    resultMap.put('Message', GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-53644'));
                    return resultMap;
                }
            }
            Set<Id> appIds = new Set<Id>();
            List<ChangeRequest__c> crList = [SELECT Id FROM ChangeRequest__c WHERE Application__c IN : selectedRecordIds
                                             AND Status__c IN ('Submitted By Applicant', 'Review in Progress', 'Review Completed')];
            if (crList == null || crList.size() == 0) {
                //Checks to make sure that there are no currently issued awards on this application
                List<Award__c> awards = [SELECT Id, Name FROM Award__c WHERE Application__c  = : selectedRecordIds];
                if (awards.size() > 0) {
                    String errorMessage = 'One or more awards(';
                    for (Award__c award : awards) {
                        errorMessage += '<a href="/' + award.Id + '">' + award.Name + '</a>';
                    }
                    errorMessage += ') have already been initiated for this application.';
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
                    return null;
                }
                String ns = AppUtils.getNamespacePrefix();

                List<ReviewStepApplication__c> revAppList = [Select Id, Name, Application__c, RequestedAmount__c, AmountThisAction__c from ReviewStepApplication__c where Id IN : selectedRecordIds];

                for (ReviewStepApplication__c rsa : revAppList) {
                    appIds.add(rsa.Application__c);
                }
                List<Application__c> appList = [SELECT Id, ProjectOfficer__c, DataEvaluator__c, GrantMonitor__c,
                                                Announcement__r.OrganizationName__c,
                                                Announcement__r.EstimatedBudgetPeriodStartDate__c,
                                                Announcement__r.Organization__c,
                                                Announcement__r.EstimatedBudgetPeriodEndDate__c,
                                                Announcement__r.EstimatedProjectPeriodStartDate__c,
                                                Announcement__r.EstimatedProjectPeriodEndDate__c,
                                                Announcement__r.ScheduleManager__c, Announcement__r.AnnouncementType__c, ExternalOrganization__r.PointofContactUser__c,
                                                ExternalOrganization__r.Name, ExternalOrganization__c,
                                                Announcement__r.Program__r.AdministrationAcronym__c, ObligatedAmount__c,
                                                Announcement__r.MatchRequired__c, AmountThisAction__c,
                                                Announcement__r.Program__c, Grant__c,
                                                Title__c, Awarddecisionstatus__c, Status__c
                                                FROM Application__c WHERE Id IN : appIds];
                List<Application__c> applicationList = new List<Application__c>();                             
                if (appList != null && appList.size() > 0) {
                    System.debug('LEON HERE');
                    for (Application__c app : appList) {
                        app.awarddecisionstatus__c = 'Award Created';
                        app.status__c = 'Converted to Award';
                        applicationList.add(app);
                    }

                    if (applicationList.size() > 0) {
                        ApplicationTriggerHelper.skipTrigger = true;
                        update applicationList;
                        ApplicationTriggerHelper.skipTrigger = false;
                    }               
                    createAwards(appIds, recAmount, futureAmount, finalAmountNegotiated, revStepId );
                } else {
                    // resultMap.put('Message','Award can not be created for selected applications.');
                    resultMap.put('Message', GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-51906'));
                    return resultMap;
                }
            }
            if (finetError != false) { finetError = true; resultMap.put('Message', 'To create an Award, please ensure that your Finet Program contains values for Federal Award Date, FAIN Number, and Federal Awarded Amount'); }
            resultMap.put('Message', 'Success');
            return resultMap;
        } catch (Exception e) {
            ApplicationTriggerHelper.skipTrigger = false;
            AnnouncementTriggerHelper.skipTrigger = false;
            system.debug('Error in creating award ---' + e);
            //resultMap.put('Message','Error in creating Award for selected applications.');
            //resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-68133'));
            resultMap.put('Message', e.getStackTraceString() + '::' + e.getMessage());
            Database.rollBack(sp);
            return resultMap;
        }
        //resultMap.put('Message','Award has been created for selected applications.');
        resultMap.put('Message', GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-44721'));
        return resultMap;
    }
    @future
    private static void CreateAwards(Set<Id> appIds, Decimal recAmount, Decimal futureAmount, Decimal finalAmountNegotiated, Id revStepId) {
        ReviewStep__c revStep = [Select Id, Name, ReviewApprovalStatus__c, ReviewGroup__c, ReviewGroup__r.Announcement__c, GrantCode__c, ReviewGroup__r.Announcement__r.Program__r.ProgramPathway__c, ReviewGroup__r.Announcement__r.Program__c from ReviewStep__c where Id = :revStepId];
        List<Application__c> appList = [SELECT Id, ProjectOfficer__c, DataEvaluator__c, GrantMonitor__c,
                                        Announcement__r.OrganizationName__c,
                                        Announcement__r.EstimatedBudgetPeriodStartDate__c,
                                        Announcement__r.Organization__c,
                                        Announcement__r.EstimatedBudgetPeriodEndDate__c,
                                        Announcement__r.EstimatedProjectPeriodStartDate__c,
                                        Announcement__r.EstimatedProjectPeriodEndDate__c,
                                        Announcement__r.ScheduleManager__c, Announcement__r.AnnouncementType__c, ExternalOrganization__r.PointofContactUser__c,
                                        ExternalOrganization__r.Name, ExternalOrganization__c,
                                        Announcement__r.Program__r.AdministrationAcronym__c, ObligatedAmount__c,
                                        Announcement__r.MatchRequired__c, AmountThisAction__c,
                                        Announcement__r.Program__c, Grant__c,
                                        Title__c
                                        FROM Application__c WHERE Id IN : appIds];
        List<Grant__c> grantList = new List<Grant__c>();
        List<Award__c> awardList = new List<Award__c>();
        List<Application__c> applicationList = new List<Application__c>();

        system.debug('award entered');
        // Create all Grants first
        for (Application__c app : appList) {
            Grant__c grant = new Grant__c(
                ExternalOrganization__c =   app.Announcement__r.Organization__c,          // Grantor  Org
                InternalOrganization__c = app.ExternalOrganization__c, // Applicant Org
                GrantAbbreviation__c = revStep.GrantCode__c,
                Program__c = app.Announcement__r.Program__c,
                Announcement__c = app.Announcement__c,
                AdministrationAcronym__c = app.Announcement__r.Program__r.AdministrationAcronym__c,
                ProjectTitle__c = app.Title__c,
                Application__c = app.Id,
                ProjectPeriodStartDate__c = app.Announcement__r.EstimatedProjectPeriodStartDate__c,
                ProjectPeriodEndDate__c = app.Announcement__r.EstimatedProjectPeriodEndDate__c,
                ProgramManager__c = app.Announcement__r.ScheduleManager__c,
                DataEvaluator__c = app.DataEvaluator__c,
                ProjectOfficer__c = app.ProjectOfficer__c,
                GrantMonitor__c = app.GrantMonitor__c,
                GranteePOC__c =  app.ExternalOrganization__r.PointofContactUser__c,
                GrantsContact__c = UserInfo.getUserId(),
                Status__c = 'Draft'
            );
            grantList.add(grant);
            app.awarddecisionstatus__c = 'Award Created';
            app.status__c = 'Converted to Award';
            system.debug('before futureAmount');
            if (futureAmount == null)
                futureAmount = 0;
            system.debug('the future amount is --->' + futureAmount);
            //app.AmountThisAction__c=recAmount;
            app.ObligatedAmount__c = recAmount + futureAmount;
            System.debug('The Obligated amount is --->' +  app.ObligatedAmount__c);
            applicationList.add(app);
        }
        System.debug('grantlist' + grantList);
        SystemContextMethodsHelper SystemContextMethodsHelper = new SystemContextMethodsHelper();
        SystemContextMethodsHelper.insertGrant(grantList);
        if (applicationList.size() > 0) {
            ApplicationTriggerHelper.skipTrigger = true;
            update applicationList;
            ApplicationTriggerHelper.skipTrigger = false;
        }
        Set<Id> grantIdSet = new Set<Id>();
        for (Grant__c gt : grantList) {
            grantIdSet.add(gt.Id);
        }

        List<AwardFundingAccount__c> awardFundingAccounts = new List<AwardFundingAccount__c>();
        List<Grant__c> grantsList = [
                                        SELECT Id, Name, Application__r.TotalFederalMatch__c, GranteePOC__r.Email, ProjectPeriodStartDate__c, Announcement__c, Application__r.ProposalDescription__c, ProjectPeriodEndDate__c, Application__c, ProgramManager__c, ProjectOfficer__c, DataEvaluator__c, GrantMonitor__c, Program__c, Application__r.AmountThisAction__c, Application__r.Title__c, Application__r.ObligatedAmount__c, Application__r.IndirectCostPercentage__c, GranteePOC__c, Application__r.Announcement__r.MatchRequired__c, Application__r.Announcement__r.AnnouncementType__c
                                        FROM Grant__c
                                        WHERE Id IN: grantIdSet];
        System.debug('Leon here =================>' + grantsList[0]);



        for (Grant__c grant : grantsList) {
            //Copies fields from the announcement object to the new award
            Award__c award = new Award__c(
                ProjectPeriodStartDate__c = grant.ProjectPeriodStartDate__c,
                ProjectPeriodEndDate__c = grant.ProjectPeriodEndDate__c,
                Application__c = grant.Application__c,
                Announcement__c = grant.Announcement__c,
                ProgramManager__c = grant.ProgramManager__c,
                ProjectOfficer__c = grant.ProjectOfficer__c,
                DataEvaluator__c = grant.DataEvaluator__c,
                GrantMonitor__c = grant.GrantMonitor__c,
                GranteePOC__c = grant.GranteePOC__c,
                ProgramCode__c = grant.Program__c,
                GrantAwardDescription__c = grant.Application__r.ProposalDescription__c,
                //AwardedAmountthisAction__c=grant.Application__r.AmountThisAction__c,
                ApplicationPOC__c = grant.GranteePOC__r.Email,
                AwardedAmountthisAction__c = finalAmountNegotiated,
                GrantAwardName__c = grant.Application__r.Title__c,
                TotalObligateAmount__c = grant.Application__r.ObligatedAmount__c,
                IsStateMatchRequired__c = grant.Application__r.Announcement__r.MatchRequired__c,
                IndirectCostPercentageProposed__c = grant.Application__r.IndirectCostPercentage__c,
                ObligatedAwardAmount__c = grant.Application__r.TotalFederalMatch__c,
                ActiveBudgetYear__c = 1,
                Grant__c = grant.Id
            );
            if (grant.Application__r.Announcement__r.AnnouncementType__c == 'Sole Source/Directed') {
                award.AwardType__c = 'Sole-Source';
                award.IsSoleSource__c = true;
            } else {
                award.AwardType__c = 'New';
            }
            // insert award;
            System.debug('--award--' + award);
            awardList.add(award);
        }

        SystemContextMethodsHelper.insertAward(awardList);
        List<AnnouncementFundingAccount__c> appFundingAccounts = [SELECT FundingAccount__c FROM AnnouncementFundingAccount__c WHERE Announcement__c = : appList[0].Announcement__c];
        AwardFundingAccount__c tmpAwardFA;
        for (AnnouncementFundingAccount__c tmpAppFA : appFundingAccounts) {
            system.debug('awardId is ' + awardList[0].Id + ' and fundingaccount is ' + tmpAppFA.FundingAccount__c);
            tmpAwardFA = new AwardFundingAccount__c(Award__c = awardList[0].Id, FinancialAssistanceAmount__c = 0, FundingAccount__c = tmpAppFA.FundingAccount__c);
            awardFundingAccounts.add(tmpAwardFA);
        }
        System.debug(awardFundingAccounts.size());
        if (awardFundingAccounts.size() > 0) {
            insert awardFundingAccounts;
        }
        Announcement__c ann = [Select Id, Name, ApplicationsReviewStatus__c, ApplicationsAwarded__c, OrganizationName__c from Announcement__c  where id = :revStep.ReviewGroup__r.Announcement__c];
        if (ann.ApplicationsAwarded__c == null) {
            ann.ApplicationsAwarded__c = 1;
        } else {
            ann.ApplicationsAwarded__c = ann.ApplicationsAwarded__c + 1;
        }
        AnnouncementTriggerHelper.skipTrigger = true;
        update ann;
        AnnouncementTriggerHelper.skipTrigger = false;
        System.debug('***' + ann.OrganizationName__c);
        System.debug('***' + revStep.ReviewGroup__r.Announcement__r.Program__r.ProgramPathway__c);

        //[revStep.ReviewGroup__r.Announcement__r.Program__r.ProgramPathway__c != 'Lump-Sum-App' && ]
        if (ann.OrganizationName__c == 'USBE' && (revStep.ReviewGroup__r.Announcement__r.Program__r.ProgramPathway__c != 'State-Competitive' && revStep.ReviewGroup__r.Announcement__r.Program__r.ProgramPathway__c != 'Fed-Competitive')) {
            linkFinetCode(awardList);
        }
    }

    private static void linkFinetCode(List<Award__c> newAwardList) {
        Savepoint sp = Database.setSavepoint();
        try {
            List<Award__c> awardList = new List<Award__c>([SELECT Id, Status__c, Grant__r.InternalOrganization__c, Grant__r.Program__c, Grant__r.Application__r.ProgramFiscalYear__c FROM Award__c WHERE Id IN :newAwardList]);
            List<Id> programIdList = new List<Id>();
            List<Id> subRecipientIdList = new List<Id>();
            List<String> fiscalYearList = new List<String>();
            for (Award__c award : awardList) {
                programIdList.add(award.Grant__r.Program__c);
                subRecipientIdList.add(award.Grant__r.InternalOrganization__c);
                fiscalYearList.add(award.Grant__r.Application__r.ProgramFiscalYear__c.substring(4, 8));
            }

            List<FedBudgetMain__c> fedMainList = new List<FedBudgetMain__c>([SELECT Id, Program__c, SubRecipient__c, ProgramCode__c,
                    ObjectCode__c, BudgetAmountFormula__c, FiscalYear__c
                    FROM FedBudgetMain__c WHERE
                    Program__c IN :programIdList AND SubRecipient__c IN :subRecipientIdList
                    AND FiscalYear__c IN :fiscalYearList
                                                                            ]);
            System.debug('MANUALDEBUG >>> fedMainList: ' + fedMainList);
            List<String> programCodeList = new List<String>();
            List<String> objectCodeList = new List<String>();
            Map<String, List<FedBudgetMain__c>> fedMainMap = new Map<String, List<FedBudgetMain__c>>();
            for (FedBudgetMain__c fedMain : fedMainList) {
                String key = String.valueOf(fedMain.Program__c) + String.valueOf(fedMain.SubRecipient__c) + fedMain.FiscalYear__c;
                if (!fedMainMap.containsKey(key)) {
                    fedMainMap.put(key, new List<FedBudgetMain__c>());
                }
                fedMainMap.get(key).add(fedMain);
                programCodeList.add(fedMain.ProgramCode__c);
                objectCodeList.add(fedMain.ObjectCode__c);
            }

            List<r_prog__c> programCode = [SELECT Id, PROG_CD__c, FederalAwardDate__c, FAINnumber__c, FederalAwardedAmount__c FROM r_prog__c WHERE PROG_CD__c IN :programCodeList];
            List<r_obj__c> objectCode = [SELECT Id, OBJ_CD__c FROM r_obj__c WHERE OBJ_CD__c IN :objectCodeList];
            System.debug('MANUALDEBUG >>> programCode: ' + programCode);

            Map<String, Id> programCodeMap = new Map<String, Id>();
            Map<String, Id> objectCodeMap = new Map<String, Id>();

            for (r_prog__c pc : programCode) {
                if (pc.FederalAwardDate__c == null || pc.FAINnumber__c == null || pc.FederalAwardedAmount__c == null) {
                    finetError = true; //throw new FinetProgramDataException('To create an Award, please ensure that your Finet Program contains values for Federal Award Date, FAIN Number, and Federal Awarded Amount');
                    //pc.addError('To create an Award, please ensure that your Finet Program contains values for Federal Award Date, FAIN Number, and Federal Awarded Amount');
                    throw new FinetProgramDataException('To create an Award, please ensure that your Finet Program contains values for Federal Award Date, FAIN Number, and Federal Awarded Amount');
                }
                programCodeMap.put(pc.PROG_CD__c, pc.Id);
            }
            System.debug('MANUALDEBUG >>> programCodeMap: ' + programCodeMap);

            for (r_obj__c oc : objectCode) {
                objectCodeMap.put(oc.OBJ_CD__c, oc.Id);
            }

            List<AwardFINETCode__c> newAfcList = new List<AwardFINETCode__c>();
            for (Award__c award : awardList) {
                for (FedBudgetMain__c fedMain : fedMainMap.get(String.valueOf(award.Grant__r.Program__c) + String.valueOf(award.Grant__r.InternalOrganization__c) + award.Grant__r.Application__r.ProgramFiscalYear__c.substring(4, 8))) {
                    System.debug('MANUALDEBUG >>> fedMain: ' + fedMain);
                    System.debug('MANUALDEBUG >>> programCode: ' + programCodeMap.get(fedMain.ProgramCode__c));
                    AwardFINETCode__c temp = new AwardFINETCode__c(
                        Award__c = award.Id,
                        AwardStatus__c = award.Status__c,
                        ProgramCode__c = programCodeMap.get(fedMain.ProgramCode__c),
                        ObjectCode__c = objectCodeMap.get(fedMain.ObjectCode__c),
                        Amount__c = fedMain.BudgetAmountFormula__c
                    );
                    newAfcList.add(temp);
                }
            }
            insert newAfcList;
            System.debug('--------->' + newAfcList);
        } catch (FinetProgramDataException e) {
            Database.rollback(sp);
            System.debug('--------->' + e.getMessage() + ':::' + e.getStackTraceString() + ':::' + e.getLineNumber() + ':::' + e.getCause());
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        } catch (Exception e) {
        System.debug('--------->' + e.getMessage() + ':::' + e.getStackTraceString() + ':::' + e.getLineNumber() + ':::' + e.getCause());
            Database.rollback(sp);
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }

    }
}