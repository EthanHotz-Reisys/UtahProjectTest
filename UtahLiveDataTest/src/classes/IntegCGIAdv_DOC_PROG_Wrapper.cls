/**
* IntegCGIAdv_DOC_PROG_Wrapper is an abstract class used in the IntegCGIAdv classes
*
* CHANGE HISTORY
* ==================================================================================================
* Date              Name                Description
* Mar 01 2018       Brian Mason         Created
* Mar 27 2018		Brian Mason			Add PROJ_END_DT field
* ==================================================================================================
*/
public abstract class IntegCGIAdv_DOC_PROG_Wrapper {
    // PUBLIC MEMBERS
	public String NAME {get;set;}
    public Integer DOC_MJRPROG_LN_NO {get;set;}
    public Integer DOC_PROG_LN_NO {get;set;}
    public String LN_TYP {get;set;}
    public String PROG_CD {get;set;}
    public String PROG_NM {get;set;}
    public String PROG_SH_NM {get;set;}
    public Boolean ACT_FL {get;set;}
    public Boolean ALW_BUD_FL {get;set;}
    public String SUSP_STA {get;set;}
    public Boolean REIM_ELG_STA {get;set;}
    public String BILL_AGREE_DT {get;private set;}
    public String PROG_DSRC {get;set;}
    public String SACCT_CD {get;set;}
    public String EFBGN_DT {get;private set;}
    public String EFEND_DT {get;private set;}
    public String PGRP_CD {get;set;}
    public String PTYP_CD {get;set;}
    public String PCLS_CD {get;set;}
    public String PCAT_CD {get;set;}
    public String PROJ_END_DT {get;private set;}
	// PUBLIC CONSTRUCTORS
    public IntegCGIAdv_DOC_PROG_Wrapper(){
        this.NAME = 'Default Name';
        this.DOC_MJRPROG_LN_NO = -9999;
        this.DOC_PROG_LN_NO = -9999;
        this.LN_TYP = '';
        this.PROG_CD = '';
        this.PROG_NM = '';
        this.PROG_SH_NM = '';
        this.ACT_FL = NULL;
        this.ALW_BUD_FL = NULL;
        this.SUSP_STA = '';
        this.REIM_ELG_STA = NULL;
        setBILL_AGREE_DT( null );
        this.PROG_DSRC = '';
        this.SACCT_CD = '';
        setEFBGN_DT( null );
        setEFEND_DT( null );
        this.PGRP_CD = '';
        this.PTYP_CD = '';
        this.PCLS_CD = '';
        this.PCAT_CD = '';
        setPROJ_END_DT( null );
    }
    public IntegCGIAdv_DOC_PROG_Wrapper( String NAME, Integer DOC_MJRPROG_LN_NO, Integer DOC_PROG_LN_NO,
                                         String LN_TYP, String PROG_CD, String PROG_NM, String PROG_SH_NM,
                                         Boolean ACT_FL, Boolean ALW_BUD_FL, String SUSP_STA,
                                         Boolean REIM_ELG_STA, Date BILL_AGREE_DT, String PROG_DSRC,
                                         String SACCT_CD, Date EFBGN_DT, Date EFEND_DT, String PGRP_CD,
                                         String PTYP_CD, String PCLS_CD, String PCAT_CD, Date PROJ_END_DT ){
		this();
		if( String.isNotBlank( NAME ) ){ this.NAME = NAME; }
        if( String.valueOf( DOC_MJRPROG_LN_NO ).isNumeric() ){ this.DOC_MJRPROG_LN_NO = DOC_MJRPROG_LN_NO; }
        if( String.valueOf( DOC_PROG_LN_NO ).isNumeric() ){ this.DOC_PROG_LN_NO = DOC_PROG_LN_NO; }
        if( String.isNotBlank( LN_TYP ) ){ this.LN_TYP = LN_TYP; }
        if( String.isNotBlank( PROG_CD ) ){ this.PROG_CD = PROG_CD; }
        if( String.isNotBlank( PROG_NM ) ){ this.PROG_NM = PROG_NM; }
        if( String.isNotBlank( PROG_SH_NM ) ){ this.PROG_SH_NM = PROG_SH_NM; }
        if( ACT_FL != NULL ){ this.ACT_FL = ACT_FL; }
        if( ALW_BUD_FL != NULL ){ this.ALW_BUD_FL = ALW_BUD_FL; }
        if( String.isNotBlank( SUSP_STA ) ){ this.SUSP_STA = SUSP_STA; }
        if( REIM_ELG_STA != NULL ){ this.REIM_ELG_STA = REIM_ELG_STA; }
		if( BILL_AGREE_DT != NULL ){ setBILL_AGREE_DT( BILL_AGREE_DT ); }
        if( String.isNotBlank( PROG_DSRC ) ){ this.PROG_DSRC = PROG_DSRC; }
        if( String.isNotBlank( SACCT_CD ) ){ this.SACCT_CD = SACCT_CD; }
		if( EFBGN_DT != NULL ){ setEFBGN_DT( EFBGN_DT ); }
		if( EFEND_DT != NULL ){ setEFEND_DT( EFEND_DT ); }
        if( String.isNotBlank( PGRP_CD ) ){ this.PGRP_CD = PGRP_CD; }
        if( String.isNotBlank( PTYP_CD ) ){ this.PTYP_CD = PTYP_CD; }
        if( String.isNotBlank( PCLS_CD ) ){ this.PCLS_CD = PCLS_CD; }
        if( String.isNotBlank( PCAT_CD ) ){ this.PCAT_CD = PCAT_CD; }
		if( PROJ_END_DT != NULL ){ setPROJ_END_DT( PROJ_END_DT ); }
    }
    // PUBLIC METHODS
    public void setBILL_AGREE_DT( Date newDate ){ if( newDate != NULL ){ this.BILL_AGREE_DT = Integ_CGIAdv_Utilities.formatDateToString( newDate ); }else{ this.BILL_AGREE_DT = null; } }
    public void setEFBGN_DT( Date newDate ){ if( newDate != NULL ){ this.EFBGN_DT = Integ_CGIAdv_Utilities.formatDateToString( newDate ); }else{ this.EFBGN_DT = null; } }
	public void setEFEND_DT( Date newDate ){ if( newDate != NULL ){ this.EFEND_DT = Integ_CGIAdv_Utilities.formatDateToString( newDate ); }else{ this.EFEND_DT = null; } }
	public void setPROJ_END_DT( Date newDate ){ if( newDate != NULL ){ this.PROJ_END_DT = Integ_CGIAdv_Utilities.formatDateToString( newDate ); }else{ this.PROJ_END_DT = null; } }
}