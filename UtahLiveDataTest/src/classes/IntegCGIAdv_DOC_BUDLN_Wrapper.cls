/**
* IntegCGIAdv_DOC_BUDLN_Wrapper is an abstract class used in the IntegCGIAdv classes
*
* CHANGE HISTORY
* ==================================================================================================
* Date              Name                Description
* Mar 01 2018       Brian Mason         Created
* ==================================================================================================
*/
public abstract class IntegCGIAdv_DOC_BUDLN_Wrapper {
	// PUBLIC MEMBERS
    public String NAME { get; set; }
    public Integer DOC_BUDLN_LN_NO {get;set;}
    public Integer LN_ACTN {get;set;}
    public String BUD_DOC_CD {get;set;}
    public String STRU_ID {get;set;}
    public String EVNT_TYP_ID {get;set;}
    public String BUD_NM {get;set;}
    public String STRT_DT {get;private set;}
    public String END_DT {get;private set;}
    public Decimal LN_AM {get;set;}
    public String PROG_CD {get;set;}
    public String PHASE_CD {get;set;}
    public String FPRFL_CD {get;set;}
    public String FPRTY_CD {get;set;}
    public String FLINE_CD {get;set;}
    public String INCR_DCRS_IND {get;set;}
    public String BUD_UPD_OPT {get;set;}
    // PUBLIC CONSTRUCTORS
    public IntegCGIAdv_DOC_BUDLN_Wrapper(){
        this.NAME = 'Default Name';
        DOC_BUDLN_LN_NO = -9999;
        LN_ACTN = -9999;
        BUD_DOC_CD = '';
        STRU_ID = '';
        EVNT_TYP_ID = '';
        BUD_NM = '';
        setSTRT_DT( null );
        setEND_DT( null );
        LN_AM = -9999;
        PROG_CD = '';
        PHASE_CD = '';
        FPRFL_CD = '';
        FPRTY_CD = '';
        FLINE_CD = '';
        INCR_DCRS_IND = '';
        BUD_UPD_OPT = '';
    }
    public IntegCGIAdv_DOC_BUDLN_Wrapper( String NAME, Integer DOC_BUDLN_LN_NO,
                                          Integer LN_ACTN, String BUD_DOC_CD, String STRU_ID, 
                                          String EVNT_TYP_ID, String BUD_NM,
                                          Date STRT_DT, Date END_DT,
                                          Decimal LN_AM, String PROG_CD,
                                          String PHASE_CD, String FPRFL_CD,
                                          String FPRTY_CD, String FLINE_CD,
                                          String INCR_DCRS_IND, String BUD_UPD_OPT ){
		this();
		if( String.isNotBlank( NAME ) ){ this.NAME = NAME; }
		if( String.valueOf( DOC_BUDLN_LN_NO ).isNumeric() ){ this.DOC_BUDLN_LN_NO = DOC_BUDLN_LN_NO; }
		if( String.valueOf( LN_ACTN ).isNumeric() ){ this.LN_ACTN = LN_ACTN; }
        if( String.isNotBlank( BUD_DOC_CD ) ){ this.BUD_DOC_CD = BUD_DOC_CD; }
        if( String.isNotBlank( STRU_ID ) ){ this.STRU_ID = STRU_ID; }
        if( String.isNotBlank( EVNT_TYP_ID ) ){ this.EVNT_TYP_ID = EVNT_TYP_ID; }
        if( String.isNotBlank( BUD_NM ) ){ this.BUD_NM = BUD_NM; }
		if( STRT_DT != NULL ){ setSTRT_DT( STRT_DT ); }
		if( END_DT != NULL ){ setEND_DT( END_DT ); }
		if( LN_AM != NULL ){ this.LN_AM = LN_AM; }
        if( String.isNotBlank( PROG_CD ) ){ this.PROG_CD = PROG_CD; }
        if( String.isNotBlank( PHASE_CD ) ){ this.PHASE_CD = PHASE_CD; }
        if( String.isNotBlank( FPRFL_CD ) ){ this.FPRFL_CD = FPRFL_CD; }
        if( String.isNotBlank( FPRTY_CD ) ){ this.FPRTY_CD = FPRTY_CD; }
		if( String.isNotBlank( FLINE_CD ) ){ this.FLINE_CD = FLINE_CD; }
        if( String.isNotBlank( INCR_DCRS_IND ) ){ this.INCR_DCRS_IND = INCR_DCRS_IND; }
        if( String.isNotBlank( BUD_UPD_OPT ) ){ this.BUD_UPD_OPT = BUD_UPD_OPT; }
    }
    // PUBLIC METHODS
    public void setSTRT_DT( Date newDate ){ if( newDate != NULL ){ this.STRT_DT = Integ_CGIAdv_Utilities.formatDateToString( newDate ); }else{ this.STRT_DT = null; } }
    public void setEND_DT( Date newDate ){ if( newDate != NULL ){ this.END_DT = Integ_CGIAdv_Utilities.formatDateToString( newDate ); }else{ this.END_DT = null; } }
}