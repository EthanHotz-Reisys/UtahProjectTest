@isTest(SeeAllData = true)
public class TestBuildupItemTriggerHelper {

    public static testMethod void myUnitTest() {
        UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
        AnnouncementTriggerHelper.skipTrigger = true;
        RolesandResponsibilitiesTriggerHelper.skipTrigger = true;
        ApplicationTriggerHelper.skipTrigger = true;
        Announcement__c ann = TestHelper.getAnnouncement(true);
        Application__c app = TestHelper.getApplication(ann.id,true);
        BudgetCategory__c bc = [Select id from BudgetCategory__c where Type__c = 'Personnel' limit 1];
        BudgetCategory__c bc1 = [Select id from BudgetCategory__c where Type__c = 'Training' limit 1];
        BudgetCategory__c bc2 = [Select id from BudgetCategory__c where Type__c = 'Travel' limit 1];
        ApplicationBudgetCategory2__c appbc = new ApplicationBudgetCategory2__c(Amount__c=1000000000,Application__c=app.id, BudgetCategory__c = bc.Id);
        insert appbc;
        ApplicationBudgetCategory2__c appbc1 = new ApplicationBudgetCategory2__c(Amount__c=1000000000,Application__c=app.id, BudgetCategory__c = bc1.Id);
        insert appbc1;
        ApplicationBudgetCategory2__c appbc2 = new ApplicationBudgetCategory2__c(Amount__c=1000000000,Application__c=app.id, BudgetCategory__c = bc2.Id);
        insert appbc2;
        System.runAs(u){
            BuildUpItem__c buildupitem = new BuildUpItem__c(ApplicationBudgetCategory__c=appbc.id,Quantity__c=2,Title__c='buidupitem1',UnitPrice__c=2);
            insert buildupitem;
            buildupitem.Quantity__c=3;
            update buildupitem; 
            delete buildupitem;
            BuildUpItem__c buildupitem1 = new BuildUpItem__c(ApplicationBudgetCategory__c=appbc1.id,Quantity__c=2,Title__c='buidupitem1',UnitPrice__c=2);
            BuildUpItem__c buildupitem2 = new BuildUpItem__c(ApplicationBudgetCategory__c=appbc2.id,Quantity__c=2,Title__c='buidupitem1',UnitPrice__c=2);
            Test.startTest();
            insert buildupitem1;
            insert buildupitem2;
            Test.stopTest();
        }
    }
}