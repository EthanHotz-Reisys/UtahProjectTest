global with sharing class SubmitBudgetRevisionToGrantor extends GNT.FlexTableActionHandler{
    
    public class ReviewerExistanceException extends Exception {}
    public class BudgetNarrativeException extends Exception {}
    public class ProposedBudgetNotEqualApprovedBudgetException extends Exception {}

    
    global override Map<String,Object> clickHandler(){
        Savepoint savestate = Database.setSavepoint();
        Map<String,Object> retVal = new Map<String,Object>();
        String recordId = urlParams.get('id'); //Current award's Id
        
        try{
            Award__c currentAward = [SELECT Id, CreatedDate, CurrentApprovedBudgetSum__c, ProposedBudgetRevisionSum__c, BudgetRevisionInitiated__c, BudgetNarrativeRead__c, BudgetNarrativeWrite__c, Name, GrantAwardName__c, ApprovedInternally__c , PercentVarianceOverTen__c, CurrentBudgetRevisionId__c, Grant__r.InternalOrganization__c, BudgetRevisionInitiatedByUSBE__c, AwardedAmount__c, Approver__c  FROM Award__c WHERE Id =: recordId]; //Gets the current award, which submitted this budget revision
            System.debug('MANUALDEBUG >>> currentAward: ' + currentAward);
            DateTime revisionDate = DateTime.now();
            Boolean percentVarianceOverTen = false;
            Boolean equipmentTotalOver5k = false;
            
            /*
            //Need to have a written budget narrative in order to submit the revision
            if (currentAward.BudgetNarrativeWrite__c == '' || currentAward.BudgetNarrativeWrite__c == null) {
                throw new BudgetNarrativeException('In order to submit the budget revision, a budget narrative explaining and/or justifying the revision must be provided.');
            }
            //Approvers must be assigned in order to send for approver
            List<RolesAndResponsibilities__c> programRandR = new List<RolesAndResponsibilities__c>([
                SELECT Award__r.Id, BusinessRole__c, Name__c 
                FROM RolesAndResponsibilities__c 
                WHERE Award__r.Id =: recordId AND (BusinessRole__c =: 'Program Approver' OR BusinessRole__c =: 'Owner' OR BusinessRole__c =: 'Fiscal Approver' OR BusinessRole__c =: 'Legal Approver' OR BusinessRole__c =: 'Executive Approver') LIMIT 5]);
            if (programRandR.size() < 5) {
                throw new ReviewerExistanceException('In order to submit the budget revision for approval, you must have the Program Approver, Fiscal Approver, Legal Approver, Executive Approver, and Owner roles in the Roles tab'); 
            }
            else if (currentAward.Approver__c == null) {
                throw new ReviewerExistanceException('In order to submit the budget revision for approval, you must have an Internal Approver assigned to the award.'); 
            }
            //You cannot have the proposed budget not equal the current approved budget UNLESS USBE changed the allocation amount
            if (currentAward.BudgetRevisionInitiatedByUSBE__c == 'Allocation Change' && currentAward.ProposedBudgetRevisionSum__c != currentAward.AwardedAmount__c) {
                throw new ProposedBudgetNotEqualApprovedBudgetException('This revision has been initated by a USBE allocation amount change. You cannot submit a budget revision unless your proposed budget grand total is equal to the new allocated (awarded) amount.'); 
            }
            else if (currentAward.BudgetRevisionInitiatedByUSBE__c != 'Allocation Change' && currentAward.ProposedBudgetRevisionSum__c != currentAward.CurrentApprovedBudgetSum__c) {
                throw new ProposedBudgetNotEqualApprovedBudgetException('You cannot submit a revision if the proposed budget grand total does not equal the currently approved budget grand total');
            }
            */
            //We have already sent it for and got internal approval and it falls under the USBE approval validation
            if (currentAward.ApprovedInternally__c == true && currentAward.PercentVarianceOverTen__c == true) {
                //Send it off for USBE (external) approval
                AmendmentRequest__c budgetRevision = [SELECT Id, Name, AwardName__c FROM AmendmentRequest__c WHERE Id =: currentAward.CurrentBudgetRevisionId__c];
                GNT.TaskCreationHandler.createApprovalProcessTasks(budgetRevision.Id, 'Budget Revision Approval Request', budgetRevision.Name, null, System.TODAY() + 7, budgetRevision.AwardName__c, true);
                currentAward.CurrentRevisionStatus__c = 'Submitted to Grantor';
                update currentAward;
                retVal.put('Message','Budget revision successfully submitted for USBE approval');
                return retVal;
            }
        }
        /*
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
        */
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