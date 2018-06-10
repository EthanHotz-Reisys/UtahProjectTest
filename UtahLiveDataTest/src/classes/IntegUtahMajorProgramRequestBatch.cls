/**
* IntegUtahMajorProgramRequestBatch is a scheduled job used to pull the Major Program records from the 
* Utah Grants API for local storage in Utah Grants.
*
* CHANGE HISTORY
* =========================================================================================
* Date              Name            Description
* Mar 13 2018       Ethan Hotz      Created
* Mar 30 2018       Ethan Hotz      Finished modifying
* =========================================================================================
*/
public with sharing class IntegUtahMajorProgramRequestBatch implements Schedulable, Database.Batchable<Object>, Database.AllowsCallouts, Database.Stateful{
    // PUBLIC MEMBERS
    public PersistentBatchObject batchObject {get;set;}
	public static string className = 'IntegUtahMajorProgramRequestBatch';
    private FINETBatchScheduleChild__c scheduleChild;
    private integer recordLimit = 10000;

    public IntegUtahMajorProgramRequestBatch( PersistentBatchObject batchObject ){
        if( batchObject != null ){
            this.batchObject = batchObject;
        } else {
            this.batchObject = Integ_CGIAdv_Utilities.getDefaultBatchObject();
        }
        
    }
    /*  INTERFACE METHODS */
    // Required by "Schedulable" interface
    public void execute(SchedulableContext sc){
        database.executeBatch( new IntegUtahMajorProgramRequestBatch(batchObject), Integ_CGIAdv_Utilities.batchSize );
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
        List<r_mjr_prog__c> finetObjList = new List<r_mjr_prog__c>();
        if( scope instanceof List<IntegUtahMajorProgramRequestBatch.IntegUtahMajorProgram> ) {
            for ( IntegUtahMajorProgramRequestBatch.IntegUtahMajorProgram finetObj : (List<IntegUtahMajorProgramRequestBatch.IntegUtahMajorProgram>) scope ) {
                r_mjr_prog__c obj = finetObj.createSFobject();
                if (obj.DEPT_CD__r == null || obj.MJR_PROG_CD__c == null) {
                    batchObject.addErrorMessage('DATA_OP','Error on object: ' + finetObj.toString());
                } else {
                    finetObjList.add(obj);
                }
            }
            
            Database.UpsertResult[] srList = Database.upsert(finetObjList, r_mjr_prog__c.Fields.ExternalFINETId__c, false);
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
        List<IntegUtahMajorProgramRequestBatch.IntegUtahMajorProgram> wrapperClassList = new List<IntegUtahMajorProgramRequestBatch.IntegUtahMajorProgram>();
        if (mode == ApplicationReadWriteMode.READ_ONLY) { throw new Integ_CGIAdv_Utilities.ReadOnlyModeException('Read-only mode. Skipping callouts!'); } 
        else if (mode == ApplicationReadWriteMode.DEFAULT) {
            HTTPResponse r = null; 
            do{
                try {
                    IntegUtahGrantsAPI.apiQueryParameters aqp = new IntegUtahGrantsAPI.apiQueryParameters(recordLimit, batchObject.startDate, batchObject.endDate, null, null);
                    r = IntegUtahGrantorAPI.postRetrieveMajorProgramRecords( aqp, batchObject.departmentCodes, new Set<String>(), new Set<String>(), new Set<String>());
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
                    for(IntegUtahMajorProgramRequestBatch.IntegUtahMajorProgram jsonunit : (List<IntegUtahMajorProgramRequestBatch.IntegUtahMajorProgram>)json.deserialize(r.getbody(),List<IntegUtahMajorProgramRequestBatch.IntegUtahMajorProgram>.class) ){
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
        Database.executeBatch( new IntegUtahMajorProgramRequestBatch(batchObject), Integ_CGIAdv_Utilities.batchSize );
    }

    
    private class IntegUtahMajorProgram {
        public Decimal ACT_FL {get;set;}
        public Decimal ALW_BUD_FL {get;set;}
        public string EFBGN_DT {get;set;}
        public string EFEND_DT {get;set;}
        public Decimal FED_APPR_SETP {get;set;}
        public string MJR_PROG_CD {get;set;}
        public string MJR_PROG_NM {get;set;}
        public Decimal REIM_BUD_STRU_CD {get;set;}
        public Decimal SUSP_STA {get;set;}
        public Decimal REIM_BAS_IND {get;set;}
        public string MJR_PROG_SH_NM {get;set;}
        public Decimal SPLT_IND {get;set;}
        public string DEPT_CD {get;set;}

        public r_mjr_prog__c createSFObject() {
            return new r_mjr_prog__c(
                DEPT_CD__r = new Account(Code__c = DEPT_CD),
                ACT_FL__c = ACT_FL,
                ALW_BUD_FL__c = ALW_BUD_FL,
                EffectiveFrom__c = (EFBGN_DT == null) ? null : Date.valueOf(EFBGN_DT), 
                EffectiveTo__c = (EFEND_DT == null) ? null : Date.valueOf(EFEND_DT),
                FED_APPR_SETP__c = FED_APPR_SETP,
                MJR_PROG_CD__c = MJR_PROG_CD,
                MJR_PROG_NM__c = MJR_PROG_NM,
                Name = MJR_PROG_CD,
                REIM_BUD_STRU_CD__c = REIM_BUD_STRU_CD,
                SUSP_STA__c = SUSP_STA,
                REIM_BAS_IND__c = REIM_BAS_IND,
                MJR_PROG_SH_NM__c = MJR_PROG_SH_NM,
                SPLT_IND__c = SPLT_IND,
                ExternalFINETId__c = Integ_CGIAdv_Utilities.getExtId_MajorProgram(MJR_PROG_CD, DEPT_CD)
                
            );
        }

        public override string toString() {
            return 'DEPT_CD: ' + DEPT_CD + '; MJR_PROG_CD: ' + MJR_PROG_CD;
        }
    }
}