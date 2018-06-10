global with sharing class SubmitBudgetRevision extends GNT.FlexTableActionHandler{
    
    public class ReviewerExistanceException extends Exception {}
    public class BudgetNarrativeException extends Exception {}
    public class ProposedBudgetNotEqualApprovedBudgetException extends Exception {}
    public class AdminCostTooHighException extends Exception {}
    public class InternalApproverSameAsOwnerException extends Exception {}
    
    global override Map<String,Object> clickHandler(){
        Savepoint savestate = Database.setSavepoint();
        Map<String,Object> retVal = new Map<String,Object>();
        String recordId = urlParams.get('id'); //Current award's Id
        
        try{
        
            Award__c currentAward = [
                SELECT Id, CreatedDate, CurrentApprovedBudgetSum__c, ProposedBudgetRevisionSum__c, BudgetRevisionInitiated__c, BudgetNarrativeRead__c, BudgetNarrativeWrite__c, Name, GrantAwardName__c, ApprovedInternally__c , PercentVarianceOverTen__c, CurrentBudgetRevisionId__c, Grant__r.InternalOrganization__c, BudgetRevisionInitiatedByUSBE__c, AllocatedAmount__c, Approver__c, CurrentRevisionNumber__c, IndirectCostPercentageProposed__c, ProgramBudgetTypeUSBE__c, Grant__c 
                FROM Award__c 
                WHERE Id =: recordId]; //Gets the current award, which submitted this budget revision
            List<AwardBudgetCategory__c> awardBudgetCategories = new List<AwardBudgetCategory__c>([SELECT Id, Award__c, BudgetCategory__c, CurrentApprovedBudgetAmount__c, ProposedBudgetRevision__c, PercentVariance__c, PercentVarianceText__c, PercentVariancePrevious__c, RowNumberFormula__c, AdminCostValue__c, AdminCostValueProposed__c, ProjectBudgetPlusAdminCost__c, ProjectBudgetPlusAdminCostProposed__c, LastGrantorApprovedBudget__c, LastGrantorApprovedAdminCost__c FROM AwardBudgetCategory__c WHERE Award__c =: recordId AND RowNumberFormula__c != null]); //List of this award's budget categories
            System.debug('MANUALDEBUG >>> currentAward: ' + currentAward);
            DateTime revisionDate = DateTime.now();
            Boolean percentVarianceOverTen = false;
            Boolean equipmentTotalOver5k = false;
            
            //Need to have a written budget narrative in order to submit the revision
            if (currentAward.BudgetNarrativeWrite__c == '' || currentAward.BudgetNarrativeWrite__c == null) {
                throw new BudgetNarrativeException('In order to submit the budget revision, a budget narrative explaining and/or justifying the revision must be provided.');
            }
            //Approvers must be assigned in order to send for approver
            /*
            List<RolesAndResponsibilities__c> programRandR = new List<RolesAndResponsibilities__c>([
                SELECT Grant__c, BusinessRole__c, Name__c 
                FROM RolesAndResponsibilities__c 
                WHERE Grant__c =: currentAward.Grant__c AND (BusinessRole__c =: 'Payment Approver 1' OR BusinessRole__c =: 'Payment Approver 2' OR BusinessRole__c =: 'Payment Approver 3' OR BusinessRole__c =: 'Payment Approver 4') LIMIT 4]);
            if (programRandR.size() < 4) {
                throw new ReviewerExistanceException('In order to submit the budget revision for approval, you must have all the payment approvers in the Roles tab'); 
            }
            */
            List<RolesAndResponsibilities__c> programRandR = new List<RolesAndResponsibilities__c>([
                SELECT Grant__c, BusinessRole__c, Name__c 
                FROM RolesAndResponsibilities__c 
                WHERE Award__c =: currentAward.Id AND BusinessRole__c =: 'Grants Manager' AND Name__c != null LIMIT 1]);
            if (programRandR.size() < 1) {
                throw new ReviewerExistanceException('A Grants Manager needs to be listed in the Roles and Responsibilities table before proceeding.'); 
            }
            else if (currentAward.Approver__c == null) {
                throw new ReviewerExistanceException('In order to submit the budget revision for approval, you must have an Internal Approver assigned to the award.'); 
            }
            if (String.valueof(currentAward.Approver__c).equalsIgnoreCase(String.valueOf((UserInfo.getUserId())))) {
                throw new InternalApproverSameAsOwnerException('The internal approver cannot submit a budget revision. The submitter and the internal approver must be two different people.');
            }

            
            //Make sure budget values fit the proper validations       
            Decimal sumProjectBudgetPlusAdminCostProposed = 0;
            if (currentAward.ProgramBudgetTypeUSBE__c == 'CTE') {
                Decimal sumAdminCostValue = 0;
                Decimal sumTotalBudget = 0;
                Decimal sumAdminCostApproved = 0;
                Decimal sumAdminCostProposed = 0;
                Decimal sumProjectBudgetPlusAdminCost = 0;
                for (AwardBudgetCategory__c abcIterator : awardBudgetCategories) {
                    sumAdminCostValue += abcIterator.AdminCostValueProposed__c;
                    sumTotalBudget += abcIterator.ProposedBudgetRevision__c;
                    sumAdminCostApproved += abcIterator.AdminCostValue__c;
                    sumAdminCostProposed += abcIterator.AdminCostValueProposed__c;
                    sumProjectBudgetPlusAdminCost += abcIterator.ProjectBudgetPlusAdminCost__c;
                    sumProjectBudgetPlusAdminCostProposed += abcIterator.ProjectBudgetPlusAdminCostProposed__c;
                }
                System.debug('MANUALDEBUG >>> sumProjectBudgetPlusAdminCostProposed = ' + sumProjectBudgetPlusAdminCostProposed + ' sumProjectBudgetPlusAdminCost = ' + sumProjectBudgetPlusAdminCost);
                if (sumAdminCostValue > (sumProjectBudgetPlusAdminCostProposed*0.05)) {
                    throw new AdminCostTooHighException('Total Admin Costs cannot be over 5% of the total budget');
                }
                else if (currentAward.BudgetRevisionInitiatedByUSBE__c == 'Allocation Change' && sumProjectBudgetPlusAdminCostProposed != currentAward.AllocatedAmount__c) {
                    throw new ProposedBudgetNotEqualApprovedBudgetException('This revision has been initated by a USBE allocation amount change. You cannot submit a budget revision unless your proposed budget grand total is equal to the new allocated (awarded) amount.'); 
                }
                else if (currentAward.BudgetRevisionInitiatedByUSBE__c != 'Allocation Change' && sumProjectBudgetPlusAdminCost != sumProjectBudgetPlusAdminCostProposed) {
                    throw new ProposedBudgetNotEqualApprovedBudgetException('You cannot submit a revision if the proposed budget grand total does not equal the currently approved budget grand total');
                }
            }
            else {
                //You cannot have the proposed budget not equal the current approved budget UNLESS USBE changed the allocation amount
                //if (currentAward.BudgetRevisionInitiatedByUSBE__c == 'Allocation Change' && ((Decimal)currentAward.ProposedBudgetRevisionSum__c) != ((Decimal)currentAward.AwardedAmount__c) ) {
                if (currentAward.BudgetRevisionInitiatedByUSBE__c == 'Allocation Change' && (currentAward.ProposedBudgetRevisionSum__c).setScale(2) != currentAward.AllocatedAmount__c) {
                    throw new ProposedBudgetNotEqualApprovedBudgetException('This revision has been initated by a USBE allocation amount change. You cannot submit a budget revision unless your proposed budget grand total is equal to the new allocated (awarded) amount.'); 
                }
                else if (currentAward.BudgetRevisionInitiatedByUSBE__c != 'Allocation Change' && (currentAward.ProposedBudgetRevisionSum__c).setScale(2) != (currentAward.CurrentApprovedBudgetSum__c).setScale(2)) {
                    throw new ProposedBudgetNotEqualApprovedBudgetException('You cannot submit a revision if the proposed budget grand total does not equal the currently approved budget grand total');
                }
            }
            
            //We have already sent it for and got internal approval AND at least one budget category has a percent variance over 10%
            if (currentAward.ApprovedInternally__c == true && currentAward.PercentVarianceOverTen__c == true) {
                //Send it off for USBE (external) approval
                AmendmentRequest__c budgetRevision = [SELECT Id, Name, AwardName__c FROM AmendmentRequest__c WHERE Id =: currentAward.CurrentBudgetRevisionId__c];            
                GNT.TaskCreationHandler.createApprovalProcessTasks(budgetRevision.Id, 'Budget Revision Approval Request', budgetRevision.Name, null, System.TODAY() + 7, budgetRevision.AwardName__c, true);
                retVal.put('Message','Budget revision successfully submitted for approval');
                return retVal;
            }
            else { //We haven't sent it for internal approval yet
                currentAward.CurrentRevisionNumber__c = currentAward.CurrentRevisionNumber__c + 1;
                //Create the Amendment Request for which the budget revision's budget category info will get saved to           
                AmendmentRequest__c budgetRevision = new AmendmentRequest__c(); //Create an AmendmentRequest object that links to the current award (which has a lookup to the current grant)
                budgetRevision.Award__c = recordId;
                budgetRevision.Type__c = 'Budget Revision'; //Make sure that the AmendmentRequest's RecordType__c == 'Budget Revision'
                //budgetRevision.ApprovalDate__c = currentAward.CreatedDate; //Modify as need be later
                //budgetRevision.RevisionDate__c = revisionDate; //System.now().format(); //Modify as need be later
                if (currentAward.ProgramBudgetTypeUSBE__c == 'CTE') {
                    budgetRevision.TotalApprovedBudget__c = sumProjectBudgetPlusAdminCostProposed;
                }
                else {
                    budgetRevision.TotalApprovedBudget__c = (currentAward.CurrentApprovedBudgetSum__c).setScale(2); //Total approved budget shown in the history table, so it's the sum of the current approved budget
                }
                budgetRevision.Purpose__c = 'Budget Revision';
                budgetRevision.Impact__c = 'Budget Revision';
                budgetRevision.BudgetNarrative__c = currentAward.BudgetNarrativeRead__c; //Save the budget narrative that explains/justifies the approved budget
                budgetRevision.BudgetNarrativeProposed__c = currentAward.BudgetNarrativeRead__c + '<br><br>' + revisionDate + ': ' + currentAward.BudgetNarrativeWrite__c;
                budgetRevision.BudgetNarrativeThisRevisionOnly__c = currentAward.BudgetNarrativeWrite__c;
                budgetRevision.CurrentRevisionNumber__c = currentAward.CurrentRevisionNumber__c;
                budgetRevision.IndirectCostPercentage__c = currentAward.IndirectCostPercentageProposed__c;
                for (RolesAndResponsibilities__c rNr : programRandR) {
                    if (rNr.BusinessRole__c == 'Grants Manager') {
                        budgetRevision.GrantsManager__c = rNr.Name__c;
                    }
                    /*
                    if (rNr.BusinessRole__c == 'Payment Approver 1') {
                        budgetRevision.PaymentApprover1__c = rNr.Name__c;
                    }
                    else if (rNr.BusinessRole__c == 'Payment Approver 2') {
                        budgetRevision.PaymentApprover2__c = rNr.Name__c;
                    }
                    else if (rNr.BusinessRole__c == 'Payment Approver 3') {
                        budgetRevision.PaymentApprover3__c = rNr.Name__c;
                    }
                    else if (rNr.BusinessRole__c == 'Payment Approver 4') {
                        budgetRevision.PaymentApprover4__c = rNr.Name__c;
                    }
                    
                    if (rNr.BusinessRole__c == 'Program Approver') {
                        budgetRevision.ProgramApprover__c = rNr.Name__c;
                    }
                    else if (rNr.BusinessRole__c == 'Owner') {
                        budgetRevision.ProgramManager__c = rNr.Name__c;
                    }
                    else if (rNr.BusinessRole__c == 'Fiscal Approver') {
                        budgetRevision.FiscalApprover__c = rNr.Name__c;
                    }
                    else if (rNr.BusinessRole__c == 'Legal Approver') {
                        budgetRevision.LegalApprover__c = rNr.Name__c;
                    }
                    else if (rNr.BusinessRole__c == 'Executive Approver') {
                        budgetRevision.ExecutiveApprover__c = rNr.Name__c;
                    }
                    */
                }
                /*
                User internalReviewer = [SELECT Id, IsKeyContact__c, Organization__c, ProfileName__c FROM User WHERE IsKeyContact__c = true AND ProfileName__c = 'SPI' AND Organization__c =: currentAward.Grant__r.InternalOrganization__c LIMIT 1];
                if (internalReviewer != null) { //!internalReviewer.isEmpty()
                    budgetRevision.InternalApprover__c = internalReviewer.Id;
                    //budgetRevision.NewKeyPersonnel__c = internalReviewer.Id;
                } */
                if (currentAward.Approver__c != null) {                    
                    budgetRevision.InternalApprover__c = currentAward.Approver__c;             
                    List<Id> grantIds = new List<Id>();
                    grantIds.add(currentAward.Grant__c);
            
                    List<Grant__c> grants = [SELECT Id, GrantsManager__c FROM Grant__c WHERE Id IN: grantIds];     
                    Map<String, Map<String, Grant__Share>> shareMap = new Map<String, Map<String, Grant__Share>>();
                    for(Id idIterator : grantIds) {
                        if(!shareMap.containsKey(idIterator)) {
                            shareMap.put((ID)idIterator, new Map<String, Grant__Share>());
                        }
                    }
                    List<Grant__Share> currentShares = [SELECT ParentId, AccessLevel, UserOrGroupId FROM Grant__Share WHERE ParentId IN: grantIds];
                    System.debug('Current Shares: ' + currentShares);
                    System.debug('Current Size: ' + currentShares.size());
                    if(!currentShares.isEmpty()){
                        for(Grant__Share gs: currentShares) {
                            if(shareMap.containsKey(gs.ParentId)) {
                                shareMap.get(gs.ParentId).put(gs.userOrGroupId, gs);
                            }
                        } 
                        Grant__Share share;
                        List<Grant__Share> shares = new List<Grant__Share>();
                        for(Id idIterator : grantIds) {        
                            if(shareMap.get(idIterator).containsKey(currentAward.Approver__c)) {
                                //Updates the existing records to Edit if they are currently set to read
                                if(shareMap.get(idIterator).get(currentAward.Approver__c).AccessLevel == 'Read') {
                                    shareMap.get(idIterator).get(currentAward.Approver__c).AccessLevel = 'Edit';
                                    shares.add(shareMap.get(idIterator).get(currentAward.Approver__c));
                                }
                            }
                            else {
                                share = new Grant__Share(parentId = idIterator, AccessLevel = 'Edit', UserOrGroupId = currentAward.Approver__c , RowCause = Schema.Grant__Share.RowCause.SharetoExternalPOC__c);
                                shares.add(share);
                                shareMap.get(idIterator).put(currentAward.Approver__c, share);
                            }   
                        }
                        System.debug(shares);
                        if(shares.size() > 0) {
                            System.debug('Upsert');
                            // upsert shares;
                            SystemContextMethodsHelper SystemContextMethodsHelper = new SystemContextMethodsHelper();
                            SystemContextMethodsHelper.upsertGrantShare(Shares); 
                        }       
                    }
                }
                
                
                Decimal sumTotalBudget = 0;
                for (AwardBudgetCategory__c abcIterator : awardBudgetCategories) {
                    //Check to see if the percent variance between the budget category's proposed budget and the currently approved budget is <= 10%, if so it is automatically approved, if not it must get approval
                    if (Math.abs(abcIterator.PercentVariance__c) > 10) { //Absolute value of percent variance must be <= (10.0 = 10%) to not throw the error, so only acceptable values are between -10% and 10%
                        percentVarianceOverTen = true;    
                        budgetRevision.PercentVarianceOverTen__c = true;           
                    }
                    if (abcIterator.RowNumberFormula__c == '570') {
                        if (abcIterator.ProposedBudgetRevision__c != abcIterator.CurrentApprovedBudgetAmount__c && abcIterator.ProposedBudgetRevision__c > 5000) {
                            equipmentTotalOver5k = true;
                            budgetRevision.PercentVarianceOverTen__c = true;
                        }
                    } 
                }
                if (currentAward.BudgetRevisionInitiatedByUSBE__c == 'Allocation Change' || currentAward.BudgetRevisionInitiatedByUSBE__c == 'Indirect Change') {
                    budgetRevision.PercentVarianceOverTen__c = true; //This really is more 'RequiresUSBEApproval' than 'PercentVarianceOverTen'
                }               
                AmendmentRequestTriggerHelper.skipTrigger = true;
                insert budgetRevision; //Insert the created AmendmentRequest object
                AmendmentRequestTriggerHelper.skipTrigger = false;
                System.debug('MANUALDEBUG >>> budgetRevision: ' + budgetRevision);
       
                
                //Associate the data in the budget categories           
                List<AmendmentRequestBudgetCategory__c> budgetRevisionCategories = new List<AmendmentRequestBudgetCategory__c>(); //Create empty list of AmendmentRequestBudgetCategory__c
                //List<AwardBudgetCategory__c> awardBudgetCategories = new List<AwardBudgetCategory__c>([SELECT Id, Award__c, BudgetCategory__c, CurrentApprovedBudgetAmount__c, ProposedBudgetRevision__c, PercentVariance__c, PercentVarianceText__c, PercentVariancePrevious__c, RowNumberFormula__c FROM AwardBudgetCategory__c WHERE Award__c =: recordId AND RowNumberFormula__c != null]); //List of this award's budget categories
                for (AwardBudgetCategory__c abcIterator : awardBudgetCategories) { //For all the AwardBudgetCategories in the award copy the data fields from the AwardBudgetCategory to the AmendmentRequestBudgetCategory__c                
                    //Check to see if the percent variance between the budget category's proposed budget and the currently approved budget is <= 10%, if so it is automatically approved, if not it must get approval
                    //if (Math.abs(abcIterator.PercentVariance__c) > 10) { //Absolute value of percent variance must be <= (10.0 = 10%) to not throw the error, so only acceptable values are between -10% and 10%
                        //percentVarianceOverTen = true;               
                    //}                               
                    AmendmentRequestBudgetCategory__c currentARBC = new AmendmentRequestBudgetCategory__c(); //Create AmendmentRequestBudgetCategory__c
                    currentARBC.AwardBudgetCategory__c = abcIterator.Id; //Link created AmendmentRequestBudgetCategory__c to the created (and already inserted) AmendmentRequest object
                    currentARBC.AmendmentRequest__c = budgetRevision.Id; //AmendmentRequest__c
                    currentARBC.BudgetCategory__c = abcIterator.BudgetCategory__c; //BudgetCategory__c
                    currentARBC.CurrentApprovedBudgetAmount__c = abcIterator.CurrentApprovedBudgetAmount__c; //CurrentApprovedBudgetAmount__c
                    currentARBC.ProposedBudgetRevision__c = abcIterator.ProposedBudgetRevision__c; //ProposedBudgetRevision__c
                    currentARBC.PercentVariance__c = abcIterator.PercentVariancePrevious__c;
                    currentARBC.PercentVarianceCurrent__c = abcIterator.PercentVarianceText__c;
                    currentARBC.LastGrantorApprovedBudget__c = abcIterator.LastGrantorApprovedBudget__c;
                    if (currentAward.ProgramBudgetTypeUSBE__c == 'CTE') {
                        currentARBC.AdminCostValue__c = abcIterator.AdminCostValue__c;
                        currentARBC.AdminCostValueProposed__c = abcIterator.AdminCostValueProposed__c;
                        currentARBC.LastGrantorApprovedAdminCost__c = abcIterator.LastGrantorApprovedAdminCost__c;
                    }
                    budgetRevisionCategories.add(currentARBC);                
                }
                System.debug('MANUALDEBUG >>> budgetRevisionCategories' + budgetRevisionCategories );
                System.debug('MANUALDEBUG >>> awardBudgetCategories ' + awardBudgetCategories);
                insert budgetRevisionCategories; //Insert the list of created AmendmentRequestBudgetCategory__c 
                
    
                //Create the buildup item for the historied budget        
                List<BuildUpItem__c> historyBuildUpItems = new List<BuildUpItem__c>();
                List<BuildUpItem__c> currentBuildUpItems = new List<BuildUpItem__c>([
                    SELECT Id, AwardBudgetCategory__r.Award__c, AwardBudgetCategory__r.BudgetCategory__r.RowNumber__c, EquipmentDesc__c, EquipmentCost__c, EquipmentQuantity__c, EquipmentUnitPrice__c, CurrentActiveAwardBudgetBuildup__c 
                    FROM BuildUpItem__c 
                    WHERE AwardBudgetCategory__r.Award__c =: recordId AND AwardBudgetCategory__r.BudgetCategory__r.RowNumber__c = '570']); 
                    //Select the buildup items relevant for for this award's budget categories
                AmendmentRequestBudgetCategory__c buildupARBC = [
                    SELECT Id, AmendmentRequest__c, BudgetCategory__r.RowNumber__c 
                    FROM AmendmentRequestBudgetCategory__c 
                    WHERE AmendmentRequest__c =: budgetRevision.Id AND BudgetCategory__r.RowNumber__c =: '570' LIMIT 1]; //The ARBC that we want to assocaite the buildup items to
                for (BuildUpItem__c buildUpItemIterator : currentBuildUpItems) { //Iterates through all the buildup items on the award budget category
                    if (buildUpItemIterator.CurrentActiveAwardBudgetBuildup__c == 'Active') { //Adds copy of the to be historied buildup item onto the amendment request budget category
                        BuildUpItem__c buildUpItemToInsert = new BuildUpItem__c();
                        buildUpItemToInsert.AmendmentRequestBudgetCategory__c = buildupARBC.Id;
                        buildUpItemToInsert.EquipmentDesc__c = buildUpItemIterator.EquipmentDesc__c;
                        buildUpItemToInsert.EquipmentQuantity__c = buildUpItemIterator.EquipmentQuantity__c;
                        buildUpItemToInsert.EquipmentUnitPrice__c = buildUpItemIterator.EquipmentUnitPrice__c;
                        buildUpItemToInsert.CurrentActiveAwardBudgetBuildup__c = 'Active';
                        historyBuildUpItems.add(buildUpItemToInsert);
                        //Creates the copy of the buildup items onto the history item, but it doesn't add or modify anything on the current award budget category's buildup items
                    }
                    else if (buildUpItemIterator.CurrentActiveAwardBudgetBuildup__c == 'Created') { //Adds copy of the proposed buildup item onto the amendment request budget category
                        BuildUpItem__c buildUpItemToInsert = new BuildUpItem__c();
                        buildUpItemToInsert.AmendmentRequestBudgetCategory__c = buildupARBC.Id;
                        buildUpItemToInsert.EquipmentDesc__c = buildUpItemIterator.EquipmentDesc__c;
                        buildUpItemToInsert.EquipmentQuantity__c = buildUpItemIterator.EquipmentQuantity__c;
                        buildUpItemToInsert.EquipmentUnitPrice__c = buildUpItemIterator.EquipmentUnitPrice__c;
                        buildUpItemToInsert.CurrentActiveAwardBudgetBuildup__c = 'Created';
                        historyBuildUpItems.add(buildUpItemToInsert);
                        //Creates the copy of the buildup items onto the history item, but it doesn't add or modify anything on the current award budget category's buildup items
                    }
                    //Make no modification to the current award budget category's build up item(s) as of right now
                }
                insert historyBuildUpItems;
    
    
                //Budget Revision amendment request (thus history item) created, now send it for approvals
                System.debug('Internal approval task creation');
                GNT.TaskCreationHandler.createApprovalProcessTasks(budgetRevision.Id, 'Budget Revision Internal Approval Request', currentAward.Name, null, System.TODAY() + 7, currentAward.Name, true); 
                System.debug('***Task successfully sent ***');
                if (currentAward.BudgetRevisionInitiatedByUSBE__c == 'Allocation Change') {
                    //retVal.put('Message', 'Revision successfully submitted for internal approval. Please note that this revision has been initiated by an allocation amount change and must go through both internal and USBE approval.');    
                    currentAward.PercentVarianceOverTen__c = true;
                    currentAward.CurrentBudgetRevisionId__c = budgetRevision.Id;
                    currentAward.BudgetRevisionInitiated__c = 'Submitted';
                    currentAward.CurrentRevisionStatus__c = 'Submitted for Internal Approval';
                    currentAward.WaiveAllocationStatus__c = 'N/A';
                    update currentAward;
                }
                else if (currentAward.BudgetRevisionInitiatedByUSBE__c == 'Indirect Change') {
                    //retVal.put('Message', 'Revision successfully submitted for internal approval. Please note that this revision has been initiated by an indirect cost change and must go through both internal and USBEapproval.');    
                    currentAward.PercentVarianceOverTen__c = true;
                    currentAward.CurrentBudgetRevisionId__c = budgetRevision.Id;
                    currentAward.BudgetRevisionInitiated__c = 'Submitted';
                    currentAward.CurrentRevisionStatus__c = 'Submitted for Internal Approval';
                    update currentAward;
                }
                else if (percentVarianceOverTen == true && equipmentTotalOver5k == true) {
                    //retVal.put('Message', 'Revision successfully submitted for internal approval. Please note that both internal and USBE approval is required if the percent variance of a budget category is greater than 10% and if the equipment category total has both changed and has exceeded $5000.');    
                    currentAward.PercentVarianceOverTen__c = true;
                    currentAward.CurrentBudgetRevisionId__c = budgetRevision.Id;
                    currentAward.BudgetRevisionInitiated__c = 'Submitted';
                    currentAward.CurrentRevisionStatus__c = 'Submitted for Internal Approval';
                    update currentAward;
                }
                else if (equipmentTotalOver5k == true) {
                    //retVal.put('Message', 'Revision successfully submitted for internal approval. Please note that both internal and USBE approval is required if the equipment category total has both changed and has exceeded $5000.');    
                    currentAward.PercentVarianceOverTen__c = true;
                    currentAward.CurrentBudgetRevisionId__c = budgetRevision.Id;
                    currentAward.BudgetRevisionInitiated__c = 'Submitted';
                    currentAward.CurrentRevisionStatus__c = 'Submitted for Internal Approval';
                    update currentAward;
                }
                else if (percentVarianceOverTen == true) { //If % variance is over 10, then it requires USBE approval
                    //System.debug('Internal and USBE approval task creation');
                    //GNT.TaskCreationHandler.createApprovalProcessTasks(budgetRevision.Id, 'Budget Revision Approval Request', budgetRevision.Name, null, System.TODAY() + 7, budgetRevision.AwardName__c, true);
                    //GNT.TaskCreationHandler.createApprovalProcessTasks(budgetRevision.Id, 'Budget Revision Approval Request', budgetRevision.Name, null, System.TODAY() + 7, budgetRevision.AwardName__c, true);
                    //System.debug('***Task successfully sent ***');
                    //retVal.put('Message', 'Revision successfully submitted for internal approval. Please note that both internal and USBE approval is required if the percent variance of a budget category is greater than 10%.');            
                    //Flag this as requiring USBE approval. If we return to this button and that flag is active do not create the amendment request again, send the amendment request over for USBE approval
                    //currentAward.ApprovedInternally__c = false; //Default is false
                    currentAward.PercentVarianceOverTen__c = true;
                    currentAward.CurrentBudgetRevisionId__c = budgetRevision.Id;
                    currentAward.BudgetRevisionInitiated__c = 'Submitted';
                    currentAward.CurrentRevisionStatus__c = 'Submitted for Internal Approval';
                    update currentAward;    
                }
                else {             
                    //retVal.put('Message', 'Revision successfully submitted for internal approval.');
                    currentAward.BudgetRevisionInitiated__c = 'Submitted';
                    currentAward.CurrentRevisionStatus__c = 'Submitted for Internal Approval';
                    update currentAward; 
                }
                //If revision initiated by allocation or indirect change or if revision was sent back for changes, need to close the task to complete budget revision
                List<Task> taskList = [
                    SELECT Id, Status, WhatId, GNT__TaskAction__c 
                    FROM Task 
                    WHERE WhatId =: currentAward.Id AND GNT__TaskAction__c = 'Complete Budget Revision']; //OwnerId =: currentAward.Approver__c AND 
                if(!taskList.isEmpty()){
                    System.debug('MANUALDEBUG >>> taskList: ' + taskList);
                    for(Task taskIterator: taskList){
                        taskIterator.Status='Completed';
                    }                   
                    update taskList;
                }
                  
                retVal.put('Message', 'Revision successfully submitted for internal approval.');         
                return retVal;
            }         
        }
        catch(ReviewerExistanceException e) {
            Database.rollback(savestate);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            retVal.put('Message', e.getMessage());
            return retVal;
        }
        catch(BudgetNarrativeException e) {
            Database.rollback(savestate);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            retVal.put('Message', e.getMessage());
            return retVal;
        }
        catch (ProposedBudgetNotEqualApprovedBudgetException e) {
            Database.rollback(savestate);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            retVal.put('Message', e.getMessage());
            return retVal;
        }
        catch (InternalApproverSameAsOwnerException e) {
            Database.rollback(savestate);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            retVal.put('Message', e.getMessage());
            return retVal;
        }

        
        catch(Exception e){
            Database.rollback(savestate);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            retVal.put('Message', e.getMessage());
            return retVal;
        }


        
        retVal.put('PageReference','/apex/awardview?id=' + recordId);
        retVal.put('Message','Budget revision successfully submitted');
        return retVal;
    }
}