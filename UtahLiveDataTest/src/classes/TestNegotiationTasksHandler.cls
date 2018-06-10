@isTest
private class TestNegotiationTasksHandler{

    static testMethod void myUnitTest() {
        
        User u = TestHelper.getAdminUser(true);
        GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateasGrantor');
        system.runAs(u) {
         
            AnnouncementTriggerHelper.skipTrigger = true;
            ApplicationTriggerHelper.skipTrigger = true;
            
            Announcement__c ann = TestHelper.getAnnouncement(true);
            GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateasGrantor'); 
            Application__c app = TestHelper.getApplication(ann.Id,false);
            insert app;
            
            ChangeRequest__c changeReq = new ChangeRequest__c(GranteeNotified__c=false,Application__c=app.Id);
            insert changeReq;
            
            List<ChangeRequest__c> scope = new List<ChangeRequest__c>();
            scope.add(changeReq);
           
            Test.startTest();
            NegotiationTasksHandler ctrl= new NegotiationTasksHandler();
            Database.executeBatch(ctrl);

            Test.stopTest();
        }
    
    }
    
      
}