@isTest(SeeAllData=false)
private class TestTermConditionScheduleTrigger {
    @isTest(onInstall=false)
    public static void testAll() {                            
        Date startDate = System.today();
        Date endDate = startDate.addMonths(1);
        Date dueDate = endDate - 2 ; 
        Date taskDate = dueDate - 1;  
        TermConditionSchedule__c tcs = new TermConditionSchedule__c(StartDate__c = startDate, EndDate__c = endDate, 
                                                                    TaskCreationDate__c = taskDate, DueDate__c = dueDate);
        
        Test.startTest();
            
            try {

                insert tcs;
                tcs.EndDate__c =startDate.addMonths(2);
                update tcs;
            }
            catch (DmlException e) {
                system.debug(e.getMessage());
            }
            
        Test.stopTest();
    }
}