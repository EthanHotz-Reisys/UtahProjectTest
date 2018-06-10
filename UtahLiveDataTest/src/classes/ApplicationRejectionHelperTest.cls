@isTest
public class ApplicationRejectionHelperTest {
    static testMethod void someTest() {
        AnnouncementTriggerHelper.skipTrigger = true;
        ApplicationTriggerHelper.skipTrigger = true;
        
        Announcement__c ann = TestHelper.getAnnouncement(true);
        Application__c a = TestHelper.getSubmittedApplication(ann.Id,true);
        ApexPages.currentPage().getParameters().put('id',a.id);
        ApplicationRejectionHelper e = new ApplicationRejectionHelper();
        e.whenClicked();
    }
}