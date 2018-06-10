global with sharing class ProgramBudgetCategoryActionHandler extends GNT.FlexTableActionHandler {
   global override Map<String,Object> clickHandler(){
        Map<String,Object> resultMap = new Map<String,Object>();
         Id parentId = urlParams.get('parentid');     
         
         List<ProgramBudgetCategory__c> pgmBCs= new List<ProgramBudgetCategory__c>();
         if(selectedRecordIds != null && !selectedRecordIds.isEmpty()){
            for(Id recordId: selectedRecordIds){
                ProgramBudgetCategory__c progBC= new ProgramBudgetCategory__c();
                progBC.BudgetCategory__c = recordId;
                progBC.Program__c = parentId;
                pgmBCs.add(progBC);
            }
            insert(pgmBCs);           
            //resultMap.put('Message','Budget Category added succesfully.');
            resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-31176'));
         }else{
            //resultMap.put('Message','No records are selected.');
            resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-58429'));
         }
        
        return resultMap;   
    }
}