global with sharing class CloneAwardHelper extends GNT.DynamicLayoutActionRedirect{
    
    global override PageReference whenClicked(){
        Savepoint sp = Database.setSavePoint();
        try{
            String recordId = ApexPages.CurrentPage().getParameters().get('id');
            Set<Id> oldAwardIds = new Set<Id>();
            oldAwardIds.add(recordId);
            deepCloneAwardList(oldAwardIds, 'Submitted for Approval');
            PageReference pf = Page.AwardView;
            pf.setRedirect(true);
            pf.getParameters().put('id', recordId);
            return pf;
        }catch(Exception e){
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, e.getMessage()));
            return null;
        }
    }
    
    @future
    global static void deepCloneAwardList(Set<Id> oldAwardIds, String newAwardStatus){
        if (oldAwardIds.size() > 0){
            USBEAwardTriggerHelper.skipfromAmendment = true;
            AwardTriggerHelper.skipfromAmendment = true;
            
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            String uniqueIdAPIName = 'InternalUniqueID__c';
            String SobjectApiName = 'Award__c';
            Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
            String commaSeparatedFields = '';
            for(String fieldName : fieldMap.keyset()){
                if(!fieldName.equalsIgnorecase(uniqueIdAPIName)){
                    if(commaSeparatedFields == null || commaSeparatedFields == ''){
                        commaSeparatedFields = fieldName;
                    }else{
                        commaSeparatedFields = commaSeparatedFields + ', ' + fieldName;
                    }
                }
            }
            String idstring = '';
            for(Id recordId : oldAwardIds){
                if (idstring == ''){
                    idstring = 'Id = \'' + recordId + '\'';
                }else{
                    idstring = idstring + ' OR Id = \'' + recordId + '\'';
                }
            }
            String query = 'select ' + commaSeparatedFields + ' from ' + SobjectApiName + ' where ' + idstring;
            List<Award__c> oldAwardList = Database.query(query);
    
            /*List<Award__c> oldAwardList = [SELECT Account__c, Acknowledgement__c, ActiveBudgetYear__c, Addressline1__c, Addressline2__c, AdministrationAcronym__c, 
                            Agreement1__c, Agreement2__c, Agreement3__c, Agreement4__c, AllocatedAmount__c, AmendedPurchaseOrderNumber__c, 
                            AmendedRequisitionNumber__c, Amendments__c, AmendmentStatus__c, AmendmentType__c, AmountAwardedThisBudgetPeriod__c, 
                            AmountAwardedToDate__c, AmountDirectAssistance__c, AmountDirectAssistanceCumulativePrior__c, AmountDirectAssistanceThisAction__c, 
                            AmountDirectCost__c, AmountFinancialAssistanceThisAction__c, AmountIndirectCost__c, AmountNonFederalShare__c, 
                            AmountProgramIncome__c, AmountUnawardedDirectAssistanceBalance__c, AmountUnobligatedCarryover__c, AmountUnobligatedOffset__c, 
                            Announcement__c, Application__c, ApplicationPOC__c, ApprovedbyODon__c, ApprovedIndirectCostRate__c, ApprovedInternally__c, 
                            Approver__c, AreTCspartofNGAAttachments__c, Assurances__c, AssurancesAgreed__c, AssurancesDecision__c, AssurancesDisagreed__c, 
                            AuditDecision__c, Authorization__c, AuthorizedRepresentativeEmail__c, AuthorizedRepresentativeLastName__c, 
                            AuthorizedRepresentativeName__c, AuthorizedRepresentativePhone__c, AuthorizedRepresentativeTitle__c, AwardAmount__c, 
                            AwardedAmountthisAction__c, AwardIssueDate__c, AwardNegotiated__c, AwardNumber__c, AwardReleaseDate__c, AwardType__c, 
                            BriberyDecision__c, BudgetNarrativeRead__c, BudgetNarrativeWrite__c, BudgetPeriod__c, BudgetPeriodEndDate__c, 
                            BudgetPeriodStartDate__c, BudgetRevisionInitiated__c, BudgetRevisionInitiatedByUSBE__c, BureauChief__c, CAGENumber__c, 
                            CashMatch__c, CertificationAgreed__c, CertificationDecision__c, CertificationDisagreed__c, Certifications__c, CFDANumber__c, 
                            City__c, CloseoutCreated__c, CompensationDecision__c, Comptroller__c, CongressionalDistrictCode__c, CongressionalDistrictName__c, 
                            Country__c, County__c, CurrentBudgetRevisionId__c, CurrentRevisionNumber__c, CurrentRevisionStatus__c, DataEvaluator__c, 
                            DeepCloned__c, DeptHasEstablishedIndirectCostRate__c, DisplayEditButton__c, DocumentNumber__c, EIN__c, Federal__c, 
                            FederalAgency__c, FederalAssistanceType__c, FederalGrantAwardIdFAIN__c, FINETProgLookup__c, FiscalYear__c, FO_Approved__c, 
                            FormsValidated__c, FOUser__c, Grant__c, GrantAdministrator__c, GrantAwardDescription__c, GrantAwardName__c, GranteeDetails__c,
                            GranteePOC__c, GranteeProgramincome__c, GrantMonitor__c, GrantsContact__c, GrantSupervisor__c, GrantType__c, HasAdjustments__c, 
                            HasApproval__c, HaveYouAcceptedTheAward__c, IDCRIssueDate__c, IndirectCostPercentage__c, IndirectCostPercentageProposed__c, 
                            IndirectCostRateDecision__c, InKind__c, IsClosedOut__c, IsInApprovalProcess__c, IsMigrated__c, IsRecordRecalled__c, 
                            IsSoleSource__c, IsStateMatchRequired__c, IsStateMatchWaived__c, IsSubAwardeeNotifiedofTermination__c, KeyPOC__c, LatestAward__c, 
                            Latitude__c, LEAComment__c, Longitude__c, MaximumAward__c, MSPValidateOrderNumber__c, NAICSCode__c, NumberOfBudgetPeriods__c, 
                            ObligatedAwardAmount__c, OD__c, OrganizationAddress__c, OrganizationName__c, OtherAssistanceTypespecify__c, PaymentMadeWithError__c, 
                            PaymentMadeWithoutError__c, PercentVarianceOverTen__c, PersonnelDecision__c, POCEmail__c, POCFax__c, POCFirstName__c, POCLastName__c, 
                            POCPhone__c, POCPrefix__c, POCSuffix__c, POCTitle__c, POUser__c, PreviousAwardNumber__c, PreviousBudgetEndDate__c, PreviousBudgetStartDate__c, 
                            PriorAwardedAmount__c, ProgramCode__c, ProgramComment__c, ProgramManager__c, ProgramsContact__c, ProjectDirector__c, ProjectOfficer__c, 
                            ProjectPeriodEndDate__c, ProjectPeriodStartDate__c, ProjectTitle__c, ProposalDescription__c, PurchaseOrderNumber__c, PurchaseOrderNumber2__c, 
                            Q1DueDate__c, Q2DueDate__c, Q3DueDate__c, Q4DueDate__c, RecallComment__c, RequisitionNumber__c, RequisitionNumber2__c, RevisionNumber__c, 
                            RevisionTotalIndirectCost__c, SendBackWithComments__c, SiteVisitPackage__c, SourceOfFunds__c, State__c, StateMatchDueDate__c, 
                            StateShareAmount__c, SubAwardee__c, SubmittedOn__c, SupportYear__c, TermsAgreed__c, TermsDisagreed__c, TermsOfAgreement__c, TotalApprovedBudget__c, 
                            TotalObligateAmount__c, VersionNumber__c, Waived__c, WaiveFunds__c, Zip4__c, zipcode__c, ExecutiveApprover__c, GrantsManager__c, 
                            PaymentApprover1__c, PaymentApprover2__c, PaymentApprover3__c, PaymentApprover4__c
                     FROM Award__c WHERE Id IN :oldAwardIds];*/
    
            List<Award__c> newAwardList = new List<Award__c>();
            for(Award__c oldAward : oldAwardList){
                Award__c newAward = oldAward.clone(false, false, false, false);
                newAward.Status__c = newAwardStatus;
                newAwardList.add(newAward);
            }
    
            insert newAwardList;
            Map<Id, Id> oldNewAwardMap = new Map<Id, Id>();
            for(Integer i = 0; i < oldAwardList.size(); i++){
                oldNewAwardMap.put(oldAwardList[i].Id, newAwardList[i].Id);
            }
            
            List<GrantContact__c> oldContactList = [SELECT Id, Contact__c, Role__c, Award__c FROM GrantContact__c WHERE Award__c IN :oldAwardList];
            List<GrantContact__c> newContactList = new List<GrantContact__c>();
            for(GrantContact__c oldContact : oldContactList){
                GrantContact__c newContact = oldContact.clone(false, false, false, false);
                newContact.Award__c = oldNewAwardMap.get(oldContact.Award__c);
                newContactList.add(newContact);
            }
            insert newContactList;
            
    
            List<AwardBudgetCategory__c> oldBCList = [SELECT Id, BudgetCategory__c, CurrentApprovedBudgetAmount__c, ProposedBudgetRevision__c, Award__c, AdminCostValue__c, AdminCostValueProposed__c, YTDReimbursementPaid__c, PendingPayment__c FROM AwardBudgetCategory__c WHERE Award__c IN :oldAwardList];
            List<AwardBudgetCategory__c> newBCList = new List<AwardBudgetCategory__c>();
    
            for(AwardBudgetCategory__c oldBC : oldBCList){
                AwardBudgetCategory__c newBC = oldBC.clone(false, false, false, false);
                newBC.Award__c = oldNewAwardMap.get(oldBC.Award__c);
                newBCList.add(newBC);
            }
            insert newBCList;
    
            Map<Id, Id> oldNewBCMap = new Map<Id, Id>();
            for(Integer i = 0; i < oldBCList.size(); i++){
                oldNewBCMap.put(oldBCList[i].Id, newBCList[i].Id);
            }
    
            List<BuildUpItem__c> oldBuildUpList = [SELECT Id, EquipmentDesc__c, EquipmentQuantity__c, EquipmentUnitPrice__c, AwardBudgetCategory__c, CurrentActiveAwardBudgetBuildup__c FROM BuildUpItem__c WHERE AwardBudgetCategory__c IN :oldBCList];
            List<BuildUpItem__c> newBuildUpList = new List<BuildUpItem__c>();
            for(BuildUpItem__c oldBuildUp : oldBuildUpList){
                BuildUpItem__c newBuildUp = oldBuildUp.clone(false, false, false, false);
                newBuildUp.AwardBudgetCategory__c = oldNewBCMap.get(oldBuildUp.AwardBudgetCategory__c);
                newBuildUpList.add(newBuildUp);
            }
            insert newBuildUpList;
    
            
            List<RolesAndResponsibilities__c> oldRRList = [SELECT Id, Name__c, BusinessRole__c, Responsibility__c, Notify__c, Award__c FROM RolesAndResponsibilities__c WHERE Award__c IN :oldAwardList];
            List<RolesAndResponsibilities__c> newRRList = new List<RolesAndResponsibilities__c>();
            for(RolesAndResponsibilities__c oldRR : oldRRList){
                RolesAndResponsibilities__c newRR = oldRR.clone(false, false, false, false);
                newRR.Award__c = oldNewAwardMap.get(oldRR.Award__c);
                newRRList.add(newRR);
            }
    
            insert newRRList;
            
            List<AwardFINETCode__c> oldAfcList = [SELECT Id, ProgramCode__c, ObjectCode__c, Amount__c, AwardStatus__c, Award__c, SpentAmount__c FROM AwardFINETCode__c WHERE Award__c IN :oldAwardList];
            List<AwardFINETCode__c> newAfcList = new List<AwardFINETCode__c>();
            for(AwardFINETCode__c oldAfc : oldAfcList){
                AwardFINETCode__c newAfc = oldAfc.clone(false, false, false, false);
                newAfc.Award__c = oldNewAwardMap.get(oldAfc.Award__c);
                newAfc.AwardStatus__c = newAwardStatus;
                newAfcList.add(newAfc);
            }
            insert newAfcList;
    
            USBEAwardTriggerHelper.skipfromAmendment = false;
            AwardTriggerHelper.skipfromAmendment = false;
        }
    }
    
    

    global static Map<String, String> deepCloneAwardList(List<Id> oldAwardIds, String oldAwardStatus, String newAwardStatus, List<AwardBudgetCategory__c> abcListApprovedByUSBE, List<BuildUpItem__c> buildUpItemListApprovedByUSBE, List<AmendmentRequest__c> currentAmendmentRequests){
        USBEAwardTriggerHelper.skipfromAmendment = true;
        AwardTriggerHelper.skipfromAmendment = true;
        
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        String uniqueIdAPIName = 'InternalUniqueID__c';
        String SobjectApiName = 'Award__c';
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
        String commaSeparatedFields = '';
        for(String fieldName : fieldMap.keyset()){
            if(!fieldName.equalsIgnorecase(uniqueIdAPIName)){
                if(commaSeparatedFields == null || commaSeparatedFields == ''){
                    commaSeparatedFields = fieldName;
                }else{
                    commaSeparatedFields = commaSeparatedFields + ', ' + fieldName;
                }
            }
        }
        String idstring = '';
        for(Id recordId : oldAwardIds){
            if (idstring == ''){
                idstring = 'Id = \'' + recordId + '\'';
            }else{
                idstring = idstring + ' OR Id = \'' + recordId + '\'';
            }
        }
        String query = 'select ' + commaSeparatedFields + ' from ' + SobjectApiName + ' where ' + idstring;
        List<Award__c> oldAwardList = Database.query(query);
    
        /*List<Award__c> oldAwardList = [
            SELECT Account__c, Acknowledgement__c, ActiveBudgetYear__c, Addressline1__c, Addressline2__c, AdministrationAcronym__c, 
                Agreement1__c, Agreement2__c, Agreement3__c, Agreement4__c, AllocatedAmount__c, AmendedPurchaseOrderNumber__c, 
                AmendedRequisitionNumber__c, Amendments__c, AmendmentStatus__c, AmendmentType__c, AmountAwardedThisBudgetPeriod__c, 
                AmountAwardedToDate__c, AmountDirectAssistance__c, AmountDirectAssistanceCumulativePrior__c, AmountDirectAssistanceThisAction__c, 
                AmountDirectCost__c, AmountFinancialAssistanceThisAction__c, AmountIndirectCost__c, AmountNonFederalShare__c, 
                AmountProgramIncome__c, AmountUnawardedDirectAssistanceBalance__c, AmountUnobligatedCarryover__c, AmountUnobligatedOffset__c, 
                Announcement__c, Application__c, ApplicationPOC__c, ApprovedbyODon__c, ApprovedIndirectCostRate__c, ApprovedInternally__c, 
                Approver__c, AreTCspartofNGAAttachments__c, Assurances__c, AssurancesAgreed__c, AssurancesDecision__c, AssurancesDisagreed__c, 
                AuditDecision__c, Authorization__c, AuthorizedRepresentativeEmail__c, AuthorizedRepresentativeLastName__c, 
                AuthorizedRepresentativeName__c, AuthorizedRepresentativePhone__c, AuthorizedRepresentativeTitle__c, AwardAmount__c, 
                AwardedAmountthisAction__c, AwardIssueDate__c, AwardNegotiated__c, AwardNumber__c, AwardReleaseDate__c, AwardType__c, 
                BriberyDecision__c, BudgetNarrativeRead__c, BudgetNarrativeWrite__c, BudgetPeriod__c, BudgetPeriodEndDate__c, 
                BudgetPeriodStartDate__c, BudgetRevisionInitiated__c, BudgetRevisionInitiatedByUSBE__c, BureauChief__c, CAGENumber__c, 
                CashMatch__c, CertificationAgreed__c, CertificationDecision__c, CertificationDisagreed__c, Certifications__c, CFDANumber__c, 
                City__c, CloseoutCreated__c, CompensationDecision__c, Comptroller__c, CongressionalDistrictCode__c, CongressionalDistrictName__c, 
                Country__c, County__c, CurrentBudgetRevisionId__c, CurrentRevisionNumber__c, CurrentRevisionStatus__c, DataEvaluator__c, 
                DeepCloned__c, DeptHasEstablishedIndirectCostRate__c, DisplayEditButton__c, DocumentNumber__c, EIN__c, Federal__c, 
                FederalAgency__c, FederalAssistanceType__c, FederalGrantAwardIdFAIN__c, FINETProgLookup__c, FiscalYear__c, FO_Approved__c, 
                FormsValidated__c, FOUser__c, Grant__c, GrantAdministrator__c, GrantAwardDescription__c, GrantAwardName__c, GranteeDetails__c,
                GranteePOC__c, GranteeProgramincome__c, GrantMonitor__c, GrantsContact__c, GrantSupervisor__c, GrantType__c, HasAdjustments__c, 
                HasApproval__c, HaveYouAcceptedTheAward__c, IDCRIssueDate__c, IndirectCostPercentage__c, IndirectCostPercentageProposed__c, 
                IndirectCostRateDecision__c, InKind__c, IsClosedOut__c, IsInApprovalProcess__c, IsMigrated__c, IsRecordRecalled__c, 
                IsSoleSource__c, IsStateMatchRequired__c, IsStateMatchWaived__c, IsSubAwardeeNotifiedofTermination__c, KeyPOC__c, LatestAward__c, 
                Latitude__c, LEAComment__c, Longitude__c, MaximumAward__c, MSPValidateOrderNumber__c, NAICSCode__c, NumberOfBudgetPeriods__c, 
                ObligatedAwardAmount__c, OD__c, OrganizationAddress__c, OrganizationName__c, OtherAssistanceTypespecify__c, PaymentMadeWithError__c, 
                PaymentMadeWithoutError__c, PercentVarianceOverTen__c, PersonnelDecision__c, POCEmail__c, POCFax__c, POCFirstName__c, POCLastName__c, 
                POCPhone__c, POCPrefix__c, POCSuffix__c, POCTitle__c, POUser__c, PreviousAwardNumber__c, PreviousBudgetEndDate__c, PreviousBudgetStartDate__c, 
                PriorAwardedAmount__c, ProgramCode__c, ProgramComment__c, ProgramManager__c, ProgramsContact__c, ProjectDirector__c, ProjectOfficer__c, 
                ProjectPeriodEndDate__c, ProjectPeriodStartDate__c, ProjectTitle__c, ProposalDescription__c, PurchaseOrderNumber__c, PurchaseOrderNumber2__c, 
                Q1DueDate__c, Q2DueDate__c, Q3DueDate__c, Q4DueDate__c, RecallComment__c, RequisitionNumber__c, RequisitionNumber2__c, RevisionNumber__c, 
                RevisionTotalIndirectCost__c, SendBackWithComments__c, SiteVisitPackage__c, SourceOfFunds__c, State__c, StateMatchDueDate__c, 
                StateShareAmount__c, SubAwardee__c, SubmittedOn__c, SupportYear__c, TermsAgreed__c, TermsDisagreed__c, TermsOfAgreement__c, TotalApprovedBudget__c, 
                TotalObligateAmount__c, VersionNumber__c, Waived__c, WaiveFunds__c, Zip4__c, zipcode__c, ExecutiveApprover__c, GrantsManager__c, 
                PaymentApprover1__c, PaymentApprover2__c, PaymentApprover3__c, PaymentApprover4__c 
            FROM Award__c 
            WHERE Id IN :oldAwardIds];*/
    
        //Budget revision modifies the award
        Map<Id, Double> grantToUpdateAmount = new Map<Id, Double>();
        List<Award__c> newAwardList = new List<Award__c>();
        List<Award__c> awardListToUpsert = new List<Award__c>();
        Map<Id, Boolean> awardMapUSBEApproval = new Map<Id, Boolean>();
        for(Award__c oldAward : oldAwardList){
            Award__c newAward = oldAward.clone(false, false, false, false);
            //newAward.Status__c = newAwardStatus;   
            newAward.Status__c = 'Activated';     
            //JC
            oldAward.Status__c = oldAwardStatus; //Status set to Amended
            for (AmendmentRequest__c amendmentRequestIterator : currentAmendmentRequests) {
                if (amendmentRequestIterator.Award__r.Id == oldAward.Id) {
                    newAward.BudgetNarrativeRead__c = amendmentRequestIterator.BudgetNarrativeProposed__c;
                }
            }
            newAward.BudgetNarrativeWrite__c = ''; 
            newAward.BudgetRevisionInitiated__c = 'Not Started'; //Change to whatever status that we intend to have it set to
            newAward.CurrentRevisionStatus__c = 'Active';
            newAward.ApprovedInternally__c = false;
            newAward.PercentVarianceOverTen__c = false;
            newAward.CurrentBudgetRevisionId__c = null;
            newAward.BudgetRevisionInitiatedByUSBE__c = 'Not Initiated By USBE';
            if (oldAward.BudgetRevisionInitiatedByUSBE__c == 'Allocation Change') {
                newAward.ObligatedAwardAmount__c = oldAward.AllocatedAmount__c;
                grantToUpdateAmount.put(oldAward.Grant__c, oldAward.AllocatedAmount__c);
            }
            if (oldAward.PercentVarianceOverTen__c = true) {
                awardMapUSBEApproval.put(oldAward.Id, true);
            }
            else {
                awardMapUSBEApproval.put(oldAward.Id, false);
            }
            //JC
            newAwardList.add(newAward); 
            awardListToUpsert.add(newAward);
            awardListToUpsert.add(oldAward);        
        }
        //insert newAwardList;
        upsert awardListToUpsert;
    
        Map<Id, Id> oldNewAwardMap = new Map<Id, Id>();
        Map<String, String> oldAwardNameMapNewAwardName = new Map<String, String>();
        for(Integer i = 0; i < oldAwardList.size(); i++){
            oldNewAwardMap.put(oldAwardList[i].Id, newAwardList[i].Id);
            oldAwardNameMapNewAwardName.put(oldAwardList[i].Name, newAwardList[i].Id);
        }
        System.debug('MANUALDEBUG >>> oldNewAwardMap: ' + oldNewAwardMap);
        
        
        List<Grant__c> grantList = [SELECT Id, CumulativeAwardedAmount__c FROM Grant__c WHERE Id IN: grantToUpdateAmount.keySet()];
        for (Grant__c grantIterator : grantList) {
            grantIterator.CumulativeAwardedAmount__c = grantToUpdateAmount.get(grantIterator.Id);
        }
        GrantTriggerHelper.skipTrigger = true;
        update grantList;
        GrantTriggerHelper.skipTrigger = false;
        
        List<GrantContact__c> oldContactList = [
            SELECT Id, Contact__c, Role__c, Award__c 
            FROM GrantContact__c 
            WHERE Award__c IN :oldAwardList];
        List<GrantContact__c> newContactList = new List<GrantContact__c>();
        for(GrantContact__c oldContact : oldContactList){
            GrantContact__c newContact = oldContact.clone(false, false, false, false);
            newContact.Award__c = oldNewAwardMap.get(oldContact.Award__c);
            newContactList.add(newContact);
        }
        insert newContactList;
        
        //Budget revision modifies the budget categories
        /* List<AwardBudgetCategory__c> oldBCList = [
            SELECT Id, BudgetCategory__c, CurrentApprovedBudgetAmount__c, ProposedBudgetRevision__c, Award__c, AdminCostValue__c, AdminCostValueProposed__c, YTDReimbursementPaid__c, PendingPayment__c 
            FROM AwardBudgetCategory__c 
            WHERE Award__c IN :oldAwardList]; */ //JC
        List<AwardBudgetCategory__c> newBCList = new List<AwardBudgetCategory__c>();
        for(AwardBudgetCategory__c oldBC : abcListApprovedByUSBE){
            AwardBudgetCategory__c newBC = oldBC.clone(false, false, false, false);
            newBC.Award__c = oldNewAwardMap.get(oldBC.Award__c);
            //JC
            //Modifications made to award budget categories
            newBC.CurrentApprovedBudgetAmount__c = oldBC.ProposedBudgetRevision__c; //set the CurrentApprovedBudgetAmount to the ProposedBudgetRevision value
            newBC.PercentVariancePrevious__c = oldBC.PercentVarianceText__c;
            newBC.AdminCostValue__c = oldBC.AdminCostValueProposed__c;
            if (awardMapUSBEApproval.get(oldBC.Award__c) == true) {
                newBC.LastGrantorApprovedBudget__c = oldBC.ProposedBudgetRevision__c; 
                newBC.LastGrantorApprovedAdminCost__c = oldBC.AdminCostValueProposed__c;
            }
            //JC
            newBCList.add(newBC);
        }
        insert newBCList;
    
        System.debug('MANUALDEBUG >>> abcListApprovedByUSBE:' + abcListApprovedByUSBE);
        System.debug('MANUALDEBUG >>> newBCList: ' + newBCList);
        Map<Id, Id> oldNewBCMap = new Map<Id, Id>();
        for(Integer i = 0; i < abcListApprovedByUSBE.size(); i++){
            oldNewBCMap.put(abcListApprovedByUSBE[i].Id, newBCList[i].Id);
        }
    
        //Budget revision modifies the buildup items
        /* List<BuildUpItem__c> oldBuildUpList = [
            SELECT Id, EquipmentDesc__c, EquipmentQuantity__c, EquipmentUnitPrice__c, AwardBudgetCategory__c, CurrentActiveAwardBudgetBuildup__c 
            FROM BuildUpItem__c 
            WHERE AwardBudgetCategory__c IN :oldBCList]; */ //JC
        List<BuildUpItem__c> newBuildUpList = new List<BuildUpItem__c>();
        for(BuildUpItem__c oldBuildUp : buildUpItemListApprovedByUSBE){
            BuildUpItem__c newBuildUp = oldBuildUp.clone(false, false, false, false);
            newBuildUp.AwardBudgetCategory__c = oldNewBCMap.get(oldBuildUp.AwardBudgetCategory__c);
            //JC
            if (oldBuildUp.CurrentActiveAwardBudgetBuildup__c == 'Active') { //This revision was approved, so we don't need to roll back the buildup items. Can retire them from view
                newBuildUp.CurrentActiveAwardBudgetBuildup__c = 'Revised';
            }
            else if (oldBuildUp.CurrentActiveAwardBudgetBuildup__c == 'Created') { //Modifies award budget category's build up item
                //Clone of the current 'created' buildup items which are flagged as 'active' so that if the next revision is rejected it is there for reference to rollback data to
                BuildUpItem__c activeBuildUpItem = oldBuildUp.clone(false, false, false, false);
                activeBuildUpItem.AwardBudgetCategory__c = oldNewBCMap.get(oldBuildUp.AwardBudgetCategory__c);
                //activeBuildUpItem.EquipmentDesc__c = oldBuildUp.EquipmentDesc__c;
                //activeBuildUpItem.EquipmentQuantity__c = oldBuildUp.EquipmentQuantity__c;
                //activeBuildUpItem.EquipmentUnitPrice__c = oldBuildUp.EquipmentUnitPrice__c;
                activeBuildUpItem.CurrentActiveAwardBudgetBuildup__c = 'Active';
                newBuildUpList.add(activeBuildUpItem);
            }
            //JC
            newBuildUpList.add(newBuildUp);
        }
        System.debug('MANUALDEBUG >>> buildUpItemListApprovedByUSBE:' + buildUpItemListApprovedByUSBE);
        System.debug('MANUALDEBUG >>> newBuildUpList:' + newBuildUpList);
        insert newBuildUpList;
    
        
        List<RolesAndResponsibilities__c> oldRRList = [
            SELECT Id, Name__c, BusinessRole__c, Responsibility__c, Notify__c, Program__c, Award__c, Agency__c, RecordTypeId, UserType__c 
            FROM RolesAndResponsibilities__c 
            WHERE Award__c IN :oldAwardList];
        List<RolesAndResponsibilities__c> newRRList = new List<RolesAndResponsibilities__c>();
        for(RolesAndResponsibilities__c oldRR : oldRRList){
            RolesAndResponsibilities__c newRR = oldRR.clone(false, false, false, false);
            newRR.Award__c = oldNewAwardMap.get(oldRR.Award__c);
            newRRList.add(newRR);
        }
        insert newRRList;
        
        List<AwardFINETCode__c> oldAfcList = [
            SELECT Id, ProgramCode__c, ObjectCode__c, Amount__c, AwardStatus__c, Award__c, SpentAmount__c 
            FROM AwardFINETCode__c 
            WHERE Award__c IN :oldAwardList];
        List<AwardFINETCode__c> newAfcList = new List<AwardFINETCode__c>();
        for(AwardFINETCode__c oldAfc : oldAfcList){
            AwardFINETCode__c newAfc = oldAfc.clone(false, false, false, false);
            newAfc.Award__c = oldNewAwardMap.get(oldAfc.Award__c);
            newAfc.AwardStatus__c = newAwardStatus;
            newAfcList.add(newAfc);
        }
        insert newAfcList;
    
        USBEAwardTriggerHelper.skipfromAmendment = false;
        AwardTriggerHelper.skipfromAmendment = false;
        
        return oldAwardNameMapNewAwardName;
    }
}