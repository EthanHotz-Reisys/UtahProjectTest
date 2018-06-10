global with sharing class PaymentRequestCreationHandler extends GNT.FlexTableActionHandler{
    global  override Map<String,Object> clickHandler(){
        Savepoint savestate = Database.setSavepoint();
        Map<String,Object> retVal = new Map<String,Object>();
        //String recordId = 'a1e35000000HZ44AAG';
        //String recordId = urlParams.get('id');
        String recordId = ApexPages.currentPage().getParameters().get('id');
        //Award__c award = [SELECT Id, Grant__c, POUser__c, Grant__r.GranteePOC__c, Grant__r.GrantNumber__c,Grant__r.Program__r.PaymentRequestSetting__c FROM Award__c WHERE Id =: recordId];
        /*PaymentRequest__c pr = new PaymentRequest__c();
        pr.Award__c = award.Id;
        pr.Grant__c = award.Grant__c;
        pr.status__c = 'Created';
        pr.PaymentRequestCreation__c = 'Planned';
        pr.ProgramManager__c = award.POUser__c;
        //pr.BillingStartDate__c = termSchedule.StartDate__c;
        pr.Type__c = 'Reimbursement';
        pr.Applicant__c = award.Grant__r.GranteePOC__c;
        //pr.BillingEndDate__c  =  termSchedule.EndDate__c;
        //pr.Title__c= termSchedule.TermAndCondition__r.ReportName__c;
        pr.RecipientsAccountNumber__c = award.Grant__r.GrantNumber__c;
        pr.PaymentRequestSetting__c = award.Grant__r.Program__r.PaymentRequestSetting__c;
        pr.RequestSubmittedDate__c=System.Today();
        GNT.TaskCreationHandler.createApprovalProcessTasks(pr.Id, 'Review Payment Request', pr.Name, null, System.TODAY() + 7, pr.Title__c, true);
        insert pr;*/
        retVal.put('PageReference', '/' + recordId);
        return retVal;
    }
}