/**
* @author: Charan - 2017-06-21
* This class is used to create mock response for class applyGGServicesApplicantwebse 
* Mock response is retruned when testclass(TestApplyGGServicesApplicantwebse) invokes 
* webservice.callout method. 
*/

@isTest
public class GGServicesApplicantwebseMock implements WebServiceMock {
  public static String indicator;

   public void doInvoke(
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
      applyGGServicesApplicantwebse.GetApplicationInfoResponse_element test = 
                    new applyGGServicesApplicantwebse.GetApplicationInfoResponse_element();
      test.GrantsGovTrackingNumber = 'Sometrackingnumber1';     
      response.put('response_x', test);
    }
    if(indicator.equals('GetOpportunitiesPlusCompTitle')) {
      List<applyGGServicesApplicantwebse.OpportunityInfo_element> oppElements = 
                    new List<applyGGServicesApplicantwebse.OpportunityInfo_element>();

      applyGGServicesApplicantwebse.OpportunityInfo_element oppElement = 
                    new applyGGServicesApplicantwebse.OpportunityInfo_element();
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

      applyGGServicesApplicantwebse.GetOpportunitiesResponse_element oppPlusComp =
                    new applyGGServicesApplicantwebse.GetOpportunitiesResponse_element();
      oppPlusComp.OpportunityInfo = oppElements;
      response.put('response_x', oppPlusComp);
    } 

    if(indicator.equals('GetApplicationList')) {

      List<applyGGServicesApplicantwebse.ApplicationInfo_element> applicationElements =
                    new List<applyGGServicesApplicantwebse.ApplicationInfo_element>();

      applyGGServicesApplicantwebse.ApplicationInfo_element applicationElement = 
                    new applyGGServicesApplicantwebse.ApplicationInfo_element();


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
      applyGGServicesApplicantwebse.GetApplicationListResponse_element getAppList =
                    new applyGGServicesApplicantwebse.GetApplicationListResponse_element();
      getAppList.ApplicationInfo = applicationElements;
      response.put('response_x',getAppList);

    }
    /*if(indicator.equals('GetApplicationZip')) {
      applyGGServicesApplicantwebse.GetApplicationZipResponse_element appElement =
                    new applyGGServicesApplicantwebse.GetApplicationZipResponse_element();
      appElement.FileDataHandler = 'SomeFileHaldler';
      response.put('response_x',appElement);
    }*/
    if(indicator.equals('SubmitApplicationAsThirdParty')) {
      applyGGServicesApplicantwebse.SubmitApplicationAsThirdPartyResponse_element subThrParty = 
                    new applyGGServicesApplicantwebse.SubmitApplicationAsThirdPartyResponse_element();
      subThrParty.GrantsGovTrackingNumber = 'Sometrackingnumber1';
      subThrParty.ReceivedDateTime = system.today();
      response.put('response_x',subThrParty);
    }
    if(indicator.equals('AuthenticateAOR')) {
      applyGGSystemGrantscommonelem.Token_element tokenElement =
                    new applyGGSystemGrantscommonelem.Token_element();
      tokenElement.UserID = 'SomeuserId';
      tokenElement.TokenId = 'SometokenId';
      tokenElement.DUNS = 'SomeDUNSNumber';
      tokenElement.FullName = 'SomeTestname';
      tokenElement.AORStatus = 'SomeAORStatus';
      tokenElement.TokenExpiration = System.today() + 10;

      applyGGSystemGrantscommonelem.SecurityMessage_element secMsgElement = 
                    new applyGGSystemGrantscommonelem.SecurityMessage_element();
      secMsgElement.MessageCode = 'SomeMessageCode';
      secMsgElement.MessageText = 'SomeMessageText';
      applyGGServicesApplicantwebse.AuthenticateAORResponse_element aorElement = 
                    new applyGGServicesApplicantwebse.AuthenticateAORResponse_element();
      aorElement.Token = tokenElement;
      aorElement.SecurityMessage = secMsgElement;
      response.put('response_x',aorElement);
    }
    if(indicator.equals('GetOpportunities')) {

      List<applyGGServicesApplicantwebse.OpportunityInfo_element> oppElements = 
                    new List<applyGGServicesApplicantwebse.OpportunityInfo_element>();

      applyGGServicesApplicantwebse.OpportunityInfo_element oppElement = 
                    new applyGGServicesApplicantwebse.OpportunityInfo_element();
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
      applyGGServicesApplicantwebse.GetOpportunitiesResponse_element oppRespElement = 
                      new applyGGServicesApplicantwebse.GetOpportunitiesResponse_element();
      oppRespElement.OpportunityInfo = oppElements;
      response.put('response_x',oppRespElement);
    }
    if(indicator.equals('GetApplicationListAsThirdParty')) {

      List<applyGGServicesApplicantwebse.ApplicationInfo_element> applicationElements =
                    new List<applyGGServicesApplicantwebse.ApplicationInfo_element>();

      applyGGServicesApplicantwebse.ApplicationInfo_element applicationElement = 
                    new applyGGServicesApplicantwebse.ApplicationInfo_element();


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

      applyGGServicesApplicantwebse.GetApplicationListAsThirdPartyResponse_element appThirdPartyElement =
                    new applyGGServicesApplicantwebse.GetApplicationListAsThirdPartyResponse_element();
      appThirdPartyElement.AvailableApplicationNumber = 120;
      appThirdPartyElement.ApplicationInfo = applicationElements;
      response.put('response_x',appThirdPartyElement);
    }
    if(indicator.equals('SubmitApplication')) {
      applyGGServicesApplicantwebse.SubmitApplicationResponse_element subAppElement = 
                    new applyGGServicesApplicantwebse.SubmitApplicationResponse_element();
      subAppElement.GrantsGovTrackingNumber = 'Sometrackingnumber1';
      subAppElement.ReceivedDateTime = system.today();
      response.put('response_x',subAppElement);
    }
    if(indicator.equals('GetApplicationInfoAsThirdParty')) {
      applyGGServicesApplicantwebse.GetApplicationInfoAsThirdPartyResponse_element appThirdPartyElement =
                    new applyGGServicesApplicantwebse.GetApplicationInfoAsThirdPartyResponse_element();
      appThirdPartyElement.GrantsGovTrackingNumber = 'Sometrackingnumber1';
      appThirdPartyElement.StatusDetail = 'somestatusdetail';
      appThirdPartyElement.AgencyTrackingNumber = 'Sometrackingnumber2';
      appThirdPartyElement.AgencyNotes = 'Somenotes';
      response.put('response_x',appThirdPartyElement);
    }
    if(indicator.equals('GetApplicationStatusDetail')) {
      applyGGServicesApplicantwebse.GetApplicationStatusDetailResponse_element appStatusDetail =
                    new applyGGServicesApplicantwebse.GetApplicationStatusDetailResponse_element();
      appStatusDetail.GrantsGovTrackingNumber = 'Sometrackingnumber1';
      appStatusDetail.DetailedStatus = 'somestatusdetail';
      response.put('response_x',appStatusDetail);
    }
        // Create response element from the autogenerated class.
        // Populate response element.
        // Add response element to the response parameter, as follows:
        //response.put('response_x', responseElement); 
   }
}