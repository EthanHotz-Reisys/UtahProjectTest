/**
* @author: Sarat Mahavratayajula - 2016-07-26
* This class is used to create mock response for class applyGrantsGovServicesApplicantwebse 
* Mock response is retruned when testclass(TestapplyGrntsGovSrvcsApplicantwebse) invokes 
* webservice.callout method. 
*/
@isTest
global class GrantsGovServsApplicantWebseMock Implements WebServiceMock {
	public static String indicator;
	
	global void doInvoke(
	           Object stub,
	           Object request,
	           Map<String, Object> response,
	           String endpoint,
	           String soapAction,
	           String requestName,
	           String responseNS,
	           String responseName,
	           String responseType) {
		if(indicator.equals('GetApplicationInfo')) {
			applyGrantsGovServicesApplicantwebse.GetApplicationInfoResponse_element test = 
										new applyGrantsGovServicesApplicantwebse.GetApplicationInfoResponse_element();
			test.GrantsGovTrackingNumber = 'Sometrackingnumber1';			
			response.put('response_x', test);
		}
		
		if(indicator.equals('GetOpportunitiesPlusCompTitle')) {
			List<applyGrantsGovServicesApplicantwebse.OpportunityInfo_element> oppElements = 
										new List<applyGrantsGovServicesApplicantwebse.OpportunityInfo_element>();

			applyGrantsGovServicesApplicantwebse.OpportunityInfo_element oppElement = 
										new applyGrantsGovServicesApplicantwebse.OpportunityInfo_element();
			oppElement.FundingOpportunityNumber = 'SomeFundNumber1';
			oppElement.CFDANumber = 'SomeCFDANumber1';
			oppElement.CompetitionID = 'SomeCompetitionId';
			oppElement.OpeningDate = system.today() + 1;
			oppElement.ClosingDate = system.today() + 20;
			oppElement.FundingOpportunityTitle = 'Some test title';
			oppElement.OfferingAgency = 'Test agency';
			oppElement.AgencyContactInfo = 'Test agency contact info';
			oppElement.CFDADescription = 'Some Description';
			oppElement.SchemaURL = 'http://testurl.com';
			oppElement.InstructionsURL = 'http://testurl.com';
			oppElement.IsMultiProject = true;

			oppElements.add(oppElement);

			applyGrantsGovServicesApplicantwebse.GetOpportunitiesPlusCompTitleResponse_element oppPlusComp =
										new applyGrantsGovServicesApplicantwebse.GetOpportunitiesPlusCompTitleResponse_element();
			oppPlusComp.OpportunityInfo = oppElements;
			response.put('response_x', oppPlusComp);
		}	

		if(indicator.equals('GetApplicationList')) {

			List<applyGrantsGovServicesApplicantwebse.ApplicationInfo_element> applicationElements =
										new List<applyGrantsGovServicesApplicantwebse.ApplicationInfo_element>();

			applyGrantsGovServicesApplicantwebse.ApplicationInfo_element applicationElement = 
										new applyGrantsGovServicesApplicantwebse.ApplicationInfo_element();


			applicationElement.CFDANumber = 'SomeCFDANumber1';
			applicationElement.FundingOpportunityNumber = 'SomeFundNumber1';
			applicationElement.CompetitionID = 'SomeCompetitionId';
			applicationElement.GrantsGovTrackingNumber = 'Sometrackingnumber1';
			applicationElement.ReceivedDateTime = system.today();
			applicationElement.GrantsGovApplicationStatus = 'somestatus';
			applicationElement.StatusDateTime = system.today() + 10;
			applicationElement.AgencyTrackingNumber = 'someagencynumber';
			applicationElement.SubmissionTitle = 'sometesttitle';

			applicationElements.add(applicationElement);
			applyGrantsGovServicesApplicantwebse.GetApplicationListResponse_element getAppList =
										new applyGrantsGovServicesApplicantwebse.GetApplicationListResponse_element();
			getAppList.ApplicationInfo = applicationElements;
			response.put('response_x',getAppList);

		}
		if(indicator.equals('GetApplicationZip')) {
			applyGrantsGovServicesApplicantwebse.GetApplicationZipResponse_element appElement =
										new applyGrantsGovServicesApplicantwebse.GetApplicationZipResponse_element();
			appElement.FileDataHandler = 'SomeFileHaldler';
			response.put('response_x',appElement);
		}
		if(indicator.equals('SubmitApplicationAsThirdParty')) {
			applyGrantsGovServicesApplicantwebse.SubmitApplicationAsThirdPartyResponse_element subThrParty = 
										new applyGrantsGovServicesApplicantwebse.SubmitApplicationAsThirdPartyResponse_element();
			subThrParty.GrantsGovTrackingNumber = 'Sometrackingnumber1';
			subThrParty.ReceivedDateTime = system.today();
			response.put('response_x',subThrParty);
		}
		if(indicator.equals('AuthenticateAOR')) {
			applyGrantsGovSystemGrantscommonelem.Token_element tokenElement =
										new applyGrantsGovSystemGrantscommonelem.Token_element();
			tokenElement.UserID = 'SomeuserId';
			tokenElement.TokenId = 'SometokenId';
			tokenElement.DUNS = 'SomeDUNSNumber';
			tokenElement.FullName = 'SomeTestname';
			tokenElement.AORStatus = 'SomeAORStatus';
			tokenElement.TokenExpiration = System.today() + 10;

			applyGrantsGovSystemGrantscommonelem.SecurityMessage_element secMsgElement = 
										new applyGrantsGovSystemGrantscommonelem.SecurityMessage_element();
			secMsgElement.MessageCode = 'SomeMessageCode';
			secMsgElement.MessageText = 'SomeMessageText';
			applyGrantsGovServicesApplicantwebse.AuthenticateAORResponse_element aorElement = 
										new applyGrantsGovServicesApplicantwebse.AuthenticateAORResponse_element();
			aorElement.Token = tokenElement;
			aorElement.SecurityMessage = secMsgElement;
			response.put('response_x',aorElement);
		}
		if(indicator.equals('GetOpportunities')) {

			List<applyGrantsGovServicesApplicantwebse.OpportunityInfo_element> oppElements = 
										new List<applyGrantsGovServicesApplicantwebse.OpportunityInfo_element>();

			applyGrantsGovServicesApplicantwebse.OpportunityInfo_element oppElement = 
										new applyGrantsGovServicesApplicantwebse.OpportunityInfo_element();
			oppElement.FundingOpportunityNumber = 'SomeFundNumber1';
			oppElement.CFDANumber = 'SomeCFDANumber1';
			oppElement.CompetitionID = 'SomeCompetitionId';
			oppElement.OpeningDate = system.today() + 1;
			oppElement.ClosingDate = system.today() + 20;
			oppElement.FundingOpportunityTitle = 'Some test title';
			oppElement.OfferingAgency = 'Test agency';
			oppElement.AgencyContactInfo = 'Test agency contact info';
			oppElement.CFDADescription = 'Some Description';
			oppElement.SchemaURL = 'http://testurl.com';
			oppElement.InstructionsURL = 'http://testurl.com';
			oppElement.IsMultiProject = true;

			oppElements.add(oppElement);
			applyGrantsGovServicesApplicantwebse.GetOpportunitiesResponse_element oppRespElement = 
											new applyGrantsGovServicesApplicantwebse.GetOpportunitiesResponse_element();
			oppRespElement.OpportunityInfo = oppElements;
			response.put('response_x',oppRespElement);
		}
		if(indicator.equals('GetApplicationListAsThirdParty')) {

			List<applyGrantsGovServicesApplicantwebse.ApplicationInfo_element> applicationElements =
										new List<applyGrantsGovServicesApplicantwebse.ApplicationInfo_element>();

			applyGrantsGovServicesApplicantwebse.ApplicationInfo_element applicationElement = 
										new applyGrantsGovServicesApplicantwebse.ApplicationInfo_element();


			applicationElement.CFDANumber = 'SomeCFDANumber1';
			applicationElement.FundingOpportunityNumber = 'SomeFundNumber1';
			applicationElement.CompetitionID = 'SomeCompetitionId';
			applicationElement.GrantsGovTrackingNumber = 'Sometrackingnumber1';
			applicationElement.ReceivedDateTime = system.today();
			applicationElement.GrantsGovApplicationStatus = 'somestatus';
			applicationElement.StatusDateTime = system.today() + 10;
			applicationElement.AgencyTrackingNumber = 'someagencynumber';
			applicationElement.SubmissionTitle = 'sometesttitle';

			applicationElements.add(applicationElement);

			applyGrantsGovServicesApplicantwebse.GetApplicationListAsThirdPartyResponse_element appThirdPartyElement =
										new applyGrantsGovServicesApplicantwebse.GetApplicationListAsThirdPartyResponse_element();
			appThirdPartyElement.AvailableApplicationNumber = 120;
			appThirdPartyElement.ApplicationInfo = applicationElements;
			response.put('response_x',appThirdPartyElement);
		}
		if(indicator.equals('SubmitApplication')) {
			applyGrantsGovServicesApplicantwebse.SubmitApplicationResponse_element subAppElement = 
										new applyGrantsGovServicesApplicantwebse.SubmitApplicationResponse_element();
			subAppElement.GrantsGovTrackingNumber = 'Sometrackingnumber1';
			subAppElement.ReceivedDateTime = system.today();
			response.put('response_x',subAppElement);
		}
		if(indicator.equals('GetApplicationInfoAsThirdParty')) {
			applyGrantsGovServicesApplicantwebse.GetApplicationInfoAsThirdPartyResponse_element appThirdPartyElement =
										new applyGrantsGovServicesApplicantwebse.GetApplicationInfoAsThirdPartyResponse_element();
			appThirdPartyElement.GrantsGovTrackingNumber = 'Sometrackingnumber1';
			appThirdPartyElement.StatusDetail = 'somestatusdetail';
			appThirdPartyElement.AgencyTrackingNumber = 'Sometrackingnumber2';
			appThirdPartyElement.AgencyNotes = 'Somenotes';
			response.put('response_x',appThirdPartyElement);
		}
		if(indicator.equals('GetApplicationStatusDetail')) {
			applyGrantsGovServicesApplicantwebse.GetApplicationStatusDetailResponse_element appStatusDetail =
										new applyGrantsGovServicesApplicantwebse.GetApplicationStatusDetailResponse_element();
			appStatusDetail.GrantsGovTrackingNumber = 'Sometrackingnumber1';
			appStatusDetail.DetailedStatus = 'somestatusdetail';
			response.put('response_x',appStatusDetail);
		}
	}
}