@isTest
public class TaskDueDateFlexTableCtrlTest {

	public static testMethod void test() {
	    Testhelper.getCustomAppConfig(true);

        GNT__CustomAppPhaseConfig__c objCustomAppPhaseConfig = Testhelper.getCustomAppPhaseConfig(false);
        objCustomAppPhaseConfig.GNT__isPhase__c = true;
        insert objCustomAppPhaseConfig;
        
         TestHelper.getUserPreference(true,'ActiveAppName__c','StateasGrantor');
         ApexPages.currentPage().getParameters().put('flexTableName','TasksDueInSevenDays');
         Task objTask = Testhelper.getTask(false);
         objTask.GNT__PhaseName__c = 'Planning';
         objTask.ActivityDate = system.today().adddays(-1);
         objTask.Status = 'Not Started';
         objTask.ownerid = UserInfo.getUserId();
         insert objTask;
         
         system.debug('Test Task@@@@'+objTask.ownerid+'---'+objTask.GNT__LateTasks__c+'-----'+objTask.GNT__PhaseName__c+'-----'+objTask.Status);
         
        
             TaskDueDateFlexTableCtrl objCls = new TaskDueDateFlexTableCtrl();
             objCls.getListParams();
         
         
        
	}
	
	public static testMethod void test2() {
	    Testhelper.getCustomAppConfig(true);

        GNT__CustomAppPhaseConfig__c objCustomAppPhaseConfig = Testhelper.getCustomAppPhaseConfig(false);
        objCustomAppPhaseConfig.GNT__isPhase__c = true;
        insert objCustomAppPhaseConfig;
        
         TestHelper.getUserPreference(true,'ActiveAppName__c','StateasGrantor');
         ApexPages.currentPage().getParameters().put('flexTableName','TasksDueInThirtyDays');
         Task objTask = Testhelper.getTask(false);
         objTask.GNT__PhaseName__c = 'Planning';
         objTask.ActivityDate = system.today().adddays(-1);
         objTask.Status = 'Not Started';
         objTask.ownerid = UserInfo.getUserId();
         insert objTask;
         
         system.debug('Test Task@@@@'+objTask.ownerid+'---'+objTask.GNT__LateTasks__c+'-----'+objTask.GNT__PhaseName__c+'-----'+objTask.Status);
         
        
             TaskDueDateFlexTableCtrl objCls = new TaskDueDateFlexTableCtrl();
             objCls.getListParams();
         
         
        
	}
	
	public static testMethod void test3() {
	    Testhelper.getCustomAppConfig(true);

        GNT__CustomAppPhaseConfig__c objCustomAppPhaseConfig = Testhelper.getCustomAppPhaseConfig(false);
        objCustomAppPhaseConfig.GNT__isPhase__c = true;
        insert objCustomAppPhaseConfig;
        
         TestHelper.getUserPreference(true,'ActiveAppName__c','StateasGrantor');
         ApexPages.currentPage().getParameters().put('flexTableName','TasksAllOthers');
         Task objTask = Testhelper.getTask(false);
         objTask.GNT__PhaseName__c = 'Planning';
         objTask.ActivityDate = system.today().adddays(-1);
         objTask.Status = 'Not Started';
         objTask.ownerid = UserInfo.getUserId();
         insert objTask;
         
         system.debug('Test Task@@@@'+objTask.ownerid+'---'+objTask.GNT__LateTasks__c+'-----'+objTask.GNT__PhaseName__c+'-----'+objTask.Status);
         
        
             TaskDueDateFlexTableCtrl objCls = new TaskDueDateFlexTableCtrl();
             objCls.getListParams();
         
         
        
	}

}