@isTest
private with sharing class TestExternalReviewersOverviewBatchCtrl{
    
    static Database.QueryLocator QL;
    static Database.BatchableContext BC;
    static List<Sobject> userList;
    @isTest
    private static void testAll(){
        userList = new List<Sobject>();
        UserTriggerHelper.skipTrigger = true; 
        User admin = TestHelper.getAdminUSer(true);
        system.runAs(admin){
            User u1 = TestHelper.getAdminUser(false);
            u1.IsReviewer__c = true;
            insert u1;        
            u1.FirstName = 'Test';
            update u1;                        
            
            Test.startTest(); 
                ExternalReviewersOverviewBatchCtrl ctrl = new ExternalReviewersOverviewBatchCtrl();
                Database.executeBatch(ctrl,1);  
                ExternalReviewersOverviewBatchCtrl.scheduleMe();          
            Test.stopTest();  
        }                     
    }            
}