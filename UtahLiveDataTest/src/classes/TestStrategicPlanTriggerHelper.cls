@isTest
private class TestStrategicPlanTriggerHelper{
   
      static testMethod void testTrigger() {  
          UserTriggerHelper.skipTrigger=true;
          User u = TestHelper.getAdminUser(true); 
          Account acct = null;
          
          System.runAs(u){
            
             AccountTriggerHelper.skipAll = true;
             RolesAndResponsibilitiesTriggerHelper.skipTrigger = true;
             GNT__KeyValueStore__c key= new GNT__KeyValueStore__c(Name='ENTERPRISE',GNT__BooleanValue__c=true);
             
             acct = TestHelper.getAccount(true);
             Program__c prog1= TestHelper.getProgram(acct.Id,true);
             List<RolesAndResponsibilities__c> rolesAndResp = new List<RolesAndResponsibilities__c>();          
             RolesAndResponsibilities__c rolesAndResponsibilities2 = new RolesAndResponsibilities__c(Program__c = prog1.Id,
                                                                            BusinessRole__c='Key POC',Name__c = prog1.ProgramApprover__c);  
             RolesAndResponsibilities__c rolesAndResponsibilities3 = new RolesAndResponsibilities__c(Program__c = prog1.Id,
                                                                            BusinessRole__c='Program Approver',Name__c = prog1.ProgramApprover__c);

            rolesAndResp.add(rolesAndResponsibilities2);
            rolesAndResp.add(rolesAndResponsibilities3);
            insert rolesAndResp;
            StrategicPlan__c stratPlan = TestHelper.getStrategicPlan(true);
             
            
        }
    
   }
   
}