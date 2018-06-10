global with sharing class CancelBudgetRevisionUSBE extends GNT.FlexTableActionHandler{
    
    public class NoCancelNonLeaInitiatedRevisionException extends Exception {}  
      
    global override Map<String,Object> clickHandler(){
        Savepoint savestate = Database.setSavepoint();
        Map<String,Object> retVal = new Map<String,Object>();
        String recordId = urlParams.get('id'); //Current award's Id
        
        
        try{
            Award__c currentAward = [SELECT Id, CreatedDate, CurrentApprovedBudgetSum__c, ProposedBudgetRevisionSum__c, BudgetRevisionInitiated__c, BudgetNarrativeRead__c, BudgetNarrativeWrite__c, Name, GrantAwardName__c, ApprovedInternally__c , PercentVarianceOverTen__c, CurrentBudgetRevisionId__c, Grant__r.InternalOrganization__c, ProgramBudgetTypeUSBE__c, BudgetRevisionInitiatedByUSBE__c FROM Award__c WHERE Id =: recordId]; //Gets the current award, which submitted this budget revision
            System.debug('MANUALDEBUG >>> currentAward: ' + currentAward);
            
            //Can only cancel revision if the revision was initiated by LEA
            //if (currentAward.BudgetRevisionInitiatedByUSBE__c == 'Not Initiated By USBE')
            if (currentAward.BudgetRevisionInitiatedByUSBE__c != 'Allocation Change' && currentAward.BudgetRevisionInitiatedByUSBE__c  != 'Indirect Change') {
                //List<AwardBudgetCategory__c> awardBudgetCategoryList = new List<AwardBudgetCategory__c>();
                List<BuildUpItem__c> buildUpItemList = new List<BuildUpItem__c>();
                //List<Award__c> awardList = new List<Award__c>();
                                   
                List<AwardBudgetCategory__c> awardBudgetCategories = new List<AwardBudgetCategory__c>([
                    SELECT Id, Award__c, BudgetCategory__c, CurrentApprovedBudgetAmount__c, ProposedBudgetRevision__c, PercentVariance__c, PercentVarianceText__c, RowNumberFormula__c, AdminCostValue__c 
                    FROM AwardBudgetCategory__c 
                    WHERE Award__c =: recordId AND RowNumberFormula__c != null]);
                for (AwardBudgetCategory__c abcIterator : awardBudgetCategories) { //For (all the award budget categories in the award)
                    //Modifications made to award budget category:
                    // abcIterator.CurrentApprovedBudgetAmount__c = abcIterator.ProposedBudgetRevision__c; //
                    abcIterator.ProposedBudgetRevision__c = abcIterator.CurrentApprovedBudgetAmount__c;  //Default proposed budget gets set to equal the value of the currently active budget (reset the value to pre-revision)
                    //abcIterator.PercentVariancePrevious__c = abcIterator.PercentVarianceText__c; //We're keeping the old percent variance value(s)
                    //abcIterator.PercentVarianceText__c = abcIterator.PercentVariancePrevious__c;
                    //awardBudgetCategoryList.add(abcIterator);
                    if (currentAward.ProgramBudgetTypeUSBE__c == 'CTE') {
                        abcIterator.AdminCostValueProposed__c = abcIterator.AdminCostValue__c;
                    }
                }
                          
                //Reset the buildup items in the AwardBudgetCategory 570           
                List<BuildUpItem__c> currentBuildUpItems = new List<BuildUpItem__c>([
                    SELECT Id, AwardBudgetCategory__c, AwardBudgetCategory__r.Award__c, AwardBudgetCategory__r.BudgetCategory__r.RowNumber__c, CurrentActiveAwardBudgetBuildup__c, EquipmentDesc__c, EquipmentQuantity__c, EquipmentUnitPrice__c  
                    FROM BuildUpItem__c 
                    WHERE AwardBudgetCategory__r.Award__c =: recordId AND AwardBudgetCategory__r.BudgetCategory__r.RowNumber__c = '570']); 
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
                        //currentBuildUpItems.add(activeBuildUpItem);
                        buildUpItemList.add(activeBuildUpItem);
                    }
                    else if (buildUpItemIterator.CurrentActiveAwardBudgetBuildup__c == 'Created') { //
                        //Remove all 'created' buildup items and replace them with the old 'active' buildup items (revert to pre-revision) for reference use if the next revision is rejected
                        buildUpItemIterator.CurrentActiveAwardBudgetBuildup__c = 'Revised';
                        buildUpItemList.add(buildUpItemIterator);      
                    }      
                }
                
                //Reset award
                currentAward.BudgetNarrativeWrite__c = '';
                currentAward.BudgetRevisionInitiated__c = 'Not Started';
                currentAward.CurrentRevisionStatus__c = 'Not Started';
                currentAward.ApprovedInternally__c = false;
                currentAward.PercentVarianceOverTen__c = false;
                currentAward.CurrentBudgetRevisionId__c = null;
                currentAward.BudgetRevisionInitiatedByUSBE__c = 'Not Initiated By USBE'; //REMOVE WHEN IN NOT IN DEMO MODE. YOU CANNOT CANCEL A USBE INITIATED REVISION
                //awardList.add(currentAward);
                           
                GrantTriggerHelper.skipTrigger = true;
                AwardBudgetCategoryTriggerHelper.skipTrigger = true;
                USBEAwardTriggerHelper.skipTriggers = true;
                USBEAwardTriggerHelper.skipTrigger = true;
                USBEAwardTriggerHelper.skipfromAmendment = true;
                update awardBudgetCategories;
                upsert buildUpItemList;
                update currentAward;
                GrantTriggerHelper.skipTrigger = false;
                AwardBudgetCategoryTriggerHelper.skipTrigger = false;
                USBEAwardTriggerHelper.skipTriggers = false;  
                USBEAwardTriggerHelper.skipTrigger = false;
                USBEAwardTriggerHelper.skipfromAmendment = false;
            }
            else {
                throw new NoCancelNonLeaInitiatedRevisionException('A revision that is not LEA initiated cannot be canceled');
            }            
        }
        catch (NoCancelNonLeaInitiatedRevisionException  e) {
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
        retVal.put('Message','Budget revision successfully canceled');
        return retVal;
    }
}