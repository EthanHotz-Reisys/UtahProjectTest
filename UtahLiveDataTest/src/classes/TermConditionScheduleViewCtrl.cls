public with sharing class TermConditionScheduleViewCtrl {
	public ID recordId {get;set;}
    public String recordType {get;set;}
    public String templateName{get;set;}
    public GNT__PageTemplate__c template;
    public List<TermCondition__c> grantIds {get;set;}
    public Id grantId {get;set;}

	public TermConditionScheduleViewCtrl(ApexPages.StandardController stdController) {
		recordId = ApexPages.CurrentPage().getParameters().get('id');
		templateName = 'TermConditionNewScheduleTemplate';
	}
}