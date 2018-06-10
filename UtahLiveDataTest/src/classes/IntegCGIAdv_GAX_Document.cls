/**
* IntegCGIAdv_GAX_Document is used to produce the JSON for GAX files
*
* CHANGE HISTORY
* ==================================================================================================
* Date              Name                Description
* Mar 01 2018       Brian Mason         Created
* ==================================================================================================
*/
public class IntegCGIAdv_GAX_Document extends IntegCGIAdv_AMS_DOC_XML_EXPORT_Wrapper {
    // PRIVATE STATIC CONSTANTS
    private static final String DOCCAT = 'ABS';
    private static final String DOCTYP = 'ABS';
    private static final String DOCCD = 'GGAX';
    private static final String DOCVERSNO = '1';
    private static final Boolean AUTODOCNUM = TRUE;
    private static final String DOCIMPORTMODE = 'OE';
    private static final String AMSDOCROOTNAME = 'AMS_DOC_XML_EXPORT_FILE';
    private static final String AMSDOCROOTVERSION = '1.0';
    private static final String AMSDOCNAME = 'AMS_DOCUMENT';
    private static final String AMSHEADERNAME = 'ABS_DOC_HDR';
    private static final String AMSVENDORNAME = 'ABS_DOC_VEND';
    private static final String AMSACCTNGNAME = 'ABS_DOC_ACTG';
    // PUBLIC MEMBERS
    public IntegCGIAdv_AMS_Document_GAX[] DOCUMENTS {get;set;}
    // PUBLIC CONSTRUCTORS
    public IntegCGIAdv_GAX_Document( String DEPT_CD ){
        this( AMSDOCROOTVERSION, AMSDOCROOTNAME, DateTime.now(), Integ_CGIAdv_Utilities.DefaultTimeZone(), DEPT_CD );
    }
    public IntegCGIAdv_GAX_Document( String VERSION, String NAME, String DEPT_CD ){
        this( Integ_CGIAdv_Utilities.valueIfBlank( VERSION, AMSDOCROOTVERSION ), Integ_CGIAdv_Utilities.valueIfBlank( NAME, AMSDOCROOTNAME ),
              DateTime.now(), Integ_CGIAdv_Utilities.DefaultTimeZone(), DEPT_CD );
    }
    public IntegCGIAdv_GAX_Document( String VERSION, String NAME, DateTime EXPORT_DATE, String DEPT_CD ){
        this( Integ_CGIAdv_Utilities.valueIfBlank( VERSION, AMSDOCROOTVERSION ), Integ_CGIAdv_Utilities.valueIfBlank( NAME, AMSDOCROOTNAME ),
               EXPORT_DATE, Integ_CGIAdv_Utilities.DefaultTimeZone(), DEPT_CD );
    }
    public IntegCGIAdv_GAX_Document( String VERSION, String NAME, DateTime EXPORT_DATE, String TimeZone, String DEPT_CD ){
        super( Integ_CGIAdv_Utilities.valueIfBlank( VERSION, AMSDOCROOTVERSION ), Integ_CGIAdv_Utilities.valueIfBlank( NAME, AMSDOCROOTNAME ),
               EXPORT_DATE, Integ_CGIAdv_Utilities.valueIfBlank( TimeZone, Integ_CGIAdv_Utilities.DefaultTimeZone() ), DEPT_CD );
        if( DOCUMENTS == NULL ){ DOCUMENTS = new IntegCGIAdv_AMS_Document_GAX[]{}; }
    }
    public IntegCGIAdv_GAX_Document( String VERSION, String NAME, IntegCGIAdv_AMS_Document_GAX[] AMS_DOCUMENTS, String DEPT_CD ){
        this( VERSION, NAME, DateTime.now(), Integ_CGIAdv_Utilities.DefaultTimeZone(), DEPT_CD );
        if( AMS_DOCUMENTS != NULL ){ this.DOCUMENTS = AMS_DOCUMENTS; }
    }
    public IntegCGIAdv_GAX_Document( String VERSION, String NAME, DateTime EXPORT_DATE, 
                                     IntegCGIAdv_AMS_Document_GAX[] AMS_DOCUMENTS, String DEPT_CD ){
        this( VERSION, NAME, EXPORT_DATE, Integ_CGIAdv_Utilities.DefaultTimeZone(), DEPT_CD );
        if( AMS_DOCUMENTS != NULL ){ this.DOCUMENTS = AMS_DOCUMENTS; }
    }
    public IntegCGIAdv_GAX_Document( String VERSION, String NAME, DateTime EXPORT_DATE, String TimeZone, 
									 IntegCGIAdv_AMS_Document_GAX[] AMS_DOCUMENTS, String DEPT_CD ){
        this( VERSION, NAME, EXPORT_DATE, TimeZone, DEPT_CD );
        if( AMS_DOCUMENTS != NULL ){ this.DOCUMENTS = AMS_DOCUMENTS; }
    }
    // PUBLIC METHODS
    public IntegCGIAdv_AMS_Document_GAX createAMS_DOCUMENT( Boolean addToAMSDOCUMENTS,
                                                            String NAME, String DOC_CAT, String DOC_TYP, String DOC_CD, String DOC_DEPT_CD, 
                                                            String DOC_UNIT_CD, String DOC_ID, String DOC_VERS_NO, Boolean AUTO_DOC_NUM, 
                                                            String DOC_IMPORT_MODE, 
                                                            IntegCGIAdv_ABS_DOC_HDR_GAX ABS_DOC_HDR,
                                                            IntegCGIAdv_ABS_DOC_VEND_GAX ABS_DOC_VEND,
                                                            IntegCGIAdv_ABS_DOC_ACTG_GAX[] ABS_DOC_ACTG ){
        IntegCGIAdv_AMS_Document_GAX newDoc = 
            new IntegCGIAdv_AMS_Document_GAX( NAME, DOC_CAT, DOC_TYP, DOC_CD, DOC_DEPT_CD, DOC_UNIT_CD, 
                                              DOC_ID, DOC_VERS_NO, AUTO_DOC_NUM, DOC_IMPORT_MODE, 
                                              ABS_DOC_HDR, ABS_DOC_VEND, ABS_DOC_ACTG );
        if( addToAMSDOCUMENTS ){ this.DOCUMENTS.add( newDoc ); } 
        return newDoc;
    }
    public IntegCGIAdv_AMS_Document_GAX createAMS_DOCUMENTwithDefaults( Boolean addToAMSDOCUMENTS,
                                                                        String DOC_DEPT_CD, String DOC_UNIT_CD, String DOC_ID, 
                                                                        IntegCGIAdv_ABS_DOC_HDR_GAX ABS_DOC_HDR,
                                                                        IntegCGIAdv_ABS_DOC_VEND_GAX ABS_DOC_VEND,
                                                                        IntegCGIAdv_ABS_DOC_ACTG_GAX[] ABS_DOC_ACTG ){
        IntegCGIAdv_AMS_Document_GAX newDoc = 
            new IntegCGIAdv_AMS_Document_GAX( DOCCAT, DOCTYP, DOCCD, DOC_DEPT_CD, DOC_UNIT_CD, 
                                              DOC_ID, DOCVERSNO, AUTODOCNUM, DOCIMPORTMODE, 
                                              ABS_DOC_HDR, ABS_DOC_VEND, ABS_DOC_ACTG );
        if( addToAMSDOCUMENTS ){ this.DOCUMENTS.add( newDoc ); }
        return newDoc;
    }
    public IntegCGIAdv_AMS_Document_GAX initializeAMS_DOCUMENTwithDefaults( Boolean addToAMSDOCUMENTS, String DOC_DEPT_CD,
                                                                            String DOC_UNIT_CD, String DOC_ID ){
        IntegCGIAdv_ABS_DOC_HDR_GAX header = new IntegCGIAdv_ABS_DOC_HDR_GAX();
        header.NAME = AMSHEADERNAME;
        IntegCGIAdv_ABS_DOC_VEND_GAX vendor = new IntegCGIAdv_ABS_DOC_VEND_GAX();
        vendor.NAME = AMSVENDORNAME;
        IntegCGIAdv_ABS_DOC_ACTG_GAX[] accountingLines = new IntegCGIAdv_ABS_DOC_ACTG_GAX[]{};
        IntegCGIAdv_AMS_Document_GAX newDoc = 
            new IntegCGIAdv_AMS_Document_GAX( DOCCAT, DOCTYP, DOCCD, DOC_DEPT_CD, DOC_UNIT_CD, 
                                              DOC_ID, DOCVERSNO, AUTODOCNUM, DOCIMPORTMODE, 
                                              header, vendor, accountingLines );
        if( addToAMSDOCUMENTS ){ this.DOCUMENTS.add( newDoc ); }
        return newDoc;
    }
    // PUBLIC CLASSES
    public class IntegCGIAdv_AMS_Document_GAX extends IntegCGIAdv_AMS_Document_Wrapper{
        // PUBLIC MEMBERS
        IntegCGIAdv_ABS_DOC_HDR_GAX DOC_HDR {get;set;}
        IntegCGIAdv_ABS_DOC_VEND_GAX DOC_VEND {get;set;}
        IntegCGIAdv_ABS_DOC_ACTG_GAX[] DOC_ACTG {get;set;}
        
        // PUBLIC CONSTRUCTORS
        public IntegCGIAdv_AMS_Document_GAX(){
            super();
        }
        public IntegCGIAdv_AMS_Document_GAX( String DOC_CAT, String DOC_TYP, String DOC_CD, String DOC_DEPT_CD, String DOC_UNIT_CD, 
                                             String DOC_ID, String DOC_VERS_NO, Boolean AUTO_DOC_NUM, String DOC_IMPORT_MODE,
                                             IntegCGIAdv_ABS_DOC_HDR_GAX DOC_HDR,
                                             IntegCGIAdv_ABS_DOC_VEND_GAX DOC_VEND,
                                             IntegCGIAdv_ABS_DOC_ACTG_GAX[] DOC_ACTG ){
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
        public IntegCGIAdv_AMS_Document_GAX( String NAME,String DOC_CAT, String DOC_TYP, String DOC_CD, String DOC_DEPT_CD, String DOC_UNIT_CD, 
                                             String DOC_ID, String DOC_VERS_NO, Boolean AUTO_DOC_NUM, String DOC_IMPORT_MODE,
                                             IntegCGIAdv_ABS_DOC_HDR_GAX DOC_HDR,
                                             IntegCGIAdv_ABS_DOC_VEND_GAX DOC_VEND,
                                             IntegCGIAdv_ABS_DOC_ACTG_GAX[] DOC_ACTG ){
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
    public class IntegCGIAdv_ABS_DOC_HDR_GAX extends IntegCGIAdv_DOC_HDR_Wrapper{
        // PUBLIC MEMBERS
        public String DOC_REC_DT_DC { get; private set; }
        public String DOC_PER_DC { get; set; }
        public Integer DOC_FY_DC { get; set; }
        // PUBLIC CONSTRUCTORS
        public IntegCGIAdv_ABS_DOC_HDR_GAX(){
            super();
            setDOC_REC_DT_DC( null );
            this.DOC_PER_DC = '';
            this.DOC_FY_DC = null;
		}
        public IntegCGIAdv_ABS_DOC_HDR_GAX( Date DOC_REC_DT_DC, String DOC_PER_DC,
                                            Integer DOC_FY_DC, String DOC_DSCR ){
            this( AMSHEADERNAME, DOC_REC_DT_DC, DOC_PER_DC, DOC_FY_DC, DOC_DSCR );
        }
        public IntegCGIAdv_ABS_DOC_HDR_GAX( String NAME, Date DOC_REC_DT_DC, String DOC_PER_DC,
                                            Integer DOC_FY_DC, String DOC_DSCR ){
            super( Integ_CGIAdv_Utilities.valueIfBlank( NAME, AMSHEADERNAME ), DOC_DSCR );
        	if( DOC_REC_DT_DC != NULL ){ setDOC_REC_DT_DC( DOC_REC_DT_DC ); }
        	if( String.isNotBlank( DOC_PER_DC) ){ this.DOC_PER_DC = DOC_PER_DC; }
        	if( String.valueOf( DOC_FY_DC ).isNumeric() ){ this.DOC_FY_DC = DOC_FY_DC; }
        }
        // PUBLIC METHODS
        public void setDOC_REC_DT_DC( Date newDate ){ if( newDate != NULL ){ this.DOC_REC_DT_DC = Integ_CGIAdv_Utilities.formatDateToString( newDate ); }else{ this.DOC_REC_DT_DC = null; } }
    }
    public class IntegCGIAdv_ABS_DOC_VEND_GAX extends IntegCGIAdv_DOC_VEND_Wrapper{
        // PUBLIC MEMBERS
        public String SCHED_PYMT_DT { get; private set; }
        // PUBLIC CONSTRUCTORS
        public IntegCGIAdv_ABS_DOC_VEND_GAX(){
            super();
            setSCHED_PYMT_DT( null );
        }
        public IntegCGIAdv_ABS_DOC_VEND_GAX( Integer DOC_VEND_LN_NO, String VEND_CUST_CD,
                                             String AD_ID, Date SCHED_PYMT_DT){
            this( AMSVENDORNAME,
                  DOC_VEND_LN_NO,
                  VEND_CUST_CD,
                  AD_ID,
                  SCHED_PYMT_DT );
        }
        public IntegCGIAdv_ABS_DOC_VEND_GAX( String NAME, Integer DOC_VEND_LN_NO, String VEND_CUST_CD,
                                             String AD_ID, Date SCHED_PYMT_DT){
            super( Integ_CGIAdv_Utilities.valueIfBlank( NAME, AMSVENDORNAME ),
                   DOC_VEND_LN_NO,
                   VEND_CUST_CD,
                   AD_ID );
            if( SCHED_PYMT_DT != NULL ){ setSCHED_PYMT_DT( SCHED_PYMT_DT ); }
        }
        // PUBLIC METHODS
        public void setSCHED_PYMT_DT( Date newDate ){ if( newDate != null ){ this.SCHED_PYMT_DT = Integ_CGIAdv_Utilities.formatDateToString( newDate ); }else{ this.SCHED_PYMT_DT = null;} }        
    }
    public class IntegCGIAdv_ABS_DOC_ACTG_GAX extends IntegCGIAdv_DOC_ACTG_Wrapper{
        // PUBLIC MEMBERS
        public String VEND_INV_NO { get; set; }
        public Integer VEND_INV_LN_NO { get; set; }
        public String VEND_INV_DT { get; private set; }
		public Integer DOC_VEND_LN_NO { get; set; }
        // PUBLIC CONSTRUCTORS
        public IntegCGIAdv_ABS_DOC_ACTG_GAX(){
            super();
            this.VEND_INV_NO = '';
            this.VEND_INV_LN_NO = -9999;
            setVEND_INV_DT( null );
            this.DOC_VEND_LN_NO = -9999;
        }
        public IntegCGIAdv_ABS_DOC_ACTG_GAX( Integer DOC_VEND_LN_NO, Integer DOC_ACTG_LN_NO, 
                                             String ACTG_LN_DSCR, Decimal LN_AM, String VEND_INV_NO,
                                             Integer VEND_INV_LN_NO, Date VEND_INV_DT,
                                             String FUND_CD, String DEPT_CD, String UNIT_CD, 
                                             String APPR_CD, String OBJ_CD, String PROG_CD, String PHASE_CD ){
            this( AMSACCTNGNAME, DOC_VEND_LN_NO, DOC_ACTG_LN_NO, ACTG_LN_DSCR, LN_AM, VEND_INV_NO, VEND_INV_LN_NO,
                  VEND_INV_DT, FUND_CD, DEPT_CD, UNIT_CD, APPR_CD, OBJ_CD, PROG_CD, PHASE_CD );
        }
        public IntegCGIAdv_ABS_DOC_ACTG_GAX( String NAME, Integer DOC_VEND_LN_NO, Integer DOC_ACTG_LN_NO, 
                                             String ACTG_LN_DSCR, Decimal LN_AM, String VEND_INV_NO,
                                             Integer VEND_INV_LN_NO, Date VEND_INV_DT,
                                             String FUND_CD, String DEPT_CD, String UNIT_CD, 
                                             String APPR_CD, String OBJ_CD, String PROG_CD, String PHASE_CD ){
            super( Integ_CGIAdv_Utilities.valueIfBlank( NAME, AMSACCTNGNAME ),
                   DOC_ACTG_LN_NO, ACTG_LN_DSCR, LN_AM,
                   FUND_CD, DEPT_CD, UNIT_CD, APPR_CD, OBJ_CD, PROG_CD, PHASE_CD );
            if( String.isNotBlank( VEND_INV_NO ) ){ this.VEND_INV_NO = VEND_INV_NO; }
            if( String.valueOf( VEND_INV_LN_NO ).isNumeric() ){ this.VEND_INV_LN_NO = VEND_INV_LN_NO; }
            if( VEND_INV_DT != NULL ){ setVEND_INV_DT( VEND_INV_DT ); }
        	if( String.valueOf( DOC_VEND_LN_NO ).isNumeric() ){ this.DOC_VEND_LN_NO = DOC_VEND_LN_NO; }
        }
        // PUBLIC METHODS
        public void setVEND_INV_DT( Date newDate ){ if( newDate != NULL){ this.VEND_INV_DT = Integ_CGIAdv_Utilities.formatDateToString( newDate ); }else{ this.VEND_INV_DT = null; } }
    }
}