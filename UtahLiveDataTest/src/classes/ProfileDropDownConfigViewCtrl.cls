public with sharing class ProfileDropDownConfigViewCtrl {
	
	//Properties
    public ID recordId{get;set;}
	
	public Map<String,String> keyValueMap = new Map<String,String>();
	
	public ProfileDropDownConfigViewCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');
        
    }

}