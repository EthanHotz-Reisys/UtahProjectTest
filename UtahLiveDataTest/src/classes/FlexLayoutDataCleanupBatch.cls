/*
    This is a data cleanup batch for DataTableConfig. While invoking set batch size as 1.
    Sample usage : Database.executeBatch(new FlexLayoutDataCleanupBatch(),1)
    
    *******************************************************************************************************************
    Audit History
    ********************************************************************************************************************
    2017-05-10       Charan           Created 
    
    **********************************************************************************************************************  
*/ 

global class FlexLayoutDataCleanupBatch implements Database.Batchable<sObject>, Database.Stateful {
	
	List<GNT__PageLayoutConfig__c> newRecords=new List<GNT__PageLayoutConfig__c>();
	String query;
	
	global FlexLayoutDataCleanupBatch() {
   		List<GNT__PageLayoutConfig__c> updateRecords=new List<GNT__PageLayoutConfig__c>();
   		for(GNT__PageLayoutConfig__c record:[SELECT Id from GNT__PageLayoutConfig__c where Obsolete__c=true]){
   			record.Obsolete__c=false;
   			updateRecords.add(record);
   		}
   		update updateRecords;
	}
	//,GNT__SObjectConfig__c
	global Database.QueryLocator start(Database.BatchableContext BC) {
		query='SELECT Id,Name, GNT__SObjectConfig__c from GNT__PageLayoutConfig__c';
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<GNT__PageLayoutConfig__c> records) {
   		List<GNT__PageTemplate__c> pages=[SELECT Id, Name,GNT__EditLayoutConfig__c,GNT__PrintLayoutConfig__c,GNT__ViewLayoutConfig__c FROM GNT__PageTemplate__c];
		List<ApexClass> classes=[Select Body from ApexClass];
		List<ApexTrigger> triggers=[Select Body from ApexTrigger];
		List<ApexPage> pagesBody=[Select Markup from ApexPage];
		List<ApexComponent> components=[Select Markup from ApexComponent];
   		Integer count=0;
   		Id recordId=records.get(0).Id;

   		if(count==0){count+=[Select count() from GNT__PageLayoutConfig__c where GNT__ParentLayout__c=: recordId];}
   		if(count==0){count+=[Select count() from GNT__PageTemplate__c where GNT__EditLayoutConfig__c=: recordId];}
   		if(count==0){count+=[Select count() from GNT__PageTemplate__c where GNT__PrintLayoutConfig__c=: recordId];}
   		if(count==0){count+=[Select count() from GNT__PageTemplate__c where GNT__ViewLayoutConfig__c=: recordId];}
   		if(count==0){count+=[Select count() from GNT__SObjectLayoutConfig__c where GNT__PageLayoutConfig__c=: recordId];}

		List<String> recordNames=new List<String>();
		Set<Id> pageTemplateIds = new Set<Id>();
		for(GNT__PageTemplate__c page:pages){
			if(page.GNT__EditLayoutConfig__c==recordId || page.GNT__PrintLayoutConfig__c==recordId || page.GNT__ViewLayoutConfig__c==recordId){
				recordNames.add(page.Name);
				pageTemplateIds.add(page.Id);
			}
		}

		if(count==0){count+=[Select count() from ChangeRequestDetail__c where FormConfig__c in :pageTemplateIds];}
		if(count==0){count+=[Select count() from Form__c where PageTemplateConfig__c in :pageTemplateIds];}
		if(count==0){count+=[Select count() from GNT__PackageFormConfig__c where GNT__FormConfig__c in :pageTemplateIds];}
		if(count==0){count+=[Select count() from GNT__PackageTypeConfig__c where GNT__LayoutForm__c in :pageTemplateIds];}
		if(count==0){count+=[Select count() from GNT__Package__c where GNT__PageTemplateConfig__c in :pageTemplateIds];}
		if(count==0){count+=[Select count() from ReviewPanelTemplate__c where PanelLayout__c in :pageTemplateIds];}
		if(count==0){count+=[Select count() from ReviewPanelTemplate__c where ReviewFormConfig__c in :pageTemplateIds];}
		if(count==0){count+=[Select count() from ReviewPanel__c where PanelLayout__c in :pageTemplateIds];}
		if(count==0){count+=[Select count() from ReviewPanel__c where ReviewFormConfig__c in :pageTemplateIds];}
		if(count==0){count+=[Select count() from ReviewStepTemplate__c where ApprovalConfirmationLayout__c in :pageTemplateIds];}
		if(count==0){count+=[Select count() from ReviewStepTemplate__c where RejectionConfirmationLayout__c in :pageTemplateIds];}
		if(count==0){count+=[Select count() from ReviewStepTemplate__c where ReviewFormConfig__c in :pageTemplateIds];}
		if(count==0){count+=[Select count() from ReviewStepTemplate__c where ReviewStepLayout__c in :pageTemplateIds];}
		if(count==0){count+=[Select count() from ReviewStep__c where ApprovalConfirmationLayout__c in :pageTemplateIds];}
		if(count==0){count+=[Select count() from ReviewStep__c where RejectionConfirmationLayout__c in :pageTemplateIds];}
		if(count==0){count+=[Select count() from ReviewStep__c where ReviewFormConfig__c in :pageTemplateIds];}
		if(count==0){count+=[Select count() from ReviewStep__c where ReviewStepLayout__c in :pageTemplateIds];}
		if(count==0){count+=[Select count() from Review__c where PageTemplate__c in :pageTemplateIds];}
		if(count==0){count+=[Select count() from RiskAssessment__c where PageTemplateConfig__c in :pageTemplateIds];}
		if(count==0){count+=[Select count() from RiskAssessment__c where templateName__c in :pageTemplateIds];}
		if(count==0){count+=[Select count() from RolesAndResponsibilities__c where PageTemplateConfig__c in :pageTemplateIds];}


		for(String recordName:recordNames){
			if (count == 0) {
				count+=checkInApexClasses(recordName,classes);
			}
			if (count == 0) {
				count+=checkInApexTriggers(recordName,triggers);
			}
			if (count == 0) {
				count+=checkInApexPages(recordName,pagesBody);
			}
			if (count == 0) {
				count+=checkInApexComponents(recordName,components);
			}
		}

		String pageLayoutName = records.get(0).Name;
		if (count == 0) {
			count+=checkInApexClasses(pageLayoutName,classes);
		}
		if (count == 0) {
			count+=checkInApexTriggers(pageLayoutName,triggers);
		}
		if (count == 0) {
			count+=checkInApexPages(pageLayoutName,pagesBody);
		}
		if (count == 0) {
			count+=checkInApexComponents(pageLayoutName,components);
		}

		// || records.get(0).GNT__SObjectConfig__c==null		
 		if(count==0){
			newRecords.add(records.get(0));
		}
	}
	
	global void finish(Database.BatchableContext BC) {
		for(GNT__PageLayoutConfig__c record: newRecords){
            record.Obsolete__c = true;
        }
        update newRecords;
	}

	global Integer checkInApexClasses(String x,List<ApexClass> classes){
		Boolean exists=false;
		for(ApexClass classRecord:classes){
			if(classRecord.Body.contains(x)){
				exists=true;
				break;
			}
		}
		return exists ? 1 : 0;
	}

	global Integer checkInApexTriggers(String x,List<ApexTrigger> triggers){
		Boolean exists=false;
		for(ApexTrigger triggerRecord:triggers){
				if(triggerRecord.Body.contains(x)){
					exists=true;
					break;
				}
			}
		if(exists){
			return 1;
		}
		else{
			return 0;
		}
		
	}

	global Integer checkInApexPages(String x,List<ApexPage> pagesBody){
		Boolean exists=false;
		for(ApexPage page:pagesBody){
				if(page.Markup.contains(x)){
					exists=true;
					break;
				}
			}
		if(exists){
			return 1;
		}
		else{
			return 0;
		}
		
	}
	global Integer checkInApexComponents(String x,List<ApexComponent> components){
		Boolean exists=false;
		for(ApexComponent component:components){
				if(component.Markup.contains(x)){
					exists=true;
					break;
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