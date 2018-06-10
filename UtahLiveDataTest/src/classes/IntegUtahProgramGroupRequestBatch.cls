/**
* IntegUtahProgramGroupRequestBatch is a scheduled job used to pull the Program Group records from the 
* Utah Grants API for local storage in Utah Grants.
*
* CHANGE HISTORY
* =========================================================================================
* Date              Name            Description
* Mar 13 2018       Ethan Hotz      Created
* Mar 30 2018       Ethan Hotz      Finished modifying
* =========================================================================================
*/
public with sharing class IntegUtahProgramGroupRequestBatch implements Schedulable, Database.Batchable<Object>, Database.AllowsCallouts, Database.Stateful{
    // PUBLIC MEMBERS
    public PersistentBatchObject batchObject {get;set;}
	public static string className = 'IntegUtahProgramGroupRequestBatch';
    private FINETBatchScheduleChild__c scheduleChild;
    private integer recordLimit = 10000;

    public IntegUtahProgramGroupRequestBatch( PersistentBatchObject batchObject ){
        if( batchObject != null ){
            this.batchObject = batchObject;
        } else {
            this.batchObject = Integ_CGIAdv_Utilities.getDefaultBatchObject();
        }
        
    }
    /*  INTERFACE METHODS */
    // Required by "Schedulable" interface
    public void execute(SchedulableContext sc){
        database.executeBatch( new IntegUtahProgramGroupRequestBatch(batchObject), Integ_CGIAdv_Utilities.batchSize );
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
        List<r_pgrp__c> finetObjList = new List<r_pgrp__c>();
        if( scope instanceof List<IntegUtahProgramGroupRequestBatch.IntegUtahProgramGroup> ) {
            for ( IntegUtahProgramGroupRequestBatch.IntegUtahProgramGroup finetObj : (List<IntegUtahProgramGroupRequestBatch.IntegUtahProgramGroup>) scope ) {
                r_pgrp__c obj = finetObj.createSFobject();
                if (obj.PGRP_CD__c == null || obj.DEPT_CD__r == null) {
                    batchObject.addErrorMessage('DATA_OP','Error on object: ' + finetObj.toString());
                } else {
                    finetObjList.add(obj);
                }
            }
            
            Database.UpsertResult[] srList = Database.upsert(finetObjList, r_pgrp__c.Fields.ExternalFINETId__c, false);
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
        List<IntegUtahProgramGroupRequestBatch.IntegUtahProgramGroup> wrapperClassList = new List<IntegUtahProgramGroupRequestBatch.IntegUtahProgramGroup>();
        if (mode == ApplicationReadWriteMode.READ_ONLY) { throw new Integ_CGIAdv_Utilities.ReadOnlyModeException('Read-only mode. Skipping callouts!'); } 
        else if (mode == ApplicationReadWriteMode.DEFAULT) {
            HTTPResponse r = null; 
            do{
                try {
                    IntegUtahGrantsAPI.apiQueryParameters aqp = new IntegUtahGrantsAPI.apiQueryParameters(recordLimit, batchObject.startDate, batchObject.endDate, null, null);
                    r = IntegUtahGrantorAPI.postRetrieveProgramGroupRecords( aqp, batchObject.departmentCodes, new Set<String>(), new Set<String>(), new Set<String>());
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
                    for(IntegUtahProgramGroupRequestBatch.IntegUtahProgramGroup jsonunit : (List<IntegUtahProgramGroupRequestBatch.IntegUtahProgramGroup>)json.deserialize(r.getbody(),List<IntegUtahProgramGroupRequestBatch.IntegUtahProgramGroup>.class) ){
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
        Database.executeBatch( new IntegUtahProgramGroupRequestBatch(batchObject), Integ_CGIAdv_Utilities.batchSize );
    }


    private class IntegUtahProgramGroup {
        public string PGRP_CD {get;set;}
        public string PGRP_NM {get;set;}
        public string PGRP_SH_NM {get;set;}
        public string DEPT_CD {get;set;}

        public r_PGRP__c createSFObject() {
            return new r_PGRP__c(
                PGRP_CD__c = PGRP_CD,
                PGRP_NM__c = PGRP_NM,
                Name = PGRP_NM,
                PGRP_SH_NM__c = PGRP_SH_NM,
                DEPT_CD__r = new Account(Code__c = DEPT_CD),
                ExternalFINETId__c = Integ_CGIAdv_Utilities.getExtId_ProgramGroup(PGRP_CD,DEPT_CD)
            );
        }

        public override string toString() {
            return 'PGRP_CD: ' + PGRP_CD + '; PGRP_NM: ' + PGRP_NM;
        }
    }
    
}