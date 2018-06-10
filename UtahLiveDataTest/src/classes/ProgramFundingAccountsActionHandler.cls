global with sharing class ProgramFundingAccountsActionHandler extends GNT.FlexTableActionHandler {
   global override Map<String,Object> clickHandler(){
        Map<String,Object> resultMap = new Map<String,Object>();
         Id parentId = urlParams.get('parentid');     
         
         List<ProgramFundingAccount__c> pgmfundingaccnts = new List<ProgramFundingAccount__c>();
         if(selectedRecordIds != null && !selectedRecordIds.isEmpty()){
            for(Id recordId: selectedRecordIds){
                ProgramFundingAccount__c pgmfndaccnt = new ProgramFundingAccount__c();
                pgmfndaccnt.FundingAccount__c = recordId;
                pgmfndaccnt.Program__c = parentId;
                pgmfundingaccnts.add(pgmfndaccnt);
            }
            insert(pgmfundingaccnts);           
            //resultMap.put('Message','Funding Accounts added succesfully.');
            resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-23183'));
         }else{
            //resultMap.put('Message','No records are selected.');
            resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-58429'));
         }
        
        return resultMap;   
    }
}