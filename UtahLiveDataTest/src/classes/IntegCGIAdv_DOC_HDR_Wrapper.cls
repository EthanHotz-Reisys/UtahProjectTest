/**
* IntegCGIAdv_DOC_HDR_Wrapper is an abstract class used in the IntegCGIAdv classes
*
* CHANGE HISTORY
* ==================================================================================================
* Date              Name                Description
* Mar 01 2018       Brian Mason         Created
* ==================================================================================================
*/
public abstract class IntegCGIAdv_DOC_HDR_Wrapper {
    // PUBLIC MEMBERS
    public String NAME { get; set; }
    public String DOC_DSCR { get; set; }
    // PUBLIC CONSTRUCTORS
    public IntegCGIAdv_DOC_HDR_Wrapper(){
        this.NAME = 'Default Name';
        this.DOC_DSCR = '';
    }
    public IntegCGIAdv_DOC_HDR_Wrapper( String NAME, String DOC_DSCR ){
        this();
        if( String.isNotBlank( NAME ) ){ this.NAME = NAME; }
        if( String.isNotBlank( DOC_DSCR ) ){ this.DOC_DSCR = DOC_DSCR; }
    }
}