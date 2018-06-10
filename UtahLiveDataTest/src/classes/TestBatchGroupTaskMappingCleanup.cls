@isTest
private class TestBatchGroupTaskMappingCleanup{

    static testMethod void myUnitTest() {
        
        User u = TestHelper.getAdminUser(true);
        system.runAs(u) {
            // skip unwanted triggers
            AccountTriggerHelper.skipAll = true;
            ContactTriggerHelper.skiptrigger = true;
            UserRegistrationTriggerHelper.skipTrigger = true;
            UserTriggerHelper.skipTrigger = true;
            
            TaskTriggerHelper.skipTrigger = true;
            Task tsk = new Task(Status='Completed');
            insert tsk;
            
            Group grp = new Group(Name='Test Group');
            insert grp;
            
            GroupTaskMapping__c grpTskMap = new GroupTaskMapping__c(Name=tsk.Id,ParentRecordId__c=grp.Id);
            insert grpTskMap;
            
            Test.startTest();
            BatchGroupTaskMappingCleanup ctrl= new BatchGroupTaskMappingCleanup();
            Database.executeBatch(ctrl);
           
            Test.stopTest();
        }
    
    }
    
      
}