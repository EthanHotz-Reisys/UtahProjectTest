@isTest
private class TestAddAnnouncemntServiceAreaCtrl {

    static testMethod void myUnitTest() {
        AnnouncementTriggerHelper.skipTrigger = true;
        ServiceAreaTriggerHelper.skipTrigger = true;
        UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
        System.runAs(u) {
            Announcement__c ann = TestHelper.getAnnouncement(true);
            ann.RecordTypeId = Schema.SObjectType.Announcement__c.getRecordTypeInfosByName().get('Grantee').getRecordTypeId();
            update ann;
            ServiceArea__c servarea = TestHelper.getServiceArea(true);
            AnnouncementServiceArea__c annServicerea = new AnnouncementServiceArea__c (Announcement__c = ann.id,ServiceArea__c = servarea.id);
            insert annServicerea;
            List<String> selectedRecordIds = new List<String>();
            selectedRecordIds.add(servarea.id);
            ApexPages.currentPage().getParameters().put('Id', ann.Id);
            Map<String,String> urlParams = new Map<String,String>();
            AddAnnouncementServiceAreaCtrl addannservarea = new AddAnnouncementServiceAreaCtrl();
            addannservarea.selectedRecordIds = selectedRecordIds;
            urlParams.put('parentid',ann.Id);
            addannservarea.urlParams = urlParams;
            addannservarea.clickHandler();           
        }
    }
    static testMethod void myUnitTest1() {
    /*
        AccountTriggerHelper.skipTrigger = true;
        ProgramTriggerhelper.skipTrigger = true;
        AnnouncementTriggerHelper.skipTrigger = true;
        ServiceAreaTriggerHelper.skipTrigger = true;
        UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
        System.runAs(u) {
            Account acc = TestHelper.getAccount(true);
            Program__c prg = TestHelper.getProgram(acc.Id, true);
            Announcement__c ann = TestHelper.getAnnouncement(true);
            ann.RecordTypeId = Schema.SObjectType.Announcement__c.getRecordTypeInfosByName().get('Grantor').getRecordTypeId();
            update ann;
            ServiceArea__c servarea = TestHelper.getServiceArea(true);
            ProgramServiceArea__c relatedServicerea = new ProgramServiceArea__c (Program__c = prg.id,ServiceArea__c = servarea.id);
            AnnouncementServiceArea__c annServicerea = new AnnouncementServiceArea__c (Announcement__c = ann.id,ProgramServiceArea__c = relatedServicerea.id);
            insert annServicerea;
            List<String> selectedRecordIds = new List<String>();
            selectedRecordIds.add(relatedServicerea.id);
            ApexPages.currentPage().getParameters().put('Id', ann.Id);
            Map<String,String> urlParams = new Map<String,String>();
            AddAnnouncementServiceAreaCtrl addannservarea = new AddAnnouncementServiceAreaCtrl();
            addannservarea.selectedRecordIds = selectedRecordIds;
            urlParams.put('parentid',ann.Id);
            addannservarea.urlParams = urlParams;
            addannservarea.clickHandler();           
        }
        */
    }
}