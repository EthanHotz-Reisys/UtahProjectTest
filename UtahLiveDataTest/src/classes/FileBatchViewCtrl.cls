public with sharing class FileBatchViewCtrl {

    public String recordId {get; set;}
    public String packageId {get; set;}
    public PageReference deleteURL {get; set;}
    public String stageJSON {get; set;}
    public String mainJSON {get; set;}
    public String fbStatus {get; set;}
    public Boolean renderApproveAndRejectBtn {get; set;}
    public String approveBtnText {get; set;}
    public String rejectBtnText {get; set;}
    public String fileBatchRecordType {get; set;}
    public String errorsMessage {get;set;}
    public FileBatchProcess fbp;
    public FileBatch__c fb;
    public String fileBatchComment{get;set;}
    public Boolean showFirstComment{get;set;}
    public Boolean showSecondComment{get;set;}

    public FileBatchViewCtrl (ApexPages.StandardController stdController) {
        recordId = ApexPages.CurrentPage().getParameters().get('id');
        packageId = null;
        deleteURL = null;

        fb = [SELECT Id, ActionType__c, Status__c, FiscalYear__c, FirstApprover__c, SecondApprover__c, RecordType.Name, ErrorLog__c, FirstApproverComment__c, SecondApproverComment__c FROM FileBatch__c WHERE Id = :recordId];
        fbStatus = fb.Status__c;
        fileBatchRecordType = fb.RecordType.Name;
        errorsMessage = fb.ErrorLog__c;
        if(errorsMessage == null){
            errorsMessage = '';
        }
        errorsMessage = escapeCharacters(errorsMessage);

        if(fb.FirstApproverComment__c != null && fb.FirstApproverComment__c != ''){
            showFirstComment = true;
        }else{
            showFirstComment = false;
        }

        if(fb.SecondApproverComment__c != null && fb.SecondApproverComment__c != ''){
            showSecondComment = true;
        }else{
            showSecondComment = false;
        }

        if ((fb.FirstApprover__c == UserInfo.getUserId() && fbStatus == 'Processed') || (fb.SecondApprover__c == UserInfo.getUserId() && fbStatus == 'Sent for Activation')) {
            renderApproveAndRejectBtn = true;
        } else {
            renderApproveAndRejectBtn = false;
        }

        String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
        System.debug('monitor >>> ' + appName);
        try {
            if (renderApproveAndRejectBtn) {
                UTConstants uc = new UTConstants();
                approveBtnText = uc.approveAndRejectBtnText.get(fb.RecordType.Name).get(fb.Status__c).get(fb.ActionType__c).get('Approve');
                rejectBtnText = uc.approveAndRejectBtnText.get(fb.RecordType.Name).get(fb.Status__c).get(fb.ActionType__c).get('Reject');
            }
        } catch (Exception e) {
            approveBtnText = 'Approve';
            rejectBtnText = 'Reject';
        }

        if (fb.RecordType.Name == UTConstants.FILE_BATCH_MSP  || fb.RecordType.Name == UTConstants.FILE_BATCH_LSNA) {
            fbp = new MSPFileBatchProcess();
        } else if (fb.RecordType.Name == UTConstants.FILE_BATCH_FED_FORMULA || fb.RecordType.Name == UTConstants.FILE_BATCH_STATE_FORMULA 
            || fb.RecordType.Name == UTConstants.FILE_BATCH_APP12 || fb.RecordType.Name == UTConstants.FILE_BATCH_LSA) {
            fbp = new FedFormulaFileBatchProcess();
        }

        Map<String, String> JSONData = fbp.getData(fb);
        stageJSON = JSONData.get('stageJSON');
        mainJSON = JSONData.get('mainJSON') == null || JSONData.get('mainJSON') == '' ? '{}' : JSONData.get('mainJSON');



    }
    private string escapeCharacters(string value){
        value = value.replace('\r\n', ' ');
    value = value.replace('\n', ' ');
    value = value.replace('\r', ' ');
    return value;
    }

    public String getKeyValueMap() {
        Map<String, String> keyValueMap = new Map<String, String>();
        keyValueMap.put('batchId', recordId);
        return JSON.serialize(keyValueMap);
    }

    public String getListParameters() {
        Map<String, Set<String>> listParams = new Map<String, Set<String>>();
        return JSON.serialize(listParams);
    }

    public PageReference approve() {
        Savepoint sp = Database.setSavepoint();
        System.debug('---->' + fileBatchComment);
        try{
            if(fileBatchComment == null || fileBatchComment == ''){
                throw new FileBatchProcessException('Comment cannot be blank');
            }else if(fbStatus == 'Processed'){
                fb.FirstApproverComment__c = fileBatchComment;
            }else if(fbStatus == 'Sent for Activation'){
                fb.SecondApproverComment__c = fileBatchComment;
            }
            update fb;
        }catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
            Database.rollback(sp);
            return null;
        }
        Map<String, List<String>> results = fbp.approve(fb);
        if (results.get('Error').size() > 0) {
            for (String mes : results.get('Error')) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, mes));
            }
            Database.rollback(sp);
            return null;
        } else {
            
            PageReference pageref = Page.PhaseView;
            pageref.getParameters().put('t', 'GrantorPlanning');
            pageref.setRedirect(true);
            return pageref;
            //return null;
        }
    }


    public PageReference reject() {

        Savepoint sp = Database.setSavepoint();
        try{
            if(fileBatchComment == null || fileBatchComment == ''){
                throw new FileBatchProcessException('Comment cannot be blank');
            }else if(fbStatus == 'Processed'){
                fb.FirstApproverComment__c = fileBatchComment;
            }else if(fbStatus == 'Sent for Activation'){
                fb.SecondApproverComment__c = fileBatchComment;
            }
            update fb;
        }catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
            Database.rollback(sp);
            return null;
        }
        Map<String, List<String>> results = fbp.reject(fb);

        if (results.get('Error').size() > 0) {
            for (String mes : results.get('Error')) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, mes));
            }
            Database.rollback(sp);
            return null;
        } else {
            PageReference pageref = Page.PhaseView;
            pageref.getParameters().put('t', 'GrantorPlanning');
            pageref.setRedirect(true);
            return pageref;
        }
    }

    public PageReference cancel() {
        PageReference pageref = Page.PhaseView;
        pageref.getParameters().put('t', 'GrantorPlanning');
        pageref.setRedirect(true);
        return pageref;
    }

    public class FileBatchProcessException extends Exception{}
}