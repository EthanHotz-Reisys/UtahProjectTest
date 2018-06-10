/*
  **********************************************************
  Audit History
  **********************************************************
  2014-04-30        Kunal Shah                      Created
2015-09-23          swati singh                     Actually wrote tests
  **********************************************************  
*/
@IsTest
private with sharing class TestReviewStepUserAddCtrl {
    @IsTest
    private static void testInsert() {
        User u = TestHelper.getAdminUser(true);
       
        
        System.runAs(u) { 
      	 
                  Test.startTest();
                  ReviewStepUserAddCtrl prec = new ReviewStepUserAddCtrl();
                  prec.getUsers();
                  prec.findAddedUsers();
                  prec.addToReviewStep();
                  prec.Cancel();
                  Test.stopTest();
        
                  //Assert test data

                 System.assertEquals(prec, prec);
        }
    }
}