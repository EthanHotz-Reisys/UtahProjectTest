/**
* IntegCGIAdv_Transmittal_Wrapper is an abstract class used in the IntegCGIAdv classes
*
* CHANGE HISTORY
* ==================================================================================================
* Date              Name                Description
* Mar 01 2018       Brian Mason         Created
* ==================================================================================================
*/
public abstract class IntegCGIAdv_Transmittal_Wrapper {
	// PUBLIC MEMBERS
    public String filename { get;set; }
    public String dept { get; set; }
    public String documentcode { get; set; }
    public String firstdocid { get; set; }
    public String lastdocid { get; set; }
    public Integer numofdocs { get; set; }
    public Decimal totalamt { get; set; }
    public String returnemail { get; set; }
    // PUBLIC CONSTRUCTORS
    private IntegCGIAdv_Transmittal_Wrapper(){
        filename = '';
        dept = '';
        documentcode = '';
        firstdocid = '';
        lastdocid = '';
        numofdocs = 0;
        totalamt = 0.00;
        returnemail = '';
    }
    public IntegCGIAdv_Transmittal_Wrapper( String filename, String dept, String documentcode, 
                                            String firstdocid, String lastdocid, Integer numofdocs,
                                            Decimal totalamt, String returnemail ){
        this();
        if( String.isNotBlank( filename ) ){ this.filename = filename; }
        if( String.isNotBlank( dept ) ){ this.dept = dept; }
        if( String.isNotBlank( documentcode ) ){ this.documentcode = documentcode; }
        if( String.isNotBlank( firstdocid ) ){ this.firstdocid = firstdocid; }
        if( String.isNotBlank( lastdocid ) ){ this.lastdocid = lastdocid; }
        this.numofdocs = numofdocs;
        this.totalamt = totalamt;
        if( String.isNotBlank( returnemail ) ){ this.returnemail = returnemail; }
    }
    // PUBLIC METHODS
}