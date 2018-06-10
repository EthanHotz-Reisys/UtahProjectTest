@isTest
private with sharing class TestTeamingPartnerEditCtrl{
    static testMethod void testController() {
          UserTriggerHelper.skipTrigger=true;
          User u = TestHelper.getAdminUser(true);
          TeamingPartners__c teamPartner = null;
          Announcement__c ann = null;

          System.runAs(u){
              AnnouncementTriggerHelper.skipTrigger = true;
              
              ann = TestHelper.getAnnouncement(true);
              teamPartner= new TeamingPartners__c();
              insert teamPartner;
             
          }   
         
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.standardController(teamPartner);
        ApexPages.currentPage().getParameters().put('Id',teamPartner.id);
        ApexPages.currentPage().getParameters().put('announcementId',ann.id);
        TeamingPartnerEditCtrl ctrl = new TeamingPartnerEditCtrl(sc);
        ctrl.getKeyValueMap();
        Test.stopTest();
        
    }
}