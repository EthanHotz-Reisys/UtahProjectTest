/**
* IntegCGIAdv_GCAM_ProgPhse_Budgt_Document is used to produce the JSON for Program/Phase/Budget
* association files
*
* CHANGE HISTORY
* ==================================================================================================
* Date              Name                Description
* Mar 01 2018       Brian Mason         Created
* ==================================================================================================
*/
public class IntegCGIAdv_GCAM_ProgPhse_Budgt_Document extends IntegCGIAdv_AMS_DOC_XML_EXPORT_Wrapper{
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
    private static final String CAMDOCPHSEPROGNAME = 'CAM_DOC_PHSEPROG';
    private static final String CAMDOCFPINAME = 'CAM_DOC_FPI';
    private static final String CAMDOCBUDLNNAME = 'CAM_DOC_BUDLN';
    // PUBLIC MEMBERS
    public IntegCGIAdv_AMS_Document_GCAM_ProgramPhase_Budget[] DOCUMENTS {get;set;}
    // PUBLIC CONSTRUCTORS
    public IntegCGIAdv_GCAM_ProgPhse_Budgt_Document( String DEPT_CD ){
        this( CAMDOCROOTVERSION, CAMDOCROOTNAME, DateTime.now(), Integ_CGIAdv_Utilities.DefaultTimeZone(), DEPT_CD );
    }
    public IntegCGIAdv_GCAM_ProgPhse_Budgt_Document( String VERSION, String NAME, String DEPT_CD ){
        this( Integ_CGIAdv_Utilities.valueIfBlank( VERSION, CAMDOCROOTVERSION ), Integ_CGIAdv_Utilities.valueIfBlank( NAME, CAMDOCROOTNAME ),
              DateTime.now(), Integ_CGIAdv_Utilities.DefaultTimeZone(), DEPT_CD );
    }
    public IntegCGIAdv_GCAM_ProgPhse_Budgt_Document( String VERSION, String NAME, DateTime EXPORT_DATE, String DEPT_CD ){
        this( Integ_CGIAdv_Utilities.valueIfBlank( VERSION, CAMDOCROOTVERSION ), Integ_CGIAdv_Utilities.valueIfBlank( NAME, CAMDOCROOTNAME ),
               EXPORT_DATE, Integ_CGIAdv_Utilities.DefaultTimeZone(), DEPT_CD );
    }
    public IntegCGIAdv_GCAM_ProgPhse_Budgt_Document( String VERSION, String NAME, DateTime EXPORT_DATE, String TimeZone, String DEPT_CD ){
        super( Integ_CGIAdv_Utilities.valueIfBlank( VERSION, CAMDOCROOTVERSION ), Integ_CGIAdv_Utilities.valueIfBlank( NAME, CAMDOCROOTNAME ),
               EXPORT_DATE, Integ_CGIAdv_Utilities.valueIfBlank( TimeZone, Integ_CGIAdv_Utilities.DefaultTimeZone() ), DEPT_CD );
        if( DOCUMENTS == NULL ){ DOCUMENTS = new IntegCGIAdv_AMS_Document_GCAM_ProgramPhase_Budget[]{}; }
    }
    public IntegCGIAdv_GCAM_ProgPhse_Budgt_Document( String VERSION, String NAME,
                                                     IntegCGIAdv_AMS_Document_GCAM_ProgramPhase_Budget[] AMS_DOCUMENTS, String DEPT_CD ){
        this( VERSION, NAME, DateTime.now(), Integ_CGIAdv_Utilities.DefaultTimeZone(), DEPT_CD );
        if( AMS_DOCUMENTS != NULL ){ this.DOCUMENTS = AMS_DOCUMENTS; }
    }
    public IntegCGIAdv_GCAM_ProgPhse_Budgt_Document( String VERSION, String NAME, DateTime EXPORT_DATE, 
													 IntegCGIAdv_AMS_Document_GCAM_ProgramPhase_Budget[] AMS_DOCUMENTS, String DEPT_CD ){
        this( VERSION, NAME, EXPORT_DATE, Integ_CGIAdv_Utilities.DefaultTimeZone(), DEPT_CD );
        if( AMS_DOCUMENTS != NULL ){ this.DOCUMENTS = AMS_DOCUMENTS; }
    }
    public IntegCGIAdv_GCAM_ProgPhse_Budgt_Document( String VERSION, String NAME, DateTime EXPORT_DATE, String TimeZone, 
													 IntegCGIAdv_AMS_Document_GCAM_ProgramPhase_Budget[] AMS_DOCUMENTS, String DEPT_CD ){
        this( VERSION, NAME, EXPORT_DATE, TimeZone, DEPT_CD );
        if( AMS_DOCUMENTS != NULL ){ this.DOCUMENTS = AMS_DOCUMENTS; }
    }
    // PUBLIC METHODS
    public IntegCGIAdv_AMS_Document_GCAM_ProgramPhase_Budget createAMS_DOCUMENT( Boolean addToAMSDOCUMENTS, String NAME,
                                                                                 String DOC_CAT, String DOC_TYP, String DOC_CD,
                                                                                 String DOC_DEPT_CD, String DOC_UNIT_CD,
                                                                                 String DOC_ID, String DOC_VERS_NO,
                                                                                 Boolean AUTO_DOC_NUM, String DOC_IMPORT_MODE, 
                                                                                 IntegCGIAdv_CAM_DOC_HDR_GCAM_ProgPhse_Budgt DOC_HDR,
                                                                                 IntegCGIAdv_CAM_DOC_MJRPROG_GCAM_ProgPhse_Budgt[] DOC_MJRPROG,
                                                                                 IntegCGIAdv_CAM_DOC_PROG_GCAM_ProgPhse_Budgt[] DOC_PROG,
                                                                                 IntegCGIAdv_CAM_DOC_PHSEPROG_GCAM_ProgPhse_Budgt[] DOC_PHSEPROG,
                                                                                 IntegCGIAdv_CAM_DOC_FPI_GCAM_ProgPhse_Budgt[] DOC_FPI,
                                                                                 IntegCGIAdv_CAM_DOC_BUDLN_GCAM_ProgPhse_Budgt[] DOC_BUDLN ){
        IntegCGIAdv_AMS_Document_GCAM_ProgramPhase_Budget newDoc = 
            new IntegCGIAdv_AMS_Document_GCAM_ProgramPhase_Budget( NAME, DOC_CAT, DOC_TYP, DOC_CD, DOC_DEPT_CD, DOC_UNIT_CD, DOC_ID,
                                                                   DOC_VERS_NO, AUTO_DOC_NUM, DOC_IMPORT_MODE, DOC_HDR, DOC_MJRPROG,
                                                                   DOC_PROG, DOC_PHSEPROG, DOC_FPI, DOC_BUDLN );
        if( addToAMSDOCUMENTS ){ this.DOCUMENTS.add( newDoc ); } 
        return newDoc;
    }
    public IntegCGIAdv_AMS_Document_GCAM_ProgramPhase_Budget createAMS_DOCUMENTwithDefaults( Boolean addToAMSDOCUMENTS, String DOC_DEPT_CD,
                                                                                             String DOC_UNIT_CD, String DOC_ID,
                                                                                             IntegCGIAdv_CAM_DOC_HDR_GCAM_ProgPhse_Budgt DOC_HDR,
                                                                                             IntegCGIAdv_CAM_DOC_MJRPROG_GCAM_ProgPhse_Budgt[] DOC_MJRPROG,
                                                                                             IntegCGIAdv_CAM_DOC_PROG_GCAM_ProgPhse_Budgt[] DOC_PROG,
                                                                                             IntegCGIAdv_CAM_DOC_PHSEPROG_GCAM_ProgPhse_Budgt[] DOC_PHSEPROG,
                                                                                             IntegCGIAdv_CAM_DOC_FPI_GCAM_ProgPhse_Budgt[] DOC_FPI,
                                                                                             IntegCGIAdv_CAM_DOC_BUDLN_GCAM_ProgPhse_Budgt[] DOC_BUDLN ){
        IntegCGIAdv_AMS_Document_GCAM_ProgramPhase_Budget newDoc = 
            new IntegCGIAdv_AMS_Document_GCAM_ProgramPhase_Budget( DOCCAT, DOCTYP, DOCCD, DOC_DEPT_CD, DOC_UNIT_CD, DOC_ID, DOCVERSNO, AUTODOCNUM, DOCIMPORTMODE, 
                                                                   DOC_HDR, DOC_MJRPROG, DOC_PROG, DOC_PHSEPROG, DOC_FPI, DOC_BUDLN );
        if( addToAMSDOCUMENTS ){ this.DOCUMENTS.add( newDoc ); }
        return newDoc;
    }
    public IntegCGIAdv_AMS_Document_GCAM_ProgramPhase_Budget initializeAMS_DOCUMENTwithDefaults( Boolean addToAMSDOCUMENTS,
                                                                                                 String DOC_DEPT_CD,
                                                                                                 String DOC_UNIT_CD,
                                                                                                 String DOC_ID ){
        IntegCGIAdv_CAM_DOC_HDR_GCAM_ProgPhse_Budgt DOCHDR = new IntegCGIAdv_CAM_DOC_HDR_GCAM_ProgPhse_Budgt();
        DOCHDR.NAME = CAMHEADERNAME;
		IntegCGIAdv_CAM_DOC_MJRPROG_GCAM_ProgPhse_Budgt[] DOCMJRPROGs = new IntegCGIAdv_CAM_DOC_MJRPROG_GCAM_ProgPhse_Budgt[]{};
        IntegCGIAdv_CAM_DOC_MJRPROG_GCAM_ProgPhse_Budgt DOCMJRPROG = new IntegCGIAdv_CAM_DOC_MJRPROG_GCAM_ProgPhse_Budgt();
        DOCMJRPROG.NAME = CAMDOCMJRPROGNAME;
		DOCMJRPROGs.add( DOCMJRPROG );
        IntegCGIAdv_CAM_DOC_PROG_GCAM_ProgPhse_Budgt[] DOCPROGs = new IntegCGIAdv_CAM_DOC_PROG_GCAM_ProgPhse_Budgt[]{};
        IntegCGIAdv_CAM_DOC_PROG_GCAM_ProgPhse_Budgt DOCPROG = new IntegCGIAdv_CAM_DOC_PROG_GCAM_ProgPhse_Budgt();
        DOCPROG.NAME = CAMDOCPROGNAME;
        DOCPROGs.add( DOCPROG );
        IntegCGIAdv_CAM_DOC_PHSEPROG_GCAM_ProgPhse_Budgt[] DOCPHSEPROGs = new IntegCGIAdv_CAM_DOC_PHSEPROG_GCAM_ProgPhse_Budgt[]{};
        IntegCGIAdv_CAM_DOC_PHSEPROG_GCAM_ProgPhse_Budgt DOCPHSEPROG = new IntegCGIAdv_CAM_DOC_PHSEPROG_GCAM_ProgPhse_Budgt();
        DOCPHSEPROG.NAME = CAMDOCPHSEPROGNAME;
        DOCPHSEPROGs.add( DOCPHSEPROG );
        IntegCGIAdv_CAM_DOC_FPI_GCAM_ProgPhse_Budgt[] DOCFPIlines = new IntegCGIAdv_CAM_DOC_FPI_GCAM_ProgPhse_Budgt[]{};
        IntegCGIAdv_CAM_DOC_FPI_GCAM_ProgPhse_Budgt DOCFPIline = new IntegCGIAdv_CAM_DOC_FPI_GCAM_ProgPhse_Budgt();
        DOCFPIline.NAME = CAMDOCFPINAME;
        DOCFPIlines.add( DOCFPIline );
        IntegCGIAdv_CAM_DOC_BUDLN_GCAM_ProgPhse_Budgt[] DOCBUDLNS = new IntegCGIAdv_CAM_DOC_BUDLN_GCAM_ProgPhse_Budgt[]{};
        IntegCGIAdv_CAM_DOC_BUDLN_GCAM_ProgPhse_Budgt DOCBUDLN = new IntegCGIAdv_CAM_DOC_BUDLN_GCAM_ProgPhse_Budgt();
        DOCBUDLN.NAME = CAMDOCBUDLNNAME;
        DOCBUDLNS.add( DOCBUDLN );
        IntegCGIAdv_AMS_Document_GCAM_ProgramPhase_Budget newDoc = 
            new IntegCGIAdv_AMS_Document_GCAM_ProgramPhase_Budget( DOCCAT, DOCTYP, DOCCD, DOC_DEPT_CD, DOC_UNIT_CD, DOC_ID, DOCVERSNO, AUTODOCNUM, DOCIMPORTMODE, 
                                                                   DOCHDR, DOCMJRPROGs, DOCPROGs, DOCPHSEPROGs, DOCFPIlines, DOCBUDLNS );
        if( addToAMSDOCUMENTS ){ this.DOCUMENTS.add( newDoc ); }
        return newDoc;
    }
    // PUBLIC CLASSES
    public class IntegCGIAdv_AMS_Document_GCAM_ProgramPhase_Budget extends IntegCGIAdv_AMS_Document_Wrapper{
        // PUBLIC MEMBERS
        IntegCGIAdv_CAM_DOC_HDR_GCAM_ProgPhse_Budgt DOC_HDR {get;set;}
        IntegCGIAdv_CAM_DOC_MJRPROG_GCAM_ProgPhse_Budgt[] DOC_MJRPROG {get;set;}
        IntegCGIAdv_CAM_DOC_PROG_GCAM_ProgPhse_Budgt[] DOC_PROG {get;set;}
        IntegCGIAdv_CAM_DOC_PHSEPROG_GCAM_ProgPhse_Budgt[] DOC_PHSEPROG {get;set;}
        IntegCGIAdv_CAM_DOC_FPI_GCAM_ProgPhse_Budgt[] DOC_FPI {get;set;} 
        IntegCGIAdv_CAM_DOC_BUDLN_GCAM_ProgPhse_Budgt[] DOC_BUDLN {get;set;}
        // PUBLIC CONSTRUCTORS
        public IntegCGIAdv_AMS_Document_GCAM_ProgramPhase_Budget(){ super(); }
        public IntegCGIAdv_AMS_Document_GCAM_ProgramPhase_Budget( String DOC_CAT, String DOC_TYP, String DOC_CD, String DOC_DEPT_CD, String DOC_UNIT_CD, 
                                                                  String DOC_ID, String DOC_VERS_NO, Boolean AUTO_DOC_NUM, String DOC_IMPORT_MODE,
                                                                  IntegCGIAdv_CAM_DOC_HDR_GCAM_ProgPhse_Budgt DOC_HDR,
                                                                  IntegCGIAdv_CAM_DOC_MJRPROG_GCAM_ProgPhse_Budgt[] DOC_MJRPROG,
                                                                  IntegCGIAdv_CAM_DOC_PROG_GCAM_ProgPhse_Budgt[] DOC_PROG,
                                                                  IntegCGIAdv_CAM_DOC_PHSEPROG_GCAM_ProgPhse_Budgt[] DOC_PHSEPROG,
                                                                  IntegCGIAdv_CAM_DOC_FPI_GCAM_ProgPhse_Budgt[] DOC_FPI,
                                                                  IntegCGIAdv_CAM_DOC_BUDLN_GCAM_ProgPhse_Budgt[] DOC_BUDLN ){
            this( CAMDOCNAME,
                  Integ_CGIAdv_Utilities.valueIfBlank( DOC_CAT, DOCCAT ),
                  Integ_CGIAdv_Utilities.valueIfBlank( DOC_TYP, DOCTYP ),
                  Integ_CGIAdv_Utilities.valueIfBlank( DOC_CD, DOCCD ),
                  DOC_DEPT_CD, DOC_UNIT_CD, DOC_ID, 
                  Integ_CGIAdv_Utilities.valueIfBlank( DOC_VERS_NO, DOCVERSNO ),
                  AUTO_DOC_NUM != NULL ? AUTO_DOC_NUM : AUTODOCNUM,
                  Integ_CGIAdv_Utilities.valueIfBlank( DOC_IMPORT_MODE, DOCIMPORTMODE ),
                  DOC_HDR, DOC_MJRPROG, DOC_PROG, DOC_PHSEPROG, DOC_FPI, DOC_BUDLN );
        }
        public IntegCGIAdv_AMS_Document_GCAM_ProgramPhase_Budget( String NAME, String DOC_CAT,
                                                                  String DOC_TYP, String DOC_CD,
                                                                  String DOC_DEPT_CD, String DOC_UNIT_CD, 
                                                                  String DOC_ID, String DOC_VERS_NO,
                                                                  Boolean AUTO_DOC_NUM, String DOC_IMPORT_MODE,
                                                                  IntegCGIAdv_CAM_DOC_HDR_GCAM_ProgPhse_Budgt DOC_HDR,
                                                                  IntegCGIAdv_CAM_DOC_MJRPROG_GCAM_ProgPhse_Budgt[] DOC_MJRPROG,
                                                                  IntegCGIAdv_CAM_DOC_PROG_GCAM_ProgPhse_Budgt[] DOC_PROG,
                                                                  IntegCGIAdv_CAM_DOC_PHSEPROG_GCAM_ProgPhse_Budgt[] DOC_PHSEPROG,
                                                                  IntegCGIAdv_CAM_DOC_FPI_GCAM_ProgPhse_Budgt[] DOC_FPI,
                                                                  IntegCGIAdv_CAM_DOC_BUDLN_GCAM_ProgPhse_Budgt[] DOC_BUDLN ){
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
            if( DOC_PHSEPROG != NULL ){ this.DOC_PHSEPROG = DOC_PHSEPROG; }
            if( DOC_FPI != NULL ){ this.DOC_FPI = DOC_FPI; }
            if( DOC_BUDLN != NULL ){ this.DOC_BUDLN = DOC_BUDLN; }
        }
    }
    public class IntegCGIAdv_CAM_DOC_HDR_GCAM_ProgPhse_Budgt extends IntegCGIAdv_DOC_HDR_Wrapper{
        // PUBLIC CONSTRUCTORS
        public IntegCGIAdv_CAM_DOC_HDR_GCAM_ProgPhse_Budgt(){ super(); }
        public IntegCGIAdv_CAM_DOC_HDR_GCAM_ProgPhse_Budgt( String DOC_DSCR ){
            this( CAMHEADERNAME, DOC_DSCR );
        }
        public IntegCGIAdv_CAM_DOC_HDR_GCAM_ProgPhse_Budgt( String NAME, String DOC_DSCR ){
            super( Integ_CGIAdv_Utilities.valueIfBlank( NAME, CAMHEADERNAME ), DOC_DSCR );
        }
    }
    public class IntegCGIAdv_CAM_DOC_MJRPROG_GCAM_ProgPhse_Budgt extends IntegCGIAdv_DOC_MJRPROG_Wrapper{
        // PUBLIC CONSTRUCTORS
        public IntegCGIAdv_CAM_DOC_MJRPROG_GCAM_ProgPhse_Budgt(){ super(); }
        public IntegCGIAdv_CAM_DOC_MJRPROG_GCAM_ProgPhse_Budgt( Integer DOC_MJRPROG_LN_NO, String DEPT_CD,
                                                                String MJR_PROG_CD, String MJR_PROG_NM, String MJR_PROG_SH_NM,
                                                                Boolean ACT_FL, Date EFBGN_DT, Date EFEND_DT,
                                                                Boolean ALW_BUD_FL, String SUSP_STA, String REIM_BAS_IND,
                                                                String REIM_BUD_STRU_CD, String SPLT_IND, String FED_APPR_SETP,
                                                                String MJR_PROG_DSRC ){
            this( CAMDOCMJRPROGNAME, DOC_MJRPROG_LN_NO, DEPT_CD, MJR_PROG_CD, MJR_PROG_NM, MJR_PROG_SH_NM, ACT_FL,
                  EFBGN_DT, EFEND_DT, ALW_BUD_FL, SUSP_STA, REIM_BAS_IND, REIM_BUD_STRU_CD, SPLT_IND,
                  FED_APPR_SETP, MJR_PROG_DSRC );
        }
        public IntegCGIAdv_CAM_DOC_MJRPROG_GCAM_ProgPhse_Budgt( String NAME, Integer DOC_MJRPROG_LN_NO, String DEPT_CD,
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
    public class IntegCGIAdv_CAM_DOC_PROG_GCAM_ProgPhse_Budgt extends IntegCGIAdv_DOC_PROG_Wrapper{
        // PUBLIC CONSTRUCTORS
        public IntegCGIAdv_CAM_DOC_PROG_GCAM_ProgPhse_Budgt(){ super(); }
        public IntegCGIAdv_CAM_DOC_PROG_GCAM_ProgPhse_Budgt( Integer DOC_MJRPROG_LN_NO, Integer DOC_PROG_LN_NO,
                                                             String LN_TYP, String PROG_CD, String PROG_NM, String PROG_SH_NM,
                                                             Boolean ACT_FL, Boolean ALW_BUD_FL, String SUSP_STA,
                                                             Boolean REIM_ELG_STA, Date BILL_AGREE_DT, String PROG_DSRC,
                                                             String SACCT_CD, Date EFBGN_DT, Date EFEND_DT, String PGRP_CD,
                                                             String PTYP_CD, String PCLS_CD, String PCAT_CD, Date PROJ_END_DT ){
            this( CAMDOCPROGNAME, DOC_MJRPROG_LN_NO, DOC_PROG_LN_NO, LN_TYP, PROG_CD, PROG_NM, PROG_SH_NM,
                  ACT_FL, ALW_BUD_FL, SUSP_STA, REIM_ELG_STA, BILL_AGREE_DT, PROG_DSRC, SACCT_CD, EFBGN_DT,
                  EFEND_DT, PGRP_CD, PTYP_CD, PCLS_CD, PCAT_CD, PROJ_END_DT );
        }
        public IntegCGIAdv_CAM_DOC_PROG_GCAM_ProgPhse_Budgt( String NAME, Integer DOC_MJRPROG_LN_NO, Integer DOC_PROG_LN_NO,
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
    public class IntegCGIAdv_CAM_DOC_PHSEPROG_GCAM_ProgPhse_Budgt extends IntegCGIAdv_DOC_PHSEPROG_Wrapper{
        // PUBLIC CONSTRUCTORS
        public IntegCGIAdv_CAM_DOC_PHSEPROG_GCAM_ProgPhse_Budgt(){ super(); }
        public IntegCGIAdv_CAM_DOC_PHSEPROG_GCAM_ProgPhse_Budgt( Integer DOC_MJRPROG_LN_NO,
                                                                 Integer DOC_PROG_LN_NO, Integer DOC_PHSEPROG_LN_NO,
                                                                 String LN_TYP, String PHASE_CD, String PROG_CD,
                                                                 String SACCT_CD, String SITE_LOC_CD,
                                                                 Date EFBGN_DT, Date EFEND_DT, Date BILL_AGREE_DT, 
                                                                 Boolean ACT_FL, Boolean ALW_BUD_FL, Boolean REIM_ELG_STA,
                                                                 String SUSP_STA, String PHASE_DSRC ){
            this( CAMDOCPHSEPROGNAME, DOC_MJRPROG_LN_NO, DOC_PROG_LN_NO, DOC_PHSEPROG_LN_NO, LN_TYP, PHASE_CD, PROG_CD, SACCT_CD, SITE_LOC_CD,
                  EFBGN_DT, EFEND_DT, BILL_AGREE_DT, ACT_FL, ALW_BUD_FL, REIM_ELG_STA, SUSP_STA, PHASE_DSRC );
        }
        public IntegCGIAdv_CAM_DOC_PHSEPROG_GCAM_ProgPhse_Budgt( String NAME, Integer DOC_MJRPROG_LN_NO,
                                                                 Integer DOC_PROG_LN_NO, Integer DOC_PHSEPROG_LN_NO,
                                                                 String LN_TYP, String PHASE_CD, String PROG_CD,
                                                                 String SACCT_CD, String SITE_LOC_CD,
                                                                 Date EFBGN_DT, Date EFEND_DT, Date BILL_AGREE_DT, 
                                                                 Boolean ACT_FL, Boolean ALW_BUD_FL, Boolean REIM_ELG_STA,
                                                                 String SUSP_STA, String PHASE_DSRC ){
            super( Integ_CGIAdv_Utilities.valueIfBlank( NAME, CAMDOCPHSEPROGNAME ), DOC_MJRPROG_LN_NO, DOC_PROG_LN_NO,
                   DOC_PHSEPROG_LN_NO, LN_TYP, PHASE_CD, PROG_CD, SACCT_CD, SITE_LOC_CD, EFBGN_DT, EFEND_DT,
                   BILL_AGREE_DT, ACT_FL, ALW_BUD_FL, REIM_ELG_STA, SUSP_STA, PHASE_DSRC );
        }
    }
    public class IntegCGIAdv_CAM_DOC_FPI_GCAM_ProgPhse_Budgt extends IntegCGIAdv_DOC_FPI_Wrapper{
        public IntegCGIAdv_CAM_DOC_FPI_GCAM_ProgPhse_Budgt(){ super(); }
        public IntegCGIAdv_CAM_DOC_FPI_GCAM_ProgPhse_Budgt( Integer DOC_FPI_LN_NO, String LN_TYP,
                                                            String FUND_PRFL_INF, String PROG_CD,
                                                            String FPRFL_CD, String REIM_ELG_STA_MTCH,
                                                            String PHASE_CD ){
            this( CAMDOCFPINAME, DOC_FPI_LN_NO, LN_TYP, FUND_PRFL_INF, PROG_CD, FPRFL_CD, REIM_ELG_STA_MTCH, PHASE_CD ); 
        }
        public IntegCGIAdv_CAM_DOC_FPI_GCAM_ProgPhse_Budgt( String NAME, Integer DOC_FPI_LN_NO, String LN_TYP,
                                                            String FUND_PRFL_INF, String PROG_CD,
                                                            String FPRFL_CD, String REIM_ELG_STA_MTCH,
                                                            String PHASE_CD ){
            super( Integ_CGIAdv_Utilities.valueIfBlank( NAME, CAMDOCFPINAME ), DOC_FPI_LN_NO, LN_TYP, FUND_PRFL_INF, PROG_CD, FPRFL_CD,
                   REIM_ELG_STA_MTCH, PHASE_CD ); 
        }
    }
    public class IntegCGIAdv_CAM_DOC_BUDLN_GCAM_ProgPhse_Budgt extends IntegCGIAdv_DOC_BUDLN_Wrapper{
        // PUBLIC CONSTRUCTORS
        public IntegCGIAdv_CAM_DOC_BUDLN_GCAM_ProgPhse_Budgt(){ super(); }
        public IntegCGIAdv_CAM_DOC_BUDLN_GCAM_ProgPhse_Budgt( Integer DOC_BUDLN_LN_NO,
                                                              Integer LN_ACTN, String BUD_DOC_CD, String STRU_ID, 
                                                              String EVNT_TYP_ID, String BUD_NM,
                                                              Date STRT_DT, Date END_DT,
                                                              Decimal LN_AM, String PROG_CD,
                                                              String PHASE_CD, String FPRFL_CD,
                                                              String FPRTY_CD, String FLINE_CD,
                                                              String INCR_DCRS_IND, String BUD_UPD_OPT ){
            this( CAMDOCBUDLNNAME, DOC_BUDLN_LN_NO, LN_ACTN, BUD_DOC_CD, STRU_ID, EVNT_TYP_ID, BUD_NM,
                  STRT_DT, END_DT, LN_AM, PROG_CD, PHASE_CD, FPRFL_CD, FPRTY_CD,
                  FLINE_CD, INCR_DCRS_IND, BUD_UPD_OPT );
        }
        public IntegCGIAdv_CAM_DOC_BUDLN_GCAM_ProgPhse_Budgt( String NAME, Integer DOC_BUDLN_LN_NO,
                                                              Integer LN_ACTN, String BUD_DOC_CD, String STRU_ID, 
                                                              String EVNT_TYP_ID, String BUD_NM,
                                                              Date STRT_DT, Date END_DT,
                                                              Decimal LN_AM, String PROG_CD,
                                                              String PHASE_CD, String FPRFL_CD,
                                                              String FPRTY_CD, String FLINE_CD,
                                                              String INCR_DCRS_IND, String BUD_UPD_OPT ){
            super( Integ_CGIAdv_Utilities.valueIfBlank( NAME, CAMDOCBUDLNNAME ),
                   DOC_BUDLN_LN_NO, LN_ACTN, BUD_DOC_CD, STRU_ID, EVNT_TYP_ID, BUD_NM, STRT_DT, END_DT,
                   LN_AM, PROG_CD, PHASE_CD, FPRFL_CD, FPRTY_CD, FLINE_CD,
                   INCR_DCRS_IND, BUD_UPD_OPT);
        }
    }
}