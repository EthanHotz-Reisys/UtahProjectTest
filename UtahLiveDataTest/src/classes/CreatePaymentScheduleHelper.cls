global with sharing class CreatePaymentScheduleHelper {
    
    global void createPaymentSchedule(String fiscalYear){
        List<MSPPaymentSchedule__c> mpss = new List<MSPPaymentSchedule__c>();
        Date paymentStartDate = Date.newInstance(Integer.valueOf(fiscalYear) - 1, 7, 15);
        for(Integer i = 0; i < 12; i++){
            MSPPaymentSchedule__c temp = new MSPPaymentSchedule__c(
                FiscalYear__c = fiscalYear,
                ScheduleDate__c = paymentStartDate.addMonths(i),
                Pathway__c = 'App12',
                Status__c = 'Created'
            );
            mpss.add(temp);
        }
        insert mpss;
    }
}