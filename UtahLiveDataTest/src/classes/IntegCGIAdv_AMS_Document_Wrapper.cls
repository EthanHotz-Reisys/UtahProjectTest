/**
* IntegCGIAdv_AMS_Document_Wrapper is an abstract class used in the IntegCGIAdv classes
*
* CHANGE HISTORY
* ==================================================================================================
* Date              Name                Description
* Mar 01 2018       Brian Mason         Created
* ==================================================================================================
*/
public abstract class IntegCGIAdv_AMS_Document_Wrapper {
	// PUBLIC MEMBERS
    public String NAME { get;set; }
    public String DOC_CAT { get; set; }
    public String DOC_TYP { get; set; }
    public String DOC_CD { get; set; }
    public String DOC_DEPT_CD { get; set; }
    public String DOC_UNIT_CD { get; set; }
    public String DOC_ID { get; set; }
    public String DOC_VERS_NO { get; set; }
    public Boolean AUTO_DOC_NUM { get; set; }
    public String DOC_IMPORT_MODE { get; set; }
    // PUBLIC CONSTRUCTORS
    public IntegCGIAdv_AMS_Document_Wrapper(){
        this.NAME = 'Default Name';
        this.DOC_CAT = '';
        this.DOC_TYP = '';
        this.DOC_CD = '';
        this.DOC_DEPT_CD = '';
        this.DOC_UNIT_CD = '';
        this.DOC_ID = '';
        this.DOC_VERS_NO = '';
        this.AUTO_DOC_NUM = true;
        this.DOC_IMPORT_MODE = '';
    }
    public IntegCGIAdv_AMS_Document_Wrapper( String NAME, String DOC_CAT, String DOC_TYP, String DOC_CD, String DOC_DEPT_CD, 
                                             String DOC_UNIT_CD, String DOC_ID, String DOC_VERS_NO, Boolean AUTO_DOC_NUM, 
                                             String DOC_IMPORT_MODE ){
                            this();
                            if( String.isNotBlank( NAME ) ){ this.NAME = NAME; }
                            this.DOC_CAT = DOC_CAT;
                            this.DOC_TYP = DOC_TYP;
                            this.DOC_CD = DOC_CD;
                            this.DOC_DEPT_CD = DOC_DEPT_CD;
                            this.DOC_UNIT_CD = DOC_UNIT_CD;
                            this.DOC_ID = DOC_ID;
                            this.DOC_VERS_NO = DOC_VERS_NO;
                            this.AUTO_DOC_NUM = AUTO_DOC_NUM;
                            this.DOC_IMPORT_MODE = DOC_IMPORT_MODE;
    }
}