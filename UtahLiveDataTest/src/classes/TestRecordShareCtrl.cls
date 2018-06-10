@isTest
private class TestRecordShareCtrl{
   
    @isTest
    private static void testgetRecords(){
        user user = TestHelper.getAdminUser(true);
        system.runAs(user){
        AccountTriggerHelper.skipAll = true;
        ProgramTriggerHelper.skipTrigger = true;
        AnnouncementTriggerHelper.skipTrigger = true;
        ApplicationTriggerHelper.skipTrigger = true;
        PreApplicationTriggerHelper.skipTrigger = true;
        AccountTriggerHelper.skipTrigger = true;
            Test.startTest();
            TestHelper.CreateCustomSettings(true);
            PreApplication__c preApp = TestHelper.getPreApplication(true);
            Test.setCurrentPageReference(new PageReference('Page.RecordShare')); 
            System.currentPageReference().getParameters().put('id', preApp.id);
            system.assert(new RecordShareCtrl().getRecords() != null);
            Test.stopTest();
        }
        
    }
    
    @isTest
    private static void testgetFields(){
            Test.startTest();
            system.assert(new RecordShareCtrl().getFields() != null);
            Test.stopTest();
    }

}