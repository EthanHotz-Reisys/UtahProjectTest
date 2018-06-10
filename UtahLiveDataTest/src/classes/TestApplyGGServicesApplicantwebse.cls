@isTest
private class TestApplyGGServicesApplicantwebse {
	
	static void mockService() {
		Test.setMock(WebServiceMock.class, new GGServicesApplicantwebseMock());
	}
	
	@isTest static void test_method_one() {
		String trackingNo = 'SometestNumber1';
		mockService();
		GGServicesApplicantwebseMock.indicator = 'GetApplicationInfo';
		applyGGServicesApplicantwebse.ApplicantWebServicesSoapPort test1 = 
											new applyGGServicesApplicantwebse.ApplicantWebServicesSoapPort();
		applyGGServicesApplicantwebse.GetApplicationInfoResponse_element testResp =  test1.GetApplicationInfo(trackingNo);
		System.debug('***mytest1' + testResp);
	}
	
	/*@isTest static void test_method_02() {
		String fundOpprNumber = 'SomeFundNumber1';
		String cfdaNumber = 'SomeCFDANumber1';
		String competitionID = 'SomeCompetitionId';
		GGServicesApplicantwebseMock.indicator = 'GetOpportunitiesPlusCompTitle';
		mockService();
		applyGGServicesApplicantwebse.ApplicantWebServicesSoapPort test1 = 
											new applyGGServicesApplicantwebse.ApplicantWebServicesSoapPort();
		applyGGServicesApplicantwebse.OpportunityInfo_element[] testResp =  
											test1.GetOpportunitiesPlusCompTitle(fundOpprNumber,cfdaNumber,competitionID);
	}*/	
	@isTest static void test_method_03() {

		GGServicesApplicantwebseMock.indicator = 'GetApplicationList';

		List<applyGGSystemGrantscommonelem.ApplicationFilter_element> appFilters = 
											new List<applyGGSystemGrantscommonelem.ApplicationFilter_element>();

		applyGGSystemGrantscommonelem.ApplicationFilter_element appFilter = 
											new applyGGSystemGrantscommonelem.ApplicationFilter_element();
		appFilter.Filter = 'SomeFilter';
		appFilter.FilterValue = 'SomeFilterValue';

		appFilters.add(appFilter);

		mockService();
		applyGGServicesApplicantwebse.ApplicantWebServicesSoapPort test1 = 
											new applyGGServicesApplicantwebse.ApplicantWebServicesSoapPort();
		applyGGServicesApplicantwebse.GetApplicationListResponse_element testResp =  
											test1.GetApplicationList(appFilters);
	}
	/*@isTest static void test_method_04() {	
		String trackingNo = 'SometestNumber1';
		GGServicesApplicantwebseMock.indicator = 'GetApplicationZip';
		mockService();
		applyGGServicesApplicantwebse.ApplicantWebServicesSoapPort test1 = 
											new applyGGServicesApplicantwebse.ApplicantWebServicesSoapPort();
		String testResp = test1.GetApplicationZip(trackingNo);
	}*/
	@isTest static void test_method_05() {
		GGServicesApplicantwebseMock.indicator = 'SubmitApplicationAsThirdParty';

		String someXML = 'SomeApplicationXML';
		applyGGSystemGrantscommonelem.Token_element tokenElement = 
											new applyGGSystemGrantscommonelem.Token_element();
		tokenElement.UserID = 'SomeuserId';
		tokenElement.TokenId = 'SometokenId';
		tokenElement.DUNS = 'SomeDUNSNumber';
		tokenElement.FullName = 'SomeTestname';
		tokenElement.AORStatus = 'SomeAORStatus';
		tokenElement.TokenExpiration = System.today() + 10;

		List<applyGGSystemGrantscommonelem.Attachment_element> attchElements = 
											new List<applyGGSystemGrantscommonelem.Attachment_element>();

		applyGGSystemGrantscommonelem.Attachment_element attchElement = 
											new applyGGSystemGrantscommonelem.Attachment_element();
		attchElement.FileContentId = 'SomeFileContentID';
		attchElement.FileDataHandler = 'SomeFileDatahandler';
		attchElements.add(attchElement);

		mockService();
		applyGGServicesApplicantwebse.ApplicantWebServicesSoapPort test1 = 
											new applyGGServicesApplicantwebse.ApplicantWebServicesSoapPort();
		applyGGServicesApplicantwebse.SubmitApplicationAsThirdPartyResponse_element testResp = 
											test1.SubmitApplicationAsThirdParty(tokenElement,someXML,attchElements);

	}
	@isTest static void test_method_06() {

		GGServicesApplicantwebseMock.indicator = 'AuthenticateAOR';
		String aorUserId = 'SomeUserId';
		String aorPwd = 'SomePassword';
		mockService();
		applyGGServicesApplicantwebse.ApplicantWebServicesSoapPort test1 = 
											new applyGGServicesApplicantwebse.ApplicantWebServicesSoapPort();
		applyGGServicesApplicantwebse.AuthenticateAORResponse_element authAORElement = 
											test1.AuthenticateAOR(aorUserId,aorPwd);	
	}
	@isTest static void test_method_07() {
		GGServicesApplicantwebseMock.indicator = 'GetOpportunities';
		String fundOpprNumber = 'SomeFundNumber1';
		String cfdaNumber = 'SomeCFDANumber1';
		String competitionID = 'SomeCompetitionId';
		mockService();
		applyGGServicesApplicantwebse.ApplicantWebServicesSoapPort test1 = 
											new applyGGServicesApplicantwebse.ApplicantWebServicesSoapPort();
		applyGGServicesApplicantwebse.OpportunityInfo_element[] testResp =
											test1.GetOpportunities(fundOpprNumber,cfdaNumber,competitionID);
	}
	@isTest static void test_method_08() {
		GGServicesApplicantwebseMock.indicator = 'GetApplicationListAsThirdParty';
		
		List<applyGGSystemGrantscommonelem.ApplicationFilter_element> appFilters =
											new List<applyGGSystemGrantscommonelem.ApplicationFilter_element>();
		applyGGSystemGrantscommonelem.ApplicationFilter_element appFilter = 
											new applyGGSystemGrantscommonelem.ApplicationFilter_element();
		appFilter.Filter = 'SomeFilter';
		appFilter.FilterValue = 'SomeFilterValue';
		appFilters.add(appFilter);
		mockService();
		applyGGServicesApplicantwebse.ApplicantWebServicesSoapPort test1 = 
											new applyGGServicesApplicantwebse.ApplicantWebServicesSoapPort();
		applyGGServicesApplicantwebse.GetApplicationListAsThirdPartyResponse_element testResp =
											test1.GetApplicationListAsThirdParty(appFilters);
	}
	@isTest static void test_method_09() {
		GGServicesApplicantwebseMock.indicator = 'SubmitApplication';
		String someXML = 'SomeApplicationXML';
		List<applyGGSystemGrantscommonelem.Attachment_element> attchElements = 
											new List<applyGGSystemGrantscommonelem.Attachment_element>();

		applyGGSystemGrantscommonelem.Attachment_element attchElement = 
											new applyGGSystemGrantscommonelem.Attachment_element();
		attchElement.FileContentId = 'SomeFileContentID';
		attchElement.FileDataHandler = 'SomeFileDatahandler';
		attchElements.add(attchElement);

		mockService();
		applyGGServicesApplicantwebse.ApplicantWebServicesSoapPort test1 = 
											new applyGGServicesApplicantwebse.ApplicantWebServicesSoapPort();
		applyGGServicesApplicantwebse.SubmitApplicationResponse_element testResp =
											test1.SubmitApplication(someXML,attchElements);
	}
	@isTest static void test_method_10() {
		GGServicesApplicantwebseMock.indicator = 'GetApplicationInfoAsThirdParty';
		String trackingNo = 'somtrackingnumber1';
		mockService();
		applyGGServicesApplicantwebse.ApplicantWebServicesSoapPort test1 = 
											new applyGGServicesApplicantwebse.ApplicantWebServicesSoapPort();
		applyGGServicesApplicantwebse.GetApplicationInfoAsThirdPartyResponse_element testResp =
											test1.GetApplicationInfoAsThirdParty(trackingNo);
	}
	@isTest static void test_method_11() {
		GGServicesApplicantwebseMock.indicator = 'GetApplicationStatusDetail';
		String trackingNo = 'somtrackingnumber1';
		mockService();
		applyGGServicesApplicantwebse.ApplicantWebServicesSoapPort test1 = 
											new applyGGServicesApplicantwebse.ApplicantWebServicesSoapPort();		
		applyGGServicesApplicantwebse.GetApplicationStatusDetailResponse_element testResp =
											test1.GetApplicationStatusDetail(trackingNo);
	}
}