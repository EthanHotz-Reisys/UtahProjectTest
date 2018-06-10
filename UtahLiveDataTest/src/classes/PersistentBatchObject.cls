public with sharing class PersistentBatchObject {
    // PUBLIC MEMBERS 
    public DateTime startDate {get; private set;}
    public DateTime endDate {get; private set;}
    public DateTime absoluteEndDate {get; private set;}
    private Decimal interval {get;set;}
    public List<string> errorMessages {get; private set;}
    private Map<string,string> errorMap {get;set;}
    public boolean fallthroughFlag {get;set;}
    public Set<string> departmentCodes {
        get {
            if (departmentCodes == null) {
                departmentCodes = Integ_CGIAdv_Utilities.getDepartmentCodes();
            }
            return departmentCodes;
        }
        private set;
    }
    public Set<Integer> fiscalYears {
        get {
            if (fiscalYears == null) {
                fiscalYears = Integ_CGIAdv_Utilities.getFiscalYears();
            }
            return fiscalYears;
        }
        private set;
    }
    private integer stuckCounter {get;set;}
    public Map<Double,Integer> errorCount {get; private set;}
    public Map<Double,Integer> successCount {get; private set;}

    public PersistentBatchObject(DateTime startDate, DateTime endDate, DateTime absoluteEnd, Set<string> deptCodes) {
        this.startDate = DateTime.newInstance(truncateMilliseconds(startDate.getTime()).longValue());
        this.endDate = DateTime.newInstance(truncateMilliseconds(endDate.getTime()).longValue());
        this.absoluteEndDate = DateTime.newInstance(truncateMilliseconds(absoluteEnd.getTime()).longValue());
        interval = truncateMilliseconds(Decimal.valueOf(endDate.getTime()) - Decimal.valueOf(startDate.getTime()));
        fallthroughFlag = false; 
        errorMessages = new List<string>();
        stuckCounter = 0;
        errorCount = new Map<Double,Integer>();
        successCount = new Map<Double,Integer>();

        errorMap = new Map<string,string>();
        errorMap.put('DATA_OP', 'Data integrity error');
        errorMap.put('UPSERT_OP', 'Database operation error');
        errorMap.put('NULL_r', 'HTTP response is null - error getting FINET data');
        errorMap.put('CO_ERROR', 'CalloutException - hit system limits while getting data.');
        errorMap.put('?', 'Unknown Error');

        //Used for running program batch when new departments added
        if (deptCodes != null) { departmentCodes = deptCodes; }
    }
    // PUBLIC METHODS
    public PersistentBatchObject setForNextBatch(){
        if (fallthroughFlag == true) return this;
        if( this.interval != null ){
            DateTime successfulEndDate = this.endDate;
            widenInterval();
            setNewEndDate();
            this.startDate = successfulEndDate.addSeconds(1);
            if (startDate > absoluteEndDate) startDate = absoluteEndDate;
        }
        return this;
    }
    public void addToInterval(){
        this.interval = this.interval / 2;
        
        if (this.interval < 1000) {
            this.interval = 1000;
            stuckCounter++;
            if (stuckCounter == 10) { throw new Integ_CGIAdv_Utilities.BatchLogicException('Batch processing is unable to continue'); }
        }
    }

    public void widenInterval() {
        this.interval = this.interval * 4;
    }

    public void setNewEndDate() { 
        endDate = DateTime.newInstance(truncateMilliseconds((Decimal.valueOf(startDate.getTime()) + interval)).longValue());
        if (endDate > absoluteEndDate) endDate = absoluteEndDate;
        stuckCounter = 0;
    }

    public Decimal truncateMilliseconds(Decimal millis) {
        Long seconds = millis.longValue() / 1000;
        return Decimal.valueOf(seconds * 1000);
    }

    public void addErrorMessage(string errorSource, string error) {
        if (errorMessages.size() == 0) {
            errorMessages.add('Error source, Error message \n');
        }
        errorMessages.add(errorMap.get(errorSource) + ',"' + error + '"\n');
    }

    public void logErrors(FINETBatchScheduleChild__c scheduleChild) {
        scheduleChild.Log__c += 'A fatal error has caused the batch upload to stop on the ' + scheduleChild.Name + ' class; administrators have been e-mailed.';
        scheduleChild.Status__c = 'Error';
        update scheduleChild;
        update new FINETBatchScheduleParent__c(Id = scheduleChild.FINETBatchScheduleParent__c, Status__c = 'Error');
        Integ_CGIAdv_Utilities.sendErrorEmails(errorMessages);
    }

    public void handle404(string body) {
        Map<String, String> payload = (Map<String, String>)json.deserialize(body,Map<String,String>.class);
        if( payload.get( 'message' ) == 'Count of records returned is greater than max supplied.' ){
            addToInterval();
            setNewEndDate();
        }else if (payload.get('message') == 'No records found.'){
            setForNextBatch();
        } else {
            throw new Integ_CGIAdv_Utilities.NullReferenceException('Unknown 404 message');
        }
    }

    public List<Object> handleCalloutExceptions(CalloutException ce, FINETBatchScheduleChild__c scheduleChild) {
        if (ce.getMessage() == 'Read timed out') {
            System.debug('Timeout: ' + ce);
            fallthroughFlag = true; 
            return new List<Object>(); 
        } else if(ce.getMessage().contains('Exceeded maximum time allotted for callout')) {
            System.debug('Other Callout Exception: ' + ce);
            addToInterval();
            setNewEndDate();
            fallthroughFlag = true;
            return new List<Object>();
        } else {
            addErrorMessage('CO_ERROR', ce.getMessage());
            logErrors(scheduleChild);
            throw new Integ_CGIAdv_Utilities.FINETAPIException('CalloutException Error: ' + ce.getMessage());
        }
    }

    public void scheduleNextObjectBatch(FINETBatchScheduleChild__c scheduleChild) {
        scheduleChild.Log__c += scheduleChild.Name + ' batch completed with ' + errorMessages.size() + ' errors.\n';
        scheduleChild.ErrorCount__c += errorMessages.size();
        for (string err : errorMessages) {
            scheduleChild.Log__c += err;
        }
        scheduleChild.Status__c = 'Complete';
        Integer successes = 0;
        Integer errors = 0;
        if (errorCount == null || errorCount.keySet().size() == 0) {
            errors = 0;
        } else {
            for (Double key : errorCount.keySet()) {
                errors += errorCount.get(key);
            }
        }
        if (successCount == null || successCount.keySet().size() == 0) {
            successes = 0;
        } else {
            for (Double key : successCount.keySet()) {
                successes += successCount.get(key);
            }
        }
        
        scheduleChild.ErrorCount__c = errors;
        scheduleChild.SuccessCount__c = successes;
        try {
            update scheduleChild;
        } catch (Exception e) {
            addAttachment(scheduleChild, errorMessages);
            scheduleChild.Log__c = scheduleChild.Name + ' batch completed with ' + errorMessages.size() + ' errors; log has been created as an attachment: ' + scheduleChild.FINETBatchScheduleParent__c;
            update scheduleChild;
        }
        DateTime newTime = DateTime.now().addMinutes(2);
        String cronTime = '0 ' + newTime.minute() + ' ' + newTime.hour() + ' ' + newTime.day() + ' ' + newTime.month() + ' ? ' + newTime.year();
        System.schedule('MasterBatchScheduler_'+cronTime, cronTime , new FINETMasterScheduler());
    }

    public void addSuccess(Double batchId) {
        Integer count = (successCount.get(batchId) == null) ? 0 : successCount.get(batchId);
        count++;
        successCount.put(batchId,count);
    }

    public void addError(Double batchId) {
        Integer count = (errorCount.get(batchId) == null) ? 0 : errorCount.get(batchId);
        count++;
        errorCount.put(batchId,count);
    }

    //PRIVATE METHODS
    private Id addAttachment(FINETBatchScheduleChild__c scheduleChild, List<String> errorList) {
        String body = '';
        for (String error : errorList) {
            body += error + '\n';
        }

        Attachment att = new Attachment();
        att.Body = Blob.valueOf(body);
        att.Name = scheduleChild.Name + ' error log for ' + DateTime.now();
        att.parentId = scheduleChild.Id;
        Database.SaveResult sr = Database.insert(att, true);
        if (sr.isSuccess()) {
            return sr.getId();
        } else {
            throw new Integ_CGIAdv_Utilities.BatchLogicException('Error adding error log attachment');
        }
    }
}