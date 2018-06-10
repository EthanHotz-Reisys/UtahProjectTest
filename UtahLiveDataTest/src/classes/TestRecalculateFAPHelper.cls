@isTest
private class TestRecalculateFAPHelper {

    static testMethod void myUnitTest() {
        
        AnnouncementTriggerHelper.skipTrigger = true;
        
        User u = TestHelper.getAdminUser(true);
        System.runAs(u) {
        	Announcement__c ann = TestHelper.getAnnouncement(true);
        	PreApplication__c preapp = TestHelper.getPreApplication(ann.id,false);
            preapp.AllocationPercentage__c = 5.0;
        	insert preapp;
        	Map<String,String> urlParams = new Map<String,String>();
            test.starttest();
            RecalculateFAPHelper recalcfaphelper = new RecalculateFAPHelper();
            urlParams.put('id',ann.Id);
            recalcfaphelper.urlParams = urlParams;
            recalcfaphelper.clickHandler(); 
            test.stoptest();
                      
        }
    }
     static testMethod void myUnitTest1() {
        
        AnnouncementTriggerHelper.skipTrigger = true;
        
        User u = TestHelper.getAdminUser(true);
        System.runAs(u) {
        	Announcement__c ann = TestHelper.getAnnouncement(false);
        	ann.SetAsideAmount__c = 2000;
        	insert ann;
        	PreApplication__c preapp = TestHelper.getPreApplication(ann.id,false);
            preapp.AllocationPercentage__c = 100.0;
        	insert preapp;
        	List<PreApplication__c> preapplist = new List<PreApplication__c>();
        	preapplist.add(preapp);
        	preapp.AmountAllocated__c = preapp.AllocationPercentage__c*ann.SetAsideAmount__c;
        	update preapp; 
        	Map<String,String> urlParams = new Map<String,String>();
            test.starttest();
            RecalculateFAPHelper recalcfaphelper = new RecalculateFAPHelper();
            urlParams.put('id',ann.Id);
            recalcfaphelper.urlParams = urlParams;
            recalcfaphelper.clickHandler(); 
            recalcfaphelper.updateFAP(ann,preapplist);
            test.stoptest();
                      
        }
    }
}