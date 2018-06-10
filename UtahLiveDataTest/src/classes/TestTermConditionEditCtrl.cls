@isTest
private class  TestTermConditionEditCtrl{
    
    static TermCondition__c obj; 
    static TermConditionEditCtrl tcEditCtrl;
    static Grant__c grant; 
    static Award__c award; 
    static Program__c program; 
    
    private static void setupData(boolean create, String recordType){
        UserTriggerHelper.skipTrigger=true;
        AccountTriggerHelper.skipTrigger = true;
        AwardTriggerHelper.skipTrigger = true;
        GrantTriggerHelper.skipTrigger = true;
       obj = TestHelper.getTermCondition(create, recordType);
       //grant = TestHelper.getGrant(false);
       //grant.ProjectPeriodStartDate__c=date.today();
       //grant.ProjectPeriodEndDate__c=date.today()+360;
      // insert grant;
        grant = TestHelper.getGrant(false);        
        grant.Status__c = 'Active';
        grant.ProjectPeriodStartDate__c=Date.today();
        
        insert grant;
       award = TestHelper.getAwards(grant.Id, true);
       Account acc = TestHelper.getAccount(true);
       program = TestHelper.getProgram(acc.Id, true);
       Test.setCurrentPageReference(new PageReference('Page.BlankPage')); 
       System.currentPageReference().getParameters().put('recordType', recordType);
       System.currentPageReference().getParameters().put('Id',obj.Id);
       System.currentPageReference().getParameters().put('isProgram','true');
       System.currentPageReference().getParameters().put('grantId',grant.Id);
       System.currentPageReference().getParameters().put('awardId',award.Id);
       System.currentPageReference().getParameters().put('programId',program.Id);
       System.currentPageReference().getParameters().put('isNew','true');
       ApexPages.Standardcontroller sc123 = New ApexPages.StandardController(obj);
       tcEditCtrl = new TermConditionEditCtrl (sc123);
    }
    
    @isTest
    public static void test1 () {
    /*
        UserTriggerHelper.skipTrigger=true;
        AccountTriggerHelper.skipTrigger = true;
        AwardTriggerHelper.skipTrigger = true;
        GrantTriggerHelper.skipTrigger = true;
        ProgramTriggerHelper.skipTrigger = true;
        obj = TestHelper.getTermCondition(false, 'Payment Request');
        obj.ReportStartDate__c = 'Fixed';
        obj.Frequency__c = 'Monthly';
        obj.FixedStartDate__c = Date.newInstance(1960, 2, 17);
        obj.FixedEndDate__c = Date.newInstance(1961, 2, 17);
      //  obj.DueDateType__c = 'Before';
        obj.DueDateDays__c = 10;
        obj.TaskAvailability__c = 3;
        insert obj;
       grant = TestHelper.getGrant(false);        
        grant.Status__c = 'Active';
        grant.ProjectPeriodStartDate__c=Date.today();
        
        insert grant;
        award = TestHelper.getAwards(grant.Id, true);
        Account acc = TestHelper.getAccount(true);
        program = TestHelper.getProgram(acc.Id, true);
        Test.setCurrentPageReference(new PageReference('Page.BlankPage')); 
        // System.currentPageReference().getParameters().put('recordType', recordType);
        System.currentPageReference().getParameters().put('Id',obj.Id);
        System.currentPageReference().getParameters().put('isProgram','true');
        System.currentPageReference().getParameters().put('grantId',grant.Id);
        System.currentPageReference().getParameters().put('awardId',award.Id);
        System.currentPageReference().getParameters().put('programId',program.Id);
        ApexPages.Standardcontroller sc123 = New ApexPages.StandardController(obj);
        tcEditCtrl = new TermConditionEditCtrl (sc123);
        
        */
    }
    
    @isTest
    public static void testGetterSetter(){
    /*
        UserTriggerHelper.skipTrigger=true;
        User u = TestHelper.getAdminUser(true);
        System.runAs(u) {
        AccountTriggerHelper.skipTrigger = true;
        AwardTriggerHelper.skipTrigger = true;
        GrantTriggerHelper.skipTrigger = true;
        ProgramTriggerHelper.skipTrigger= true;
        setupData(false,'Term');
        Test.startTest();
        
       // system.assert(tcEditCtrl.savePage == null);
        //system.assert(tcEditCtrl.cancelPage == null);  
        Test.stopTest();
        }
         */
    }
    
    @isTest
    public static void testTerm(){
    /*
        UserTriggerHelper.skipTrigger=true;
        User u = TestHelper.getAdminUser(true);
        System.runAs(u) {
        AccountTriggerHelper.skipTrigger = true;
        AwardTriggerHelper.skipTrigger = true;
        GrantTriggerHelper.skipTrigger = true;
        ProgramTriggerHelper.skipTrigger= true;
        Test.startTest();
        setupData(true, 'Term');
        Test.stopTest();
        system.assertNotEquals(tcEditCtrl,null);
        }
         */
    }
    
     @isTest
    public static void testElse(){
    /*
        UserTriggerHelper.skipTrigger=true;
        User u = TestHelper.getAdminUser(true);
        System.runAs(u) {
        AccountTriggerHelper.skipTrigger = true;
        AwardTriggerHelper.skipTrigger = true;
        GrantTriggerHelper.skipTrigger = true;
        ProgramTriggerHelper.skipTrigger= true;
        
        obj = TestHelper.getTermCondition(true, 'Condition');
        grant = TestHelper.getGrant(false);        
        grant.Status__c = 'Active';
        grant.ProjectPeriodStartDate__c=Date.today();
        insert grant;
        award = TestHelper.getAwards(grant.Id, true);
        Account acc = TestHelper.getAccount(true);
        program = TestHelper.getProgram(acc.Id, true);
        
        Test.startTest();      
        System.currentPageReference().getParameters().put('recordType', 'Condition');
        System.currentPageReference().getParameters().put('Id',obj.Id);
        System.currentPageReference().getParameters().put('isProgram','true');
        System.currentPageReference().getParameters().put('grantId',grant.Id);
        System.currentPageReference().getParameters().put('awardId',award.Id);
        System.currentPageReference().getParameters().put('programId',program.Id);
        System.currentPageReference().getParameters().put('isNew','true');
        ApexPages.Standardcontroller sc123 = New ApexPages.StandardController(obj);
        tcEditCtrl = new TermConditionEditCtrl (sc123);
        Test.stopTest();
       }
        */
    }
    
    
    
    @isTest
    public static void testCondition(){
    /*
        UserTriggerHelper.skipTrigger=true;
        User u = TestHelper.getAdminUser(true);
        System.runAs(u) {
        AccountTriggerHelper.skipTrigger = true;
        AwardTriggerHelper.skipTrigger = true;
        GrantTriggerHelper.skipTrigger = true;
        ProgramTriggerHelper.skipTrigger= true;
        Test.startTest();
        setupData(true, 'Condition');
        Test.stopTest();
        system.assertNotEquals(tcEditCtrl,null);
        }
    }
    
    @isTest
    public static void testReportingReq(){
        UserTriggerHelper.skipTrigger=true;
        User u = TestHelper.getAdminUser(true);
        System.runAs(u) {
        AccountTriggerHelper.skipTrigger = true;
        AwardTriggerHelper.skipTrigger = true;
        GrantTriggerHelper.skipTrigger = true;
        ProgramTriggerHelper.skipTrigger= true;
        setupData(true, 'Reporting Requirement');
        Test.startTest();
        System.currentPageReference().getParameters().put('isProgram','false');
        ApexPages.Standardcontroller sc1 = New ApexPages.StandardController(obj);
        tcEditCtrl = new TermConditionEditCtrl (sc1);
        Test.stopTest();
        system.assertNotEquals(tcEditCtrl,null);
        }
         */
    }
    
    @isTest
    public static void testisProgram(){
    /*
        UserTriggerHelper.skipTrigger=true;
        User u = TestHelper.getAdminUser(true);
        System.runAs(u) {
        AccountTriggerHelper.skipTrigger = true;
        AwardTriggerHelper.skipTrigger = true;
        GrantTriggerHelper.skipTrigger = true;
        ProgramTriggerHelper.skipTrigger= true;
        setupData(true, 'Reporting Requirement');
        Test.startTest();
        obj = TestHelper.getTermCondition(false, 'Payment Request');
        obj.type__c='Program';
        insert obj;
        System.currentPageReference().getParameters().put('isProgram',null);
        ApexPages.Standardcontroller sc1 = New ApexPages.StandardController(obj);
        tcEditCtrl = new TermConditionEditCtrl (sc1);
        Test.stopTest();
        system.assertNotEquals(tcEditCtrl,null);
        }
         */
    }
    
    @isTest
    public static void testNullController(){
    /*
        UserTriggerHelper.skipTrigger=true;
        User u = TestHelper.getAdminUser(true);
        System.runAs(u) {
        AccountTriggerHelper.skipTrigger = true;
        AwardTriggerHelper.skipTrigger = true;
        GrantTriggerHelper.skipTrigger = true;
        ProgramTriggerHelper.skipTrigger= true;
        setupData(true, 'Reporting Requirement');
        Test.startTest();
        System.currentPageReference().getParameters().put('isProgram',null);
        
        ApexPages.Standardcontroller sc1 = new ApexPages.StandardController(obj);
        
        tcEditCtrl = new TermConditionEditCtrl (sc1);
        Test.stopTest();
        system.assertNotEquals(tcEditCtrl,null);
        }
         */
    }
}