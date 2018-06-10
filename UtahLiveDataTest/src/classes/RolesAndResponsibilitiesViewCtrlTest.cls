@isTest
public class RolesAndResponsibilitiesViewCtrlTest {
    static testMethod void someTest() {
        // RolesAndResponsibilities__c name object not available in the sandbox and in the same name object creation
        // code also not available in the GNT.TestHelper class method.
      RolesAndResponsibilities__c rolesAndResponsibilities1 = null;
      RolesandResponsibilitiesTriggerHelper.skipTrigger = true;
      User u = new User(Id=UserInfo.getUserId());
      AccountTriggerHelper.skipAll=true;
      System.runAs(u){
        StrategicPlan__c splan = TestHelper.getStrategicPlan(true);
        rolesAndResponsibilities1 = new RolesAndResponsibilities__c(StrategicPlan__c = splan.Id,
                                                                            BusinessRole__c='Key POC',Name__c = splan.StrategyOwner__c);
        insert rolesAndResponsibilities1;
      }
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.standardController(rolesAndResponsibilities1);
        ApexPages.currentPage().getParameters().put('Id',rolesAndResponsibilities1.id);
        RolesAndResponsibilitiesViewCtrl e = new RolesAndResponsibilitiesViewCtrl(sc);
        e.getKeyValueMap();
        Test.stopTest();
    }
}