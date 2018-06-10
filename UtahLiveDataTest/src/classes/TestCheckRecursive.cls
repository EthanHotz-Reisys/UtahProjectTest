@isTest
private with sharing class TestCheckRecursive{
    static testMethod void testrun() {
       
          User u = TestHelper.getAdminUser(true);
          System.runAs(u){
          
              Test.startTest();
              CheckRecursive.runOnce();
              CheckRecursive.run=false;
              CheckRecursive.runOnce();
              Test.stopTest();
          }
        
    }
}