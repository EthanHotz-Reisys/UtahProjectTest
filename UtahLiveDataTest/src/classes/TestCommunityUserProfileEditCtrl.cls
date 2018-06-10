@isTest
private with sharing class TestCommunityUserProfileEditCtrl {

      static testMethod void testController(){
          UserTriggerHelper.skipTrigger = true; 
          User u = TestHelper.getAdminUser(true);
         System.runAs(u) {
         TestHelper.CreateCustomSettings(true);
        UserRegistration__c uReg = new UserRegistration__c();
        uReg.OrganizationName__c ='TestORG';
        uReg.LastName__c = 'Betty';
        uReg.username__c = System.now().millisecond() + 'test@123test.com';
        uReg.EINo__c = Math.Random();
        uReg.Email__c = 'test15@test.com';
        //uReg.RecordType.DeveloperName = 'Reviewer';
        insert uReg;
        Contact con = TestHelper.getContact(true);
          Test.startTest();
         ApexPages.currentPage().getParameters().put('id', con.Id);
          CommunityUserProfileEditCtrl ctrl = new CommunityUserProfileEditCtrl(new ApexPages.StandardController(con));
          ctrl.isFirstLogin();
          //ctrl.login();
          Test.stopTest();
      }
}

 
    
  
      
}