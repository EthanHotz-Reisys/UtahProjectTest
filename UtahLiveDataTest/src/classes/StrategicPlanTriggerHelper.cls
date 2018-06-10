/*
    This class has methods to execute methods related to StrategicPlan Trigger
    **********************************************************
    Audit History
    **********************************************************
    2014-05-19  Ramu Loke       Created
    **********************************************************  
*/

public with sharing class StrategicPlanTriggerHelper extends GNT.TriggerHelper {
    public static boolean skipTrigger = false;
      public override void processAfterInsert() {
            if(!skipTrigger) {
               insertOwnerinRolesandResp();
            }
        }
      
      /* Insert owner of Strategic Plan in Roles and Responsibility*/
      private void insertOwnerinRolesandResp(){
        List<RolesAndResponsibilities__c> listrolesandresp = new List<RolesAndResponsibilities__c>();
        List<RecordType> recordTypeList = [select Id, Name,DeveloperName, SobjectType FROM RecordType where SobjectType=:AppUtils.getNamespacePrefix()+'RolesAndResponsibilities__c' and DeveloperName='StrategicPlan'];
         for(StrategicPlan__c strategicplan : (List<StrategicPlan__c>) Trigger.New) {
            RolesAndResponsibilities__c rresp = new RolesAndResponsibilities__c();
            rresp.StrategicPlan__c = strategicplan.id;
            rresp.Name__c = strategicplan.CreatedById;
            //rresp.Role__c = 'Other';
            rresp.BusinessRole__c = 'Owner';
            rresp.recordTypeId = recordTypeList[0].Id;
            listrolesandresp.add(rresp);
        }
        if(!listrolesandresp.isempty()) insert listrolesandresp;
    }
        
}