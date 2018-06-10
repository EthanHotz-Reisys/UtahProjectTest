/**
* TEST CLASS FOR REVIEWASSIGNMENTADDCTRL
*
* CHANGE HISTORY
*================================================================ 
* 04/30/2014    Kunal Shah            Created 
*================================================================
*/
@isTest
private with sharing class TestReviewAssignmentAddCtrl {
	
	@isTest
	public static void test_cntr(){
		Test.startTest();
		ReviewAssignmentAddCtrl ctrl = new ReviewAssignmentAddCtrl();
		ctrl.getUsers();
		ctrl.findAddedUsers();
		ctrl.Cancel();
		ctrl.addToReviewStepApplication();
		Test.stopTest();
	}
}