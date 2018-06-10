global with sharing class ProgramContactsActionHandler extends GNT.FlexTableActionHandler {
	global override Map<String,Object> clickHandler(){
		Map<String,Object> resultMap = new Map<String,Object>();
		 Id parentId = urlParams.get('parentid');     
		 
		 List<ProgramContacts__c> pgmcnts = new List<ProgramContacts__c>();
		 if(selectedRecordIds != null && !selectedRecordIds.isEmpty()){
		 	for(Id recordId: selectedRecordIds){
		 		ProgramContacts__c pgmcnt = new ProgramContacts__c();
		 		pgmcnt.Contact__c = recordId;
		 		pgmcnt.Program__c = parentId;
		 		
		 		pgmcnts.add(pgmcnt);
		 	}
			insert(pgmcnts);

			//resultMap.put('Message','Contacts added succesfully.');
			resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-40353'));
		 }else{
		 	//resultMap.put('Message','No records are selected.');
		 	resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-58429'));
		 }
		
		return resultMap;	
	}

}