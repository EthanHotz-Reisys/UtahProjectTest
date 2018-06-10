global with sharing class StrategicPlanProgramsActionHandler extends GNT.FlexTableActionHandler{

	global override Map<String,Object> clickHandler(){
		Map<String,Object> resultMap = new Map<String,Object>();
		 Id parentId = urlParams.get('parentid');     
		 
		 List<StrategicPlanPrograms__c> pgms = new List<StrategicPlanPrograms__c>();
		 
		 System.debug(' >>>>>>>>>>>>'+selectedRecordIds );
		 
		 if(selectedRecordIds != null && !selectedRecordIds.isEmpty()){
		 	for(Id recordId: selectedRecordIds){
		 		StrategicPlanPrograms__c pgm = new StrategicPlanPrograms__c();
		 		pgm.Program__c = recordId;
		 		pgm.StrategicPlan__c = parentId;
		 		pgms.add(pgm);
		 	}
		 	
		 	System.debug('>>>>>>>>>'+pgms);
			insert(pgms);
			//resultMap.put('Message','Programs added succesfully.');
			resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-01077'));
		 }else{
		 	//resultMap.put('Message','No records are selected.');
		 	resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-58429'));
		 }
		
		return resultMap;	
	}
	
}