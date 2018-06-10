/**
* IntegCGIAdv_DOC_PHSEPROG_Wrapper is an abstract class used in the IntegCGIAdv classes
*
* CHANGE HISTORY
* ==================================================================================================
* Date              Name                Description
* Mar 01 2018       Brian Mason         Created
* ==================================================================================================
*/
public abstract class IntegCGIAdv_DOC_PHSEPROG_Wrapper {
	// PUBLIC MEMBERS
	public String NAME {get;set;}
    public Integer DOC_MJRPROG_LN_NO {get;set;}
    public Integer DOC_PROG_LN_NO {get;set;}
    public Integer DOC_PHSEPROG_LN_NO {get;set;}
    public String LN_TYP {get;set;}
    public String PHASE_CD {get;set;}
    public String PROG_CD {get;set;}
    public String SACCT_CD {get;set;}
    public String SITE_LOC_CD {get;set;}
    public String EFBGN_DT {get;private set;}
    public String EFEND_DT {get;private set;}
    public String BILL_AGREE_DT {get;private set;}
    public Boolean ACT_FL {get;set;}
    public Boolean ALW_BUD_FL {get;set;}
    public Boolean REIM_ELG_STA {get;set;}
    public String SUSP_STA {get;set;}
    public String PHASE_DSRC {get;set;}
    // PUBLIC CONSTRUCTORS
    public IntegCGIAdv_DOC_PHSEPROG_Wrapper(){
        this.NAME = 'Default Name';
        this.DOC_MJRPROG_LN_NO = -9999;
        this.DOC_PROG_LN_NO = -9999;
        this.DOC_PHSEPROG_LN_NO = -9999;
        this.LN_TYP = '';
        this.PHASE_CD = '';
        this.PROG_CD = '';
        this.SACCT_CD = '';
        this.SITE_LOC_CD = '';
        setEFBGN_DT( null );
        setEFEND_DT( null );
        setBILL_AGREE_DT( null );
        this.ACT_FL = NULL;
        this.ALW_BUD_FL = NULL;
        this.REIM_ELG_STA = NULL;
        this.SUSP_STA = '';
        this.PHASE_DSRC = '';
    }
    public IntegCGIAdv_DOC_PHSEPROG_Wrapper( String NAME, Integer DOC_MJRPROG_LN_NO,
                                             Integer DOC_PROG_LN_NO, Integer DOC_PHSEPROG_LN_NO,
                                             String LN_TYP, String PHASE_CD, String PROG_CD,
                                             String SACCT_CD, String SITE_LOC_CD,
                                             Date EFBGN_DT, Date EFEND_DT, Date BILL_AGREE_DT, 
                                             Boolean ACT_FL, Boolean ALW_BUD_FL, Boolean REIM_ELG_STA,
                                             String SUSP_STA, String PHASE_DSRC ){
        this();
        if( String.isNotBlank( NAME ) ){ this.NAME = NAME; }
		if( String.valueOf( DOC_MJRPROG_LN_NO ).isNumeric() ){ this.DOC_MJRPROG_LN_NO = DOC_MJRPROG_LN_NO; }
		if( String.valueOf( DOC_PROG_LN_NO ).isNumeric() ){ this.DOC_PROG_LN_NO = DOC_PROG_LN_NO; }
		if( String.valueOf( DOC_PHSEPROG_LN_NO ).isNumeric() ){ this.DOC_PHSEPROG_LN_NO = DOC_PHSEPROG_LN_NO; }
        if( String.isNotBlank( LN_TYP ) ){ this.LN_TYP = LN_TYP; }
        if( String.isNotBlank( PHASE_CD ) ){ this.PHASE_CD = PHASE_CD; }
        if( String.isNotBlank( PROG_CD ) ){ this.PROG_CD = PROG_CD; }
        if( String.isNotBlank( SACCT_CD ) ){ this.SACCT_CD = SACCT_CD; }
        if( String.isNotBlank( SITE_LOC_CD ) ){ this.SITE_LOC_CD = SITE_LOC_CD; }
		if( EFBGN_DT != NULL ){ setEFBGN_DT( EFBGN_DT ); }
		if( EFEND_DT != NULL ){ setEFEND_DT( EFEND_DT ); }
		if( BILL_AGREE_DT != NULL ){ setBILL_AGREE_DT( BILL_AGREE_DT ); }
        if( ACT_FL != NULL ){ this.ACT_FL = ACT_FL; }
        if( ALW_BUD_FL != NULL ){ this.ALW_BUD_FL = ALW_BUD_FL; }
        if( REIM_ELG_STA != NULL ){ this.REIM_ELG_STA = REIM_ELG_STA; }
        if( String.isNotBlank( SUSP_STA ) ){ this.SUSP_STA = SUSP_STA; }
        if( String.isNotBlank( PHASE_DSRC ) ){ this.PHASE_DSRC = PHASE_DSRC; }
    }
    // PUBLIC METHODS
    public void setEFBGN_DT( Date newDate ){ if( newDate != NULL ){ this.EFBGN_DT = Integ_CGIAdv_Utilities.formatDateToString( newDate ); }else{ this.EFBGN_DT = null; } }
    public void setEFEND_DT( Date newDate ){ if( newDate != NULL ){ this.EFEND_DT = Integ_CGIAdv_Utilities.formatDateToString( newDate ); }else{ this.EFEND_DT = null; } }
    public void setBILL_AGREE_DT( Date newDate ){ if( newDate != NULL ){ this.BILL_AGREE_DT = Integ_CGIAdv_Utilities.formatDateToString( newDate ); }else{ this.BILL_AGREE_DT = null; } }
}