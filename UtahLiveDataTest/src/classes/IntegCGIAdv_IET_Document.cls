/**
* IntegCGIAdv_IET_Document is used to produce the JSON for IET files
*
* CHANGE HISTORY
* ==================================================================================================
* Date              Name                Description
* Mar 01 2018       Brian Mason         Created
* ==================================================================================================
*/
public class IntegCGIAdv_IET_Document extends IntegCGIAdv_AMS_DOC_XML_EXPORT_Wrapper {
    // PRIVATE STATIC CONSTANTS
    private static final String DOCCAT = 'INT';
    private static final String DOCTYP = 'IET';
    private static final String DOCCD = 'GIET';
    private static final String DOCVERSNO = '1';
    private static final Boolean AUTODOCNUM = TRUE;
    private static final String DOCIMPORTMODE = 'OE';
    private static final String AMSDOCROOTNAME = 'AMS_DOC_XML_EXPORT_FILE';
    private static final String AMSDOCROOTVERSION = '1.0';
    private static final String AMSDOCNAME = 'AMS_DOCUMENT';
    private static final String IETHEADERNAME = 'IET_DOC_HDR';
    private static final String IETVENDORNAME = 'IET_DOC_VEND';
    private static final String IETACCTNGNAME = 'IET_DOC_ACTG';
    // PUBLIC MEMBERS
    public IntegCGIAdv_AMS_Document_IET[] DOCUMENTS {get;set;}
    // PUBLIC CONSTRUCTORS
    public IntegCGIAdv_IET_Document( String DEPT_CD ){
        this( AMSDOCROOTVERSION, AMSDOCROOTNAME, DateTime.now(), Integ_CGIAdv_Utilities.DefaultTimeZone(), DEPT_CD );
    }
    public IntegCGIAdv_IET_Document( String VERSION, String NAME, String DEPT_CD ){
        this( Integ_CGIAdv_Utilities.valueIfBlank( VERSION, AMSDOCROOTVERSION ), Integ_CGIAdv_Utilities.valueIfBlank( NAME, AMSDOCROOTNAME ),
              DateTime.now(), Integ_CGIAdv_Utilities.DefaultTimeZone(), DEPT_CD );
    }
    public IntegCGIAdv_IET_Document( String VERSION, String NAME, DateTime EXPORT_DATE, String DEPT_CD ){
        this( Integ_CGIAdv_Utilities.valueIfBlank( VERSION, AMSDOCROOTVERSION ), Integ_CGIAdv_Utilities.valueIfBlank( NAME, AMSDOCROOTNAME ),
               EXPORT_DATE, Integ_CGIAdv_Utilities.DefaultTimeZone(), DEPT_CD );
    }
    public IntegCGIAdv_IET_Document( String VERSION, String NAME, DateTime EXPORT_DATE, String TimeZone, String DEPT_CD ){
        super( Integ_CGIAdv_Utilities.valueIfBlank( VERSION, AMSDOCROOTVERSION ), Integ_CGIAdv_Utilities.valueIfBlank( NAME, AMSDOCROOTNAME ),
               EXPORT_DATE, Integ_CGIAdv_Utilities.valueIfBlank( TimeZone, Integ_CGIAdv_Utilities.DefaultTimeZone() ), DEPT_CD );
        if( DOCUMENTS == NULL ){ DOCUMENTS = new IntegCGIAdv_AMS_Document_IET[]{}; }
    }
    public IntegCGIAdv_IET_Document( String VERSION, String NAME, IntegCGIAdv_AMS_Document_IET[] AMS_DOCUMENTS, String DEPT_CD ){
        this( VERSION, NAME, DateTime.now(), Integ_CGIAdv_Utilities.DefaultTimeZone(), DEPT_CD );
        if( AMS_DOCUMENTS != NULL ){ this.DOCUMENTS = AMS_DOCUMENTS; }
    }
    public IntegCGIAdv_IET_Document( String VERSION, String NAME, DateTime EXPORT_DATE, 
                                              IntegCGIAdv_AMS_Document_IET[] AMS_DOCUMENTS, String DEPT_CD ){
        this( VERSION, NAME, EXPORT_DATE, Integ_CGIAdv_Utilities.DefaultTimeZone(), DEPT_CD );
        if( AMS_DOCUMENTS != NULL ){ this.DOCUMENTS = AMS_DOCUMENTS; }
    }
    public IntegCGIAdv_IET_Document( String VERSION, String NAME, DateTime EXPORT_DATE, String TimeZone, 
                                              IntegCGIAdv_AMS_Document_IET[] AMS_DOCUMENTS, String DEPT_CD ){
        this( VERSION, NAME, EXPORT_DATE, TimeZone, DEPT_CD );
        if( AMS_DOCUMENTS != NULL ){ this.DOCUMENTS = AMS_DOCUMENTS; }
    }
    // PUBLIC METHODS
    public IntegCGIAdv_AMS_Document_IET createAMS_DOCUMENT( Boolean addToAMSDOCUMENTS,
                                                            String NAME, String DOC_CAT, String DOC_TYP, String DOC_CD, String DOC_DEPT_CD, 
                                                            String DOC_UNIT_CD, String DOC_ID, String DOC_VERS_NO, Boolean AUTO_DOC_NUM, 
                                                            String DOC_IMPORT_MODE, 
                                                            IntegCGIAdv_IET_DOC_HDR_IET IET_DOC_HDR,
                                                            IntegCGIAdv_IET_DOC_VEND_IET IET_DOC_VEND,
                                                            IntegCGIAdv_IET_DOC_ACTG_IET[] IET_DOC_ACTG ){
        IntegCGIAdv_AMS_Document_IET newDoc = 
            new IntegCGIAdv_AMS_Document_IET( NAME, DOC_CAT, DOC_TYP, DOC_CD, DOC_DEPT_CD, DOC_UNIT_CD, 
                                              DOC_ID, DOC_VERS_NO, AUTO_DOC_NUM, DOC_IMPORT_MODE, 
                                              IET_DOC_HDR, IET_DOC_VEND, IET_DOC_ACTG );
        if( addToAMSDOCUMENTS ){ this.DOCUMENTS.add( newDoc ); } 
        return newDoc;
    }
    public IntegCGIAdv_AMS_Document_IET createAMS_DOCUMENTwithDefaults( Boolean addToAMSDOCUMENTS,
                                                                        String DOC_DEPT_CD, String DOC_UNIT_CD, String DOC_ID, 
                                                                        IntegCGIAdv_IET_DOC_HDR_IET IET_DOC_HDR,
                                                                        IntegCGIAdv_IET_DOC_VEND_IET IET_DOC_VEND,
                                                                        IntegCGIAdv_IET_DOC_ACTG_IET[] IET_DOC_ACTG ){
        IntegCGIAdv_AMS_Document_IET newDoc = 
            new IntegCGIAdv_AMS_Document_IET( DOCCAT, DOCTYP, DOCCD, DOC_DEPT_CD, DOC_UNIT_CD, 
                                              DOC_ID, DOCVERSNO, AUTODOCNUM, DOCIMPORTMODE, 
                                              IET_DOC_HDR, IET_DOC_VEND, IET_DOC_ACTG );
        if( addToAMSDOCUMENTS ){ this.DOCUMENTS.add( newDoc ); }
        return newDoc;
    }
    public IntegCGIAdv_AMS_Document_IET initializeAMS_DOCUMENTwithDefaults( Boolean addToAMSDOCUMENTS, String DOC_DEPT_CD,
                                                                            String DOC_UNIT_CD, String DOC_ID ){
        IntegCGIAdv_IET_DOC_HDR_IET header = new IntegCGIAdv_IET_DOC_HDR_IET();
        header.NAME = IETHEADERNAME;
        IntegCGIAdv_IET_DOC_VEND_IET vendor = new IntegCGIAdv_IET_DOC_VEND_IET();
        vendor.NAME = IETVENDORNAME;
        IntegCGIAdv_IET_DOC_ACTG_IET[] accountingLines = new IntegCGIAdv_IET_DOC_ACTG_IET[]{};
        IntegCGIAdv_AMS_Document_IET newDoc = 
            new IntegCGIAdv_AMS_Document_IET( DOCCAT, DOCTYP, DOCCD, DOC_DEPT_CD, DOC_UNIT_CD, 
                                              DOC_ID, DOCVERSNO, AUTODOCNUM, DOCIMPORTMODE, 
                                              header, vendor, accountingLines );
        if( addToAMSDOCUMENTS ){ this.DOCUMENTS.add( newDoc ); }
        return newDoc;
    }
    // PUBLIC CLASSES
    public class IntegCGIAdv_AMS_Document_IET extends IntegCGIAdv_AMS_Document_Wrapper{
        // PUBLIC MEMBERS
        IntegCGIAdv_IET_DOC_HDR_IET DOC_HDR {get;set;}
        IntegCGIAdv_IET_DOC_VEND_IET DOC_VEND {get;set;}
        IntegCGIAdv_IET_DOC_ACTG_IET[] DOC_ACTG {get;set;}
        // PUBLIC CONSTRUCTORS
        public IntegCGIAdv_AMS_Document_IET(){
            super();
            DOC_HDR = null;
            DOC_VEND = null;
            DOC_ACTG = null;
        }
        public IntegCGIAdv_AMS_Document_IET( String DOC_CAT, String DOC_TYP, String DOC_CD, String DOC_DEPT_CD, String DOC_UNIT_CD, 
                                             String DOC_ID, String DOC_VERS_NO, Boolean AUTO_DOC_NUM, String DOC_IMPORT_MODE,
                                             IntegCGIAdv_IET_DOC_HDR_IET DOC_HDR,
                                             IntegCGIAdv_IET_DOC_VEND_IET DOC_VEND,
                                             IntegCGIAdv_IET_DOC_ACTG_IET[] DOC_ACTG ){
            this( AMSDOCNAME,
                  Integ_CGIAdv_Utilities.valueIfBlank( DOC_CAT, DOCCAT ),
                  Integ_CGIAdv_Utilities.valueIfBlank( DOC_TYP, DOCTYP ),
                  Integ_CGIAdv_Utilities.valueIfBlank( DOC_CD, DOCCD ),
                  DOC_DEPT_CD, DOC_UNIT_CD, DOC_ID, 
                  Integ_CGIAdv_Utilities.valueIfBlank( DOC_VERS_NO, DOCVERSNO ),
                  AUTO_DOC_NUM != NULL ? AUTO_DOC_NUM : AUTODOCNUM,
                  Integ_CGIAdv_Utilities.valueIfBlank( DOC_IMPORT_MODE, DOCIMPORTMODE ),
                  DOC_HDR, DOC_VEND, DOC_ACTG );
        }
        public IntegCGIAdv_AMS_Document_IET( String NAME,String DOC_CAT, String DOC_TYP, String DOC_CD, String DOC_DEPT_CD, String DOC_UNIT_CD, 
                                             String DOC_ID, String DOC_VERS_NO, Boolean AUTO_DOC_NUM, String DOC_IMPORT_MODE,
                                             IntegCGIAdv_IET_DOC_HDR_IET DOC_HDR,
                                             IntegCGIAdv_IET_DOC_VEND_IET DOC_VEND,
                                             IntegCGIAdv_IET_DOC_ACTG_IET[] DOC_ACTG ){
            super( Integ_CGIAdv_Utilities.valueIfBlank( NAME, AMSDOCNAME ),
                   Integ_CGIAdv_Utilities.valueIfBlank( DOC_CAT, DOCCAT ),
                   Integ_CGIAdv_Utilities.valueIfBlank( DOC_TYP, DOCTYP ),
                   Integ_CGIAdv_Utilities.valueIfBlank( DOC_CD, DOCCD ),
                   DOC_DEPT_CD, DOC_UNIT_CD, DOC_ID, 
                   Integ_CGIAdv_Utilities.valueIfBlank( DOC_VERS_NO, DOCVERSNO ),
                   AUTO_DOC_NUM != NULL ? AUTO_DOC_NUM : AUTODOCNUM,
                   Integ_CGIAdv_Utilities.valueIfBlank( DOC_IMPORT_MODE, DOCIMPORTMODE ) );
            if( DOC_HDR != NULL ){ this.DOC_HDR = DOC_HDR; }
            if( DOC_VEND != NULL ){ this.DOC_VEND = DOC_VEND; }
            if( DOC_ACTG != NULL ){ this.DOC_ACTG = DOC_ACTG; }
        }
    }
    public class IntegCGIAdv_IET_DOC_HDR_IET extends IntegCGIAdv_DOC_HDR_Wrapper{
        // PUBLIC MEMBERS
        public String AD_ID {get;set;}
        public String INIT_CD {get;set;}
        public String DOC_REC_DT_DC { get; private set; }
        public String DOC_PER_DC { get; set; }
        public Integer DOC_FY_DC { get; set; }
        public String VEND_CUST_CD { get;set; }
        // PUBLIC CONSTRUCTORS
        public IntegCGIAdv_IET_DOC_HDR_IET(){
            super();
            this.AD_ID = '';
            this.INIT_CD = '';
            setDOC_REC_DT_DC( null );
            this.DOC_PER_DC = '';
            this.DOC_FY_DC = null;
            this.VEND_CUST_CD = null;
        }
        public IntegCGIAdv_IET_DOC_HDR_IET( Date DOC_REC_DT_DC, String DOC_PER_DC,
                                            Integer DOC_FY_DC, String DOC_DSCR,
                                            String AD_ID, String INIT_CD, String VEND_CUST_CD ){
            this( IETHEADERNAME, DOC_REC_DT_DC, DOC_PER_DC, DOC_FY_DC, DOC_DSCR, AD_ID, INIT_CD, VEND_CUST_CD );
        }
        public IntegCGIAdv_IET_DOC_HDR_IET( String NAME, Date DOC_REC_DT_DC, String DOC_PER_DC,
                                            Integer DOC_FY_DC, String DOC_DSCR,
                                            String AD_ID, String INIT_CD, String VEND_CUST_CD ){
            super( Integ_CGIAdv_Utilities.valueIfBlank( NAME, IETHEADERNAME ), DOC_DSCR );
            if( DOC_REC_DT_DC != NULL ){ setDOC_REC_DT_DC( DOC_REC_DT_DC ); }
            if( String.isNotBlank( DOC_PER_DC) ){ this.DOC_PER_DC = DOC_PER_DC; }
            if( String.valueOf( DOC_FY_DC ).isNumeric() ){ this.DOC_FY_DC = DOC_FY_DC; }
            if( String.isNotBlank( AD_ID ) ){ this.AD_ID = AD_ID; }
            if( String.isNotBlank( INIT_CD ) ){ this.INIT_CD = INIT_CD; }
            if( String.isNotBlank( VEND_CUST_CD ) ){ this.VEND_CUST_CD = VEND_CUST_CD; }
        }
        // PUBLIC METHODS
        public void setDOC_REC_DT_DC( Date newDate ){ if( newDate != NULL ){ this.DOC_REC_DT_DC = Integ_CGIAdv_Utilities.formatDateToString( newDate ); }else{ this.DOC_REC_DT_DC = null; } }
    }
    public class IntegCGIAdv_IET_DOC_VEND_IET extends IntegCGIAdv_DOC_VEND_Wrapper{
        // PUBLIC MEMBERS
        public String EVNT_TYP_ID {get;set;}
        public String FUND_CD {get;set;}
        public String DEPT_CD {get;set;}
        public String UNIT_CD {get;set;}
        public String APPR_CD {get;set;}
        public String OBJ_CD {get;set;}
        public String ACTV_CD {get;set;}
        public String FUNC_CD {get;set;}
        public String RSRC_CD {get;set;}
        public String PROG_CD {get;set;}
        public String PHASE_CD {get;set;}
        public String PPC_CD {get;set;}
        public Decimal VL_ACTU_AM {get;set;}
        // PUBLIC CONSTRUCTORS
        public IntegCGIAdv_IET_DOC_VEND_IET(){
            super();
            this.EVNT_TYP_ID = '';
            this.FUND_CD = '';
            this.DEPT_CD = '';
            this.UNIT_CD = '';
            this.APPR_CD = '';
            this.RSRC_CD = '';
            this.OBJ_CD = '';
            this.ACTV_CD = '';
            this.FUNC_CD = '';
            this.PROG_CD = '';
            this.PHASE_CD = '';
            this.PPC_CD = '';
            this.VL_ACTU_AM = -9999;
        }
        public IntegCGIAdv_IET_DOC_VEND_IET( Integer DOC_VEND_LN_NO, String VEND_CUST_CD,
                                             String AD_ID, String EVNT_TYP_ID, String FUND_CD,
                                             String DEPT_CD, String UNIT_CD, String APPR_CD,
                                             String OBJ_CD, String ACTV_CD, String FUNC_CD,
                                             String RSRC_CD, String PROG_CD, String PHASE_CD,
                                             String PPC_CD, Decimal VL_ACTU_AM ){
            this( IETVENDORNAME, DOC_VEND_LN_NO, VEND_CUST_CD, AD_ID, EVNT_TYP_ID, FUND_CD,
                  DEPT_CD, UNIT_CD, APPR_CD, OBJ_CD, ACTV_CD, FUNC_CD, RSRC_CD, PROG_CD,
                  PHASE_CD, PPC_CD, VL_ACTU_AM );
        }
        public IntegCGIAdv_IET_DOC_VEND_IET( String NAME, Integer DOC_VEND_LN_NO, String VEND_CUST_CD,
                                             String AD_ID, String EVNT_TYP_ID, String FUND_CD,
                                             String DEPT_CD, String UNIT_CD, String APPR_CD,
                                             String OBJ_CD, String ACTV_CD, String FUNC_CD,
                                             String RSRC_CD, String PROG_CD, String PHASE_CD,
                                             String PPC_CD, Decimal VL_ACTU_AM ){
            super( Integ_CGIAdv_Utilities.valueIfBlank( NAME, IETVENDORNAME ),
                   DOC_VEND_LN_NO,
                   VEND_CUST_CD,
                   AD_ID );
            if( String.isNotBlank( EVNT_TYP_ID ) ){ this.EVNT_TYP_ID = EVNT_TYP_ID; }
            if( String.isNotBlank( FUND_CD ) ){ this.FUND_CD = FUND_CD; }
            if( String.isNotBlank( DEPT_CD ) ){ this.DEPT_CD = DEPT_CD; }
            if( String.isNotBlank( UNIT_CD ) ){ this.UNIT_CD = UNIT_CD; }
            if( String.isNotBlank( APPR_CD ) ){ this.APPR_CD = APPR_CD; }
            if( String.isNotBlank( RSRC_CD ) ){ this.RSRC_CD = RSRC_CD; }
            if( String.isNotBlank( OBJ_CD ) ){ this.OBJ_CD = OBJ_CD; }
            if( String.isNotBlank( ACTV_CD ) ){ this.ACTV_CD = ACTV_CD; }
            if( String.isNotBlank( FUNC_CD ) ){ this.FUNC_CD = FUNC_CD; }
            if( String.isNotBlank( RSRC_CD ) ){ this.RSRC_CD = RSRC_CD; }
            if( String.isNotBlank( PROG_CD ) ){ this.PROG_CD = PROG_CD; }
            if( String.isNotBlank( PHASE_CD ) ){ this.PHASE_CD = PHASE_CD; }
            if( String.isNotBlank( PPC_CD ) ){ this.PPC_CD = PPC_CD; }
            if( VL_ACTU_AM != NULL ){ this.VL_ACTU_AM = VL_ACTU_AM; }
        }   
    }
    public class IntegCGIAdv_IET_DOC_ACTG_IET extends IntegCGIAdv_DOC_ACTG_Wrapper{
        // PUBLIC MEMBERS
        public String RSRC_CD {get;set;}
        public String ACTV_CD {get;set;}
        public String FUNC_CD {get;set;}
        public String PPC_CD {get;set;}
        public Integer DOC_VEND_LN_NO { get; set; }
        // PUBLIC CONSTRUCTORS
        public IntegCGIAdv_IET_DOC_ACTG_IET(){
            super();
            this.RSRC_CD = '';
            this.ACTV_CD = '';
            this.FUNC_CD = '';
            this.PPC_CD = '';
            this.DOC_VEND_LN_NO = -9999;
        }
        public IntegCGIAdv_IET_DOC_ACTG_IET( Integer DOC_VEND_LN_NO, Integer DOC_ACTG_LN_NO, 
                                             String ACTG_LN_DSCR, Decimal LN_AM, String FUND_CD,
                                             String DEPT_CD, String UNIT_CD, String APPR_CD,
                                             String RSRC_CD, String OBJ_CD, String ACTV_CD,
                                             String FUNC_CD, String PROG_CD, String PHASE_CD,
                                             String PPC_CD ){
            this( IETACCTNGNAME, DOC_VEND_LN_NO, DOC_ACTG_LN_NO, ACTG_LN_DSCR, LN_AM, FUND_CD,
                  DEPT_CD, UNIT_CD, APPR_CD, RSRC_CD, OBJ_CD, ACTV_CD, FUNC_CD, PROG_CD,
                  PHASE_CD, PPC_CD );
        }
        public IntegCGIAdv_IET_DOC_ACTG_IET( String NAME, Integer DOC_VEND_LN_NO, Integer DOC_ACTG_LN_NO, 
                                             String ACTG_LN_DSCR, Decimal LN_AM, String FUND_CD,
                                             String DEPT_CD, String UNIT_CD, String APPR_CD,
                                             String RSRC_CD, String OBJ_CD, String ACTV_CD,
                                             String FUNC_CD, String PROG_CD, String PHASE_CD, String PPC_CD ){
            super( Integ_CGIAdv_Utilities.valueIfBlank( NAME, IETACCTNGNAME ),
                   DOC_ACTG_LN_NO, ACTG_LN_DSCR, LN_AM,
                   FUND_CD, DEPT_CD, UNIT_CD, APPR_CD, OBJ_CD, PROG_CD, PHASE_CD );
            if( String.isNotBlank( RSRC_CD ) ){ this.RSRC_CD = RSRC_CD; }
            if( String.isNotBlank( ACTV_CD ) ){ this.ACTV_CD = ACTV_CD; }
            if( String.isNotBlank( FUNC_CD ) ){ this.FUNC_CD = FUNC_CD; }
            if( String.isNotBlank( PPC_CD ) ){ this.PPC_CD = PPC_CD; }
            if( String.valueOf( DOC_VEND_LN_NO ).isNumeric() ){ this.DOC_VEND_LN_NO = DOC_VEND_LN_NO; }
        }
    }
}