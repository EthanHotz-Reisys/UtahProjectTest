global class MSPPaymentSendToFinetActionBatch implements Database.Batchable<sObject>, Database.Stateful {

    public String query;
    public List<String> errors;
    public MSPPaymentSchedule__c mps;
    
    global MSPPaymentSendToFinetActionBatch(MSPPaymentSchedule__c mps) {
        this.mps = mps;
        errors = new List<String>();
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        try{
            query = 'SELECT Id, Status__c FROM PaymentRequest__c WHERE MSPPaymentSchedule__c = \'' + mps.Id + '\'';
            return Database.getQueryLocator(query);
        }catch(Exception e){
            errors.add(e.getMessage());
            return null;
        }
    }

    global void execute(Database.BatchableContext BC, List<PaymentRequest__c> scope) {
        for(PaymentRequest__c pr : scope){
            pr.Status__c = 'Approved';
        }
         update scope;
    }
    
    global void finish(Database.BatchableContext BC) {
         mps.Status__c = 'Sent to FINET';
         update mps;
         Database.executeBatch(new GAXPaymentCreationBatch(mps), 1);
    }
    
}