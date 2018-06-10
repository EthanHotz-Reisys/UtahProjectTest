global with sharing class USBEPaymentRequestTriggerHelper extends GNT.TriggerHelper{
    private Set<Id> paymentIds;
    private Set<Id> awardIds;
    private Set<Id> grantIds;
    private Set<id> fiscalyearIds;
    global static boolean skipTrigger = false;
    global override void processBeforeInsert() {
        if(skipTrigger == false) {
            populateIds();
            checkBudgetRevisions(Trigger.new);
            checkFiscalYear(Trigger.new);
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
            insertpaymentfinetcode(Trigger.New);
            createPaymentShares(Trigger.new);  
        }
    }
    global override void processBeforeUpdate(){
        if(skipTrigger == false) {
            populateIds();
            //checkBudgetRevisions(Trigger.new);
            //CheckBudgetValidations(Trigger.new);
            //CheckFundingAccount(Trigger.new);
            updateStatus(Trigger.new);
            waiveFunds(Trigger.New, Trigger.Old);
        }
    }
    global override void processAfterUpdate() {
        if(skipTrigger == false) {
            populateIds();
            //upsertpaymentcategorieslive((List<PaymentRequest__c>) Trigger.New);
            updateAwardYTD((List<PaymentRequest__c>) Trigger.New, Trigger.Old);
            updateLinkedAwardBudgetCategories();
            updateIndirect(Trigger.New);
            //updateQuarterlyExpenses(Trigger.New);
            //approvalSendBack(Trigger.New, Trigger.Old);
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
    
    private void checkBudgetRevisions(List<PaymentRequest__c> paymentreq){
        List<AmendmentRequest__c> budgetlist = [SELECT Id,Award__c,Award__r.CurrentRevisionStatus__c FROM AmendmentRequest__c WHERE Award__c IN: awardids AND Status__c != 'Revised'];
        for (AmendmentRequest__c budget : budgetlist){
            for (PaymentRequest__c payreq : paymentreq){
                if (payreq.Award__c == budget.Award__c && budget.Award__r.CurrentRevisionStatus__c != 'Not Started' && budget.Award__r.CurrentRevisionStatus__c != 'Active' && budget.Award__r.CurrentRevisionStatus__c != null){
                    payreq.addError('You Cannot Continue With Payment Requests Before Completing All Budget Revisions');
                }
            }
        }
    }
    
    private void checkFiscalYear(List<PaymentRequest__c> paymentreq){
        Set<Id> orgIds = new Set<Id>();
        boolean firstyear = false;
        List<Award__c> currentawards = [SELECT Id,Grant__r.ProjectPeriodStartDate__c,Grant__r.ProjectPeriodEndDate__c,Grant__r.InternalOrganization__c FROM Award__c WHERE Id IN: awardIds];
        List<USBELEACostRate__c> currentfiscalyears = [SELECT Id,Year__r.StartDate__c,Year__r.EndDate__c,Name FROM USBELeaCostRate__c WHERE Id IN: fiscalyearIds ORDER BY Year__r.StartDate__c DESC];
        for (Award__c award : currentawards){
            orgIds.add(award.Grant__r.InternalOrganization__c);
        }
        List<USBELEACostRate__c> orgFiscalYears = [SELECT Id,Year__r.StartDate__c,Year__r.EndDate__c,Account__c,Name FROM USBELEACostRate__c WHERE Account__c IN: orgIds];
        
        Map<Id,List<Date>> datemap = new Map<Id,List<Date>>();
        Map<Id,List<USBELEACostRate__c>> fiscalyearmap = new Map<Id,List<USBELEACostRate__c>>();
        
        for (USBELEACostRate__c fiscalyear : currentfiscalyears){
            datemap.put(fiscalyear.Id, new List<Date>{fiscalyear.Year__r.StartDate__c,fiscalyear.Year__r.EndDate__c});
        }
        
        for (USBELEACostRate__c fiscalyear : orgFiscalYears){
            List<USBELEACostRate__c> tmp = fiscalyearmap.get(fiscalyear.Account__c);
            if (tmp == null){
                tmp = new List<USBELEACostRate__c>();
                fiscalyearmap.put(fiscalyear.Account__c,tmp);
            }
            tmp.add(fiscalyear);
        }
        
        List<USBELEACostRate__c> availableFiscalYears = new List<USBELEACostRate__c>();
        for (Award__c award : currentawards){
            Date startDate = award.Grant__r.ProjectPeriodStartDate__c;
            Date endDate = award.Grant__r.ProjectPeriodEndDate__c;
            List<USBELEACostRate__c> fiscalyears = fiscalyearmap.get(award.Grant__r.InternalOrganization__c);
            for (USBELEACostRate__c fiscalyear : fiscalyears){
                if ((fiscalYear.Year__r.StartDate__c > startDate && fiscalYear.Year__r.StartDate__c < endDate) || (fiscalYear.Year__r.EndDate__c > startDate && fiscalYear.Year__r.StartDate__c < endDate)){
                    availableFiscalYears.add(fiscalYear);
                }
            }
        }
        
        List<USBELEACostRate__c> previousyears = new List<USBELEACostRate__c>();
        for (USBELEACostRate__c currentyear : currentfiscalyears){
            if (currentyear.Id == availableFiscalYears[0].Id){
                firstyear = true;
            }
            for (USBELEACostRate__c availableyear : availableFiscalYears){
                if (Integer.valueOf(availableyear.Name) == Integer.valueOf(currentyear.Name) - 1){
                    previousyears.add(availableyear);
                }
            }
        }
        
        List<PaymentRequest__c> previouspayreqlist = [SELECT Id,Award__c FROM PaymentRequest__c WHERE Award__c IN: awardIds AND USBELEACostRate__c IN: previousyears AND (Status__c != 'Created')]; //OR Status__c != 'Change Requested'
        
        for (PaymentRequest__c payreq : paymentreq){
            Date startDate = datemap.get(payreq.USBELeaCostRate__c)[0];
            Date endDate = datemap.get(payreq.USBELeaCostRate__c)[1];
            if (previouspayreqlist.size() == 0 && firstyear != true){
                payReq.addError('You Cannot Submit a Payment Request For This Fiscal Year Before Submitting One For Prior Fiscal Year');
            }
            if (payreq.BillingStartDate__c < startDate || payreq.BillingEndDate__c > endDate){
                payReq.addError('Expense Incurred From and Through Cannot Cross Fiscal Years');
            }
        }
    }
    
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
            if(payment.Approver1__c!= null) {
                if(shareMap.get(payment.id).containsKey(payment.Approver1__c)) {
                    //Updates the existing records to Edit if they are currently set to read
                    if(shareMap.get(payment.id).get(payment.Approver1__c).AccessLevel == 'Read') {
                        shareMap.get(payment.id).get(payment.Approver1__c).AccessLevel = 'Edit';
                        shares.add(shareMap.get(payment.id).get(payment.Approver1__c));
                    }
                } else {
                    share = new PaymentRequest__Share(parentId = payment.id, AccessLevel = 'Edit', UserOrGroupId = payment.Approver1__c, RowCause = Schema.PaymentRequest__Share.RowCause.SharetoApprover__c);
                    shares.add(share);
                    shareMap.get(payment.id).put(payment.Approver1__c, share);
                }
               
            }
            if(payment.Approver2__c!= null) {
                if(shareMap.get(payment.id).containsKey(payment.Approver2__c)) {
                    //Updates the existing records to Edit if they are currently set to read
                    if(shareMap.get(payment.id).get(payment.Approver2__c).AccessLevel == 'Read') {
                        shareMap.get(payment.id).get(payment.Approver2__c).AccessLevel = 'Edit';
                        shares.add(shareMap.get(payment.id).get(payment.Approver2__c));
                    }
                } else {
                    share = new PaymentRequest__Share(parentId = payment.id, AccessLevel = 'Edit', UserOrGroupId = payment.Approver2__c, RowCause = Schema.PaymentRequest__Share.RowCause.SharetoApprover__c);
                    shares.add(share);
                    shareMap.get(payment.id).put(payment.Approver2__c, share);
                }
               
            }
            if(payment.Approver3__c!= null) {
                if(shareMap.get(payment.id).containsKey(payment.Approver3__c)) {
                    //Updates the existing records to Edit if they are currently set to read
                    if(shareMap.get(payment.id).get(payment.Approver3__c).AccessLevel == 'Read') {
                        shareMap.get(payment.id).get(payment.Approver3__c).AccessLevel = 'Edit';
                        shares.add(shareMap.get(payment.id).get(payment.Approver3__c));
                    }
                } else {
                    share = new PaymentRequest__Share(parentId = payment.id, AccessLevel = 'Edit', UserOrGroupId = payment.Approver3__c, RowCause = Schema.PaymentRequest__Share.RowCause.SharetoApprover__c);
                    shares.add(share);
                    shareMap.get(payment.id).put(payment.Approver3__c, share);
                }
               
            }
            if(payment.Approver4__c!= null) {
                if(shareMap.get(payment.id).containsKey(payment.Approver4__c)) {
                    //Updates the existing records to Edit if they are currently set to read
                    if(shareMap.get(payment.id).get(payment.Approver4__c).AccessLevel == 'Read') {
                        shareMap.get(payment.id).get(payment.Approver4__c).AccessLevel = 'Edit';
                        shares.add(shareMap.get(payment.id).get(payment.Approver4__c));
                    }
                } else {
                    share = new PaymentRequest__Share(parentId = payment.id, AccessLevel = 'Edit', UserOrGroupId = payment.Approver4__c, RowCause = Schema.PaymentRequest__Share.RowCause.SharetoApprover__c);
                    shares.add(share);
                    shareMap.get(payment.id).put(payment.Approver4__c, share);
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
        List<PaymentBudgetCategory__c> paymentbclist = new List<PaymentBudgetCategory__c>();
        PaymentBudgetCategory__c payBudCategory;
        List<AwardBudgetCategory__c> awardbudgetcategories = [select Id,Name,BudgetCategory__c,GrantServiceArea__c,Amount1__c,GrantorAmount__c,GranteeAmount__c,BudgetPeriod__c,Award__c,GrantBudgetCategory__c,
                                                              YTDReimbursementPaid__c,PendingPayment__c,CurrentApprovedBudgetAmount__c,
                                                              AdminCostValue__c,AdminYTDReimbursementPaid__c,AdminPendingPayment__c,Award__r.ProgramBudgetTypeUSBE__c from AwardBudgetCategory__c where Award__c IN: awardIds];
        List<PaymentBudgetCategory__c> ytdpaymentlist = [SELECT Id,UpdatedYTDExpenditure__c,AwardBudgetCategory__c,PaymentRequest__r.USBELeaCostRate__c,AdminUpdatedYTDExpenditure__c FROM PaymentBudgetCategory__c
                                                         WHERE PaymentRequest__r.Award__c IN: awardIds AND PaymentRequest__r.USBELeaCostRate__c IN: fiscalyearIds AND PaymentRequest__r.IsMaster__c = true];
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
                payBudCategory.AwardedBudget__c = awdbc.CurrentApprovedBudgetAmount__c;
                for (PaymentBudgetCategory__c ytdpayment : ytdpaymentlist){
                    if (ytdpayment.AwardBudgetCategory__c == payBudCategory.AwardBudgetCategory__c && ytdpayment.PaymentRequest__r.USBELeaCostRate__c == payReq.USBELeaCostRate__c){
                        payBudCategory.YTDExpenditure__c = ytdpayment.UpdatedYTDExpenditure__c;
                        payBudCategory.AdminYTDExpenditure__c = ytdpayment.AdminUpdatedYTDExpenditure__c;
                    }
                }
                if (awdbc.Award__r.ProgramBudgetTypeUSBE__c == 'CTE') {
                    payBudCategory.AdminAwardedBudget__c = awdbc.AdminCostValue__c;
                    payBudCategory.AdminYTDReimbursementPaid__c = awdbc.AdminYTDReimbursementPaid__c;
                    payBudCategory.AdminPendingPayment__c = awdbc.AdminPendingPayment__c;
                }
                paymentbclist.add(payBudCategory);
            }
        }
        insert paymentbclist;
    }
    /* METHOD to Update the Grant ID based on Award ID*/
    private void PopulateGrantid(){
        // SOQL the parent records
         Map<Id, Award__c> awards = new Map<Id, Award__c>(); 
         if(!awardIds.isEmpty()){ 
                awards = new Map<Id, Award__c>([select id,Grant__c,Name,FOUser__c,Approver__c from Award__c where id IN: awardIds]);
         }

         for(PaymentRequest__c payreq: (list<PaymentRequest__c>)Trigger.new){
            if(payreq.Award__c != null){
              Award__c award = awards.get(payreq.Award__c);
              payreq.Grant__c = award.Grant__c ;
              payreq.FiscalOfficer__c = award.FOUser__c;
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
        List<Award__c> awardlist = [SELECT Id,PaymentApprover1__c,PaymentApprover2__c,PaymentApprover3__c,PaymentApprover4__c, Approver__c FROM Award__c WHERE Id IN: awardIds];
        System.debug('debug test : ' + awardIds + ' ||| ' + awardlist);
        for (PaymentRequest__c payreq : paymentreq) {
            for (Award__c award : awardlist){
                if (payreq.Award__c == award.Id){
                    payreq.Approver1__c = award.PaymentApprover1__c;
                    payreq.Approver2__c = award.PaymentApprover2__c;
                    payreq.Approver3__c = award.PaymentApprover3__c;
                    payreq.Approver4__c = award.PaymentApprover4__c;
                    if (award.Approver__c != null) {
                        payreq.Approver__c = award.Approver__c;
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
                List<PaymentRequest__c> ytdpayreqlist = [SELECT Id FROM PaymentRequest__c WHERE Award__c =: payreq.Award__c AND USBELeaCostRate__c =: payReq.USBELeaCostRate__c AND IsMaster__c = true];
                if(ytdpayreqlist.size() == 0) {
                    payReq.IsMaster__c = true;
                }
            } else if (payReq.Status__c == 'Approved') {
                if (payReq.TotalRequestedAmountthisAction__c != payReq.FINETAmount__c){
                    payReq.addError('FINET requested amount does not match total requested amount');
                }
            } else if (payReq.Status__c == 'Created' ) { //|| payReq.Status__c == 'Change Requested'
                payReq.DateSubmitted__c = null;
                payReq.DatePaid__c = null;
                payReq.IsMaster__c = false;
            }
        }
    }
    
    /*---Inserting or Updating YTD fields on Award Budget Category based on Payment Requests---*/
    
    private void updateAwardYTD(List<PaymentRequest__c> paymentreq, List<PaymentRequest__c> paymentreqold){
        List<Id> paidlist = new List<Id>();
        List<Id> ytdpayreqids = new List<Id>();
        AwardBudgetCategory__c awdlivepaycat;
        List<AwardBudgetCategory__c> awdpbc = new List<AwardBudgetCategory__c>();
        List<PaymentBudgetCategory__c> paybc = new List<PaymentBudgetCategory__c>();
        List<PaymentBudgetCategory__c> paymentbclist = [select id,name,GrantProjectArea__c,PaymentRequest__c,BudgetCategory__c,AwardedBudget__c,RequestedExpense__c,PendingPayment__c,AwardBudgetCategory__c,
                                                        PaymentRequest__r.USBELEACostRate__c,UpdatedYTDExpenditure__c,AdminRequestedExpenditure__c from PaymentBudgetCategory__c where PaymentRequest__c IN: paymentIds];
        List<AwardBudgetCategory__c> awdpbclist = [select id,name,Award__c,ServiceArea__c,BudgetCategory__c,GrantServiceArea__c,YTDReimbursementPaid__c,PendingPayment__c,
                                                   AdminPendingPayment__c,AdminYTDReimbursementPaid__c,Award__r.ProgramBudgetTypeUSBE__c from AwardBudgetCategory__c where Award__c IN: awardIds];
        List<PaymentRequest__c> ytdpayreqlist = [SELECT Id FROM PaymentRequest__c WHERE USBELeaCostRate__c IN: fiscalyearIds AND IsMaster__c = true];
        for (PaymentRequest__c payreq : ytdpayreqlist){
            ytdpayreqids.add(payreq.id);
        }
        List<PaymentBudgetCategory__c> ytdpaymentlist = [SELECT Id,UpdatedYTDExpenditure__c,AwardBudgetCategory__c,PaymentRequest__r.USBELEACostRate__c,AdminUpdatedYTDExpenditure__c,PaymentRequest__r.Award__r.ProgramBudgetTypeUSBE__c
                                                         FROM PaymentBudgetCategory__c WHERE PaymentRequest__c IN: ytdpayreqids];
        
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
                        if (awdlivepaymentcat.Award__r.ProgramBudgetTypeUSBE__c == 'CTE') {
                            awdlivepaymentcat.AdminPendingPayment__c += paymentbc.AdminRequestedExpenditure__c;
                        }
                    }
                    awdpbc.add(awdlivepaymentcat);
                }
            } else if(payReq.Status__c == 'Paid' && payReqOld.Status__c != 'Paid'){
                paidlist.add(payreq.id);
                for(AwardBudgetCategory__c awdlivepaymentcat : awdpbclist){
                    List<PaymentBudgetCategory__c> paymentbcs = budgetcategoryMap.get(awdlivepaymentcat.Id);
                    for(PaymentBudgetCategory__c paymentbc : paymentbcs){
                        awdlivepaymentcat.YTDReimbursementPaid__c += paymentbc.RequestedExpense__c;
                        awdlivepaymentcat.PendingPayment__c -= paymentbc.RequestedExpense__c;
                        if (awdlivepaymentcat.Award__r.ProgramBudgetTypeUSBE__c == 'CTE') {
                            awdlivepaymentcat.AdminYTDReimbursementPaid__c += paymentbc.AdminRequestedExpenditure__c;
                            awdlivepaymentcat.AdminPendingPayment__c -= paymentbc.AdminRequestedExpenditure__c;
                        }
                    }
                    awdpbc.add(awdlivepaymentcat);
                }
                for(PaymentBudgetCategory__c ytdpayment : ytdpaymentlist){
                    for(PaymentBudgetCategory__c paymentbc : paymentbclist){
                        if (paymentbc.AwardBudgetCategory__c == ytdpayment.AwardBudgetCategory__c && paymentbc.PaymentRequest__r.USBELEACostRate__c == ytdpayment.PaymentRequest__r.USBELEACostRate__c){
                            ytdpayment.UpdatedYTDExpenditure__c += paymentbc.RequestedExpense__c;
                            if (ytdpayment.PaymentRequest__r.Award__r.ProgramBudgetTypeUSBE__c == 'CTE') {
                                ytdpayment.AdminUpdatedYTDExpenditure__c += paymentbc.AdminRequestedExpenditure__c;
                            }
                            paybc.add(ytdpayment);
                        }
                    }
                }
            }/* else if(payReq.Status__c == 'Change Requested' && payReqOld.Status__c != 'Change Requested'){
                for(AwardBudgetCategory__c awdlivepaymentcat : awdpbclist){
                    List<PaymentBudgetCategory__c> paymentbcs = budgetcategoryMap.get(awdlivepaymentcat.Id);
                    for(PaymentBudgetCategory__c paymentbc : paymentbcs){
                        awdlivepaymentcat.PendingPayment__c -= paymentbc.RequestedExpense__c;
                        awdpbc.add(awdlivepaymentcat);
                    }
                }
            }*/
        }
        if (paidlist != null){
            payFINET(paidlist);
        }
        update awdpbc;
        update paybc;
    }
    
    private void insertpaymentfinetcode(List<PaymentRequest__c> payreqs){
        List<PaymentFINETCode__c> payprglist = new List<PaymentFINETCode__c>();
        List<AwardFINETCode__c> awdprglist = [SELECT Id,Award__c,Amount__c,SpentAmount__c FROM AwardFINETCode__c WHERE Award__c IN: awardIds];
        Map<Id,List<AwardFINETCode__c>> prgmap = new Map<Id,List<AwardFINETCode__c>>();
        for (AwardFINETCode__c awdprg : awdprglist){
            List<AwardFINETCode__c> tmp = prgmap.get(awdprg.Award__c);
            if (tmp == null){
                tmp = new List<AwardFINETCode__c>();
                prgmap.put(awdprg.Award__c,tmp);
            }
            tmp.add(awdprg);
        }
        for (PaymentRequest__c payreq: payreqs){
            List<AwardFINETCode__c> awdprgs = prgmap.get(payreq.Award__c);
            if (awdprgs != null){
                for (AwardFINETCode__c awdprg : awdprgs){
                    PaymentFINETCode__c payprg = new PaymentFINETCode__c();
                    payprg.PaymentRequest__c = payreq.Id;
                    payprg.AwardFINETCode__c = awdprg.Id;
                    payprg.Amount__c = awdprg.Amount__c;
                    payprg.SpentAmount__c = awdprg.SpentAmount__c;
                    payprglist.add(payprg);
                }
            }
        }
        insert payprglist;
    }
    
    private void payFINET(List<Id> payreqids){
        List<id> awdids = new List<id>();
        List<PaymentFINETCode__c> payprgs = [SELECT Id,AwardFINETCode__c,RequestedAmount__c FROM PaymentFINETCode__c WHERE PaymentRequest__c IN: payreqids];
        for (PaymentFINETCode__c payprg : payprgs){
            awdids.add(payprg.AwardFINETCode__c);
        }
        List<AwardFINETCode__c> awdprgs = [SELECT Id,SpentAmount__c FROM AwardFINETCode__c WHERE Id IN: awdids];
        for (PaymentFINETCode__c payprg : payprgs){
            for (AwardFINETCode__c awdprg : awdprgs){
                if (payprg.AwardFINETCode__c == awdprg.Id){
                    awdprg.SpentAmount__c += payprg.RequestedAmount__c;
                }
            }
        }
        update awdprgs;
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
        List<PaymentBudgetCategory__c> indirectList = [SELECT Id,PaymentRequest__c FROM PaymentBudgetCategory__c WHERE PaymentRequest__c IN: paymentIds AND RowNumber__c = '599'];
        Map<Id,List<PaymentBudgetCategory__c>> budgetcategoryMap = new Map<Id,List<PaymentBudgetCategory__c>>();
        for (PaymentBudgetCategory__c indirect : indirectList){
            List<PaymentBudgetCategory__c> tmp = budgetcategoryMap.get(indirect.PaymentRequest__c);
            if(tmp == null){
                tmp = new List<PaymentBudgetCategory__c>();
                budgetcategoryMap.put(indirect.PaymentRequest__c,tmp);
            }
            tmp.add(indirect);
        }
        for (PaymentRequest__c payreq : paymentreq) {
            List<PaymentBudgetCategory__c> budgetcategories = budgetcategoryMap.get(payreq.Id);
            
            if (budgetcategories != null){
                for (PaymentBudgetCategory__c budgetcategory : budgetcategories) {
                        budgetcategory.RequestedExpense__c = payreq.Indirect__c;
                        budgetcategory.AdminRequestedExpenditure__c = payreq.AdminIndirect__c;
                }
            }
        }
        PaymentBudgetCategoryTriggerHelper.skipTrigger = true;
        update indirectList;
        PaymentBudgetCategoryTriggerHelper.skipTrigger = false;
    }
    
    /*Updating Updated Quarterly Expenses*/
    /*private void updateQuarterlyExpenses(List<PaymentRequest__c> paymentreq) {
        List<PaymentBudgetCategory__c> masterpbcList = [SELECT Id,PaymentRequest__c,AwardBudgetCategory__c,Q1__c,Q2__c,Q3__c,Q4__c,PaymentRequest__r.USBELEACostRate__c FROM PaymentBudgetCategory__c
                                                        WHERE PaymentRequest__r.Award__c IN: awardIds AND PaymentRequest__r.USBELEACostRate__c IN: fiscalYearIds AND PaymentRequest__r.Status__c = 'Paid' AND PaymentRequest__r.IsMaster__c = true];
        List<PaymentBudgetCategory__c> pbcList = [SELECT Id,PaymentRequest__c,AwardBudgetCategory__c,Q1__c,Q2__c,Q3__c,Q4__c,PaymentRequest__r.USBELEACostRate__c FROM PaymentBudgetCategory__c
                                                  WHERE PaymentRequest__r.Award__c IN: awardIds AND PaymentRequest__r.USBELEACostRate__c IN: fiscalYearIds AND PaymentRequest__r.Status__c = 'Paid' AND PaymentRequest__r.IsMaster__c = false];
        for (PaymentBudgetCategory__c masterpbc: masterpbcList) {
            masterpbc.UpdatedQ1__c = masterpbc.Q1__c;
            masterpbc.UpdatedQ2__c = masterpbc.Q2__c;
            masterpbc.UpdatedQ3__c = masterpbc.Q3__c;
            masterpbc.UpdatedQ4__c = masterpbc.Q4__c;
            for (PaymentBudgetCategory__c pbc : pbcList) {
                if (masterpbc.AwardBudgetCategory__c == pbc.AwardBudgetCategory__c && masterpbc.PaymentRequest__r.USBELEACostRate__c == pbc.PaymentRequest__r.USBELEACostRate__c) {
                    masterpbc.UpdatedQ1__c += pbc.Q1__c;
                    masterpbc.UpdatedQ2__c += pbc.Q2__c;
                    masterpbc.UpdatedQ3__c += pbc.Q3__c;
                    masterpbc.UpdatedQ4__c += pbc.Q4__c;
                }
            }
        }
        PaymentBudgetCategoryTriggerHelper.skipTrigger = true;
        update masterpbcList;
        PaymentBudgetCategoryTriggerHelper.skipTrigger = false;
    }*/
    
    /*---Creates task for recipient when sent back---*/
    /*
    private void approvalSendBack(List<PaymentRequest__c> paymentreq, List<PaymentRequest__c> paymentreqold) {
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
    }
    */
    private void waiveFunds(List<PaymentRequest__c> paymentreq, List<PaymentRequest__c> paymentreqold) {
        List<Id> listids = new List<Id>();
        for (PaymentRequest__c payreq : paymentreq) {
            for (PaymentRequest__c payreqold : paymentreqold) {
                if (payreq.Type__c == 'Waiver' && payreq.Id == payreqold.Id && payreq.Status__c == 'Waived' && payreq.Status__c != payreqold.Status__c) {
                    listids.add(payreq.id);
                }
            }
        }
        
        if (listids.size() > 0){
            PaymentRequest__c payreq = [SELECT Id FROM PaymentRequest__c WHERE Id IN: listids LIMIT 1];
            Award__c award = [SELECT Id,Status__c FROM Award__c WHERE Id =: payreq.Award__c LIMIT 1];
            List<AwardBudgetCategory__c> abclist = [SELECT Id,CurrentApprovedBudgetAmount__c,RemainingBudget__c FROM AwardBudgetCategory__c WHERE Award__c =: award.Id];
            SystemContextMethodsHelper SystemContextMethodsHelper = new SystemContextMethodsHelper();
            award.Waived__c = true;
            payreq.Status__c = 'Waived';
            for(AwardBudgetCategory__c abc : abclist){
                abc.CurrentApprovedBudgetAmount__c -= abc.RemainingBudget__c;
            }
            AwardBudgetCategoryTriggerHelper.skipTrigger = true;
            update abclist;
            AwardTriggerHelper.skipTrigger = true;
            SystemContextMethodsHelper.updateAwards(new List<Award__c>{award});
        }
    }
}