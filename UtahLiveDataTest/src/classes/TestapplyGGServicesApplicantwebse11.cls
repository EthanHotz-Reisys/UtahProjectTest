@isTest
private class TestapplyGGServicesApplicantwebse11 {
    
    static void mockService() {
        Test.setMock(WebServiceMock.class, new GGServicesApplicantwebse1Mock());
    }
    
    @isTest static void test_method_one() {
        String trackingNo = 'SometestNumber1';
        mockService();
        GGServicesApplicantwebse1Mock.indicator = 'GetApplicationInfo';
        applyGGServicesApplicantwebse1.ApplicantWebServicesSoapPort test1 = 
                                            new applyGGServicesApplicantwebse1.ApplicantWebServicesSoapPort();
        applyGGServicesApplicantwebse1.GetApplicationInfoResponse_element testResp =  test1.GetApplicationInfo(trackingNo);
        System.debug('***mytest1' + testResp);
    }
    
    @isTest static void test_method_02() {
        String fundOpprNumber = 'SomeFundNumber1';
        String cfdaNumber = 'SomeCFDANumber1';
        String competitionID = 'SomeCompetitionId';
        GGServicesApplicantwebse1Mock.indicator = 'GetOpportunitiesPlusCompTitle';
        mockService();
        applyGGServicesApplicantwebse1.ApplicantWebServicesSoapPort test1 = 
                                            new applyGGServicesApplicantwebse1.ApplicantWebServicesSoapPort();
        //applyGGServicesApplicantwebse1.OpportunityInfo_element[] testResp =  
        //                                    test1.GetOpportunitiesPlusCompTitle(fundOpprNumber,cfdaNumber,competitionID);
    }
    @isTest static void test_method_03() {

        GGServicesApplicantwebse1Mock.indicator = 'GetApplicationList';

        List<applyGGSystemGrantscommonelem1.ApplicationFilter_element> appFilters = 
                                            new List<applyGGSystemGrantscommonelem1.ApplicationFilter_element>();

        applyGGSystemGrantscommonelem1.ApplicationFilter_element appFilter = 
                                            new applyGGSystemGrantscommonelem1.ApplicationFilter_element();
        appFilter.Filter = 'SomeFilter';
        appFilter.FilterValue = 'SomeFilterValue';

        appFilters.add(appFilter);

        mockService();
        applyGGServicesApplicantwebse1.ApplicantWebServicesSoapPort test1 = 
                                            new applyGGServicesApplicantwebse1.ApplicantWebServicesSoapPort();
        applyGGServicesApplicantwebse1.GetApplicationListResponse_element testResp =  
                                            test1.GetApplicationList(appFilters);
    }
    @isTest static void test_method_04() {    
        String trackingNo = 'SometestNumber1';
        GGServicesApplicantwebse1Mock.indicator = 'GetApplicationZip';
        mockService();
        applyGGServicesApplicantwebse1.ApplicantWebServicesSoapPort test1 = 
                                            new applyGGServicesApplicantwebse1.ApplicantWebServicesSoapPort();
        String testResp = test1.GetApplicationZip(trackingNo);
    }
    @isTest static void test_method_05() {
        GGServicesApplicantwebse1Mock.indicator = 'SubmitApplicationAsThirdParty';

        String someXML = 'SomeApplicationXML';
        applyGGSystemGrantscommonelem1.Token_element tokenElement = 
                                            new applyGGSystemGrantscommonelem1.Token_element();
        tokenElement.UserID = 'SomeuserId';
        tokenElement.TokenId = 'SometokenId';
        tokenElement.DUNS = 'SomeDUNSNumber';
        tokenElement.FullName = 'SomeTestname';
        tokenElement.AORStatus = 'SomeAORStatus';
        tokenElement.TokenExpiration = System.today() + 10;

        List<applyGGSystemGrantscommonelem1.Attachment_element> attchElements = 
                                            new List<applyGGSystemGrantscommonelem1.Attachment_element>();

        applyGGSystemGrantscommonelem1.Attachment_element attchElement = 
                                            new applyGGSystemGrantscommonelem1.Attachment_element();
        attchElement.FileContentId = 'SomeFileContentID';
        attchElement.FileDataHandler = 'SomeFileDatahandler';
        attchElements.add(attchElement);

        mockService();
        applyGGServicesApplicantwebse1.ApplicantWebServicesSoapPort test1 = 
                                            new applyGGServicesApplicantwebse1.ApplicantWebServicesSoapPort();
        applyGGServicesApplicantwebse1.SubmitApplicationAsThirdPartyResponse_element testResp = 
                                            test1.SubmitApplicationAsThirdParty(tokenElement,someXML,attchElements);

    }
    @isTest static void test_method_06() {

        GGServicesApplicantwebse1Mock.indicator = 'AuthenticateAOR';
        String aorUserId = 'SomeUserId';
        String aorPwd = 'SomePassword';
        String duns ='Some Duns';
        mockService();
        applyGGServicesApplicantwebse1.ApplicantWebServicesSoapPort test1 = 
                                            new applyGGServicesApplicantwebse1.ApplicantWebServicesSoapPort();
        applyGGServicesApplicantwebse1.AuthenticateAORResponse_element authAORElement = 
                                            test1.AuthenticateAOR(aorUserId,aorPwd,duns);    
    }
    @isTest static void test_method_07() {
        GGServicesApplicantwebse1Mock.indicator = 'GetOpportunities';
        String fundOpprNumber = 'SomeFundNumber1';
        String cfdaNumber = 'SomeCFDANumber1';
        String competitionID = 'SomeCompetitionId';
        mockService();
        applyGGServicesApplicantwebse1.ApplicantWebServicesSoapPort test1 = 
                                            new applyGGServicesApplicantwebse1.ApplicantWebServicesSoapPort();
        //applyGGServicesApplicantwebse1.OpportunityInfo_element[] testResp =
        //                                    test1.GetOpportunitiesExpanded(fundOpprNumber,cfdaNumber,competitionID);
    }
    @isTest static void test_method_12() {
        GGServicesApplicantwebse1Mock.indicator = 'GetOpportunities';
        String fundOpprNumber = 'SomeFundNumber1';
        String cfdaNumber = 'SomeCFDANumber1';
        String competitionID = 'SomeCompetitionId';
        mockService();
        applyGGServicesApplicantwebse1.ApplicantWebServicesSoapPort test1 = 
                                            new applyGGServicesApplicantwebse1.ApplicantWebServicesSoapPort();
        applyGGServicesApplicantwebse1.OpportunityInfo_element[] testResp =
                                            test1.GetOpportunities(fundOpprNumber,cfdaNumber,competitionID);
    }
    @isTest static void test_method_08() {
        GGServicesApplicantwebse1Mock.indicator = 'GetApplicationListAsThirdParty';
        
        List<applyGGSystemGrantscommonelem1.ApplicationFilter_element> appFilters =
                                            new List<applyGGSystemGrantscommonelem1.ApplicationFilter_element>();
        applyGGSystemGrantscommonelem1.ApplicationFilter_element appFilter = 
                                            new applyGGSystemGrantscommonelem1.ApplicationFilter_element();
        appFilter.Filter = 'SomeFilter';
        appFilter.FilterValue = 'SomeFilterValue';
        appFilters.add(appFilter);
        mockService();
        applyGGServicesApplicantwebse1.ApplicantWebServicesSoapPort test1 = 
                                            new applyGGServicesApplicantwebse1.ApplicantWebServicesSoapPort();
        applyGGServicesApplicantwebse1.GetApplicationListAsThirdPartyResponse_element testResp =
                                            test1.GetApplicationListAsThirdParty(appFilters);
    }
    @isTest static void test_method_09() {
        GGServicesApplicantwebse1Mock.indicator = 'SubmitApplication';
        String someXML = 'SomeApplicationXML';
        List<applyGGSystemGrantscommonelem1.Attachment_element> attchElements = 
                                            new List<applyGGSystemGrantscommonelem1.Attachment_element>();

        applyGGSystemGrantscommonelem1.Attachment_element attchElement = 
                                            new applyGGSystemGrantscommonelem1.Attachment_element();
        attchElement.FileContentId = 'SomeFileContentID';
        attchElement.FileDataHandler = 'SomeFileDatahandler';
        attchElements.add(attchElement);

        mockService();
        applyGGServicesApplicantwebse1.ApplicantWebServicesSoapPort test1 = 
                                            new applyGGServicesApplicantwebse1.ApplicantWebServicesSoapPort();
        applyGGServicesApplicantwebse1.SubmitApplicationResponse_element testResp =
                                            test1.SubmitApplication(someXML,attchElements);
    }
    @isTest static void test_method_10() {
        GGServicesApplicantwebse1Mock.indicator = 'GetApplicationInfoAsThirdParty';
        String trackingNo = 'somtrackingnumber1';
        mockService();
        applyGGServicesApplicantwebse1.ApplicantWebServicesSoapPort test1 = 
                                            new applyGGServicesApplicantwebse1.ApplicantWebServicesSoapPort();
        applyGGServicesApplicantwebse1.GetApplicationInfoAsThirdPartyResponse_element testResp =
                                            test1.GetApplicationInfoAsThirdParty(trackingNo);
    }
    @isTest static void test_method_11() {
        GGServicesApplicantwebse1Mock.indicator = 'GetApplicationStatusDetail';
        String trackingNo = 'somtrackingnumber1';
        mockService();
        applyGGServicesApplicantwebse1.ApplicantWebServicesSoapPort test1 = 
                                            new applyGGServicesApplicantwebse1.ApplicantWebServicesSoapPort();      
        applyGGServicesApplicantwebse1.GetApplicationStatusDetailResponse_element testResp =
                                            test1.GetApplicationStatusDetail(trackingNo);
    }
    
}