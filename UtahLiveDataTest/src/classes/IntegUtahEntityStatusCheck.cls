/**
* IntegUtahProgramStatusCheck is a scheduled job used to check the status of program records
* which have been submitted to the Grants API.
*
* CHANGE HISTORY
* =========================================================================================
* Date              Name            Description
* Mar 28 2018       Brian Mason     Created
* Apr 25 2018       Ethan Hotz      Finished modifying
* May 24 2018       Ethan Hotz      404 error count added, business hours bug fixed
* =========================================================================================
*/
public abstract class IntegUtahEntityStatusCheck implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    // PUBLIC MEMBERS
    // PUBLIC METHODS
    public class ReadOnlyModeException extends Exception {}
    // PRIVATE MEMBERS
    private List<Grants_API_Document_Status__c> docs {get;set;}
    private String query = 'SELECT ID, Needs_Status_Check__c, Grants_API_Document_Type__c, Grants_API_Document_Status__c,' + 
        'Grants_API_Document_Phase__c, Grants_API_DOC_ID__c, GovGrants_DOC_ID__c, Document_Transmission_Date__c, Last_Status_Check__c, '+ 
        'Grants_API_Document_Final__c, CreatedDate, Grants_API_Document_Dept_CD__c, ErrorCount__c FROM Grants_API_Document_Status__c WHERE ID IN :ids ';
    // possible values:
    // No Phase, Draft, Pending, Final, Historical (Final), Conflict Draft, Template
    private static final Set<String> reschedulePhases = new Set<String>{'NO PHASE','DRAFT','PENDING','CONFLICT DRAFT'};
    private List<String> errorList;
    private boolean businessHoursFlag;
    private static final Integer endOfBusinessHour = 18;
    private static final Integer startOfBusinessHour = 6;
    private static final Integer maxErrorCount = 5;

    // PUBLIC CONSTRUCTORS
    public IntegUtahEntityStatusCheck(){ 
        this.docs = null;
        errorList = new List<String>();
        businessHoursFlag = false;
    }
    public IntegUtahEntityStatusCheck( List<Grants_API_Document_Status__c> docs ){
        this();
        if( docs != null ){ this.docs = docs; }
    }
    /*  INTERFACE METHODS */
    // Required by "Database.Batchable" interface
    public Database.QueryLocator start( Database.BatchableContext BC ){
        
        // Get Read-only mode status
        ApplicationReadWriteMode mode = System.getApplicationReadWriteMode();
        if (mode == ApplicationReadWriteMode.READ_ONLY) {
            // Prevent the callout
            throw new ReadOnlyModeException('Read-only mode. Skipping callouts!');
        }else if (mode == ApplicationReadWriteMode.DEFAULT) {
            if( this.docs == null || this.docs.isEmpty() ){ System.abortJob( bc.getJobID() ); return null; }
        }
        businessHoursFlag = currentBusinessHours(System.now());
        Set<ID> ids = new Map<ID, Grants_API_Document_Status__c>( docs ).keySet();
        return Database.getQueryLocator( query );
    }
    // Required by "Database.Batchable" interface
    public void execute( Database.BatchableContext BC, List<Grants_API_Document_Status__c> docs ){
        if( docs != null && !docs.isEmpty() ){
            if (!businessHoursFlag) { //Job is outside of business hours - hold all jobs until the morning when the API is available again
                for (Grants_API_Document_Status__c doc : docs) {
                    doc.Needs_Status_Check__c = true;
                    DateTime lastStatusCheck = (doc.Last_Status_Check__c == null) ? System.now() : doc.Last_Status_Check__c;
                    Integer utahOffset = Timezone.getTimeZone(Integ_CGIAdv_Utilities.DefaultTimeZone()).getOffset(System.now()) / (60 * 60 * 1000);
                    Integer daysToAdd = (System.now().hour() > (endOfBusinessHour - utahOffset)) ? 1 : 0;
                    doc.Last_Status_Check__c = DateTime.newInstanceGMT(lastStatusCheck.year(), lastStatusCheck.month(), lastStatusCheck.addDays(daysToAdd).day(), startOfBusinessHour - utahOffset, 0, 0);
                }
                update docs;
                System.abortJob( bc.getJobID());
                return;
            }
            Set<ID> idsToProcess = new Map<ID, Grants_API_Document_Status__c>( docs ).keySet();
            List<ID> idsProcessed = new List<ID>();
            List<sObject> objectsToUpdate = new List<sObject>();
            for( Grants_API_Document_Status__c doc : docs ){
                if (doc.Grants_API_Document_Final__c == true) { continue; }
                HttpResponse resp = null;
                try {
                    String docId = null;
                    if (String.isNotBlank( doc.Grants_API_DOC_ID__c )) {
                        docId = doc.Grants_API_DOC_ID__c;
                    } else {
                        String fy = (doc.Document_Transmission_Date__c != null) ? 
                            String.valueOf(FiscalYearHelper.getFiscalYearShort(Date.valueOf(doc.Document_Transmission_Date__c))) :
                            String.valueOf(FiscalYearHelper.getFiscalYearShort(doc.CreatedDate.Date())); 
                        docId = fy;
                        doc.Grants_API_DOC_ID__c = fy;
                    }
                    resp = callAPI(doc.GovGrants_DOC_ID__c, doc.Grants_API_Document_Type__c, doc.Grants_API_Document_Dept_CD__c, docId, 1 );
                }catch ( CalloutException ce ) {
                    handleCalloutExceptions( ce, doc );
                    objectsToUpdate.add(doc);
                    continue;
                } catch ( Exception e ) {
                    errorList.add( 'Error while fetching program: ' + doc + '; Error: ' + e);
                    System.debug( 'Unknown Error: ' + e );
                    continue;
                }
                if( resp.getStatusCode() == 200 ){
                    try{
                        List<documentStatusResponse> progStatusResps = (List<documentStatusResponse>)json.deserialize( resp.getbody(), List<documentStatusResponse>.class );
                        if( progStatusResps != null && progStatusResps.size() > 0 ){
                            documentStatusResponse progStatusResp = progStatusResps[0];
                            doc.Needs_Status_Check__c = progStatusResp.DOC_PHASE_NM == null || reschedulePhases.contains( progStatusResp.DOC_PHASE_NM.toUpperCase() ) ;
                            if( String.isNotBlank(progStatusResp.DOC_ID) ) { doc.Grants_API_DOC_ID__c = progStatusResp.DOC_ID; }
                            doc.Grants_API_Document_Phase__c = progStatusResp.DOC_PHASE_NM;
                            doc.Grants_API_Document_Status__c = progStatusResp.DOC_STA_NM;
                            idsProcessed.add( doc.ID );
                            idsToProcess.remove( doc.ID );
                        }
                        if(progStatusResps.size() > 1 ){
                            errorList.add( 'Warning: Database has returned more than 1 document; it is recommended to check data and ensure correct program has been selected. For document: ' + doc); 
                        }

                        List<Grants_API_Document_Status_Detail__c> childList = 
                            [SELECT Active__c, Grants_API_Document_Item_ID__c, Grants_API_Document_Status__c 
                            FROM Grants_API_Document_Status_Detail__c WHERE Grants_API_Document_Status__c =: doc.Id AND Active__c = true];
                        for (Grants_API_Document_Status_Detail__c child : childList) { //Dynamically update objects based on SF ID in child objects
                            ID sfObjId = (ID)child.Grants_API_Document_Item_ID__c;
                            sObject sObj = sfObjId.getSObjectType().newSObject();
                            sObj.put('Id', sfObjId);
                            sObj.put('Grants_API_Document_Phase__c', doc.Grants_API_Document_Phase__c);
                            sObj.put('Grants_API_Document_Status__c', doc.Grants_API_Document_Status__c);
                            objectsToUpdate.add(sObj);
                        }
                        doc.Last_Status_Check__c = DateTime.now();
                        objectsToUpdate.add( doc );
                    }catch( Exception e ){
                        System.debug( 'Unknown Error: ' + e );
                    }
                }else if( resp.getStatusCode() == 404 ){
                    doc.Last_Status_Check__c = DateTime.now();
                    idsProcessed.add( doc.ID );
                    idsToProcess.remove( doc.ID );
                    objectsToUpdate.add( doc );
                    if (doc.ErrorCount__c >= maxErrorCount) {
                        doc.Needs_Status_Check__c = false;
                        errorList.add('Error: Program not found in FINET database. Document: ' + doc + 
                            '. Exceeded maximum number of 404s for this item, this item will no longer be checked until updated again.');
                    } else {
                        doc.Needs_Status_Check__c = true;
                        doc.ErrorCount__c++;
                        errorList.add( 'Error: Program not found in FINET database. Document: ' + doc);
                    }
                }else if ( resp.getStatusCode() == 500 ) {
                    // Stop all processing of records, queue an error email to system administrator and set Needs_Status_Check__c to true on impacted records.
                    // Error email should come from Finish method after all batches have run
                    errorList.add( 'Error: The FINET database experienced an error: ' + resp.getBody());
                    for (ID unprocessed : idsToProcess) {
                        objectsToUpdate.add(new Grants_API_Document_Status__c(
                            Id = unprocessed, Needs_Status_Check__c = true, Last_Status_Check__c = DateTime.now()
                        ));
                    }
                    break;
                }
            }
            Database.SaveResult[] srList = Database.update( objectsToUpdate, false );
            for( Integer i = 0; i < srList.size(); i++ ) {
                if( !srList[i].isSuccess() ) {
                    for( Database.Error err : srList[i].getErrors() ) {
                        System.debug( 'The following error has occurred.' );                    
                        System.debug( err.getStatusCode() + ': ' + err.getMessage() );
                        System.debug( 'Unit fields that affected this error: ' + err.getFields() );
                        errorList.add('Record#: ' + i + '; ' + err.getStatusCode() + ': ' + err.getMessage());
                    }
                }
            }
        }
    }
    // Required by "Database.Batchable" interface
    public void finish( Database.BatchableContext BC ){
        // send an error email if needed
        if (errorList.size() > 0) {
            Integ_CGIAdv_Utilities.sendErrorEmails(errorList);
        }
        
    }

    //Abstract method - child classes implement the API endpoint
    protected abstract HttpResponse callAPI(string GovGrants_DOC_ID, string Grants_API_Document_Type, string Grants_API_Document_Dept_CD, string Grants_API_DOC_ID, integer versionNumber);

    // PRIVATE METHODS
    private Grants_API_Document_Status__c handleCalloutExceptions(CalloutException ce, Grants_API_Document_Status__c doc ) {
        if (ce.getMessage() == 'Read timed out') {
            System.debug('Timeout: ' + ce);
            doc.Needs_Status_Check__c = true;
            doc.Last_Status_Check__c = DateTime.now();
            return doc; 
        } else if(ce.getMessage().contains('Exceeded maximum time allotted for callout')) {
            System.debug('Other Callout Exception: ' + ce);
            doc.Needs_Status_Check__c = true;
            doc.Last_Status_Check__c = DateTime.now();
            return doc;
        } else {
            System.debug('Exception: ' + ce);
            doc.Needs_Status_Check__c = true;
            doc.Last_Status_Check__c = DateTime.now();
            return doc;
        }
    }

    private boolean currentBusinessHours(DateTime gmtTime) {
        //Standardize all times to GMT
        Integer utahOffset = Timezone.getTimeZone(Integ_CGIAdv_Utilities.DefaultTimeZone()).getOffset(gmtTime) / (60 * 60 * 1000);
        DateTime gmtStart = DateTime.newInstanceGMT(gmtTime.year(), gmtTime.month(), gmtTime.day(), startOfBusinessHour - utahOffset,0,0);
        DateTime gmtEnd = DateTime.newInstanceGMT(gmtTime.year(), gmtTime.month(), gmtTime.day(), endOfBusinessHour - utahOffset,0,0);
        return !(gmtTime < gmtStart || gmtTime > gmtEnd);
    }

    // PRIVATE CLASSES
    private class documentStatusResponse{
        String DOC_DSCR {get;set;}
        String DOC_CD {get;set;}
        String DOC_DEPT_CD {get;set;}
        String DOC_ID {get;set;}
        Integer DOC_VERS_NO {get;set;}
        Integer DOC_PHASE_CD {get;set;}
        String DOC_PHASE_NM {get;set;}
        String DOC_STA_NM {get;set;}
        Integer DOC_STA_CD {get;set;}
    }
}