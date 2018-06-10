global with sharing class FundingAccntBudgetCategoryTriggerHelper extends GNT.TriggerHelper{
    public override void processAfterUpdate() {
        calculateFundingSourceBudgetCategoryRemainingAmount();
    }
    
    
    private void calculateFundingSourceBudgetCategoryRemainingAmount() {
        //Fetch FundingSource budget category remaining amount in a map
       Map<id,Decimal> remainingAmountMap = new Map<id,Decimal>();  //key->FundingSource budget category record id, value->remaining amount
       for(FundingAccountBudgetCategory__c funaccountbudcat : (List<FundingAccountBudgetCategory__c>) Trigger.New){
            remainingAmountMap.put(funaccountbudcat.FundingSourceBudgetCategory__c, funaccountbudcat.RemainingAmount__c);
       }

       //Adjust the money left in the pool (fundingsource budget category)
       for(FundingAccountBudgetCategory__c funaccountbudcat : (List<FundingAccountBudgetCategory__c>) Trigger.New){
         FundingAccountBudgetCategory__c fundingaccountbudcatold = (FundingAccountBudgetCategory__c)trigger.oldmap.get(funaccountbudcat.id);
         Decimal deltaamount = funaccountbudcat.Amount__c - fundingaccountbudcatold.Amount__c;
         Decimal amountLeftInPool = remainingAmountMap.get(funaccountbudcat.FundingSourceBudgetCategory__c);

         if(deltaamount > amountLeftInPool){
          // Added Error config on 04/21/2017 - Charan
           // funaccountbudcat.adderror('You are allocating more than Remaining amount for budget category: ' + funaccountbudcat.CategoryName__c);
           funaccountbudcat.adderror(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-80334')+' ' + funaccountbudcat.CategoryName__c);
         }
         
            amountLeftInPool = amountLeftInPool - deltaamount;
            remainingAmountMap.put(funaccountbudcat.FundingSourceBudgetCategory__c, amountLeftInPool);
        
       }
       
       //perform update on award budget category line items
       List<FundingSourceBudgetCategory__c> fbcItemsToUpdate = new List<FundingSourceBudgetCategory__c>();
       for (Id fbcId : remainingAmountMap.keySet()) {
            if(fbcId!=null){
            fbcItemsToUpdate.add(new FundingSourceBudgetCategory__c(Id=fbcId, RemainingAmount__c=remainingAmountMap.get(fbcId)));
            }
       }
       if(!fbcItemsToUpdate.isEmpty()) update fbcItemsToUpdate;
    }    
}