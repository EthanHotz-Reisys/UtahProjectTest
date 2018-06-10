@isTest
private class TestStrategicPlanProgramsActionHandler {

    static testMethod void myUnitTest() {
        AccountTriggerHelper.skipAll = true;
        ProgramTriggerHelper.skipTrigger = true;
        StrategicPlanTriggerHelper.skipTrigger = true;
        UserTriggerHelper.skipTrigger=true;
        User u = TestHelper.getAdminUser(true);
        System.runAs(u) {
            Account acc = TestHelper.getAccount(true); 
            Program__c prg = TestHelper.getProgram(acc.Id, true);
            System.debug('*** program test' + prg.id);
            List<String> selectedRecordIds = new List<String>();
            selectedRecordIds.add(prg.id);
            StrategicPlan__c obj = TestHelper.getStrategicPlan(true);
            StrategicPlanPrograms__c stpgm = new StrategicPlanPrograms__c(Program__c = prg.id,StrategicPlan__c = obj.id);
            insert stpgm;
            ApexPages.currentPage().getParameters().put('Id', obj.Id);
            PageReference p = Page.StrategicPlanView;
            Map<String,String> urlParams = new Map<String,String>();
            StrategicPlanProgramsActionHandler strategicplanLayoutactionhandler = new StrategicPlanProgramsActionHandler();
            strategicplanLayoutactionhandler.selectedRecordIds = selectedRecordIds;
            urlParams.put('parentid',obj.Id);
            strategicplanLayoutactionhandler.urlParams = urlParams;
            strategicplanLayoutactionhandler.clickHandler();           
        }
    }
}