global with sharing class FundingAllocationPlanHelper extends GNT.FlexTableActionHandler{
    
    global FundingAllocationPlanHelper(){}

   Map<String,Object> resultMap = new Map<String,Object>(); 

    public override Map<String,Object> clickHandler(){
        Id recordId = urlParams.get('id');
        system.debug('--recordId--'+recordId);
      
        try{
             Announcement__c ann = [Select Id, Name,FundingPlanCreated__c,FundingAllocationStatus__c,SetAsideAmount__c, FormulaVariable1__c,FormulaVariable2__c,FormulaVariable3__c,DWVariable1__c,DWVariable2__c,DWVariable3__c from Announcement__c where id =: recordId Limit 1];

             system.debug('--ann--'+ann);
            List<PreApplication__c> preAppList = [Select Id, Name,AllocationPercentage__c,AmountAllocated__c,PreApplicationScore__c,FormulaVariable1__c,FormulaVariable2__c,FormulaVariable3__c from PreApplication__c where Announcement__c=:ann.Id];
            createFAP(ann,preAppList);
            system.debug('--preAppList--'+preAppList);

          /*  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Announcement published successfully.'));
            PageReference  pageref = Page.FundingAllocationPlan;
            pageref.getParameters().put('Id',recordId);
            pageref.setRedirect(true);*/

            ann.FundingPlanCreated__c=true;
            ann.FundingAllocationStatus__c='Created';
            update ann;
            // resultMap.put('Message','Funding Allocation Plan Created.');
            resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-78073'));
           // return pageref;   
        }
        catch(Exception e){
           // resultMap.put('Message','Error in creating Funding Allocation Plan ');
           resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-68008'));
           system.debug(e);
        }

          return resultMap;
    }
    
    // Method to calculate allocation amoutn based on the formula for the announcement
   private void createFAP(Announcement__c ann,List<PreApplication__c> preAppList)
    {

     Decimal totalFundValue=ann.SetAsideAmount__c;
     Decimal totalScore=0.0;
     for(PreApplication__c preapp : preAppList){
         preapp.PreApplicationScore__c=(ann.FormulaVariable1__c*ann.DWVariable1__c*preapp.FormulaVariable1__c)+(ann.FormulaVariable2__c*ann.DWVariable2__c*preapp.FormulaVariable2__c)+(ann.FormulaVariable3__c*ann.DWVariable3__c*preapp.FormulaVariable3__c);
        totalScore=totalScore+preapp.PreApplicationScore__c;
     }
  
    for(PreApplication__c preapp : preAppList){
        preapp.AllocationPercentage__c=(preapp.PreApplicationScore__c/totalScore)*100;
        preapp.AmountAllocated__c=preapp.AllocationPercentage__c*totalFundValue;
     }
    
    update preAppList;

    }
}