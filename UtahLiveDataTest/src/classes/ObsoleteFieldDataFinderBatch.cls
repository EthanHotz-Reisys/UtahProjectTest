/*
    This is a data cleanup batch for Formula Fields. While invoking set batch size as 1.
    Sample usage : Database.executeBatch(new ObsoleteFieldDataFinderBatch(),1)
    
    *******************************************************************************************************************
    Audit History
    ********************************************************************************************************************
    2017-05-19       Charan           Created 
    
    **********************************************************************************************************************  
*/ 

global class ObsoleteFieldDataFinderBatch implements Database.Batchable<sObject>, Database.Stateful {
	
	String query;
	
	global ObsoleteFieldDataFinderBatch() {
		List<BusinessObject__c> updateList=new List<BusinessObject__c>();
		for(BusinessObject__c obj:[SELECT id,ObsoleteDataFields__c from BusinessObject__c]){
			if(obj.ObsoleteDataFields__c!=null){
				obj.ObsoleteDataFields__c=null;
			}
			updateList.add(obj);
		}
		update updateList;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		query='SELECT Id,Name,ObsoleteDataFields__c FROM BusinessObject__c';
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<BusinessObject__c> records) {
   		for(BusinessObject__c record:records){
   			ObsoleteFieldDataFinder check=new ObsoleteFieldDataFinder(record.Name);
   			List<String> results=check.findObsoleteFields();
   			String newBody='';
			for(String result:results){
				newBody=newBody+result+',';
			}
			record.ObsoleteDataFields__c=newBody;
			update record;
   		}
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}