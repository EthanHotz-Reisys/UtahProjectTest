@isTest
private class TestStagingLeadsToLeadsBatch{

    static testMethod void myUnitTest() {
        /*
        User u = TestHelper.getAdminUser(true);
        STGFOALead__c stgfoLead = null;
        FOALead__c foaLead = null;
        
        system.runAs(u) {
            // skip unwanted triggers
            AccountTriggerHelper.skipAll = true;
            ContactTriggerHelper.skiptrigger = true;
            UserRegistrationTriggerHelper.skipTrigger = true;
            UserTriggerHelper.skipTrigger = true;
            
            stgfoLead = new STGFOALead__c(FundingOpportunityNumber__c = 'Test - 123',CFDANumber__c='12.300');
            insert stgfoLead;
            
            foaLead = TestHelper.getFOALead(true);
            GNT.KeyValueStoreHelper.setTextValue('IntegrationSupportEmailAddress','abc@gmail',true);
            Test.startTest();
         
            StagingLeadsToLeadsBatch ctrl= new StagingLeadsToLeadsBatch();
            Database.executeBatch(ctrl);

            Test.stopTest();
        }
    */
    }
    
    static testMethod void myUnitTest2() {
        /*
        User u = TestHelper.getAdminUser(true);
        STGFOALead__c stgfoLead = null;
        FOALead__c foaLead = null;
        
        system.runAs(u) {
            // skip unwanted triggers
            AccountTriggerHelper.skipAll = true;
            ContactTriggerHelper.skiptrigger = true;
            UserRegistrationTriggerHelper.skipTrigger = true;
            UserTriggerHelper.skipTrigger = true;
            
            stgfoLead = new STGFOALead__c(FundingOpportunityNumber__c = 'Test - 123',CFDANumber__c='12.300');
            insert stgfoLead;
            
            foaLead = TestHelper.getFOALead(true);
            foaLead.FundingOpportunityNumber__c=stgfoLead.FundingOpportunityNumber__c;
            update foaLead;
            
            Test.startTest();
            StagingLeadsToLeadsBatch ctrl= new StagingLeadsToLeadsBatch();
            Database.executeBatch(ctrl);
            Test.stopTest();
        }
    */
    }
}