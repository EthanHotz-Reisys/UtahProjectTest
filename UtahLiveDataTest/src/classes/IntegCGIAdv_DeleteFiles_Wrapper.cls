/**
* IntegCGIAdv_DeleteFiles_Wrapper is an abstract class used in the IntegCGIAdv classes
*
* CHANGE HISTORY
* ==================================================================================================
* Date              Name                Description
* Mar 01 2018       Brian Mason         Created
* ==================================================================================================
*/
public abstract class IntegCGIAdv_DeleteFiles_Wrapper {
	// PUBLIC MEMBERS
    public String[] files {get; private set;}
    // PUBLIC CONSTRUCTORS
    public IntegCGIAdv_DeleteFiles_Wrapper(){ if( this.files == null ){ this.files = new String[]{}; } }
    public IntegCGIAdv_DeleteFiles_Wrapper( String file ){
        this();
        if( String.isNotBlank( file ) ){ this.files.add( file ); }
    }
    // PUBLIC METHODS
    public String renderJSON( Boolean renderPretty ){ return renderPretty ? JSON.serializePretty( this ) : JSON.serialize( this ); }
    public void addFile( String file ){
        if( String.isNotBlank( file ) ){
        	this.files.add( file );
        	this.files = new List<String>( new Set<String>( this.files ) );
    	}
	}
    public void removeFile( String file ){
        if( String.isNotBlank( file ) ){
            for( Integer i = 0; i < this.files.size(); i++){
                if( this.files[i] == file ){ this.files.remove(i); }
            }
    	}
	}
}