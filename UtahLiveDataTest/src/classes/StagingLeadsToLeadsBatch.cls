global with sharing class StagingLeadsToLeadsBatch extends GNT.BatchApexHandler /*implements Database.Batchable<sObject>, Database.Stateful, Schedulable*/ {
	
	Integer processedRecords = 0;
	Integer failedRecords = 0;
	
	//global Database.QueryLocator start(Database.BatchableContext BC){
		 global override String getQuery() {
		//return Database.getQueryLocator([SELECT Id, FundingOpportunityNumber__c, CFDANumber__c FROM STGFOALead__c]);
		String query = 'SELECT Id, FundingOpportunityNumber__c, CFDANumber__c FROM STGFOALead__c';
		return query;
	}

	// global void execute(Database.BatchableContext BC, List<sObject> records) {
	 	 global override void execute(List<SObject> records){
	 	String ns = AppUtils.getNamespacePrefix();
		for(sObject record: records){
			try{
				STGFOALead__c stgLead = (STGFOALead__c)record;
				String stgOppNumber = stgLead.FundingOpportunityNumber__c;
				String stgCfdaNumber = stgLead.CFDANumber__c;
				List<FOALead__c> leads = [SELECT Id FROM FOALead__c WHERE FundingOpportunityNumber__c = :stgOppNumber];
				/*if(String.isNotEmpty(stgCfdaNumber) && stgCfdaNumber.length() == 6){
					leads = [SELECT Id FROM FOALead__c WHERE FundingOpportunityNumber__c = :stgOppNumber];// AND CFDANumber__c = :stgCfdaNumber];
					//String query = 'SELECT Id FROM FOALead__c WHERE FundingOpportunityNumber__c = :stgOppNumber AND CFDANumber__c LIKE :stgCfdaNumber';
					//leads = Database.query(query);
				}else{
					leads = [SELECT Id FROM FOALead__c WHERE FundingOpportunityNumber__c = :stgOppNumber];
				}*/

				List<Id> IdList = new List<Id>();
    			IdList.add(stgLead.id);
				if(leads == null || leads.isEmpty()){
					List<Sobject> objects = GNT.AppUtils.copyRecords((ns+'STGFOALead__c'), (ns+'FOALead__c'), IdList, true);					
				}else{
					for(FOALead__c lead: leads){
						List<Sobject> objects = GNT.AppUtils.copyRecords((ns+'STGFOALead__c'), (ns+'FOALead__c'), IdList, false);
						if(!objects.isempty()) {
            				FOALead__c leadObj = (FOALead__c)objects.get(0);
            				leadObj.Id = lead.id;
            				update leadObj;
						}
					}
				}
				processedRecords += 1;
			}catch(Exception e){
				failedRecords += 1;
				System.debug('StagingLeadsToLeadsBatch>>>execute Exception ' + e.getMessage());
			}
		}
	 }

	 //global void finish(Database.BatchableContext BC) {
	 global override void finish(){
        try {           

            String emailAddress = GNT.KeyValueStoreHelper.getTextValue('IntegrationSupportEmailAddress',true);
            if(emailAddress != null){
                
                String body = ('Records processed '+ processedRecords + '. Failed records ' + failedRecords + '.');
                /*String[] toAddresses = new String[] {emailAddress};
                
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setSubject();
                mail.setToAddresses(toAddresses);
                mail.setPlainTextBody(body);
                if(!Test.isRunningTest()){
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                }*/
                
                new GNT.EmailFeeder().toEmail(emailAddress).subject('Staging leads to lead sync').htmlBody(body).send();

                System.debug('StagingLeadsToLeadsBatch>>>finish>>>>>mail sent>>>>>>>>>> ');              
            }
            
        }
        catch (Exception e) {
            System.debug('StagingLeadsToLeadsBatch>>>finish Exception ' + e.getMessage());
        }
	 }

	 global void execute(SchedulableContext SC) {
		StagingLeadsToLeadsBatch handler = new StagingLeadsToLeadsBatch();
        Database.executeBatch(handler, 25);
	 }	 
	 
}