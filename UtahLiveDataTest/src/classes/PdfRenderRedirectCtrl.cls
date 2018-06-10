public with sharing class PdfRenderRedirectCtrl {
	private String templateName;
	private String recordId;
	public PdfRenderRedirectCtrl() {
		recordId = ApexPages.CurrentPage().getParameters().get('id');

		Application__c appObj = [SELECT Announcement__c
						FROM Application__c 
						WHERE Id =: recordId];
		BusinessPackage__c applicationPkg = [Select Id,Name,PackageConfig__r.GNT__PageTemplateConfig__r.Name from BusinessPackage__c where PackageType__c ='Application' and FundingOpportunity__c =:appObj.Announcement__c];
		templateName = applicationPkg.PackageConfig__r.GNT__PageTemplateConfig__r.Name;
		//select PackageConfig__r.Name from Business_Packages__r where PackageType__c='Application')
	}

	public PageReference redirect() {
		PageReference redirecturl = new PageReference('/apex/' + AppUtils.getNamespacePrefix() + 'DynamicLayoutExport?id='+recordId);
		redirecturl.getParameters().put('viewTemplateName',templateName);
		return redirecturl;
	}
}
/*
 TO DO : Extend this functionality for objects other than Pre-Applications and Applications.

*/