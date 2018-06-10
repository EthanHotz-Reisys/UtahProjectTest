global class USBEPaymentRequestViewCtrl {

    public ID recordId {get; set;}
    public String pageTemplateName {get; set;}
    public String stageJSON {get; set;}
    public Boolean renderSave {get; set;}
    public Boolean renderSendForApproval {get; set;}
    public Boolean renderReject {get; set;}
    public Boolean renderSendToFINET {get; set;}
    public Boolean renderCancel {get; set;}
    public PaymentBatchRequest__c batchRequest {get; set;}
    public Program__c program {get; set;}
    public integer awardsCount {get; set;}
    public boolean canEdit {get; set;}
    public String source {get; set;}

    public USBEPaymentRequestViewCtrl() {
    }

    public void init() {
        Map<String, String> parameters = ApexPages.currentPage().getParameters();
        Id id = (Id)parameters.get('id');
        Id programId ;
        source = parameters.get('source');
        PaymentBatchRequest__c pbr = new PaymentBatchRequest__c();

        if (source == 'program') {
            programId = id;
            setPaymentBatchRequestByProgram(programId);
        }

        else if (source == 'paymentbatch') {
            batchRequest = [Select id, Status__c, Approver1__c,Approver1__r.Name,Approver2__r.Name, Approver2__c, Program__r.Name, LEARequests__c from PaymentBatchRequest__c where id = :id  ];
            programId =  batchRequest.Program__C;
        }

        program = [Select id, ProgramPaymentBatchStatus__c, ProgramPathway__c, FiscalYear__c, FiscalYear__r.Name, Name, ProgramName__c   from Program__c where id = :programId];


        List<Award__c> awards = [Select id, Grant__r.InternalOrganization__r.LEA_Id__c, GranteeOrganization__c, AwardedAmount__c, PaidAmountOnAwardLS__c, YTDReimbursementPaid__c, YTDRemainingAmount__c, Grant__R.Program__C    from Award__c where Status__c = 'Activated' and  Grant__R.Program__C = : program.id ];
        awardsCount = awards.size();
        if (program.ProgramPaymentBatchStatus__c == 'Initiate' && awards.size() > 0 && source == 'program') {
            CreatePaymentBatchRequest(program.Id);
            UpdateProgram();
        }
        stageJSON = JSON.serialize(awards);
        if (batchRequest != null && program != null) {
            resolveActions(batchRequest);
        }
    }

    private void setPaymentBatchRequestByProgram(Id programId) {
        List<PaymentBatchRequest__c> batchRequests = [Select id, Status__c, Approver1__c, Approver1__r.Name, Approver2__c, Approver2__r.Name, Program__r.Name, LEARequests__c from PaymentBatchRequest__c where Program__c = :programId ORDER BY CreatedDate DESC limit 1];
        if (batchRequests.size() > 0) {
            batchRequest = batchRequests[0];
        }
    }

    private PaymentBatchRequest__c getPaymentBatchRequest(Id requestId) {
        PaymentBatchRequest__c batchRequest = [Select id, Status__c, Approver1__c, Approver1__r.Name, Approver2__c, Approver2__r.Name, Program__r.Name, LEARequests__c from PaymentBatchRequest__c where Id = :requestId];
        return batchRequest;
    }


    private void UpdateProgram() {
        program.ProgramPaymentBatchStatus__c = 'Created';
        ProgramTriggerHelperUSBE.skipTrigger = true;
        update program;
        ProgramTriggerHelperUSBE.skipTrigger = false;
    }


    private void CreatePaymentBatchRequest(Id programId) {

        Program__c program = [Select id, ProgramPaymentBatchStatus__c, FiscalYear__c, FiscalYear__r.Name, PaymentApprover1__c, ProgramPathway__c from Program__c where id = :programId];
        Id firstApproverId = UserInfo.getUserId();
        Id secondApproverId = UserInfo.getUserId();
        String fiscalYear = program.FiscalYear__r.Name.replace('SFY-', '');
        System.debug('VERY IMPORTANT====================>' + fiscalYear);

        Map<String, String> recordTypeMap = new Map<String, String> {
            'Lump-Sum-App' => 'LSA',
            'Lump-Sum-No-App' => 'LSNA'
        };

        String pathway = recordTypeMap.get(program.ProgramPathway__c);
        System.debug('LEON HERE1=========================>' + pathway);
        System.debug('LEON HERE YEAR=====================>' + program.FiscalYear__c);
        List<FileBatch__c>  fileBatches = [SELECT FirstApprover__c, Id, SecondApprover__c, RecordTypeId FROM FileBatch__c  where FiscalYear__c = :fiscalYear and status__c = 'Active' and  RecordType.Name = : pathway  order by createddate DESC];
        System.debug('LEON HERE1=========================>' + fileBatches.size());
        System.debug('LEON HERE2=========================>' + fileBatches);
        if (fileBatches != null && fileBatches.size() > 0 && fileBatches[0].FirstApprover__c != null && fileBatches[0].SecondApprover__c != null ) {
            firstApproverId = fileBatches[0].FirstApprover__c;
            secondApproverId = fileBatches[0].SecondApprover__c;
        } else {
            firstApproverId = UserInfo.getUserId();
            secondApproverId = UserInfo.getUserId();
        }
        PaymentBatchRequest__c pbr = new PaymentBatchRequest__c();
        pbr.Program__c = program.Id;
        pbr.Status__c = 'Created';
        pbr.Approver1__c = firstApproverId;
        pbr.CreatedDate__c = Date.today();
        pbr.Approver2__c = secondApproverId;
        System.debug('SIVA TEST++++++++++++++++>' + pbr.id);
        insert pbr;
        batchRequest = getPaymentBatchRequest(pbr.Id);

    }

    private Id getApprover(string approverType) {

        if (approverType == 'FirstApprover') {

        }
        return (Id) UserInfo.getUserId();
    }

    private void resolveActions(PaymentBatchRequest__c pbr) {
        System.debug('JONATHAN TESTED' + pbr);
        Map<String, List<String>> conditions = new Map<String, List<String>> {'Save' => new List<String>{'Created'},
        'Send for Approval' => new List<String>{'Created'},
        'Cancel' => new List<String>{'Created', 'Sent for Approval', 'Sent to FINET', 'Paid'},
        'Send to FINET' => new List<String>{'Sent for Approval'},
        'Reject' => new List<String>{'Sent for Approval'}
                                                                             };
        String status = pbr.Status__c;
        System.debug('JONATHAN TEST' + pbr.Status__c);
        renderSave = conditions.get('Save').contains(status) && pbr.Approver1__c == UserInfo.getUserId() && source == 'program';
        renderCancel = conditions.get('Cancel').contains(status) && source == 'program';
        renderReject = conditions.get('Reject').contains(status) && pbr.Approver2__c == UserInfo.getUserId() && source == 'program';
        renderSendToFINET = conditions.get('Send to FINET').contains(status) && pbr.Approver2__c == UserInfo.getUserId() && source == 'program';
        renderSendForApproval = conditions.get('Send for Approval').contains(status) && pbr.Approver1__c == UserInfo.getUserId() && source == 'program';

        canEdit = pbr.Approver1__c == UserInfo.getUserId();
    }
    public static string getKeyValueMap() {
        Map<String, String> keyValueMap = new Map<String, String>();
        //keyValueMap.put('programid', ApexPages.currentPage().getParameters().get('id'));
        return JSON.serialize(keyValueMap);
    }



    private static void createBatchTask(PaymentBatchRequest__c batchRequest) {
        List<Task> budgetCreationApprovalTask = GNT.TaskCreationHandler.createTasks(batchRequest.Approver2__c,
                                                batchRequest.Id, 'Payment Request Batch Created',
                                                batchRequest.Program__r.Name + ' ' + batchRequest.Status__c, null, false, null,
                                                'Approval', batchRequest.Program__r.Name + ' ' + batchRequest.Status__c, false
                                                                                   );

        if (budgetCreationApprovalTask != null && budgetCreationApprovalTask.size() > 0) {
            insert budgetCreationApprovalTask[0];
        }
    }


    private static PaymentBatchRequest__c getRemotePaymentBatchRequest(string requestId) {
        PaymentBatchRequest__c batchRequest = [Select id, Status__c, Approver1__c, Approver2__c, Program__r.Name, LEARequests__c from PaymentBatchRequest__c where Id = :requestId];
        return batchRequest;
    }
    private static Program__c getRemoteProgram(string programId) {
        Program__C program = [Select id, ProgramPaymentBatchStatus__c from Program__C where Id = :programId];
        return program;
    }

    private static string getNextPaymentBatchStatus(string action) {
        Map<string, string> actionStatuses = new Map<string, string> {'approve' => 'Sent for Approval',
                'reject' => 'Rejected',
                'finet' => 'Sent to FINET'
                                                                     };
        return actionStatuses.get(action);
    }

    private static string getNextProgramBatchStatus(string action) {
        Map<string, string> actionStatuses = new Map<string, string> {'approve' => 'In Approval Process',
                'reject' => 'Initiate',
                'finet' => 'Initiate'
                                                                     };
        return actionStatuses.get(action);
    }

    @RemoteAction
    global static Boolean approve(string programId, string batchId) {
        PaymentBatchRequest__c batchRequest = getRemotePaymentBatchRequest(batchId);
        Program__C program = getRemoteProgram(programId);
        program.ProgramPaymentBatchStatus__c = getNextProgramBatchStatus('approve');
        ProgramTriggerHelperUSBE.skipTrigger = true;
        update program;
        batchRequest.Status__c = getNextPaymentBatchStatus('approve');
        update batchRequest;
        createBatchTask(batchRequest);
        ProgramTriggerHelperUSBE.skipTrigger = false;
        return true;
    }

    @RemoteAction
    global static Boolean reject(string programId, string batchId) {
        PaymentBatchRequest__c batchRequest = getRemotePaymentBatchRequest(batchId);
        Program__C program = getRemoteProgram(programId);
        program.ProgramPaymentBatchStatus__c = getNextProgramBatchStatus('reject');
        ProgramTriggerHelperUSBE.skipTrigger = true;
        update program;
        batchRequest.Status__c = getNextPaymentBatchStatus('reject');
        update batchRequest;
        ProgramTriggerHelperUSBE.skipTrigger = false;
        Task task = [Select id from Task where whatId = :batchRequest.Id limit 1];
        task.Status = 'Completed';
        update task;
        return true;
    }

    @RemoteAction
    global static String sendToFinet(string programId, string batchId, string inputAmounts) {
        PaymentBatchRequest__c batchRequest = getRemotePaymentBatchRequest(batchId);
        Program__C program = getRemoteProgram(programId);
        program.ProgramPaymentBatchStatus__c = getNextProgramBatchStatus('finet');

        Map<Id, decimal> amounts = resolveInputs(inputAmounts);
        Map<Id, Award__C> awards = new Map<ID, Award__C>([Select Id, Grant__c, AwardedAmount__c, Grant__R.Program__C, VersionNumber__c, PaidAmountOnAwardLS__c, Grant__R.Program__R.ProgramPathway__c from Award__C where id in:(amounts.keySet())]);
        List<Award__c> updatedAwards = new List<Award__c>();
        List<PaymentRequest__c> paymentRequests = new List<PaymentRequest__c>();
        for (Id awardId : awards.keySet()) {
            Award__C award = awards.get(awardId);
            System.debug('LEON TEST================>' + award.PaidAmountOnAwardLS__c);
            award.PaidAmountOnAwardLS__c = ifnull(award.PaidAmountOnAwardLS__c) + amounts.get(award.id).setScale(2);
            updatedAwards.add(award);
            PaymentRequest__c temp = new PaymentRequest__c(
                Grant__c = award.Grant__c,
                //PaymentOrder__c = mg.PaymentCount__c + 1,

                PaymentAmount__c = amounts.get(award.id).setScale(2),
                Status__c = 'Approved',
                USBEPathway__c = award.Grant__R.Program__R.ProgramPathway__c,
                AwardVersionNumber__c = award.VersionNumber__c,
                Award__c = award.Id
            );
            paymentRequests.add(temp);
        }
        system.debug('payment requests>>>' + paymentRequests);

        try {


            if (paymentRequests.size() > 0) {
                insert paymentRequests;
                insertPaymentFinetCode(paymentRequests, awards);
                update updatedAwards;
            }


            ProgramTriggerHelperUSBE.skipTrigger = true;
            update program;
            batchRequest.Status__c = getNextPaymentBatchStatus('finet') ;
            update batchRequest;
            ProgramTriggerHelperUSBE.skipTrigger = false;
            Task task = [Select id from Task where whatId = :batchRequest.Id limit 1];
            task.Status = 'Completed';
            update task;
        } catch (Exception e) {
            //errors.add(e.getMessage());
            //Database.rollback(sp);
            String errorMessage = e.getMessage();
            batchRequest.Status__c = 'Error';
            batchRequest.ErrorLog__c = errorMessage;
            update batchRequest;
            System.debug('Start**' + errorMessage);
            return errorMessage;
        }
        return 'Success';
    }
    private static decimal ifnull(decimal num ) {
        if (num == null) num = 0;
        return num;
    }
    static void insertPaymentFinetCode(List<PaymentRequest__c> paymentRequests, Map<Id, Award__c> awards) {
        List<PaymentFINETCode__c> paymentFinets = new List<PaymentFINETCode__c>();
        List<AwardFINETCode__c> rawAwardFinets = [SELECT Id, Award__c, Amount__c, SpentAmount__c FROM AwardFINETCode__c WHERE Award__c IN: (awards.keySet())];
        Map<Id, List<AwardFINETCode__c>> sourcesMap = new Map<Id, List<AwardFINETCode__c>>();

        for (AwardFINETCode__c awardFinet : rawAwardFinets) {
            List<AwardFINETCode__c> temp = sourcesMap.get(awardFinet.Award__c);
            if (temp == null) {
                temp = new List<AwardFINETCode__c>();
                sourcesMap.put(awardFinet.Award__c, temp);
            }
            temp.add(awardFinet);
        }
        for (PaymentRequest__c paymentRequest : paymentRequests) {
            List<AwardFINETCode__c> awardFinets = sourcesMap.get(paymentRequest.Award__c);
            if (awardFinets != null && awardFinets.size() > 0) {
                Award__c award = awards.get( paymentRequest.Award__c);
                for (AwardFINETCode__c awardFinet : awardFinets) {
                    PaymentFINETCode__c paymentFinet = new PaymentFINETCode__c();
                    paymentFinet.PaymentRequest__c = paymentRequest.Id;
                    paymentFinet.AwardFINETCode__c = awardFinet.Id;
                    paymentFinet.Amount__c = awardFinet.Amount__c;
                    decimal percent = ( paymentRequest.PaymentAmount__c / award.AwardedAmount__c) * 100;
                    decimal percentAmount = (percent / 100) * awardFinet.Amount__c;
                    paymentFinet.SpentAmount__c = percentAmount;
                    //paymentFinet.RequestedAmount__c = paymentFinet.SpentAmount__c;
                    paymentFinets.add(paymentFinet);
                }
            }
        }
        if (paymentFinets.size() > 0) {
            insert paymentFinets;
        }

    }

    static Map<Id, decimal> resolveInputs(string amounts) {
        Map<String, Object> root = (Map<String, Object>)JSON.deserializeUntyped(amounts);
        List<Object> items = (List<Object>)root.get('items');
        Map<Id, decimal> results = new Map<Id, decimal>();
        for (Object item : items) {
            Map<String, Object> i = (Map<String, Object>)item;
            Id awardId = (Id) i.get('awardId');
            decimal amount = decimal.valueOf((string)i.get('amount'));
            System.debug('id>>>' + awardId );
            System.debug('amount>>>' + amount);
            results.put(awardId, amount);

        }
        return results;
    }

    @RemoteAction
    global static Boolean save(string requestId, String data) {
        //System.debug('JONATHAN TEST' + pbr.Status__c);
        PaymentBatchRequest__c request = [select id, LEARequests__c from PaymentBatchRequest__c where id = :requestId];
        request.LEARequests__c = data;
        update request;
        return true;
    }


    @RemoteAction
    global static List<Object> tempAction(string requestId, string amounts) {
        Map<String, Object> root = (Map<String, Object>)JSON.deserializeUntyped(amounts);
        List<Object> items = (List<Object>)root.get('items');
        for (Object item : items) {
            Map<String, Object> i = (Map<String, Object>)item;
            System.debug('id>>>' + i.get('recordId'));
            System.debug('amount>>>' + i.get('amount'));
        }
        return items;
    }

}