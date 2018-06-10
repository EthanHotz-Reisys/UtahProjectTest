/**
* IntegUtahGrantorAPITest is a Test class for the 
* IntegUtahGrantorAPI class
*
* CHANGE HISTORY
* ==================================================================================================
* Date              Name                Description
* Apr 30 2018       Brian Mason         Created
* ==================================================================================================
*/
@isTest
private class IntegUtahGrantorAPITest {
    private static void setupAPIConn(){
        Boolean sandbox = [SELECT Id, IsSandbox FROM Organization LIMIT 1].IsSandbox;
        insert new FINET_URLs__c(
            GranteeDevURL__c = 'https://govgrants-esb.dev.utah.gov/grantee/v1/',
            GrantorDevURL__c = 'https://govgrants-esb.dev.utah.gov/grantor/v1/',
            GrantorProdURL__c = 'https://govgrants-dasesb.utah.gov/grantor/v1/',
            GranteeProdURL__c = 'https://govgrants-dasesb.utah.gov/grantee/v1/'
        );
        insert new FINET_Integration__c( Grantor_Integration_Root_URL__c = sandbox ? Integ_CGIAdv_Utilities.grantorDevURL : Integ_CGIAdv_Utilities.grantorProdURL,
                                         Grantor_Client_ID__c = 'XXX', Grantor_Client_Secret__c ='XXX',
                                         Grantee_Integration_Root_URL__c = sandbox ? Integ_CGIAdv_Utilities.granteeDevURL : Integ_CGIAdv_Utilities.granteeProdURL,
                                         Grantee_Client_ID__c = 'XXX', Grantee_Client_Secret__c = 'XXX',
                                         SetupOwnerId=Userinfo.getUserId() );
        
    }
    @isTest(SeeAllData=FALSE)
    private static void APICallMissingDetails(){
        Test.setMock(HttpCalloutMock.class, new IntegCGIAdv_MockHTTPResponseGen('A'));
        Test.startTest();
        Boolean exceptionFound = FALSE;
        try{
            IntegCGIAdv_GAX_Document gax = new IntegCGIAdv_GAX_Document('400');
            IntegCGIAdv_GAX_Document.IntegCGIAdv_ABS_DOC_HDR_GAX header = new IntegCGIAdv_GAX_Document.IntegCGIAdv_ABS_DOC_HDR_GAX( date.today(), '1', 2018, '0000,000,00' );
            IntegCGIAdv_GAX_Document.IntegCGIAdv_ABS_DOC_VEND_GAX vendor = new IntegCGIAdv_GAX_Document.IntegCGIAdv_ABS_DOC_VEND_GAX( 1, '76453J', '00', date.today() );
            IntegCGIAdv_GAX_Document.IntegCGIAdv_ABS_DOC_ACTG_GAX[] accountingLines = new IntegCGIAdv_GAX_Document.IntegCGIAdv_ABS_DOC_ACTG_GAX[]{};
            accountingLines.add( new IntegCGIAdv_GAX_Document.IntegCGIAdv_ABS_DOC_ACTG_GAX( 1, 1, '18PPA Kindergarten SFY2018:VAR/3005', 109927.54,
                                                                                           '170721-1', 1, date.today(), '2480', '400',
                                                                                           '0100', 'PPA', '7511', '18PPA', '030' ) );
            accountingLines.add( new IntegCGIAdv_GAX_Document.IntegCGIAdv_ABS_DOC_ACTG_GAX( 1, 2, '18PPB Grades 1-12 SFY2018:VAR/3010', 2387678.36,
                                                                                           '170721-2', 2, date.today(), '2480', '400',
                                                                                           '0100', 'PPB', '7511', '18PPB', '030' ) );
            gax.createAMS_DOCUMENTwithDefaults( TRUE, '400', 'null', '', header, vendor, accountingLines );
            httpresponse resp = IntegUtahGrantorAPI.postGAXPaymentDetails( gax );
        }catch( Integ_CGIAdv_Utilities.NullReferenceException nre) {
            exceptionFound = TRUE;
        }
        System.assertEquals(TRUE, exceptionFound, 'Test 1: Integration Detail error not thrown');
        Test.stopTest();
    }
    @isTest(SeeAllData=FALSE)
    private static void GAXAPICall(){
        Test.setMock(HttpCalloutMock.class, new IntegCGIAdv_MockHTTPResponseGen('A'));
        setupAPIConn();
        Test.startTest();
        IntegCGIAdv_GAX_Document gax = new IntegCGIAdv_GAX_Document('400');
        IntegCGIAdv_GAX_Document.IntegCGIAdv_ABS_DOC_HDR_GAX header = new IntegCGIAdv_GAX_Document.IntegCGIAdv_ABS_DOC_HDR_GAX( date.today(), '1', 2018, '0000,000,00' );
        IntegCGIAdv_GAX_Document.IntegCGIAdv_ABS_DOC_VEND_GAX vendor = new IntegCGIAdv_GAX_Document.IntegCGIAdv_ABS_DOC_VEND_GAX( 1, '76453J', '00', date.today() );
        IntegCGIAdv_GAX_Document.IntegCGIAdv_ABS_DOC_ACTG_GAX[] accountingLines = new IntegCGIAdv_GAX_Document.IntegCGIAdv_ABS_DOC_ACTG_GAX[]{};
            accountingLines.add( new IntegCGIAdv_GAX_Document.IntegCGIAdv_ABS_DOC_ACTG_GAX( 1, 1, '18PPA Kindergarten SFY2018:VAR/3005', 109927.54,
                                                                                           '170721-1', 1, date.today(), '2480', '400',
                                                                                           '0100', 'PPA', '7511', '18PPA', '030' ) );
        accountingLines.add( new IntegCGIAdv_GAX_Document.IntegCGIAdv_ABS_DOC_ACTG_GAX( 1, 2, '18PPB Grades 1-12 SFY2018:VAR/3010', 2387678.36,
                                                                                       '170721-2', 2, date.today(), '2480', '400',
                                                                                       '0100', 'PPB', '7511', '18PPB', '030' ) );
        gax.createAMS_DOCUMENTwithDefaults( TRUE, '400', 'null', '', header, vendor, accountingLines );
        httpresponse resp = IntegUtahGrantorAPI.postGAXPaymentDetails( gax );
        System.assertEquals( 200, resp.getStatusCode(), 'Test 2: Successful response not received' );
        IntegCGIAdv_GAX_Document gax2 = new IntegCGIAdv_GAX_Document('1', 'TestName', '400');
        IntegCGIAdv_GAX_Document gax3 = new IntegCGIAdv_GAX_Document('1', 'TestName', DateTime.now(), '400');
        IntegCGIAdv_GAX_Document gax4 = new IntegCGIAdv_GAX_Document('1', 'TestName', Datetime.now(), Integ_CGIAdv_Utilities.DefaultTimeZone(), 
                                                                     new IntegCGIAdv_GAX_Document.IntegCGIAdv_AMS_Document_GAX[]{}, '400');
        IntegCGIAdv_GAX_Document gax5 = new IntegCGIAdv_GAX_Document('1', 'TestName', Datetime.now(), 
                                                                     new IntegCGIAdv_GAX_Document.IntegCGIAdv_AMS_Document_GAX[]{}, '400');
        IntegCGIAdv_GAX_Document gax6 = new IntegCGIAdv_GAX_Document('1', 'TestName', new IntegCGIAdv_GAX_Document.IntegCGIAdv_AMS_Document_GAX[]{}, '400');
        gax5.createAMS_DOCUMENT( true, 'NAME', 'DOC_CAT', 'DOC_TYP', 'DOC_CD', 'DOC_DEPT_CD','DOC_UNIT_CD', 'DOC_ID',  'DOC_VERS_NO', true, 
                                'DOC_IMPORT_MODE', 
                                new IntegCGIAdv_GAX_Document.IntegCGIAdv_ABS_DOC_HDR_GAX(),
                                new IntegCGIAdv_GAX_Document.IntegCGIAdv_ABS_DOC_VEND_GAX(),
                                new IntegCGIAdv_GAX_Document.IntegCGIAdv_ABS_DOC_ACTG_GAX[]{new IntegCGIAdv_GAX_Document.IntegCGIAdv_ABS_DOC_ACTG_GAX()} );
        gax6.initializeAMS_DOCUMENTwithDefaults( true, 'DOC_DEPT_CD', 'DOC_UNIT_CD', 'DOC_ID' );
        IntegCGIAdv_GAX_Document.IntegCGIAdv_AMS_Document_GAX gd = new IntegCGIAdv_GAX_Document.IntegCGIAdv_AMS_Document_GAX();
        
        IntegCGIAdv_GAX_DeleteFile gaxDF = new IntegCGIAdv_GAX_DeleteFile();
        gaxDF.addFile('test2.xml');
        gaxDF.removeFile('test2.xml');
        IntegCGIAdv_GAX_DeleteFile gaxDF1 = new IntegCGIAdv_GAX_DeleteFile('Test_file.xml');
        resp = IntegUtahGrantorAPI.deleteDeleteGAX( gaxDF1 );
        
        IntegCGIAdv_GAX_Transmittal_Files gaxTF = new IntegCGIAdv_GAX_Transmittal_Files( 
            new IntegCGIAdv_GAX_Transmittal_Files.IntegCGIAdv_GAX_Transmittal_File( 'filename', 'dept', 'firstdocid', 'lastdocid', 1, 1.00, 'test@reisystems.com' ) );
        gaxTF.addTranmittal( 'filename', 'dept', 'firstdocid', 'lastdocid', 1, 1.00, 'test@reisystems.com' );
        resp = IntegUtahGrantorAPI.postGAXTransmittalFile( gaxTF );
        system.assert(gaxtf.renderJSON(false) != null, 'JSON is null');
        Test.stopTest();
    }
    @isTest(SeeAllData=FALSE)
    private static void IETAPICall(){
        Test.setMock(HttpCalloutMock.class, new IntegCGIAdv_MockHTTPResponseGen('A'));
        setupAPIConn();
        Test.startTest();
        IntegCGIAdv_IET_Document iet = new IntegCGIAdv_IET_Document('400');
        IntegCGIAdv_IET_Document.IntegCGIAdv_IET_DOC_HDR_IET header = new IntegCGIAdv_IET_Document.IntegCGIAdv_IET_DOC_HDR_IET(
            date.newInstance(2017, 10, 18), '1', 2018, '0000,000,00', '00', 'P', '9999' );
        IntegCGIAdv_IET_Document.IntegCGIAdv_IET_DOC_VEND_IET vendor = new IntegCGIAdv_IET_Document.IntegCGIAdv_IET_DOC_VEND_IET(
            1, '44348A', '00', 'IN04', '7000', '050', '7560', 'null', 'null', 'null', 'null', '4052', 'null', 'null', 'null', 37026.82 );
        IntegCGIAdv_IET_Document.IntegCGIAdv_IET_DOC_ACTG_IET[] accountingLines = new IntegCGIAdv_IET_Document.IntegCGIAdv_IET_DOC_ACTG_IET[]{};
        accountingLines.add( new IntegCGIAdv_IET_Document.IntegCGIAdv_IET_DOC_ACTG_IET(
            1, 2, '17T1FT Flow-through FFY2017 FY 2018 Fiscal Month 4', 37026.82, '2480', '400', '0664', 'PAE', 'null', '7508', 'null', 'null', '17T1FT', '020', 'null' ) );
        iet.createAMS_DOCUMENTwithDefaults( TRUE, '400', 'null', '', header, vendor, accountingLines );
        httpresponse resp = IntegUtahGrantorAPI.postIETPaymentDetails( iet );
        System.assertEquals( 200, resp.getStatusCode(), 'Test 2: Successful response not received' );
        IntegCGIAdv_IET_Document iet2 = new IntegCGIAdv_IET_Document('1', 'TestName', '400');
        IntegCGIAdv_IET_Document iet3 = new IntegCGIAdv_IET_Document('1', 'TestName', DateTime.now(), '400');
        IntegCGIAdv_IET_Document iet4 = new IntegCGIAdv_IET_Document('1', 'TestName', Datetime.now(), Integ_CGIAdv_Utilities.DefaultTimeZone(), 
                                                                     new IntegCGIAdv_IET_Document.IntegCGIAdv_AMS_Document_IET[]{}, '400');
        IntegCGIAdv_IET_Document iet5 = new IntegCGIAdv_IET_Document('1', 'TestName', Datetime.now(), 
                                                                     new IntegCGIAdv_IET_Document.IntegCGIAdv_AMS_Document_IET[]{}, '400');
        IntegCGIAdv_IET_Document iet6 = new IntegCGIAdv_IET_Document('1', 'TestName', new IntegCGIAdv_IET_Document.IntegCGIAdv_AMS_Document_IET[]{}, '400');
        iet5.createAMS_DOCUMENT( true, 'NAME', 'DOC_CAT', 'DOC_TYP', 'DOC_CD', 'DOC_DEPT_CD','DOC_UNIT_CD', 'DOC_ID',  'DOC_VERS_NO', true, 
                                'DOC_IMPORT_MODE', 
                                new IntegCGIAdv_IET_Document.IntegCGIAdv_IET_DOC_HDR_IET(),
                                new IntegCGIAdv_IET_Document.IntegCGIAdv_IET_DOC_VEND_IET(),
                                new IntegCGIAdv_IET_Document.IntegCGIAdv_IET_DOC_ACTG_IET[]{new IntegCGIAdv_IET_Document.IntegCGIAdv_IET_DOC_ACTG_IET()} );
        iet6.initializeAMS_DOCUMENTwithDefaults( true, 'DOC_DEPT_CD', 'DOC_UNIT_CD', 'DOC_ID' );
        IntegCGIAdv_IET_Document.IntegCGIAdv_AMS_Document_IET gd = new IntegCGIAdv_IET_Document.IntegCGIAdv_AMS_Document_IET();
        
        IntegCGIAdv_IET_DeleteFile ietDF = new IntegCGIAdv_IET_DeleteFile();
        IntegCGIAdv_IET_DeleteFile ietDF1 = new IntegCGIAdv_IET_DeleteFile('Test_file.xml');
        resp = IntegUtahGrantorAPI.deleteDeleteIET( ietDF1 );
        
        IntegCGIAdv_IET_Transmittal_Files ietTF = new IntegCGIAdv_IET_Transmittal_Files( 
            new IntegCGIAdv_IET_Transmittal_Files.IntegCGIAdv_IET_Transmittal_File( 'filename', 'dept', 'firstdocid', 'lastdocid', 1, 1.00, 'test@reisystems.com' ) );
        ietTF.addTranmittal( 'filename', 'dept', 'firstdocid', 'lastdocid', 1, 1.00, 'test@reisystems.com' );
        resp = IntegUtahGrantorAPI.postIETTransmittalFile( ietTF );
        system.assert(iettf.renderJSON(false) != null, 'JSON is null');
        Test.stopTest();
    }
    @isTest(SeeAllData=FALSE)
    private static void ProgramAPICall(){
        Test.setMock(HttpCalloutMock.class, new IntegCGIAdv_MockHTTPResponseGen('A'));
        setupAPIConn();
        Test.startTest();
        IntegCGIAdv_GCAM_Program_Document prog = new IntegCGIAdv_GCAM_Program_Document('400');
        IntegCGIAdv_GCAM_Program_Document.IntegCGIAdv_CAM_DOC_HDR_GCAM_Program header = new IntegCGIAdv_GCAM_Program_Document.IntegCGIAdv_CAM_DOC_HDR_GCAM_Program(
            '(GovGrants Unique Record ID,GovGrants User ID)' );
        IntegCGIAdv_GCAM_Program_Document.IntegCGIAdv_CAM_DOC_MJRPROG_GCAM_Program[] mjrprograms = 
            new IntegCGIAdv_GCAM_Program_Document.IntegCGIAdv_CAM_DOC_MJRPROG_GCAM_Program[]{};
        IntegCGIAdv_GCAM_Program_Document.IntegCGIAdv_CAM_DOC_MJRPROG_GCAM_Program mjrprogram = 
                new IntegCGIAdv_GCAM_Program_Document.IntegCGIAdv_CAM_DOC_MJRPROG_GCAM_Program(
            1, '400', '84011', 'Test Setup for UtahGrants - All Tables', 'Test UtahGrants', true, null, null, true, '2', '2', '40', '1', '2', 'null');
        mjrprograms.add( mjrprogram );
        IntegCGIAdv_GCAM_Program_Document.IntegCGIAdv_CAM_DOC_PROG_GCAM_Program[] programs = new IntegCGIAdv_GCAM_Program_Document.IntegCGIAdv_CAM_DOC_PROG_GCAM_Program[]{};
        IntegCGIAdv_GCAM_Program_Document.IntegCGIAdv_CAM_DOC_PROG_GCAM_Program program = new IntegCGIAdv_GCAM_Program_Document.IntegCGIAdv_CAM_DOC_PROG_GCAM_Program(
            1, 1, '1', '18UTGRNT01', 'Test Setup for UtahGrants', 'Test UtahGrants', true, true, '2', true, Date.newInstance(2017, 10, 1), 'V002A160045',
            '1230/3100', null, null, 'null', 'SAS', 'FED', 'PROG', date.today() );
        programs.add( program );
        prog.createAMS_DOCUMENTwithDefaults( TRUE, '400', 'null', '18', header, mjrprograms, programs );

        httpresponse resp = IntegUtahGrantorAPI.postCreateProgram( prog );
        System.assertEquals( 200, resp.getStatusCode(), 'Test 2: Successful response not received' );
        IntegCGIAdv_GCAM_Program_Document prog2 = new IntegCGIAdv_GCAM_Program_Document('1', 'TestName', '400');
        IntegCGIAdv_GCAM_Program_Document prog3 = new IntegCGIAdv_GCAM_Program_Document('1', 'TestName', DateTime.now(), '400');
        IntegCGIAdv_GCAM_Program_Document prog4 = new IntegCGIAdv_GCAM_Program_Document('1', 'TestName', Datetime.now(), Integ_CGIAdv_Utilities.DefaultTimeZone(), 
                                                                    new IntegCGIAdv_GCAM_Program_Document.IntegCGIAdv_AMS_Document_GCAM_Program[]{}, '400');
        IntegCGIAdv_GCAM_Program_Document prog5 = new IntegCGIAdv_GCAM_Program_Document('1', 'TestName', Datetime.now(), 
                                                                    new IntegCGIAdv_GCAM_Program_Document.IntegCGIAdv_AMS_Document_GCAM_Program[]{}, '400');
        IntegCGIAdv_GCAM_Program_Document prog6 = new IntegCGIAdv_GCAM_Program_Document('1', 'TestName', 
                                                                    new IntegCGIAdv_GCAM_Program_Document.IntegCGIAdv_AMS_Document_GCAM_Program[]{}, '400');
        prog5.createAMS_DOCUMENT( true, 'NAME', 'DOC_CAT', 'DOC_TYP', 'DOC_CD', 'DOC_DEPT_CD','DOC_UNIT_CD', 'DOC_ID',  'DOC_VERS_NO', true, 
                                'DOC_IMPORT_MODE', 
                                new IntegCGIAdv_GCAM_Program_Document.IntegCGIAdv_CAM_DOC_HDR_GCAM_Program(),
                                new IntegCGIAdv_GCAM_Program_Document.IntegCGIAdv_CAM_DOC_MJRPROG_GCAM_Program[]{},
                                new IntegCGIAdv_GCAM_Program_Document.IntegCGIAdv_CAM_DOC_PROG_GCAM_Program[]{
                                    new IntegCGIAdv_GCAM_Program_Document.IntegCGIAdv_CAM_DOC_PROG_GCAM_Program()} );
        prog6.initializeAMS_DOCUMENTwithDefaults( true, 'DOC_DEPT_CD', 'DOC_UNIT_CD', 'DOC_ID' );
        IntegCGIAdv_GCAM_Program_Document.IntegCGIAdv_AMS_Document_GCAM_Program gd = new IntegCGIAdv_GCAM_Program_Document.IntegCGIAdv_AMS_Document_GCAM_Program();
        
        IntegCGIAdv_Program_DeleteFile progDF = new IntegCGIAdv_Program_DeleteFile();
        IntegCGIAdv_Program_DeleteFile progDF1 = new IntegCGIAdv_Program_DeleteFile('Test_file.xml');
        resp = IntegUtahGrantorAPI.deleteDeleteProgram( progDF1 );
        
        IntegCGIAdv_Program_Transmittal_Files progTF = new IntegCGIAdv_Program_Transmittal_Files( 
            new IntegCGIAdv_Program_Transmittal_Files.IntegCGIAdv_Program_Transmittal_File( 'filename', 'dept', 'firstdocid', 'lastdocid', 1, 1.00, 'test@reisystems.com' ) );
        progTF.addTranmittal( 'filename', 'dept', 'firstdocid', 'lastdocid', 1, 1.00, 'test@reisystems.com' );
        resp = IntegUtahGrantorAPI.postProgramTransmittalFile( progTF );
        system.assert(progtf.renderJSON(false) != null, 'JSON is null');
        Test.stopTest();
    }
    @isTest(SeeAllData=FALSE)
    private static void ProgramPhaseBudgetCreationAPICall(){
        Test.setMock(HttpCalloutMock.class, new IntegCGIAdv_MockHTTPResponseGen('A'));
        setupAPIConn();
        Test.startTest();
        IntegCGIAdv_GCAM_ProgPhse_Budgt_Document ppb = new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document('400');
        IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_HDR_GCAM_ProgPhse_Budgt header = 
            new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_HDR_GCAM_ProgPhse_Budgt( '(GovGrants Unique Record ID,GovGrants User ID)' );
        IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_MJRPROG_GCAM_ProgPhse_Budgt[] mjrprograms = 
            new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_MJRPROG_GCAM_ProgPhse_Budgt[]{};
        IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_MJRPROG_GCAM_ProgPhse_Budgt mjrprogram = 
            new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_MJRPROG_GCAM_ProgPhse_Budgt( 1, '400', '84011', 'Test Setup for UtahGrants - All Tables',
                                                                                                         'Test UtahGrants', true, null, null, true, '2', '2',
                                                                                                         '40', '1', '2', 'null');
        mjrprograms.add( mjrprogram );
        IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_PROG_GCAM_ProgPhse_Budgt[] programs = new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_PROG_GCAM_ProgPhse_Budgt[]{};
            IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_PROG_GCAM_ProgPhse_Budgt program =
            new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_PROG_GCAM_ProgPhse_Budgt( 1, 1, '2', '18MGAD', 'Administration FFY2018', 'Test UtahGrants',
                                                                                                      true, true, '2', true, Date.newinstance(2017, 7, 1), 'V002A160045',
                                                                                                      '1230/3100', null, null, 'null', 'SAS', 'FED', 'PROG', Date.Today() );
        programs.add( program );
        IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_PHSEPROG_GCAM_ProgPhse_Budgt[] programPhases = new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_PHSEPROG_GCAM_ProgPhse_Budgt[]{};
            IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_PHSEPROG_GCAM_ProgPhse_Budgt programPhase =
            new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_PHSEPROG_GCAM_ProgPhse_Budgt( 1, 1, 1, '1', '030', '18MGAD', 'PTIF', '00District',
                                                                                                          null, null, Date.newInstance(2017, 07, 01), true, true, true,
                                                                                                          '2', 'BEAVER CO SCHOOL DISTRICT --Special Education - Preschool SFY2018' );
        programPhases.add( programPhase );
        IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_FPI_GCAM_ProgPhse_Budgt[] FPIlines = new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_FPI_GCAM_ProgPhse_Budgt[]{};
            IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_FPI_GCAM_ProgPhse_Budgt FPIline =
            new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_FPI_GCAM_ProgPhse_Budgt( 1, '1', '2', '18MGAD', '84011', '1', '030' );
        FPIlines.add( FPIline );
        
        IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_BUDLN_GCAM_ProgPhse_Budgt[] Budgetlines =
            new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_BUDLN_GCAM_ProgPhse_Budgt[]{};
        IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_BUDLN_GCAM_ProgPhse_Budgt Budgetline =
            new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_BUDLN_GCAM_ProgPhse_Budgt( 1, 1, 'BGPHR', '2',  'BG22', 'Test Setup for UtahGrants',
                                                                                                       null, null, 100000.00, '18MGAD', '030', '84011', '10', '1',
                                                                                                       '1', '2' );
        Budgetlines.add( Budgetline );
        ppb.createAMS_DOCUMENTwithDefaults( TRUE, '400', 'null', '18', header, mjrprograms, programs, programPhases, FPIlines, Budgetlines );
        httpresponse resp = IntegUtahGrantorAPI.postCreateProgramPhaseWithBudget( ppb );
        System.assertEquals( 200, resp.getStatusCode(), 'Test 2: Successful response not received' );
        IntegCGIAdv_GCAM_ProgPhse_Budgt_Document ppb2 = new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document('1', 'TestName', '400');
        IntegCGIAdv_GCAM_ProgPhse_Budgt_Document ppb3 = new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document('1', 'TestName', DateTime.now(), '400');
        IntegCGIAdv_GCAM_ProgPhse_Budgt_Document ppb4 = new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document('1', 'TestName', Datetime.now(), Integ_CGIAdv_Utilities.DefaultTimeZone(), 
            new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_AMS_Document_GCAM_ProgramPhase_Budget[]{}, '400');
        IntegCGIAdv_GCAM_ProgPhse_Budgt_Document ppb5 = new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document('1', 'TestName', Datetime.now(), 
            new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_AMS_Document_GCAM_ProgramPhase_Budget[]{}, '400');
        IntegCGIAdv_GCAM_ProgPhse_Budgt_Document ppb6 = new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document('1', 'TestName', 
            new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_AMS_Document_GCAM_ProgramPhase_Budget[]{}, '400');
        ppb5.createAMS_DOCUMENT( true, 'NAME', 'DOC_CAT', 'DOC_TYP', 'DOC_CD', 'DOC_DEPT_CD','DOC_UNIT_CD', 'DOC_ID',  'DOC_VERS_NO', true, 
                                'DOC_IMPORT_MODE', 
                                new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_HDR_GCAM_ProgPhse_Budgt(),
                                new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_MJRPROG_GCAM_ProgPhse_Budgt[]{},
                                new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_PROG_GCAM_ProgPhse_Budgt[]{
                                    new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_PROG_GCAM_ProgPhse_Budgt()},
                                new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_PHSEPROG_GCAM_ProgPhse_Budgt[]{},
                                new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_FPI_GCAM_ProgPhse_Budgt[]{},
                                new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_BUDLN_GCAM_ProgPhse_Budgt[]{});
        ppb6.initializeAMS_DOCUMENTwithDefaults( true, 'DOC_DEPT_CD', 'DOC_UNIT_CD', 'DOC_ID' );
        IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_AMS_Document_GCAM_ProgramPhase_Budget gd = 
            new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_AMS_Document_GCAM_ProgramPhase_Budget();
        
        IntegCGIAdv_ProgPhaseBudget_DeleteFile ppbDF = new IntegCGIAdv_ProgPhaseBudget_DeleteFile();
        IntegCGIAdv_ProgPhaseBudget_DeleteFile ppbDF1 = new IntegCGIAdv_ProgPhaseBudget_DeleteFile('Test_file.xml');
        resp = IntegUtahGrantorAPI.deleteDeleteProgramPhaseBudget( ppbDF1 );
        
        IntegCGIAdv_ProgPhasBud_Transmit_Files ppbTF = new IntegCGIAdv_ProgPhasBud_Transmit_Files( 
            new IntegCGIAdv_ProgPhasBud_Transmit_Files.IntegCGIAdv_ProgPhasBud_Transmittal_File( 'filename', 'dept', 'firstdocid', 'lastdocid', 1, 1.00, 'test@reisystems.com' ) );
        ppbTF.addTranmittal( 'filename', 'dept', 'firstdocid', 'lastdocid', 1, 1.00, 'test@reisystems.com' );
        resp = IntegUtahGrantorAPI.postProgramPhaseBudgetTransmittalFile( ppbTF );
        system.assert(ppbtf.renderJSON(false) != null, 'JSON is null');
        Test.stopTest();
    }
    @isTest(SeeAllData=FALSE)
    private static void ProgramPhaseBudgetModificationAPICall(){
        Test.setMock(HttpCalloutMock.class, new IntegCGIAdv_MockHTTPResponseGen('A'));
        setupAPIConn();
        Test.startTest();
        IntegCGIAdv_GCAM_ProgPhse_Mod_Document ppb = new IntegCGIAdv_GCAM_ProgPhse_Mod_Document( '400' );
        IntegCGIAdv_GCAM_ProgPhse_Mod_Document.IntegCGIAdv_CAM_DOC_HDR_GCAM_ProgPhse_Mod header = 
            new IntegCGIAdv_GCAM_ProgPhse_Mod_Document.IntegCGIAdv_CAM_DOC_HDR_GCAM_ProgPhse_Mod( '(GovGrants Unique Record ID,GovGrants User ID)' );
        IntegCGIAdv_GCAM_ProgPhse_Mod_Document.IntegCGIAdv_CAM_DOC_MJRPROG_GCAM_ProgPhse_Mod[] mjrprograms =
            new IntegCGIAdv_GCAM_ProgPhse_Mod_Document.IntegCGIAdv_CAM_DOC_MJRPROG_GCAM_ProgPhse_Mod[]{};
        IntegCGIAdv_GCAM_ProgPhse_Mod_Document.IntegCGIAdv_CAM_DOC_MJRPROG_GCAM_ProgPhse_Mod mjrprogram = 
            new IntegCGIAdv_GCAM_ProgPhse_Mod_Document.IntegCGIAdv_CAM_DOC_MJRPROG_GCAM_ProgPhse_Mod( 1, '400', '84011', 'Test Setup for UtahGrants - All Tables',
                                                                                                     'Test UtahGrants', true, null, null, true, '2', '2',
                                                                                                     '40', '1', '2', 'null');
        mjrprograms.add( mjrprogram );
        IntegCGIAdv_GCAM_ProgPhse_Mod_Document.IntegCGIAdv_CAM_DOC_PROG_GCAM_ProgPhse_Mod[] programs = new IntegCGIAdv_GCAM_ProgPhse_Mod_Document.IntegCGIAdv_CAM_DOC_PROG_GCAM_ProgPhse_Mod[]{};
            IntegCGIAdv_GCAM_ProgPhse_Mod_Document.IntegCGIAdv_CAM_DOC_PROG_GCAM_ProgPhse_Mod program =
            new IntegCGIAdv_GCAM_ProgPhse_Mod_Document.IntegCGIAdv_CAM_DOC_PROG_GCAM_ProgPhse_Mod( 1, 1, '2', '18MGAD', 'Administration FFY2018', 'Test UtahGrants',
                                                                                                  true, true, '2', true, Date.newinstance(2017, 7, 1), 'V002A160045',
                                                                                                  '1230/3100', null, null, 'null', 'SAS', 'FED', 'PROG', date.today() );
        programs.add( program );
        IntegCGIAdv_GCAM_ProgPhse_Mod_Document.IntegCGIAdv_CAM_DOC_PHSEPROG_GCAM_ProgPhse_Mod[] programPhases =
            new IntegCGIAdv_GCAM_ProgPhse_Mod_Document.IntegCGIAdv_CAM_DOC_PHSEPROG_GCAM_ProgPhse_Mod[]{};
        IntegCGIAdv_GCAM_ProgPhse_Mod_Document.IntegCGIAdv_CAM_DOC_PHSEPROG_GCAM_ProgPhse_Mod programPhase =
            new IntegCGIAdv_GCAM_ProgPhse_Mod_Document.IntegCGIAdv_CAM_DOC_PHSEPROG_GCAM_ProgPhse_Mod( 1, 1, 1, '1', '030', '18MGAD', 'PTIF', '00District',
                                                                                                      null, null, Date.newInstance(2017, 07, 01), true, true, true,
                                                                                                      '2', 'BEAVER CO SCHOOL DISTRICT --Special Education - Preschool SFY2018' );
        programPhases.add( programPhase );
        ppb.createAMS_DOCUMENTwithDefaults( TRUE, '400', 'null', '18', header, mjrprogram, programs, programPhases );
        httpresponse resp = IntegUtahGrantorAPI.putModifyProgramPhaseBudget( ppb );
        System.assertEquals( 200, resp.getStatusCode(), 'Test 2: Successful response not received' );
        IntegCGIAdv_GCAM_ProgPhse_Mod_Document ppb2 = new IntegCGIAdv_GCAM_ProgPhse_Mod_Document('1', 'TestName', '400');
        IntegCGIAdv_GCAM_ProgPhse_Mod_Document ppb3 = new IntegCGIAdv_GCAM_ProgPhse_Mod_Document('1', 'TestName', DateTime.now(), '400');
        IntegCGIAdv_GCAM_ProgPhse_Mod_Document ppb4 = new IntegCGIAdv_GCAM_ProgPhse_Mod_Document('1', 'TestName', Datetime.now(), Integ_CGIAdv_Utilities.DefaultTimeZone(), 
            new IntegCGIAdv_GCAM_ProgPhse_Mod_Document.IntegCGIAdv_AMS_Document_GCAM_ProgramPhase_Mod[]{}, '400');
        IntegCGIAdv_GCAM_ProgPhse_Mod_Document ppb5 = new IntegCGIAdv_GCAM_ProgPhse_Mod_Document('1', 'TestName', Datetime.now(), 
            new IntegCGIAdv_GCAM_ProgPhse_Mod_Document.IntegCGIAdv_AMS_Document_GCAM_ProgramPhase_Mod[]{}, '400');
        IntegCGIAdv_GCAM_ProgPhse_Mod_Document ppb6 = new IntegCGIAdv_GCAM_ProgPhse_Mod_Document('1', 'TestName', 
            new IntegCGIAdv_GCAM_ProgPhse_Mod_Document.IntegCGIAdv_AMS_Document_GCAM_ProgramPhase_Mod[]{}, '400');
        ppb5.createAMS_DOCUMENT( true, 'NAME', 'DOC_CAT', 'DOC_TYP', 'DOC_CD', 'DOC_DEPT_CD','DOC_UNIT_CD', 'DOC_ID',  'DOC_VERS_NO', true, 
                                'DOC_IMPORT_MODE', 
                                new IntegCGIAdv_GCAM_ProgPhse_Mod_Document.IntegCGIAdv_CAM_DOC_HDR_GCAM_ProgPhse_Mod(),
                                new IntegCGIAdv_GCAM_ProgPhse_Mod_Document.IntegCGIAdv_CAM_DOC_MJRPROG_GCAM_ProgPhse_Mod(),
                                new IntegCGIAdv_GCAM_ProgPhse_Mod_Document.IntegCGIAdv_CAM_DOC_PROG_GCAM_ProgPhse_Mod[]{
                                    new IntegCGIAdv_GCAM_ProgPhse_Mod_Document.IntegCGIAdv_CAM_DOC_PROG_GCAM_ProgPhse_Mod()},
                                new IntegCGIAdv_GCAM_ProgPhse_Mod_Document.IntegCGIAdv_CAM_DOC_PHSEPROG_GCAM_ProgPhse_Mod[]{});
        ppb6.initializeAMS_DOCUMENTwithDefaults( true, 'DOC_DEPT_CD', 'DOC_UNIT_CD', 'DOC_ID' );
        IntegCGIAdv_GCAM_ProgPhse_Mod_Document.IntegCGIAdv_AMS_Document_GCAM_ProgramPhase_Mod gd = 
            new IntegCGIAdv_GCAM_ProgPhse_Mod_Document.IntegCGIAdv_AMS_Document_GCAM_ProgramPhase_Mod();
        Test.stopTest();
    }
}