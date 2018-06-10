public abstract class IntegCGIAdv_ABS_DOC_VEND_Wrapper {
    public String NAME { get; set; }
	public Integer DOC_VEND_LN_NO { get; set; }
    public String VEND_CUST_CD { get; set; }
    public String AD_ID { get; set; }
    
    public IntegCGIAdv_ABS_DOC_VEND_Wrapper(){
        this.NAME = 'Default Name';
        this.DOC_VEND_LN_NO = NULL;
        this.VEND_CUST_CD = NULL;
        this.AD_ID = NULL;
    }
    public IntegCGIAdv_ABS_DOC_VEND_Wrapper( String NAME, Integer DOC_VEND_LN_NO, String VEND_CUST_CD, String AD_ID ){
        this();
        if( String.isNotBlank( NAME ) ){ this.NAME = NAME; }
        if( String.valueOf( DOC_VEND_LN_NO ).isNumeric() ){ this.DOC_VEND_LN_NO = DOC_VEND_LN_NO; }
        if( String.isNotBlank( VEND_CUST_CD ) ){ this.VEND_CUST_CD = VEND_CUST_CD; }
        if( String.isNotBlank( AD_ID ) ){ this.AD_ID = AD_ID; }
    }
}