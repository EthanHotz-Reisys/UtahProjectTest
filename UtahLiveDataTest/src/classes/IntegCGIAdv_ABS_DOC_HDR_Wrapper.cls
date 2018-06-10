public abstract class IntegCGIAdv_ABS_DOC_HDR_Wrapper {
	public String DOC_REC_DT_DC { get; private set; }
    public String DOC_PER_DC { get; set; }
    public Integer DOC_FY_DC { get; set; }
    public String DOC_DSCR { get; set; }
    public String NAME { get; set; }
    
    // PUBLIC CONSTRUCTORS
    public IntegCGIAdv_ABS_DOC_HDR_Wrapper(){
        this.NAME = 'Default Name';
        this.DOC_REC_DT_DC = NULL;
        this.DOC_PER_DC = NULL;
        this.DOC_FY_DC = NULL;
        this.DOC_DSCR = NULL;
    }
    public IntegCGIAdv_ABS_DOC_HDR_Wrapper( String NAME, String DOC_REC_DT_DC, String DOC_PER_DC, Integer DOC_FY_DC, String DOC_DSCR ){
        this();
        if( String.isNotBlank( NAME ) ){ this.NAME = NAME; }
        if( String.isNotBlank( DOC_REC_DT_DC ) && date.parse( DOC_REC_DT_DC ) != NULL ){ setDOC_REC_DT_DC( DOC_REC_DT_DC ); }
        if( String.isNotBlank( DOC_PER_DC) ){ this.DOC_PER_DC = DOC_PER_DC; }
        if( String.valueOf( DOC_FY_DC ).isNumeric() ){ this.DOC_FY_DC = DOC_FY_DC; }
        if( String.isNotBlank( DOC_DSCR ) ){ this.DOC_DSCR = DOC_DSCR; }
    }
    // PUBLIC METHODS
    public void setDOC_REC_DT_DC( String newDate ){
        Date dt = date.parse( newDate );
        this.DOC_REC_DT_DC = dt.year() + '-' + dt.month() + '-' + dt.day();
    }
}