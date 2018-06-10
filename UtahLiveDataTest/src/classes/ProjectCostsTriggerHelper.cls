/*
    All code for Trigger on ProjectCostByFundingSource__c  Object
    ***********************************************************
    Audit History
    ***********************************************************
    Apr-11-2017      Davinder Singh         Created
    *********************************************************** 
*/
global with sharing class ProjectCostsTriggerHelper extends GNT.TriggerHelper {
    global override void processBeforeInsert() {
        populateZeroValues();
        validateName();
    }
           
    global override void processBeforeUpdate() {
        populateZeroValues();
        validateName();
    }
         
    private void populateZeroValues(){
        List<ProjectCostByFundingSource__c> projectCosts = (List<ProjectCostByFundingSource__c>)Trigger.new;
        for(ProjectCostByFundingSource__c pfs : projectCosts){
            if(pfs.SecuredAmount__c == null){
                pfs.SecuredAmount__c = 0;
            }
            if(pfs.UnsecuredAmount__c == null){
                pfs.UnsecuredAmount__c = 0;
            }
        }        
    }

    private void validateName(){
        List<ProjectCostByFundingSource__c> projectCosts = (List<ProjectCostByFundingSource__c>)Trigger.new;
        Profile p = [Select Name from Profile where Id = :UserInfo.getProfileId()];
        for(ProjectCostByFundingSource__c pfs : projectCosts){
            if(pfs.Name == null){
                if(p.Name != 'SPI' && p.Name != 'SPA' && p.Name != 'SME'){    
                    pfs.addError('Please input Financial Source');
                }else{
                    pfs.addError('Please input Project Cost Name');
                }
            }
        }
    }
}