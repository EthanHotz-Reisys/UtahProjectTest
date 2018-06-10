/**
* IntegUtahVendorRequestBatch is a scheduled job used to pull the subrecipient records from the 
* Utah Grants API for local storage in Utah Grants.
*
* CHANGE HISTORY
* =========================================================================================
* Date              Name            Description
* Mar 13 2018       Ethan Hotz      Created
* Mar 30 2018       Ethan Hotz      Finished modifying
* =========================================================================================
*/
public with sharing class IntegUtahVendorRequestBatch implements Schedulable, Database.Batchable<Object>, Database.AllowsCallouts, Database.Stateful{
    // PUBLIC MEMBERS
    public PersistentBatchObject batchObject {get;set;}
	public static string className = 'IntegUtahVendorRequestBatch';
    private FINETBatchScheduleChild__c scheduleChild;
    private integer recordLimit = 50000;


    public IntegUtahVendorRequestBatch( PersistentBatchObject batchObject ){
        if( batchObject != null ){
            this.batchObject = batchObject;
        } else {
            this.batchObject = Integ_CGIAdv_Utilities.getDefaultBatchObject();
        }
        
    }
    /*  INTERFACE METHODS */
    // Required by "Schedulable" interface
    public void execute(SchedulableContext sc){
        database.executeBatch( new IntegUtahVendorRequestBatch(batchObject), Integ_CGIAdv_Utilities.batchSize );
    }

    // Required by "Database.Batchable" interface
    public List<Object> start( Database.BatchableContext BC ){ 
        List<FINETBatchScheduleChild__c> childList = [select Log__c, Status__c, ErrorCount__c, SuccessCount__c, Name, FINETBatchScheduleParent__c 
                        from FINETBatchScheduleChild__c where Name =: className AND Status__c = 'Processing'];
        if (childList.size() != 1) { throw new Integ_CGIAdv_Utilities.BatchLogicException('Error: number of ' + className + ' child objects is: ' + childList.size()); }
        scheduleChild = childList[0];
        scheduleChild.Log__c = '';
        List<Object> objList = fetchSizedBatch();
        if (objList == null) { throw new Integ_CGIAdv_Utilities.NullReferenceException('Error fetching data - Unknown ApplicationReadWriteMode');}
        return objList;
    }

    // Required by "Database.Batchable" interface
    public void execute( Database.BatchableContext BC, List<Object> scope ){
        List<r_vend_cust__c> finetObjList = new List<r_vend_cust__c>();
        if( scope instanceof List<IntegUtahVendorRequestBatch.IntegUtahVendor> ) {
            for ( IntegUtahVendorRequestBatch.IntegUtahVendor finetObj : (List<IntegUtahVendorRequestBatch.IntegUtahVendor>) scope ) {
                r_vend_cust__c obj = finetObj.createSFobject();
                if (obj.VEND_CUST_CD__c == null) {
                    batchObject.addErrorMessage('DATA_OP','Error on object: ' + finetObj.toString());
                } else {
                    finetObjList.add(obj);
                }
            }
            
            Database.UpsertResult[] srList = Database.upsert(finetObjList, r_vend_cust__c.Fields.vend_cust_cd__c, false);
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
        List<IntegUtahVendorRequestBatch.IntegUtahVendor> wrapperClassList = new List<IntegUtahVendorRequestBatch.IntegUtahVendor>();

        if (mode == ApplicationReadWriteMode.READ_ONLY) { throw new Integ_CGIAdv_Utilities.ReadOnlyModeException('Read-only mode. Skipping callouts!'); } 
        else if (mode == ApplicationReadWriteMode.DEFAULT) {
            HTTPResponse r = null; 
            do{
                try {
                    IntegUtahGrantsAPI.apiQueryParameters aqp = new IntegUtahGrantsAPI.apiQueryParameters(recordLimit, batchObject.startDate, batchObject.endDate, null, null);
                    r = IntegUtahGrantorAPI.postRetrieveSubrecipientRecords( aqp, new Set<String>(), new Set<String>(), new Set<String>(), new Set<String>());
                } catch (CalloutException ce) {
                    return batchObject.handleCalloutExceptions(ce, scheduleChild);
                } catch (Exception e) {
                    System.debug('Unknown Error: ' + e);
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
                    for(IntegUtahVendorRequestBatch.IntegUtahVendor jsonunit : (List<IntegUtahVendorRequestBatch.IntegUtahVendor>)json.deserialize(r.getbody(),List<IntegUtahVendorRequestBatch.IntegUtahVendor>.class) ){
                        wrapperClassList.add( jsonunit );
                    }
                    return wrapperClassList;
                    
                }else if( r.getStatusCode() == 404 ){
                    batchObject.handle404(r.getBody());

                } else if (r.getStatusCode() == 500) {
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
        Database.executeBatch( new IntegUtahVendorRequestBatch(batchObject), Integ_CGIAdv_Utilities.batchSize );
    }

	private class IntegUtahVendor {
		public string VEND_CUST_CD {get;set;}
        public string LGL_NM {get;set;}
        public string TIN {get;set;}
        public string DUNS_NO {get;set;}

		public r_vend_cust__c createSFobject() {
			return new r_vend_cust__c(
				VEND_CUST_CD__c = VEND_CUST_CD,
                LGL_NM__c = LGL_NM,
                TIN__c = TIN,
                DUNS_NO__c = DUNS_NO
			);
		}

		public override string toString() {
			return 'VEND_CUST_CD: ' + VEND_CUST_CD + '; LGL_NM: ' + LGL_NM + '; DUNS_NO: ' + DUNS_NO + '; TIN' + TIN;
		}

	}

}