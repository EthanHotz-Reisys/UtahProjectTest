/**
* TEST CLASS FOR REVIEWASSIGNMENTADDCTRL
*
* CHANGE HISTORY
*================================================================ 
* 05/05/2014    Kunal Shah            Created 
*================================================================
*/

@isTest
private with sharing class TestReviewAssignmentsSendCtrl {
    @IsTest(OnInstall=false)
    public static void test_ctor(){
    	Test.startTest();
        ReviewAssignmentsSendCtrl ctrl = new ReviewAssignmentsSendCtrl();
        ctrl.Cancel();
        ctrl.findSentProposals();
        ctrl.getProposals();
        ctrl.sendProposals();
        Test.stopTest();
    }
    
}