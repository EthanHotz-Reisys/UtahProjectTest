/**
* IntegCGIAdv_DOC_MJRPROG_Wrapper is an abstract class used in the IntegCGIAdv classes
*
* CHANGE HISTORY
* ==================================================================================================
* Date              Name                Description
* Mar 01 2018       Brian Mason         Created
* ==================================================================================================
*/
public abstract class IntegCGIAdv_DOC_MJRPROG_Wrapper {
    // PUBLIC MEMBERS
    public String NAME {get;set;}
    public Integer DOC_MJRPROG_LN_NO {get;set;}
    public String DEPT_CD {get;set;}
    public String MJR_PROG_CD {get;set;}
    public String MJR_PROG_NM {get;set;}
    public String MJR_PROG_SH_NM {get;set;}
    public Boolean ACT_FL {get;set;}
    public String EFBGN_DT {get;private set;}
    public String EFEND_DT {get;private set;}
    public Boolean ALW_BUD_FL {get;set;}
    public String SUSP_STA {get;set;}
    public String REIM_BAS_IND {get;set;}
    public String REIM_BUD_STRU_CD {get;set;}
    public String SPLT_IND {get;set;}
    public String FED_APPR_SETP {get;set;}
    public String MJR_PROG_DSRC {get;set;}
    // PUBLIC CONSTRUCTORS
    public IntegCGIAdv_DOC_MJRPROG_Wrapper(){
        this.NAME = 'Default Name';
        this.DOC_MJRPROG_LN_NO = -9999;
        this.DEPT_CD = '';
        this.MJR_PROG_CD = '';
        this.MJR_PROG_NM = '';
        this.MJR_PROG_SH_NM = '';
        this.ACT_FL = NULL;
        setEFBGN_DT( null );
        setEFEND_DT( null );
        this.ALW_BUD_FL = NULL;
        this.SUSP_STA = '';
        this.REIM_BAS_IND = '';
        this.REIM_BUD_STRU_CD = '';
        this.SPLT_IND = '';
        this.FED_APPR_SETP = '';
        this.MJR_PROG_DSRC = '';
    }
    public IntegCGIAdv_DOC_MJRPROG_Wrapper( String NAME, Integer DOC_MJRPROG_LN_NO, String DEPT_CD,
                                            String MJR_PROG_CD, String MJR_PROG_NM, String MJR_PROG_SH_NM,
                                            Boolean ACT_FL, Date EFBGN_DT, Date EFEND_DT,
                                            Boolean ALW_BUD_FL, String SUSP_STA, String REIM_BAS_IND,
                                            String REIM_BUD_STRU_CD, String SPLT_IND, String FED_APPR_SETP,
                                            String MJR_PROG_DSRC ){
        this();
		if( String.isNotBlank( NAME ) ){ this.NAME = NAME; }
    	if( String.valueOf( DOC_MJRPROG_LN_NO ).isNumeric() ){ this.DOC_MJRPROG_LN_NO = DOC_MJRPROG_LN_NO; }
        if( String.isNotBlank( DEPT_CD ) ){ this.DEPT_CD = DEPT_CD; }
        if( String.isNotBlank( MJR_PROG_CD ) ){ this.MJR_PROG_CD = MJR_PROG_CD; }
        if( String.isNotBlank( MJR_PROG_NM ) ){ this.MJR_PROG_NM = MJR_PROG_NM; }
        if( String.isNotBlank( MJR_PROG_SH_NM ) ){ this.MJR_PROG_SH_NM = MJR_PROG_SH_NM; }
        if( ACT_FL != NULL ){ this.ACT_FL = ACT_FL; }
        if( EFBGN_DT != NULL ){ setEFBGN_DT( EFBGN_DT ); }
        if( EFEND_DT != NULL ){ setEFEND_DT( EFEND_DT ); }
        if( ALW_BUD_FL != NULL ){ this.ALW_BUD_FL = ALW_BUD_FL; }
        if( String.isNotBlank( SUSP_STA ) ){ this.SUSP_STA = SUSP_STA; }
        if( String.isNotBlank( REIM_BAS_IND ) ){ this.REIM_BAS_IND = REIM_BAS_IND; }
        if( String.isNotBlank( REIM_BUD_STRU_CD ) ){ this.REIM_BUD_STRU_CD = REIM_BUD_STRU_CD; }
        if( String.isNotBlank( SPLT_IND ) ){ this.SPLT_IND = SPLT_IND; }
        if( String.isNotBlank( FED_APPR_SETP ) ){ this.FED_APPR_SETP = FED_APPR_SETP; }
        if( String.isNotBlank( MJR_PROG_DSRC ) ){ this.MJR_PROG_DSRC = MJR_PROG_DSRC; }
    }
    // PUBLIC METHODS
    public void setEFBGN_DT( Date newDate ){ if( newDate != NULL ){ this.EFBGN_DT = Integ_CGIAdv_Utilities.formatDateToString( newDate ); }else{ this.EFBGN_DT = null; } }
    public void setEFEND_DT( Date newDate ){ if( newDate != NULL ){ this.EFEND_DT = Integ_CGIAdv_Utilities.formatDateToString( newDate ); }else{ this.EFEND_DT = null; } }    
}