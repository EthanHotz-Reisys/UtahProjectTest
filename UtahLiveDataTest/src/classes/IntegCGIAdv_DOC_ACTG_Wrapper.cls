/**
* IntegCGIAdv_DOC_ACTG_Wrapper is an abstract class used in the IntegCGIAdv classes
*
* CHANGE HISTORY
* ==================================================================================================
* Date              Name                Description
* Mar 01 2018       Brian Mason         Created
* ==================================================================================================
*/
public abstract class IntegCGIAdv_DOC_ACTG_Wrapper {
    // PUBLIC MEMBERS
    public String NAME { get; set; }
    public Integer DOC_ACTG_LN_NO { get; set; }
    public String ACTG_LN_DSCR { get; set; }
    public Decimal LN_AM { get; set; }
    public String FUND_CD { get; set; }
    public String DEPT_CD { get; set; }
    public String UNIT_CD { get; set; }
    public String APPR_CD { get; set; }
    public String OBJ_CD { get; set; }
    public String PROG_CD { get; set; }
    public String PHASE_CD { get; set; }
    // PUBLIC CONSTRUCTORS
    public IntegCGIAdv_DOC_ACTG_Wrapper(){
        this.NAME = 'Default Name';
        this.DOC_ACTG_LN_NO = -9999;
        this.ACTG_LN_DSCR = '';
        this.LN_AM = -9999;
        this.FUND_CD = '';
        this.DEPT_CD = '';
        this.UNIT_CD = '';
        this.APPR_CD = '';
        this.OBJ_CD = '';
        this.PROG_CD = '';
        this.PHASE_CD = '';
    }
    public IntegCGIAdv_DOC_ACTG_Wrapper( String NAME, Integer DOC_ACTG_LN_NO, String ACTG_LN_DSCR, Decimal LN_AM,
										 String FUND_CD, String DEPT_CD, String UNIT_CD, String APPR_CD, String OBJ_CD,
                                         String PROG_CD, String PHASE_CD ){
		this();
        if( String.isNotBlank( NAME ) ){ this.NAME = NAME; }
        if( String.valueOf( DOC_ACTG_LN_NO ).isNumeric() ){ this.DOC_ACTG_LN_NO = DOC_ACTG_LN_NO; }
        if( String.isNotBlank( ACTG_LN_DSCR ) ){ this.ACTG_LN_DSCR = ACTG_LN_DSCR; }
        if( LN_AM != NULL ){ this.LN_AM = LN_AM; }
        if( String.isNotBlank( FUND_CD ) ){ this.FUND_CD = FUND_CD; }
        if( String.isNotBlank( DEPT_CD ) ){ this.DEPT_CD = DEPT_CD; }
        if( String.isNotBlank( UNIT_CD ) ){ this.UNIT_CD = UNIT_CD; }
        if( String.isNotBlank( APPR_CD ) ){ this.APPR_CD = APPR_CD; }
        if( String.isNotBlank( OBJ_CD ) ){ this.OBJ_CD = OBJ_CD; }
        if( String.isNotBlank( PROG_CD ) ){ this.PROG_CD = PROG_CD; }
        if( String.isNotBlank( PHASE_CD ) ){ this.PHASE_CD = PHASE_CD; }
	}
}