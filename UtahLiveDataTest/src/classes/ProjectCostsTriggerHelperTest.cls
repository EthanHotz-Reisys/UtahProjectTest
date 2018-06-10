@isTest
private class ProjectCostsTriggerHelperTest {

    static testMethod void testWhenClicked() {
        User u = TestHelper.getAdminUser(true);
        System.runAs(u) {
        Test.startTest();
        PreapplicationTriggerHelper.skipTrigger = true;
        ApplicationTriggerHelper.skipTrigger = true;
        AnnouncementTriggerHelper.skipTrigger = true;
        PanelUserTriggerHelper.skipAll= true;
        UserTriggerHelper.skipTrigger = true;
        ProjectCostByFundingSource__c  pcfs = new ProjectCostByFundingSource__c();
        pcfs.UnsecuredAmount__c = 100;
        pcfs.SecuredAmount__c = 100;
        pcfs.Sequence__c = 1;
        pcfs.name= 'tets';
        insert pcfs;
        pcfs.UnsecuredAmount__c = 200;
        update pcfs;
        Test.stopTest();    
    }
}
    @isTest
     static void testWhenClicked1() {
        User u = TestHelper.getAdminUser(true);
        System.runAs(u) {
        Test.startTest();
        PreapplicationTriggerHelper.skipTrigger = true;
        ApplicationTriggerHelper.skipTrigger = true;
        AnnouncementTriggerHelper.skipTrigger = true;
        PanelUserTriggerHelper.skipAll= true;
        UserTriggerHelper.skipTrigger = true;
        Announcement__c ann = TestHelper.getAnnouncement(true);
        Application__c app =TestHelper.getApplication(ann.Id,true);
        ProjectCostByFundingSource__c  pcfs = new ProjectCostByFundingSource__c();
        pcfs.UnsecuredAmount__c = 100;
        pcfs.SecuredAmount__c = 100;
        pcfs.Sequence__c = 1;
        pcfs.name= 'tets';
        pcfs.Application__c = app.Id;
        insert pcfs;
        pcfs.UnsecuredAmount__c = 200;
        update pcfs;
        Test.stopTest();    
    }    
}
}