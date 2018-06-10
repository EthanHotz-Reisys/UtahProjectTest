/**
* IntegCGIAdv_ProgPhasBud_Transmit_Files is used to produce the JSON for Program/Phase/Budget association
* transmittal files
*
* CHANGE HISTORY
* ==================================================================================================
* Date              Name                Description
* Mar 01 2018       Brian Mason         Created
* ==================================================================================================
*/
public class IntegCGIAdv_ProgPhasBud_Transmit_Files {
	// PRIVATE STATIC CONSTANTS
	// PUBLIC MEMBERS
    public IntegCGIAdv_ProgPhasBud_Transmittal_File[] transmittals {get;set;}
	// PUBLIC CONSTRUCTORS
    public IntegCGIAdv_ProgPhasBud_Transmit_Files(){ if( this.transmittals == null){ transmittals = new IntegCGIAdv_ProgPhasBud_Transmittal_File[]{};} }
    public IntegCGIAdv_ProgPhasBud_Transmit_Files( IntegCGIAdv_ProgPhasBud_Transmittal_File file ){
        this();
        if( file != null){ this.transmittals.add( file ); }
    }
    // PUBLIC METHODS
	public void addTranmittal( String filename, String dept,  
                               String firstdocid, String lastdocid, Integer numofdocs,
                               Decimal totalamt, String returnemail ){
		addTranmittal( 
            new IntegCGIAdv_ProgPhasBud_Transmittal_File( filename, dept, firstdocid, lastdocid, numofdocs, totalamt, returnemail )
        );
    }
    public void addTranmittal( IntegCGIAdv_ProgPhasBud_Transmittal_File transmittal ){
        if( transmittal != null){ this.transmittals.add( transmittal ); }
    }
    public String renderJSON( Boolean renderPretty ){ return renderPretty ? JSON.serializePretty( this ) : JSON.serialize( this ); }
	// PUBLIC CLASSES
    public class IntegCGIAdv_ProgPhasBud_Transmittal_File extends IntegCGIAdv_Transmittal_Wrapper{
        // PUBLIC CONSTRUCTORS
        public IntegCGIAdv_ProgPhasBud_Transmittal_File( String filename, String dept, 
                                                 String firstdocid, String lastdocid, Integer numofdocs,
                                                 Decimal totalamt, String returnemail ){
			super( filename, dept, 'GCAM', firstdocid, lastdocid, numofdocs, totalamt, returnemail );
		}
    }
}