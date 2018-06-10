/***********************************************************************************
This is a test class to test ScheduleReviewGroupAutoCreate
****************************************************************************************
5-01-2014       Hafsa Syed      Created
***************************************************************************************
*/
 
@isTest(SeeAllData=false)

private class TestScheduleReviewGroupAutoCreate {

    @isTest(OnInstall=false)
    static void myUnitTest1() {        
        Test.startTest();  
      ScheduleReviewGroupAutoCreate srgac = new ScheduleReviewGroupAutoCreate();           
      ScheduleReviewGroupAutoCreate.scheduleJob();          
      Test.stopTest();    
       // system.assertNotEquals(srgac,null);                
    }    
}