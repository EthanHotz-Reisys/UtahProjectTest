@isTest
private with sharing class TestReSendInvitationHelper{


    static testMethod void someTest() {
    
        User u = TestHelper.getAdminUser(true);
        System.runAs(u){
        
            List<String> IdSet = new List<String>();
            
            UserTriggerHelper.skipTrigger = true;
           
            IdSet.add(u.Id);
            GNT.RecordIdStorageHelper.setRecordIds(IdSet,'SelectedUserInvitations'); 
            ReSendInvitationHelper ctrl = new ReSendInvitationHelper();
            ctrl.selectedRecordIds = IdSet;
            ctrl.clickHandler();
        
        }
  }
  
}