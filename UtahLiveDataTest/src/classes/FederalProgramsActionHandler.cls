global with sharing class FederalProgramsActionHandler extends GNT.FlexTableActionHandler {
  global override Map<String,Object> clickHandler(){
    Map<String,Object> resultMap = new Map<String,Object>();
     Id parentId = urlParams.get('parentid');     
     String FedPrograms = urlParams.get('type');
     List<JXPrograms__c> fedpgms = new List<JXPrograms__c>();
     if(selectedRecordIds != null && !selectedRecordIds.isEmpty()){
       for(Id recordId: selectedRecordIds){
         JXPrograms__c fedpgm = new JXPrograms__c();
         fedpgm.FederalProgram__c = recordId;
         fedpgm.StateProgram__c = parentId;
         fedpgms.add(fedpgm);
       }
      insert(fedpgms);
      PageReference pageRef = new PageReference('/apex/SelectRecordsPopUp?parentid='+parentId+'&flextable=SelectFederalPrograms&type='+FedPrograms); 
      pageRef.getParameters().put('id',parentId);
     // resultMap.put('PageReference',pageRef);       
      //resultMap.put('Message','Federal Programs added succesfully.');
      resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-88469'));
     }else{
       //resultMap.put('Message','No records are selected.');
       resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-58429'));
     }
    
    return resultMap;  
  }

}