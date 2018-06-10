/**
* Edit/Add page controller for the AwardFundingAccount__c object
* 
* CHANGE HISTORY
* =============================================================================
* Date          Name            Description
* 05/16/2014    Kunal Shah      Created
* =============================================================================
*/

public with sharing class AwardFundingAccountAddCtrl {
    //Shah 5/22/2015 Commenting out the below logic due to revised data model
    /*
    public Id awardId {get;set;}
    public Award__c awardInstance {get;set;}
    public List<AwardFundingAccountWrapper> lstAwardFundingAccountWrapper {get;set;}
    public AwardFundingAccount__c awardFundingAccount {get;set;}
    
    public AwardFundingAccountAddCtrl(){
        awardId = ApexPages.CurrentPage().getParameters().get('awardId');   
        awardInstance = [SELECT Grant__r.Program__c,Application__c,Application__r.Announcement__c,FiscalYear__c FROM Award__c WHERE Id = : awardId];
        lstAwardFundingAccountWrapper = new List<AwardFundingAccountWrapper>();
        List<Id> addedFundingAccounts = findAddedFundingAccounts();
        
        //IF THE AWARD IS CREATED FOR A PROGRAM, GET THE PROGRAM FUNDING ACCOUNTS
        if(awardInstance.Grant__r.Program__c != null){
            List<ProgramFundingAccount__c> progFundAcct = [SELECT FundingAccount__c FROM ProgramFundingAccount__c 
                                                            WHERE Program__c = : awardInstance.Grant__r.Program__c];
            List<Id> fundAcctIds = new List<Id>();
            for(ProgramFundingAccount__c pfa : progFundAcct){
                fundAcctIds.add(pfa.FundingAccount__c);
            }   
                                                        
            List<FundingAccountYear__c> fundingAcctYear = [SELECT Id,FundingAccount__r.Name,FundsAvailable__c,FundsAwardedByState__c,ObligationInProgress__c,TotalFunds__c,FiscalYear__c
                                                            FROM FundingAccountYear__c 
                                                            WHERE FundingAccount__c IN : fundAcctIds 
                                                            AND FiscalYear__c = : awardInstance.FiscalYear__c
                                                            AND Id NOT IN : addedFundingAccounts];
                                                            
            for(FundingAccountYear__c fay: fundingAcctYear){
                lstAwardFundingAccountWrapper.add(new AwardFundingAccountWrapper(fay));     
            }                                               
        }
        //IF THE AWARD IS CREATED FOR AN APPLICATION, GET THE ANNOUNCEMENT FUNDING ACCOUNTS
        else{
            List<AnnouncementFundingAccount__c> annFundAcct = [SELECT FundingAccountYear__c FROM AnnouncementFundingAccount__c 
                                                                WHERE Announcement__c = : awardInstance.Application__r.Announcement__c];
            List<Id> fundAcctIds = new List<Id>();
            for(AnnouncementFundingAccount__c afa : annFundAcct){
                fundAcctIds.add(afa.FundingAccountYear__c);
            }   
            List<FundingAccountYear__c> fundingAcctYear = [SELECT Id,FundingAccount__r.Name,FundsAvailable__c,FundsAwardedByState__c,ObligationInProgress__c,TotalFunds__c,FiscalYear__c 
                                                            FROM FundingAccountYear__c 
                                                            WHERE ID IN : fundAcctIds 
                                                            AND FiscalYear__c = : awardInstance.FiscalYear__c
                                                            AND Id NOT IN :addedFundingAccounts];       
            for(FundingAccountYear__c fay: fundingAcctYear){
                lstAwardFundingAccountWrapper.add(new AwardFundingAccountWrapper(fay));     
            }                           
        }
    }
    
    public void addFundingAccount(){
        try{
            List<AwardFundingAccount__c> lstAwardFundingAccounts = new List<AwardFundingAccount__c>();
            for(AwardFundingAccountWrapper afa: lstAwardFundingAccountWrapper) {
                if(afa.selected == true) {
                    AwardFundingAccount__c awardFundingAccount = new AwardFundingAccount__c();
                    awardFundingAccount.Award__c = awardId;
                    awardFundingAccount.FundingAccountYear__c = afa.fundAccYear.Id;
                    awardFundingAccount.FinancialAssistanceAmount__c = afa.financialAmount;
                    lstAwardFundingAccounts.add(awardFundingAccount);
                }   
            } 
            if(Schema.sObjectType.AwardFundingAccount__c.isCreateable()){
                insert lstAwardFundingAccounts;
            }
        }catch (Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, e.getMessage());
            ApexPages.addMessage(myMsg);
        }
    }
    
    public List<Id> findAddedFundingAccounts(){
        List<Id> faIds = new List<Id>();
        for(AwardFundingAccount__c afa: [SELECT FundingAccountYear__c FROM AwardFundingAccount__c WHERE Award__c =: awardId]){
            faIds.add(afa.FundingAccountYear__c);
        }
        return faIds;
    }
    
    private class AwardFundingAccountWrapper{
        public FundingAccountYear__c fundAccYear {get;set;}
        public Boolean selected {get;set;}
        public decimal financialAmount {get;set;}
        
        public AwardFundingAccountWrapper(FundingAccountYear__c fay){
            fundAccYear = fay; 
            selected = false;   
        }   
    }
    */
}