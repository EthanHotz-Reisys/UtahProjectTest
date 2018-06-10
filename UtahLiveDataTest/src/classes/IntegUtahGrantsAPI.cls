/**
* IntegUtahGrantsAPI is a utility class used in the IntegCGIAdv classes to provide connectivity to
* the API
*
* CHANGE HISTORY
* ==================================================================================================
* Date              Name                Description
* Mar 01 2018       Brian Mason         Created
* Mar 20 2018       Brian Mason         Removed '&' from end of http Query Parameters
* May 07 2018       Ethan Hotz          Added getCorrectIntegrationDetails() logic/implementation
* ==================================================================================================
*/
public class IntegUtahGrantsAPI{
    // PRIVATE CLASS MEMBERS 
    @TestVisible private static FINET_Integration__c integrationDetails;
    private static final Set<String> restVerbs = new set<String>{'DELETE','GET','HEAD','POST','PUT','TRACE'};
    private static final Set<String> integrationTypes = new Set<String>{'GRANTEE','GRANTOR'};
    // PRIVATE METHODS
    private static void fetchIntegrationDetails(){
        if( integrationDetails == NULL ){ 
            Boolean sandbox = [SELECT Id, IsSandbox FROM Organization LIMIT 1].IsSandbox;
            if (sandbox == null){ throw new Integ_CGIAdv_Utilities.NullReferenceException('Null reference: No organization object'); }
            integrationDetails = FINET_Integration__c.getInstance();
            if (integrationDetails == NULL || String.isBlank(integrationDetails.Grantor_Integration_Root_URL__c) || String.isBlank(integrationDetails.Grantee_Integration_Root_URL__c)) { 
                integrationDetails = getCorrectIntegrationDetails(sandbox);
                integrationDetails.SetupOwnerId = UserInfo.getOrganizationId();
                upsert integrationDetails;
                throw new Integ_CGIAdv_Utilities.NullReferenceException('FINET Integration Custom Setting was empty or incorrectly configured; it has been updated. Please try again.');
            }else if ( (!sandbox && (integrationDetails.Grantor_Integration_Root_URL__c.toLowerCase() != Integ_CGIAdv_Utilities.grantorProdURL.toLowerCase() ||
                integrationDetails.Grantee_Integration_Root_URL__c.toLowerCase() != Integ_CGIAdv_Utilities.granteeProdURL.toLowerCase())) ||
                      (sandbox && (integrationDetails.Grantor_Integration_Root_URL__c.toLowerCase() == Integ_CGIAdv_Utilities.grantorProdURL.toLowerCase() ||
                integrationDetails.Grantee_Integration_Root_URL__c.toLowerCase() == Integ_CGIAdv_Utilities.granteeProdURL.toLowerCase())) ) {
                integrationDetails = getCorrectIntegrationDetails(sandbox);
                upsert integrationDetails;
                throw new Integ_CGIAdv_Utilities.NullReferenceException('FINET Integration Custom Setting was empty or incorrectly configured; it has been updated. Please try again.');
            }
        }
    }
    private static FINET_Integration__c getCorrectIntegrationDetails(boolean sandbox) {
        FINET_Integration__c intDetails = new FINET_Integration__c(
            Grantor_Client_Secret__c = 'yi4MKTQVaQfMUuFNS4sz5RuRN2McsRir',
            Grantee_Client_Secret__c = 'yi4MKTQVaQfMUuFNS4sz5RuRN2McsRir',
            Grantor_Client_ID__c = 'R7fkyIp7LDk6rw3eimACZrfnxFSCevTF',
            Grantee_Client_ID__c = 'R7fkyIp7LDk6rw3eimACZrfnxFSCevTF'
        );
        intDetails.Grantor_Integration_Root_URL__c = sandbox ? Integ_CGIAdv_Utilities.grantorDevURL : Integ_CGIAdv_Utilities.grantorProdURL;
        intDetails.Grantee_Integration_Root_URL__c = sandbox ? Integ_CGIAdv_Utilities.granteeDevURL : Integ_CGIAdv_Utilities.granteeProdURL;
        return intDetails;
    }
    private static HttpRequest createRequest( String endPoint, String restVerb,
                                              Map<String, String> requestHeaders,
                                              httpQueryParameters queryParams,
                                              Integer timeout, String GrantorOrGranteeAPI ){
        
        HttpRequest request = NULL;
        if( String.isNotBlank( restVerb ) && String.isNotBlank( endPoint ) ){ restVerb = restVerb.toUpperCase(); }else{ return request; }
        if( String.isNotBlank( GrantorOrGranteeAPI ) ){ GrantorOrGranteeAPI = GrantorOrGranteeAPI.toUpperCase(); } else{ return request; }
        if( integrationDetails == NULL ){ fetchIntegrationDetails(); }
        if( restVerbs.contains( restVerb ) && integrationTypes.contains( GrantorOrGranteeAPI ) ){
            String httpQueryParams = queryParams != NULL ? queryParams.toParameterString() : '';
            request = new HttpRequest();
            System.debug('GrantsAPICheck: ' + (String)integrationDetails.get( GrantorOrGranteeAPI + '_Integration_Root_URL__c') + endPoint + httpQueryParams);
            request.setEndpoint( (String)integrationDetails.get( GrantorOrGranteeAPI + '_Integration_Root_URL__c') + endPoint + httpQueryParams );
            request.setMethod( restVerb );
            request.setHeader('client_id', (String)integrationDetails.get( GrantorOrGranteeAPI + '_Client_ID__c') );
            request.setHeader('client_secret', (String)integrationDetails.get( GrantorOrGranteeAPI + '_Client_Secret__c') );
            for( String header : requestHeaders.keySet() ){
                request.setHeader( header, requestHeaders.get( header ) );
            }
            if( timeout > -1 && timeout < 120001 ){ request.setTimeout( timeout ); }
        }
        return request;
    }
    private static HttpRequest createRequest( String endPoint, String restVerb,
                                             Map<String, String> requestHeaders,
                                             httpQueryParameters queryParams,
                                             Integer timeout, String body, String GrantorOrGranteeAPI ){
        HttpRequest request = createRequest( endPoint, restVerb, requestHeaders, queryParams, timeout, GrantorOrGranteeAPI );
        if( request != NULL && String.isNotBlank( body ) ){ request.setBody( body ); }
        System.debug('GrantsAPIBody: ' + body);
        return request;
    }
/*
    private static HttpRequest createRequest( String endPoint, String restVerb, Map<String, String> requestHeaders, httpQueryParameters queryParams,
                                              Integer timeout, Blob body, String GrantorOrGranteeAPI ){
        HttpRequest request = createRequest( endPoint, restVerb, requestHeaders, queryParams, timeout, GrantorOrGranteeAPI );
        if( request != NULL && body != NULL ){ request.setBodyAsBlob( body ); }
        return request;
    }
    private static HttpRequest createRequest( String endPoint, String restVerb, Map<String, String> requestHeaders, httpQueryParameters queryParams,
                                              Integer timeout, Dom.Document body, String GrantorOrGranteeAPI ){
        HttpRequest request = createRequest( endPoint, restVerb, requestHeaders, queryParams, timeout, GrantorOrGranteeAPI );
        if( request != NULL && body != NULL ){ request.setBodyDocument( body ); }
        return request;
    }
*/
    // PUBLIC METHODS
    public static HttpResponse fetchResponse( String endPoint, String restVerb, Map<String, String> requestHeaders, httpQueryParameters queryParams,
                                              Integer timeout, String GrantorOrGranteeAPI ){
        return new http().send( createRequest( endPoint, restVerb, requestHeaders, queryParams, timeout, GrantorOrGranteeAPI ) );
    }
    public static HttpResponse fetchResponse( String endPoint, String restVerb, Map<String, String> requestHeaders, httpQueryParameters queryParams,
                                              Integer timeout, String body, String GrantorOrGranteeAPI ){
        return new http().send( createRequest( endPoint, restVerb, requestHeaders, queryParams, timeout, body, GrantorOrGranteeAPI ) );
    }
/*
    public static HttpResponse fetchResponse( String endPoint, String restVerb, Map<String, String> requestHeaders, httpQueryParameters queryParams,
                                              Integer timeout, Blob body, String GrantorOrGranteeAPI ){
        return new http().send( createRequest( endPoint, restVerb, requestHeaders, queryParams, timeout, body, GrantorOrGranteeAPI ) );
    }
    public static HttpResponse fetchResponse( String endPoint, String restVerb, Map<String, String> requestHeaders, httpQueryParameters queryParams,
                                              Integer timeout, Dom.Document body, String GrantorOrGranteeAPI ){
        return new http().send( createRequest( endPoint, restVerb, requestHeaders, queryParams, timeout, body, GrantorOrGranteeAPI ) );
    }
*/
    // PUBLIC CLASSES
    public class apiQueryParameters extends httpQueryParameters{
        // PUBLIC MEMBERS
        public Integer max{get;set;}
        public Long beginDate{get;set;}
        public Long endDate{get;set;}
        public Long effBeginDate{get;set;}
        public Long effEndDate{get;set;}
        // PUBLIC CONSTRUCTORS
        public apiQueryParameters(){
            this.max = null;
            this.beginDate = null;
            this.endDate = null;
            this.effBeginDate = null;
            this.effEndDate = null;
        }
        public apiQueryParameters( Integer max, DateTime beginDateGMT, DateTime endDateGMT, DateTime effBeginDateGMT, DateTime effEndDateGMT ){
            this();
            this.max = max;
            this.beginDate = (beginDateGMT == null) ? null : beginDateGMT.getTime();
            this.endDate = (endDateGMT == null) ? null : endDateGMT.getTime();
            this.effBeginDate = (effBeginDateGMT == null) ? null : effBeginDateGMT.getTime();
            this.effEndDate = (effEndDateGMT == null) ? null : effEndDateGMT.getTime();
        }
        // PUBLIC METHODS
        public override String toParameterString(){
            String httpQueryParams = '';
            httpQueryParams += max != null ? 'max=' + EncodingUtil.urlEncode( String.valueOf( max ), 'UTF-8' ) + '&': '';
            httpQueryParams += beginDate != null ? 'begindate=' + EncodingUtil.urlEncode( String.valueOf( beginDate ), 'UTF-8' ) + '&' : '';
            httpQueryParams += endDate != null ? 'enddate=' + EncodingUtil.urlEncode( String.valueOf( endDate ), 'UTF-8' ) + '&' : '';
            httpQueryParams += effBeginDate != null ? 'effbegindate=' + EncodingUtil.urlEncode( String.valueOf( effBeginDate ), 'UTF-8' ) + '&' : '';
            httpQueryParams += effEndDate != null ? 'effenddate=' + EncodingUtil.urlEncode( String.valueOf( effEndDate ), 'UTF-8' ) : '';
            if( String.isNotEmpty( httpQueryParams ) ) {
                httpQueryParams = httpQueryParams.removeEnd('&');
                httpQueryParams = '?' + httpQueryParams;
            }
            return httpQueryParams;
        }
    }
    public class statusQueryParameters extends httpQueryParameters{
        // PUBLIC MEMBERS
        public String docDscr{get;set;}
        public String docCd{get;set;}
        public String docDeptCd{get;set;}
        public String docId{get;set;}
        public Integer docVersNo{get;set;}
        // PUBLIC CONSTRUCTORS
        public statusQueryParameters(){
            this.docDscr = '';
            this.docCd = '';
            this.docDeptCd = '';
            this.docId = '';
            this.docVersNo = NULL;
        }
        public statusQueryParameters( String docDscr, String docCd, String docDeptCd, String docId, Integer docVersNo ){
            this();
            if( String.isNotBlank( docDscr ) ){ this.docDscr = docDscr; }
            if( String.isNotBlank( docCd ) ){ this.docCd = docCd; }
            if( String.isNotBlank( docDeptCd ) ){ this.docDeptCd = docDeptCd; }
            if( String.isNotBlank( docId ) ){ this.docId = docId; }
            if( docVersNo != NULL  ){ this.docVersNo = docVersNo; }
        }
        // PUBLIC METHODS
        public Boolean anyStatusValuesIsBlank(){
            return String.isblank( this.docDscr ) || String.isblank( this.docCd ) || String.isblank( this.docDeptCd ) || 
               /*String.isblank( this.docId ) ||*/ this.docVersNo == null;
        }
        public override String toParameterString(){
            String httpQueryParams = '';
            httpQueryParams += docDscr != null ? 'docdscr=' + EncodingUtil.urlEncode( docDscr, 'UTF-8' ) + '&': '';
            httpQueryParams += docCd != null ? 'doccd=' + EncodingUtil.urlEncode( docCd, 'UTF-8' ) + '&' : '';
            httpQueryParams += docDeptCd != null ? 'docdeptcd=' + EncodingUtil.urlEncode( docDeptCd, 'UTF-8' ) + '&' : '';
            httpQueryParams += docId != null ? 'docid=' + EncodingUtil.urlEncode( docId, 'UTF-8' ) + '&' : '';
            httpQueryParams += docVersNo != null ? 'docversno=' + EncodingUtil.urlEncode( String.valueOf( docVersNo ), 'UTF-8' ) : '';
            if( String.isNotEmpty( httpQueryParams ) ) {
                httpQueryParams = httpQueryParams.removeEnd('&');
                httpQueryParams = '?' + httpQueryParams;
            }
            return httpQueryParams;
        }
    }
    public class GrantsAPIDocumentStatus{
        // PUBLIC MEMBERS
        public Grants_API_Document_Status__c gads {get;set;}
        public Set<ID> itemIDs {get;private set;}
        // PUBLIC CONSTRUCTOR
        public GrantsAPIDocumentStatus( String GovGrants_DOC_ID, String Grants_API_Document_Type, String Grants_API_Document_Dept_CD ){
            Boolean validGADTFound = FALSE;
            if( String.isNotBlank( Grants_API_Document_Type ) ){
                for( Schema.PicklistEntry ple : Grants_API_Document_Status__c.Grants_API_Document_Type__c.getDescribe().getPicklistValues() ){
                    if( Grants_API_Document_Type == ple.getValue() ){ validGADTFound = TRUE; }
                }
            }
            if( String.isNotBlank( GovGrants_DOC_ID ) && String.isNotBlank( Grants_API_Document_Dept_CD ) && validGADTFound ){
                gads = new Grants_API_Document_Status__c( GovGrants_DOC_ID__c = GovGrants_DOC_ID,
                                                          Grants_API_Document_Type__c = Grants_API_Document_Type,
                                                          Grants_API_Document_Dept_CD__c = Grants_API_Document_Dept_CD,
                                                          Needs_Status_Check__c = TRUE );
                itemIDs = new Set<ID>();
            }else{ throw new Integ_CGIAdv_Utilities.NullReferenceException( 'GovGrants_DOC_ID, Grants_API_Document_Type and Grants_API_Document_Dept_CD are required values'); }
        }
        public GrantsAPIDocumentStatus( String GovGrants_DOC_ID, String Grants_API_Document_Type, String Grants_API_Document_Dept_CD, Set<ID> newItemIDs ){
            this( GovGrants_DOC_ID, Grants_API_Document_Type, Grants_API_Document_Dept_CD );
            if( newItemIDs != null ){ addItemIDs( newItemIDs );
            }else{ throw new Integ_CGIAdv_Utilities.NullReferenceException( 'itemIDs are required values and cannot be null or empty' ); }    
        }
        // PUBLIC METHODS
        public void addItemID( ID itemID ){
            if( itemID != null && verifyObjectFields( itemID ) ){ itemIDs.add( itemID );
            }else{ throw new Integ_CGIAdv_Utilities.NullReferenceException( 'itemID is a required value and cannot be null or empty' ); } 
        }
        public void addItemIDs( Set<ID> newItemIDs ){
            Set<ID> idsToAdd = new Set<ID>();
            if( newItemIDs != null ){
                for( ID itemID : newItemIDs ){ if( verifyObjectFields( itemID ) ){ idsToAdd.add( itemID ); } }
                itemIDs.addAll( idsToAdd );
            }else{ throw new Integ_CGIAdv_Utilities.NullReferenceException( 'itemIDs are required values and cannot be null' ); } 
        }
        public Boolean removeItemID( ID itemIDtoRemove ){
            Boolean itemRemoved = FALSE;
            if( itemIDtoRemove != null ){ itemRemoved = itemIDs.remove( itemIDtoRemove ); }
            return itemRemoved;
        }
        public Boolean removeItemIDs( Set<ID> itemIDstoRemove ){
            Boolean setChanged = FALSE;
            if( itemIDstoRemove != null ){ for( ID itemID : itemIDstoRemove ){ if( removeItemID( itemID ) ){ setChanged = TRUE; } } }
            return setChanged;
        }
        public Grants_API_Document_Status__c insertParent( DateTime Document_Transmission_Date, String JSONDoc ){
            if( Document_Transmission_Date != null && String.isNotBlank( JSONDoc ) ){
                gads.Document_Transmission_Date__c = Document_Transmission_Date;
                gads.Last_Status_Check__c = Document_Transmission_Date;
                gads.Document_Transmission_Date_in_MS__c = Document_Transmission_Date.getTime();
                insert gads;
                insert new Attachment( parentid = gads.ID, Body = Blob.valueOf( JSONDoc ), Name = gads.GovGrants_DOC_ID__c + '.json' );
                return gads;
            }else{ throw new Integ_CGIAdv_Utilities.NullReferenceException( 'Document_Transmission_Date and JSONDoc are required values and cannot be null or empty' ); }
        }
        public List<sObject> insertRecords( ){
            if( gads.ID == null ){ throw new Integ_CGIAdv_Utilities.NullReferenceException( 'Grants API Document Status record must be inserted first when using this method.\n' +
                                                                                            'Please call "insertParent" first or call "insertRecords(DateTime Document_Transmission_Date, String JSONDoc)".'); }
            return processItemIDsToRecords();
        }
        public List<sObject> insertRecords( DateTime Document_Transmission_Date, String JSONDoc ){
            if( gads.ID == null && !itemIDs.isEmpty() ){ insertParent( Document_Transmission_Date, JSONDoc ); }
            return processItemIDsToRecords();
        }
        // PRIVATE METHODS
        private Boolean verifyObjectFields( ID idToCheck ){
            Boolean objectHasFields = FALSE;
            if( String.isNotBlank( idToCheck ) ){
                Map<String, Schema.SObjectField> fieldMap = idToCheck.getSobjectType().getDescribe().fields.getMap();
                if( fieldMap.containsKey( 'grants_api_document_phase__c' ) && fieldMap.containsKey( 'grants_api_document_status__c' ) &&
                    fieldMap.get( 'grants_api_document_phase__c' ).getDescribe().getType() == Schema.DisplayType.Picklist &&
                    fieldMap.get( 'grants_api_document_status__c' ).getDescribe().getType() == Schema.DisplayType.Picklist ){ objectHasFields = TRUE; }
                else{ throw new Integ_CGIAdv_Utilities.NullReferenceException( idToCheck.getSobjectType() + 
                                                                              ' does not have grants_api_document_phase__c or grants_api_document_status__c as a field' ); } 
            }
            return objectHasFields;
        }
        private List<sObject> processItemIDsToRecords(){
            if( !itemIDs.isEmpty() ){
                List<sObject> recs = new List<sObject>();
                for( ID itemID : itemIDs ){
                    recs.add( new Grants_API_Document_Status_Detail__c( Grants_API_Document_Status__c = gads.ID, 
                                                                        Active__c = TRUE, 
                                                                        Grants_API_Document_Item_ID__c = itemID ) );
                }
                insert recs;
                recs.add( gads );
                return recs;
            }else{ throw new Integ_CGIAdv_Utilities.NullReferenceException( 'itemIDs are required values and cannot be null or empty' ); } 
        } 
    }
    // PRIVATE CLASSES
    public abstract class httpQueryParameters{
        // PUBLIC METHODS
        public abstract string toParameterString();
    }
    
}