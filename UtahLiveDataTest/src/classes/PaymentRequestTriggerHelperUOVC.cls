global with sharing class PaymentRequestTriggerHelperUOVC extends GNT.TriggerHelper{
    private Map<Id, PaymentBudgetCategory__c> budgetCategoryMap;
    private Map<Id, PaymentServiceArea__c> serviceAreaMap;
    private Map<Id,  Map<Id, PaymentBudgetCategory__c>> payIdbudgetCategoryMap;
    private Map<Id, Map<Id, PaymentServiceArea__c> > payIdserviceAreaMap;
    private Set<Id> paymentId;
    private List<GrantBudgetCategory__c> upsertGbcs = new List<GrantBudgetCategory__c>();
    private String msg;
    private Boolean updateFlag=true;
    global static boolean skipTrigger = false;
    global override void processBeforeInsert() {
        if(skipTrigger == false) {
        CheckMoreThanOneAdvanceRequest();
        PopulateGrantid();
        PopulateRoles(Trigger.New);
        GNT.NameTemplateTriggerHelper.beforeInsert(); 
        }   
    }
    global override void processAfterInsert() {
        if(skipTrigger == false) {
        insertpaymentserviceareas((List<PaymentRequest__c>) Trigger.New);
        insertpaymentbudgetcategories(Trigger.New);
        insertpaymentfinetcode(Trigger.New);
        createPaymentShares(Trigger.new);  
        }
    }
    global override void processBeforeUpdate(){
        if(skipTrigger == false) {
        CheckBudgetValidations(Trigger.new);
        //CheckFundingAccount(Trigger.new);
        updateStatus(Trigger.new);
        //updateFiscalYear(Trigger.New, Trigger.Old);
        }
    }
    global override void processAfterUpdate() {
        if(skipTrigger == false) {
        //upsertpaymentcategorieslive((List<PaymentRequest__c>) Trigger.New);
         updateLinkedAwardBudgetCategories();
         updateIndirect(Trigger.New);
         approvalSendBack(Trigger.New, Trigger.Old);
        }
    }

   
             
    /*
        This method will lock the Payment Request if a closeout has been Approved for for the Grant.
    
    */
   /* private void lockPaymentRequestForCloseout(List<PaymentRequest__c> payReqList){
        Set<Id> grantSet = new Set<Id>();
        for(PaymentRequest__c payReq : payReqList){
            grantSet.add(payReq.Grant__c);
        }
        Map<Id, Id> grantCloseoutMap = new Map<Id, Id>();
        List<Closeout__c> closeoutList = new List<Closeout__c>([SELECT Id, Grant__c, Status__c FROM Closeout__c WHERE Status__c IN
                                                               ('Initiated By PM', 'Under PM Review', 'Approved By PM', 'Initiated By GM', 'Under GM Review', 'Approved By GM') AND Grant__c IN :grantSet]);
        if(closeoutList != null && closeoutList.size() > 0){
            for(Closeout__c ct : closeoutList){
                grantCloseoutMap.put(ct.Grant__c, ct.Id);
            }
        }
        if((grantCloseoutMap != null || !grantCloseoutMap.isEmpty()) && grantCloseoutMap.size() > 0){
            for(PaymentRequest__c payReq : payReqList){
                if(grantCloseoutMap.containsKey(payReq.Grant__c)){
                    //payReq.addError('Closeout is in progress for the Grant. Unable to complete request.');
                    payReq.addError(GNT.ErrorMessageHelper.fetchMessage('M01-GRNTR-94855'));
                }
            }
        }
    }*/
    
    /* to update the status of payment request as 'Not Required' if the current payment request is marked as final payment request */
    
   /*  private void updateNotRequiredPaymentRequests(){
        Set<Id> awardIdSet = new Set<Id>();
        Set<Id> paymentIdSet = new Set<Id>();
        Set<Id> grantIdSet = new Set<Id>();
        for(PaymentRequest__c payment : (List<PaymentRequest__c>)trigger.new){
            PaymentRequest__c oldPayment = (PaymentRequest__c)trigger.oldMap.get(payment.Id);
            
            if(payment.Status__c == 'Approved' && oldPayment.Status__c != 'Approved' && payment.FinalPaymentRequested__c == true){
                System.debug('payment status=380=>'+payment.Status__c +'old :'+oldPayment.Status__c);
                awardIdSet.add(payment.Award__c);
                paymentIdSet.add(payment.Id);
                grantIdSet.add(payment.Grant__c);
            }
        }
        system.debug('paymentIdSet==>'+paymentIdSet);
        system.debug('awardIdSet==>'+paymentIdSet);
        List<PaymentRequest__c> futurePaymentReqList = [Select Id from PaymentRequest__c Where Status__c = 'Created' AND Award__c IN : awardIdSet AND Id Not IN : paymentIdSet];
        system.debug('futurePaymentReqList==='+futurePaymentReqList);
        if(futurePaymentReqList.size() > 0){
            for(PaymentRequest__c pay : futurePaymentReqList){
                pay.Status__c = 'Not Required';
            }
            PaymentRequestTriggerHelper.skipTrigger = true;
            update futurePaymentReqList;
            closeNotRequiredTasks(futurePaymentReqList);
            PaymentRequestTriggerHelper.skipTrigger = false;
        }else{
            List<TermConditionSchedule__c> lstTncSchedule = [Select Id, TaskCreated__c from TermConditionSchedule__c where 
                TermAndCondition__r.Award__r.RecordType.Name='Grantor' and RecordType.Name='Payment Request' AND 
                TermAndCondition__r.Award__r.Grant__c IN: grantIdSet AND TaskCreated__c = false];
            for(TermConditionSchedule__c tnc :lstTncSchedule){
                tnc.TaskCreated__c = true;
            }
            update lstTncSchedule;
        }
    }
    
    private void closeNotRequiredTasks(List<PaymentRequest__c> payList){
        List<Task> tskList = [Select Id, Status from Task Where WhatId IN : payList AND Status IN ('Not Started', 'In Progress')];
        system.debug('tskList==>'+tskList);
        if(tskList.size() > 0){
            for(Task tsk : tskList){
                tsk.Status = 'Completed';
            }
            update tskList;
        }
    } */
    
    private void CheckBudgetValidations(List<PaymentRequest__c> paymentRequestList){
       List<id> awardids =new List<id>();
       for(PaymentRequest__c payreq : paymentRequestList){
         awardids.add(payreq.Award__c);
       }
       List<AwardPaymentBudgetCategory__c> awdpbclist = [select id,name,Award__c,AwardedAmount__c,GrantProjectArea__c,BudgetCategory__c,YTDReimbursementPaid__c,YTDAdvancePaid__c,YTDAdvanceApplied__c
                                                           from AwardPaymentBudgetCategory__c where Award__c IN:awardids];
       for(PaymentRequest__c payReq : paymentRequestList){
          for(AwardPaymentBudgetCategory__c awdlivepaymentcat : awdpbclist){
             if((payReq.Status__c == 'Approved') && (awdlivepaymentcat.YTDReimbursementPaid__c > awdlivepaymentcat.AwardedAmount__c)){
                 //payReq.addError('You cannot Approve if Reimbursement Paid Greater than Reimbursement Available in Payment Summary');
                 payReq.addError(GNT.ErrorMessageHelper.fetchMessage('M01-GRNTR-85806'));
             }
          }
       }
    }
   
    /*private void CheckFundingAccount(List<PaymentRequest__c> paymentRequestList){
        Set<id> Payreqids =new Set<id>();
        for(PaymentRequest__c payreq : paymentRequestList){
            Payreqids.add(payreq.id);
        }
        List<PaymentBudgetCategory__c> pbclist = [select id,name,PaymentRequest__c,FundingAccount__c,BudgetCategory__r.name,RequestedExpense__c from PaymentBudgetCategory__c where PaymentRequest__c IN:Payreqids];
        for(PaymentRequest__c payReq : paymentRequestList){
            for(PaymentBudgetCategory__c paymentbudgetcat : pbclist){
                if((payReq.Status__c == 'Approved') && (paymentbudgetcat.RequestedExpense__c > 0) && (paymentbudgetcat.FundingAccount__c == null)){
                    payReq.addError(paymentbudgetcat.BudgetCategory__r.name+':'+GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-94938'));                 
                }
            }
        }
    }*/

    private void createPaymentShares(List<PaymentRequest__c> payments) {
        List<String> paymentIds = new List<String>();
        Map<String, Map<String, PaymentRequest__Share>> shareMap = new Map<String, Map<String, PaymentRequest__Share>>();
        for(PaymentRequest__c payment: payments) {
            paymentIds.add(payment.id);
            if(!shareMap.containsKey(payment.id)) {
                shareMap.put((ID)payment.id, new Map<String, PaymentRequest__Share>());
            }
        }
        List<PaymentRequest__Share> currentShares = [SELECT ParentId, AccessLevel, UserOrGroupId FROM PaymentRequest__Share WHERE ParentId IN: paymentIds];
        if(!currentShares.isEmpty()){
        for(PaymentRequest__Share ps: currentShares) {
            if(shareMap.containsKey(ps.ParentId))
            shareMap.get(ps.ParentId).put(ps.userOrGroupId, ps);
         }
        } 
        
        PaymentRequest__Share share;
        List<PaymentRequest__Share> shares = new List<PaymentRequest__Share>();
        List<Paymentrequest__c> paymentslist = [select id,FiscalOfficer__c,Approver__c,Applicant__c,ProgramManager__c,GrantMonitor__c,ProgramOwner__c 
                                                  from Paymentrequest__c where id IN:paymentIds ];
        
        
        for(PaymentRequest__c payment: paymentslist) {
            
            if(payment.FiscalOfficer__c != null) {
                if(shareMap.get(payment.id).containsKey(payment.FiscalOfficer__c)) {
                    //Updates the existing records to Edit if they are currently set to read
                    if(shareMap.get(payment.id).get(payment.FiscalOfficer__c).AccessLevel == 'Read') {
                        shareMap.get(payment.id).get(payment.FiscalOfficer__c).AccessLevel = 'Edit';
                        shares.add(shareMap.get(payment.id).get(payment.FiscalOfficer__c));
                    }
                } else {
                    share = new PaymentRequest__Share(parentId = payment.id, AccessLevel = 'Edit', UserOrGroupId = payment.FiscalOfficer__c, RowCause = Schema.PaymentRequest__Share.RowCause.SharetoFiscalOfficer__c);
                    shares.add(share);
                    shareMap.get(payment.id).put(payment.FiscalOfficer__c, share);
                }
               
            }
            if(payment.ProgramOwner__c != null) {
                if(shareMap.get(payment.id).containsKey(payment.ProgramOwner__c)) {
                    //Updates the existing records to Edit if they are currently set to read
                    if(shareMap.get(payment.id).get(payment.ProgramOwner__c).AccessLevel == 'Read') {
                        shareMap.get(payment.id).get(payment.ProgramOwner__c).AccessLevel = 'Edit';
                        shares.add(shareMap.get(payment.id).get(payment.ProgramOwner__c));
                    }
                } else {
                    share = new PaymentRequest__Share(parentId = payment.id, AccessLevel = 'Edit', UserOrGroupId = payment.ProgramOwner__c, RowCause = Schema.PaymentRequest__Share.RowCause.SharetoProgramOwner__c);
                    shares.add(share);
                    shareMap.get(payment.id).put(payment.ProgramOwner__c, share);
                }
               
            }
            if(payment.Approver__c!= null) {
                if(shareMap.get(payment.id).containsKey(payment.Approver__c)) {
                    //Updates the existing records to Edit if they are currently set to read
                    if(shareMap.get(payment.id).get(payment.Approver__c).AccessLevel == 'Read') {
                        shareMap.get(payment.id).get(payment.Approver__c).AccessLevel = 'Edit';
                        shares.add(shareMap.get(payment.id).get(payment.Approver__c));
                    }
                } else {
                    share = new PaymentRequest__Share(parentId = payment.id, AccessLevel = 'Edit', UserOrGroupId = payment.Approver__c, RowCause = Schema.PaymentRequest__Share.RowCause.SharetoApprover__c);
                    shares.add(share);
                    shareMap.get(payment.id).put(payment.Approver__c, share);
                }
               
            }
            if(payment.ProgramManager__c != null) {
                if(shareMap.get(payment.id).containsKey(payment.ProgramManager__c)) {
                    //Updates the existing records to Edit if they are currently set to read
                    if(shareMap.get(payment.id).get(payment.ProgramManager__c).AccessLevel == 'Read') {
                        shareMap.get(payment.id).get(payment.ProgramManager__c).AccessLevel = 'Edit';
                        shares.add(shareMap.get(payment.id).get(payment.ProgramManager__c));
                    }
                } else {
                    share = new PaymentRequest__Share(parentId = payment.id, AccessLevel = 'Edit', UserOrGroupId = payment.ProgramManager__c, RowCause = Schema.PaymentRequest__Share.RowCause.SharetoProgramManager__c);
                    shares.add(share);
                    shareMap.get(payment.id).put(payment.ProgramManager__c, share);
                }
               
            }
            if(payment.Applicant__c != null) {
                if(shareMap.get(payment.id).containsKey(payment.Applicant__c)) {
                    //Updates the existing records to Edit if they are currently set to read
                    if(shareMap.get(payment.id).get(payment.Applicant__c).AccessLevel == 'Read') {
                        shareMap.get(payment.id).get(payment.Applicant__c).AccessLevel = 'Edit';
                        shares.add(shareMap.get(payment.id).get(payment.Applicant__c));
                    }
                } else {
                    share = new PaymentRequest__Share(parentId = payment.id, AccessLevel = 'Edit', UserOrGroupId = payment.Applicant__c, RowCause = Schema.PaymentRequest__Share.RowCause.SharetoApplicant__c);
                    shares.add(share);
                    shareMap.get(payment.id).put(payment.Applicant__c, share);
                }
               
            }

                     
        //update paymentMap.values();
        System.debug('Shares: ' + shares);
        
     }
     if(shares.size() > 0) {
            System.debug('Upsert');
           // upsert shares;
           SystemContextMethodsHelper SystemContextMethodsHelper = new SystemContextMethodsHelper();
           SystemContextMethodsHelper.updatePaymentRequestShares(Shares); 
        }
   }
    

 /* private void updateGrantToPointToLatestPaymentOnInsert(){
        Map<Id,Id> grantRiskMap =  new Map<Id,Id>();
        for(PaymentRequest__c pr : (List<PaymentRequest__c>)Trigger.new ){            
              grantRiskMap.put(pr.Grant__c,pr.id);                  
        }
        
        List<Grant__c> grants = [SELECT Id,Name FROM Grant__c WHERE Id in :grantRiskMap.keySet()];
        
        List<Grant__c> grantsToBeUpdated = new List<Grant__c>();
        
        for(Grant__c grant :grants){
            //grant.LatestPaymentRequest__c = grantRiskMap.get(grant.Id);
            grantsToBeUpdated.add(grant);
            system.debug('grant-----'+grant);
        }
        
        if(grantsToBeUpdated.size() > 0){
            system.debug('grantsToBeUpdated-----'+grantsToBeUpdated);
            SystemContextMethodsHelper sc = new SystemContextMethodsHelper();
            sc.updateGrants(grantsToBeUpdated);
        }
    }*/
    
    /*----Inserting Payment Service Areas-----*/
    private void insertpaymentserviceareas(List<PaymentRequest__c> paymentreq){
        PaymentServiceArea__c payServ;
        List<id> listids = new List<id>();
        for (PaymentRequest__c payreq :paymentreq){
              listIds.add(payreq.Grant__c);
            }
        List<GrantServiceArea__c> grantServList;
        List<PaymentServiceArea__c> payServList;
        grantServList = [Select ServiceArea__c from GrantServiceArea__c where Grant__c IN :listIds] ;
        payServList = new List<PaymentServiceArea__c>();
        for(PaymentRequest__c payReq : paymentreq){
          for(GrantServiceArea__c grantServ:grantServList){          
            payServ = new PaymentServiceArea__c();
            payServ.PaymentRequest__c= payReq.id;
            payServ.ServiceArea__c=grantServ.ServiceArea__c;
            payServ.GrantProjectArea__c = grantServ.id;
            payServList.add(payServ);
            }
        }
       if(!payServList.isEmpty()) insert payServList;
    }
    
    /*----Inserting Payment Budget Categories-----*/
    
    private void insertpaymentbudgetcategories(List<PaymentRequest__c> paymentreq){
        List<id> listids = new List<id>();
        List<PaymentBudgetCategory__c> paymentbclist = new List<PaymentBudgetCategory__c>();
        PaymentBudgetCategory__c payBudCategory;
        for (PaymentRequest__c payreq :paymentreq){
              listIds.add(payreq.Award__c);
        }
        List<AwardBudgetCategory__c> awardbudgetcategories = [select Id,Name,BudgetCategory__c,GrantServiceArea__c,Amount1__c,GrantorAmount__c,GranteeAmount__c,BudgetPeriod__c,Award__c,GrantBudgetCategory__c,
                                                              YTDReimbursementPaid__c,PendingPayment__c,CurrentApprovedBudgetAmount__c,InKind__c,InKindExpenditure__c,CashMatch__c,CashMatchExpenditure__c,Federal__c
                                                              from AwardBudgetCategory__c where Award__c IN:listIds];
        /*List<GrantBudgetCategory__c> gbcList = [select Name, BudgetCategory__c, ServiceArea__c, CityAmount__c, BudgetPeriod__c, Grant__c from GrantBudgetCategory__c where Grant__c IN :grantIdSet];
        Map<Id, List<GrantBudgetCategory__c>> grantIdToGbcListMap = new Map<Id, List<GrantBudgetCategory__c>>();
        for(GrantBudgetCategory__c gbc : gbcList ){
            List<GrantBudgetCategory__c> gbcListTemp = grantIdToGbcListMap.get(gbc.Grant__c);
            if(gbcListTemp == null){
                gbcListTemp = new List<GrantBudgetCategory__c>();
            }
            gbcListTemp.add(gbc);
            grantIdToGbcListMap.put(gbc.Grant__c, gbcListTemp);
        }*/
        for(PaymentRequest__c payReq : paymentreq){
            for(AwardBudgetCategory__c awdbc: awardbudgetcategories){
                if(awdbc.Award__c==payReq.Award__c){
                    payBudCategory = new PaymentBudgetCategory__c();
                    payBudCategory.PaymentRequest__c = payReq.id;
                    payBudCategory.BudgetCategory__c = awdbc.BudgetCategory__c;
                    //payBudCategory.AwardedBudget__c = awdbc.Amount1__c;
                    payBudCategory.GranteeShare__c = awdbc.GranteeAmount__c;
                    payBudCategory.GrantProjectArea__c = awdbc.GrantServiceArea__c;
                    payBudCategory.BudgetPeriod__c = awdbc.BudgetPeriod__c;
                    //swati:
                    payBudCategory.AwardBudgetCategory__c = awdbc.Id;
                    payBudCategory.GrantBudgetCategory__c = awdbc.GrantBudgetCategory__c;
                    payBudCategory.YTDReimbursementPaid__c = awdbc.YTDReimbursementPaid__c;
                    payBudCategory.PendingPayment__c = awdbc.PendingPayment__c;
                    payBudCategory.AwardedBudget__c = awdbc.Federal__c;
                    payBudCategory.InKindBudgeted__c = awdbc.InKind__c;
                    payBudCategory.InKindRemaining__c = awdbc.InKind__c - awdbc.InKindExpenditure__c;
                    payBudCategory.CashMatchBudgeted__c = awdbc.CashMatch__c;
                    payBudCategory.CashMatchRemaining__c = awdbc.CashMatch__c - awdbc.CashMatchExpenditure__c;
                    paymentbclist.add(payBudCategory);
                }
            }
        }
        if(!paymentbclist.isEmpty()) insert paymentbclist;
    }
    /* METHOD to Create only one Advance Payment Request */
    private static void CheckMoreThanOneAdvanceRequest(){
        Set<Id> awardIds = new Set<Id>();
        for(PaymentRequest__c payreq: (list<PaymentRequest__c>)Trigger.new){
            if(payreq.Award__c != null){
             awardIds.add(payreq.Award__c);
            }
          }
         List<PaymentRequest__c> advancaereqlist = [select id,Name,Award__c,Type__c from PaymentRequest__c where Type__c = 'Advance' and Award__c in: awardIds];
         for(PaymentRequest__c payreq: (list<PaymentRequest__c>)Trigger.new){
            if(payreq.Type__c == 'Advance' && advancaereqlist.size() == 1){
               //payreq.adderror('You cannot request more than one Advance Type Payment Request for Award');
               payreq.addError(GNT.ErrorMessageHelper.fetchMessage('M01-GRNTR-51843'));
        }
      }
    }
    /* METHOD to Update the Grant ID based on Award ID*/
    private static void PopulateGrantid(){
        Set<Id> awardIds = new Set<Id>();
        
        for(PaymentRequest__c payreq: (list<PaymentRequest__c>)Trigger.new){
            if(payreq.Award__c != null){
             awardIds.add(payreq.Award__c);
            }
          }

        // SOQL the parent records
         Map<Id, Award__c> awards = new Map<Id, Award__c>(); 
         if(!awardIds.isEmpty()){ 
                awards = new Map<Id, Award__c>([select id,Grant__c,Name,FOUser__c,Approver__c from Award__c where id in: awardIds]);
         }

         for(PaymentRequest__c payreq: (list<PaymentRequest__c>)Trigger.new){
            if(payreq.Award__c != null){
              Award__c award = awards.get(payreq.Award__c);
              payreq.Grant__c = award.Grant__c ;
              payreq.FiscalOfficer__c = award.FOUser__c; 
              //payreq.Approver__c = award.Approver__c;
            }
          }
       }
    
    private void PopulateRoles(List<PaymentRequest__c> paymentreq) {
        List<Id> listawdids = new List<Id>();
        for (PaymentRequest__c payreq : paymentreq) {
            listawdids.add(payreq.Award__c);
        }
        List<RolesAndResponsibilities__c> listroles = [SELECT Id,Award__c,BusinessRole__c,Name__c FROM RolesAndResponsibilities__c WHERE Award__c IN: listawdids];
        for (PaymentRequest__c payreq : paymentreq) {
            for (RolesAndResponsibilities__c role : listroles) {
                if (payreq.Award__c == role.Award__c) {
                    if (role.BusinessRole__c == 'Owner') {
                        payreq.ProgramOwner__c = role.Name__c;
                    } else if (role.BusinessRole__c == 'Program Approver') {
                        payreq.ProgramApprover__c = role.Name__c;
                    } else if (role.BusinessRole__c == 'Fiscal Approver') {
                        payreq.FiscalApprover__c = role.Name__c;
                    } else if (role.BusinessRole__c == 'Grants Administrator') {
                        payreq.GrantAdministrator__c = role.Name__c;
                    }
                }
            }
        }
    }
    
    /*---Updates various status and date related fields---*/
    private void updateStatus(List<PaymentRequest__c> paymentreq) {
        for (PaymentRequest__c payreq : paymentreq) {
            if (payReq.Status__c == 'Submitted to Grantor' && payReq.DateSubmitted__c == null) {
                payReq.DateSubmitted__c = System.Today();
            } else if (payReq.Status__c == 'Paid' && payReq.DatePaid__c == null) {
                payReq.DatePaid__c = System.Today();
                payReq.Paid__c = true;
            } else if (payReq.Status__c == 'Approved') {
                payReq.Approved__c = true;
            } else if (payReq.Status__c == 'Rejected') {
                payReq.Rejected__c = true;
            } else if (payReq.Status__c == 'Created' || payReq.Status__c == 'Change Requested') {
                payReq.DateSubmitted__c = null;
                payReq.DatePaid__c = null;
                payReq.Paid__c = false;
                payReq.IsMaster__c = false;
                payReq.Approved__c = false;
                payReq.Rejected__c = false;
            }
        }
    }
    
    /*---Inserting or Updating Payment Budget Categories based on Payment Requests---*/
    
    /*private void upsertpaymentcategorieslive(List<PaymentRequest__c> paymentreq){
        List<id> listawdids = new List<id>();
        List<id> payreqids = new List<id>();
        AwardPaymentBudgetCategory__c awdlivepaycat;
        List<AwardPaymentBudgetCategory__c> awdpbc = new List<AwardPaymentBudgetCategory__c>();
        for (PaymentRequest__c payreq :paymentreq){
            listawdids.add(payreq.Award__c);
            payreqids.add(payreq.id);
        }
        List<PaymentBudgetCategory__c> paymentbclist = [select id,name,GrantProjectArea__c,PaymentRequest__c,BudgetCategory__c,AwardedBudget__c,RequestedExpense__c,AdvanceApplied__c from PaymentBudgetCategory__c 
                                                        where   PaymentRequest__c IN:payreqids];
        List<AwardPaymentBudgetCategory__c> awdpbclist = [select id,name,Award__c,GrantProjectArea__c,BudgetCategory__c,YTDReimbursementPaid__c,YTDAdvancePaid__c,YTDAdvanceApplied__c
                                                          from AwardPaymentBudgetCategory__c where Award__c IN:listawdids];
        if(awdpbclist.isEmpty()){
            for(PaymentRequest__c payReq : paymentreq){
                if(payReq.Status__c == 'Approved'){
                    for(PaymentBudgetCategory__c paymentbc:paymentbclist){
                        awdlivepaycat = new AwardPaymentBudgetCategory__c();
                        awdlivepaycat.Award__c = payReq.Award__c;
                        awdlivepaycat.GrantProjectArea__c = paymentbc.GrantProjectArea__c;
                        awdlivepaycat.BudgetCategory__c = paymentbc.BudgetCategory__c;
                        awdlivepaycat.AwardedAmount__c  = paymentbc.AwardedBudget__c;
                        if(payReq.Type__c == 'Reimbursement'){
                           awdlivepaycat.YTDReimbursementPaid__c = paymentbc.RequestedExpense__c;
                           awdlivepaycat.YTDAdvanceApplied__c = paymentbc.AdvanceApplied__c;
                        }
                        if(payReq.Type__c == 'Advance'){
                            awdlivepaycat.YTDAdvancePaid__c = paymentbc.RequestedExpense__c;
                        }
                        awdpbc.add(awdlivepaycat);
                    }
                }
            }
            if(!awdpbc.isEmpty()) insert awdpbc;
        } else {  
            for(PaymentRequest__c payReq : paymentreq){
                if(payReq.Status__c == 'Approved'){
                    for(AwardPaymentBudgetCategory__c awdlivepaymentcat : awdpbclist){
                        for(PaymentBudgetCategory__c paymentbc:paymentbclist){
                            if ((payReq.Type__c == 'Reimbursement')  && (paymentbc.BudgetCategory__c == awdlivepaymentcat.BudgetCategory__c) && (paymentbc.GrantProjectArea__c == awdlivepaymentcat.GrantProjectArea__c)){
                                awdlivepaymentcat.YTDReimbursementPaid__c = paymentbc.RequestedExpense__c + awdlivepaymentcat.YTDReimbursementPaid__c;
                                awdlivepaymentcat.YTDAdvanceApplied__c = paymentbc.AdvanceApplied__c + awdlivepaymentcat.YTDAdvanceApplied__c;
                            }
                            if ((payReq.Type__c == 'Advance')  && (paymentbc.BudgetCategory__c == awdlivepaymentcat.BudgetCategory__c) && (paymentbc.GrantProjectArea__c == awdlivepaymentcat.GrantProjectArea__c)){
                                awdlivepaymentcat.YTDAdvancePaid__c = paymentbc.RequestedExpense__c + awdlivepaymentcat.YTDAdvancePaid__c;
                            }
                        }
                    awdpbc.add(awdlivepaymentcat); 
                    }
                }
            }
            update awdpbc;
        }
    }*/
    
    /*---Inserting or Updating YTD fields on Award Budget Category based on Payment Requests---*/
    
    private void updateAwardYTD(List<PaymentRequest__c> paymentreq, List<PaymentRequest__c> paymentreqold){
        List<id> listawdids = new List<id>();
        List<id> payreqids = new List<id>();
        List<id> fiscalyearids = new List<id>();
        List<id> ytdpayreqids = new List<id>();
        List<id> paidlist = new List<id>();
        AwardBudgetCategory__c awdlivepaycat;
        List<AwardBudgetCategory__c> awdpbc = new List<AwardBudgetCategory__c>();
        List<PaymentBudgetCategory__c> paybc = new List<PaymentBudgetCategory__c>();
        for (PaymentRequest__c payreq :paymentreq){
            listawdids.add(payreq.Award__c);
            payreqids.add(payreq.id);
        }
        List<PaymentBudgetCategory__c> paymentbclist = [select id,name,GrantProjectArea__c,PaymentRequest__c,BudgetCategory__c,AwardedBudget__c,RequestedExpense__c,AdvanceApplied__c,PendingPayment__c,AwardBudgetCategory__c,
                                                        UpdatedYTDExpenditure__c,InKindExpenditure__c,CashMatchExpenditure__c from PaymentBudgetCategory__c where PaymentRequest__c IN:payreqids];
        List<AwardBudgetCategory__c> awdpbclist = [select id,name,Award__c,ServiceArea__c,BudgetCategory__c,GrantServiceArea__c,YTDReimbursementPaid__c,YTDAdvancePaid__c,YTDAdvanceApplied__c,PendingPayment__c,InKindExpenditure__c,CashMatchExpenditure__c
                                                   from AwardBudgetCategory__c where Award__c IN:listawdids AND BudgetCategory__c != null];
        if(awdpbclist.isEmpty()){
            for(PaymentRequest__c payReq : paymentreq){
                if(payReq.Status__c == 'Approved'){
                    for(PaymentBudgetCategory__c paymentbc : paymentbclist){
                        awdlivepaycat = new AwardBudgetCategory__c();
                        awdlivepaycat.Award__c = payReq.Award__c;
                        awdlivepaycat.ServiceArea__c = paymentbc.GrantProjectArea__c;
                        awdlivepaycat.BudgetCategory__c = paymentbc.BudgetCategory__c;
                      //awdlivepaycat.AwardedAmount__c  = paymentbc.AwardedBudget__c;
                        if(payReq.Type__c == 'Reimbursement'){
                            awdlivepaycat.YTDReimbursementPaid__c = 0;
                            awdlivepaycat.PendingPayment__c = paymentbc.RequestedExpense__c;
                            awdlivepaycat.YTDAdvanceApplied__c = paymentbc.AdvanceApplied__c;
                        }
                        if(payReq.Type__c == 'Advance'){
                            awdlivepaycat.YTDAdvancePaid__c = paymentbc.RequestedExpense__c;
                        }
                        awdpbc.add(awdlivepaycat);
                    }
                }
            }
            if(!awdpbc.isEmpty()) insert awdpbc;
        }else{  
            for(PaymentRequest__c payReq : paymentreq){
                for(PaymentRequest__c payReqOld : paymentreqold) {
                    if(payReq.Id == payReqOld.Id) {
                        if(payReq.Status__c == 'Approved' && payReqOld.Approved__c == false){
                            for(AwardBudgetCategory__c awdlivepaymentcat : awdpbclist){
                                for(PaymentBudgetCategory__c paymentbc : paymentbclist){
                                    if ((payReq.Type__c == 'Reimbursement')  && (paymentbc.AwardBudgetCategory__c == awdlivepaymentcat.Id)){
                                        awdlivepaymentcat.PendingPayment__c += paymentbc.RequestedExpense__c;
                                        if (payReq.OrganizationName__c == 'UOVC') {
                                            awdlivepaymentcat.InKindExpenditure__c += paymentbc.InKindExpenditure__c;
                                            awdlivepaymentcat.CashMatchExpenditure__c += paymentbc.CashMatchExpenditure__c;
                                        }
                                        //payReq.Approved__c = true;
                                        //awdlivepaymentcat.YTDAdvanceApplied__c = paymentbc.AdvanceApplied__c + awdlivepaymentcat.YTDAdvanceApplied__c;
                                    }
                                }
                            awdpbc.add(awdlivepaymentcat);
                            }
                        } else if(payReq.Status__c == 'Paid' && payReqOld.Paid__c == false){
                            for(AwardBudgetCategory__c awdlivepaymentcat : awdpbclist){
                                for(PaymentBudgetCategory__c paymentbc : paymentbclist){
                                    if ((payReq.Type__c == 'Reimbursement')  && (paymentbc.AwardBudgetCategory__c == awdlivepaymentcat.Id)){
                                        awdlivepaymentcat.YTDReimbursementPaid__c += paymentbc.RequestedExpense__c;
                                        awdlivepaymentcat.PendingPayment__c -= paymentbc.RequestedExpense__c;
                                        paidlist.add(payreq.id);
                                    }
                                    /*if ((payReq.Type__c == 'Advance')  && (paymentbc.BudgetCategory__c == awdlivepaymentcat.BudgetCategory__c) && (paymentbc.GrantProjectArea__c == awdlivepaymentcat.ServiceArea__c)){
                                        awdlivepaymentcat.YTDAdvancePaid__c = paymentbc.RequestedExpense__c + awdlivepaymentcat.YTDAdvancePaid__c;
                                    }*/
                                }
                            awdpbc.add(awdlivepaymentcat); 
                            }
                        } else if(payReq.Status__c == 'Rejected' && payReqOld.Rejected__c == false){
                            for(AwardBudgetCategory__c awdlivepaymentcat : awdpbclist){
                                for(PaymentBudgetCategory__c paymentbc:paymentbclist){
                                    if ((payReq.Type__c == 'Reimbursement')  && (paymentbc.AwardBudgetCategory__c == awdlivepaymentcat.Id)){
                                        awdlivepaymentcat.PendingPayment__c -= paymentbc.RequestedExpense__c;
                                    }
                                }
                            awdpbc.add(awdlivepaymentcat);
                            }
                        } else {
                            //payReq.YTDEarnedAmount__c = 1;
                        }
                    }
                }
            }
            if (paidlist != null){
            	payFINET(paidlist);
            }
            update awdpbc;
            update paybc;
        }
    }
    
    private void insertpaymentfinetcode(List<PaymentRequest__c> payreqs){
    	List<id> awdids = new List<id>();
    	List<PaymentFINETCode__c> payprgs = new List<PaymentFINETCode__c>();
    	for (PaymentRequest__c payreq : payreqs){
    		awdids.add(payreq.Award__c);
    	}
    	List<AwardFINETCode__c> awdprgs = [SELECT Id,Award__c,Amount__c,SpentAmount__c FROM AwardFINETCode__c WHERE Award__c IN: awdids];
    	for (PaymentRequest__c payreq: payreqs){
    		for (AwardFINETCode__c awdprg : awdprgs){
    			if (payreq.Award__c == awdprg.Award__c){
    				PaymentFINETCode__c payprg = new PaymentFINETCode__c();
    				payprg.PaymentRequest__c = payreq.Id;
    				payprg.AwardFINETCode__c = awdprg.Id;
    				payprg.Amount__c = awdprg.Amount__c;
    				payprg.SpentAmount__c = awdprg.SpentAmount__c;
    				payprgs.add(payprg);
    			}
    		}
    	}
    	insert payprgs;
    }
    
    private void payFINET(List<Id> payreqids){
    	List<id> awdids = new List<id>();
    	List<PaymentFINETCode__c> payprgs = [SELECT Id,AwardFINETCode__c,RequestedAmount__c FROM PaymentFINETCode__c WHERE PaymentRequest__c IN: payreqids];
    	for (PaymentFINETCode__c payprg : payprgs){
    		awdids.add(payprg.AwardFINETCode__c);
    	}
    	List<AwardFINETCode__c> awdprgs = [SELECT Id,SpentAmount__c FROM AwardFINETCode__c WHERE Award__c IN: awdids];
    	for (PaymentFINETCode__c payprg : payprgs){
    		for (AwardFINETCode__c awdprg : awdprgs){
    			if (payprg.AwardFINETCode__c == awdprg.Id){
    				awdprg.SpentAmount__c += payprg.RequestedAmount__c;
    			}
    		}
    	}
    	update payprgs;
    }
    
     // This method update the award budget category lookup on payment budget category for the payment requests created for next billing period.
    private void updateLinkedAwardBudgetCategories(){
        Set<Id> paymentIdSet = new Set<Id>();
        Set<Id> awardIdSet = new Set<Id>();
        for(PaymentRequest__c payment : (List<PaymentRequest__c>)trigger.new){
            PaymentRequest__c oldPayment = (PaymentRequest__c)trigger.oldMap.get(payment.Id);
            if(payment.Award__c != oldPayment.Award__c){
                paymentIdSet.add(payment.Id);
                awardIdSet.add(payment.Award__c);
            }
        }
        if(paymentIdSet.size() > 0){
            Map<Id, Map<Id, Id>> awardIdToABCMasterMap = new Map<Id, Map<Id, Id>>();
            Map<Id, Id> awardIdToABCListMap = new Map<Id, Id>();
            List<AwardBudgetCategory__c > abcList = [Select Id, Award__c, BudgetCategory__c from AwardBudgetCategory__c Where Award__c IN : awardIdSet AND BudgetCategory__c != null];
            for(AwardBudgetCategory__c abc : abcList){
                Map<Id, Id> awardIdToABCMap = awardIdToABCMasterMap.get(abc.Award__c);
                if(awardIdToABCMap == null){
                    awardIdToABCMap = new Map<Id, Id>();
                }
                awardIdToABCMap.put(abc.BudgetCategory__c, abc.Id);
                awardIdToABCMasterMap.put(abc.Award__c, awardIdToABCMap);
            }
            List<PaymentBudgetCategory__c> pbcList = [Select Id, AwardId__c, BudgetCategory__c from PaymentBudgetCategory__c 
                Where PaymentRequest__c IN : paymentIdSet AND PaymentRequest__r.Status__c = 'Created'];
            for(PaymentBudgetCategory__c pbc : pbcList){
                Map<Id, Id> awdIdToABCMap = awardIdToABCMasterMap.get(pbc.AwardId__c);
                if(awdIdToABCMap != null){
                    pbc.AwardBudgetCategory__c = awdIdToABCMap.get(pbc.BudgetCategory__c);
                }
            }
            if(pbcList.size() > 0){
                update pbcList;
            }
        }
    }
    
    /*Updating Indirect Costs*/
    private void updateIndirect(List<PaymentRequest__c> paymentreq) {
        List<Id> paymentId = new List<Id>();
        for (PaymentRequest__c payreq : paymentreq) {
            paymentId.add(payreq.Id);
        }
        List<PaymentBudgetCategory__c> indirectList = [SELECT Id,PaymentRequest__c FROM PaymentBudgetCategory__c WHERE PaymentRequest__c IN: paymentId AND RowNumber__c = '213'];
        for (PaymentRequest__c payreq : paymentreq) {
            for (PaymentBudgetCategory__c indirect : indirectList) {
                if (indirect.PaymentRequest__c == payreq.Id) {
                    indirect.Q1__c = payreq.IndirectQ1__c;
                    indirect.Q2__c = payreq.IndirectQ2__c;
                    indirect.Q3__c = payreq.IndirectQ3__c;
                    indirect.Q4__c = payreq.IndirectQ4__c;
                    indirect.RequestedExpense__c = indirect.Q1__c + indirect.Q2__c + indirect.Q3__c + indirect.Q4__c;
                }
            }
        }
        PaymentBudgetCategoryTriggerHelper.skipTrigger = true;
        update indirectList;
        PaymentBudgetCategoryTriggerHelper.skipTrigger = false;
    }
    
    /*---Creates task for recipient when sent back---*/
    private void approvalSendBack(List<PaymentRequest__c> paymentreq, List<PaymentRequest__c> paymentreqold) {
        List<Id> listids = new List<Id>();
        for (PaymentRequest__c payreq : paymentreq) {
            for (PaymentRequest__c payreqold : paymentreqold) {
                if (payreq.Id == payreqold.Id && payreq.Status__c == 'Change Requested' && payreq.Status__c != payreqold.Status__c) {
                    listids.add(payreq.Id);
                }
            }
        }
        if (listids.size() > 0) {
            approvalSendBackHelper(listids);
        }
    }
    
    @future
    private static void approvalSendBackHelper(List<Id> listids){
        List<PaymentRequest__c> payreqlist = [SELECT Id,Applicant__c,Name,Title__c FROM PaymentRequest__c WHERE Id IN: listids];
        for (PaymentRequest__c payreq : payreqlist) {
            GNT.TaskCreationHandler.createTasks(payreq.Applicant__c, payreq.Id, 'Redo Payment Request', payreq.Name, null, false, System.TODAY() + 7, 'Redo Payment Request', payreq.Title__c, true);
        }
    }
}