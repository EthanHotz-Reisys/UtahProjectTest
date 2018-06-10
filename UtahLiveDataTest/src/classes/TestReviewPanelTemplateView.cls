@isTest
private with sharing class TestReviewPanelTemplateView {

        @isTest
        private static void testAll(){
            UserTriggerHelper.skipTrigger=true;
            User u = TestHelper.getAdminUser(true);
            System.runAs(u){
                Account a=TestHelper.getAccount(false);
                Program__c p = TestHelper.getProgram(a.id,false);
                ReviewStepTemplate__c template = TestHelper.getReviewStepTemplate(p.Id,true,'Application');
                ReviewPanelTemplate__c rpt = TestHelper.getReviewPanelTemplate(template.Id, 'Application', true);
                ApexPages.StandardController stdController = new ApexPages.StandardController(rpt);
                ReviewPanelTemplateViewCtrl ctrl = new ReviewPanelTemplateViewCtrl(stdController);
            }
        }
}