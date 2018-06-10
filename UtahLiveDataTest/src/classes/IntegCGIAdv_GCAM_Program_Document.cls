/**
* IntegCGIAdv_GCAM_Program_Document is used to produce the JSON for Program files
*
* CHANGE HISTORY
* ==================================================================================================
* Date              Name                Description
* Mar 01 2018       Brian Mason         Created
* ==================================================================================================
*/
public class IntegCGIAdv_GCAM_Program_Document extends IntegCGIAdv_AMS_DOC_XML_EXPORT_Wrapper{
	// PRIVATE STATIC CONSTANTS
    private static final String DOCCAT = 'CA';
    private static final String DOCTYP = 'CAM';
    private static final String DOCCD = 'GCAM';
    private static final String DOCVERSNO = '1';
    private static final Boolean AUTODOCNUM = TRUE;
    private static final String DOCIMPORTMODE = 'OE';
    private static final String CAMDOCROOTNAME = 'AMS_DOC_XML_EXPORT_FILE';
    private static final String CAMDOCROOTVERSION = '1.0';
    private static final String CAMDOCNAME = 'AMS_DOCUMENT';
    private static final String CAMHEADERNAME = 'CAM_DOC_HDR';
    private static final String CAMDOCMJRPROGNAME = 'CAM_DOC_MJRPROG';
    private static final String CAMDOCPROGNAME = 'CAM_DOC_PROG';
    // PUBLIC MEMBERS
    public IntegCGIAdv_AMS_Document_GCAM_Program[] DOCUMENTS {get;set;}
    // PUBLIC CONSTRUCTORS
    public IntegCGIAdv_GCAM_Program_Document( String DEPT_CD ){
        this( CAMDOCROOTVERSION, CAMDOCROOTNAME, DateTime.now(), Integ_CGIAdv_Utilities.DefaultTimeZone(), DEPT_CD );
    }
    public IntegCGIAdv_GCAM_Program_Document( String VERSION, String NAME, String DEPT_CD ){
        this( Integ_CGIAdv_Utilities.valueIfBlank( VERSION, CAMDOCROOTVERSION ), Integ_CGIAdv_Utilities.valueIfBlank( NAME, CAMDOCROOTNAME ),
			  DateTime.now(), Integ_CGIAdv_Utilities.DefaultTimeZone(), DEPT_CD );
    }
    public IntegCGIAdv_GCAM_Program_Document( String VERSION, String NAME, DateTime EXPORT_DATE, String DEPT_CD ){
        this( Integ_CGIAdv_Utilities.valueIfBlank( VERSION, CAMDOCROOTVERSION ), Integ_CGIAdv_Utilities.valueIfBlank( NAME, CAMDOCROOTNAME ),
               EXPORT_DATE, Integ_CGIAdv_Utilities.DefaultTimeZone(), DEPT_CD );
    }
    public IntegCGIAdv_GCAM_Program_Document( String VERSION, String NAME, DateTime EXPORT_DATE, String TimeZone, String DEPT_CD ){
        super( Integ_CGIAdv_Utilities.valueIfBlank( VERSION, CAMDOCROOTVERSION ), Integ_CGIAdv_Utilities.valueIfBlank( NAME, CAMDOCROOTNAME ),
               EXPORT_DATE, Integ_CGIAdv_Utilities.valueIfBlank( TimeZone, Integ_CGIAdv_Utilities.DefaultTimeZone() ), DEPT_CD );
        if( DOCUMENTS == NULL ){ DOCUMENTS = new IntegCGIAdv_AMS_Document_GCAM_Program[]{}; }
    }
    public IntegCGIAdv_GCAM_Program_Document( String VERSION, String NAME,
                                              IntegCGIAdv_AMS_Document_GCAM_Program[] AMS_DOCUMENTS, String DEPT_CD ){
        this( VERSION, NAME, DateTime.now(), Integ_CGIAdv_Utilities.DefaultTimeZone(), DEPT_CD );
        if( AMS_DOCUMENTS != NULL ){ this.DOCUMENTS = AMS_DOCUMENTS; }
    }
    public IntegCGIAdv_GCAM_Program_Document( String VERSION, String NAME, DateTime EXPORT_DATE, 
                                              IntegCGIAdv_AMS_Document_GCAM_Program[] AMS_DOCUMENTS, String DEPT_CD ){
		this( VERSION, NAME, EXPORT_DATE, Integ_CGIAdv_Utilities.DefaultTimeZone(), DEPT_CD );
        if( AMS_DOCUMENTS != NULL ){ this.DOCUMENTS = AMS_DOCUMENTS; }
	}
    public IntegCGIAdv_GCAM_Program_Document( String VERSION, String NAME, DateTime EXPORT_DATE, String TimeZone, 
                                              IntegCGIAdv_AMS_Document_GCAM_Program[] AMS_DOCUMENTS, String DEPT_CD ){
		this( VERSION, NAME, EXPORT_DATE, TimeZone, DEPT_CD );
        if( AMS_DOCUMENTS != NULL ){ this.DOCUMENTS = AMS_DOCUMENTS; }
	}
    // PUBLIC METHODS
    public IntegCGIAdv_AMS_Document_GCAM_Program createAMS_DOCUMENT( Boolean addToAMSDOCUMENTS, String NAME, String DOC_CAT, String DOC_TYP, String DOC_CD, String DOC_DEPT_CD, 
                                                             String DOC_UNIT_CD, String DOC_ID, String DOC_VERS_NO, Boolean AUTO_DOC_NUM, String DOC_IMPORT_MODE, 
                                                             IntegCGIAdv_CAM_DOC_HDR_GCAM_Program CAM_DOC_HDR,
                                                             IntegCGIAdv_CAM_DOC_MJRPROG_GCAM_Program[] DOC_MJRPROG,
                                                             IntegCGIAdv_CAM_DOC_PROG_GCAM_Program[] DOC_PROG ){
        IntegCGIAdv_AMS_Document_GCAM_Program newDoc = 
            new IntegCGIAdv_AMS_Document_GCAM_Program( NAME, DOC_CAT, DOC_TYP, DOC_CD, DOC_DEPT_CD, DOC_UNIT_CD, DOC_ID, DOC_VERS_NO, AUTO_DOC_NUM, DOC_IMPORT_MODE, 
                                               CAM_DOC_HDR, DOC_MJRPROG, DOC_PROG );
        if( addToAMSDOCUMENTS ){ this.DOCUMENTS.add( newDoc ); } 
        return newDoc;
    }
    public IntegCGIAdv_AMS_Document_GCAM_Program createAMS_DOCUMENTwithDefaults( Boolean addToAMSDOCUMENTS, String DOC_DEPT_CD, String DOC_UNIT_CD, String DOC_ID, 
                                                                        IntegCGIAdv_CAM_DOC_HDR_GCAM_Program CAM_DOC_HDR,
                                                                        IntegCGIAdv_CAM_DOC_MJRPROG_GCAM_Program[] DOC_MJRPROG,
                                                                        IntegCGIAdv_CAM_DOC_PROG_GCAM_Program[] DOC_PROG ){
        IntegCGIAdv_AMS_Document_GCAM_Program newDoc = 
            new IntegCGIAdv_AMS_Document_GCAM_Program( DOCCAT, DOCTYP, DOCCD, DOC_DEPT_CD, DOC_UNIT_CD, DOC_ID, DOCVERSNO, AUTODOCNUM, DOCIMPORTMODE, 
													   CAM_DOC_HDR, DOC_MJRPROG, DOC_PROG );
        if( addToAMSDOCUMENTS ){ this.DOCUMENTS.add( newDoc ); }
        return newDoc;
    }
    public IntegCGIAdv_AMS_Document_GCAM_Program initializeAMS_DOCUMENTwithDefaults( Boolean addToAMSDOCUMENTS, String DOC_DEPT_CD,
                                                                                     String DOC_UNIT_CD, String DOC_ID ){
        IntegCGIAdv_CAM_DOC_HDR_GCAM_Program DOCHDR = new IntegCGIAdv_CAM_DOC_HDR_GCAM_Program();
        DOCHDR.NAME = CAMHEADERNAME;
		IntegCGIAdv_CAM_DOC_MJRPROG_GCAM_Program[] DOCMJRPROGs = new IntegCGIAdv_CAM_DOC_MJRPROG_GCAM_Program[]{};
        IntegCGIAdv_CAM_DOC_MJRPROG_GCAM_Program DOCMJRPROG = new IntegCGIAdv_CAM_DOC_MJRPROG_GCAM_Program();
        DOCMJRPROG.NAME = CAMDOCMJRPROGNAME;
		DOCMJRPROGs.add( DOCMJRPROG );
        IntegCGIAdv_CAM_DOC_PROG_GCAM_Program[] DOC_PROGs = new IntegCGIAdv_CAM_DOC_PROG_GCAM_Program[]{};
        IntegCGIAdv_CAM_DOC_PROG_GCAM_Program DOC_PROG = new IntegCGIAdv_CAM_DOC_PROG_GCAM_Program();
        DOC_PROG.NAME = CAMDOCPROGNAME;
        DOC_PROGs.add( DOC_PROG );
        DOC_PROG.NAME = CAMDOCPROGNAME;
        IntegCGIAdv_AMS_Document_GCAM_Program newDoc = 
            new IntegCGIAdv_AMS_Document_GCAM_Program( DOCCAT, DOCTYP, DOCCD, DOC_DEPT_CD, DOC_UNIT_CD, DOC_ID, DOCVERSNO,
                                                       AUTODOCNUM, DOCIMPORTMODE, DOCHDR, DOCMJRPROGs, DOC_PROGs );
        if( addToAMSDOCUMENTS ){ this.DOCUMENTS.add( newDoc ); }
        return newDoc;
    }
    // PUBLIC CLASSES
    public class IntegCGIAdv_AMS_Document_GCAM_Program extends IntegCGIAdv_AMS_Document_Wrapper{
        // PUBLIC MEMBERS
        IntegCGIAdv_CAM_DOC_HDR_GCAM_Program DOC_HDR {get;set;}
        IntegCGIAdv_CAM_DOC_MJRPROG_GCAM_Program[] DOC_MJRPROG {get;set;}
        IntegCGIAdv_CAM_DOC_PROG_GCAM_Program[] DOC_PROG {get;set;}
        // PUBLIC CONSTRUCTORS
        public IntegCGIAdv_AMS_Document_GCAM_Program(){ super(); }
        public IntegCGIAdv_AMS_Document_GCAM_Program( String DOC_CAT, String DOC_TYP, String DOC_CD, String DOC_DEPT_CD, String DOC_UNIT_CD, 
                                              String DOC_ID, String DOC_VERS_NO, Boolean AUTO_DOC_NUM, String DOC_IMPORT_MODE,
                                              IntegCGIAdv_CAM_DOC_HDR_GCAM_Program DOC_HDR,
                                              IntegCGIAdv_CAM_DOC_MJRPROG_GCAM_Program[] DOC_MJRPROG,
                                              IntegCGIAdv_CAM_DOC_PROG_GCAM_Program[] DOC_PROG ){
            this( CAMDOCNAME,
                  Integ_CGIAdv_Utilities.valueIfBlank( DOC_CAT, DOCCAT ),
                  Integ_CGIAdv_Utilities.valueIfBlank( DOC_TYP, DOCTYP ),
                  Integ_CGIAdv_Utilities.valueIfBlank( DOC_CD, DOCCD ),
                  DOC_DEPT_CD, DOC_UNIT_CD, DOC_ID, 
                  Integ_CGIAdv_Utilities.valueIfBlank( DOC_VERS_NO, DOCVERSNO ),
                  AUTO_DOC_NUM != NULL ? AUTO_DOC_NUM : AUTODOCNUM,
                  Integ_CGIAdv_Utilities.valueIfBlank( DOC_IMPORT_MODE, DOCIMPORTMODE ),
          		  DOC_HDR, DOC_MJRPROG, DOC_PROG );
        }
        public IntegCGIAdv_AMS_Document_GCAM_Program( String NAME, String DOC_CAT, String DOC_TYP, String DOC_CD, String DOC_DEPT_CD, String DOC_UNIT_CD, 
                                              String DOC_ID, String DOC_VERS_NO, Boolean AUTO_DOC_NUM, String DOC_IMPORT_MODE,
                                              IntegCGIAdv_CAM_DOC_HDR_GCAM_Program DOC_HDR,
                                              IntegCGIAdv_CAM_DOC_MJRPROG_GCAM_Program[] DOC_MJRPROG,
                                              IntegCGIAdv_CAM_DOC_PROG_GCAM_Program[] DOC_PROG ){
            super( Integ_CGIAdv_Utilities.valueIfBlank( NAME, CAMDOCNAME ),
			Integ_CGIAdv_Utilities.valueIfBlank( DOC_CAT, DOCCAT ),
                   Integ_CGIAdv_Utilities.valueIfBlank( DOC_TYP, DOCTYP ),
                   Integ_CGIAdv_Utilities.valueIfBlank( DOC_CD, DOCCD ),
                   DOC_DEPT_CD, DOC_UNIT_CD, DOC_ID,
                   Integ_CGIAdv_Utilities.valueIfBlank( DOC_VERS_NO, DOCVERSNO ),
                   AUTO_DOC_NUM != NULL ? AUTO_DOC_NUM : AUTODOCNUM,
                   Integ_CGIAdv_Utilities.valueIfBlank( DOC_IMPORT_MODE, DOCIMPORTMODE ) );
      		if( DOC_HDR != NULL ){ this.DOC_HDR = DOC_HDR; }
            if( DOC_MJRPROG != NULL ){ this.DOC_MJRPROG = DOC_MJRPROG; }
            if( DOC_PROG != NULL ){ this.DOC_PROG = DOC_PROG; }
        }
    }
    public class IntegCGIAdv_CAM_DOC_HDR_GCAM_Program extends IntegCGIAdv_DOC_HDR_Wrapper{
        // PUBLIC CONSTRUCTORS
        public IntegCGIAdv_CAM_DOC_HDR_GCAM_Program(){ super(); }
        public IntegCGIAdv_CAM_DOC_HDR_GCAM_Program( String DOC_DSCR ){
            this( CAMHEADERNAME, DOC_DSCR );
        }
        public IntegCGIAdv_CAM_DOC_HDR_GCAM_Program( String NAME, String DOC_DSCR ){
            super( Integ_CGIAdv_Utilities.valueIfBlank( NAME, CAMHEADERNAME ), DOC_DSCR );
        }
    }
    public class IntegCGIAdv_CAM_DOC_MJRPROG_GCAM_Program extends IntegCGIAdv_DOC_MJRPROG_Wrapper{
        // PUBLIC CONSTRUCTORS
        public IntegCGIAdv_CAM_DOC_MJRPROG_GCAM_Program(){ super(); }
        public IntegCGIAdv_CAM_DOC_MJRPROG_GCAM_Program( Integer DOC_MJRPROG_LN_NO, String DEPT_CD,
                                                         String MJR_PROG_CD, String MJR_PROG_NM, String MJR_PROG_SH_NM,
                                                         Boolean ACT_FL, Date EFBGN_DT, Date EFEND_DT,
                                                         Boolean ALW_BUD_FL, String SUSP_STA, String REIM_BAS_IND,
                                                         String REIM_BUD_STRU_CD, String SPLT_IND, String FED_APPR_SETP,
                                                         String MJR_PROG_DSRC ){
            this( CAMDOCMJRPROGNAME, DOC_MJRPROG_LN_NO, DEPT_CD, MJR_PROG_CD, MJR_PROG_NM, MJR_PROG_SH_NM, ACT_FL,
                  EFBGN_DT, EFEND_DT, ALW_BUD_FL, SUSP_STA, REIM_BAS_IND, REIM_BUD_STRU_CD, SPLT_IND,
                  FED_APPR_SETP, MJR_PROG_DSRC );
        }
        public IntegCGIAdv_CAM_DOC_MJRPROG_GCAM_Program( String NAME, Integer DOC_MJRPROG_LN_NO, String DEPT_CD,
                                                         String MJR_PROG_CD, String MJR_PROG_NM, String MJR_PROG_SH_NM,
                                                         Boolean ACT_FL, Date EFBGN_DT, Date EFEND_DT,
                                                         Boolean ALW_BUD_FL, String SUSP_STA, String REIM_BAS_IND,
                                                         String REIM_BUD_STRU_CD, String SPLT_IND, String FED_APPR_SETP,
                                                         String MJR_PROG_DSRC ){
            super( Integ_CGIAdv_Utilities.valueIfBlank( NAME, CAMDOCMJRPROGNAME ), DOC_MJRPROG_LN_NO, DEPT_CD, MJR_PROG_CD,
                   MJR_PROG_NM, MJR_PROG_SH_NM, ACT_FL, EFBGN_DT, EFEND_DT, ALW_BUD_FL, SUSP_STA, REIM_BAS_IND,
                   REIM_BUD_STRU_CD, SPLT_IND, FED_APPR_SETP, MJR_PROG_DSRC );
        }
    }
    public class IntegCGIAdv_CAM_DOC_PROG_GCAM_Program extends IntegCGIAdv_DOC_PROG_Wrapper{
        // PUBLIC CONSTRUCTORS
        public IntegCGIAdv_CAM_DOC_PROG_GCAM_Program(){ super(); }
        public IntegCGIAdv_CAM_DOC_PROG_GCAM_Program( Integer DOC_MJRPROG_LN_NO, Integer DOC_PROG_LN_NO,
													  String LN_TYP, String PROG_CD, String PROG_NM, String PROG_SH_NM,
													  Boolean ACT_FL, Boolean ALW_BUD_FL, String SUSP_STA,
													  Boolean REIM_ELG_STA, Date BILL_AGREE_DT, String PROG_DSRC,
													  String SACCT_CD, Date EFBGN_DT, Date EFEND_DT, String PGRP_CD,
													  String PTYP_CD, String PCLS_CD, String PCAT_CD, Date PROJ_END_DT ){
            this( CAMDOCPROGNAME, DOC_MJRPROG_LN_NO, DOC_PROG_LN_NO, LN_TYP, PROG_CD, PROG_NM, PROG_SH_NM,
				  ACT_FL, ALW_BUD_FL, SUSP_STA, REIM_ELG_STA, BILL_AGREE_DT, PROG_DSRC, SACCT_CD, EFBGN_DT,
				  EFEND_DT, PGRP_CD, PTYP_CD, PCLS_CD, PCAT_CD, PROJ_END_DT );
        }
        public IntegCGIAdv_CAM_DOC_PROG_GCAM_Program( String NAME, Integer DOC_MJRPROG_LN_NO, Integer DOC_PROG_LN_NO,
													  String LN_TYP, String PROG_CD, String PROG_NM, String PROG_SH_NM,
													  Boolean ACT_FL, Boolean ALW_BUD_FL, String SUSP_STA,
													  Boolean REIM_ELG_STA, Date BILL_AGREE_DT, String PROG_DSRC,
													  String SACCT_CD, Date EFBGN_DT, Date EFEND_DT, String PGRP_CD,
													  String PTYP_CD, String PCLS_CD, String PCAT_CD, Date PROJ_END_DT ){
            super( Integ_CGIAdv_Utilities.valueIfBlank( NAME, CAMDOCPROGNAME ), DOC_MJRPROG_LN_NO, DOC_PROG_LN_NO,
                   LN_TYP, PROG_CD, PROG_NM, PROG_SH_NM, ACT_FL, ALW_BUD_FL, SUSP_STA, REIM_ELG_STA, BILL_AGREE_DT,
                   PROG_DSRC, SACCT_CD, EFBGN_DT, EFEND_DT, PGRP_CD, PTYP_CD, PCLS_CD, PCAT_CD, PROJ_END_DT );
        }
    }
}