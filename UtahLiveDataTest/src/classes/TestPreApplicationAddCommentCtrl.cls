@isTest
private with sharing class TestPreApplicationAddCommentCtrl{
    
    @isTest
    private static void testAll(){
        user u = testHelper.getAdminUser(false);
        system.runAs(u){
            test.startTest();
            TestHelper.CreateCustomSettings(true);
            preApplication__c preApp = testHelper.getPreApplication(true);
            ApexPages.CurrentPage().getParameters().put('id',preApp.id);
            PreApplicationAddCommentCtrl ctrl = new PreApplicationAddCommentCtrl();
            ctrl.btnAddComment();
            ctrl.btnCancel();    
            test.stopTest(); 
            system.assertNotEquals(ctrl.selectedPreApp,null);       
        }
    }

}