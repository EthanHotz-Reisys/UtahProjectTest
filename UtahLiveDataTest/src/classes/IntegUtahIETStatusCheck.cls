public with sharing class IntegUtahIETStatusCheck extends IntegUtahEntityStatusCheck {
    public IntegUtahIETStatusCheck(List<Grants_API_Document_Status__c> docs) {
        super(docs);
    }
    @InvocableMethod(label='Check for IET Document Status' description='Check Status of IET Documents in FINET')
    public static void getStatus( List<Grants_API_Document_Status__c> docs ){
        if( docs != null && !docs.isEmpty() ){ Database.executeBatch( new IntegUtahIETStatusCheck( docs ), 4 ); }
    }

    protected override HttpResponse callAPI(string GovGrants_DOC_ID, string Grants_API_Document_Type, string Grants_API_Document_Dept_CD, string Grants_API_DOC_ID, integer versionNumber) {
        IntegUtahGrantsAPI.statusQueryParameters params = new IntegUtahGrantsAPI.statusQueryParameters( GovGrants_DOC_ID, Grants_API_Document_Type, Grants_API_Document_Dept_CD, Grants_API_DOC_ID, 1 );
        return IntegUtahGrantorAPI.getIETStatus( params ); 
    }
}