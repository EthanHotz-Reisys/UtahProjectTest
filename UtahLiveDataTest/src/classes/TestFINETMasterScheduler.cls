@isTest
public class TestFINETMasterScheduler {
    @testSetup static void dataSetup() {
        FiscalYear__c fy = new FiscalYear__c(FiscalYearNumber__c = '2018');
        insert fy;
        AccountTriggerHelper.skipTrigger = true;
        AccountTriggerHelper.skipAll = true;
        Account acc = new Account(Code__c = '400', Name = 'TestAcc');
        insert acc;
        FINET_Integration__c intSetting = new FINET_Integration__c(
            Grantor_Client_Secret__c = 'T0k3nt1M3',
            Grantee_Client_Secret__c = 'T0k3nt1M3',
            Grantee_Integration_Root_URL__c = 'https://govgrants-esb.dev.utah.gov/grantee/v1/',
            Grantor_Integration_Root_URL__c = 'https://govgrants-esb.dev.utah.gov/grantor/v1/',
            Grantor_Client_ID__c = 'REI',
            Grantee_Client_ID__c = 'REI'
        );
        insert intSetting;
    }
    
    @isTest static void testFirstRun() {
    
        FINETBatchScheduleParent__c parent = new FINETBatchScheduleParent__c(IsRunning__c = true, ScheduleDate__c = DateTime.now().date());
        insert parent;
        
        Test.startTest();
        System.schedule('MasterBatchScheduler_' + getCronTime(), getCronTime() , new FINETMasterScheduler());
        Test.stopTest();
        
        
    }
    @isTest static void testBatchJobComplete() {
    
        FINETBatchScheduleParent__c parent = new FINETBatchScheduleParent__c(ScheduleDate__c = DateTime.now().date());
        insert parent;
        
        Test.setMock(HttpCalloutMock.class, new IntegCGIAdv_MockHTTPResponseGen('A'));
        
        Schema.DescribeFieldResult fieldResult = FINETBatchScheduleParent__c.ChildOrder__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        List<string> values = new List<string>();
        for (Schema.PicklistEntry entry : ple) { values.add(entry.getValue()); }
        List<FINETBatchScheduleChild__c> childList = new List<FINETBatchScheduleChild__c>();
        for (string value : values) {
            childList.add(new FINETBatchScheduleChild__c(Name = value, Status__c = 'Complete', Log__c = 'ayy', FINETBatchScheduleParent__c = parent.Id));
        }
        insert childList;
        
        Test.startTest();
        System.schedule('MasterBatchScheduler_' + getCronTime(), getCronTime() , new FINETMasterScheduler());
        Test.stopTest();
        
    }    
    
    private static string getCronTime() {
        DateTime newTime = DateTime.now().addMinutes(2);
        return '0 ' + newTime.minute() + ' ' + newTime.hour() + ' ' + newTime.day() + ' ' + newTime.month() + ' ? ' + newTime.year();
    }
}