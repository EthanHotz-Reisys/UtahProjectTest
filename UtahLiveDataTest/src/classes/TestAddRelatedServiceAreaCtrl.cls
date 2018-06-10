@isTest
private with sharing class TestAddRelatedServiceAreaCtrl {

    static testMethod void myUnitTest(){
    /*
        AccountTriggerHelper.skipTrigger = true;
        ProgramTriggerhelper.skipTrigger = true;
        ServiceAreaTriggerHelper.skipTrigger = true;
        UserTriggerHelper.skipTrigger = true;
        
        User u = TestHelper.getAdminUser(true);
        System.runAs(u) {
            UserTriggerHelper.skipTrigger = true;
            Account acc = TestHelper.getAccount(true);
            Program__c prg = TestHelper.getProgram(acc.Id, true);
            ServiceArea__c servarea = TestHelper.getServiceArea(true);
            ProgramServiceArea__c relatedServicerea = new ProgramServiceArea__c (Program__c = prg.id,ServiceArea__c = servarea.id);
            insert relatedServicerea;
            List<String> selectedRecordIds = new List<String>();
            selectedRecordIds.add(servarea.id);
            ApexPages.currentPage().getParameters().put('Id', prg.Id);
            Map<String,String> urlParams = new Map<String,String>();
            AddRelatedServiceAreaCtrl addrelservarea = new AddRelatedServiceAreaCtrl();
            addrelservarea.selectedRecordIds = selectedRecordIds;
            urlParams.put('parentid',prg.Id);
            addrelservarea.urlParams = urlParams;
            addrelservarea.clickHandler();           
        }
        */
    }
}