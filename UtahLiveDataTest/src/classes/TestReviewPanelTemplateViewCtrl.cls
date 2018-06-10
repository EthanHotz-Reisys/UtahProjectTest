@isTest
private class TestReviewPanelTemplateViewCtrl{
    @isTest
    private static void testReviewPanelTemplateViewCtrl(){
        UserTriggerHelper.skipTrigger=true;
        User u = TestHelper.getAdminUser(true);
        System.runAs(u){
            Account a=TestHelper.getAccount(false);
            Program__c p = TestHelper.getProgram(a.id,false);
            ReviewStepTemplate__c template = TestHelper.getReviewStepTemplate(p.Id,true,'Application');
            ReviewPanelTemplate__c rpt = TestHelper.getReviewPanelTemplate(template.Id, 'Application', true);
            ApexPages.StandardController stdController = new ApexPages.StandardController(rpt);
            ReviewPanelTemplateViewCtrl ctrl = new ReviewPanelTemplateViewCtrl(stdController);
            ctrl.getKeyValueMap();
        }
    }
}