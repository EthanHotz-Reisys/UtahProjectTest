@isTest
private class TestAsyncApplyGGServicesApplicantwebse {

	static void mockService() {
		Test.setMock(WebServiceMock.class, new GGServicesApplicantwebseMock());
	}
	
	@isTest static void test_method_01() {
		String trackingNo = 'SometestNumber1';
		mockService();
		GGServicesApplicantwebseMock.indicator = 'GetApplicationInfo';
		AsyncApplyGGServicesApplicantwebse.AsyncApplicantWebServicesSoapPort test1 = 
											new AsyncApplyGGServicesApplicantwebse.AsyncApplicantWebServicesSoapPort();
		Continuation cont = new Continuation(60);
		AsyncApplyGGServicesApplicantwebse.GetApplicationInfoResponse_elementFuture testResp =  test1.beginGetApplicationInfo(cont,trackingNo);
		System.debug('***mytest1' + testResp);
	}
	
	/*@isTest static void test_method_02() {
		String fundOpprNumber = 'SomeFundNumber1';
		String cfdaNumber = 'SomeCFDANumber1';
		String competitionID = 'SomeCompetitionId';
		GGServicesApplicantwebseMock.indicator = 'GetOpportunitiesPlusCompTitle';
		mockService();
		AsyncApplyGGServicesApplicantwebse.AsyncApplicantWebServicesSoapPort test1 = 
											new AsyncApplyGGServicesApplicantwebse.AsyncApplicantWebServicesSoapPort();
		AsyncApplyGGServicesApplicantwebse.OpportunityInfo_element[] testResp =  
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
		AsyncApplyGGServicesApplicantwebse.AsyncApplicantWebServicesSoapPort test1 = 
											new AsyncApplyGGServicesApplicantwebse.AsyncApplicantWebServicesSoapPort();

		Continuation cont = new Continuation(60);

		AsyncApplyGGServicesApplicantwebse.GetApplicationListResponse_elementFuture testResp =  
											test1.beginGetApplicationList(cont,appFilters);
	}
	/*@isTest static void test_method_04() {	
		String trackingNo = 'SometestNumber1';
		GGServicesApplicantwebseMock.indicator = 'GetApplicationZip';
		mockService();
		AsyncApplyGGServicesApplicantwebse.AsyncApplicantWebServicesSoapPort test1 = 
											new AsyncApplyGGServicesApplicantwebse.AsyncApplicantWebServicesSoapPort();
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
		AsyncApplyGGServicesApplicantwebse.AsyncApplicantWebServicesSoapPort test1 = 
											new AsyncApplyGGServicesApplicantwebse.AsyncApplicantWebServicesSoapPort();

		Continuation cont = new Continuation(60);
		AsyncApplyGGServicesApplicantwebse.SubmitApplicationAsThirdPartyResponse_elementFuture testResp = 
											test1.beginSubmitApplicationAsThirdParty(cont,tokenElement,someXML,attchElements);

	}
	@isTest static void test_method_06() {

		GGServicesApplicantwebseMock.indicator = 'AuthenticateAOR';
		String aorUserId = 'SomeUserId';
		String aorPwd = 'SomePassword';
		mockService();
		AsyncApplyGGServicesApplicantwebse.AsyncApplicantWebServicesSoapPort test1 = 
											new AsyncApplyGGServicesApplicantwebse.AsyncApplicantWebServicesSoapPort();
		Continuation cont = new Continuation(60);
		AsyncApplyGGServicesApplicantwebse.AuthenticateAORResponse_elementFuture authAORElement = 
											test1.beginAuthenticateAOR(cont,aorUserId,aorPwd);	
	}
	@isTest static void test_method_07() {
		GGServicesApplicantwebseMock.indicator = 'GetOpportunities';
		String fundOpprNumber = 'SomeFundNumber1';
		String cfdaNumber = 'SomeCFDANumber1';
		String competitionID = 'SomeCompetitionId';
		mockService();
		AsyncApplyGGServicesApplicantwebse.AsyncApplicantWebServicesSoapPort test1 = 
											new AsyncApplyGGServicesApplicantwebse.AsyncApplicantWebServicesSoapPort();
											Continuation cont = new Continuation(60);
		AsyncApplyGGServicesApplicantwebse.GetOpportunitiesResponse_elementFuture testResp =
											test1.beginGetOpportunities(cont,fundOpprNumber,cfdaNumber,competitionID);
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
		AsyncApplyGGServicesApplicantwebse.AsyncApplicantWebServicesSoapPort test1 = 
											new AsyncApplyGGServicesApplicantwebse.AsyncApplicantWebServicesSoapPort();
		Continuation cont = new Continuation(60);
		AsyncApplyGGServicesApplicantwebse.GetApplicationListAsThirdPartyResponse_elementFuture testResp =
											test1.beginGetApplicationListAsThirdParty(cont,appFilters);
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
		AsyncApplyGGServicesApplicantwebse.AsyncApplicantWebServicesSoapPort test1 = 
											new AsyncApplyGGServicesApplicantwebse.AsyncApplicantWebServicesSoapPort();
		Continuation cont = new Continuation(60);
		AsyncApplyGGServicesApplicantwebse.SubmitApplicationResponse_elementFuture testResp =
											test1.beginSubmitApplication(cont,someXML,attchElements);
	}
	@isTest static void test_method_10() {
		GGServicesApplicantwebseMock.indicator = 'GetApplicationInfoAsThirdParty';
		String trackingNo = 'somtrackingnumber1';
		mockService();
		AsyncApplyGGServicesApplicantwebse.AsyncApplicantWebServicesSoapPort test1 = 
											new AsyncApplyGGServicesApplicantwebse.AsyncApplicantWebServicesSoapPort();
		Continuation cont = new Continuation(60);
		AsyncApplyGGServicesApplicantwebse.GetApplicationInfoAsThirdPartyResponse_elementFuture testResp =
											test1.beginGetApplicationInfoAsThirdParty(cont,trackingNo);
	}
	@isTest static void test_method_11() {
		GGServicesApplicantwebseMock.indicator = 'GetApplicationStatusDetail';
		String trackingNo = 'somtrackingnumber1';
		mockService();
		AsyncApplyGGServicesApplicantwebse.AsyncApplicantWebServicesSoapPort test1 = 
											new AsyncApplyGGServicesApplicantwebse.AsyncApplicantWebServicesSoapPort();	
		Continuation cont = new Continuation(60);	
		AsyncApplyGGServicesApplicantwebse.GetApplicationStatusDetailResponse_elementFuture testResp =
											test1.beginGetApplicationStatusDetail(cont,trackingNo);
	}
	
}