@isTest(Seealldata=true)
private with sharing class TestFieldSetsConfigSetupIconCtrl{
    
     static testMethod void someTest() {
      
        User u = TestHelper.getAdminUser(true);  
        System.runAs(u){
         
            Test.startTest();
            FieldSetsConfigSetupIconCtrl ctrl= new FieldSetsConfigSetupIconCtrl();
            FieldSetsConfigSetupIconCtrl.customObjectId = 'Test';
            FieldSetsConfigSetupIconCtrl.fieldSetId='Test';
            FieldSetsConfigSetupIconCtrl.customObFieldSet = 'Test';
            FieldSetsConfigSetupIconCtrl.readFieldSetSync('Test','Test1');
            Test.stopTest();
            
         }
    }
    
    
}