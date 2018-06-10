@isTest
private class TestPreApplicationApprovalHelper{
    static Map<String,Object> testResult;
    @isTest
    private static void testPreApplicationApprovalHelper(){
        User u = TestHelper.getAdminUser(true);
        System.runAs(u){
            Test.startTest();
            TestHelper.createCustomSettings(true);
            PreApplication__c preapp = TestHelper.getPreApplication(true);
            ApexPages.CurrentPage().getParameters().put('id',preapp.Announcement__c);
            PreApplicationApprovalHelper paah = new PreApplicationApprovalHelper();
            paah.selectedRecordIds = new List<String>();
            paah.selectedRecordIds.add(preapp.id);  
            testResult = paah.clickHandler();
            Test.stopTest();
            System.assert(testResult != null);
        }
    } 
}