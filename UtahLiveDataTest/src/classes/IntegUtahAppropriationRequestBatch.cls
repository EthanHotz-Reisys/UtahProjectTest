/**
* IntegUtahAppropriationRequestBatch is a scheduled job used to pull the Appropriation records from the 
* Utah Grants API for local storage in Utah Grants.
*
* CHANGE HISTORY
* =========================================================================================
* Date              Name            Description
* Mar 13 2018       Ethan Hotz      Created
* Mar 30 2018       Ethan Hotz      Finished modifying
* =========================================================================================
*/
public with sharing class IntegUtahAppropriationRequestBatch implements Schedulable, Database.Batchable<Object>, Database.AllowsCallouts, Database.Stateful{
    // PUBLIC MEMBERS
    public PersistentBatchObject batchObject {get;set;}
    public static string className = 'IntegUtahAppropriationRequestBatch';
    private FINETBatchScheduleChild__c scheduleChild;
    private integer recordLimit = 20000;

    public IntegUtahAppropriationRequestBatch( PersistentBatchObject batchObject ){
        if( batchObject != null ){
            this.batchObject = batchObject;
        } else {
            this.batchObject = Integ_CGIAdv_Utilities.getDefaultBatchObject();
        }
        
    }
    /*  INTERFACE METHODS */
    // Required by "Schedulable" interface
    public void execute(SchedulableContext sc){
        database.executeBatch( new IntegUtahAppropriationRequestBatch(batchObject), Integ_CGIAdv_Utilities.batchSize );
    }

    // Required by "Database.Batchable" interface
    public List<Object> start( Database.BatchableContext BC ){ 
        List<FINETBatchScheduleChild__c> childList = [select Log__c, Status__c, ErrorCount__c, SuccessCount__c, Name, FINETBatchScheduleParent__c 
                        from FINETBatchScheduleChild__c where Name =: className AND Status__c = 'Processing'];
        if (childList.size() != 1) { throw new Integ_CGIAdv_Utilities.BatchLogicException('Error: number of ' + className + ' child objects is: ' + childList.size()); }
        scheduleChild = childList[0];
        scheduleChild.Log__c = '';
        List<Object> objList = fetchSizedBatch();
        if (objList == null) { throw new Integ_CGIAdv_Utilities.NullReferenceException('Error fetching data - Unknown ApplicationReadWriteMode'); }
        return objList;
    }

    // Required by "Database.Batchable" interface
    public void execute( Database.BatchableContext BC, List<Object> scope ){
        List<r_appr__c> finetObjList = new List<r_appr__c>();
        if( scope instanceof List<IntegUtahAppropriationRequestBatch.IntegUtahAppropriation> ) {
            for ( IntegUtahAppropriationRequestBatch.IntegUtahAppropriation finetObj : (List<IntegUtahAppropriationRequestBatch.IntegUtahAppropriation>) scope ) {
                r_appr__c obj = finetObj.createSFobject();
                if (obj.APPR_CD__c == null || obj.FiscalYear__r == null) {
                    batchObject.addErrorMessage('DATA_OP','Error on object: ' + finetObj.toString());
                } else {
                    finetObjList.add(obj);
                }
            }
            
            Database.UpsertResult[] srList = Database.upsert(finetObjList, r_appr__c.Fields.ExternalFINETId__c, false);
            Double randomKey = Math.random();

            for (Integer i = 0; i < srList.size(); i++) {
                if (!srList[i].isSuccess()) {
                    for(Database.Error err : srList[i].getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Unit fields that affected this error: ' + err.getFields());
                        batchObject.addErrorMessage('UPSERT_OP', 'Class: ' + className + '; Record#: ' + i + '; ' + err.getStatusCode() + ': ' + err.getMessage());
                        batchObject.addError(randomKey); 
                    }
                } else { 
                    batchObject.addSuccess(randomKey);
                }
            }
        }   
    }

    // Required by "Database.Batchable" interface
    public void finish( Database.BatchableContext BC ){
        if (batchObject.endDate < batchObject.absoluteEndDate || batchObject.fallthroughFlag == true) {
            if(!Test.IsRunningTest()) {
                startNewBatch();
            }
        } else {
            batchObject.scheduleNextObjectBatch(scheduleChild);
        }
    }

    public List<Object> fetchSizedBatch() { 
        // Get Read-only mode status
        ApplicationReadWriteMode mode = System.getApplicationReadWriteMode();
        String returnValue = '';
        List<IntegUtahAppropriationRequestBatch.IntegUtahAppropriation> wrapperClassList = new List<IntegUtahAppropriationRequestBatch.IntegUtahAppropriation>();
        if (mode == ApplicationReadWriteMode.READ_ONLY) { throw new Integ_CGIAdv_Utilities.ReadOnlyModeException('Read-only mode. Skipping callouts!'); } 
        else if (mode == ApplicationReadWriteMode.DEFAULT) {
            HTTPResponse r = null; 
            do{
                try {
                    IntegUtahGrantsAPI.apiQueryParameters aqp = new IntegUtahGrantsAPI.apiQueryParameters(recordLimit, batchObject.startDate, batchObject.endDate, null, null);
                    r = IntegUtahGrantorAPI.postRetrieveApprRecords( aqp, batchObject.fiscalYears, new Set<String>(), new Set<String>(), new Set<String>());
                } catch (CalloutException ce) {
                    return batchObject.handleCalloutExceptions(ce, scheduleChild);
                } catch (Exception e) {
                    batchObject.addErrorMessage('?', e.getMessage());
                    batchObject.logErrors(scheduleChild);
                    return null;
                }
                if( r.getStatusCode() == 200 ){
                    if ((Limits.getHeapSize()*3) > Limits.getLimitHeapSize()) { 
                        System.debug('Heap size overflow');
                        batchObject.addToInterval();
                        batchObject.setNewEndDate();
                        batchObject.fallthroughFlag = true;
                        return new List<Object>();
                    }
                    for(IntegUtahAppropriationRequestBatch.IntegUtahAppropriation jsonunit : (List<IntegUtahAppropriationRequestBatch.IntegUtahAppropriation>)json.deserialize(r.getbody(),List<IntegUtahAppropriationRequestBatch.IntegUtahAppropriation>.class) ){
                        wrapperClassList.add( jsonunit );
                    }
                    return wrapperClassList;
                    
                }else if( r.getStatusCode() == 404 ){
                    batchObject.handle404(r.getBody());

                } else if (r.getStatusCode() == 500) {
                    batchObject.addErrorMessage('?',r.getBody());
                    batchObject.logErrors(scheduleChild);
                    throw new Integ_CGIAdv_Utilities.FINETAPIException('FINET API error');
                }
            }while(r != null && r.getStatusCode() != 200 && Limits.getCallouts() < Limits.getLimitCallouts() && batchObject.startDate != batchObject.absoluteEndDate);
            if (r == null) {
                batchObject.addErrorMessage('NULL_r', 'Null HTTP response');
                batchObject.logErrors(scheduleChild);
                throw new Integ_CGIAdv_Utilities.NullReferenceException('Null HTTP response');
            }
            if( Limits.getCallouts() == Limits.getLimitCallouts()){
                batchObject.fallthroughFlag = true;
            }
            return new List<Object>();
        }
        
        return null;
    }

    

    /* PRIVATE METHODS */
    private void startNewBatch() {
        if (batchObject.fallthroughFlag == false) {
            batchObject.setForNextBatch();
        } else {
            batchObject.fallthroughFlag = false;
        }
        Database.executeBatch( new IntegUtahAppropriationRequestBatch(batchObject), Integ_CGIAdv_Utilities.batchSize );
    }

    
    private class IntegUtahAppropriation {
        public string APPR_NM {get;set;}
        public string APPR_CD {get;set;}
        public integer FY {get;set;}
        
        public r_APPR__c createSFObject() {
            return new r_APPR__c(
                APPR_CD__c = APPR_CD,
                APPR_NM__c = APPR_NM,
                Name = APPR_CD,
                fiscalyear__r = new FiscalYear__c(FiscalYearNumber__c = String.valueOf(FY)),
                ExternalFINETId__c = Integ_CGIAdv_Utilities.getExtId_Appropriation(APPR_CD,String.valueOf(FY))
            );
            
        }

        public override String toString() {
            return 'APPR_NM: ' + APPR_NM + '; APPR_CD: ' + APPR_CD + '; FY: ' + FY;
        }
    }
}