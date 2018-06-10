public with sharing class MSPAwardViewCtrl {
	public ID recordId {get;set;}
	public PageReference deleteURL {get;set;}
	public String pageTemplateName {get;set;}
	
	public MSPAwardViewCtrl(ApexPages.StandardController stdController) {
		recordId = ApexPages.CurrentPage().getParameters().get('id');
		pageTemplateName = 'MSPAwardView';
	}

    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('awardId', recordId); 
        return JSON.serialize(keyValueMap);
    }
}