/*
    Test Class for Snapshot Controller
    ***********************************************************
    Audit History
    ***********************************************************
    04/25/2014      Vineeth Shetty             Created
    *********************************************************** 
*/
@isTest
private class TestSnapshotCtrl {

    static testMethod void TestUnassignedCtrl() {
        UserTriggerHelper.skipTrigger=true;
        User u = TestHelper.getAdminUser(true);
        System.runAs(u) {
        //Arrange
        Announcement__c announcementInstance = TestHelper.getAnnouncement(true);
        ApexPages.currentPage().getParameters().put('id', announcementInstance.Id);
        
        //Act
        Test.startTest();   
        Test.stopTest();
        }               
    }
}