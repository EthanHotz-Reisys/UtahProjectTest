/**
* IntegUtahGrantorAPI is a utility class used in the IntegCGIAdv classes to submit requests to the API
*
* CHANGE HISTORY
* ==================================================================================================
* Date              Name                Description
* Mar 01 2018       Brian Mason         Created
* Mar 20 2018		Brian Mason			Update function methods to take related objects
* ==================================================================================================
*/
public class IntegUtahGrantorAPI {
    // PUBLIC EXCEPTIONS
    public class statusValuesBlankException extends Exception{}
    // PUBLIC METHODS
    public static HttpResponse postGAXPaymentDetails( IntegCGIAdv_GAX_Document GAX_DOCUMENT ){
        if( GAX_DOCUMENT == NULL ){ return NULL; }
        return IntegUtahGrantsAPI.fetchResponse( 'award/payment-request/gax', 'POST',
                                                 new Map<String, String>{'Content-Type' => 'application/json'},
                                                 NULL, 120000, GAX_DOCUMENT.renderJSON(false), 'GRANTOR' );
    }
    public static HttpResponse postIETPaymentDetails( IntegCGIAdv_IET_Document IET_DOCUMENT ){
        if( IET_DOCUMENT == NULL ){ return NULL; }
        return IntegUtahGrantsAPI.fetchResponse( 'award/payment-request/iet', 'POST', 
												 new Map<String, String>{'Content-Type' => 'application/json'},
                                                 NULL, 120000, IET_DOCUMENT.renderJSON(false), 'GRANTOR' );
    }
    public static HttpResponse postCreateProgram( IntegCGIAdv_GCAM_Program_Document PROGRAM_DOCUMENT ){
        if( PROGRAM_DOCUMENT == NULL ){ return NULL; }
        return IntegUtahGrantsAPI.fetchResponse( 'program', 'POST', 
                                               	 new Map<String, String>{'Content-Type' => 'application/json'},
                                               	 NULL, 120000, PROGRAM_DOCUMENT.renderJSON(false), 'GRANTOR' );
    }
    public static HttpResponse postCreateProgramPhaseWithBudget( IntegCGIAdv_GCAM_ProgPhse_Budgt_Document PROGRAM_PHASE_DOCUMENT ){
        if( PROGRAM_PHASE_DOCUMENT == NULL ){ return NULL; }
        return IntegUtahGrantsAPI.fetchResponse( 'program/phase-budget', 'POST', 
                                               	 new Map<String, String>{'Content-Type' => 'application/json'},
                                               	 NULL, 120000, PROGRAM_PHASE_DOCUMENT.renderJSON(false), 'GRANTOR' );
    }
    public static HttpResponse putModifyProgramPhaseBudget( IntegCGIAdv_GCAM_ProgPhse_Mod_Document PROGRAM_PHASE_DOCUMENT ){
        if(  PROGRAM_PHASE_DOCUMENT == NULL ){ return NULL; }
        return IntegUtahGrantsAPI.fetchResponse( 'program/phase-budget', 'PUT', 
                                                 new Map<String, String>{'Content-Type' => 'application/json'},
                                                 NULL, 120000, PROGRAM_PHASE_DOCUMENT.renderJSON(false), 'GRANTOR' );
    }
    public static HttpResponse postRetrieveApprRecords( IntegUtahGrantsAPI.apiQueryParameters queryParams,
														Set<Integer> fiscalYears, Set<String> codes, Set<String> names, Set<String> shortNames ){
        return IntegUtahGrantsAPI.fetchResponse( 'appr/query', 'POST',
                                                 new Map<String, String>{'Content-Type' => 'application/json', 'X-HTTP-Method-Override' => 'GET'},
                                                 queryParams, 120000,
                                                 JSON.serialize( new apprQueryRequestBody( fiscalYears, codes, names, shortnames ) ), 'GRANTOR' );
    }
    public static HttpResponse postRetrieveFundRecords( IntegUtahGrantsAPI.apiQueryParameters queryParams,
														Set<Integer> fiscalYears, Set<String> codes, Set<String> names, Set<String> shortNames ){
        return IntegUtahGrantsAPI.fetchResponse( 'fund/query', 'POST',
                                                 new Map<String, String>{'Content-Type' => 'application/json', 'X-HTTP-Method-Override' => 'GET'},
                                                 queryParams, 120000,
                                                 JSON.serialize( new fundQueryRequestBody( fiscalYears, codes, names, shortnames ) ), 'GRANTOR' );
    }
    public static HttpResponse postRetrieveFundingInferenceProfileRecords( IntegUtahGrantsAPI.apiQueryParameters queryParams,
																		   Set<String> departments, Set<String> codes, 
                                                                           Set<String> names, Set<String> majorprograms ){
        return IntegUtahGrantsAPI.fetchResponse( 'funding-inference-profile/query', 'POST',
                                                 new Map<String, String>{'Content-Type' => 'application/json', 'X-HTTP-Method-Override' => 'GET'},
                                                 queryParams, 120000,
                                                 JSON.serialize( new fundingInferenceProfileQueryRequestBody( departments, codes, names, majorprograms ) ), 'GRANTOR' );
    }
    public static HttpResponse postRetrieveMajorProgramRecords( IntegUtahGrantsAPI.apiQueryParameters queryParams,
																Set<String> departments, Set<String> codes, Set<String> names, Set<String> shortNames ){
        return IntegUtahGrantsAPI.fetchResponse( 'major-program/query', 'POST',
                                               	 new Map<String, String>{'Content-Type' => 'application/json', 'X-HTTP-Method-Override' => 'GET'},
                                                 queryParams, 120000,
                                                 JSON.serialize( new majorProgramQueryRequestBody( departments, codes, names, shortnames ) ), 'GRANTOR' );
    }
    public static HttpResponse postRetrieveObjRecords( IntegUtahGrantsAPI.apiQueryParameters queryParams,
                                                       Set<Integer> fiscalYears, Set<String> codes, Set<String> names, Set<String> shortNames ){
        return IntegUtahGrantsAPI.fetchResponse( 'obj/query', 'POST',
                                                 new Map<String, String>{'Content-Type' => 'application/json', 'X-HTTP-Method-Override' => 'GET'},
                                                 queryParams, 120000,
                                                 JSON.serialize( new objQueryRequestBody( fiscalYears, codes, names, shortnames ) ), 'GRANTOR' );
    }
    public static HttpResponse postRetrieveProgramRecords( IntegUtahGrantsAPI.apiQueryParameters queryParams,
														   Set<String> departments, Set<String> codes, Set<String> names, Set<String> shortNames ){
        return IntegUtahGrantsAPI.fetchResponse( 'program/query', 'POST',
                                                 new Map<String, String>{'Content-Type' => 'application/json', 'X-HTTP-Method-Override' => 'GET'},
                                                 queryParams, 120000,
                                                 JSON.serialize( new majorProgramQueryRequestBody( departments, codes, names, shortnames ) ), 'GRANTOR' );
    }
    public static HttpResponse postRetrieveProgramCategoryRecords( IntegUtahGrantsAPI.apiQueryParameters queryParams,
                                                                   Set<String> codes, Set<String> names, Set<String> shortNames ){
        return IntegUtahGrantsAPI.fetchResponse( 'program/category/query', 'POST',
                                                 new Map<String, String>{'Content-Type' => 'application/json', 'X-HTTP-Method-Override' => 'GET'},
                                                 queryParams, 120000,
                                                 JSON.serialize( new programCategoryQueryRequestBody( codes, names, shortnames ) ), 'GRANTOR' );
    }
    public static HttpResponse postRetrieveProgramClassRecords( IntegUtahGrantsAPI.apiQueryParameters queryParams,
                                                                Set<String> codes, Set<String> names, Set<String> shortNames ){
        return IntegUtahGrantsAPI.fetchResponse( 'program/class/query', 'POST',
                                                 new Map<String, String>{'Content-Type' => 'application/json', 'X-HTTP-Method-Override' => 'GET'},
                                                 queryParams, 120000,
                                                 JSON.serialize( new programClassQueryRequestBody( codes, names, shortnames ) ), 'GRANTOR' );
    }
    public static HttpResponse postRetrieveProgramGroupRecords( IntegUtahGrantsAPI.apiQueryParameters queryParams,
                                                                Set<String> departments, Set<String> codes, Set<String> names, Set<String> shortNames ){
        return IntegUtahGrantsAPI.fetchResponse( 'program/group/query', 'POST',
                                                 new Map<String, String>{'Content-Type' => 'application/json', 'X-HTTP-Method-Override' => 'GET'},
                                                 queryParams, 120000,
                                                 JSON.serialize( new programGroupQueryRequestBody( departments, codes, names, shortnames ) ), 'GRANTOR' );
    }
    public static HttpResponse postRetrieveProgramTypeRecords( IntegUtahGrantsAPI.apiQueryParameters queryParams,
                                                               Set<String> departments, Set<String> codes, Set<String> names, Set<String> shortNames ){
        return IntegUtahGrantsAPI.fetchResponse( 'program/type/query', 'POST',
                                                 new Map<String, String>{'Content-Type' => 'application/json', 'X-HTTP-Method-Override' => 'GET'},
                                                 queryParams, 120000,
                                                 JSON.serialize( new programTypeQueryRequestBody( departments, codes, names, shortnames ) ), 'GRANTOR' );
    }
    public static HttpResponse postRetrieveSubrecipientRecords( IntegUtahGrantsAPI.apiQueryParameters queryParams,
                                                               	Set<String> codes, Set<String> legal_names, Set<String> tins, Set<String> duns_nos ){
        return IntegUtahGrantsAPI.fetchResponse( 'subrecipient/query', 'POST',
                                               	 new Map<String, String>{'Content-Type' => 'application/json', 'X-HTTP-Method-Override' => 'GET'},
                                                 queryParams, 120000,
                                                 JSON.serialize( new subrecipientQueryRequestBody( codes, legal_names, tins, duns_nos ) ), 'GRANTOR' );
    }
    public static HttpResponse postRetrieveSubrecipientAddressRecords( IntegUtahGrantsAPI.apiQueryParameters queryParams,
																	   Set<String> codes, Set<String> address_types ){
        return IntegUtahGrantsAPI.fetchResponse( 'subrecipient/address/query', 'POST',
                                                 new Map<String, String>{'Content-Type' => 'application/json', 'X-HTTP-Method-Override' => 'GET'},
                                                 queryParams, 120000,
                                                 JSON.serialize( new subrecipientAddressQueryRequestBody( codes, address_types ) ), 'GRANTOR' );
    }
    public static HttpResponse postRetrieveUnitRecords( IntegUtahGrantsAPI.apiQueryParameters queryParams,
														Set<String> departments, Set<Integer> fiscalyears, Set<String> codes, Set<String> names, Set<String> shortnames ){
        return IntegUtahGrantsAPI.fetchResponse( 'unit/query', 'POST',
                                                 new Map<String, String>{'Content-Type' => 'application/json', 'X-HTTP-Method-Override' => 'GET'},
                                                 queryParams, 120000,
                                                 JSON.serialize( new unitQueryRequestBody( departments, fiscalyears, codes, names, shortnames ) ), 'GRANTOR' );
    }
    public static HttpResponse postGAXTransmittalFile( IntegCGIAdv_GAX_Transmittal_Files GAX_TRANSMITTAL ){
        if( GAX_TRANSMITTAL == NULL ){ return NULL; }
        return IntegUtahGrantsAPI.fetchResponse( 'award/payment-request/gax/transmittal', 'POST',
                                                 new Map<String, String>{'Content-Type' => 'application/json'},
                                                 NULL, NULL, GAX_TRANSMITTAL.renderJSON(false), 'GRANTOR' );
    }
    public static HttpResponse postIETTransmittalFile( IntegCGIAdv_IET_Transmittal_Files IET_TRANSMITTAL ){
        if( IET_TRANSMITTAL == NULL ){ return NULL; }
        return IntegUtahGrantsAPI.fetchResponse( 'award/payment-request/iet/transmittal', 'POST',
                                                 new Map<String, String>{'Content-Type' => 'application/json'},
                                                 NULL, NULL, IET_TRANSMITTAL.renderJSON(false), 'GRANTOR' );
    }
    public static HttpResponse postProgramTransmittalFile( IntegCGIAdv_Program_Transmittal_Files PROGRAM_TRANSMITTAL ){
        if( PROGRAM_TRANSMITTAL == NULL ){ return NULL; }
        return IntegUtahGrantsAPI.fetchResponse( 'program/transmittal', 'POST',
                                                 new Map<String, String>{'Content-Type' => 'application/json'},
                                                 NULL, NULL, PROGRAM_TRANSMITTAL.renderJSON(false), 'GRANTOR' );
    }
    public static HttpResponse postProgramPhaseBudgetTransmittalFile( IntegCGIAdv_ProgPhasBud_Transmit_Files PROGRAM_PHASE_TRANSMITTAL ){
        if( PROGRAM_PHASE_TRANSMITTAL == NULL ){ return NULL; }
        return IntegUtahGrantsAPI.fetchResponse( 'program/phase-budget/transmittal', 'POST',
                                                 new Map<String, String>{'Content-Type' => 'application/json'},
                                                 NULL, NULL, PROGRAM_PHASE_TRANSMITTAL.renderJSON(false), 'GRANTOR' );
    }
    public static HttpResponse deleteDeleteGAX( IntegCGIAdv_GAX_DeleteFile GAX_DELETE ){
        if( GAX_DELETE == NULL ){ return NULL; }
        return IntegUtahGrantsAPI.fetchResponse( 'award/payment-request/gax', 'DELETE',
                                               	 new Map<String, String>{'Content-Type' => 'application/json'},
                                               	 NULL, NULL, GAX_DELETE.renderJSON(false), 'GRANTOR' );
    }
    public static HttpResponse deleteDeleteIET( IntegCGIAdv_IET_DeleteFile IET_DELETE ){
        if( IET_DELETE == NULL ){ return NULL; }
        return IntegUtahGrantsAPI.fetchResponse( 'award/payment-request/iet', 'DELETE',
                                                 new Map<String, String>{'Content-Type' => 'application/json'},
                                                 NULL, NULL, IET_DELETE.renderJSON(false), 'GRANTOR' );
    }
    public static HttpResponse deleteDeleteProgram( IntegCGIAdv_Program_DeleteFile PROGRAM_DELETE ){
        if( PROGRAM_DELETE == NULL ){ return NULL; }
        return IntegUtahGrantsAPI.fetchResponse( 'program', 'DELETE',
                                                 new Map<String, String>{'Content-Type' => 'application/json'},
                                                 NULL, NULL, PROGRAM_DELETE.renderJSON(false), 'GRANTOR' );
    }
    public static HttpResponse deleteDeleteProgramPhaseBudget( IntegCGIAdv_ProgPhaseBudget_DeleteFile PROGRAM_PHASE_DELETE ){
        if( PROGRAM_PHASE_DELETE == NULL ){ return NULL; }
        return IntegUtahGrantsAPI.fetchResponse( 'program/phase-budget', 'DELETE',
                                                 new Map<String, String>{'Content-Type' => 'application/json'},
                                                 NULL, NULL, PROGRAM_PHASE_DELETE.renderJSON(false), 'GRANTOR' );
    }
    public static HttpResponse getGAXStatus( IntegUtahGrantsAPI.statusQueryParameters queryParams ){
        if( queryParams.anyStatusValuesIsBlank() ){ throw new statusValuesBlankException(); }
        return IntegUtahGrantsAPI.fetchResponse( 'award/payment-request/gax/status', 'GET',
                                                 new Map<String, String>{'Content-Type' => 'application/json'},
                                                 queryParams, NULL, 'GRANTOR' );
    }
    public static HttpResponse getIETStatus( IntegUtahGrantsAPI.statusQueryParameters queryParams ){
        if( queryParams.anyStatusValuesIsBlank() ){ throw new statusValuesBlankException(); }
        return IntegUtahGrantsAPI.fetchResponse( 'award/payment-request/iet/status', 'GET',
                                                 new Map<String, String>{'Content-Type' => 'application/json'},
                                                 queryParams, NULL, 'GRANTOR' );
    }
    public static HttpResponse getGCAMStatus( IntegUtahGrantsAPI.statusQueryParameters queryParams ){
        if( queryParams.anyStatusValuesIsBlank() ){ throw new statusValuesBlankException(); }
        return IntegUtahGrantsAPI.fetchResponse( 'program/status', 'GET',
                                                 new Map<String, String>{'Content-Type' => 'application/json'},
                                                 queryParams, NULL, 'GRANTOR' );
    }
    // public static HttpResponse getProgramPhaseBudgetStatus( IntegUtahGrantsAPI.statusQueryParameters queryParams ){
    //     if( queryParams.anyStatusValuesIsBlank() ){ throw new statusValuesBlankException(); }
    //     return IntegUtahGrantsAPI.fetchResponse( 'program/phase-budget/status', 'GET',
    //                                              new Map<String, String>{'Content-Type' => 'application/json'},
    //                                              queryParams, NULL, 'GRANTOR' );
    // }
    // PRIVATE CLASSES
    private abstract class queryRequestBody{
        private String[] codes{get;set;}
        public queryRequestBody(){ this.codes = new String[]{}; }
        public queryRequestBody( Set<String> codes ){
            this();
            this.codes = codes != null ? new List<String>( Integ_CGIAdv_Utilities.dedupeSet( codes ) ) : new List<String>();
        }
    }
    private class apprQueryRequestBody extends queryRequestBody{
        private Integer[] fiscalyears{get;set;}
        private String[] names{get;set;}
        private String[] shortnames{get;set;}
        public apprQueryRequestBody( Set<Integer> fiscalyears, Set<String> codes, Set<String> names, Set<String> shortnames ){
            super( codes );
            this.fiscalyears = fiscalyears != null ? new List<Integer>( fiscalyears ) : new List<Integer>();
            this.names = names != null ? new List<String>( Integ_CGIAdv_Utilities.dedupeSet( names ) ) : new List<String>();
            this.shortnames = shortnames != null ? new List<String>( Integ_CGIAdv_Utilities.dedupeSet( shortnames ) ) : new List<String>();
        }
    }
    private class fundQueryRequestBody extends queryRequestBody{
        private Integer[] fiscalyears{get;set;}
        private String[] names{get;set;}
        private String[] shortnames{get;set;}
        public fundQueryRequestBody( Set<Integer> fiscalyears, Set<String> codes, Set<String> names, Set<String> shortnames ){
            super( codes );
            this.fiscalyears = fiscalyears != null ? new List<Integer>( fiscalyears ) : new List<Integer>();
            this.names = names != null ? new List<String>( Integ_CGIAdv_Utilities.dedupeSet( names ) ) : new List<String>();
            this.shortnames = shortnames != null ? new List<String>( Integ_CGIAdv_Utilities.dedupeSet( shortnames ) ) : new List<String>();
        }
    }
    private class fundingInferenceProfileQueryRequestBody extends queryRequestBody{
        private String[] departments{get;set;}
        private String[] names{get;set;}
        private String[] majorprograms{get;set;}
        public fundingInferenceProfileQueryRequestBody( Set<String> departments, Set<String> codes, Set<String> names, Set<String> majorprograms ){
            super( codes );
            this.departments = departments != null ? new List<String>( Integ_CGIAdv_Utilities.dedupeSet( departments ) ) : new List<String>();
            this.names = names != null ? new List<String>( Integ_CGIAdv_Utilities.dedupeSet( names ) ) : new List<String>();
            this.majorprograms = majorprograms != null ? new List<String>( Integ_CGIAdv_Utilities.dedupeSet( majorprograms ) ) : new List<String>();
        }
    }
    private class majorProgramQueryRequestBody extends queryRequestBody{
        private String[] departments{get;set;}
        private String[] names{get;set;}
        private String[] shortnames{get;set;}
        public majorProgramQueryRequestBody( Set<String> departments, Set<String> codes, Set<String> names, Set<String> shortnames ){
            super( codes );
            this.departments = departments != null ? new List<String>( Integ_CGIAdv_Utilities.dedupeSet( departments ) ) : new List<String>();
            this.names = names != null ? new List<String>( Integ_CGIAdv_Utilities.dedupeSet( names ) ) : new List<String>();
            this.shortnames = shortnames != null ? new List<String>( Integ_CGIAdv_Utilities.dedupeSet( shortnames ) ) : new List<String>();
        }
    }
    private class objQueryRequestBody extends queryRequestBody{
        private Integer[] fiscalyears{get;set;}
        private String[] names{get;set;}
        private String[] shortnames{get;set;}
        public objQueryRequestBody( Set<Integer> fiscalyears, Set<String> codes, Set<String> names, Set<String> shortnames ){
            super( codes );
            this.fiscalyears = fiscalyears != null ? new List<Integer>( fiscalyears ) : new List<Integer>();
            this.names = names != null ? new List<String>( Integ_CGIAdv_Utilities.dedupeSet( names ) ) : new List<String>();
            this.shortnames = shortnames != null ? new List<String>( Integ_CGIAdv_Utilities.dedupeSet( shortnames ) ) : new List<String>();
        }
    }
    private class programQueryRequestBody extends queryRequestBody{
        private String[] departments{get;set;}
        private String[] names{get;set;}
        private String[] shortnames{get;set;}
        public programQueryRequestBody( Set<String> departments, Set<String> codes, Set<String> names, Set<String> shortnames ){
            super( codes );
            this.departments = departments != null ? new List<String>( Integ_CGIAdv_Utilities.dedupeSet( departments ) ) : new List<String>();
            this.names = names != null ? new List<String>( Integ_CGIAdv_Utilities.dedupeSet( names ) ) : new List<String>();
            this.shortnames = shortnames != null ? new List<String>( Integ_CGIAdv_Utilities.dedupeSet( shortnames ) ) : new List<String>();
        }
    }
    private class programCategoryQueryRequestBody extends queryRequestBody{
        private String[] names{get;set;}
        private String[] shortnames{get;set;}
        public programCategoryQueryRequestBody( Set<String> codes, Set<String> names, Set<String> shortnames ){
            super( codes );
            this.names = names != null ? new List<String>( Integ_CGIAdv_Utilities.dedupeSet( names ) ) : new List<String>();
            this.shortnames = shortnames != null ? new List<String>( Integ_CGIAdv_Utilities.dedupeSet( shortnames ) ) : new List<String>();
        }
    }
    private class programClassQueryRequestBody extends queryRequestBody{
        private String[] names{get;set;}
        private String[] shortnames{get;set;}
        public programClassQueryRequestBody( Set<String> codes, Set<String> names, Set<String> shortnames ){
            super( codes );
            this.names = names != null ? new List<String>( Integ_CGIAdv_Utilities.dedupeSet( names ) ) : new List<String>();
            this.shortnames = shortnames != null ? new List<String>( Integ_CGIAdv_Utilities.dedupeSet( shortnames ) ) : new List<String>();
        }
    }
    private class programGroupQueryRequestBody extends queryRequestBody{
        private String[] departments{get;set;}
        private String[] names{get;set;}
        private String[] shortnames{get;set;}
        public programGroupQueryRequestBody( Set<String> departments, Set<String> codes, Set<String> names, Set<String> shortnames ){
            super( codes );
            this.departments = departments != null ? new List<String>( Integ_CGIAdv_Utilities.dedupeSet( departments ) ) : new List<String>();
            this.names = names != null ? new List<String>( Integ_CGIAdv_Utilities.dedupeSet( names ) ) : new List<String>();
            this.shortnames = shortnames != null ? new List<String>( Integ_CGIAdv_Utilities.dedupeSet( shortnames ) ) : new List<String>();
        }
    }
    private class programTypeQueryRequestBody extends queryRequestBody{
        private String[] departments{get;set;}
        private String[] names{get;set;}
        private String[] shortnames{get;set;}
        public programTypeQueryRequestBody( Set<String> departments, Set<String> codes, Set<String> names, Set<String> shortnames ){
            super( codes );
            this.departments = departments != null ? new List<String>( Integ_CGIAdv_Utilities.dedupeSet( departments ) ) : new List<String>();
            this.names = names != null ? new List<String>( Integ_CGIAdv_Utilities.dedupeSet( names ) ) : new List<String>();
            this.shortnames = shortnames != null ? new List<String>( Integ_CGIAdv_Utilities.dedupeSet( shortnames ) ) : new List<String>();
        }
    }
    private class subrecipientQueryRequestBody extends queryRequestBody{
        private String[] legal_names{get;set;}
        private String[] tins{get;set;}
        private String[] duns_nos{get;set;}
        public subrecipientQueryRequestBody( Set<String> codes, Set<String> legal_names, Set<String> tins, Set<String> duns_nos ){
            super( codes );
            this.legal_names = legal_names != null ? new List<String>( Integ_CGIAdv_Utilities.dedupeSet( legal_names ) ) : new List<String>();
            this.tins = tins != null ? new List<String>( Integ_CGIAdv_Utilities.dedupeSet( tins ) ) : new List<String>();
            this.duns_nos = duns_nos != null ? new List<String>( Integ_CGIAdv_Utilities.dedupeSet( duns_nos ) ) : new List<String>();
        }
    }
    private class subrecipientAddressQueryRequestBody extends queryRequestBody{
        private String[] address_types{get;set;}
        public subrecipientAddressQueryRequestBody( Set<String> codes, Set<String> address_types ){
            super( codes );
            this.address_types = address_types != null ? new List<String>( Integ_CGIAdv_Utilities.dedupeSet( address_types ) ) : new List<String>();
        }
    }
    private class UnitQueryRequestBody extends queryRequestBody{
        private String[] departments{get;set;}
        private Integer[] fiscalyears{get;set;}
        private String[] names{get;set;}
        private String[] shortnames{get;set;}
        public UnitQueryRequestBody( Set<String> departments, Set<Integer> fiscalyears, Set<String> codes, Set<String> names, Set<String> shortnames ){
            super( codes );
            this.departments = departments != null ? new List<String>( Integ_CGIAdv_Utilities.dedupeSet( departments ) ) : new List<String>();
            this.fiscalyears = fiscalyears != null ? new List<Integer>( fiscalyears ) : new List<Integer>();
            this.names = names != null ? new List<String>( Integ_CGIAdv_Utilities.dedupeSet( names ) ) : new List<String>();
            this.shortnames = shortnames != null ? new List<String>( Integ_CGIAdv_Utilities.dedupeSet( shortnames ) ) : new List<String>();
        }
    }
}