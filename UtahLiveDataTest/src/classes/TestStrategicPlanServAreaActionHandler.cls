@isTest
private with sharing class TestStrategicPlanServAreaActionHandler {
    static testMethod void myUnitTest() {
        AccountTriggerHelper.skipAll = true;
        ProgramTriggerHelper.skipTrigger = true;
        StrategicPlanTriggerHelper.skipTrigger = true;
        UserTriggerHelper.skipTrigger=true;
        User u = TestHelper.getAdminUser(true);
        System.runAs(u) {
            Account acc = TestHelper.getAccount(true); 
            Program__c prg = TestHelper.getProgram(acc.Id, true);
            ServiceArea__c serarea = Testhelper.getServiceArea(true);
            StrategicPlan__c obj = TestHelper.getStrategicPlan(true);
            List<String> selectedRecordIds = new List<String>();
            selectedRecordIds.add(serarea.id);
            StrategicPlanServiceArea__c stsa = new StrategicPlanServiceArea__c(ServiceArea__c = serarea.id,StrategicPlan__c = obj.id);
            insert stsa;
            ApexPages.currentPage().getParameters().put('Id', obj.Id);
            PageReference p = Page.StrategicPlanView;
            Map<String,String> urlParams = new Map<String,String>();
            StrategicPlanServiceAreaActionHandler strategicplanLayoutactionhandler = new StrategicPlanServiceAreaActionHandler();
            strategicplanLayoutactionhandler.selectedRecordIds = selectedRecordIds;
            urlParams.put('parentid',obj.Id);
            strategicplanLayoutactionhandler.urlParams = urlParams;
            strategicplanLayoutactionhandler.clickHandler();
            
            
        }
    }
    static testMethod void myUnitTest1() {
        AccountTriggerHelper.skipAll = true;
        ProgramTriggerHelper.skipTrigger = true;
        StrategicPlanTriggerHelper.skipTrigger = true;
        UserTriggerHelper.skipTrigger=true;
        User u = TestHelper.getAdminUser(true);
        System.runAs(u) {
            Account acc = TestHelper.getAccount(true); 
            Program__c prg = TestHelper.getProgram(acc.Id, true);
            ServiceArea__c serarea = Testhelper.getServiceArea(true);
            StrategicPlan__c obj = TestHelper.getStrategicPlan(true);
            List<String> selectedRecordIds = new List<String>();
            selectedRecordIds.add(obj.id);
            StrategicPlanServiceArea__c stsa = new StrategicPlanServiceArea__c(ServiceArea__c = serarea.id,StrategicPlan__c = obj.id);
            insert stsa;
            ApexPages.currentPage().getParameters().put('Id', serarea.Id);
            PageReference p = Page.StrategicPlanView;
            Map<String,String> urlParams = new Map<String,String>();
            StrategicPlanServiceAreaActionHandler strategicplanLayoutactionhandler = new StrategicPlanServiceAreaActionHandler();
            strategicplanLayoutactionhandler.selectedRecordIds = selectedRecordIds;
            urlParams.put('parentid',serarea.Id);
            strategicplanLayoutactionhandler.urlParams = urlParams;
            strategicplanLayoutactionhandler.clickHandler();
            
            
        }
    }
    static testMethod void myUnitTest2() {
        AccountTriggerHelper.skipAll = true;
        ProgramTriggerHelper.skipTrigger = true;
        StrategicPlanTriggerHelper.skipTrigger = true;
        UserTriggerHelper.skipTrigger=true;
        User u = TestHelper.getAdminUser(true);
        
        System.runAs(u) {
            Account acc = TestHelper.getAccount(true); 
            Program__c prg = TestHelper.getProgram(acc.Id, true);
            ServiceArea__c serarea = Testhelper.getServiceArea(true);
            StrategicPlan__c obj = TestHelper.getStrategicPlan(true);
            List<String> selectedRecordIds = new List<String>();
            selectedRecordIds.add(serarea.id);
            StrategicPlanServiceArea__c stsa = new StrategicPlanServiceArea__c(ServiceArea__c = serarea.id,Program__c = prg.id);
            insert stsa;
            ApexPages.currentPage().getParameters().put('Id', prg.Id);
            PageReference p = Page.StrategicPlanView;
            Map<String,String> urlParams = new Map<String,String>();
            StrategicPlanServiceAreaActionHandler strategicplanLayoutactionhandler = new StrategicPlanServiceAreaActionHandler();
            strategicplanLayoutactionhandler.selectedRecordIds = selectedRecordIds;
            urlParams.put('parentid',prg.Id);
            strategicplanLayoutactionhandler.urlParams = urlParams;
            strategicplanLayoutactionhandler.clickHandler();
            
            
        }
    }

}