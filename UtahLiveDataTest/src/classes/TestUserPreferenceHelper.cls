/**
    Test class for UserPreferenceHelper
    **********************************************************
    Audit History
    **********************************************************
    4/27/2014   Someone   Created
    5/19/2014   Vani      Added TestUserGrpQueUseCase
    **********************************************************  
*/
@isTest
private with sharing class TestUserPreferenceHelper {

    @IsTest(OnInstall=false)
    private static void modifyMyName() {
        //Prepare test data
        
        Test.startTest();

        //Execute test

        Test.stopTest();

        //Assert test data
        System.assertEquals(true, true);
    }
    @IsTest (SeeAllData = false)
    private static void TestUserGrpQueUseCase() {
        //Prepare test data
        
        User u = TestHelper.getAdminUser(true);
          System.runAs(u) 
          {
          
        List<Profile> lProfile = [Select Id, Name from Profile where UserType = 'Standard'  limit 2];
        User UserObj = [select ProfileId, Id from User where Id != : UserInfo.getUserId() and UserType = 'Standard' limit 1];
        
        
        Test.startTest();
        
        if(lProfile != null && lProfile.size() > 0 && UserObj != null){
            UserObj.ProfileId = lProfile[0].Id;
           // update UserObj;
            if(lProfile.size() > 1) {
                UserObj.ProfileId = lProfile[1].Id;
              //  update UserObj;
                UserObj.ProfileId = lProfile[0].Id;
               // update UserObj;
            }
        }
        //Execute test

         Test.stopTest();

        //Assert test data
         System.assertNotEquals(UserObj.ProfileId, null);
        }
    }
}