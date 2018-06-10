@isTest
private class TestEventTrigger {
    
    @isTest static void test_method_one() {
    
        AccountTriggerHelper.skipAll = true;
        Account a = TestHelper.getAccount(true);
        Event e = new Event(whatId = a.Id, StartDateTime = System.now() + 1, EndDateTime = System.now() + 10);
        insert e;
        
    }
    
}