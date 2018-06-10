@isTest
private class TestProgramContactsActionHandler {

    static testMethod void myUnitTest() {
        /*
        AccountTriggerHelper.skipTrigger = true;
        ProgramTriggerhelper.skipTrigger = true;
        
        User u = TestHelper.getAdminUser(true);
        System.runAs(u) {
            Account acc = TestHelper.getAccount(true);
            Contact con = TestHelper.getContact(true);
            Program__c prg = TestHelper.getProgram(acc.Id, true);
            ProgramContacts__c pgmcnt = new ProgramContacts__c(Contact__c =con.id ,Program__c = prg.id);
            insert pgmcnt;
            List<String> selectedRecordIds = new List<String>();
            selectedRecordIds.add(con.id);
            ApexPages.currentPage().getParameters().put('Id', prg.Id);
            Map<String,String> urlParams = new Map<String,String>();
            ProgramContactsActionHandler pgmconactionhandler = new ProgramContactsActionHandler();
            pgmconactionhandler.selectedRecordIds = selectedRecordIds;
            urlParams.put('parentid',prg.Id);
            pgmconactionhandler.urlParams = urlParams;
            pgmconactionhandler.clickHandler();           
        }
    
    */
    }
}