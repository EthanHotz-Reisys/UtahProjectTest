global with sharing class DeleteBudgetCategoriesActionHandler extends GNT.FlexTableActionHandler{

  global override Map<String,Object> clickHandler(){
    Map<String,Object> resultMap = new Map<String,Object>();
    ID parentId = urlParams.get('parentid');   
    String parentObjName = parentId.getSObjectType().getDescribe().getName();
    parentObjName = GNT.AppUtils.removeNamespacePrefix(parentObjName);
      
     List<AwardBudgetCategory__c> objs = new List<AwardBudgetCategory__c>();
     if(selectedRecordIds != null && !selectedRecordIds.isEmpty()){
    
       for(Id recordId: selectedRecordIds){
         AwardBudgetCategory__c obj = new AwardBudgetCategory__c();
        if(parentObjName == 'Award__c'){
           obj.id = recordId;
           //obj.Award__c = parentId;
        }
         objs.add(obj);
       }
      delete(objs);
      
      if(parentObjName == 'Award__c'){
        resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-79709'));
        //resultMap.put('Message','Budget Categories deleted succesfully.');
      } 
      
     }else{
       resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-58429'));
       //resultMap.put('Message','No records are selected.');
     }
    
    return resultMap;  
  }
  
}