global with sharing class InternalPaymentSubmissionHelper extends GNT.DynamicLayoutActionRedirect {
    String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
    Integer count = 0;
    global override PageReference whenClicked(){
        Savepoint sp = Database.setSavepoint();
        List<String> errors = new List<String>();
        try{
            Id recordId = apexpages.currentpage().getparameters().get('id');
            PaymentRequest__c paymentreq = [SELECT Id,Name,Title__c,Status__c,Approver__c,RequestedAmountthisAction__c,RequestSubmittedDate__c,Applicant__r.Email,Award__r.Application__r.Announcement__r.ProgramIncomeTrackingRequired__c,
                                            Award__r.ProgramCode__r.ProgramIncomeTrackingRequired__c,YTDEarnedAmount__c,YTDDisbursedAmount__c,USBELEACostRate__c,Grant__r.ExternalOrgName__c,Award__c,OwnerId,TermsAgreement__c,Grant__r.Program__r.ProgramPathway__c
                                            FROM PaymentRequest__c WHERE Id =: recordId LIMIT 1];
            List<PaymentRequest__c> pendingwaiver = [SELECT Id FROM PaymentRequest__c WHERE Award__c =: paymentreq.Award__c AND Type__c = 'Waiver'];
            List<Attachment> attachmentlist = [SELECT id FROM Attachment WHERE ParentId = :recordId];
            List<MatchTracker__c> matchlist = [SELECT id,name,MatchType__c,PaymentRequest__c FROM MatchTracker__c WHERE PaymentRequest__c =:recordId];
            SystemContextMethodsHelper SystemContextMethodsHelper = new SystemContextMethodsHelper();
            PaymentRequest__c payment = SystemContextMethodsHelper.getPaymentRequest(recordId);
            boolean budgeterror = false;
            boolean pendingerror = false;
            if (paymentreq.Grant__r.ExternalOrgName__c == 'USBE' && paymentreq.Grant__r.Program__r.ProgramPathway__c.contains('Fed')){
                String programkey = payment.Grant__r.Program__r.ProgramKey__c;
                List<String> previousprograms = new List<String>();
                if (programkey != null) {
                    String delims = '_+';
                    String[] tokens = programkey.split(delims);
                    String programname = tokens[0];
                    for (Integer i = 1; i < (tokens.size() - 1); i++) {
                      programname += '_' + tokens[i];
                    }
                    Integer year = Integer.valueOf(tokens[tokens.size() - 1]);
                    previousprograms.add(programname + '_' + String.valueOf(year - 1));
                    previousprograms.add(programname + '_' + String.valueOf(year - 2));
                }
                List<Award__c> awardlist = SystemContextMethodsHelper.getAwardsFromProgramKey(previousprograms);
                for (Award__c awards : awardlist) {
                    if (awards.RemainingBudget__c != 0) {
                        budgeterror = true;
                    }
                    if (awards.PendingPayment__c != 0) {
                        pendingerror = true;
                    }
                }
            }
            if (paymentreq.TermsAgreement__c != 'I Agree'){
                errors.add('You must agree to the terms and conditions');
            }
            if (paymentreq.RequestedAmountthisAction__c < 1){
                errors.add('Requested amount cannot be 0');
            }
            if (pendingwaiver.size() > 0) {
                errors.add('You cannot submit a payment request for an award with a waiver');
            }
            if (budgeterror == true) {
                errors.add('Please use up or waive remaining funds in previous related grants');
            }
            if (pendingerror == true) {
                errors.add('Please wait until pending payments are processed in previous related grants');
            }
            if (paymentreq.USBELEACostRate__c == null && paymentreq.Grant__r.ExternalOrgName__c == 'USBE') {
                errors.add('Please fill in Fiscal Year field');
            }
            if (attachmentlist.size() < 1 && paymentreq.Grant__r.ExternalOrgName__c == 'UOVC' ){
                //errors.add ('Please add Expense attachment before you submit Reimbursement request');
                errors.add (GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-33907'));
            }
            if(paymentreq.Award__r.Application__r.Announcement__r.ProgramIncomeTrackingRequired__c == true || paymentreq.Award__r.ProgramCode__r.ProgramIncomeTrackingRequired__c == true){
                for(MatchTracker__c match: matchlist){
                    if(match.MatchType__c == 'Program Income')
                    count = count + 1;
                }
                if(count ==0){
                    //errors.add ('Please add at least one program income entry in the Match Tracking section before you submit Reimbursement Request');
                    errors.add (GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-56080'));
                }
            }
            if (paymentreq.Approver__c!=null && paymentreq.Grant__r.ExternalOrgName__c == 'USBE'){
                if (String.valueof(paymentreq.Approver__c).equalsIgnoreCase(String.valueOf((UserInfo.getUserId())))) {
                    errors.add('The internal approver cannot submit a budget revision. The submitter and the internal approver must be two different people.');
                }
            }
            if(paymentreq.YTDEarnedAmount__c >=1 && paymentreq.YTDDisbursedAmount__c >=1 ){
                if(paymentreq.YTDEarnedAmount__c <= paymentreq.YTDDisbursedAmount__c ){
                    //errors.add ('YTD disbursed amount should be less than equal to YTD earned amount.');
                    errors.add (GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-31876'));
                }
            }
            if(errors.size() > 0){
              for(String error: errors){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, error));
              } 
            }
            else{
                if(paymentreq.Status__c=='Change Requested'){
                    List<Task> taskList = [SELECT WhatId,Status,OwnerId FROM Task where WhatId=:paymentreq.Id and Status IN ('In Progress', 'Not Started')];
                    if (!taskList.isEmpty()) {
                        for (Task t : taskList) {
                            if (t.OwnerId == paymentreq.Applicant__c) {
                                t.Status = 'Completed';
                            }
                        }
                        update taskList;
                    }
                }
                GNT.TaskCreationHandler.createApprovalProcessTasks(paymentreq.Id, 'Recipient Review Payment Request', paymentreq.Name, null, System.TODAY() + 7, paymentreq.Title__c, true);
                PageReference p = Page.PaymentRequestView;
                p.getParameters().put('id', paymentreq.Id);
                p.setRedirect(true);
                return p;
               }
             return null;
          }catch(Exception e){
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }
    }
}