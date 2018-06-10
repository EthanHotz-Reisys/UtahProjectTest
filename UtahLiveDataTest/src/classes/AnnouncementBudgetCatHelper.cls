global with sharing class AnnouncementBudgetCatHelper extends GNT.FlexTableActionHandler{
    global AnnouncementBudgetCatHelper() {}
    Map<String,Object> resultMap = new Map<String,Object>(); 

    public override Map<String,Object> clickHandler(){
       if(selectedRecordIds==null || selectedRecordIds.isEmpty()){
         resultMap.put('Message','No Records have been selected');
          return resultMap;
        }  
          
      try {         
        List<FundingOpportunityBudgetCategory__c> annBCList = [Select Id, Name from FundingOpportunityBudgetCategory__c where Id IN: selectedRecordIds ];
        Delete annBCList;        
        //resultMap.put('Message','Selected Records have been deleted');
        resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-28211'));
        return resultMap;       
        }
        catch(Exception exc){
         //resultMap.put('Message','An Error was encountered while processing the request');
         resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-92093'));
         System.debug(exc);
         return resultMap;
        }
       return null; 
      }
  }