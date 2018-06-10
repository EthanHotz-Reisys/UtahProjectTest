/*
    This is a data cleanup batch for Formula Fields. While invoking set batch size as 1.
    Sample usage : Database.executeBatch(new ObsoleteFieldCodeFinderBatch(),1)
    
    *******************************************************************************************************************
    Audit History
    ********************************************************************************************************************
    2017-05-22       Charan           Created 
    
    **********************************************************************************************************************  
*/ 
global class ObsoleteFieldCodeFinderBatch implements Database.Batchable<sObject>, Database.Stateful {
	List<ApexClass> classes;
	List<ApexTrigger> triggers;
	String query;
	
	global ObsoleteFieldCodeFinderBatch() {
		this.classes=[Select Name,Body from ApexClass];
		this.triggers=[Select Name,Body from ApexTrigger];
   		List<BusinessObject__c> objList=new List<BusinessObject__c>();
   		for(BusinessObject__c obj:[Select Id,ObsoleteCodeFields__c,ExistDataFields__c from BusinessObject__c]){
   			if(obj.ObsoleteCodeFields__c!=null || obj.ExistDataFields__c!=null){
   				obj.ObsoleteCodeFields__c=null;
   				obj.ExistDataFields__c=null;
   				objList.add(obj);
   			}
   		}
   		update objList;   		
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		query='SELECT Id,Name FROM BusinessObject__c';
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<BusinessObject__c> records) {
   		List<ApexPage> pages=[Select Name,Markup from ApexPage];
		List<ApexComponent> components=[Select Name,Markup from ApexComponent];
		ObsoleteFieldCodeFinder check=new ObsoleteFieldCodeFinder(records[0].Name);
		Map<String,List<String>> results=check.findObsoleteFields(classes,triggers,pages,components);
		String newBody='';
		Map<String,list<String>> newMap=new Map<String,list<String>>();
		for(String str:results.keySet()){
			if(results.get(str).size()==0){
				newBody=newBody+str+',';
			}
			else{
				newMap.put(str,results.get(str));
			}
		}
		records[0].ObsoleteCodeFields__c=newBody;
		records[0].ExistDataFields__c=JSON.serialize(newMap);
		update records;
	}

	global void finish(Database.BatchableContext BC) {
		
	}
	
}