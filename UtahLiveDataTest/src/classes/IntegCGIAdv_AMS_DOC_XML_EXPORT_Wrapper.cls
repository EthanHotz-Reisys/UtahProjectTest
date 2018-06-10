/**
* IntegCGIAdv_AMS_DOC_XML_EXPORT_Wrapper is an abstract class used in the IntegCGIAdv classes
*
* CHANGE HISTORY
* ==================================================================================================
* Date              Name                Description
* Mar 01 2018       Brian Mason         Created
* ==================================================================================================
*/
public abstract class IntegCGIAdv_AMS_DOC_XML_EXPORT_Wrapper {
    // PUBLIC MEMBERS
    public String NAME{get;set;}
    public String VERSION{get;set;}
    public String EXPORT_DATE{get;private set;}
    public String DEPT_CD{get; set;}
    public class MissingDeptCodeException extends Exception {}
    // PUBLIC CONSTRUCTORS
/*
    public IntegCGIAdv_AMS_DOC_XML_EXPORT_Wrapper( String DEPT_CD ){
        this( '1.0', 'Default Name', DateTime.now(), Integ_CGIAdv_Utilities.DefaultTimeZone(), DEPT_CD );
    }
    public IntegCGIAdv_AMS_DOC_XML_EXPORT_Wrapper( String VERSION, String NAME, String DEPT_CD ){
        this( VERSION, NAME, DateTime.now(), Integ_CGIAdv_Utilities.DefaultTimeZone(), DEPT_CD );
    }
    public IntegCGIAdv_AMS_DOC_XML_EXPORT_Wrapper( String VERSION, String NAME, DateTime EXPORT_DATE, String DEPT_CD ){
        this( VERSION, NAME, EXPORT_DATE, Integ_CGIAdv_Utilities.DefaultTimeZone(), DEPT_CD );
    }
*/
    public IntegCGIAdv_AMS_DOC_XML_EXPORT_Wrapper( String VERSION, String NAME, DateTime EXPORT_DATE, String TimeZone, String DEPT_CD ){
        if( String.isNotBlank( VERSION ) ){ this.VERSION = VERSION; }
        if( String.isNotBlank( NAME ) ){ this.NAME = NAME; }
        if( EXPORT_DATE != NULL ){ setEXPORT_DATE( EXPORT_DATE, TimeZone ); }
        if( String.isNotBlank( DEPT_CD ) ){ this.DEPT_CD = DEPT_CD; }
        if( String.isBlank( DEPT_CD ) ){ throw new MissingDeptCodeException('Department Code is missing and must be present.'); }
    }
    // PUBLIC METHODS
    public String renderJSON( Boolean renderPretty ){ return renderPretty ? JSON.serializePretty( this ) : JSON.serialize( this ); }
    public void setEXPORT_DATE( DateTime EXPORT_DATE, String TimeZone ){
        if( EXPORT_DATE != NULL ) {
            this.EXPORT_DATE = EXPORT_DATE.format( 'yyyy-MM-dd HH:mm:ss.SSSSSS', String.isBlank( TimeZone ) ? Integ_CGIAdv_Utilities.DefaultTimeZone() : TimeZone );
		}
    }
}