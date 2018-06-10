global with sharing class UOVCPaymentRequestTriggerHelper extends GNT.TriggerHelper{
    private Set<Id> paymentIds;
    private Set<Id> awardIds;
    private Set<Id> grantIds;
    private Set<id> fiscalyearIds;
    global static boolean skipTrigger = false;
    global override void processBeforeInsert() {
        if(skipTrigger == false) {
            populateIds();
            //checkBudgetRevisions(Trigger.new);
            PopulateGrantid();
            PopulateRoles(Trigger.New);
            GNT.NameTemplateTriggerHelper.beforeInsert(); 
        }   
    }
    global override void processAfterInsert() {
        if(skipTrigger == false) {
            populateIds();
            insertpaymentserviceareas((List<PaymentRequest__c>) Trigger.New);
            insertpaymentbudgetcategories(Trigger.New);
            createPaymentShares(Trigger.new);  
        }
    }
    global override void processBeforeUpdate(){
        if(skipTrigger == false) {
            populateIds();
            //checkBudgetRevisions(Trigger.new);
            CheckBudgetValidations(Trigger.new);
            updateStatus(Trigger.new);
        }
    }
    global override void processAfterUpdate() {
        if(skipTrigger == false) {
            populateIds();
             updateAwardYTD((List<PaymentRequest__c>) Trigger.New, Trigger.Old);
             updateLinkedAwardBudgetCategories();
             updateIndirect(Trigger.New);
             //approvalSendBack(Trigger.New, Trigger.Old);
             createPaymentShares(Trigger.new);
        }
    }
    
    private void populateIds(){
        paymentIds = new Set<Id>();
        awardIds = new Set<Id>();
        grantIds = new Set<Id>();
        fiscalyearIds = new Set<id>();
        for (PaymentRequest__c payreq : (List<PaymentRequest__c>)Trigger.New){
            paymentIds.add(payreq.Id);
            awardIds.add(payreq.Award__c);
            grantIds.add(payreq.Grant__c);
            fiscalyearIds.add(payreq.USBELeaCostRate__c);
        }
    }
    
    /*private void checkBudgetRevisions(List<PaymentRequest__c> paymentreq){
        List<AmendmentRequest__c> budgetlist = [SELECT Id,Award__c FROM AmendmentRequest__c WHERE Award__c IN: awardids AND Status__c != 'Revised'];
        if (budgetlist.size() > 0){
            for (PaymentRequest__c payreq : paymentreq){
                for (AmendmentRequest__c budget : budgetlist){
                    if (payreq.Award__c == budget.Award__c){
                        payreq.addError('Complete All Budget Revisions Before Continuing With Payment Requests');
                    }
                }
            }
        }
    }*/
    
    private void CheckBudgetValidations(List<PaymentRequest__c> paymentRequestList){
       List<AwardPaymentBudgetCategory__c> awdpbclist = [select id,name,Award__c,AwardedAmount__c,GrantProjectArea__c,BudgetCategory__c,YTDReimbursementPaid__c
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

    private void createPaymentShares(List<PaymentRequest__c> payments) {
        Map<String, Map<String, PaymentRequest__Share>> shareMap = new Map<String, Map<String, PaymentRequest__Share>>();
        for(PaymentRequest__c payment: payments) {
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
        List<PaymentRequest__c> paymentslist = [select id,FiscalOfficer__c,Approver__c,Applicant__c,ProgramManager__c,GrantMonitor__c,ProgramOwner__c,Approver1__c,Approver2__c,Approver3__c,Approver4__c,Grant__r.InternalOrganization__c
                                                  from Paymentrequest__c where id IN:paymentIds];
        Set<Id> orgIds = new Set<Id>();
        for (PaymentRequest__c payment : paymentslist){
            orgIds.add(payment.Grant__r.InternalOrganization__c);
        }
        List<User> userList = [SELECT Id,Organization__c FROM User WHERE Organization__c IN: orgIds];
        Map<Id,List<User>> userMap = new Map<Id,List<User>>();
        for (User u : userList){
            List<User> tmp = userMap.get(u.Organization__c);
            if (tmp == null){
                tmp = new List<User>();
                userMap.put(u.Organization__c,tmp);
            }
            tmp.add(u);
        }
        
        for(PaymentRequest__c payment: paymentslist) {
            List<User> users = userMap.get(payment.Grant__r.InternalOrganization__c);
            
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
            
            if (users != null){
                for (User u : users){
                    if(!shareMap.get(payment.id).containsKey(u.Id)) {
                        share = new PaymentRequest__Share(parentId = payment.id, AccessLevel = 'Read', UserOrGroupId = u.Id, RowCause = Schema.PaymentRequest__Share.RowCause.SharetoOrganization__c);
                        shares.add(share);
                        shareMap.get(payment.id).put(u.Id, share);
                    }
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
    
    /*----Inserting Payment Service Areas-----*/
    private void insertpaymentserviceareas(List<PaymentRequest__c> paymentreq){
        PaymentServiceArea__c payServ;
        List<GrantServiceArea__c> grantServList;
        List<PaymentServiceArea__c> payServList;
        grantServList = [Select ServiceArea__c from GrantServiceArea__c where Grant__c IN :grantIds] ;
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
        Map<Id,List<AwardBudgetCategory__c>> budgetcategorymap = new Map<Id,List<AwardBudgetCategory__c>>();
        for (AwardBudgetCategory__c bc : awardbudgetcategories){
            List<AwardBudgetCategory__c> tmp = budgetcategoryMap.get(bc.Award__c);
            if (tmp == null){
                tmp = new List<AwardBudgetCategory__c>();
                budgetcategoryMap.put(bc.Award__c,tmp);
            }
            tmp.add(bc);
        }
        
        for(PaymentRequest__c payReq : paymentreq){
            List<AwardBudgetCategory__c> budgetcategories = budgetcategorymap.get(payReq.Award__c);
            for(AwardBudgetCategory__c awdbc: budgetcategories){
                payBudCategory = new PaymentBudgetCategory__c();
                payBudCategory.PaymentRequest__c = payReq.id;
                payBudCategory.BudgetCategory__c = awdbc.BudgetCategory__c;
                payBudCategory.GranteeShare__c = awdbc.GranteeAmount__c;
                payBudCategory.GrantProjectArea__c = awdbc.GrantServiceArea__c;
                payBudCategory.BudgetPeriod__c = awdbc.BudgetPeriod__c;
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
        if(!paymentbclist.isEmpty()) insert paymentbclist;
    }
    /* METHOD to Update the Grant ID based on Award ID*/
    private void PopulateGrantid(){
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
        List<RolesAndResponsibilities__c> listroles = [SELECT Id,Award__c,BusinessRole__c,Name__c FROM RolesAndResponsibilities__c WHERE Award__c IN: awardIds];
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
            } else if (payReq.Status__c == 'Approved') {
            } else if (payReq.Status__c == 'Created' || payReq.Status__c == 'Change Requested') {
                payReq.DateSubmitted__c = null;
                payReq.DatePaid__c = null;
                payReq.IsMaster__c = false;
            }
        }
    }
    
    /*---Inserting or Updating YTD fields on Award Budget Category based on Payment Requests---*/
    
    private void updateAwardYTD(List<PaymentRequest__c> paymentreq, List<PaymentRequest__c> paymentreqold){
        AwardBudgetCategory__c awdlivepaycat;
        List<AwardBudgetCategory__c> awdpbc = new List<AwardBudgetCategory__c>();
        List<PaymentBudgetCategory__c> paybc = new List<PaymentBudgetCategory__c>();
        List<PaymentBudgetCategory__c> paymentbclist = [select id,name,GrantProjectArea__c,PaymentRequest__c,BudgetCategory__c,AwardedBudget__c,RequestedExpense__c,PendingPayment__c,AwardBudgetCategory__c,
                                                        InKindExpenditure__c,CashMatchExpenditure__c from PaymentBudgetCategory__c where PaymentRequest__c IN: paymentIds];
        List<AwardBudgetCategory__c> awdpbclist = [select id,name,Award__c,ServiceArea__c,BudgetCategory__c,GrantServiceArea__c,YTDReimbursementPaid__c,PendingPayment__c,InKindExpenditure__c,CashMatchExpenditure__c,
                                                   Award__r.ProgramBudgetTypeUSBE__c from AwardBudgetCategory__c where Award__c IN: awardIds];
        
        Map<Id,List<PaymentBudgetCategory__c>> budgetcategoryMap = new Map<Id,List<PaymentBudgetCategory__c>>();
        for (PaymentBudgetCategory__c bc : paymentbclist){
            List<PaymentBudgetCategory__c> tmp = budgetcategoryMap.get(bc.Id);
            if (tmp == null){
                tmp = new List<PaymentBudgetCategory__c>();
                budgetcategoryMap.put(bc.AwardBudgetCategory__c,tmp);
            }
            tmp.add(bc);
        }
        for(PaymentRequest__c payReq : paymentreq){
            PaymentRequest__c payReqOld = (PaymentRequest__c) Trigger.oldMap.get(payReq.Id);
            if(payReq.Status__c == 'Approved' && payReqOld.Status__c != 'Approved'){
                for(AwardBudgetCategory__c awdlivepaymentcat : awdpbclist){
                    List<PaymentBudgetCategory__c> paymentbcs = budgetcategoryMap.get(awdlivepaymentcat.Id);
                    for(PaymentBudgetCategory__c paymentbc : paymentbcs){
                        awdlivepaymentcat.PendingPayment__c += paymentbc.RequestedExpense__c;
                        awdlivepaymentcat.InKindExpenditure__c += paymentbc.InKindExpenditure__c;
                        awdlivepaymentcat.CashMatchExpenditure__c += paymentbc.CashMatchExpenditure__c;
                    }
                    awdpbc.add(awdlivepaymentcat);
                }
            } else if(payReq.Status__c == 'Paid' && payReqOld.Status__c != 'Paid'){
                for(AwardBudgetCategory__c awdlivepaymentcat : awdpbclist){
                    List<PaymentBudgetCategory__c> paymentbcs = budgetcategoryMap.get(awdlivepaymentcat.Id);
                    for(PaymentBudgetCategory__c paymentbc : paymentbcs){
                        awdlivepaymentcat.YTDReimbursementPaid__c += paymentbc.RequestedExpense__c;
                        awdlivepaymentcat.PendingPayment__c -= paymentbc.RequestedExpense__c;
                    }
                awdpbc.add(awdlivepaymentcat); 
                }
            }
            update awdpbc;
            update paybc;
        }
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
                    awardIdToABCMasterMap.put(abc.Award__c, awardIdToABCMap);
                }
                awardIdToABCMap.put(abc.BudgetCategory__c, abc.Id);
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
        //List<PaymentBudgetCategory__c> indirectList = [SELECT Id,PaymentRequest__c,RequestedExpense__c FROM PaymentBudgetCategory__c WHERE PaymentRequest__c IN: paymentIds AND RowNumber__c = '213'];
        //for (PaymentRequest__c payreq : paymentreq) {
        //    for (PaymentBudgetCategory__c indirect : indirectList) {
        //        if (indirect.PaymentRequest__c == payreq.Id) {
        //            indirect.Q1__c = payreq.IndirectQ1__c;
        //            indirect.Q2__c = payreq.IndirectQ2__c;
        //            indirect.Q3__c = payreq.IndirectQ3__c;
        //            indirect.Q4__c = payreq.IndirectQ4__c;
        //            indirect.RequestedExpense__c = indirect.Q1__c + indirect.Q2__c + indirect.Q3__c + indirect.Q4__c;
        //        }
        //    }
        //}
        //PaymentBudgetCategoryTriggerHelper.skipTrigger = true;
        //update indirectList;
        //PaymentBudgetCategoryTriggerHelper.skipTrigger = false;
        SystemContextMethodsHelper contextHelper = new SystemContextMethodsHelper();
        contextHelper.updateIndirectCosts(paymentreq);
    }
    
    /*---Creates task for recipient when sent back---*/
    /*private void approvalSendBack(List<PaymentRequest__c> paymentreq, List<PaymentRequest__c> paymentreqold) {
        List<Id> listids = new List<Id>();
        for (PaymentRequest__c payreq : paymentreq) {
            PaymentRequest__c payreqold = (PaymentRequest__c) Trigger.oldMap.get(payreq.Id);
            if (payreq.Status__c == 'Change Requested' && payreq.Status__c != payreqold.Status__c) {
                listids.add(payreq.Id);
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
    }*/
}