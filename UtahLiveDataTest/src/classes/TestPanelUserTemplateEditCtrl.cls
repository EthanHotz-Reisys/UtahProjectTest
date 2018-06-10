@isTest
private class TestPanelUserTemplateEditCtrl{
    @isTest
    private static void testPanelUserTemplateEditCtrl(){
        User u = TestHelper.getAdminUser(true);
        System.runAs(u){
            Account a=TestHelper.getAccount(false);
            Program__c p = TestHelper.getProgram(a.id,false);
            ReviewStepTemplate__c template = TestHelper.getReviewStepTemplate(p.Id,true,'Application');
            ReviewPanelTemplate__c rpt = TestHelper.getReviewPanelTemplate(template.Id, 'Application', true);
            PanelUserTemplate__c put = TestHelper.getPanelUserTemplate(rpt.Id, true);
            ApexPages.StandardController stdController = new ApexPages.StandardController(put);
            PanelUserTemplateEditCtrl ctrl = new PanelUserTemplateEditCtrl(stdController);
            ctrl.getKeyValueMap();
        }
    }
}