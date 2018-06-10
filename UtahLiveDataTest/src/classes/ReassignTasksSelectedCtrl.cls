global with sharing class ReassignTasksSelectedCtrl extends GNT.FlexTableActionHandler {
    
    global override Map<String,Object> clickHandler(){
         Map<String,object> resultMap = new Map<String,object>();
         system.debug('url Params'+urlParams);
         Id ownerId = urlParams.get('sourceUser');
         Id targetId = urlParams.get('targetUser');
         GNT__UserPreferences__c pref = GNT__UserPreferences__c.getValues(UserInfo.getUserId());
         String appName;
         if(pref != null){
            appName = pref.GNT__ActiveAppName__c;
         }else{
            pref = GNT__UserPreferences__c.getInstance();
            appName = pref.GNT__ActiveAppName__c;
         } 
         String query = 'select id,IsReassignmentInitiated__c from Task where ownerId=:ownerId and status in(\'Not Started\',\'In Progress\') AND GNT__CustomAppName__c =:appName and IsReassignmentInitiated__c = false ';         
         if(selectedRecordIds != null && selectedRecordIds.size()>0){
            query += 'and id in:selectedRecordIds'; 
         }else{
             resultMap.put('Error','No records to assign');
             return resultMap;
         }   
         List<Sobject> sobjs = database.query(query);
         system.debug('sobjs--->>>'+sobjs);
         if(sobjs.size() == 0){
            resultMap.put('Error','No records to assign');
         }
         Set<Id> ids = new Set<Id>();
         for(Sobject sobj : sobjs){
             sobj.put('IsReassignmentInitiated__c',true);
             ids.add(sobj.id);   
         }
         update sobjs;
         GNT.TaskReassignmentBatch batch = new GNT.TaskReassignmentBatch(ids,ownerId,targetId );
         database.executeBatch(batch);
         resultMap.put('Message', Label.TaskReassignmentNotification);
         String ns = AppUtils.getNamespacePrefix();
         return resultMap;
    }
}