global class PaymentRequestsTasksHandler extends GNT.BatchApexHandler{
    Integer recordCount;

    global override String getQuery() {
        String query = 'Select Id,TermAndCondition__r.Award__c,TermAndCondition__r.Award__r.DUNSNumber__c,TermAndCondition__r.Award__r.POUser__c,TaskCreated__c,TermAndCondition__r.Award__r.EIN__c,TermAndCondition__r.Award__r.FederalGrantAwardIdFAIN__c,'+
                'TermAndCondition__r.Frequency__c, TermAndCondition__r.ReportingFrequency__c, TermAndCondition__r.Award__r.Grant__r.InternalOrganization__c,'+
                'TermAndCondition__r.Award__r.Grant__r.ExternalOrganization__c, TermAndCondition__r.Award__r.GrantorOrganization__c,TermAndCondition__r.Award__r.Grant__r.GrantNumber__c, TermAndCondition__r.Award__r.Grant__r.Program__r.PaymentRequestSetting__c,'+
                'TermAndCondition__r.ReportName__c, EndDate__c,Status__c,TermAndCondition__r.Award__r.Grant__r.GranteePOC__c, StartDate__c, TermAndCondition__r.Award__r.Grant__c,TermAndCondition__r.Category__c,TermAndCondition__r.Award__r.Grant__r.Name from TermConditionSchedule__c where TaskCreationDate__c=LAST_N_DAYS:2 and TaskCreated__c=false AND TermAndCondition__r.Award__r.RecordType.Name=\'Grantor\' and RecordType.Name=\'Payment Request\'';
        system.debug('*** Lenght of query' + query.length());
        return query;
    }

    global override void execute(List<SObject> scope1){
        Savepoint sp = Database.setSavepoint();
        try{
            List<TermConditionSchedule__c> scope = (List<TermConditionSchedule__c>)scope1;
            List<PaymentRequest__c> lstPaymentRequests=new List<PaymentRequest__c>();
            system.debug('scope '+scope);
            ProgressReportsConfig__c progressRptCfg = ProgressReportsConfig__c.getInstance('Grantor_Reports');
            Integer taskCreationAge = (Integer)progressRptCfg.TaskCreationAge__c;
            List<Task> paymentRequestTasks = new List<Task>();
            List<PaymentRequest__c> paymentrqstlist = preparePaymentRequests(scope);

            /*
            List<PaymentRequest__c> autoSubmitPayment = new List<PaymentRequest__c>();
            List<PaymentRequest__c> manualSubmitPayment = new List<PaymentRequest__c>();
            for(PaymentRequest__c pr : paymentrqstlist){
              if(pr.PaymentRequestSetting__c == '1/12th'){
                autoSubmitPayment.add(pr);
              }else{
                manualSubmitPayment.add(pr);
              }
            }

            for(PaymentRequest__c pr : autoSubmitPayment){
              pr.RequestSubmittedDate__c=System.Today();
              GNT.TaskCreationHandler.createApprovalProcessTasks(pr.Id, 'Review Payment Request', pr.Name, null, System.TODAY() + 7, pr.Title__c, true);
            }
            */

            for(PaymentRequest__c paymentrqst : paymentrqstlist){
                List<Task> paymentRequestRevisionTasks = GNT.TaskCreationHandler.createTasks(paymentrqst.Applicant__c,
                        paymentrqst.id,'Create Payment Request',
                        paymentrqst.Title__c, null, false, null,
                        'Approval', paymentrqst.Title__c, false);
                if(paymentRequestRevisionTasks != null && paymentRequestRevisionTasks.size() > 0) {
                    paymentRequestTasks.add(paymentRequestRevisionTasks[0]);
                    paymentrqst.status__c='Created';
                    lstPaymentRequests.add(paymentrqst);
                }

            }
            insert paymentRequestTasks;
            update paymentrqstlist;
            if(paymentrqstlist.size()>0)
            {
                updateTermConditionSchedules(scope);
            }
        }
        catch(Exception exc)  {
            System.debug('An exception Occured while running the batch  '+exc);
            Database.rollback(sp);
        }
    }

    // In the Finish method, the list of notification users and batch runner (user) is sent a status mail when any deactivation occurs
    global override void finish(){
        //List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();    //Email needs to be sent only if number of inactive users >0
        String msgDetails = 'Task Completed for '+ Date.today();
        msgDetails+='<br>  Total number of Reports created : '+recordCount;
        /*Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTargetObjectId(UserInfo.getUserId());
        mail.saveAsActivity = false;            
        mail.setSubject(' PaymentRequestsTasksHandler has completed ' ); 
        system.debug(msgDetails);
        mail.setPlainTextBody(msgDetails);
        mails.add(mail); 
        Messaging.sendEmail(mails);*/
        new GNT.EmailFeeder().TargetObjectId(UserInfo.getUserId()).htmlBody(msgDetails).subject(' PaymentRequestsTasksHandler has completed ').send();
    }

    private List<PaymentRequest__c> preparePaymentRequests(List<TermConditionSchedule__c> lstSchedules){
        /*
        Set<Id> awardIds = new Set<Id>();
        for(TermConditionSchedule__c termSchedule : lstSchedules){
            if(!awardIds.contains(termSchedule.TermAndCondition__r.Award__c)){
                awardIds.add(termSchedule.TermAndCondition__r.Award__c);
            }
        }
        Map<Id, Award__c> awardsMap = new Map<Id, Award__c>([SELECT Id, ObligatedAwardAmount__c FROM Award__c WHERE Id IN :awardIds]);
        AggregateResult[] aggs = [SELECT COUNT(Id) paymentNum, SUM(RequestAmountForFormula__c) awarded, SUM(Catchup__c) awardedCatchup, Award__c awardId FROM PaymentRequest__c WHERE Award__c IN :awardIds GROUP BY Award__c];
        Map<Id, Integer> paymentCount = new Map<Id, Integer>();
        Map<Id, Double> paymentSum = new Map<Id, Double>();
        Map<Id, Double> catchUpSum = new Map<Id, Double>();
        for(AggregateResult agg : aggs){
            paymentCount.put(String.valueOf(agg.get('awardId')), Integer.valueOf(agg.get('paymentNum')));
            paymentSum.put(String.valueOf(agg.get('awardId')), (Double)agg.get('awarded'));
            catchUpSum.put(String.valueOf(agg.get('awardId')), (Double)agg.get('awardedCatchup'));
        }
        */
        List<PaymentRequest__c> lstpayments= new List<PaymentRequest__c>();
        List<TermCondition__c> terms = new List<TermCondition__c>();
        for(TermConditionSchedule__c termSchedule : lstSchedules){
            System.debug('termStermSchedule.TermAndCondition__r.Award__r.Grant__c- '+ termSchedule.TermAndCondition__r.Award__r.Grant__c);
            System.debug('TermAndCondition__r.Award__r.POUser__c- '+ termSchedule.TermAndCondition__r.Award__r.POUser__c);
            System.debug('termStermSchedule.TermAndCondition__r.Award__r.Grant__c- '+ termSchedule.TermAndCondition__r.Award__r.Grant__r.GranteePOC__c);
            PaymentRequest__c paymentrequest = new PaymentRequest__c();
            paymentrequest.Award__c=termSchedule.TermAndCondition__r.Award__c;
            paymentrequest.Grant__c=termSchedule.TermAndCondition__r.Award__r.Grant__c;
            paymentrequest.status__c='Created';
            paymentrequest.PaymentRequestCreation__c ='Planned';
            paymentrequest.ProgramManager__c=termSchedule.TermAndCondition__r.Award__r.POUser__c;
            paymentrequest.BillingStartDate__c = termSchedule.StartDate__c;
            paymentrequest.Type__c = 'Reimbursement';
            paymentrequest.Applicant__c = termSchedule.TermAndCondition__r.Award__r.Grant__r.GranteePOC__c;
            //paymentrequest.ownerid =  termSchedule.TermAndCondition__r.Award__r.Grant__r.GranteePOC__c;
            paymentrequest.BillingEndDate__c  =  termSchedule.EndDate__c;
            paymentrequest.Title__c= termSchedule.TermAndCondition__r.ReportName__c;
            paymentrequest.RecipientsAccountNumber__c=termSchedule.TermAndCondition__r.Award__r.Grant__r.GrantNumber__c;
            paymentrequest.PaymentRequestSetting__c = termSchedule.TermAndCondition__r.Award__r.Grant__r.Program__r.PaymentRequestSetting__c;
            /*
            if(termSchedule.TermAndCondition__r.Award__r.Grant__r.Program__r.PaymentRequestSetting__c == '1/12th'){
              if(aggs.size() == 0){
                  paymentrequest.RequestAmountForFormula__c = awardsMap.get(termSchedule.TermAndCondition__r.Award__c).ObligatedAwardAmount__c / 12;
              }else{
                  Double originalPay = awardsMap.get(termSchedule.TermAndCondition__r.Award__c).ObligatedAwardAmount__c / 12 * paymentCount.get(termSchedule.TermAndCondition__r.Award__c);
                  if(originalPay > (paymentSum.get(termSchedule.TermAndCondition__r.Award__c) + catchUpSum.get(termSchedule.TermAndCondition__r.Award__c))){
                      paymentrequest.Catchup__c = originalPay - paymentSum.get(termSchedule.TermAndCondition__r.Award__c) - catchUpSum.get(termSchedule.TermAndCondition__r.Award__c);
                      paymentrequest.RequestAmountForFormula__c = awardsMap.get(termSchedule.TermAndCondition__r.Award__c).ObligatedAwardAmount__c / 12;
                  }else{
                      paymentrequest.RequestAmountForFormula__c = (awardsMap.get(termSchedule.TermAndCondition__r.Award__c).ObligatedAwardAmount__c - paymentSum.get(termSchedule.TermAndCondition__r.Award__c) - catchUpSum.get(termSchedule.TermAndCondition__r.Award__c)) / (12 - paymentCount.get(termSchedule.TermAndCondition__r.Award__c));
                  }
              }
            }
            */
            System.debug('Create  Progress Reports now-- '+ paymentrequest);
            lstpayments.add(paymentrequest);
        }
        recordCount=lstpayments.size();
        if(lstpayments.size()>0){
            insert lstpayments;
        }
        return lstpayments;
    }

    // Updating the Term Condition Schedule records so that duplicate reports are not created
    private  void updateTermConditionSchedules(List<TermConditionSchedule__c> lstSchedules){

        for(TermConditionSchedule__c termSchedule : lstSchedules)// Getting list of TnC
        {

            termSchedule.Status__c='Completed';
            termSchedule.TaskCreated__c=true;
        }

        update lstSchedules;
    }
}