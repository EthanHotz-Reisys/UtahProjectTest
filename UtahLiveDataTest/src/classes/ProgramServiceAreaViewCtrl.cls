public with sharing class ProgramServiceAreaViewCtrl {
	public PageReference deleteURL{get;set;}
	public String pageTemplateName {get;set;}
	public ID recordId{get;set;}
			    
	public ProgramServiceAreaViewCtrl (ApexPages.StandardController stdController){
		pageTemplateName = 'ProgramServiceAreaView';
		recordId = ApexPages.CurrentPage().getParameters().get('id');
		deleteURL = null;
	}

	public string getKeyValueMap(){
		Map<String,String> keyValueMap = new Map<String,String>();
		return JSON.serialize(keyValueMap);
	}		    
}