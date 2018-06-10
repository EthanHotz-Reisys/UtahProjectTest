@isTest(Seealldata=false)
private with sharing class TestRiskItemEditCtrl {
    
     static testMethod void testRiskItemEdit() {
        RiskItem__c ri = null;
        RiskAssessment__c ra = null;
        Program__c program = null;
        UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true); 
             
        System.runAs(u){
            GNT__KeyValueStore__c key= new GNT__KeyValueStore__c(Name='ENTERPRISE',GNT__BooleanValue__c=true);
            GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateAsGrantor');
            AppUtils.skipAccountTrigger=true;
            ProgramTriggerHelper.skipTrigger=true;
            Account acc = new Account();
            acc.Name = 'test'+system.currentTimeMillis();
            acc.status__c = 'Active';   
            insert acc;  
           
            program = TestHelper.getProgram(acc.id,false);
            program.status__c = 'Active';
            insert program;  
            
            ra = new RiskAssessment__c();
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
        ApexPages.currentPage().getParameters().put('riskAssessmentID',ra.Id);
        ApexPages.currentPage().getParameters().put('programId',program.Id);
        RiskItemEditCtrl ann = new RiskItemEditCtrl(sc);
        ann.getKeyValueMap();        
        Test.stopTest();
    }
    
    static testMethod void testRiskItemEdit2() {
        RiskItem__c ri = null;
        Grant__c grant = null;
        UserTriggerHelper.skipTrigger = true;
        GrantTriggerHelper.skipTrigger=true;
        User u = TestHelper.getAdminUser(true); 
          grant = TestHelper.getGrant(true);
           
             
        System.runAs(u){
          //  TestHelper.getServiceArea(true);
            GNT__KeyValueStore__c key= new GNT__KeyValueStore__c(Name='ENTERPRISE',GNT__BooleanValue__c=true);
            GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateAsGrantor');
            AppUtils.skipAccountTrigger=true;
            ri = new RiskItem__c();
            ri.RiskIdentifiedDate__c=System.today();
            ri.DueDate__c=System.today()+7;
            ri.PlanofAction__c='Sample Text';
            insert ri;
            
        }        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.standardController(ri);
        ApexPages.currentPage().getParameters().put('id',ri.Id);
        ApexPages.currentPage().getParameters().put('grantId',grant.Id);
        RiskItemEditCtrl ann = new RiskItemEditCtrl(sc);
        ann.getKeyValueMap();        
        Test.stopTest();
    }
}