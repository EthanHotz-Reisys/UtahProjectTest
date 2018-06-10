@isTest
public class TestAddSelectedGrantContactToPageCtrl {

    static testMethod void testController() {
        UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true); 
             
        System.runAs(u){
            
            GrantTriggerHelper.skipTrigger = true;
            UserTriggerHelper.skipTrigger = true;
            
            Grant__c grant = TestHelper.getGrant(true);
            List<Grant__c> grantList = new List<Grant__c>();
            grantList.add(grant);
            
            List<String> IdSet = new List<String>();
            IdSet.add(grant.Id);
            GNT.RecordIdStorageHelper.setRecordIds(IdSet,'SelectedGrants');
            Test.startTest();
          
            AddSelectedGrantContactToPageCtrl ctrl= new AddSelectedGrantContactToPageCtrl();
            ctrl.grantList = grantList;
            ctrl.getListParameters();        
            Test.stopTest();
        }
    }
}