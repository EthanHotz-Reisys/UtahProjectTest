global with sharing class AddPaymentRequestHandler extends GNT.FlexTableActionHandler {
   global override Map<String,Object> clickHandler(){
		Map<String,Object> resultMap = new Map<String,Object>();
		 Id parentId = urlParams.get('parentid');     
		 
		 List<DrawdownDetail__c> drawdowndetailslist = new List<DrawdownDetail__c>();
		 if(selectedRecordIds != null && !selectedRecordIds.isEmpty()){
		 	for(Id recordId: selectedRecordIds){
		 		DrawdownDetail__c drawdowndetail = new DrawdownDetail__c();
		 		drawdowndetail.PaymentRequest__c = recordId;
		 		drawdowndetail.Drawdown__c = parentId;
		 		drawdowndetailslist.add(drawdowndetail);
		 	}
			insert(drawdowndetailslist);		 	
			//resultMap.put('Message','Funding Accounts added succesfully.');
			resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-23183'));
		 }else{
		 	//resultMap.put('Message','No records are selected.');
		 	resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-58429'));
		 }
		
		return resultMap;	
	}
}