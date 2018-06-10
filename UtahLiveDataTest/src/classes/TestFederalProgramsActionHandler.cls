@isTest
private class TestFederalProgramsActionHandler {

    static testMethod void myUnitTest() {
        /*
        AccountTriggerHelper.skipTrigger = true;
        ProgramTriggerhelper.skipTrigger = true;
        UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
        System.runAs(u) {
            Account acc = TestHelper.getAccount(true);
            Program__c prg = TestHelper.getProgram(acc.Id, true);
            JXPrograms__c fedpgm = new JXPrograms__c(FederalProgram__c = prg.id,StateProgram__c = prg.id);
            insert fedpgm;
            List<String> selectedRecordIds = new List<String>();
            selectedRecordIds.add(prg.id);
            ApexPages.currentPage().getParameters().put('Id', prg.Id);
            Map<String,String> urlParams = new Map<String,String>();
            FederalProgramsActionHandler pgmactionhandler = new FederalProgramsActionHandler();
            pgmactionhandler.selectedRecordIds = selectedRecordIds;
            urlParams.put('parentid',prg.Id);
            pgmactionhandler.urlParams = urlParams;
            pgmactionhandler.clickHandler();           
        }
    */
    
    }
}