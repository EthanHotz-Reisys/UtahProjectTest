/**
* IntegCGIAdv_DOC_FPI_Wrapper is an abstract class used in the IntegCGIAdv classes
*
* CHANGE HISTORY
* ==================================================================================================
* Date              Name                Description
* Mar 01 2018       Brian Mason         Created
* ==================================================================================================
*/
public abstract class IntegCGIAdv_DOC_FPI_Wrapper {
	// PUBLIC MEMBERS
    public String NAME {get;set;}
    public Integer DOC_FPI_LN_NO {get;set;}
    public String LN_TYP {get;set;}
    public String FUND_PRFL_INF {get;set;}
    public String PROG_CD {get;set;}
    public String FPRFL_CD {get;set;}
    public String REIM_ELG_STA_MTCH {get;set;}
    public String PHASE_CD {get;set;}
    // PUBLIC CONSTRUCTORS
    public IntegCGIAdv_DOC_FPI_Wrapper(){
        this.NAME = 'Default Name';
        this.DOC_FPI_LN_NO = -9999;
        this.LN_TYP = '';
        this.FUND_PRFL_INF = '';
        this.PROG_CD = '';
        this.FPRFL_CD = '';
        this.REIM_ELG_STA_MTCH = '';
        this.PHASE_CD = '';
    }
    public IntegCGIAdv_DOC_FPI_Wrapper( String NAME, Integer DOC_FPI_LN_NO,
                                      	String LN_TYP, String FUND_PRFL_INF, 
                                      	String PROG_CD, String FPRFL_CD, 
                                      	String REIM_ELG_STA_MTCH,
                                        String PHASE_CD ){
		this();
		if( String.isNotBlank( NAME ) ){ this.NAME = NAME; }
    	if( String.valueOf( DOC_FPI_LN_NO ).isNumeric() ){ this.DOC_FPI_LN_NO = DOC_FPI_LN_NO; }
        if( String.isNotBlank( LN_TYP ) ){ this.LN_TYP = LN_TYP; }
        if( String.isNotBlank( FUND_PRFL_INF ) ){ this.FUND_PRFL_INF = FUND_PRFL_INF; }
        if( String.isNotBlank( PROG_CD ) ){ this.PROG_CD = PROG_CD; }
        if( String.isNotBlank( FPRFL_CD ) ){ this.FPRFL_CD = FPRFL_CD; }
        if( String.isNotBlank( REIM_ELG_STA_MTCH ) ){ this.REIM_ELG_STA_MTCH = REIM_ELG_STA_MTCH; }
        if( String.isNotBlank( PHASE_CD ) ){ this.PHASE_CD = PHASE_CD; }
    }
}