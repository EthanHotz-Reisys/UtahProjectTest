global with sharing class DeleteAppBudgetCategoriesActionHandler extends GNT.FlexTableActionHandler{

  global override Map<String,Object> clickHandler(){
    Map<String,Object> resultMap = new Map<String,Object>();
    ID parentId = urlParams.get('parentid');   
    String parentObjName = parentId.getSObjectType().getDescribe().getName();
    parentObjName = GNT.AppUtils.removeNamespacePrefix(parentObjName);
      
     List<ApplicationBudgetCategory2__c> objs = new List<ApplicationBudgetCategory2__c>();
     if(selectedRecordIds != null && !selectedRecordIds.isEmpty()){
    
       for(Id recordId: selectedRecordIds){
         ApplicationBudgetCategory2__c obj = new ApplicationBudgetCategory2__c();
        if(parentObjName == 'Application__c'){
           obj.id = recordId;
           //obj.Award__c = parentId;
        }
         objs.add(obj);
       }
      delete(objs);
      
      if(parentObjName == 'Application__c'){
        //resultMap.put('Message','Budget Categories deleted succesfully.');
        resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-79709'));
      } 
      
     }else{
       //resultMap.put('Message','No records are selected.');
       resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-58429'));
     }
    
    return resultMap;  
  }
  
}