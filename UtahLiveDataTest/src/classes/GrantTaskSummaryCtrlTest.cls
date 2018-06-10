@isTest
public class GrantTaskSummaryCtrlTest {

	public static testMethod void test() {
	    User u = TestHelper.getAdminUser(true);
	     System.runAs(u){
        TestHelper.getUserPreference(true,'ActiveAppName__c','StateasGrantor');
        TestHelper.getCustomAppConfig(true);
        //TestHelper.getCustomAppPhaseConfig(true);
        GNT__CustomAppPhaseConfig__c objAppPhaseConfig =  TestHelper.getCustomAppPhaseConfig(false);
        objAppPhaseConfig.GNT__isPhase__c = true;
        insert objAppPhaseConfig;
        /*Task objTask = TestHelper.getTask(false);
        objTask.GNT__PhaseName__c = 'Planning';
        insert objTask;*/
        GrantTaskSummaryCtrl objClass = new GrantTaskSummaryCtrl();
        objClass.getUserType();
	     }
	}

}