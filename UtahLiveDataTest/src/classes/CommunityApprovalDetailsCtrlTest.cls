@isTest
public class CommunityApprovalDetailsCtrlTest {
    public static testMethod void test() {
        UserRegistration__c objUserRegistration = Testhelper.getUserRegistration(true);
        Apexpages.StandardController objStdController = new Apexpages.StandardController(objUserRegistration);
        CommunityApprovalDetailsCtrl objCls = new CommunityApprovalDetailsCtrl(objStdController);
      /*  ProcessInstance objProcessInstance = new ProcessInstance();
        objProcessInstance.TargetObjectId = objUserRegistration.id;
        insert objProcessInstance;
        
        ApexPages.currentPage().getParameters().put('Id',objProcessInstance.id);
        
        ProcessInstanceWorkitem objWorkItem = Testhelper.getWorkItem();
        objWorkItem.ProcessInstanceId = objProcessInstance.id;
        insert objWorkItem; */
        
        objCls.cancelPage();
        objCls.approveRecord();
        objCls.rejectRecord();
    }
}