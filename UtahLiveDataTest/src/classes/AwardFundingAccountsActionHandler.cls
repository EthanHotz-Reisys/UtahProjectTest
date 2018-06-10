global with sharing class AwardFundingAccountsActionHandler extends GNT.FlexTableActionHandler {
   global override Map<String,Object> clickHandler(){
        Map<String,Object> resultMap = new Map<String,Object>();
         Id parentId = urlParams.get('awardId');     
         
         List<AwardFundingAccount__c> awdfundingaccnts = new List<AwardFundingAccount__c>();
         if(selectedRecordIds != null && !selectedRecordIds.isEmpty()){
            for(Id recordId: selectedRecordIds){
                AwardFundingAccount__c awdfndaccnt = new AwardFundingAccount__c();
                awdfndaccnt.FundingAccount__c = recordId;
                awdfndaccnt.Award__c = parentId;
                awdfundingaccnts.add(awdfndaccnt);
            }
            insert(awdfundingaccnts);           
            //resultMap.put('Message','Funding Accounts added succesfully.');
            resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-23183'));
         }else{
            // resultMap.put('Message','No records are selected.');
            resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-58429'));

         }
        
        return resultMap;   
    }
}