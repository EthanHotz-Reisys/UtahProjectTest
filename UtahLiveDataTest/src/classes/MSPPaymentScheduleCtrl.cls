public with sharing class MSPPaymentScheduleCtrl {
    public String recordId{get;set;}
    public String packageId{get;set;}
    public PageReference deleteURL{get;set;}
    public String paymentJSON{get;set;}
    public Boolean renderForFirstApprover{get;set;}
    public Boolean renderForFinalApprover{get;set;}
    public Boolean renderForSendToFinet{get;set;}

    public MSPPaymentScheduleCtrl(ApexPages.StandardController stdController) {
        recordId = ApexPages.CurrentPage().getParameters().get('id');
        packageId = null;
        deleteURL = null;
        MSPPaymentSchedule__c mps = [SELECT Id, Status__c, FinalApprover__c, FirstApprover__c, ScheduleDate__c FROM MSPPaymentSchedule__c WHERE Id = :recordId];

        if(mps.Status__c == 'Payment Requests Created' && mps.FirstApprover__c == UserInfo.getUserId()){
            renderForFirstApprover = true;
        }else{
            renderForFirstApprover = false;
        }

        if(mps.Status__c == 'First Approved' && mps.FinalApprover__c == UserInfo.getUserId()){
            renderForFinalApprover = true;
        }else{
            renderForFinalApprover = false;
        }

        if(mps.Status__c == 'Final Approved' && mps.FinalApprover__c == UserInfo.getUserId()){
            renderForSendToFinet = true;
        }else{
            renderForSendToFinet = false;
        }

        List<PaymentRequest__c> mpas = [SELECT Id, MSPTotal__c, PaymentAmount__c, CatchUp__c, Grant__r.Program__r.ProgramName__c, Grant__r.InternalOrganization__r.Name, Grant__r.InternalOrganization__r.LEA_Id__c, Grant__r.ProgramCode__c, Grant__r.ObjectCode__c FROM PaymentRequest__c WHERE MSPPaymentSchedule__c = :recordId ORDER BY Grant__r.InternalOrganization__r.LEA_Id__c, Grant__r.Program__r.ProgramKey__c];
        List<PaymentWrapper> mpsWrapper = new List<PaymentWrapper>();
        
        for(PaymentRequest__c mp : mpas){
            PaymentWrapper temp = new PaymentWrapper();
        	temp.programName = mp.Grant__r.Program__r.ProgramName__c;
        	temp.subRecipientName = mp.Grant__r.InternalOrganization__r.Name;
            temp.paymentAmount = mp.PaymentAmount__c;
            temp.catchUp = mp.CatchUp__c;
            temp.objectCode = mp.Grant__r.ObjectCode__c;
            temp.programCode = mp.Grant__r.ProgramCode__c;
            temp.leaId = mp.Grant__r.InternalOrganization__r.LEA_Id__c;
            temp.total = mp.MSPTotal__c;
            mpsWrapper.add(temp);
        }
        paymentJSON = JSON.serialize(mpsWrapper);
    }

    public PageReference approve(){
        MSPPaymentSchedule__c mps = [SELECT Id, Status__c, FinalApprover__c, FirstApprover__c, ScheduleDate__c FROM MSPPaymentSchedule__c WHERE Id = :recordId];
        if(mps.Status__c == 'Payment Requests Created' && UserInfo.getUserId() == mps.FirstApprover__c){
            firstApprove(mps);
        }else if(mps.Status__c == 'First Approved' && UserInfo.getUserId() == mps.FinalApprover__c){
            finalApprove(mps);
        }else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please refresh page'));
            return null;
        }
        PageReference pageref = Page.PhaseView;
        pageref.getParameters().put('t','Monitoring');
        pageref.setRedirect(true);
        return pageref; 
    }
    
    public PageReference reject(){
        MSPPaymentSchedule__c mps = [SELECT Id, Status__c, FinalApprover__c, FirstApprover__c, ScheduleDate__c FROM MSPPaymentSchedule__c WHERE Id = :recordId];
        if(mps.Status__c == 'Payment Requests Created' && UserInfo.getUserId() == mps.FirstApprover__c){
            updateFirstApprovalTask();
        }else if(mps.Status__c == 'First Approved' && UserInfo.getUserId() == mps.FinalApprover__c){
            updateFinalApprovalTask();
        }else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please refresh page'));
            return null;            
        }
        mps.Status__c = 'Rejected ';
        update mps;
        PageReference pageref = Page.PhaseView;
        pageref.getParameters().put('t','Monitoring');
        pageref.setRedirect(true);
        return pageref; 
    }    
    

    public PageReference cancel(){
        PageReference pageref = Page.PhaseView;
        pageref.getParameters().put('t','Monitoring');
        pageref.setRedirect(true);
        return pageref; 
    }

    public PageReference sendToFinet(){
        MSPPaymentSchedule__c mps = [SELECT Id, Status__c, FinalApprover__c, FirstApprover__c, ScheduleDate__c FROM MSPPaymentSchedule__c WHERE Id = :recordId];
        mps.Status__c = 'Processing';
        update mps;
        Database.executeBatch(new MSPPaymentSendToFinetActionBatch(mps), 200);
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Sent to FINET'));
        PageReference pageref = Page.PhaseView;
        pageref.getParameters().put('t','Monitoring');
        pageref.setRedirect(true);
        return pageref; 
    }

    private void firstApprove(MSPPaymentSchedule__c mps){
        mps.Status__c = 'First Approved';
        update mps;
        updateFirstApprovalTask();
        List<Task> finalApprovalTask = GNT.TaskCreationHandler.createTasks(mps.FinalApprover__c,
            mps.Id,'MSP Payment Final Approval',
            String.valueOf(mps.ScheduleDate__c) + ' MSP Payments Final Approval', null, false, null,
            'Approval', String.valueOf(mps.ScheduleDate__c) + ' MSP Payments Final Approval', false
        );

        if(finalApprovalTask != null && finalApprovalTask.size() > 0) {
            insert finalApprovalTask[0];
        }
    }

    private void finalApprove(MSPPaymentSchedule__c mps){
        updateFinalApprovalTask();
        mps.Status__c = 'Final Approved';
        update mps;

    }

    private void updateFirstApprovalTask(){
        List<Task> creationTaskList = [SELECT Id, Status FROM Task WHERE WhatId = :recordId AND OwnerId = :UserInfo.getUserId() AND GNT__TaskAction__c = 'MSP Payment First Approval'];
        if(creationTaskList != null && creationTaskList.size() > 0){
            for(Task t : creationTaskList){
                t.Status = 'Completed';
            }
        }

        update creationTaskList;
    }

    private void updateFinalApprovalTask(){
        List<Task> creationTaskList = [SELECT Id, Status FROM Task WHERE WhatId = :recordId AND OwnerId = :UserInfo.getUserId() AND GNT__TaskAction__c = 'MSP Payment Final Approval'];
        if(creationTaskList != null && creationTaskList.size() > 0){
            for(Task t : creationTaskList){
                t.Status = 'Completed';
            }
        }

        update creationTaskList;
    }

    class PaymentWrapper{
    	public String programName{get;set;}
    	public String subRecipientName{get;set;}
        public Decimal paymentAmount{get;set;}
        public Decimal catchUp{get;set;}
        public String programCode{get;set;}
        public String objectCode{get;set;}
        public String leaId{get;set;}
        public Decimal total{get;set;}
    }
}