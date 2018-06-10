/**
    Test class for ReviewAssignment
    **********************************************************
    Audit History
    **********************************************************
    
    4/28/2014   Manasi Gangal            04/28/2014
    **********************************************************  
*/
@isTest
private class TestReviewAssignmentTriggerHelper{

     @isTest
    static void testAll(){
    User u = TestHelper.getAdminUser(true);

        System.runAs(u) {
        	//ReviewAssignmentTriggerHelper review = new ReviewAssignmentTriggerHelper();
        	}
        }
}