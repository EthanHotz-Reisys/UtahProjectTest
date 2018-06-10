@isTest
private class TestNotifyPreApplicationHelper {

    static testMethod void myUnitTest() {
       User u = TestHelper.getAdminUser(true);
       AnnouncementTriggerHelper.skipTrigger = true;
       PreApplicationTriggerHelper.skipTrigger = true;
       System.runAs(u){
       	Announcement__c ann = TestHelper.getAnnouncement(false);
       	ann.FundingAllocationStatus__c='Approved';
       	insert ann;
       	PreApplication__c preapp = TestHelper.getPreApplication(ann.id,false);
       	preapp.AllocationPercentage__c = 100;
       	insert preapp;
       	Contact con = TestHelper.getcontact(true);
       	test.starttest(); 
       	NotifyPreApplicationHelper notify = new NotifyPreApplicationHelper();
       	ApexPages.currentPage().getParameters().put('id',ann.Id);  
       	notify.whenClicked();
       	notify.notifyUsers(ann);
       	test.stoptest();
       }
    }
    static testMethod void myUnitTest1() {
       User u = TestHelper.getAdminUser(true);
       AnnouncementTriggerHelper.skipTrigger = true;
       PreApplicationTriggerHelper.skipTrigger = true;
       System.runAs(u){
       	Announcement__c ann = TestHelper.getAnnouncement(false);
       	ann.FundingAllocationStatus__c='Accepted';
       	insert ann;
       	test.starttest(); 
       	NotifyPreApplicationHelper notify = new NotifyPreApplicationHelper();
       	ApexPages.currentPage().getParameters().put('id',ann.Id);  
       	notify.whenClicked();
       	test.stoptest();
       }
    }
}