global with sharing class PaymentFINETProgramActionHandler extends GNT.FlexTableActionHandler {
   global override Map<String,Object> clickHandler(){
        Map<String,Object> resultMap = new Map<String,Object>();
         Id parentId = urlParams.get('payId');     
         
         List<PaymentFINETCode__c> payfinetprgs = new List<PaymentFINETCode__c>();
         if(selectedRecordIds != null && !selectedRecordIds.isEmpty()){
            for(Id recordId: selectedRecordIds){
                PaymentFINETCode__c payfinetprg = new PaymentFINETCode__c();
                //payfinetprg.ProgramCode__c = recordId;
                payfinetprg.PaymentRequest__c = parentId;
                payfinetprgs.add(payfinetprg);
            }
            insert(payfinetprgs);
            resultMap.put('Message','FINET Programs added successfully');
         }else{
            // resultMap.put('Message','No records are selected.');
            resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-58429'));

         }
        
        return resultMap;   
    }
}