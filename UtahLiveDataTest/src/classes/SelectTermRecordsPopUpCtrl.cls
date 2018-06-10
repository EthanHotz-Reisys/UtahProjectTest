public with sharing class SelectTermRecordsPopUpCtrl{
    
    public String templateName{get;set;}
    private String reqType;
    private Map<Id,TermCondition__c> termConditionMap;

    public SelectTermRecordsPopUpCtrl(){
        templateName = ApexPages.CurrentPage().getParameters().get('flextable');
        Id parentId  = ApexPages.CurrentPage().getParameters().get('parentid');

		reqType      = ApexPages.CurrentPage().getParameters().get('reqType');
		List<Id> addedTerms =new List<Id>();
		if(reqType=='Program'){
			for(TermCondition__c term :[Select Id,CopiedFrom__c from TermCondition__c where Program__c =: parentId]){
				addedTerms.add(term.CopiedFrom__c);
			}
			termConditionMap = new Map<Id,TermCondition__c>([Select Id, Name from TermCondition__c where recordType.Name='Term' and Program__c=null and Award__c=null and Id Not in :addedTerms]);			
		}
		else if (reqType=='Award'){
			for(TermCondition__c term :[Select Id,CopiedFrom__c from TermCondition__c where Award__c =: parentId]){
				addedTerms.add(term.CopiedFrom__c);
			}
			Id programId=ApexPages.CurrentPage().getParameters().get('programId');
			termConditionMap = new Map<Id,TermCondition__c> ([Select Id, Name from TermCondition__c where Program__c=: programId and Award__c=null and Id Not in :addedTerms]);
		}
		else if(reqType=='Federal'){
		  Set<String> setProgramFAId = new Set<String>();
		   for(ProgramFundingAccount__c progFA : [select Id,Name, LatestActiveAward__c from ProgramFundingAccount__c where Program__c =: parentId] )
		   {
		   	if(progFA.LatestActiveAward__c!=null)
		   	setProgramFAId.add(progFA.LatestActiveAward__c);
		   }
		  for(TermCondition__c term :[Select Id,CopiedFrom__c from TermCondition__c where Program__c =: parentId ])	{
				addedTerms.add(term.CopiedFrom__c);
			}
			termConditionMap = new Map<Id,TermCondition__c> ([Select Id, Name from TermCondition__c where Award__c IN: setProgramFAId and Id Not in :addedTerms]);
		}
		else{
			termConditionMap = new Map<Id,TermCondition__c> ([Select Id, Name from TermCondition__c where Program__c=null and Award__c=null]);
		}
    }

    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('parentid',ApexPages.CurrentPage().getParameters().get('parentid'));
        return JSON.serialize(keyValueMap);
    }

      public string getListParameters(){
      	Map<String,Set<String>> listParams = new Map<String,Set<String>>();     
      	Set<String> termConditionIdSet = (Set<String>)JSON.deserialize(JSON.serialize(termConditionMap.keyset()), Set<String>.class);
      	listParams.put('termConditionIdSet',termConditionIdSet);
      	 return JSON.serialize(listParams);
      }
}