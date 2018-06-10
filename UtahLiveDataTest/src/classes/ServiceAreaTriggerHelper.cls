/*
  <Purpose of this class>    
    *******************************************************************************************************************
    Audit History
    ********************************************************************************************************************
    2017-04-01  Shah Kadirmohideen  Code Reviewed
    **********************************************************************************************************************  
*/ 
global without sharing class ServiceAreaTriggerHelper extends GNT.TriggerHelper{
    public static boolean skipTrigger = false;
    global override void processBeforeDelete() {
     if (skipTrigger == false){
        Set<Id> serviceAreaIds = Trigger.oldMap.keySet();
        List<ProgramServiceArea__c> psas = [SELECT ServiceArea__c FROM ProgramServiceArea__c WHERE ServiceArea__c IN: serviceAreaIds];
        List<ApplicationServiceArea__c> appsas = [SELECT ServiceAreaLookup__c FROM ApplicationServiceArea__c WHERE ServiceAreaLookup__c IN: serviceAreaIds];
        List<AnnouncementServiceArea__c> annsas = [SELECT ServiceArea__c FROM AnnouncementServiceArea__c WHERE ServiceArea__c IN: serviceAreaIds];
        List<AwardServiceArea__c> asas = [SELECT ServiceArea__c FROM AwardServiceArea__c WHERE ServiceArea__c IN: serviceAreaIds];

        Set<Id> ids = new Set<Id>();
        for(ProgramServiceArea__c sa: psas) {
            ids.add(sa.ServiceArea__c);
        }
        for(ApplicationServiceArea__c sa: appsas) {
            ids.add(sa.ServiceAreaLookup__c);
        }
        for(AnnouncementServiceArea__c sa: annsas) {
            ids.add(sa.ServiceArea__c);
        }
        for(AwardServiceArea__c sa: asas) {
            ids.add(sa.ServiceArea__c);
        }

        for(ServiceArea__c sa: (List<ServiceArea__c>)Trigger.old) {
            if(ids.contains(sa.Id)) {
                //sa.AddError('This service area is currently being used and cannot be deleted.');
                sa.addError(GNT.ErrorMessageHelper.fetchMessage('P17-GRNTE-45093'));
            }
        }
      }
    }
    global override void processAfterInsert() {
        if (skipTrigger == false){
           insertOwnerinRolesandResp();
         }
        }
    /* Insert owner of Service Area in Roles and Responsibility*/
   private void insertOwnerinRolesandResp(){
        List<RolesAndResponsibilities__c> listrolesandresp = new List<RolesAndResponsibilities__c>();
        List<RecordType> recordTypeList = [select Id, Name,DeveloperName,SobjectType FROM RecordType where SobjectType=:AppUtils.getNamespacePrefix()+'RolesAndResponsibilities__c' and DeveloperName='StrategicPlan'];
         for(ServiceArea__c servicearea : (List<ServiceArea__c>) Trigger.New) {
            RolesAndResponsibilities__c rresp = new RolesAndResponsibilities__c();
            rresp.ServiceArea__c = servicearea.id;
            rresp.Name__c = servicearea.CreatedById;
            //rresp.Role__c = 'Other';
            rresp.BusinessRole__c= 'Owner';
            rresp.recordTypeId = recordTypeList[0].Id;
            listrolesandresp.add(rresp);
        }
        if(!listrolesandresp.isempty()) insert listrolesandresp;
    }
}