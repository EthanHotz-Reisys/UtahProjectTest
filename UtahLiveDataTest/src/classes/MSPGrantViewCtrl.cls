public with sharing class MSPGrantViewCtrl {

	public ID recordId {get;set;}
	public PageReference deleteURL {get;set;}
	public String pageTemplateName {get;set;}
	
	public MSPGrantViewCtrl(ApexPages.StandardController stdController) {
		recordId = ApexPages.CurrentPage().getParameters().get('id');
		pageTemplateName = 'MSPGrantView';
	}

    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('MSPGrantId', recordId);      
        return JSON.serialize(keyValueMap);
    }
}