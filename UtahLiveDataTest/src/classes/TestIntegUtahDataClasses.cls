@isTest
public class TestIntegUtahDataClasses {
    @testSetup static void dataSetup() {
        FiscalYear__c fy = new FiscalYear__c(FiscalYearNumber__c = '2018');
        insert fy;
        AccountTriggerHelper.skipTrigger = true;
        AccountTriggerHelper.skipAll = true;
        Account acc = new Account(Code__c = '400', Name = 'TestAcc');
        insert acc;

        Boolean sandbox = [SELECT Id, IsSandbox FROM Organization LIMIT 1].IsSandbox;
        FINET_URLs__c urls = new FINET_URLs__c(
            GranteeDevURL__c = 'https://govgrants-esb.dev.utah.gov/grantee/v1/',
            GrantorDevURL__c = 'https://govgrants-esb.dev.utah.gov/grantor/v1/',
            GrantorProdURL__c = 'https://govgrants-dasesb.utah.gov/grantor/v1/',
            GranteeProdURL__c = 'https://govgrants-dasesb.utah.gov/grantee/v1/'
        );
        insert urls;

        FINET_Batch_Settings__c batchSettings = new FINET_Batch_Settings__c(
            Batch_Retrieval_Hours__c = 36
        );
        insert batchSettings;

        FINET_Integration__c intSetting = new FINET_Integration__c(
            Grantor_Client_Secret__c = 'T0k3nt1M3',
            Grantee_Client_Secret__c = 'T0k3nt1M3',
            Grantee_Integration_Root_URL__c = sandbox ? Integ_CGIAdv_Utilities.granteeDevURL : Integ_CGIAdv_Utilities.granteeProdURL,
            Grantor_Integration_Root_URL__c = sandbox ? Integ_CGIAdv_Utilities.grantorDevURL : Integ_CGIAdv_Utilities.grantorProdURL,
            Grantor_Client_ID__c = 'REI',
            Grantee_Client_ID__c = 'REI'
        );
        insert intSetting;
    }
    
    @isTest static void UnitTest() {
    
        FINETBatchScheduleParent__c parent = new FINETBatchScheduleParent__c(isRunning__c = true);
        insert parent;
        FINETBatchScheduleChild__c child = new FINETBatchScheduleChild__c(
            FINETBatchScheduleParent__c = parent.Id, Status__c ='Processing', Name = 'IntegUtahUnitRequestBatch');
        insert child;

        PersistentBatchObject bo = new PersistentBatchObject(DateTime.now().addDays(-2), DateTime.now().addDays(-1),DateTime.now(), null);
        
        Test.setMock(HttpCalloutMock.class, new IntegCGIAdv_MockHTTPResponseGen('A'));
        
        Test.startTest();
        System.schedule(''+getCronTime(), getCronTime() , new IntegUtahUnitRequestBatch(null));
        Test.stopTest();
        
    }

    @isTest static void FundTest() {
    
        FINETBatchScheduleParent__c parent = new FINETBatchScheduleParent__c(isRunning__c = true);
        insert parent;
        List<FINETBatchScheduleChild__c> childList = new List<FINETBatchScheduleChild__c>();
        for (integer i = 0; i < 1; i++) {
            childList.add(new FINETBatchScheduleChild__c(
            FINETBatchScheduleParent__c = parent.Id, Status__c ='Complete', Name = 'DummyChild'));
        }
        childList.add(new FINETBatchScheduleChild__c(
            FINETBatchScheduleParent__c = parent.Id, Status__c ='Processing', Name = 'IntegUtahFundRequestBatch'));
        insert childList;

        PersistentBatchObject bo = new PersistentBatchObject(DateTime.now().addDays(-2), DateTime.now().addDays(-1),DateTime.now(), null);
        
        Test.setMock(HttpCalloutMock.class, new IntegCGIAdv_MockHTTPResponseGen('A'));
        
        Test.startTest();
        System.schedule(''+getCronTime(), getCronTime() , new IntegUtahFundRequestBatch(bo));
        Test.stopTest();
        
        
    }

    @isTest static void ApprTest() {
    
        FINETBatchScheduleParent__c parent = new FINETBatchScheduleParent__c(isRunning__c = true);
        insert parent;
        List<FINETBatchScheduleChild__c> childList = new List<FINETBatchScheduleChild__c>();
        for (integer i = 0; i < 2; i++) {
            childList.add(new FINETBatchScheduleChild__c(
            FINETBatchScheduleParent__c = parent.Id, Status__c ='Complete', Name = 'DummyChild'));
        }
        childList.add(new FINETBatchScheduleChild__c(
            FINETBatchScheduleParent__c = parent.Id, Status__c ='Processing', Name = 'IntegUtahAppropriationRequestBatch'));
        insert childList;

        PersistentBatchObject bo = new PersistentBatchObject(DateTime.now().addDays(-2), DateTime.now().addDays(-1),DateTime.now(), null);
        
        Test.setMock(HttpCalloutMock.class, new IntegCGIAdv_MockHTTPResponseGen('A'));
        
        Test.startTest();
        System.schedule(''+getCronTime(), getCronTime() , new IntegUtahAppropriationRequestBatch(bo));
        Test.stopTest();
        
    }

    @isTest static void ObjTest() {
    
        FINETBatchScheduleParent__c parent = new FINETBatchScheduleParent__c(isRunning__c = true);
        insert parent;
        List<FINETBatchScheduleChild__c> childList = new List<FINETBatchScheduleChild__c>();
        for (integer i = 0; i < 3; i++) {
            childList.add(new FINETBatchScheduleChild__c(
            FINETBatchScheduleParent__c = parent.Id, Status__c ='Complete', Name = 'DummyChild'));
        }
        childList.add(new FINETBatchScheduleChild__c(
            FINETBatchScheduleParent__c = parent.Id, Status__c ='Processing', Name = 'IntegUtahObjectRequestBatch'));
        insert childList;

        PersistentBatchObject bo = new PersistentBatchObject(DateTime.now().addDays(-2), DateTime.now().addDays(-1),DateTime.now(), null);
        
        Test.setMock(HttpCalloutMock.class, new IntegCGIAdv_MockHTTPResponseGen('A'));
        
        Test.startTest();
        System.schedule(''+getCronTime(), getCronTime() , new IntegUtahObjectRequestBatch(bo));
        Test.stopTest();
        
    }

    @isTest static void PGRPTest() {
    
        FINETBatchScheduleParent__c parent = new FINETBatchScheduleParent__c(isRunning__c = true);
        insert parent;
        List<FINETBatchScheduleChild__c> childList = new List<FINETBatchScheduleChild__c>();
        for (integer i = 0; i < 4; i++) {
            childList.add(new FINETBatchScheduleChild__c(
            FINETBatchScheduleParent__c = parent.Id, Status__c ='Complete', Name = 'DummyChild'));
        }
        childList.add(new FINETBatchScheduleChild__c(
            FINETBatchScheduleParent__c = parent.Id, Status__c ='Processing', Name = 'IntegUtahProgramGroupRequestBatch'));
        insert childList;

        PersistentBatchObject bo = new PersistentBatchObject(DateTime.now().addDays(-2), DateTime.now().addDays(-1),DateTime.now(), null);
        
        Test.setMock(HttpCalloutMock.class, new IntegCGIAdv_MockHTTPResponseGen('A'));
        
        Test.startTest();
        System.schedule(''+getCronTime(), getCronTime() , new IntegUtahProgramGroupRequestBatch(bo));
        Test.stopTest();
        
    }

    @isTest static void PTYPTest() {
    
        FINETBatchScheduleParent__c parent = new FINETBatchScheduleParent__c(isRunning__c = true);
        insert parent;
        List<FINETBatchScheduleChild__c> childList = new List<FINETBatchScheduleChild__c>();
        for (integer i = 0; i < 5; i++) {
            childList.add(new FINETBatchScheduleChild__c(
            FINETBatchScheduleParent__c = parent.Id, Status__c ='Complete', Name = 'DummyChild'));
        }
        childList.add(new FINETBatchScheduleChild__c(
            FINETBatchScheduleParent__c = parent.Id, Status__c ='Processing', Name = 'IntegUtahProgramTypeRequestBatch'));
        insert childList;

        PersistentBatchObject bo = new PersistentBatchObject(DateTime.now().addDays(-2), DateTime.now().addDays(-1),DateTime.now(), null);
        
        Test.setMock(HttpCalloutMock.class, new IntegCGIAdv_MockHTTPResponseGen('A'));
        
        Test.startTest();
        System.schedule(''+getCronTime(), getCronTime() , new IntegUtahProgramTypeRequestBatch(bo));
        Test.stopTest();
        
    }

    @isTest static void PCLSTest() {
    
        FINETBatchScheduleParent__c parent = new FINETBatchScheduleParent__c(isRunning__c = true);
        insert parent;
        List<FINETBatchScheduleChild__c> childList = new List<FINETBatchScheduleChild__c>();
        for (integer i = 0; i < 6; i++) {
            childList.add(new FINETBatchScheduleChild__c(
            FINETBatchScheduleParent__c = parent.Id, Status__c ='Complete', Name = 'DummyChild'));
        }
        childList.add(new FINETBatchScheduleChild__c(
            FINETBatchScheduleParent__c = parent.Id, Status__c ='Processing', Name = 'IntegUtahProgramClassRequestBatch'));
        insert childList;

        PersistentBatchObject bo = new PersistentBatchObject(DateTime.now().addDays(-2), DateTime.now().addDays(-1),DateTime.now(), null);
        
        Test.setMock(HttpCalloutMock.class, new IntegCGIAdv_MockHTTPResponseGen('A'));
        
        Test.startTest();
        System.schedule(''+getCronTime(), getCronTime() , new IntegUtahProgramClassRequestBatch(bo));
        Test.stopTest();
        
    }

    @isTest static void PCATTest() {
    
        FINETBatchScheduleParent__c parent = new FINETBatchScheduleParent__c(isRunning__c = true);
        insert parent;
        List<FINETBatchScheduleChild__c> childList = new List<FINETBatchScheduleChild__c>();
        for (integer i = 0; i < 7; i++) {
            childList.add(new FINETBatchScheduleChild__c(
            FINETBatchScheduleParent__c = parent.Id, Status__c ='Complete', Name = 'DummyChild'));
        }
        childList.add(new FINETBatchScheduleChild__c(
            FINETBatchScheduleParent__c = parent.Id, Status__c ='Processing', Name = 'IntegUtahProgramCategoryRequestBatch'));
        insert childList;

        PersistentBatchObject bo = new PersistentBatchObject(DateTime.now().addDays(-2), DateTime.now().addDays(-1),DateTime.now(), null);
        
        Test.setMock(HttpCalloutMock.class, new IntegCGIAdv_MockHTTPResponseGen('A'));
        
        Test.startTest();
        System.schedule(''+getCronTime(), getCronTime() , new IntegUtahProgramCategoryRequestBatch(bo));
        Test.stopTest();
        
    }

    @isTest static void MJRProgTest() {
    
        FINETBatchScheduleParent__c parent = new FINETBatchScheduleParent__c(isRunning__c = true);
        insert parent;
        List<FINETBatchScheduleChild__c> childList = new List<FINETBatchScheduleChild__c>();
        for (integer i = 0; i < 8; i++) {
            childList.add(new FINETBatchScheduleChild__c(
            FINETBatchScheduleParent__c = parent.Id, Status__c ='Complete', Name = 'DummyChild'));
        }
        childList.add(new FINETBatchScheduleChild__c(
            FINETBatchScheduleParent__c = parent.Id, Status__c ='Processing', Name = 'IntegUtahMajorProgramRequestBatch'));
        insert childList;

        PersistentBatchObject bo = new PersistentBatchObject(DateTime.now().addDays(-2), DateTime.now().addDays(-1),DateTime.now(), null);
        
        Test.setMock(HttpCalloutMock.class, new IntegCGIAdv_MockHTTPResponseGen('A'));
        
        Test.startTest();
        System.schedule(''+getCronTime(), getCronTime() , new IntegUtahMajorProgramRequestBatch(bo));
        Test.stopTest();
        
        
    }

    @isTest static void FundInfTest() {
    
        FINETBatchScheduleParent__c parent = new FINETBatchScheduleParent__c(isRunning__c = true);
        insert parent;
        List<FINETBatchScheduleChild__c> childList = new List<FINETBatchScheduleChild__c>();
        for (integer i = 0; i < 9; i++) {
            childList.add(new FINETBatchScheduleChild__c(
            FINETBatchScheduleParent__c = parent.Id, Status__c ='Complete', Name = 'DummyChild'));
        }
        childList.add(new FINETBatchScheduleChild__c(
            FINETBatchScheduleParent__c = parent.Id, Status__c ='Processing', Name = 'IntegUtahFundingInferenceRequestBatch'));
        insert childList;

        PersistentBatchObject bo = new PersistentBatchObject(DateTime.now().addDays(-2), DateTime.now().addDays(-1),DateTime.now(), null);
        
        Test.setMock(HttpCalloutMock.class, new IntegCGIAdv_MockHTTPResponseGen('A'));
        
        Test.startTest();
        System.schedule(''+getCronTime(), getCronTime() , new IntegUtahFundingInferenceRequestBatch(bo));
        Test.stopTest();
        
    }

    @isTest static void VendorTest() {
    
        FINETBatchScheduleParent__c parent = new FINETBatchScheduleParent__c(isRunning__c = true);
        insert parent;
        List<FINETBatchScheduleChild__c> childList = new List<FINETBatchScheduleChild__c>();
        for (integer i = 0; i < 10; i++) {
            childList.add(new FINETBatchScheduleChild__c(
            FINETBatchScheduleParent__c = parent.Id, Status__c ='Complete', Name = 'DummyChild'));
        }
        childList.add(new FINETBatchScheduleChild__c(
            FINETBatchScheduleParent__c = parent.Id, Status__c ='Processing', Name = 'IntegUtahVendorRequestBatch'));
        insert childList;

        PersistentBatchObject bo = new PersistentBatchObject(DateTime.now().addDays(-2), DateTime.now().addDays(-1),DateTime.now(), null);
        
        Test.setMock(HttpCalloutMock.class, new IntegCGIAdv_MockHTTPResponseGen('A'));
        
        Test.startTest();
        System.schedule(''+getCronTime(), getCronTime() , new IntegUtahVendorRequestBatch(bo));
        Test.stopTest();
        
        
    }

    @isTest static void AddressTest() {
    
        FINETBatchScheduleParent__c parent = new FINETBatchScheduleParent__c(isRunning__c = true);
        insert parent;
        List<FINETBatchScheduleChild__c> childList = new List<FINETBatchScheduleChild__c>();
        for (integer i = 0; i < 11; i++) {
            childList.add(new FINETBatchScheduleChild__c(
            FINETBatchScheduleParent__c = parent.Id, Status__c ='Complete', Name = 'DummyChild'));
        }
        childList.add(new FINETBatchScheduleChild__c(
            FINETBatchScheduleParent__c = parent.Id, Status__c ='Processing', Name = 'IntegUtahAddressRequestBatch'));
        insert childList;

        PersistentBatchObject bo = new PersistentBatchObject(DateTime.now().addDays(-2), DateTime.now().addDays(-1),DateTime.now(), null);
        
        Test.setMock(HttpCalloutMock.class, new IntegCGIAdv_MockHTTPResponseGen('A'));
        
        Test.startTest();
        System.schedule(''+getCronTime(), getCronTime() , new IntegUtahAddressRequestBatch(bo));
        Test.stopTest();
        
        
    }

    @isTest static void ProgramTest() {
        PersistentBatchObject bo = new PersistentBatchObject(DateTime.now().addDays(-2), DateTime.now().addDays(-1),DateTime.now(), null);
        
        Test.setMock(HttpCalloutMock.class, new IntegCGIAdv_MockHTTPResponseGen('A'));
        
        Test.startTest();
        System.schedule(''+getCronTime(), getCronTime() , new IntegUtahProgramRequestBatch(bo));
        Test.stopTest();
    }


    @isTest static void Unit404Test() {
        FINETBatchScheduleParent__c parent = new FINETBatchScheduleParent__c(isRunning__c = true);
        insert parent;
        FINETBatchScheduleChild__c child = new FINETBatchScheduleChild__c(
            FINETBatchScheduleParent__c = parent.Id, Status__c ='Processing', Name = 'IntegUtahUnitRequestBatch');
        insert child;

        PersistentBatchObject bo = new PersistentBatchObject(DateTime.now().addDays(-2), DateTime.now().addDays(-1),DateTime.now(), null);
        
        Test.setMock(HttpCalloutMock.class, new IntegCGIAdv_MockHTTPResponseGen('N'));
        
        Test.startTest();
        System.schedule(''+getCronTime(), getCronTime() , new IntegUtahUnitRequestBatch(null));
        Test.stopTest();
        
    }

    @isTest static void Fund404Test() {
        FINETBatchScheduleParent__c parent = new FINETBatchScheduleParent__c(isRunning__c = true);
        insert parent;
        List<FINETBatchScheduleChild__c> childList = new List<FINETBatchScheduleChild__c>();
        for (integer i = 0; i < 1; i++) {
            childList.add(new FINETBatchScheduleChild__c(
            FINETBatchScheduleParent__c = parent.Id, Status__c ='Complete', Name = 'DummyChild'));
        }
        childList.add(new FINETBatchScheduleChild__c(
            FINETBatchScheduleParent__c = parent.Id, Status__c ='Processing', Name = 'IntegUtahFundRequestBatch'));
        insert childList;

        PersistentBatchObject bo = new PersistentBatchObject(DateTime.now().addDays(-2), DateTime.now().addDays(-1),DateTime.now(), null);
        
        Test.setMock(HttpCalloutMock.class, new IntegCGIAdv_MockHTTPResponseGen('N'));
        
        Test.startTest();
        System.schedule(''+getCronTime(), getCronTime() , new IntegUtahFundRequestBatch(null));
        Test.stopTest();
    }

    @isTest static void Appr404Test() {
        FINETBatchScheduleParent__c parent = new FINETBatchScheduleParent__c(isRunning__c = true);
        insert parent;
        List<FINETBatchScheduleChild__c> childList = new List<FINETBatchScheduleChild__c>();
        for (integer i = 0; i < 2; i++) {
            childList.add(new FINETBatchScheduleChild__c(
            FINETBatchScheduleParent__c = parent.Id, Status__c ='Complete', Name = 'DummyChild'));
        }
        childList.add(new FINETBatchScheduleChild__c(
            FINETBatchScheduleParent__c = parent.Id, Status__c ='Processing', Name = 'IntegUtahAppropriationRequestBatch'));
        insert childList;

        PersistentBatchObject bo = new PersistentBatchObject(DateTime.now().addDays(-2), DateTime.now().addDays(-1),DateTime.now(), null);
        
        Test.setMock(HttpCalloutMock.class, new IntegCGIAdv_MockHTTPResponseGen('N'));
        
        Test.startTest();
        System.schedule(''+getCronTime(), getCronTime() , new IntegUtahAppropriationRequestBatch(null));
        Test.stopTest();
    }

    @isTest static void Obj404Test() {
        FINETBatchScheduleParent__c parent = new FINETBatchScheduleParent__c(isRunning__c = true);
        insert parent;
        List<FINETBatchScheduleChild__c> childList = new List<FINETBatchScheduleChild__c>();
        for (integer i = 0; i < 3; i++) {
            childList.add(new FINETBatchScheduleChild__c(
            FINETBatchScheduleParent__c = parent.Id, Status__c ='Complete', Name = 'DummyChild'));
        }
        childList.add(new FINETBatchScheduleChild__c(
            FINETBatchScheduleParent__c = parent.Id, Status__c ='Processing', Name = 'IntegUtahObjectRequestBatch'));
        insert childList;

        PersistentBatchObject bo = new PersistentBatchObject(DateTime.now().addDays(-2), DateTime.now().addDays(-1),DateTime.now(), null);
        
        Test.setMock(HttpCalloutMock.class, new IntegCGIAdv_MockHTTPResponseGen('N'));
        
        Test.startTest();
        System.schedule(''+getCronTime(), getCronTime() , new IntegUtahObjectRequestBatch(null));
        Test.stopTest();
    }

    @isTest static void PGRP404Test() {
        FINETBatchScheduleParent__c parent = new FINETBatchScheduleParent__c(isRunning__c = true);
        insert parent;
        List<FINETBatchScheduleChild__c> childList = new List<FINETBatchScheduleChild__c>();
        for (integer i = 0; i < 4; i++) {
            childList.add(new FINETBatchScheduleChild__c(
            FINETBatchScheduleParent__c = parent.Id, Status__c ='Complete', Name = 'DummyChild'));
        }
        childList.add(new FINETBatchScheduleChild__c(
            FINETBatchScheduleParent__c = parent.Id, Status__c ='Processing', Name = 'IntegUtahProgramGroupRequestBatch'));
        insert childList;

        PersistentBatchObject bo = new PersistentBatchObject(DateTime.now().addDays(-2), DateTime.now().addDays(-1),DateTime.now(), null);
        
        Test.setMock(HttpCalloutMock.class, new IntegCGIAdv_MockHTTPResponseGen('N'));
        
        Test.startTest();
        System.schedule(''+getCronTime(), getCronTime() , new IntegUtahProgramGroupRequestBatch(null));
        Test.stopTest();
    }

    @isTest static void PTYP404Test() {
        FINETBatchScheduleParent__c parent = new FINETBatchScheduleParent__c(isRunning__c = true);
        insert parent;
        List<FINETBatchScheduleChild__c> childList = new List<FINETBatchScheduleChild__c>();
        for (integer i = 0; i < 5; i++) {
            childList.add(new FINETBatchScheduleChild__c(
            FINETBatchScheduleParent__c = parent.Id, Status__c ='Complete', Name = 'DummyChild'));
        }
        childList.add(new FINETBatchScheduleChild__c(
            FINETBatchScheduleParent__c = parent.Id, Status__c ='Processing', Name = 'IntegUtahProgramTypeRequestBatch'));
        insert childList;

        PersistentBatchObject bo = new PersistentBatchObject(DateTime.now().addDays(-2), DateTime.now().addDays(-1),DateTime.now(), null);
        
        Test.setMock(HttpCalloutMock.class, new IntegCGIAdv_MockHTTPResponseGen('N'));
        
        Test.startTest();
        System.schedule(''+getCronTime(), getCronTime() , new IntegUtahProgramTypeRequestBatch(null));
        Test.stopTest();
    }

    @isTest static void PCLS404Test() {
        FINETBatchScheduleParent__c parent = new FINETBatchScheduleParent__c(isRunning__c = true);
        insert parent;
        List<FINETBatchScheduleChild__c> childList = new List<FINETBatchScheduleChild__c>();
        for (integer i = 0; i < 6; i++) {
            childList.add(new FINETBatchScheduleChild__c(
            FINETBatchScheduleParent__c = parent.Id, Status__c ='Complete', Name = 'DummyChild'));
        }
        childList.add(new FINETBatchScheduleChild__c(
            FINETBatchScheduleParent__c = parent.Id, Status__c ='Processing', Name = 'IntegUtahProgramClassRequestBatch'));
        insert childList;

        PersistentBatchObject bo = new PersistentBatchObject(DateTime.now().addDays(-2), DateTime.now().addDays(-1),DateTime.now(), null);
        
        Test.setMock(HttpCalloutMock.class, new IntegCGIAdv_MockHTTPResponseGen('N'));
        
        Test.startTest();
        System.schedule(''+getCronTime(), getCronTime() , new IntegUtahProgramClassRequestBatch(null));
        Test.stopTest();
    }

    @isTest static void PCAT404Test() {
        FINETBatchScheduleParent__c parent = new FINETBatchScheduleParent__c(isRunning__c = true);
        insert parent;
        List<FINETBatchScheduleChild__c> childList = new List<FINETBatchScheduleChild__c>();
        for (integer i = 0; i < 7; i++) {
            childList.add(new FINETBatchScheduleChild__c(
            FINETBatchScheduleParent__c = parent.Id, Status__c ='Complete', Name = 'DummyChild'));
        }
        childList.add(new FINETBatchScheduleChild__c(
            FINETBatchScheduleParent__c = parent.Id, Status__c ='Processing', Name = 'IntegUtahProgramCategoryRequestBatch'));
        insert childList;

        PersistentBatchObject bo = new PersistentBatchObject(DateTime.now().addDays(-2), DateTime.now().addDays(-1),DateTime.now(), null);
        
        Test.setMock(HttpCalloutMock.class, new IntegCGIAdv_MockHTTPResponseGen('N'));
        
        Test.startTest();
        System.schedule(''+getCronTime(), getCronTime() , new IntegUtahProgramCategoryRequestBatch(null));
        Test.stopTest();
    }

    @isTest static void MJRProg404Test() {
        FINETBatchScheduleParent__c parent = new FINETBatchScheduleParent__c(isRunning__c = true);
        insert parent;
        List<FINETBatchScheduleChild__c> childList = new List<FINETBatchScheduleChild__c>();
        for (integer i = 0; i < 8; i++) {
            childList.add(new FINETBatchScheduleChild__c(
            FINETBatchScheduleParent__c = parent.Id, Status__c ='Complete', Name = 'DummyChild'));
        }
        childList.add(new FINETBatchScheduleChild__c(
            FINETBatchScheduleParent__c = parent.Id, Status__c ='Processing', Name = 'IntegUtahMajorProgramRequestBatch'));
        insert childList;

        PersistentBatchObject bo = new PersistentBatchObject(DateTime.now().addDays(-2), DateTime.now().addDays(-1),DateTime.now(), null);
        
        Test.setMock(HttpCalloutMock.class, new IntegCGIAdv_MockHTTPResponseGen('N'));
        
        Test.startTest();
        System.schedule(''+getCronTime(), getCronTime() , new IntegUtahMajorProgramRequestBatch(null));
        Test.stopTest();
    }

    @isTest static void FundInf404Test() {
        FINETBatchScheduleParent__c parent = new FINETBatchScheduleParent__c(isRunning__c = true);
        insert parent;
        List<FINETBatchScheduleChild__c> childList = new List<FINETBatchScheduleChild__c>();
        for (integer i = 0; i < 9; i++) {
            childList.add(new FINETBatchScheduleChild__c(
            FINETBatchScheduleParent__c = parent.Id, Status__c ='Complete', Name = 'DummyChild'));
        }
        childList.add(new FINETBatchScheduleChild__c(
            FINETBatchScheduleParent__c = parent.Id, Status__c ='Processing', Name = 'IntegUtahFundingInferenceRequestBatch'));
        insert childList;

        PersistentBatchObject bo = new PersistentBatchObject(DateTime.now().addDays(-2), DateTime.now().addDays(-1),DateTime.now(), null);
        
        Test.setMock(HttpCalloutMock.class, new IntegCGIAdv_MockHTTPResponseGen('N'));
        
        Test.startTest();
        System.schedule(''+getCronTime(), getCronTime() , new IntegUtahFundingInferenceRequestBatch(null));
        Test.stopTest();
    }

    @isTest static void Vendor404Test() {
        FINETBatchScheduleParent__c parent = new FINETBatchScheduleParent__c(isRunning__c = true);
        insert parent;
        List<FINETBatchScheduleChild__c> childList = new List<FINETBatchScheduleChild__c>();
        for (integer i = 0; i < 10; i++) {
            childList.add(new FINETBatchScheduleChild__c(
            FINETBatchScheduleParent__c = parent.Id, Status__c ='Complete', Name = 'DummyChild'));
        }
        childList.add(new FINETBatchScheduleChild__c(
            FINETBatchScheduleParent__c = parent.Id, Status__c ='Processing', Name = 'IntegUtahVendorRequestBatch'));
        insert childList;

        PersistentBatchObject bo = new PersistentBatchObject(DateTime.now().addDays(-2), DateTime.now().addDays(-1),DateTime.now(), null);
        
        Test.setMock(HttpCalloutMock.class, new IntegCGIAdv_MockHTTPResponseGen('N'));
        
        Test.startTest();
        System.schedule(''+getCronTime(), getCronTime() , new IntegUtahVendorRequestBatch(null));
        Test.stopTest();
    }

    @isTest static void Address404Test1() {
    
        FINETBatchScheduleParent__c parent = new FINETBatchScheduleParent__c(isRunning__c = true);
        insert parent;
        List<FINETBatchScheduleChild__c> childList = new List<FINETBatchScheduleChild__c>();
        for (integer i = 0; i < 11; i++) {
            childList.add(new FINETBatchScheduleChild__c(
            FINETBatchScheduleParent__c = parent.Id, Status__c ='Complete', Name = 'DummyChild'));
        }
        childList.add(new FINETBatchScheduleChild__c(
            FINETBatchScheduleParent__c = parent.Id, Status__c ='Processing', Name = 'IntegUtahAddressRequestBatch'));
        insert childList;
        
        Test.setMock(HttpCalloutMock.class, new IntegCGIAdv_MockHTTPResponseGen('N'));
        
        Test.startTest();
        database.executeBatch( new IntegUtahAddressRequestBatch(null), Integ_CGIAdv_Utilities.batchSize );
        Test.stopTest();
        
    }

    @isTest static void Program404Test() {
        PersistentBatchObject bo = new PersistentBatchObject(DateTime.now().addDays(-2), DateTime.now().addDays(-1),DateTime.now(), null);
        
        Test.setMock(HttpCalloutMock.class, new IntegCGIAdv_MockHTTPResponseGen('N'));
        
        Test.startTest();
        System.schedule(''+getCronTime(), getCronTime() , new IntegUtahProgramRequestBatch(bo));
        Test.stopTest();
    }

    @isTest static void Address404Test2() {
    
        FINETBatchScheduleParent__c parent = new FINETBatchScheduleParent__c(isRunning__c = true);
        insert parent;
        List<FINETBatchScheduleChild__c> childList = new List<FINETBatchScheduleChild__c>();
        for (integer i = 0; i < 11; i++) {
            childList.add(new FINETBatchScheduleChild__c(
            FINETBatchScheduleParent__c = parent.Id, Status__c ='Complete', Name = 'DummyChild'));
        }
        childList.add(new FINETBatchScheduleChild__c(
            FINETBatchScheduleParent__c = parent.Id, Status__c ='Processing', Name = 'IntegUtahAddressRequestBatch'));
        insert childList;
        
        Test.setMock(HttpCalloutMock.class, new IntegCGIAdv_MockHTTPResponseGen('TM'));
        
        Test.startTest();
        database.executeBatch( new IntegUtahAddressRequestBatch(null), Integ_CGIAdv_Utilities.batchSize );
        Test.stopTest();
        
    }

    @isTest static void UnitCalloutExceptionTest() {
        FINETBatchScheduleParent__c parent = new FINETBatchScheduleParent__c(isRunning__c = true);
        insert parent;
        FINETBatchScheduleChild__c child = new FINETBatchScheduleChild__c(
            FINETBatchScheduleParent__c = parent.Id, Status__c ='Processing', Name = 'IntegUtahUnitRequestBatch');
        insert child;

        PersistentBatchObject bo = new PersistentBatchObject(DateTime.now().addDays(-2), DateTime.now().addDays(-1),DateTime.now(), null);
        
        Test.setMock(HttpCalloutMock.class, new IntegCGIAdv_MockHTTPResponseGen('Exceeded maximum time allotted for callout', true));
        
        Test.startTest();
        System.schedule(''+getCronTime(), getCronTime() , new IntegUtahUnitRequestBatch(null));
        Test.stopTest();
    }

    @isTest static void FundCalloutExceptionTest() {
        FINETBatchScheduleParent__c parent = new FINETBatchScheduleParent__c(isRunning__c = true);
        insert parent;
        List<FINETBatchScheduleChild__c> childList = new List<FINETBatchScheduleChild__c>();
        for (integer i = 0; i < 1; i++) {
            childList.add(new FINETBatchScheduleChild__c(
            FINETBatchScheduleParent__c = parent.Id, Status__c ='Complete', Name = 'DummyChild'));
        }
        childList.add(new FINETBatchScheduleChild__c(
            FINETBatchScheduleParent__c = parent.Id, Status__c ='Processing', Name = 'IntegUtahFundRequestBatch'));
        insert childList;

        PersistentBatchObject bo = new PersistentBatchObject(DateTime.now().addDays(-2), DateTime.now().addDays(-1),DateTime.now(), null);
        
        Test.setMock(HttpCalloutMock.class, new IntegCGIAdv_MockHTTPResponseGen('Exceeded maximum time allotted for callout', true));
        
        Test.startTest();
        System.schedule(''+getCronTime(), getCronTime() , new IntegUtahFundRequestBatch(null));
        Test.stopTest();
    }

    @isTest static void ApprCalloutExceptionTest() {
        FINETBatchScheduleParent__c parent = new FINETBatchScheduleParent__c(isRunning__c = true);
        insert parent;
        List<FINETBatchScheduleChild__c> childList = new List<FINETBatchScheduleChild__c>();
        for (integer i = 0; i < 2; i++) {
            childList.add(new FINETBatchScheduleChild__c(
            FINETBatchScheduleParent__c = parent.Id, Status__c ='Complete', Name = 'DummyChild'));
        }
        childList.add(new FINETBatchScheduleChild__c(
            FINETBatchScheduleParent__c = parent.Id, Status__c ='Processing', Name = 'IntegUtahAppropriationRequestBatch'));
        insert childList;

        PersistentBatchObject bo = new PersistentBatchObject(DateTime.now().addDays(-2), DateTime.now().addDays(-1),DateTime.now(), null);
        
        Test.setMock(HttpCalloutMock.class, new IntegCGIAdv_MockHTTPResponseGen('Exceeded maximum time allotted for callout', true));
        
        Test.startTest();
        System.schedule(''+getCronTime(), getCronTime() , new IntegUtahAppropriationRequestBatch(null));
        Test.stopTest();
    }

    @isTest static void ObjCalloutExceptionTest() {
        FINETBatchScheduleParent__c parent = new FINETBatchScheduleParent__c(isRunning__c = true);
        insert parent;
        List<FINETBatchScheduleChild__c> childList = new List<FINETBatchScheduleChild__c>();
        for (integer i = 0; i < 3; i++) {
            childList.add(new FINETBatchScheduleChild__c(
            FINETBatchScheduleParent__c = parent.Id, Status__c ='Complete', Name = 'DummyChild'));
        }
        childList.add(new FINETBatchScheduleChild__c(
            FINETBatchScheduleParent__c = parent.Id, Status__c ='Processing', Name = 'IntegUtahObjectRequestBatch'));
        insert childList;

        PersistentBatchObject bo = new PersistentBatchObject(DateTime.now().addDays(-2), DateTime.now().addDays(-1),DateTime.now(), null);
        
        Test.setMock(HttpCalloutMock.class, new IntegCGIAdv_MockHTTPResponseGen('Exceeded maximum time allotted for callout', true));
        
        Test.startTest();
        System.schedule(''+getCronTime(), getCronTime() , new IntegUtahObjectRequestBatch(null));
        Test.stopTest();
    }

    @isTest static void PGRPCalloutExceptionTest() {
        FINETBatchScheduleParent__c parent = new FINETBatchScheduleParent__c(isRunning__c = true);
        insert parent;
        List<FINETBatchScheduleChild__c> childList = new List<FINETBatchScheduleChild__c>();
        for (integer i = 0; i < 4; i++) {
            childList.add(new FINETBatchScheduleChild__c(
            FINETBatchScheduleParent__c = parent.Id, Status__c ='Complete', Name = 'DummyChild'));
        }
        childList.add(new FINETBatchScheduleChild__c(
            FINETBatchScheduleParent__c = parent.Id, Status__c ='Processing', Name = 'IntegUtahProgramGroupRequestBatch'));
        insert childList;

        PersistentBatchObject bo = new PersistentBatchObject(DateTime.now().addDays(-2), DateTime.now().addDays(-1),DateTime.now(), null);
        
        Test.setMock(HttpCalloutMock.class, new IntegCGIAdv_MockHTTPResponseGen('Exceeded maximum time allotted for callout', true));
        
        Test.startTest();
        System.schedule(''+getCronTime(), getCronTime() , new IntegUtahProgramGroupRequestBatch(null));
        Test.stopTest();
    }

    @isTest static void PTYPCalloutExceptionTest() {
        FINETBatchScheduleParent__c parent = new FINETBatchScheduleParent__c(isRunning__c = true);
        insert parent;
        List<FINETBatchScheduleChild__c> childList = new List<FINETBatchScheduleChild__c>();
        for (integer i = 0; i < 5; i++) {
            childList.add(new FINETBatchScheduleChild__c(
            FINETBatchScheduleParent__c = parent.Id, Status__c ='Complete', Name = 'DummyChild'));
        }
        childList.add(new FINETBatchScheduleChild__c(
            FINETBatchScheduleParent__c = parent.Id, Status__c ='Processing', Name = 'IntegUtahProgramTypeRequestBatch'));
        insert childList;

        PersistentBatchObject bo = new PersistentBatchObject(DateTime.now().addDays(-2), DateTime.now().addDays(-1),DateTime.now(), null);
        
        Test.setMock(HttpCalloutMock.class, new IntegCGIAdv_MockHTTPResponseGen('Exceeded maximum time allotted for callout', true));
        
        Test.startTest();
        System.schedule(''+getCronTime(), getCronTime() , new IntegUtahProgramTypeRequestBatch(null));
        Test.stopTest();
    }

    @isTest static void PCLSCalloutExceptionTest() {
        FINETBatchScheduleParent__c parent = new FINETBatchScheduleParent__c(isRunning__c = true);
        insert parent;
        List<FINETBatchScheduleChild__c> childList = new List<FINETBatchScheduleChild__c>();
        for (integer i = 0; i < 6; i++) {
            childList.add(new FINETBatchScheduleChild__c(
            FINETBatchScheduleParent__c = parent.Id, Status__c ='Complete', Name = 'DummyChild'));
        }
        childList.add(new FINETBatchScheduleChild__c(
            FINETBatchScheduleParent__c = parent.Id, Status__c ='Processing', Name = 'IntegUtahProgramClassRequestBatch'));
        insert childList;

        PersistentBatchObject bo = new PersistentBatchObject(DateTime.now().addDays(-2), DateTime.now().addDays(-1),DateTime.now(), null);
        
        Test.setMock(HttpCalloutMock.class, new IntegCGIAdv_MockHTTPResponseGen('Exceeded maximum time allotted for callout', true));
        
        Test.startTest();
        System.schedule(''+getCronTime(), getCronTime() , new IntegUtahProgramClassRequestBatch(null));
        Test.stopTest();
    }

    @isTest static void PCATCalloutExceptionTest() {
        FINETBatchScheduleParent__c parent = new FINETBatchScheduleParent__c(isRunning__c = true);
        insert parent;
        List<FINETBatchScheduleChild__c> childList = new List<FINETBatchScheduleChild__c>();
        for (integer i = 0; i < 7; i++) {
            childList.add(new FINETBatchScheduleChild__c(
            FINETBatchScheduleParent__c = parent.Id, Status__c ='Complete', Name = 'DummyChild'));
        }
        childList.add(new FINETBatchScheduleChild__c(
            FINETBatchScheduleParent__c = parent.Id, Status__c ='Processing', Name = 'IntegUtahProgramCategoryRequestBatch'));
        insert childList;

        PersistentBatchObject bo = new PersistentBatchObject(DateTime.now().addDays(-2), DateTime.now().addDays(-1),DateTime.now(), null);
        
        Test.setMock(HttpCalloutMock.class, new IntegCGIAdv_MockHTTPResponseGen('Exceeded maximum time allotted for callout', true));
        
        Test.startTest();
        System.schedule(''+getCronTime(), getCronTime() , new IntegUtahProgramCategoryRequestBatch(null));
        Test.stopTest();
    }

    @isTest static void MJRProgCalloutExceptionTest() {
        FINETBatchScheduleParent__c parent = new FINETBatchScheduleParent__c(isRunning__c = true);
        insert parent;
        List<FINETBatchScheduleChild__c> childList = new List<FINETBatchScheduleChild__c>();
        for (integer i = 0; i < 8; i++) {
            childList.add(new FINETBatchScheduleChild__c(
            FINETBatchScheduleParent__c = parent.Id, Status__c ='Complete', Name = 'DummyChild'));
        }
        childList.add(new FINETBatchScheduleChild__c(
            FINETBatchScheduleParent__c = parent.Id, Status__c ='Processing', Name = 'IntegUtahMajorProgramRequestBatch'));
        insert childList;

        PersistentBatchObject bo = new PersistentBatchObject(DateTime.now().addDays(-2), DateTime.now().addDays(-1),DateTime.now(), null);
        
        Test.setMock(HttpCalloutMock.class, new IntegCGIAdv_MockHTTPResponseGen('Exceeded maximum time allotted for callout', true));
        
        Test.startTest();
        System.schedule(''+getCronTime(), getCronTime() , new IntegUtahMajorProgramRequestBatch(null));
        Test.stopTest();
    }

    @isTest static void FundInfCalloutExceptionTest() {
        FINETBatchScheduleParent__c parent = new FINETBatchScheduleParent__c(isRunning__c = true);
        insert parent;
        List<FINETBatchScheduleChild__c> childList = new List<FINETBatchScheduleChild__c>();
        for (integer i = 0; i < 9; i++) {
            childList.add(new FINETBatchScheduleChild__c(
            FINETBatchScheduleParent__c = parent.Id, Status__c ='Complete', Name = 'DummyChild'));
        }
        childList.add(new FINETBatchScheduleChild__c(
            FINETBatchScheduleParent__c = parent.Id, Status__c ='Processing', Name = 'IntegUtahFundingInferenceRequestBatch'));
        insert childList;

        PersistentBatchObject bo = new PersistentBatchObject(DateTime.now().addDays(-2), DateTime.now().addDays(-1),DateTime.now(), null);
        
        Test.setMock(HttpCalloutMock.class, new IntegCGIAdv_MockHTTPResponseGen('Exceeded maximum time allotted for callout', true));
        
        Test.startTest();
        System.schedule(''+getCronTime(), getCronTime() , new IntegUtahFundingInferenceRequestBatch(null));
        Test.stopTest();
    }

    @isTest static void VendorCalloutExceptionTest() {
        FINETBatchScheduleParent__c parent = new FINETBatchScheduleParent__c(isRunning__c = true);
        insert parent;
        List<FINETBatchScheduleChild__c> childList = new List<FINETBatchScheduleChild__c>();
        for (integer i = 0; i < 10; i++) {
            childList.add(new FINETBatchScheduleChild__c(
            FINETBatchScheduleParent__c = parent.Id, Status__c ='Complete', Name = 'DummyChild'));
        }
        childList.add(new FINETBatchScheduleChild__c(
            FINETBatchScheduleParent__c = parent.Id, Status__c ='Processing', Name = 'IntegUtahVendorRequestBatch'));
        insert childList;

        PersistentBatchObject bo = new PersistentBatchObject(DateTime.now().addDays(-2), DateTime.now().addDays(-1),DateTime.now(), null);
        
        Test.setMock(HttpCalloutMock.class, new IntegCGIAdv_MockHTTPResponseGen('Exceeded maximum time allotted for callout', true));
        
        Test.startTest();
        System.schedule(''+getCronTime(), getCronTime() , new IntegUtahVendorRequestBatch(null));
        Test.stopTest();
    }

    @isTest static void AddressCalloutExceptionTest() {
        FINETBatchScheduleParent__c parent = new FINETBatchScheduleParent__c(isRunning__c = true);
        insert parent;
        List<FINETBatchScheduleChild__c> childList = new List<FINETBatchScheduleChild__c>();
        for (integer i = 0; i < 11; i++) {
            childList.add(new FINETBatchScheduleChild__c(
            FINETBatchScheduleParent__c = parent.Id, Status__c ='Complete', Name = 'DummyChild'));
        }
        childList.add(new FINETBatchScheduleChild__c(
            FINETBatchScheduleParent__c = parent.Id, Status__c ='Processing', Name = 'IntegUtahAddressRequestBatch'));
        insert childList;
        
        Test.setMock(HttpCalloutMock.class, new IntegCGIAdv_MockHTTPResponseGen('Exceeded maximum time allotted for callout', true));
        
        Test.startTest();
        database.executeBatch( new IntegUtahAddressRequestBatch(null), Integ_CGIAdv_Utilities.batchSize );
        Test.stopTest();
    }

    @isTest static void ProgramCalloutExceptionTest() {
        PersistentBatchObject bo = new PersistentBatchObject(DateTime.now().addDays(-2), DateTime.now().addDays(-1),DateTime.now(), null);
        
        Test.setMock(HttpCalloutMock.class, new IntegCGIAdv_MockHTTPResponseGen('Exceeded maximum time allotted for callout', true));
        
        Test.startTest();
        System.schedule(''+getCronTime(), getCronTime() , new IntegUtahProgramRequestBatch(bo));
        Test.stopTest();
    }

    private static string getCronTime() {
        DateTime newTime = DateTime.now().addMinutes(2);
        return '0 ' + newTime.minute() + ' ' + newTime.hour() + ' ' + newTime.day() + ' ' + newTime.month() + ' ? ' + newTime.year();
    }

}