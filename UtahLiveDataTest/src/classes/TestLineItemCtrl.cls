@isTest
private class TestLineItemCtrl {

    static testMethod void myUnitTest() {
        User u = TestHelper.getAdminUser(true);
        System.runAs(u) {
        	AnnouncementTriggerHelper.skipTrigger = true;
        	ApplicationTriggerHelper.skipTrigger = true;
        	Announcement__c ann = Testhelper.getAnnouncement(true);
        	Application__c app = Testhelper.getApplication(ann.id,true);
        	ApplicationBudgetCategory2__c appbudcat = new ApplicationBudgetCategory2__c(Application__c = app.id);
        	insert appbudcat;
        	test.starttest();
        	ApexPages.currentPage().getParameters().put('id',appbudcat.id);
            ApexPages.currentPage().getParameters().put('type','Application');
            LineItemCtrl ctrl = new LineItemCtrl();
            ctrl.getKeyValueMap();
        	test.stoptest();
        }
    }
    static testMethod void myUnitTest1() {
        User u = TestHelper.getAdminUser(true);
        System.runAs(u) {
        	GrantTriggerHelper.skipTrigger = true;
        	AwardTriggerHelper.skipTrigger = true;
        	Grant__c grant = Testhelper.getGrant(true);
        	Award__c award = Testhelper.getAwards(grant.id,true);
        	AwardBudgetCategory__c awdbudcat = new AwardBudgetCategory__c(Award__c = award.id);
        	insert awdbudcat;
        	test.starttest();
        	ApexPages.currentPage().getParameters().put('id',awdbudcat.id);
            ApexPages.currentPage().getParameters().put('type','Award');
            LineItemCtrl ctrl = new LineItemCtrl();
            ctrl.getKeyValueMap();
        	test.stoptest();
        }
    }
}