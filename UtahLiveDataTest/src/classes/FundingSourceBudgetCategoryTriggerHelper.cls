global with sharing class FundingSourceBudgetCategoryTriggerHelper extends GNT.TriggerHelper {
    public override void processbeforeInsert() {
        for(FundingSourceBudgetCategory__c funsourcebudcat : (List<FundingSourceBudgetCategory__c>) Trigger.New){
         funsourcebudcat.RemainingAmount__c = funsourcebudcat.AllocatedAmount__c;
       } 
       GNT.NameTemplateTriggerHelper.beforeInsert(); 
    }
    public override void processAfterUpdate() {
        calculateAwardBudgetCategoryRemainingAmount();
    }
    public override void ProcessbeforeUpdate() {
        for(FundingSourceBudgetCategory__c funsourcebudcat : (List<FundingSourceBudgetCategory__c>) Trigger.New){
         FundingSourceBudgetCategory__c funsourcebudcatold = (FundingSourceBudgetCategory__c)trigger.oldmap.get(funsourcebudcat.id);
         if(funsourcebudcat.RemainingAmount__c == null){
            funsourcebudcat.RemainingAmount__c = 0;
         }
         Decimal delta = funsourcebudcat.AllocatedAmount__c -  funsourcebudcatold.AllocatedAmount__c;   
         funsourcebudcat.RemainingAmount__c += delta;
       }
    }
    public override void processbeforeDelete(){
        deletefundingsourcebudgetcategories();
    }
    
    private void deletefundingsourcebudgetcategories(){
        for(FundingSourceBudgetCategory__c funsourcebudcat : (List<FundingSourceBudgetCategory__c>) Trigger.Old){
            if(funsourcebudcat.TotalAmountAllocated__c != 0){
              // Added Error config on 04/21/2017 - Charan
                // funsourcebudcat.adderror('You cannot delete budget category if Awarded Amount is greater than 0:'+ funsourcebudcat.CategoryName__c);
                funsourcebudcat.adderror(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-19641')+' '+ funsourcebudcat.CategoryName__c);
            }
         
       } 
    }
    private void calculateAwardBudgetCategoryRemainingAmount() {
        //Fetch award budget category remaining amount in a map
       Map<id,Decimal> remainingAmountMap = new Map<id,Decimal>();  //key->award budget category record id or funding source id, value->remaining amount
       for(FundingSourceBudgetCategory__c funsourcebudcat : (List<FundingSourceBudgetCategory__c>) Trigger.New){
            if (funsourcebudcat.FundingSourceRecordType__c == 'External' && funsourcebudcat.AwardBudgetCategory__c != null) {
                remainingAmountMap.put(funsourcebudcat.AwardBudgetCategory__c, funsourcebudcat.RemainAmount__c);
            }
       }

       //Adjust the money left in the pool (award budget category or funding source)
       for(FundingSourceBudgetCategory__c funsourcebudcat : (List<FundingSourceBudgetCategory__c>) Trigger.New){
         if (funsourcebudcat.FundingSourceRecordType__c != 'External' || funsourcebudcat.AwardBudgetCategory__c == null) {
            continue;
         }
         
         FundingSourceBudgetCategory__c fundingsourcebudcatold = (FundingSourceBudgetCategory__c)trigger.oldmap.get(funsourcebudcat.id);
         Decimal deltaamount = funsourcebudcat.AllocatedAmount__c - fundingsourcebudcatold.AllocatedAmount__c;

         Decimal amountLeftInPool = remainingAmountMap.get(funsourcebudcat.AwardBudgetCategory__c);

         if(deltaamount > amountLeftInPool){
          // Added Error config on 04/21/2017 - Charan
           // funsourcebudcat.adderror('You are allocating more than Remaining amount for budget category: ' + funsourcebudcat.CategoryName__c);
            funsourcebudcat.adderror(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-80334')+' '+funsourcebudcat.CategoryName__c);
         }
         else{
            amountLeftInPool = amountLeftInPool - deltaamount;
            remainingAmountMap.put(funsourcebudcat.AwardBudgetCategory__c, amountLeftInPool);
         }
       }
       
       //perform update on award budget category line items
       List<AwardBudgetCategory__c> abcItemsToUpdate = new List<AwardBudgetCategory__c>();
       for (Id abcId : remainingAmountMap.keySet()) {
            abcItemsToUpdate.add(new AwardBudgetCategory__c(Id=abcId, RemainingAmount__c=remainingAmountMap.get(abcId)));
       }
       update abcItemsToUpdate;
    }
    
    

}