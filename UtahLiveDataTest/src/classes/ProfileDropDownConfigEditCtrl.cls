public with sharing class ProfileDropDownConfigEditCtrl {
	
	//Properties
    public ID recordId{get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    
    public Map<String,String> keyValueMap = new Map<String,String>();
    
    public ProfileDropDownConfigEditCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');   

        savePage = Page.ProfileDropDownConfigView;
        savePage.getParameters().put('Id', recordId);
        cancelPage = Page.ProfileDropDownConfigView;
        cancelPage.getParameters().put('Id', recordId);                                    
    }

}