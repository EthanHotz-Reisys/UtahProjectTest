public with sharing class SiteVisitActivityAddViewCtrl {
	public String recordId {get;set;}
	public String templateName {get;set;}
	public List <GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
	public PageReference savePage {get;set;}
	public PageReference cancelPage {get;set;}
	public SiteVisitActivityAddViewCtrl(ApexPages.StandardController stdController) {
		recordId = ApexPages.CurrentPage().getParameters().get('id');
		templateName = 'SiteVisitActivityTemplate';
		savePage = Page.SiteVisitActivityAddView;
		//cancelPage = Page.ProgressReportView;
		listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
	}
}