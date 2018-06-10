global without sharing class PaymentScheduleHelper {
    
    global static PaymentSchedule__c getPaymentSchedule(){
    	Date currentDate = System.today();
    	PaymentSchedule__c schedule = [SELECT Id,FiscalPeriod__c,FiscalYear__c,Month__c,MonthText__c,Organization__c,ScheduleDate__c FROM PaymentSchedule__c WHERE ScheduleDate__c >: currentDate ORDER BY ScheduleDate__c,FiscalYear__c LIMIT 1];
    	return schedule;
    }
    
    global static Date getPaymentDate(){
    	PaymentSchedule__c  schedule = getPaymentSchedule();
    	return schedule.ScheduleDate__c;
    }
}