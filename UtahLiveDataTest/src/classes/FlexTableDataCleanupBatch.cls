/*
    This is a data cleanup batch for Page Layout Config.While invoking set batch size as 1.
    Sample usage : Database.executeBatch(new FlexTableDataCleanupBatch(),1)
    
    *******************************************************************************************************************
    Audit History
    ********************************************************************************************************************
    2017-05-10       Charan           Created 
    
    **********************************************************************************************************************  
*/ 

global class FlexTableDataCleanupBatch implements Database.Batchable<sObject> , Database.Stateful{
	
	List<GNT__DataTableConfig__c> newRecords= new List<GNT__DataTableConfig__c>();	
	List<ApexClass> classes;
	List<ApexTrigger> triggers;
	//List<ApexPage> pages;
	//List<ApexComponent> components;
	String query;
	
	global FlexTableDataCleanupBatch() {
		this.classes=[Select Body from ApexClass];
   		this.triggers=[Select Body from ApexTrigger];
   		//this.pages=[Select Markup from ApexPage];
   		//this.components=[Select Markup from ApexComponent];
   		List<GNT__DataTableConfig__c> updateRecords=new List<GNT__DataTableConfig__c>();
   		for(GNT__DataTableConfig__c record:[SELECT Id,Name from GNT__DataTableConfig__c where Obsolete__c=true]){
   			record.Obsolete__c=false;
   			updateRecords.add(record);
   		}
   		update updateRecords;
	}
	// 
	global Database.QueryLocator start(Database.BatchableContext BC) {
		String some='PaymentRequestServiceArea-DOH-Advance1';
		query='SELECT Id,Name,GNT__SObjectConfig__c from GNT__DataTableConfig__c where Name=:some';
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<GNT__DataTableConfig__c> records) {
   		List<ApexPage> pages=[Select Markup from ApexPage];
   		List<ApexComponent> components=[Select Markup from ApexComponent];
   		Integer count=0;
   		Id recordId=records.get(0).Id;
   		String recordName=records.get(0).Name;
   		count+=[Select count() from GNT__AccordionContent__c where GNT__DataTableConfig__c=: recordId];
   		if(count!=0){ System.debug('GNT__AccordionContent__c');}

   		String recordPartialMatch = '%' + recordName + '%';
   		if(count==0){count+=[Select count() from GNT__AccordionContent__c where GNT__Link__c like :recordPartialMatch];}
   		if(count!=0){ System.debug('GNT__AccordionContent__c');}
   		if(count==0){count+=[Select count() from GNT__PageLayoutActionConfig__c where GNT__ActionURL__c like :recordPartialMatch];}
   		if(count!=0){ System.debug('GNT__PageLayoutActionConfig__c');}
   		if(count==0){count+=[Select count() from GNT__DataTableAction__c where GNT__ActionURL__c like :recordPartialMatch];}
   		if(count!=0){ System.debug('GNT__DataTableAction__c');}
   		
   		if(count==0){count+=[Select count() from GNT__FlexGridConfig__c where GNT__Child1FlexTable__c=: recordId];}
   		if(count!=0){ System.debug('GNT__FlexGridConfig__c');}
   		if(count==0){count+=[Select count() from GNT__FlexGridConfig__c where GNT__Child2FlexTable__c=: recordId];}
   		if(count!=0){ System.debug('GNT__FlexGridConfig__c');}
   		if(count==0){count+=[Select count() from GNT__FlexGridConfig__c where GNT__Child3FlexTable__c=: recordId];}
   		if(count!=0){ System.debug('GNT__FlexGridConfig__c');}
   		if(count==0){count+=[Select count() from GNT__FlexGridConfig__c where GNT__Child4FlexTable__c=: recordId];}
   		if(count!=0){ System.debug('GNT__FlexGridConfig__c');}
   		if(count==0){count+=[Select count() from GNT__FlexGridConfig__c where GNT__GrandChild1FlexTable__c=: recordId];}
   		if(count!=0){ System.debug('GNT__FlexGridConfig__c');}
   		if(count==0){count+=[Select count() from GNT__FlexGridConfig__c where GNT__ParentFlexTable__c=: recordId];}
   		if(count!=0){ System.debug('GNT__FlexGridConfig__c');}
   		if(count==0){count+=[Select count() from GNT__PageBlockConfig__c where GNT__FlexTableName__c=: recordId];}
   		if(count!=0){ System.debug('GNT__PageBlockConfig__c');}
   		if(count==0){count+=[Select count() from GNT__PhaseConfig__c where GNT__BodyTable__c=: recordId];}
   		if(count!=0){ System.debug('GNT__PhaseConfig__c');}
   		if(count==0){count+=[Select count() from GNT__SearchConfig__c where GNT__FlexTableConfig__c=: recordId];}
   		if(count!=0){ System.debug('GNT__SearchConfig__c');}
   		
   		if(count==0){count+=[Select count() from ReviewStepTemplate__c where ApprovalConfirmationFlexTableName__c=: recordId];}
   		if(count!=0){ System.debug('ReviewStepTemplate__c');}
   		if(count==0){count+=[Select count() from ReviewStepTemplate__c where RejectionConfirmationFlexTableName__c=: recordId];}
   		if(count!=0){ System.debug('ReviewStepTemplate__c');}
   		if(count==0){count+=[Select count() from ReviewStep__c where ApprovalConfirmationFlexTableName__c=: recordId];}
   		if(count!=0){ System.debug('ReviewStep__c');}
   		if(count==0){count+=[Select count() from ReviewStep__c where RejectionConfirmationFlexTableName__c=: recordId];}
   		if(count!=0){ System.debug('ReviewStep__c');}

   		if(count==0) {
   			count+=checkInApexClasses(recordName);
   		}
   		if(count==0) {
	   		count+=checkInApexTriggers(recordName);
	   	}
   		if(count==0) {
	   		count+=checkInApexPages(recordName,pages);
	   	}
   		if(count==0) {
	   		count+=checkInApexComponents(recordName,components);
	   	}
	   	//|| (records.get(0).GNT__SObjectConfig__c==null && records.get(0).RecordType.name !='WBS')
		if(count==0){
			newRecords.add(records.get(0));
		}
	}
	
	global void finish(Database.BatchableContext BC) {
        for(GNT__DataTableConfig__c record: newRecords){
            record.Obsolete__c = true;
        }
        update newRecords;
	}
	
	global Integer checkInApexClasses(String x){
		Boolean exists=false;
		for(ApexClass classRecord:classes){
				if(classRecord.Body.contains(x)){
					exists=true;
					break;
					System.debug(classRecord.Name);
				}
			}
		if(exists){
			return 1;
		}
		else{
			return 0;
		}
	}
	global Integer checkInApexTriggers(String x){
		Boolean exists=false;
		for(ApexTrigger triggerRecord:triggers){
				if(triggerRecord.Body.contains(x)){
					exists=true;
					break;
					System.debug(triggerRecord.Name);
				}
			}
		if(exists){
			return 1;
		}
		else{
			return 0;
		}
		
	}
	global Integer checkInApexPages(String x,List<ApexPage> pages){
		Boolean exists=false;
		for(ApexPage page:pages){
				if(page.Markup.contains(x)){
					exists=true;
					break;
					System.debug(page.Name);
				}
			}
		if(exists){
			return 1;
		}
		else{
			return 0;
		}
		
	}
	global Integer checkInApexComponents(String x, List<ApexComponent> components){
		Boolean exists=false;
		for(ApexComponent component:components){
				if(component.Markup.contains(x)){
					exists=true;
					break;
					System.debug(component.Name);
				}
			}
		if(exists){
			return 1;
		}
		else{
			return 0;
		}
		
	}
	
}