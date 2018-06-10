global with sharing class StrategicPlanServiceAreaActionHandler extends GNT.FlexTableActionHandler{

  global override Map<String,Object> clickHandler(){
    Map<String,Object> resultMap = new Map<String,Object>();
    ID parentId = urlParams.get('parentid');   
    String parentObjName = parentId.getSObjectType().getDescribe().getName();
    parentObjName = GNT.AppUtils.removeNamespacePrefix(parentObjName);
      
     List<StrategicPlanServiceArea__c> objs = new List<StrategicPlanServiceArea__c>();
     if(selectedRecordIds != null && !selectedRecordIds.isEmpty()){
       for(Id recordId: selectedRecordIds){
         StrategicPlanServiceArea__c obj = new StrategicPlanServiceArea__c();
        if(parentObjName == 'ServiceArea__c'){
           obj.StrategicPlan__c = recordId;
           obj.ServiceArea__c = parentId;
        }else if(parentObjName == 'StrategicPlan__c'){
           obj.ServiceArea__c = recordId;
           obj.StrategicPlan__c = parentId;
        }else if(parentObjName == 'Program__c'){
           obj.ServiceArea__c = recordId;
           obj.Program__c = parentId;
        }
         objs.add(obj);
       }
      insert(objs);
      
      if(parentObjName == 'ServiceArea__c'){
        //resultMap.put('Message','Strategic Plans added succesfully.');
        resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-87154'));
      } 
      if(parentObjName == 'StrategicPlan__c'){
        //resultMap.put('Message','Service Areas added succesfully.');
        resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-65684'));
      } 
     }else{
       //resultMap.put('Message','No records are selected.');
       resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-58429'));
     }
    
    return resultMap;  
  }
  
}