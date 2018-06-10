@isTest
private class TestApplyGntsGovServicesApplicantwebse11 {
	
	static void mockService() {
		Test.setMock(WebServiceMock.class, new GrantsGovServicesApplicantwebse11Mock());
	}
	
	@isTest static void test_method_01() {
		String trackingNo = 'SometestNumber1';
		mockService();
		GrantsGovServicesApplicantwebse11Mock.indicator = 'GetApplicationInfo';
		applyGrantsGovServicesApplicantwebse11.ApplicantWebServicesSoapPort test1 = 
											new applyGrantsGovServicesApplicantwebse11.ApplicantWebServicesSoapPort();
		applyGrantsGovServicesApplicantwebse11.GetApplicationInfoResponse_element testResp =  test1.GetApplicationInfo(trackingNo);
		System.debug('***mytest1' + testResp);
	}

	/*@isTest static void test_method_02() {
		String fundOpprNumber = 'SomeFundNumber1';
		String cfdaNumber = 'SomeCFDANumber1';
		String competitionID = 'SomeCompetitionId';
		GrantsGovServicesApplicantwebse11Mock.indicator = 'GetOpportunitiesPlusCompTitle';
		mockService();
		applyGrantsGovServicesApplicantwebse11.ApplicantWebServicesSoapPort test1 = 
											new applyGrantsGovServicesApplicantwebse11.ApplicantWebServicesSoapPort();
		applyGrantsGovServicesApplicantwebse11.OpportunityInfo_element[] testResp =  
											test1.GetOpportunitiesPlusCompTitle(fundOpprNumber,cfdaNumber,competitionID);
	}	*/
	@isTest static void test_method_03() {

		GrantsGovServicesApplicantwebse11Mock.indicator = 'GetApplicationList';

		List<applyGrantsGovSystemGrantscommonelem11.ApplicationFilter_element> appFilters = 
											new List<applyGrantsGovSystemGrantscommonelem11.ApplicationFilter_element>();

		applyGrantsGovSystemGrantscommonelem11.ApplicationFilter_element appFilter = 
											new applyGrantsGovSystemGrantscommonelem11.ApplicationFilter_element();
		appFilter.Filter = 'SomeFilter';
		appFilter.FilterValue = 'SomeFilterValue';

		appFilters.add(appFilter);

		mockService();
		applyGrantsGovServicesApplicantwebse11.ApplicantWebServicesSoapPort test1 = 
											new applyGrantsGovServicesApplicantwebse11.ApplicantWebServicesSoapPort();
		applyGrantsGovServicesApplicantwebse11.GetApplicationListResponse_element testResp =  
											test1.GetApplicationList(appFilters);
	}
	/*@isTest static void test_method_04() {	
		String trackingNo = 'SometestNumber1';
		GrantsGovServicesApplicantwebse11Mock.indicator = 'GetApplicationZip';
		mockService();
		applyGrantsGovServicesApplicantwebse11.ApplicantWebServicesSoapPort test1 = 
											new applyGrantsGovServicesApplicantwebse11.ApplicantWebServicesSoapPort();
		String testResp = test1.GetApplicationZip(trackingNo);
	}*/
	@isTest static void test_method_05() {
		GrantsGovServicesApplicantwebse11Mock.indicator = 'SubmitApplicationAsThirdParty';

		String someXML = 'SomeApplicationXML';
		applyGrantsGovSystemGrantscommonelem11.Token_element tokenElement = 
											new applyGrantsGovSystemGrantscommonelem11.Token_element();
		tokenElement.UserID = 'SomeuserId';
		tokenElement.TokenId = 'SometokenId';
		tokenElement.DUNS = 'SomeDUNSNumber';
		tokenElement.FullName = 'SomeTestname';
		tokenElement.AORStatus = 'SomeAORStatus';
		tokenElement.TokenExpiration = System.today() + 10;

		List<applyGrantsGovSystemGrantscommonelem11.Attachment_element> attchElements = 
											new List<applyGrantsGovSystemGrantscommonelem11.Attachment_element>();

		applyGrantsGovSystemGrantscommonelem11.Attachment_element attchElement = 
											new applyGrantsGovSystemGrantscommonelem11.Attachment_element();
		attchElement.FileContentId = 'SomeFileContentID';
		attchElement.FileDataHandler = 'SomeFileDatahandler';
		attchElements.add(attchElement);

		mockService();
		applyGrantsGovServicesApplicantwebse11.ApplicantWebServicesSoapPort test1 = 
											new applyGrantsGovServicesApplicantwebse11.ApplicantWebServicesSoapPort();
		applyGrantsGovServicesApplicantwebse11.SubmitApplicationAsThirdPartyResponse_element testResp = 
											test1.SubmitApplicationAsThirdParty(tokenElement,someXML,attchElements);

	}
	@isTest static void test_method_06() {

		GrantsGovServicesApplicantwebse11Mock.indicator = 'AuthenticateAOR';
		String aorUserId = 'SomeUserId';
		String aorPwd = 'SomePassword';
		mockService();
		applyGrantsGovServicesApplicantwebse11.ApplicantWebServicesSoapPort test1 = 
											new applyGrantsGovServicesApplicantwebse11.ApplicantWebServicesSoapPort();
		applyGrantsGovServicesApplicantwebse11.AuthenticateAORResponse_element authAORElement = 
											test1.AuthenticateAOR(aorUserId,aorPwd);	
	}
	@isTest static void test_method_07() {
		GrantsGovServicesApplicantwebse11Mock.indicator = 'GetOpportunities';
		String fundOpprNumber = 'SomeFundNumber1';
		String cfdaNumber = 'SomeCFDANumber1';
		String competitionID = 'SomeCompetitionId';
		mockService();
		applyGrantsGovServicesApplicantwebse11.ApplicantWebServicesSoapPort test1 = 
											new applyGrantsGovServicesApplicantwebse11.ApplicantWebServicesSoapPort();
		applyGrantsGovServicesApplicantwebse11.OpportunityInfo_element[] testResp =
											test1.GetOpportunities(fundOpprNumber,cfdaNumber,competitionID);
	}
	@isTest static void test_method_08() {
		GrantsGovServicesApplicantwebse11Mock.indicator = 'GetApplicationListAsThirdParty';
		
		List<applyGrantsGovSystemGrantscommonelem11.ApplicationFilter_element> appFilters =
											new List<applyGrantsGovSystemGrantscommonelem11.ApplicationFilter_element>();
		applyGrantsGovSystemGrantscommonelem11.ApplicationFilter_element appFilter = 
											new applyGrantsGovSystemGrantscommonelem11.ApplicationFilter_element();
		appFilter.Filter = 'SomeFilter';
		appFilter.FilterValue = 'SomeFilterValue';
		appFilters.add(appFilter);
		mockService();
		applyGrantsGovServicesApplicantwebse11.ApplicantWebServicesSoapPort test1 = 
											new applyGrantsGovServicesApplicantwebse11.ApplicantWebServicesSoapPort();
		applyGrantsGovServicesApplicantwebse11.GetApplicationListAsThirdPartyResponse_element testResp =
											test1.GetApplicationListAsThirdParty(appFilters);
	}
	@isTest static void test_method_09() {
		GrantsGovServicesApplicantwebse11Mock.indicator = 'SubmitApplication';
		String someXML = 'SomeApplicationXML';
		List<applyGrantsGovSystemGrantscommonelem11.Attachment_element> attchElements = 
											new List<applyGrantsGovSystemGrantscommonelem11.Attachment_element>();

		applyGrantsGovSystemGrantscommonelem11.Attachment_element attchElement = 
											new applyGrantsGovSystemGrantscommonelem11.Attachment_element();
		attchElement.FileContentId = 'SomeFileContentID';
		attchElement.FileDataHandler = 'SomeFileDatahandler';
		attchElements.add(attchElement);

		mockService();
		applyGrantsGovServicesApplicantwebse11.ApplicantWebServicesSoapPort test1 = 
											new applyGrantsGovServicesApplicantwebse11.ApplicantWebServicesSoapPort();
		applyGrantsGovServicesApplicantwebse11.SubmitApplicationResponse_element testResp =
											test1.SubmitApplication(someXML,attchElements);
	}
	@isTest static void test_method_10() {
		GrantsGovServicesApplicantwebse11Mock.indicator = 'GetApplicationInfoAsThirdParty';
		String trackingNo = 'somtrackingnumber1';
		mockService();
		applyGrantsGovServicesApplicantwebse11.ApplicantWebServicesSoapPort test1 = 
											new applyGrantsGovServicesApplicantwebse11.ApplicantWebServicesSoapPort();
		applyGrantsGovServicesApplicantwebse11.GetApplicationInfoAsThirdPartyResponse_element testResp =
											test1.GetApplicationInfoAsThirdParty(trackingNo);
	}
	@isTest static void test_method_11() {
		GrantsGovServicesApplicantwebse11Mock.indicator = 'GetApplicationStatusDetail';
		String trackingNo = 'somtrackingnumber1';
		mockService();
		applyGrantsGovServicesApplicantwebse11.ApplicantWebServicesSoapPort test1 = 
											new applyGrantsGovServicesApplicantwebse11.ApplicantWebServicesSoapPort();		
		applyGrantsGovServicesApplicantwebse11.GetApplicationStatusDetailResponse_element testResp =
											test1.GetApplicationStatusDetail(trackingNo);
	}
	
}