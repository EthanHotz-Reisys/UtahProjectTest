@isTest
public with sharing class TestDunsEinVerifyHelper {

static UserRegistration__c uReg=null;
static GNT.DynamicLayoutHolder layoutHolder=null;
static SamGovEntityCredentials__c samGov=null;
static DunsEinVerifyHelper dunsHelper=null;
static  ExternalInterfaces__c sfInterfaces;
static InterfaceConfig__c iConfig;

static void createData(String recordName) {
        UserRegistrationTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
        
        
        System.runAs(u){
        
            RecordType rec=[Select Id From RecordType  Where SobjectType = 'UserRegistration__c' and DeveloperName =:recordName limit 1 ];
            ApplicationTriggerHelper.skipTrigger = true;
            AnnouncementTriggerHelper.skipTrigger = true;
            GNT__CustomAppConfig__c cac = TestHelper.getCustomAppConfig(true);          
            uReg=new UserRegistration__c();
            uReg.OrganizationName__c ='TestORG';
            uReg.RecordTypeId=rec.id;
            uReg.LastName__c = 'Betty';
            uReg.Status__c='Submitted for Approval';
            uReg.username__c = System.now().millisecond() + 'test@123test.com';
            uReg.EINText__c= '608999520';
            uReg.DUNS__c='608999520';
            uReg.Email__c = 'test15@test.com';
            uReg.OrgnizationPhoneNumber__c='1234567891';
            uReg.OrganizationStreetAddress__c='Sunrise Valley';
            uReg.OrganizationCityAddress__c='Herndon';
            uReg.County__c='Herndon'; 
            uReg.OrganizationState__c='VA';
            uReg.OrganizationZipCode__c='20171-1234';
            uReg.OrganizationsCountry__c='US';
            uReg.Sams__c='S4MR3R7D6';
            //uReg.RecordType.DeveloperName = 'Reviewer';
            insert uReg;
       
            String ns = AppUtils.getNamespacePrefix();
            GNT__PageLayoutConfig__c pageLayoutConfig =  TestHelper.getPageLayoutConfig(true,ns + 'UserRegistration__c');
            GNT__TabConfig__c tabConfig =  TestHelper.getTabConfig(pageLayoutConfig.Id,true);
            GNT__PageBlockConfig__c pageBlockConfig =  TestHelper.getPageBlockConfig(tabConfig.Id, true);
            GNT__PageBlockDetailConfig__c pageBlockDetailConfigList = TestHelper.getPageBlockDetailConfig(pageBlockConfig.Id,false); 
           
            if(pageBlockDetailConfigList.GNT__FieldAPIName__c == 'Name') {
                insert pageBlockDetailConfigList;
            }
            
            GNT__PageLayoutActionConfig__c pageAction = TestHelper.getPageLayoutActionConfig(true,pageLayoutConfig.Id);
            
            layoutHolder = new GNT.DynamicLayoutHolder(pageLayoutConfig.id, uReg.Id,true);
            
        
    }
    
   }
   
   static testMethod void verifyApplicantSAMGovPositiveScenario(){
            createData('Applicant');
            samGov = new SamGovEntityCredentials__c();
            samGov.Name='samGovCreds';
            samGov.username__c='TestUser';
            samGov.password__c='password';
            samGov.soapNS__c='http://schemas.xmlsoap.org/soap/envelope/';
            samGov.xsi__c='http://www.sam.gov';
            samGov.endpoint__c='https://gw.sam.gov/SAMWS/1.0/Entity';
            insert samGov;
            
            sfInterfaces=new ExternalInterfaces__c();
            sfInterfaces.Name='SAM.Gov Entity Validation';
            sfInterfaces.IsEnabled__c=true;
            insert sfInterfaces;
            
            Test.startTest();          
            Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('success','SAM.Gov Entity Validation'));            
            dunsHelper=new DunsEinVerifyHelper();
            dunsHelper.layoutHolder = layoutHolder;
            dunsHelper.whenClicked();    
            //System.assertEquals('Verified',uReg.Status__c);  
            System.debug('user registration-------------------'+uReg);  
            
            IntegrationDetail__c submission=[select id, Status__c from IntegrationDetail__c where External_Registration__c =:uReg.id limit 1];
            System.debug('inserted submission-------------------'+submission);
            //System.assertNotEquals(submission,null);
            //System.assertEquals('Success',submission.Status__c);
           
           // System.assertEquals('Verified', [select id, Status__c from UserRegistration__c where id=:uReg.id limit 1].Status__c); 
            Test.stopTest();
   }
   
   static testMethod void verifyApplicantFPDSPositiveScenario(){
            createData('Applicant');
            sfInterfaces=new ExternalInterfaces__c();
            sfInterfaces.Name='FPDS';
            sfInterfaces.IsEnabled__c=true;
            insert sfInterfaces;
            
            Test.startTest();          
            Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('success','FPDS'));            
            dunsHelper=new DunsEinVerifyHelper();
            dunsHelper.layoutHolder = layoutHolder;
            dunsHelper.whenClicked();    
            //System.assertEquals('Verified',uReg.Status__c);  
            //System.debug('user registration-------------------'+uReg);  
            
            IntegrationDetail__c submission=[select id, Status__c from IntegrationDetail__c where External_Registration__c =:uReg.id limit 1];
           // System.debug('inserted submission-------------------'+submission);
           // System.assertNotEquals(submission,null);
           // System.assertEquals('Success',submission.Status__c);
           
           // System.assertEquals('Verified', [select id, Status__c from UserRegistration__c where id=:uReg.id limit 1].Status__c); 
            Test.stopTest();
   }
   
   static testMethod void verifyApplicantEPLSPositiveScenario(){
            createData('Applicant');
            sfInterfaces=new ExternalInterfaces__c();
            sfInterfaces.Name='SAM.GOV EPLS Verification';
            sfInterfaces.IsEnabled__c=true;
            insert sfInterfaces;
            
            Test.startTest();          
            Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('success','EPLS'));            
            dunsHelper=new DunsEinVerifyHelper();
            dunsHelper.layoutHolder = layoutHolder;
            dunsHelper.whenClicked();    
            //System.assertEquals('Verified',uReg.Status__c);  
          //  System.debug('user registration-------------------'+uReg);  
            
            IntegrationDetail__c submission=[select id, Status__c from IntegrationDetail__c where External_Registration__c =:uReg.id limit 1];
            System.debug('inserted submission-------------------'+submission);
           // System.assertNotEquals(submission,null);
           // System.assertEquals('Success',submission.Status__c);
           
           // System.assertEquals('Verified', [select id, Status__c from UserRegistration__c where id=:uReg.id limit 1].Status__c); 
            Test.stopTest();
   }
   
   
   static testMethod void verifyApplicantSAMGovNegativeScenario(){
            createData('Applicant');
            samGov = new SamGovEntityCredentials__c();
            samGov.Name='samGovCreds';
            samGov.username__c='TestUser';
            samGov.password__c='password';
            samGov.soapNS__c='http://schemas.xmlsoap.org/soap/envelope/';
            samGov.xsi__c='http://www.sam.gov';
            samGov.endpoint__c='https://gw.sam.gov/SAMWS/1.0/Entity';
            insert samGov;
            
            sfInterfaces=new ExternalInterfaces__c();
            sfInterfaces.Name='SAM.Gov Entity Validation';
            sfInterfaces.IsEnabled__c=true;
            insert sfInterfaces;
            
            Test.startTest();          
            Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('failure','SAM.Gov Entity Validation'));            
            dunsHelper=new DunsEinVerifyHelper();
            dunsHelper.layoutHolder = layoutHolder;
            dunsHelper.whenClicked();    
           
            System.debug('user registration-------------------'+uReg);   
            IntegrationDetail__c submission=[select id, Status__c from IntegrationDetail__c where External_Registration__c =:uReg.id limit 1];
            System.debug('inserted submission-------------------'+submission);
           // System.assertNotEquals(submission,null);
           // System.assertEquals('Success',submission.Status__c);
           // System.assertEquals('Verified', [select id, Status__c from UserRegistration__c where id=:uReg.id limit 1].Status__c);   
            Test.stopTest();
   }
   
   static testMethod void VerifyVendor() {
                 
            createData('Vendor');
            samGov = new SamGovEntityCredentials__c();
            samGov.Name='samGovCreds';
            samGov.username__c='TestUser';
            samGov.password__c='password';
            samGov.soapNS__c='http://schemas.xmlsoap.org/soap/envelope/';
            samGov.xsi__c='http://www.sam.gov';
            samGov.endpoint__c='https://gw.sam.gov/SAMWS/1.0/Entity';
            insert samGov;
            Test.startTest();          
            Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('success','SAM.Gov Entity Validation'));            
            dunsHelper=new DunsEinVerifyHelper();
            dunsHelper.layoutHolder = layoutHolder;
            dunsHelper.whenClicked(); 
            System.debug('user registration-------------------'+uReg);   
            List<IntegrationDetail__c> submission=[select id, Status__c from IntegrationDetail__c where External_Registration__c =:uReg.id limit 1];
            System.debug('inserted submission-------------------'+submission);
           // System.assertEquals(submission.size(),0);
           // System.assertEquals('Verified', [select id, Status__c from UserRegistration__c where id=:uReg.id limit 1].Status__c);      
            Test.stopTest();      
    }
    
    static testMethod void VerifyDunsAndBradstreetPositive() {
                 
            createData('Applicant');
            iConfig = new InterfaceConfig__c();
            iConfig.Name='Dun and Bradstreet Interface';
            iConfig.API_Key__c='D&BCreds';
            iConfig.isEnabled__c=true;
            iConfig.Purpose__c='Check DUNS Validation';
            iConfig.Username__c='TestUser';
            iConfig.Password__c='password';
            iConfig.Version__c='V5.0/organizations/';
            iConfig.Url__c='https://maxcvservices.dnb.com/';
            iConfig.Product_Id__c='/products/DCP_STD';
            insert iConfig;
            
            sfInterfaces=new ExternalInterfaces__c();
            sfInterfaces.Name='Dun and Bradstreet Verification';
            sfInterfaces.IsEnabled__c=true;
            insert sfInterfaces;
            
            Test.startTest();          
            SingleRequestMock fakeAuthResp = new SingleRequestMock('auth','success');

            SingleRequestMock fakeResp = new SingleRequestMock('d&bresp','success');

            Map<String, HttpCalloutMock> endpoint2TestResp =
                                       new Map<String,HttpCalloutMock>();
            endpoint2TestResp.put('https://maxcvservices.dnb.com/rest/Authentication',fakeAuthResp);
            endpoint2TestResp.put('https://maxcvservices.dnb.com/V5.0/organizations/608999520/products/DCP_STD',fakeResp);
    
            HttpCalloutMock multiCalloutMock =
                                       new TestMockTokenHttpResponseGenerator (endpoint2TestResp);
    
            Test.setMock(HttpCalloutMock.class, multiCalloutMock);
            ApexPages.currentPage().getHeaders().put('True-Client-IP', 'test');
            dunsHelper=new DunsEinVerifyHelper();
            dunsHelper.layoutHolder = layoutHolder;
            dunsHelper.whenClicked(); 
            System.debug('user registration-------------------'+uReg);   
            List<IntegrationDetail__c> submission=[select id, Status__c from IntegrationDetail__c where External_Registration__c =:uReg.id limit 1];
            System.debug('inserted submission-------------------'+submission);
           // System.assertEquals(submission.size(),1);
           // System.assertEquals('Verified', [select id, Status__c from UserRegistration__c where id=:uReg.id limit 1].Status__c);      
            Test.stopTest();      
    }
    
    static testMethod void VerifyDunsAndBradstreetNegative() {
                 
            createData('Applicant');
            iConfig = new InterfaceConfig__c();
            iConfig.Name='Dun and Bradstreet Interface';
            iConfig.API_Key__c='D&BCreds';
            iConfig.isEnabled__c=true;
            iConfig.Purpose__c='Check DUNS Validation';
            iConfig.Username__c='TestUser';
            iConfig.Password__c='password';
            iConfig.Version__c='V5.0/organizations/';
            iConfig.Url__c='https://maxcvservices.dnb.com/';
            iConfig.Product_Id__c='/products/DCP_STD';
            insert iConfig;
            
            sfInterfaces=new ExternalInterfaces__c();
            sfInterfaces.Name='Dun and Bradstreet Verification';
            sfInterfaces.IsEnabled__c=true;
            insert sfInterfaces;
            
            Test.startTest();          
            SingleRequestMock fakeAuthResp = new SingleRequestMock('auth','success');

            SingleRequestMock fakeResp = new SingleRequestMock('d&bresp','success');

            Map<String, HttpCalloutMock> endpoint2TestResp =
                                       new Map<String,HttpCalloutMock>();
            endpoint2TestResp.put('https://maxcvservices.dnb.com/rest/Authentication',fakeAuthResp);
            endpoint2TestResp.put('https://maxcvservices.dnb.com/V5.0/organizations/608999520/products/DCP_STD',fakeResp);
    
            HttpCalloutMock multiCalloutMock =
                                       new TestMockTokenHttpResponseGenerator (endpoint2TestResp);
    
            Test.setMock(HttpCalloutMock.class, multiCalloutMock);
            ApexPages.currentPage().getHeaders().put('True-Client-IP', 'test');
            dunsHelper=new DunsEinVerifyHelper();
            dunsHelper.layoutHolder = layoutHolder;
            dunsHelper.whenClicked(); 
            System.debug('user registration-------------------'+uReg);   
            List<IntegrationDetail__c> submission=[select id, Status__c from IntegrationDetail__c where External_Registration__c =:uReg.id limit 1];
            System.debug('inserted submission-------------------'+submission);
          //  System.assertEquals(submission.size(),1);
           // System.assertEquals('Verified', [select id, Status__c from UserRegistration__c where id=:uReg.id limit 1].Status__c);      
            Test.stopTest();      
    }
    
    static testMethod void VerifyGuideStarPositive() {
                 
            createData('Applicant');
            iConfig = new InterfaceConfig__c();
            iConfig.Name='GuideStar/Simplify Interface';
            iConfig.API_Key__c='Guidestar';
            iConfig.isEnabled__c=true;
            iConfig.Purpose__c='Check EIN Validation';
            iConfig.Username__c='TestUser';
            iConfig.Password__c='password';
            iConfig.Version__c='v1/charitycheck/';
            iConfig.Url__c='https://Sandboxdata.guidestar.org/';
            iConfig.Product_Id__c='/products/DCP_STD';
            insert iConfig;
            
            sfInterfaces=new ExternalInterfaces__c();
            sfInterfaces.Name='GuideStar:Non Profit Verification';
            sfInterfaces.IsEnabled__c=true;
            insert sfInterfaces;
            
            Test.startTest();          
            SingleRequestMock fakeAuthResp = new SingleRequestMock('Guidestar','failure');


            Map<String, HttpCalloutMock> endpoint2TestResp =
                                       new Map<String,HttpCalloutMock>();
            endpoint2TestResp.put('https://Sandboxdata.guidestar.org/v1/charitycheck/608999520.json',fakeAuthResp);
    
            HttpCalloutMock multiCalloutMock =
                                       new TestMockTokenHttpResponseGenerator (endpoint2TestResp);
    
            Test.setMock(HttpCalloutMock.class, multiCalloutMock);
            ApexPages.currentPage().getHeaders().put('True-Client-IP', 'test');
            dunsHelper=new DunsEinVerifyHelper();
            dunsHelper.layoutHolder = layoutHolder;
            dunsHelper.whenClicked(); 
            System.debug('user registration-------------------'+uReg);   
            List<IntegrationDetail__c> submission=[select id, Status__c from IntegrationDetail__c where External_Registration__c =:uReg.id limit 1];
            System.debug('inserted submission-------------------'+submission);
            //System.assertEquals(submission.size(),1);
            //System.assertEquals('Verified', [select id, Status__c from UserRegistration__c where id=:uReg.id limit 1].Status__c);      
            Test.stopTest();      
    }
    
    static testMethod void VerifyGuideStarNegative() {
                 
            createData('Applicant');
            iConfig = new InterfaceConfig__c();
            iConfig.Name='GuideStar/Simplify Interface';
            iConfig.API_Key__c='Guidestar';
            iConfig.isEnabled__c=true;
            iConfig.Purpose__c='Check EIN Validation';
            iConfig.Username__c='TestUser';
            iConfig.Password__c='password';
            iConfig.Version__c='v1/charitycheck/';
            iConfig.Url__c='https://Sandboxdata.guidestar.org/';
            iConfig.Product_Id__c='/products/DCP_STD';
            insert iConfig;
            
            sfInterfaces=new ExternalInterfaces__c();
            sfInterfaces.Name='GuideStar:Non Profit Verification';
            sfInterfaces.IsEnabled__c=true;
            insert sfInterfaces;
            
            Test.startTest();          
            SingleRequestMock fakeAuthResp = new SingleRequestMock('Guidestar','failure');


            Map<String, HttpCalloutMock> endpoint2TestResp =
                                       new Map<String,HttpCalloutMock>();
            endpoint2TestResp.put('https://Sandboxdata.guidestar.org/v1/charitycheck/608999520.json',fakeAuthResp);
    
            HttpCalloutMock multiCalloutMock =
                                       new TestMockTokenHttpResponseGenerator (endpoint2TestResp);
    
            Test.setMock(HttpCalloutMock.class, multiCalloutMock);
            ApexPages.currentPage().getHeaders().put('True-Client-IP', 'test');
            dunsHelper=new DunsEinVerifyHelper();
            dunsHelper.layoutHolder = layoutHolder;
            dunsHelper.whenClicked(); 
            System.debug('user registration-------------------'+uReg);   
            List<IntegrationDetail__c> submission=[select id, Status__c from IntegrationDetail__c where External_Registration__c =:uReg.id limit 1];
            System.debug('inserted submission-------------------'+submission);
          //  System.assertEquals(submission.size(),1);
          //  System.assertEquals('Verified', [select id, Status__c from UserRegistration__c where id=:uReg.id limit 1].Status__c);      
            Test.stopTest();      
    }
    
     
}