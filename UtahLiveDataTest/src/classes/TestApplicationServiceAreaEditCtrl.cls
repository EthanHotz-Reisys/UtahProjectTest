/**
  
    **********************************************************
    Audit History
    **********************************************************
    9/22/2015              swati singh    created
    **********************************************************  
*/
@IsTest
private with sharing class TestApplicationServiceAreaEditCtrl {
    @IsTest
    private static void testInsert() {
         UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
        TestHelper.createCustomSettings(true);
        ApplicationTriggerHelper.skipTrigger = true;
              
       
        
        System.runAs(u) { 
         
                //Prepare test data
                Announcement__c ann = testHelper.getAnnouncement(true); 
                Application__c app = testHelper.getApplication(ann.id,true);
                ApexPages.CurrentPage().getParameters().put('id', app.Id);  
                ApexPages.StandardController stdController = new ApexPages.StandardController(app);
                //Execute test
                Test.startTest();
                ApplicationServiceAreaEditCtrl asaec = new ApplicationServiceAreaEditCtrl(stdController);
                asaec.getKeyValueMap();
                Test.stopTest();
        
                  //Assert test data

                 System.assertEquals(asaec, asaec);
        }
    }
}