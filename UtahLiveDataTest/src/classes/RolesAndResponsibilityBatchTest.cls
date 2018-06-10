@isTest
public class RolesAndResponsibilityBatchTest {

    public static testMethod void test() {
        
        /*
        User u = TestHelper.getAdminUser(true); 
        
        System.runAs(u){
        AccountTriggerHelper.skipTrigger=true;
        RolesandResponsibilitiesTriggerHelper.skipTrigger=true;
        ApplicationTriggerHelper.skipTrigger=true;
        AnnouncementTriggerHelper.skipTrigger=true;
        
        Account acc = new Account();
        acc.Name = 'test'+system.currentTimeMillis();
        acc.status__c = 'Active';
        insert acc;
        
        Program__c program = TestHelper.getProgram(acc.id,false);
        program.status__c = 'Active';
        insert program;
        
        Announcement__c ann = TestHelper.getAnnouncement(true);
        Application__c app = TestHelper.getApplication(ann.Id,true);
        
        RolesAndResponsibilities__c objRolesAndRespnsibilities = TestHelper.getRolesAndResponsibilities(false,program.id);
        //objRolesAndRespnsibilities.Role__c='Fiscal';
        objRolesAndRespnsibilities.BusinessRole__c='Owner';
        objRolesAndRespnsibilities.BatchSharing__c = true;
        objRolesAndRespnsibilities.Application__c=app.Id;
        insert objRolesAndRespnsibilities;
     }
        RolesAndResponsibilityRecordSharingBatch objCls = new RolesAndResponsibilityRecordSharingBatch();
        Database.executeBatch(objCls);
        
        */
    }

}