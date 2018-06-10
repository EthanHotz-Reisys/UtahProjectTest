public with sharing class TaskFieldMappingViewCtrl {
	
	//Properties
    public ID recordId{get;set;}
	
	public Map<String,String> keyValueMap = new Map<String,String>();
	
	public TaskFieldMappingViewCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');
        
    }

}