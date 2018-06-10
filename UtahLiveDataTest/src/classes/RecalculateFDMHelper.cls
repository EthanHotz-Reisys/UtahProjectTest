global with sharing class RecalculateFDMHelper extends GNT.FlexTableActionHandler{
    
    global RecalculateFDMHelper(){}

   Map<String,Object> resultMap = new Map<String,Object>(); 

    public override Map<String,Object> clickHandler(){
        Id recordId = urlParams.get('id');
        // Need to recalculate Recommended amount based on Obligated Amount and allocation percentage
        try{
            
            ReviewStep__c reviewStep= [SELECT Id,Name, ReviewGroup__r.Announcement__r.ObligatedAmount__c FROM ReviewStep__c WHERE Id =: recordId LIMIT 1];
            List<ReviewStepApplication__c> rsaList = [Select Id, AllocationPercentage__c,AmountThisAction__c from ReviewStepApplication__c where ReviewStep__c =: recordId and Decision__c!='Rejected' and Application__r.AwardDecisionStatus__c=''];
            Decimal totalAmount=0.0;
            for(ReviewStepApplication__c rsa: rsaList )
            {
            if(rsa.AmountThisAction__c!=null)
            totalAmount = totalAmount+ rsa.AmountThisAction__c;
            }
            if(totalAmount > reviewStep.ReviewGroup__r.Announcement__r.ObligatedAmount__c){
             //resultMap.put('Message','Funding Allocation Percentage from all Applications can not exceed Set-Aside Amount');
           //  resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-61352'));
              return resultMap;
            }
            else{
               updateFDM(reviewStep,rsaList);
               //resultMap.put('Message','Funding Allocation is updated.');
                resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-26243'));
               return resultMap;
            }
        }
        catch(Exception e){
           //resultMap.put('Message','Error in updating Allocation, Sum of Awarded Amount for all Recommended Applications can not exceed 100% of Set-Aside Amount');
          // resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-72081'));
           system.debug('--Error in updating Allocation--'+e);
        }

          return resultMap;
    }
    
    // Method to calculate allocation amount based on the formula for the announcement
   private void updateFDM(ReviewStep__c reviewStep,List<ReviewStepApplication__c> rsaList){
    System.debug('Here--------------------');
    Decimal totalFundValue=reviewStep.ReviewGroup__r.Announcement__r.ObligatedAmount__c;
    for(ReviewStepApplication__c rsa: rsaList){
      rsa.AllocationPercentage__c =(rsa.AmountThisAction__c/totalFundValue)*100;
    }
    ReviewStepApplicationTriggerHelper.skipTrigger=True;
    update rsaList;
    ReviewStepApplicationTriggerHelper.skipTrigger=False;

    }
}