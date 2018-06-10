/**
* IntegUtahProgramRequestBatch is a scheduled job used to pull the Program records from the 
* Utah Grants API for local storage in Utah Grants.
*
* CHANGE HISTORY
* =========================================================================================
* Date              Name            Description
* Mar 13 2018       Ethan Hotz      Created
* Mar 30 2018       Ethan Hotz      Finished modifying
* =========================================================================================
*/
public with sharing class IntegUtahProgramRequestBatch implements Schedulable, Database.Batchable<Object>, Database.AllowsCallouts, Database.Stateful{
    // PUBLIC MEMBERS
    public PersistentBatchObject batchObject {get;set;}
    public static string className = 'IntegUtahProgramRequestBatch';
    private integer recordLimit = 10000;

    public IntegUtahProgramRequestBatch( PersistentBatchObject batchObject ){
        if( batchObject != null ){
            this.batchObject = batchObject;
        } else {
            this.batchObject = Integ_CGIAdv_Utilities.getDefaultBatchObject();
        }
    }
    /*  INTERFACE METHODS */
    // Required by "Schedulable" interface
    public void execute(SchedulableContext sc){
        database.executeBatch( new IntegUtahProgramRequestBatch(batchObject), 1000 );
    }

    // Required by "Database.Batchable" interface
    public List<Object> start( Database.BatchableContext BC ){ 
        List<Object> objList = fetchSizedBatch();
        if (objList == null) { throw new Integ_CGIAdv_Utilities.NullReferenceException('Error fetching data - Unknown ApplicationReadWriteMode'); }
        return objList;
    }

    // Required by "Database.Batchable" interface
    public void execute( Database.BatchableContext BC, List<Object> scope ){
        List<r_prog__c> finetObjList = new List<r_prog__c>();
        if( scope instanceof List<IntegUtahProgramRequestBatch.IntegUtahProgram> ) {
            for ( IntegUtahProgramRequestBatch.IntegUtahProgram finetObj : (List<IntegUtahProgramRequestBatch.IntegUtahProgram>) scope ) {
                r_prog__c obj = finetObj.createSFobject();
                if (obj.DEPT_CD__r == null || obj.PROG_CD__c == null) {
                    batchObject.addErrorMessage('DATA_OP','Error on object: ' + finetObj.toString());
                } else {
                    finetObjList.add(obj);
                }
            }
            
            Database.UpsertResult[] srList = Database.upsert(finetObjList, r_prog__c.Fields.ExternalFINETId__c, false);

            for (Integer i = 0; i < srList.size(); i++) {
                if (!srList[i].isSuccess()) {
                    for(Database.Error err : srList[i].getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Unit fields that affected this error: ' + err.getFields());
                        batchObject.addErrorMessage('UPSERT_OP', 'Class: IntegUtahProgramRequestBatch; Record#: ' + i + '; ' + err.getStatusCode() + ': ' + err.getMessage());
                    }
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
            Integ_CGIAdv_Utilities.sendErrorEmails(batchObject.errorMessages);
        }
    }

    public List<Object> fetchSizedBatch() { 
        // Get Read-only mode status
        ApplicationReadWriteMode mode = System.getApplicationReadWriteMode();
        String returnValue = '';
        List<IntegUtahProgramRequestBatch.IntegUtahProgram> wrapperClassList = new List<IntegUtahProgramRequestBatch.IntegUtahProgram>();
        if (mode == ApplicationReadWriteMode.READ_ONLY) { throw new Integ_CGIAdv_Utilities.ReadOnlyModeException('Read-only mode. Skipping callouts!'); } 
        else if (mode == ApplicationReadWriteMode.DEFAULT) {
            HTTPResponse r = null; 
            do{
                try {
                    IntegUtahGrantsAPI.apiQueryParameters aqp = new IntegUtahGrantsAPI.apiQueryParameters(recordLimit, batchObject.startDate, batchObject.endDate, null, null);
                    r = IntegUtahGrantorAPI.postRetrieveProgramRecords( aqp, batchObject.departmentCodes, new Set<String>(), new Set<String>(), new Set<String>());
                } catch (CalloutException ce) {
                    if (ce.getMessage() == 'Read timed out') {
                        System.debug('Timeout: ' + ce);
                        batchObject.fallthroughFlag = true; 
                        return new List<Object>(); 
                    } else if(ce.getMessage().contains('Exceeded maximum time allotted for callout')) {
                        System.debug('Other Callout Exception: ' + ce);
                        batchObject.addToInterval();
                        batchObject.setNewEndDate();
                        batchObject.fallthroughFlag = true;
                        return new List<Object>();
                    } else {
                        batchObject.addErrorMessage('CO_ERROR', ce.getMessage());
                        throw new Integ_CGIAdv_Utilities.FINETAPIException('CalloutException Error: ' + ce.getMessage());
                    }
                } catch (Exception e) {
                    batchObject.addErrorMessage('?', e.getMessage());
                    return null;
                }
                System.debug('StatusCode: ' + r.getStatusCode());
                if( r.getStatusCode() == 200 ){
                    System.debug('Heap size: ' + Limits.getHeapSize());
                    if ((Limits.getHeapSize()*3) > Limits.getLimitHeapSize()) { 
                        System.debug('Heap size overflow');
                        batchObject.addToInterval();
                        batchObject.setNewEndDate();
                        batchObject.fallthroughFlag = true;
                        return new List<Object>();
                    }
                    for(IntegUtahProgramRequestBatch.IntegUtahProgram jsonunit : (List<IntegUtahProgramRequestBatch.IntegUtahProgram>)json.deserialize(r.getbody(),List<IntegUtahProgramRequestBatch.IntegUtahProgram>.class) ){
                        wrapperClassList.add( jsonunit );
                    }
                    return wrapperClassList;
                }else if( r.getStatusCode() == 404 ){
                    batchObject.handle404(r.getBody());

                } else if (r.getStatusCode() == 500) {
                    throw new Integ_CGIAdv_Utilities.FINETAPIException('FINET API error');
                }
            }while(r != null && r.getStatusCode() != 200 && Limits.getCallouts() < Limits.getLimitCallouts() && batchObject.startDate != batchObject.absoluteEndDate);
            if (r == null) {
                batchObject.addErrorMessage('NULL_r', 'Null HTTP response');
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
        Database.executeBatch( new IntegUtahProgramRequestBatch(batchObject), Integ_CGIAdv_Utilities.batchSize );
    }

    
    private class IntegUtahProgram {
        public string PROG_NM {get;set;}
        public string DEPT_CD {get;set;}
        public string MJR_PROG_CD {get;set;}
        public string PROG_CD {get;set;}
        public integer ACT_FL {get;set;}
        public string PROG_SH_NM {get;set;}
        public integer ALW_BUD_FL {get;set;}
        public integer REIM_ELG_STA {get;set;}
        public string PCLS_CD {get;set;}
        public string PCAT_CD {get;set;}
        public string PGRP_CD {get;set;}
        public string PTYP_CD {get;set;}
        public integer SUSP_STA {get;set;}
        public string PROG_DSRC {get;set;}
        public string SITE_LOC_CD {get;set;}
        public string EFBGN_DT {get;set;}
        public string EFEND_DT {get;set;}
        public string SACCT_CD {get;set;}
        public string TBL_LAST_DT {get;set;} //Unused

        public r_prog__c createSFObject() {
            R_Prog__c rprog = new r_prog__c( DEPT_CD__r = new Account(Code__c = DEPT_CD),
                                             ACT_FL__c = (ACT_FL == 0) ? 'False' : 'True', //Picklist- 0 false, 1 true
                                             ALW_BUD_FL__c = (ALW_BUD_FL == 0) ? 'False' : 'True', //Picklist 
                                             EFBGN_DT__c = (EFBGN_DT == null) ? null : Date.valueOf(EFBGN_DT),
                                             EFEND_DT__c = (EFEND_DT == null) ? null : Date.valueOf(EFEND_DT),
                                           	 PROG_DSCR__c = PROG_DSRC,
                                             PROG_CD__c = PROG_CD,
                                             PROG_NM__c = PROG_NM,
                                             Name = PROG_CD,
                                             REIM_ELG_STA__c= (REIM_ELG_STA == 0) ? false : true, //bool
                                             SUSP_STA__c= (SUSP_STA == 1) ? 'Suspended for Reimbursement' : 'Allowed for Reimbursement', //Picklist: 1 - suspended, 2 - allowed
                                             PROG_SH_NM__c = PROG_SH_NM,
                                           	 SACCT_CD__c= SACCT_CD,
                                             ExternalFINETId__c = Integ_CGIAdv_Utilities.getExtId_Program(PROG_CD, DEPT_CD) );
            if( String.isNotBlank( DEPT_CD ) ){
                if( String.isNotBlank( MJR_PROG_CD ) ){
                    rprog.FINETMajorProgram__r = new r_mjr_prog__c(ExternalFINETId__c = Integ_CGIAdv_Utilities.getExtId_MajorProgram(MJR_PROG_CD, DEPT_CD));
                }
                if( String.isNotBlank( PGRP_CD ) ){
                    rprog.FINETProgramGroup__r = new r_pgrp__c(ExternalFINETId__c = Integ_CGIAdv_Utilities.getExtId_ProgramGroup(PGRP_CD, DEPT_CD));
                }
                if( String.isNotBlank( PTYP_CD ) ){
                    rprog.FINETProgramType__r = new r_ptype__c(ExternalFINETId__c = Integ_CGIAdv_Utilities.getExtId_ProgramType(PTYP_CD, DEPT_CD));
                }
            }
            if( String.isNotBlank( PCAT_CD ) ){
                rprog.FINETProgramCategory__r = new r_pcat__c(ExternalFINETId__c = Integ_CGIAdv_Utilities.getExtId_ProgramCategory(PCAT_CD));
            }
            if( String.isNotBlank( PCLS_CD ) ){
                rprog.FINETProgramClass__r = new r_pcls__c(ExternalFINETId__c = Integ_CGIAdv_Utilities.getExtId_ProgramClass(PCLS_CD));
            }
            return rprog;
        }

        public override string toString() {
            return 'DEPT_CD: ' + DEPT_CD + '; PROG_CD: ' + PROG_CD;
        }
    }

}