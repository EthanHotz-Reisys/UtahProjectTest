global class AnnouncementFundingAccountTriggerHelper extends GNT.TriggerHelper{
    
    global override void processAfterInsert() {
      updateFundedAmount(Trigger.New);  
    }

    public override void processAfterDelete() {
        updateFundedAmount(Trigger.old);
    }
    
  

    // Method to update Program Funded Amount based on Funding Accounts added to AnnouncementFundingAccount
      private void updateFundedAmount(List<AnnouncementFundingAccount__c> listAnnFA){

         Set<Id> annIds = new Set<Id>();
        Set<Id> fundingAccountIds = new Set<Id>();
        Decimal SumofFundingAccounts;
        // get all the accounts associated with the programs
        for(AnnouncementFundingAccount__c annFundAccount :listAnnFA){
            annIds.add(annFundAccount.announcement__c);
            fundingAccountIds.add(annFundAccount.FundingAccount__c);
        }       
       List<aggregateResult> results = [select Sum(FundingAccount__r.SumOfBudgetCategories__c) Total from AnnouncementFundingAccount__c where announcement__c in :annIds];

        for (AggregateResult ar : results)  
        SumofFundingAccounts=(Decimal)ar.get('Total');

        List<Announcement__c> annList = [Select Id, SetAsideAmount__c from Announcement__c where  Id In :annIds ];

        annList[0].SetAsideAmount__c=SumofFundingAccounts;

        update annList[0];
      }
}