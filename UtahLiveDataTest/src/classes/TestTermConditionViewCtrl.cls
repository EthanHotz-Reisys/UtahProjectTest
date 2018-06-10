@isTest
private class  TestTermConditionViewCtrl{
    
    static TermCondition__c obj; 
    static TermConditionViewCtrl tcViewCtrl;
        
    private static void setupData(boolean create, String recordType){
       UserTriggerHelper.skipTrigger=true;
       Grant__c grant = TestHelper.getGrant (false);
       grant.ProjectPeriodStartDate__c = Date.newInstance(2015,7,22);
       grant.ProjectPeriodEndDate__c = Date.newInstance(2015,9,24);
       grant.IssueDate__c=Date.newInstance(2015,6,14);
       insert grant;
       
       obj = TestHelper.getTermCondition(false, recordType);  
       obj.Grant__c = grant.Id;
       obj.ReportStartDate__c = 'Project Period Start Date';
       obj.Frequency__c = 'Monthly';
     //  obj.DueDateType__c = 'After';
       obj.DueDateDays__c = 5;
       obj.TaskAvailability__c = 5;
       insert obj;     
       Test.setCurrentPageReference(new PageReference('Page.BlankPage')); 
       System.currentPageReference().getParameters().put('recordType', recordType);
       ApexPages.CurrentPage().getParameters().put('id',obj.id);
       ApexPages.Standardcontroller sc123 = New ApexPages.StandardController(obj);
       tcViewCtrl = new TermConditionViewCtrl(sc123);
       tcViewCtrl.getKeyValueMap(); 
       tcViewCtrl.getListParams();
       
    }
    
    @isTest
    public static void testGetterSetter(){
    /*
        UserTriggerHelper.skipTrigger=true;
        User u = TestHelper.getAdminUser(true);
        System.runAs(u){
            GrantTriggerHelper.skipTrigger = true;
            AccountTriggerHelper.skipTrigger = true;
            Test.startTest();
            setupData(true, 'Term');
            Test.stopTest();
        }
        system.assertNotEquals(tcViewCtrl.getKeyValueMap(),null);
        */
    }
    @isTest
    public static void testGetterSetterCondition(){
    /*
        UserTriggerHelper.skipTrigger=true;
        User u = TestHelper.getAdminUser(true);
        System.runAs(u){
            GrantTriggerHelper.skipTrigger = true;
             AccountTriggerHelper.skipTrigger = true;
            Test.startTest();
            setupData(true, 'Condition');
            Test.stopTest();
        }
        system.assertNotEquals(tcViewCtrl.getKeyValueMap(),null);
        */
    }
    
    @isTest
    public static void testConditionApp(){
    /*
        UserTriggerHelper.skipTrigger=true;
        User u = TestHelper.getAdminUser(true);
        GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateasGrantee');
        System.runAs(u){
            GrantTriggerHelper.skipTrigger = true;
             AccountTriggerHelper.skipTrigger = true;
             GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateasGrantee');
             
             Grant__c grant = TestHelper.getGrant (false);
             grant.ProjectPeriodStartDate__c = Date.newInstance(2015,7,22);
             grant.ProjectPeriodEndDate__c = Date.newInstance(2015,9,24);
             grant.IssueDate__c=Date.newInstance(2015,6,14);
             insert grant;
       
             obj = TestHelper.getTermCondition(true,'Condition');  
             obj.Grant__c = grant.Id;
             update obj;   
       
             Test.startTest();
                GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateasGrantee');
               System.currentPageReference().getParameters().put('recordType', 'Condition');
               ApexPages.CurrentPage().getParameters().put('id',obj.id);
               ApexPages.Standardcontroller sc123 = New ApexPages.StandardController(obj);
               tcViewCtrl = new TermConditionViewCtrl(sc123);
               tcViewCtrl.getKeyValueMap(); 
               Test.stopTest();
        }
        system.assertNotEquals(tcViewCtrl.getKeyValueMap(),null);
        */
    }
     @isTest
    public static void testGetterSetterConditionreporting (){
    /*
        UserTriggerHelper.skipTrigger=true;
        User u = TestHelper.getAdminUser(true);
        System.runAs(u){
            GrantTriggerHelper.skipTrigger = true;
             AccountTriggerHelper.skipTrigger = true;
            Test.startTest();
            setupData(true, 'Reporting Requirement');
            Test.stopTest();
        }
        system.assertNotEquals(tcViewCtrl.getKeyValueMap(),null);
        */
    }
    
    
    
}