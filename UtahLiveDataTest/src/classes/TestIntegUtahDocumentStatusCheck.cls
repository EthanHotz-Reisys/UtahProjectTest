@isTest
private class TestIntegUtahDocumentStatusCheck {

    @testSetup static void dataSetup() {
        FiscalYear__c fy = new FiscalYear__c(FiscalYearNumber__c = '2018');
        insert fy;
        FINET_Integration__c intSetting = new FINET_Integration__c(
            Grantor_Client_Secret__c = 'T0k3nt1M3',
            Grantee_Client_Secret__c = 'T0k3nt1M3',
            Grantee_Integration_Root_URL__c = 'https://govgrants-esb.dev.utah.gov/grantee/v1/',
            Grantor_Integration_Root_URL__c = 'https://govgrants-esb.dev.utah.gov/grantor/v1/',
            Grantor_Client_ID__c = 'REI',
            Grantee_Client_ID__c = 'REI'
        );
        insert intSetting;

        insert new FINET_URLs__c(
            GranteeDevURL__c = 'https://govgrants-esb.dev.utah.gov/grantee/v1/',
            GrantorDevURL__c = 'https://govgrants-esb.dev.utah.gov/grantor/v1/',
            GrantorProdURL__c = 'https://govgrants-dasesb.utah.gov/grantor/v1/',
            GranteeProdURL__c = 'https://govgrants-dasesb.utah.gov/grantee/v1/'
        );
    }
    
    @isTest static void GCAMSuccessTest() {
        AccountTriggerHelper.skipAll = true;
        AccountTriggerHelper.skipTrigger = true;
        Account acc = new Account(Code__c = '400', Name = 'TestAcc');
        insert acc;
        r_mjr_prog__c mjrProg = new r_mjr_prog__c();
        insert mjrProg;
        //new parent/child objects, program
        r_prog__c prog = new r_prog__c(
            DEPT_CD__c = acc.Id,
            FINETMajorProgram__c = mjrProg.Id,
            PROG_CD__c = '17PPC',
            PROG_NM__c = 'TestName',
            PROG_SH_NM__c = 'Test'
        );
        insert prog;
        Grants_API_Document_Status__c parent = new Grants_API_Document_Status__c(
            Document_Transmission_Date__c = DateTime.now(),
            GovGrants_DOC_ID__c = prog.Id, 
            Grants_API_Document_Dept_CD__c = '400',
            Grants_API_Document_Type__c = 'GCAM',
            Needs_Status_Check__c = true,
            Document_Transmission_Date_in_MS__c	= 100000
        );
        insert parent;
        Grants_API_Document_Status_Detail__c child = new Grants_API_Document_Status_Detail__c(
            Grants_API_Document_Status__c = parent.Id,
            Active__c = true,
            Grants_API_Document_Item_ID__c = prog.Id
        );
        insert child;
        List<Grants_API_Document_Status__c> parentList = new List<Grants_API_Document_Status__c>();
        parentList.add(parent);
        Test.setMock(HttpCalloutMock.class, new Integ_DocumentStatusMock(200, false, 'GCAM'));
        Test.startTest();
        IntegUtahGCAMStatusCheck.getStatus(parentList);
        Test.stopTest();
    }

    @isTest static void GAXSuccessTest() {
        AccountTriggerHelper.skipAll = true;
        AccountTriggerHelper.skipTrigger = true;
        Account acc = new Account(Code__c = '400', Name = 'TestAcc');
        insert acc;
        r_mjr_prog__c mjrProg = new r_mjr_prog__c();
        insert mjrProg;
        //new parent/child objects, program
        r_prog__c prog = new r_prog__c(
            DEPT_CD__c = acc.Id,
            FINETMajorProgram__c = mjrProg.Id,
            PROG_CD__c = '17PPC',
            PROG_NM__c = 'TestName',
            PROG_SH_NM__c = 'Test'
        );
        insert prog;
        Grants_API_Document_Status__c parent = new Grants_API_Document_Status__c(
            Document_Transmission_Date__c = DateTime.now(),
            GovGrants_DOC_ID__c = prog.Id,
            Grants_API_Document_Dept_CD__c = '400',
            Grants_API_Document_Type__c = 'GAX',
            Needs_Status_Check__c = true,
            Document_Transmission_Date_in_MS__c	= 100000
        );
        insert parent;
        Grants_API_Document_Status_Detail__c child = new Grants_API_Document_Status_Detail__c(
            Grants_API_Document_Status__c = parent.Id,
            Active__c = true,
            Grants_API_Document_Item_ID__c = prog.Id
        );
        insert child;
        List<Grants_API_Document_Status__c> parentList = new List<Grants_API_Document_Status__c>();
        parentList.add(parent);
        Test.setMock(HttpCalloutMock.class, new Integ_DocumentStatusMock(200, false, 'GAX'));
        Test.startTest();
        IntegUtahGAXStatusCheck.getStatus(parentList);
        Test.stopTest();
    }

    @isTest static void IETSuccessTest() {
        AccountTriggerHelper.skipAll = true;
        AccountTriggerHelper.skipTrigger = true;
        Account acc = new Account(Code__c = '400', Name = 'TestAcc');
        insert acc;
        r_mjr_prog__c mjrProg = new r_mjr_prog__c();
        insert mjrProg;
        //new parent/child objects, program
        r_prog__c prog = new r_prog__c(
            DEPT_CD__c = acc.Id,
            FINETMajorProgram__c = mjrProg.Id,
            PROG_CD__c = '17PPC',
            PROG_NM__c = 'TestName',
            PROG_SH_NM__c = 'Test'
        );
        insert prog;
        Grants_API_Document_Status__c parent = new Grants_API_Document_Status__c(
            Document_Transmission_Date__c = DateTime.now(),
            GovGrants_DOC_ID__c = prog.Id,
            Grants_API_Document_Dept_CD__c = '400',
            Grants_API_Document_Type__c = 'IET',
            Needs_Status_Check__c = true,
            Document_Transmission_Date_in_MS__c	= 100000
        );
        insert parent;
        Grants_API_Document_Status_Detail__c child = new Grants_API_Document_Status_Detail__c(
            Grants_API_Document_Status__c = parent.Id,
            Active__c = true,
            Grants_API_Document_Item_ID__c = prog.Id
        );
        insert child;
        List<Grants_API_Document_Status__c> parentList = new List<Grants_API_Document_Status__c>();
        parentList.add(parent);
        Test.setMock(HttpCalloutMock.class, new Integ_DocumentStatusMock(200, false, 'IET'));
        Test.startTest();
        IntegUtahIETStatusCheck.getStatus(parentList);
        Test.stopTest();
    }

    @isTest static void doc404Test() {
        AccountTriggerHelper.skipAll = true;
        AccountTriggerHelper.skipTrigger = true;
        Account acc = new Account(Code__c = '400', Name = 'TestAcc');
        insert acc;
        r_mjr_prog__c mjrProg = new r_mjr_prog__c();
        insert mjrProg;
        //new parent/child objects, program
        r_prog__c prog = new r_prog__c(
            DEPT_CD__c = acc.Id,
            FINETMajorProgram__c = mjrProg.Id,
            PROG_CD__c = '17PPC',
            PROG_NM__c = 'TestName',
            PROG_SH_NM__c = 'Test'
        );
        insert prog;
        Grants_API_Document_Status__c parent = new Grants_API_Document_Status__c(
            Document_Transmission_Date__c = DateTime.now(),
            GovGrants_DOC_ID__c = prog.Id,
            Grants_API_Document_Dept_CD__c = '400',
            Grants_API_Document_Type__c = 'GCAM',
            Needs_Status_Check__c = true,
            Document_Transmission_Date_in_MS__c	= 100000
        );
        insert parent;
        Grants_API_Document_Status_Detail__c child = new Grants_API_Document_Status_Detail__c(
            Grants_API_Document_Status__c = parent.Id,
            Active__c = true,
            Grants_API_Document_Item_ID__c = prog.Id
        );
        insert child;
        List<Grants_API_Document_Status__c> parentList = new List<Grants_API_Document_Status__c>();
        parentList.add(parent);
        Test.setMock(HttpCalloutMock.class, new Integ_DocumentStatusMock(404, false, 'GCAM'));
        Test.startTest();
        IntegUtahGCAMStatusCheck.getStatus(parentList);
        Test.stopTest();
    }

    @isTest static void doc500Test() {
        AccountTriggerHelper.skipAll = true;
        AccountTriggerHelper.skipTrigger = true;
        Account acc = new Account(Code__c = '400', Name = 'TestAcc');
        insert acc;
        r_mjr_prog__c mjrProg = new r_mjr_prog__c();
        insert mjrProg;
        //new parent/child objects, program
        r_prog__c prog = new r_prog__c(
            DEPT_CD__c = acc.Id,
            FINETMajorProgram__c = mjrProg.Id,
            PROG_CD__c = '17PPC',
            PROG_NM__c = 'TestName',
            PROG_SH_NM__c = 'Test'
        );
        insert prog;
        Grants_API_Document_Status__c parent = new Grants_API_Document_Status__c(
            Document_Transmission_Date__c = DateTime.now(),
            GovGrants_DOC_ID__c = prog.Id,
            Grants_API_Document_Dept_CD__c = '400',
            Grants_API_Document_Type__c = 'GCAM',
            Needs_Status_Check__c = true,
            Document_Transmission_Date_in_MS__c	= 100000
        );
        insert parent;
        Grants_API_Document_Status_Detail__c child = new Grants_API_Document_Status_Detail__c(
            Grants_API_Document_Status__c = parent.Id,
            Active__c = true,
            Grants_API_Document_Item_ID__c = prog.Id
        );
        insert child;
        List<Grants_API_Document_Status__c> parentList = new List<Grants_API_Document_Status__c>();
        parentList.add(parent);
        Test.setMock(HttpCalloutMock.class, new Integ_DocumentStatusMock(500, false, 'GCAM'));
        Test.startTest();
        IntegUtahGCAMStatusCheck.getStatus(parentList);
        Test.stopTest();
    }

    @isTest static void timeoutTest() {
        AccountTriggerHelper.skipAll = true;
        AccountTriggerHelper.skipTrigger = true;
        Account acc = new Account(Code__c = '400', Name = 'TestAcc');
        insert acc;
        r_mjr_prog__c mjrProg = new r_mjr_prog__c();
        insert mjrProg;
        //new parent/child objects, program
        r_prog__c prog = new r_prog__c(
            DEPT_CD__c = acc.Id,
            FINETMajorProgram__c = mjrProg.Id,
            PROG_CD__c = '17PPC',
            PROG_NM__c = 'TestName',
            PROG_SH_NM__c = 'Test'
        );
        insert prog;
        Grants_API_Document_Status__c parent = new Grants_API_Document_Status__c(
            Document_Transmission_Date__c = DateTime.now(),
            GovGrants_DOC_ID__c = prog.Id,
            Grants_API_Document_Dept_CD__c = '400',
            Grants_API_Document_Type__c = 'GCAM',
            Needs_Status_Check__c = true,
            Document_Transmission_Date_in_MS__c	= 100000
        );
        insert parent;
        Grants_API_Document_Status_Detail__c child = new Grants_API_Document_Status_Detail__c(
            Grants_API_Document_Status__c = parent.Id,
            Active__c = true,
            Grants_API_Document_Item_ID__c = prog.Id
        );
        insert child;
        List<Grants_API_Document_Status__c> parentList = new List<Grants_API_Document_Status__c>();
        parentList.add(parent);
        Test.setMock(HttpCalloutMock.class, new Integ_DocumentStatusMock(404, true, 'GCAM'));
        Test.startTest();
        IntegUtahGCAMStatusCheck.getStatus(parentList);
        Test.stopTest();
    }
}