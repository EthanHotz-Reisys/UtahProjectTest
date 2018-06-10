@isTest(Seealldata=false)
private with sharing class TestRiskItemViewCtrl {
    
     static testMethod void testRiskItemView() {
        RiskItem__c ri = null;
        UserTriggerHelper.skipTrigger = true;
        User u = new User(Id=UserInfo.getUserId());        
        System.runAs(u){
          //  TestHelper.getServiceArea(true);
            GNT__KeyValueStore__c key= new GNT__KeyValueStore__c(Name='ENTERPRISE',GNT__BooleanValue__c=true);
            GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateAsGrantor');
            Account acc = new Account();
            acc.Name = 'test'+system.currentTimeMillis();
            acc.status__c = 'Active';        
            AppUtils.skipAccountTrigger=true;
            ProgramTriggerHelper.skipTrigger=true;
            Program__c program = TestHelper.getProgram(acc.id,false);
            program.status__c = 'Active';
            insert program;  
            RiskAssessment__c ra = new RiskAssessment__c();
            ra.Program__c=program.Id;
            ra.AssessmentDate__c=System.today();
            insert ra;
            ri = new RiskItem__c();
            ri.RiskIdentifiedDate__c=System.today();
            ri.DueDate__c=System.today()+7;
            ri.PlanofAction__c='Sample Text';
            insert ri;
            
        }        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.standardController(ri);
        ApexPages.currentPage().getParameters().put('id',ri.Id);
        RiskItemViewCtrl ann = new RiskItemViewCtrl(sc);
        ann.getKeyValueMap();        
        Test.stopTest();
    }
    
    
}