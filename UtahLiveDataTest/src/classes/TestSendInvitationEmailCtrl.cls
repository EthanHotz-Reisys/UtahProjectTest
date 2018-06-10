@isTest
private with sharing class TestSendInvitationEmailCtrl{
    static testMethod void testController() {
    
        User u = TestHelper.getAdminUser(true);
        
        Test.startTest();
        SendInvitationEmailCtrl ctrl = new SendInvitationEmailCtrl();
        ctrl.toAddr = 'abc@test.com';
        ctrl.successMsg = 'Invitation sent successfully';
        ctrl.sendEmail();
        ctrl.ActivateReviewers();
        ctrl.getKeyValueMap();
        Test.stopTest();
    }
}