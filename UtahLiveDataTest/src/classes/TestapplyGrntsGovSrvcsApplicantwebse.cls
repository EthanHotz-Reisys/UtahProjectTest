/*
* @author: Sarat Mahavratayajula - 2016-07-27
* This test class assumes a mock response is constructed and the mock response
* is returned when the webserive call out is invoked. 
*/

@isTest
private class TestapplyGrntsGovSrvcsApplicantwebse {

	static void mockService() {
		Test.setMock(WebServiceMock.class, new GrantsGovServsApplicantWebseMock());
	}
	
	@isTest static void test_method_01() {
		String trackingNo = 'SometestNumber1';
		mockService();
		GrantsGovServsApplicantWebseMock.indicator = 'GetApplicationInfo';
		applyGrantsGovServicesApplicantwebse.ApplicantWebServicesSoapPort test1 = 
											new applyGrantsGovServicesApplicantwebse.ApplicantWebServicesSoapPort();
		applyGrantsGovServicesApplicantwebse.GetApplicationInfoResponse_element testResp =  test1.GetApplicationInfo(trackingNo);
		System.debug('***mytest1' + testResp);
	}

	@isTest static void test_method_02() {
		String fundOpprNumber = 'SomeFundNumber1';
		String cfdaNumber = 'SomeCFDANumber1';
		String competitionID = 'SomeCompetitionId';
		GrantsGovServsApplicantWebseMock.indicator = 'GetOpportunitiesPlusCompTitle';
		mockService();
		applyGrantsGovServicesApplicantwebse.ApplicantWebServicesSoapPort test1 = 
											new applyGrantsGovServicesApplicantwebse.ApplicantWebServicesSoapPort();
		applyGrantsGovServicesApplicantwebse.OpportunityInfo_element[] testResp =  
											test1.GetOpportunitiesPlusCompTitle(fundOpprNumber,cfdaNumber,competitionID);
	}	
	@isTest static void test_method_03() {

		GrantsGovServsApplicantWebseMock.indicator = 'GetApplicationList';

		List<applyGrantsGovSystemGrantscommonelem.ApplicationFilter_element> appFilters = 
											new List<applyGrantsGovSystemGrantscommonelem.ApplicationFilter_element>();

		applyGrantsGovSystemGrantscommonelem.ApplicationFilter_element appFilter = 
											new applyGrantsGovSystemGrantscommonelem.ApplicationFilter_element();
		appFilter.Filter = 'SomeFilter';
		appFilter.FilterValue = 'SomeFilterValue';

		appFilters.add(appFilter);

		mockService();
		applyGrantsGovServicesApplicantwebse.ApplicantWebServicesSoapPort test1 = 
											new applyGrantsGovServicesApplicantwebse.ApplicantWebServicesSoapPort();
		applyGrantsGovServicesApplicantwebse.GetApplicationListResponse_element testResp =  
											test1.GetApplicationList(appFilters);
	}
	@isTest static void test_method_04() {	
		String trackingNo = 'SometestNumber1';
		GrantsGovServsApplicantWebseMock.indicator = 'GetApplicationZip';
		mockService();
		applyGrantsGovServicesApplicantwebse.ApplicantWebServicesSoapPort test1 = 
											new applyGrantsGovServicesApplicantwebse.ApplicantWebServicesSoapPort();
		String testResp = test1.GetApplicationZip(trackingNo);
	}
	@isTest static void test_method_05() {
		GrantsGovServsApplicantWebseMock.indicator = 'SubmitApplicationAsThirdParty';

		String someXML = 'SomeApplicationXML';
		applyGrantsGovSystemGrantscommonelem.Token_element tokenElement = 
											new applyGrantsGovSystemGrantscommonelem.Token_element();
		tokenElement.UserID = 'SomeuserId';
		tokenElement.TokenId = 'SometokenId';
		tokenElement.DUNS = 'SomeDUNSNumber';
		tokenElement.FullName = 'SomeTestname';
		tokenElement.AORStatus = 'SomeAORStatus';
		tokenElement.TokenExpiration = System.today() + 10;

		List<applyGrantsGovSystemGrantscommonelem.Attachment_element> attchElements = 
											new List<applyGrantsGovSystemGrantscommonelem.Attachment_element>();

		applyGrantsGovSystemGrantscommonelem.Attachment_element attchElement = 
											new applyGrantsGovSystemGrantscommonelem.Attachment_element();
		attchElement.FileContentId = 'SomeFileContentID';
		attchElement.FileDataHandler = 'SomeFileDatahandler';
		attchElements.add(attchElement);

		mockService();
		applyGrantsGovServicesApplicantwebse.ApplicantWebServicesSoapPort test1 = 
											new applyGrantsGovServicesApplicantwebse.ApplicantWebServicesSoapPort();
		applyGrantsGovServicesApplicantwebse.SubmitApplicationAsThirdPartyResponse_element testResp = 
											test1.SubmitApplicationAsThirdParty(tokenElement,someXML,attchElements);

	}
	@isTest static void test_method_06() {

		GrantsGovServsApplicantWebseMock.indicator = 'AuthenticateAOR';
		String aorUserId = 'SomeUserId';
		String aorPwd = 'SomePassword';
		mockService();
		applyGrantsGovServicesApplicantwebse.ApplicantWebServicesSoapPort test1 = 
											new applyGrantsGovServicesApplicantwebse.ApplicantWebServicesSoapPort();
		applyGrantsGovServicesApplicantwebse.AuthenticateAORResponse_element authAORElement = 
											test1.AuthenticateAOR(aorUserId,aorPwd);	
	}
	@isTest static void test_method_07() {
		GrantsGovServsApplicantWebseMock.indicator = 'GetOpportunities';
		String fundOpprNumber = 'SomeFundNumber1';
		String cfdaNumber = 'SomeCFDANumber1';
		String competitionID = 'SomeCompetitionId';
		mockService();
		applyGrantsGovServicesApplicantwebse.ApplicantWebServicesSoapPort test1 = 
											new applyGrantsGovServicesApplicantwebse.ApplicantWebServicesSoapPort();
		applyGrantsGovServicesApplicantwebse.OpportunityInfo_element[] testResp =
											test1.GetOpportunities(fundOpprNumber,cfdaNumber,competitionID);
	}
	@isTest static void test_method_08() {
		GrantsGovServsApplicantWebseMock.indicator = 'GetApplicationListAsThirdParty';
		
		List<applyGrantsGovSystemGrantscommonelem.ApplicationFilter_element> appFilters =
											new List<applyGrantsGovSystemGrantscommonelem.ApplicationFilter_element>();
		applyGrantsGovSystemGrantscommonelem.ApplicationFilter_element appFilter = 
											new applyGrantsGovSystemGrantscommonelem.ApplicationFilter_element();
		appFilter.Filter = 'SomeFilter';
		appFilter.FilterValue = 'SomeFilterValue';
		appFilters.add(appFilter);
		mockService();
		applyGrantsGovServicesApplicantwebse.ApplicantWebServicesSoapPort test1 = 
											new applyGrantsGovServicesApplicantwebse.ApplicantWebServicesSoapPort();
		applyGrantsGovServicesApplicantwebse.GetApplicationListAsThirdPartyResponse_element testResp =
											test1.GetApplicationListAsThirdParty(appFilters);
	}
	@isTest static void test_method_09() {
		GrantsGovServsApplicantWebseMock.indicator = 'SubmitApplication';
		String someXML = 'SomeApplicationXML';
		List<applyGrantsGovSystemGrantscommonelem.Attachment_element> attchElements = 
											new List<applyGrantsGovSystemGrantscommonelem.Attachment_element>();

		applyGrantsGovSystemGrantscommonelem.Attachment_element attchElement = 
											new applyGrantsGovSystemGrantscommonelem.Attachment_element();
		attchElement.FileContentId = 'SomeFileContentID';
		attchElement.FileDataHandler = 'SomeFileDatahandler';
		attchElements.add(attchElement);

		mockService();
		applyGrantsGovServicesApplicantwebse.ApplicantWebServicesSoapPort test1 = 
											new applyGrantsGovServicesApplicantwebse.ApplicantWebServicesSoapPort();
		applyGrantsGovServicesApplicantwebse.SubmitApplicationResponse_element testResp =
											test1.SubmitApplication(someXML,attchElements);
	}
	@isTest static void test_method_10() {
		GrantsGovServsApplicantWebseMock.indicator = 'GetApplicationInfoAsThirdParty';
		String trackingNo = 'somtrackingnumber1';
		mockService();
		applyGrantsGovServicesApplicantwebse.ApplicantWebServicesSoapPort test1 = 
											new applyGrantsGovServicesApplicantwebse.ApplicantWebServicesSoapPort();
		applyGrantsGovServicesApplicantwebse.GetApplicationInfoAsThirdPartyResponse_element testResp =
											test1.GetApplicationInfoAsThirdParty(trackingNo);
	}
	@isTest static void test_method_11() {
		GrantsGovServsApplicantWebseMock.indicator = 'GetApplicationStatusDetail';
		String trackingNo = 'somtrackingnumber1';
		mockService();
		applyGrantsGovServicesApplicantwebse.ApplicantWebServicesSoapPort test1 = 
											new applyGrantsGovServicesApplicantwebse.ApplicantWebServicesSoapPort();		
		applyGrantsGovServicesApplicantwebse.GetApplicationStatusDetailResponse_element testResp =
											test1.GetApplicationStatusDetail(trackingNo);
	}
}