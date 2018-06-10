global with sharing class AdhocPaymentRequestCreationHelper extends GNT.DynamicLayoutActionStay { 
//GNT.DynamicLayoutActionRedirect
global override String whenClicked(){ 

         Savepoint sp = Database.setSavePoint();
          try{
             Id recordId = apexpages.currentpage().getparameters().get('id');
             List<Award__c> lstAw  = [select Id,name,Grant__c,POUser__c,Grant__r.GranteePOC__c,Grant__r.GrantNumber__c from Award__c where Id =:recordId limit 1];
           
             List<PaymentRequest__c> lstPaymentRequests=new List<PaymentRequest__c>();
             List<Task> paymentRequestTasks = new List<Task>();
             List<PaymentRequest__c> paymentrqstlist = preparePaymentRequests(lstAw);
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
              PageReference p = Page.AwardView;
              p.getParameters().put('id', recordId);
              p.setRedirect(true);
              return 'The payment request got created successfully , pleas go to the manage payment request to submit the payment request.';
          //return null;
            }
          catch(Exception ex){
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, ex.getMessage())); 
            return null;
          }
        
}

    private  List<PaymentRequest__c> preparePaymentRequests(List<Award__c> lstAw){
       List<PaymentRequest__c> lstpayments= new List<PaymentRequest__c>(); 
       List<TermCondition__c> terms = new List<TermCondition__c>();
                 for(Award__c aw : lstAw){
                    
                     PaymentRequest__c paymentrequest = new PaymentRequest__c();               
                     paymentrequest.Award__c= aw.Id;
                     paymentrequest.Grant__c=aw.Grant__c;
                     paymentrequest.status__c='Created';
                     paymentrequest.PaymentRequestCreation__c ='Unplanned';
                     paymentrequest.ProgramManager__c= aw.POUser__c;
                     paymentrequest.BillingStartDate__c = date.today();
                     paymentrequest.Type__c = 'Reimbursement';
                     paymentrequest.Applicant__c = aw.Grant__r.GranteePOC__c;
                     //paymentrequest.ownerid =  termSchedule.TermAndCondition__r.Award__r.Grant__r.GranteePOC__c;         
                     paymentrequest.BillingEndDate__c  = date.today();
                     //paymentrequest.Title__c= termSchedule.TermAndCondition__r.ReportName__c;
                     paymentrequest.RecipientsAccountNumber__c= aw.Grant__r.GrantNumber__c;
                     System.debug('Create  Progress Reports now-- '+ paymentrequest);
                      lstpayments.add(paymentrequest);
                     }
           
           if(lstpayments.size()>0){
              insert lstpayments; 
             }
              return lstpayments;
     }


    
     /* public void preparePaymentRequestSchedule(List<Award__c> awards){
        Set<Id> awardIds = new Set<Id>();
        List<TermConditionSchedule__c> lstSchedules = new List<TermConditionSchedule__c>();
        boolean checkDeepClone = true;

        for(Award__c awd : awards) {
            if (awd.DeepCloned__c == true) {
                checkDeepClone = false;
            }
        }

        if(checkDeepClone) {
            List<RecordType> rctTypeList= [select Id from RecordType where Name = 'Payment Request' and SobjectType =:AppUtils.getNamespacePrefix()+'TermConditionSchedule__c' limit 1];
            List<TermCondition__c> terms = new List<TermCondition__c>();
            for(Award__c awd : awards){
              awardIds.add(awd.Id);
            }
            Map<Id,TermCondition__c> termConditionMap = new Map<Id,TermCondition__c>([Select Id,Title__c ,Name,RecordType.Name,Award__c, Grant__c,CalReportingEndDate__c,CalReportingStartDate__c,ReportName__c,Category__c,Frequency__c ,ReportingFrequency__c  from Termcondition__c where RecordType.Name IN ('Payment Request') and Award__c =: awardIds]);
            for(Award__c award : (List<Award__c>) awards) {
              Award__c awardold = (Award__c)trigger.oldmap.get(award.id); 
                if('Activated'.equals(award.status__c) && 'Grantee Accepted'.equals(awardold.status__c)) // no need to check this condition
                {
                    for(TermCondition__c termCondition : termConditionMap.values())// Getting list of TnC
                    {
                        if(termCondition.Award__c == award.Id && termCondition.CalReportingStartDate__c!=null && termCondition.CalReportingEndDate__c !=null){
                        System.debug('Create Payment Requests Schedule  now '+termCondition.Name);
                         if(termCondition.Frequency__c=='Fixed'){
                            TermConditionSchedule__c  termSchedule = new TermConditionSchedule__c();
                            termSchedule.TermAndCondition__c= termCondition.Id;
                            termSchedule.ReportStatus__c='N/A';
                            termSchedule.StartDate__c =termCondition.CalReportingStartDate__c;
                            termSchedule.RecordTypeid= rctTypeList[0].id;
                            termSchedule.EndDate__c = termCondition.CalReportingEndDate__c;
                            termSchedule.DueDate__c = termCondition.CalReportingEndDate__c.addDays(7);
                            System.debug('Create Fixed Payment Requests Schedule now ');
                            lstSchedules.add(termSchedule);
                            }
                         else{
                      //calculate the number of months for recurring reports
                         Integer  noOfMonths = (((termCondition.CalReportingEndDate__c.year()  - termCondition.CalReportingStartDate__c.YEAR() - 1) *12) + (12 - termCondition.CalReportingStartDate__c.month() +1) + termCondition.CalReportingEndDate__c.month());
                         String frequencyType=termCondition.Frequency__c;
                         Integer count;
                         if(frequencyType=='Monthly')
                         count = noOfMonths ;
                         else if(frequencyType=='Quarterly')
                         count = noOfMonths/3 ;
                         else if(frequencyType=='Semi-Annually')
                         count = noOfMonths/6 ;
                         else if(frequencyType=='Annually')
                         count = noOfMonths/12 ;
                         system.debug('noOfMonths    '+noOfMonths );
                         system.debug('count    '+count );
                         Date startDate= termCondition.CalReportingStartDate__c;
                         Date endDate = termCondition.CalReportingEndDate__c;
                         for (Integer i=0;i<=count ; i++){
                               system.debug('count in loop  '+i);
                               TermConditionSchedule__c  termSchedule = new TermConditionSchedule__c();
                               termSchedule.TermAndCondition__c= termCondition.Id;
                               termSchedule.ReportStatus__c='N/A';
                               Date dt1 = getReportEndDate(frequencyType,i-1,startDate);
                               Date dt2 = getReportEndDate(frequencyType,i,startDate);
                               termSchedule.StartDate__c = dt1.addDays(1);
                               termSchedule.RecordTypeId= rctTypeList[0].id;
                               termSchedule.EndDate__c = dt2;
                               termSchedule.DueDate__c = dt2.addDays(7);
                               System.debug('Create Recurring Payment Requests Schedule now ');
                               lstSchedules.add(termSchedule);
                         }
                      }
                    }
                        else
                        System.debug('Payment Requests can not be created due to lack of data ');
              }
            }
          }
          if(lstSchedules.size()>0){
                  insert lstSchedules; 
        }
    }
  }
  
    private Date getReportEndDate(String frequencytype, Integer count, Date startdate)
    {
    Integer numberOfDays = Date.daysInMonth(startDate.year(), startDate.month());
    Date lastDayOfMonth = Date.newInstance(startDate.year(), startDate.month(), numberOfDays);    
    Date rptStartDate;    
    if(frequencytype=='Monthly'){
    rptStartDate = lastDayOfMonth.addmonths(count*1);
    }
    else if(frequencytype=='Quarterly'){
    rptStartDate = lastDayOfMonth.addmonths(count*3);
    }
    else if(frequencytype=='Semi-Annually'){
    rptStartDate = lastDayOfMonth.addmonths(count*6);
    }
    else if(frequencytype=='Annually'){
    rptStartDate = lastDayOfMonth.addmonths(count*12);
    }      
    return rptStartDate;
} */
  }