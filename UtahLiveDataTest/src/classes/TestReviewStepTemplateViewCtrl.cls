@isTest
private with sharing class TestReviewStepTemplateViewCtrl{
    @isTest
    private static void testReviewStepTemplateViewCtrl(){
         UserTriggerHelper.skipTrigger=true;
         User u=Testhelper.getAdminUser(true);
         System.runAs(u){
             TestHelper.createCustomSettings(true);
             Test.startTest();
//             Account acc=TestHelper.getAccount(true);
             Account acc = new Account();
             acc.Name = 'test'+system.currentTimeMillis();
             acc.status__c = 'Active';
             GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateAsGrantor');
             ProgramTriggerHelper.skipTrigger=true;
             
            // Program__c prog=Testhelper.getProgram(acc.Id,true);
             Program__c program = TestHelper.getGrantorProgram(acc.id,false);
             program.status__c = 'Active';
             insert program;
             ReviewStepTemplate__c reviewsteptemplate=Testhelper.getReviewStepTemplate(program.Id,true,'Application');
             ApexPages.CurrentPage().getParameters().put('id',reviewsteptemplate.id);
             ApexPages.StandardController stdController= new ApexPages.StandardController(reviewsteptemplate);
             ReviewStepTemplateViewCtrl rstvc=new ReviewStepTemplateViewCtrl(stdController);
             rstvc.getKeyValueMap();
             Test.stopTest();             
             System.assert(rstvc.recordId ==reviewsteptemplate.id);
         }
    }
}