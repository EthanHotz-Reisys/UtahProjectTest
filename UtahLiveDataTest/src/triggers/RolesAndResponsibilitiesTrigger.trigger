trigger RolesAndResponsibilitiesTrigger on RolesAndResponsibilities__c (after insert, after update, before insert, before update,before delete,after delete) {
    if (Trigger.isInsert) { System.debug('IsInsert: Trigger.New: ' + Trigger.New); }
    
    //List<RolesAndResponsibilities__c> rolesAndResp = new List<RolesAndResponsibilities__c>();
    List<RolesAndResponsibilities__c> rolesAndRespList = new List<RolesAndResponsibilities__c>();
    List<RolesAndResponsibilities__c> rolesAndRespListUSBE = new List<RolesAndResponsibilities__c>();
    Map<Id, Id> rolesAndRespIdMapProgramId = new Map<Id, Id>();   
    List<Program__c> programList;
    if(Trigger.isInsert){
        for(RolesAndResponsibilities__c roles : Trigger.new){
            if(roles.Program__c != null) {
                rolesAndRespIdMapProgramId.put(roles.Id, roles.Program__c); //Could have one transaction add multiple R&R onto a single program?
            }
            //rolesAndResp.add(roles);
        }
    }
    else{
        for(RolesAndResponsibilities__c role : Trigger.old){
            if(role.Program__c != null) {
                rolesAndRespIdMapProgramId.put(role.Id, role.Program__c);
            }
            //rolesAndResp.add(role);
        }
    }
    if (rolesAndRespIdMapProgramId.size() > 0) { 
        programList = [SELECT Id, OrganizationName__c FROM Program__c WHERE Id IN: rolesAndRespIdMapProgramId.values() AND OrganizationName__c = 'USBE'];
    }
    if (programList != null && programList.size() > 0) {
        new RolesAndRespTriggerHelperUSBE().process();
    }
    else {
        new RolesAndResponsibilitiesTriggerHelper().process();
    }
    
}