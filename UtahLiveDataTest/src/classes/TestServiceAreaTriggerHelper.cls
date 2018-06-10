@isTest(seealldata=true)
private with sharing class TestServiceAreaTriggerHelper{

    static testMethod void testServiceAreaTrigg(){
        UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
        ServiceArea__c servArea = null;
        ProgramServiceArea__c pgmServArea = null;
        Account acct = null;
        Program__c pgm = null;
        ApplicationServiceArea__c  appServArea = null;
        Announcement__c ann = null;
        AnnouncementServiceArea__c  annServArea = null;
        AwardServiceArea__c awardServArea = null;
        Application__c app = null;
        Grant__c grant = null;
        Award__c award=null;
        GrantServiceArea__c grantServArea=null;
        
        System.runAs(u){
            GNT__KeyValueStore__c key= new GNT__KeyValueStore__c(Name='ENTERPRISE',GNT__BooleanValue__c=true);
            AccountTriggerHelper.skipTrigger=true;
            RolesandResponsibilitiesTriggerHelper.skipTrigger=true;
            ProgramTriggerHelper.skipTrigger=true;
            AnnouncementTriggerHelper.skipTrigger=true;
            AwardTriggerHelper.skipTrigger=true;
            ApplicationTriggerHelper.skipTrigger=true;
            AwardTriggerHelper.skipTrigger=true;
            GrantTriggerHelper.skipTrigger=true;
            
            acct = TestHelper.getAccount(true);
            
            servArea = TestHelper.getServiceArea(true);
            servArea.Account__c = acct.Id;
            update servArea;
            pgm = TestHelper.getProgram(acct.Id,true);
            pgmServArea = TestHelper.getProgramServiceArea(true,pgm.Id,servArea.Id);
           
            
            ann = TestHelper.getAnnouncement(true);
            annServArea = new AnnouncementServiceArea__c(Announcement__c=ann.Id,ServiceArea__c=servArea.Id);
            insert annServArea;
            
            app = TestHelper.getApplication(ann.Id,true);
            appServArea = new ApplicationServiceArea__c(ServiceArea__c=annServArea.Id,Application__c=app.Id);
            insert appServArea;
            
            grant = TestHelper.getGrant(true);
            grantServArea = new GrantServiceArea__c(Grant__c=grant.Id,ServiceArea__c=servArea.Id);
            insert grantServArea;
            award = TestHelper.getAwards(grant.Id,true);
            awardServArea = new AwardServiceArea__c(ServiceArea__c=servArea.Id,Award__c=award.Id);
            insert awardServArea;
            
            delete pgmServArea;
            delete annServArea;
            delete appServArea;
            delete grantServArea;
            delete awardServArea;
            delete servArea;
            
        }
        
         Test.startTest();
         ServiceAreaTriggerHelper servTrigHelp = new ServiceAreaTriggerHelper();
             Test.stopTest();
         
    }
}