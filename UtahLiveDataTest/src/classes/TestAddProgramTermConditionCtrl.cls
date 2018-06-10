@isTest
private class TestAddProgramTermConditionCtrl {

    static testMethod void myUnitTest() {
        
        AccountTriggerHelper.skipAll = true;
        ProgramTriggerHelper.skipTrigger = true;
        UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
        System.runAs(u) {
            UserTriggerHelper.skipTrigger = true;
            Account acc = TestHelper.getAccount(true); 
            Program__c prg = TestHelper.getProgram(acc.Id, true);
            TermCondition__c tandc = Testhelper.getTermCondition(true,'Term');
            List<String> selectedRecordIds = new List<String>();
            selectedRecordIds.add(tandc.id);
            TermCondition__c ptandc = TestHelper.getTermCondition(false,'Term');
            ptandc.Program__c = prg.id;
            insert ptandc;
            ApexPages.currentPage().getParameters().put('Id', prg.Id);
            PageReference p = Page.ProgramView;
            Map<String,String> urlParams = new Map<String,String>();
            AddProgramTermConditionCtrl addprogramtermandc = new AddProgramTermConditionCtrl();
            addprogramtermandc.selectedRecordIds = selectedRecordIds;
            urlParams.put('parentid',prg.Id);
            addprogramtermandc.urlParams = urlParams;
            addprogramtermandc.clickHandler();           
        }
    
    }
}