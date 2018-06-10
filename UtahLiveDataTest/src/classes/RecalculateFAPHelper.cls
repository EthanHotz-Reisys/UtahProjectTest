global with sharing class RecalculateFAPHelper extends GNT.FlexTableActionHandler{
    
    global RecalculateFAPHelper(){}

   Map<String,Object> resultMap = new Map<String,Object>(); 

    public override Map<String,Object> clickHandler(){
        Id recordId = urlParams.get('id');
      
        try{
             Announcement__c ann = [Select Id, Name,FundingPlanCreated__c,FundingAllocationStatus__c,SetAsideAmount__c, FormulaVariable1__c,FormulaVariable2__c,FormulaVariable3__c,DWVariable1__c,DWVariable2__c,DWVariable3__c from Announcement__c where id =: recordId Limit 1];

             system.debug('--ann--'+ann);
            List<PreApplication__c> preAppList = [Select Id, Name,AllocationPercentage__c,AmountAllocated__c,PreApplicationScore__c,FormulaVariable1__c,FormulaVariable2__c,FormulaVariable3__c from PreApplication__c where Announcement__c=:ann.Id];
             system.debug('--preAppList--'+preAppList);
      
            Decimal totalPercent=0.0;

            for(PreApplication__c preApp : preAppList )
            {
            totalPercent = totalPercent+ preApp.AllocationPercentage__c;
            }
            
            if(totalPercent != 100.00){
             //resultMap.put('Message','Funding Allocation Percentage from all Pre-Application should be 100%.');
             resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-64480'));
              return resultMap;

            }
            else{
               updateFAP(ann,preAppList);
               //resultMap.put('Message','Funding Allocation Plan is updated.');
               resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-26243'));
                   return resultMap;
        
            }

        }
        catch(Exception e){
           //resultMap.put('Message','Error in updating Funding Allocation Plan ');
           resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-81037'));
           system.debug(e);
        }

          return resultMap;
    }
    
    // Method to calculate allocation amoutn based on the formula for the announcement
   global void updateFAP(Announcement__c ann,List<PreApplication__c> preAppList)
    {

     Decimal totalFundValue=ann.SetAsideAmount__c;
  
    for(PreApplication__c preapp : preAppList){
     //   preapp.AllocationPercentage__c=(preapp.PreApplicationScore__c/totalScore)*100;
        preapp.AmountAllocated__c=preapp.AllocationPercentage__c*totalFundValue;
     }
    
    update preAppList;

    }
}