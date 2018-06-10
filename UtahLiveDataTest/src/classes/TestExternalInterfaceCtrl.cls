/**
* Test class for ExternalInterfaceCtrl. Uses MockExternalInterfaceCtrlResponse
* class for mock response.
* @author: Sarat Mahavratayajula. 2016-08-01
*/
@isTest
private class TestExternalInterfaceCtrl {

    @isTest static void testMethod1() {

        List<InterfaceConfig__c> interfaceConfigs = new List<InterfaceConfig__c>();

        InterfaceConfig__c interfaceConfig1 = new InterfaceConfig__c();
        interfaceConfig1.Name = 'GuideStarQuickstartDetailAPI';
        interfaceConfig1.isEnabled__c = true;   
        interfaceConfig1.Password__c = 'somepassword';
        interfaceConfig1.Product_Id__c = '/products';
        interfaceConfig1.Purpose__c = 'some purpose';
        interfaceConfig1.Url__c = 'https://Sometest.guidestar.org/';
        interfaceConfig1.Username__c = 'someUserName1';
        interfaceConfig1.Version__c = 'v1/charitycheck/';
        interfaceConfig1.API_Key__c = '4b6dv37fq3cbq147a591a11038029c20';
        
        InterfaceConfig__c interfaceConfig3 = new InterfaceConfig__c();
        interfaceConfig3.Name = 'GuideStarQuickstartSearchAPI';
        interfaceConfig3.isEnabled__c = true;   
        interfaceConfig3.Password__c = 'somepassword';
        interfaceConfig3.Product_Id__c = '/products';
        interfaceConfig3.Purpose__c = 'some purpose';
        interfaceConfig3.Url__c = 'https://Sometest.guidestar.org/';
        interfaceConfig3.Username__c = 'someUserName1';
        interfaceConfig3.Version__c = 'v1/charitycheck/';
        interfaceConfig3.API_Key__c = '4b6dv37fq3cbq147a591a11038029c20';

        InterfaceConfig__c interfaceConfig2 = new InterfaceConfig__c();
        interfaceConfig2.Name = 'Dun and Bradstreet Interface';
        interfaceConfig2.isEnabled__c = true;   
        interfaceConfig2.Password__c = 'somepassword2';
        interfaceConfig2.Product_Id__c = '/DCP_STD';
        interfaceConfig2.Purpose__c = 'some purpose 2';
        interfaceConfig2.Url__c = 'https://someservice.dnb.com/';
        interfaceConfig2.Username__c = 'someUserName2';
        interfaceConfig2.Version__c = 'V5.0/organizations/';
        interfaceConfig1.API_Key__c = '6b1dv37fq3cbq147a591a11036722c20';

        interfaceConfigs.add(interfaceConfig1);
        interfaceConfigs.add(interfaceConfig2);
        interfaceConfigs.add(interfaceConfig3);

        insert interfaceConfigs;

        String ein = '123abc789';
        Map<String,List<String>> callResp = new Map<String,List<String>>();
        List<String> str = new List<String>();
        str.add('somestr1');
        str.add('somestr2');
        str.add('somestr3');

        callResp.put('key1', str);
        callResp.put('key2', str);

        Test.startTest();
            MockExternalInterfaceCtrlResponse.indicator = '200';
            MockExternalInterfaceCtrlResponse.indicatorHeader = 'json';
            MockExternalInterfaceCtrlResponse.indicatorStatus = 'Pass';
            Test.setMock(HttpCalloutMock.class, new MockExternalInterfaceCtrlResponse());           
            ExternalInterfaceCtrl externalCtrl = new ExternalInterfaceCtrl();
            Map<String,List<String>> respForcheckEIN = externalCtrl.checkEIN(ein,callResp);
            ExternalInterfaceCtrl.calculate(1);
        Test.stopTest();
    }

   /*@isTest static void testMethod2() {

        List<InterfaceConfig__c> interfaceConfigs = new List<InterfaceConfig__c>();

        InterfaceConfig__c interfaceConfig1 = new InterfaceConfig__c();
        interfaceConfig1.Name = 'GuideStarQuickstartDetailAPI';
        interfaceConfig1.isEnabled__c = true;   
        interfaceConfig1.Password__c = 'somepassword';
        interfaceConfig1.Product_Id__c = '/products';
        interfaceConfig1.Purpose__c = 'some purpose';
        interfaceConfig1.Url__c = 'https://Sometest.guidestar.org/';
        interfaceConfig1.Username__c = 'someUserName1';
        interfaceConfig1.Version__c = 'v1/charitycheck/';
        interfaceConfig1.API_Key__c = '4b6dv37fq3cbq147a591a11038029c20';
        
        InterfaceConfig__c interfaceConfig3 = new InterfaceConfig__c();
        interfaceConfig3.Name = 'GuideStarQuickstartSearchAPI';
        interfaceConfig3.isEnabled__c = true;   
        interfaceConfig3.Password__c = 'somepassword';
        interfaceConfig3.Product_Id__c = '/products';
        interfaceConfig3.Purpose__c = 'some purpose';
        interfaceConfig3.Url__c = 'https://Sometest.guidestar.org/';
        interfaceConfig3.Username__c = 'someUserName1';
        interfaceConfig3.Version__c = 'v1/charitycheck/';
        interfaceConfig3.API_Key__c = '4b6dv37fq3cbq147a591a11038029c20';

        InterfaceConfig__c interfaceConfig2 = new InterfaceConfig__c();
        interfaceConfig2.Name = 'Dun and Bradstreet Interface';
        interfaceConfig2.isEnabled__c = true;   
        interfaceConfig2.Password__c = 'somepassword2';
        interfaceConfig2.Product_Id__c = '/DCP_STD';
        interfaceConfig2.Purpose__c = 'some purpose 2';
        interfaceConfig2.Url__c = 'https://someservice.dnb.com/';
        interfaceConfig2.Username__c = 'someUserName2';
        interfaceConfig2.Version__c = 'V5.0/organizations/';
        interfaceConfig1.API_Key__c = '6b1dv37fq3cbq147a591a11036722c20';

        interfaceConfigs.add(interfaceConfig1);
        interfaceConfigs.add(interfaceConfig2);
        interfaceConfigs.add(interfaceConfig3);
        
        insert interfaceConfigs;
        
        String ein = '123abc789';
        Map<String,List<String>> callResp = new Map<String,List<String>>();
        List<String> str = new List<String>();
        str.add('somestr1');
        str.add('somestr2');
        str.add('somestr3');

        callResp.put('key1', str);
        callResp.put('key2', str);

        Test.startTest();
            MockExternalInterfaceCtrlResponse.indicator = '500';
            MockExternalInterfaceCtrlResponse.indicatorHeader = 'json';
            MockExternalInterfaceCtrlResponse.indicatorStatus = 'Pass';
            Test.setMock(HttpCalloutMock.class, new MockExternalInterfaceCtrlResponse());           
            ExternalInterfaceCtrl externalCtrl = new ExternalInterfaceCtrl();
            Map<String,List<String>> respForcheckEIN = externalCtrl.checkEIN(ein,callResp);
        Test.stopTest();
    }*/

    @isTest static void testMethod3() {

        List<InterfaceConfig__c> interfaceConfigs = new List<InterfaceConfig__c>();

        InterfaceConfig__c interfaceConfig1 = new InterfaceConfig__c();
        interfaceConfig1.Name = 'GuideStar/Simplify Interface';
        interfaceConfig1.isEnabled__c = true;   
        interfaceConfig1.Password__c = 'somepassword';
        interfaceConfig1.Product_Id__c = '/products';
        interfaceConfig1.Purpose__c = 'some purpose';
        interfaceConfig1.Url__c = 'https://Sometest.guidestar.org/';
        interfaceConfig1.Username__c = 'someUserName1';
        interfaceConfig1.Version__c = 'v1/charitycheck/';
        interfaceConfig1.API_Key__c = '4b6dv37fq3cbq147a591a11038029c20';

        InterfaceConfig__c interfaceConfig2 = new InterfaceConfig__c();
        interfaceConfig2.Name = 'Dun and Bradstreet Interface';
        interfaceConfig2.isEnabled__c = true;   
        interfaceConfig2.Password__c = 'somepassword2';
        interfaceConfig2.Product_Id__c = '/DCP_STD';
        interfaceConfig2.Purpose__c = 'some purpose 2';
        interfaceConfig2.Url__c = 'https://someservice.dnb.com/';
        interfaceConfig2.Username__c = 'someUserName2';
        interfaceConfig2.Version__c = 'V5.0/organizations/';
        interfaceConfig1.API_Key__c = '6b1dv37fq3cbq147a591a11036722c20';

        interfaceConfigs.add(interfaceConfig1);
        interfaceConfigs.add(interfaceConfig2);

        insert interfaceConfigs;

        Test.startTest();
            MockExternalInterfaceCtrlResponse.indicator = '200';
            MockExternalInterfaceCtrlResponse.indicatorHeader = 'urlencoded';
            MockExternalInterfaceCtrlResponse.indicatorStatus = 'Pass';
            Test.setMock(HttpCalloutMock.class, new MockExternalInterfaceCtrlResponse());           
            ExternalInterfaceCtrl externalCtrl = new ExternalInterfaceCtrl();
            String token = externalCtrl.fetchToken();
        Test.stopTest();
    }

    @isTest static void testMethod4() {

        List<InterfaceConfig__c> interfaceConfigs = new List<InterfaceConfig__c>();

        InterfaceConfig__c interfaceConfig1 = new InterfaceConfig__c();
        interfaceConfig1.Name = 'GuideStar/Simplify Interface';
        interfaceConfig1.isEnabled__c = true;   
        interfaceConfig1.Password__c = 'somepassword';
        interfaceConfig1.Product_Id__c = '/products';
        interfaceConfig1.Purpose__c = 'some purpose';
        interfaceConfig1.Url__c = 'https://Sometest.guidestar.org/';
        interfaceConfig1.Username__c = 'someUserName1';
        interfaceConfig1.Version__c = 'v1/charitycheck/';
        interfaceConfig1.API_Key__c = '4b6dv37fq3cbq147a591a11038029c20';

        InterfaceConfig__c interfaceConfig2 = new InterfaceConfig__c();
        interfaceConfig2.Name = 'Dun and Bradstreet Interface';
        interfaceConfig2.isEnabled__c = true;   
        interfaceConfig2.Password__c = 'somepassword2';
        interfaceConfig2.Product_Id__c = '/DCP_STD';
        interfaceConfig2.Purpose__c = 'some purpose 2';
        interfaceConfig2.Url__c = 'https://someservice.dnb.com/';
        interfaceConfig2.Username__c = 'someUserName2';
        interfaceConfig2.Version__c = 'V5.0/organizations/';
        interfaceConfig1.API_Key__c = '6b1dv37fq3cbq147a591a11036722c20';

        interfaceConfigs.add(interfaceConfig1);
        interfaceConfigs.add(interfaceConfig2);

        insert interfaceConfigs;

        String dunsNo = '123abc789';
        String token = 'sometoken123';
        Map<String,List<String>> callResp = new Map<String,List<String>>();
        List<String> str = new List<String>();
        str.add('somestr1');
        str.add('somestr2');
        str.add('somestr3');

        callResp.put('key1', str);
        callResp.put('key2', str);

        Test.startTest();
            MockExternalInterfaceCtrlResponse.indicator = '200';
            MockExternalInterfaceCtrlResponse.indicatorHeader = 'json';
            MockExternalInterfaceCtrlResponse.indicatorStatus = 'Pass';
            Test.setMock(HttpCalloutMock.class, new MockExternalInterfaceCtrlResponse());           
            ExternalInterfaceCtrl externalCtrl = new ExternalInterfaceCtrl();
            Map<String,List<String>> respForcheckEIN = externalCtrl.checkDUNS(dunsNo,token,callResp);
        Test.stopTest();
    }

    @isTest static void testMethod5() {

        List<InterfaceConfig__c> interfaceConfigs = new List<InterfaceConfig__c>();

        InterfaceConfig__c interfaceConfig1 = new InterfaceConfig__c();
        interfaceConfig1.Name = 'GuideStar/Simplify Interface';
        interfaceConfig1.isEnabled__c = true;   
        interfaceConfig1.Password__c = 'somepassword';
        interfaceConfig1.Product_Id__c = '/products';
        interfaceConfig1.Purpose__c = 'some purpose';
        interfaceConfig1.Url__c = 'https://Sometest.guidestar.org/';
        interfaceConfig1.Username__c = 'someUserName1';
        interfaceConfig1.Version__c = 'v1/charitycheck/';
        interfaceConfig1.API_Key__c = '4b6dv37fq3cbq147a591a11038029c20';

        InterfaceConfig__c interfaceConfig2 = new InterfaceConfig__c();
        interfaceConfig2.Name = 'Dun and Bradstreet Interface';
        interfaceConfig2.isEnabled__c = true;   
        interfaceConfig2.Password__c = 'somepassword2';
        interfaceConfig2.Product_Id__c = '/DCP_STD';
        interfaceConfig2.Purpose__c = 'some purpose 2';
        interfaceConfig2.Url__c = 'https://someservice.dnb.com/';
        interfaceConfig2.Username__c = 'someUserName2';
        interfaceConfig2.Version__c = 'V5.0/organizations/';
        interfaceConfig1.API_Key__c = '6b1dv37fq3cbq147a591a11036722c20';

        interfaceConfigs.add(interfaceConfig1);
        interfaceConfigs.add(interfaceConfig2);

        insert interfaceConfigs;

        String dunsNo = '123abc789';
        String token = 'sometoken123';
        Map<String,List<String>> callResp = new Map<String,List<String>>();
        List<String> str = new List<String>();
        str.add('somestr1');
        str.add('somestr2');
        str.add('somestr3');

        callResp.put('key1', str);
        callResp.put('key2', str);

        Test.startTest();
            MockExternalInterfaceCtrlResponse.indicator = '500';
            MockExternalInterfaceCtrlResponse.indicatorHeader = 'json';
            MockExternalInterfaceCtrlResponse.indicatorStatus = 'Pass';
            Test.setMock(HttpCalloutMock.class, new MockExternalInterfaceCtrlResponse());           
            ExternalInterfaceCtrl externalCtrl = new ExternalInterfaceCtrl();
            Map<String,List<String>> respForcheckEIN = externalCtrl.checkDUNS(dunsNo,token,callResp);
        Test.stopTest();
    }

    @isTest static void testMethod6() {

        List<InterfaceConfig__c> interfaceConfigs = new List<InterfaceConfig__c>();

        InterfaceConfig__c interfaceConfig1 = new InterfaceConfig__c();
        interfaceConfig1.Name = 'GuideStar/Simplify Interface';
        interfaceConfig1.isEnabled__c = true;   
        interfaceConfig1.Password__c = 'somepassword';
        interfaceConfig1.Product_Id__c = '/products';
        interfaceConfig1.Purpose__c = 'some purpose';
        interfaceConfig1.Url__c = 'https://Sometest.guidestar.org/';
        interfaceConfig1.Username__c = 'someUserName1';
        interfaceConfig1.Version__c = 'v1/charitycheck/';
        interfaceConfig1.API_Key__c = '4b6dv37fq3cbq147a591a11038029c20';

        InterfaceConfig__c interfaceConfig2 = new InterfaceConfig__c();
        interfaceConfig2.Name = 'Dun and Bradstreet Interface';
        interfaceConfig2.isEnabled__c = true;   
        interfaceConfig2.Password__c = 'somepassword2';
        interfaceConfig2.Product_Id__c = '/DCP_STD';
        interfaceConfig2.Purpose__c = 'some purpose 2';
        interfaceConfig2.Url__c = 'https://someservice.dnb.com/';
        interfaceConfig2.Username__c = 'someUserName2';
        interfaceConfig2.Version__c = 'V5.0/organizations/';
        interfaceConfig1.API_Key__c = '6b1dv37fq3cbq147a591a11036722c20';

        interfaceConfigs.add(interfaceConfig1);
        interfaceConfigs.add(interfaceConfig2);

        insert interfaceConfigs;

        String samNumber = '123abc789';
        Map<String,List<String>> callResp = new Map<String,List<String>>();
        
        
        //String eplsresponse='{"country":"XUN","lastName":"","zipCode":"","city":"","NPI":"","prefix":"","crossReference":"(also INVERSIONES TURISTICAS JOYA GRANDE, S.A. DE C.V.)","exclusionType":"Prohibition/Restriction","suffix":"","terminationDate":"Indefinite","activeDate":"","address4":"","isExist":true,"CAGE":"","middle":"","address3":"","address2":"","exclusionProgram":"Reciprocal","address1":"","excludingAgency":"TREAS-OFAC","CTCode":"03-SDNTK-01","classification":"Special Entity Designation","state_Province":"","SAMNumber":"S4MR4BL9Y","firstName":"","additionalComments":"PII data has been masked from view","createdDate":"Thu Sep 07 07:32:54 UTC 2017","recordStatus":"","DUNS":"","name":"Special Entity Designation"} ';
        
        List<String> str = new List<String>();
        str.add('somestr1');
        str.add('somestr2');
        str.add('somestr3');

        callResp.put('key1', str);
        callResp.put('key2', str);

        Test.startTest();
            MockExternalInterfaceCtrlResponse.indicator = '200';
            MockExternalInterfaceCtrlResponse.indicatorHeader = 'json';
            MockExternalInterfaceCtrlResponse.indicatorStatus = 'SAM Number exist in ExclusionList';
            Test.setMock(HttpCalloutMock.class, new MockExternalInterfaceCtrlResponse());           
            ExternalInterfaceCtrl externalCtrl = new ExternalInterfaceCtrl();
            Map<String,List<String>> respForcheckEIN = externalCtrl.checkEPLS(samNumber,callResp);
        Test.stopTest();
    }

    /*@isTest static void testMethod7() {

        List<InterfaceConfig__c> interfaceConfigs = new List<InterfaceConfig__c>();

        InterfaceConfig__c interfaceConfig1 = new InterfaceConfig__c();
        interfaceConfig1.Name = 'GuideStar/Simplify Interface';
        interfaceConfig1.isEnabled__c = true;   
        interfaceConfig1.Password__c = 'somepassword';
        interfaceConfig1.Product_Id__c = '/products';
        interfaceConfig1.Purpose__c = 'some purpose';
        interfaceConfig1.Url__c = 'https://Sometest.guidestar.org/';
        interfaceConfig1.Username__c = 'someUserName1';
        interfaceConfig1.Version__c = 'v1/charitycheck/';
        interfaceConfig1.API_Key__c = '4b6dv37fq3cbq147a591a11038029c20';

        InterfaceConfig__c interfaceConfig2 = new InterfaceConfig__c();
        interfaceConfig2.Name = 'Dun and Bradstreet Interface';
        interfaceConfig2.isEnabled__c = true;   
        interfaceConfig2.Password__c = 'somepassword2';
        interfaceConfig2.Product_Id__c = '/DCP_STD';
        interfaceConfig2.Purpose__c = 'some purpose 2';
        interfaceConfig2.Url__c = 'https://someservice.dnb.com/';
        interfaceConfig2.Username__c = 'someUserName2';
        interfaceConfig2.Version__c = 'V5.0/organizations/';
        interfaceConfig1.API_Key__c = '6b1dv37fq3cbq147a591a11036722c20';

        interfaceConfigs.add(interfaceConfig1);
        interfaceConfigs.add(interfaceConfig2);

        insert interfaceConfigs;

        String samNumber = '123abc789';
        Map<String,List<String>> callResp = new Map<String,List<String>>();
        List<String> str = new List<String>();
        str.add('somestr1');
        str.add('somestr2');
        str.add('somestr3');

        callResp.put('key1', str);
        callResp.put('key2', str);

        Test.startTest();
            MockExternalInterfaceCtrlResponse.indicator = '200';
            MockExternalInterfaceCtrlResponse.indicatorHeader = 'json';
            MockExternalInterfaceCtrlResponse.indicatorStatus = 'Pass';
            Test.setMock(HttpCalloutMock.class, new MockExternalInterfaceCtrlResponse());           
            ExternalInterfaceCtrl externalCtrl = new ExternalInterfaceCtrl();
            Map<String,List<String>> respForcheckEIN = externalCtrl.checkEPLS(samNumber,callResp);
        Test.stopTest();
    }*/

    @isTest static void testMethod8() {
        
        List<ExternalInterfaceCtrl.FPDSData > sampleDatas = new List<ExternalInterfaceCtrl.FPDSData >();

        ExternalInterfaceCtrl.FPDSData sampleData1 = new ExternalInterfaceCtrl.FPDSData();
        sampleData1.name = 'Some Name 1';
        sampleData1.streetAddress = 'Some Address 1';
        sampleData1.city = 'Some City 1';
        sampleData1.state = 'Some State 1';
        sampleData1.zipCode = 'Some Zip Code 1';
        sampleData1.countryCode = 'Some Country Code 1';
        sampleData1.principalNAICSCode = 'Some Nacis code 1';
        sampleData1.lastModifiedDate = 'Some date 1';
        sampleData1.productOrServiceCode = 'Some service Code 1';


        ExternalInterfaceCtrl.FPDSData sampleData2 = new ExternalInterfaceCtrl.FPDSData();
        sampleData2.name = 'Some Name 2';
        sampleData2.streetAddress = 'Some Address 2';
        sampleData2.city = 'Some City 2';
        sampleData2.state = 'Some State 2';
        sampleData2.zipCode = 'Some Zip Code 2';
        sampleData2.countryCode = 'Some Country Code 2';
        sampleData2.principalNAICSCode = 'Some Nacis code 2';
        sampleData2.lastModifiedDate = 'Some date 2';
        sampleData2.productOrServiceCode = 'Some service Code 2';   

        String dunsNo = '123abc789';
        Map<String,List<String>> callResp = new Map<String,List<String>>();
        List<String> str = new List<String>();
        str.add('somestr1');
        str.add('somestr2');
        str.add('somestr3');

        callResp.put('key1', str);
        callResp.put('key2', str);

        Test.startTest();
            MockExternalInterfaceCtrlResponse.indicator = '200';
            MockExternalInterfaceCtrlResponse.indicatorHeader = 'json';
            MockExternalInterfaceCtrlResponse.indicatorStatus = 'XML';
            Test.setMock(HttpCalloutMock.class, new MockExternalInterfaceCtrlResponse());           
            ExternalInterfaceCtrl externalCtrl = new ExternalInterfaceCtrl();
            Map<String,List<String>> respForcheckEIN = externalCtrl.FPDSSearch(dunsNo,callResp);
        Test.stopTest();
    }

    @isTest static void testMethod9() {
        
        String dunsNo = '123abc789';
        Map<String,List<String>> callResp = new Map<String,List<String>>();
        List<String> str = new List<String>();
        str.add('somestr1');
        str.add('somestr2');
        str.add('sormestr3');

        callResp.put('key1', str);
        callResp.put('key2', str);

        Test.startTest();
            MockExternalInterfaceCtrlResponse.indicator = '200';
            MockExternalInterfaceCtrlResponse.indicatorHeader = 'json';
            MockExternalInterfaceCtrlResponse.indicatorStatus = 'XML';
            Test.setMock(HttpCalloutMock.class, new MockExternalInterfaceCtrlResponse());           
            ExternalInterfaceCtrl externalCtrl = new ExternalInterfaceCtrl();
            Map<String,List<String>> respForcheckEIN = externalCtrl.FPDSSearch(dunsNo,callResp);
        Test.stopTest();
    }
    
    @isTest static void testMethodSAMEntity(){
        String dunsNo = '123abc789',einNo='123abc789';
        Map<String,List<String>> callResp = new Map<String,List<String>>();
        List<String> str = new List<String>();
        str.add('somestr1');
        str.add('somestr2');
        str.add('sormestr3');
        
        SamGovEntityCredentials__c s=new SamGovEntityCredentials__c();
        s.Name= 'samGovCreds';
        s.endpoint__c='testEndpoint';
        s.password__c='testPwd';
        s.soapNS__c='testSoap';
        s.username__c='testUserName';
        s.xsi__c='testxsi';
        insert s;

        callResp.put('key1', str);
        callResp.put('key2', str);

        Test.startTest();
            MockExternalInterfaceCtrlResponse.indicator = '200';
            MockExternalInterfaceCtrlResponse.indicatorHeader = 'XML';
            MockExternalInterfaceCtrlResponse.indicatorStatus = 'SAMEntity';
            Test.setMock(HttpCalloutMock.class, new MockExternalInterfaceCtrlResponse());           
            ExternalInterfaceCtrl externalCtrl = new ExternalInterfaceCtrl();
            Map<String,String> respForcheckEIN = externalCtrl.checkWithSAM(dunsNo,einNo);
        Test.stopTest();
    }
    
}