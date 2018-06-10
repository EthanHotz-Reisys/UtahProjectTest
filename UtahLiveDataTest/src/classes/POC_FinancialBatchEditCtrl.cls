public with sharing class POC_FinancialBatchEditCtrl {
	
	public String recordId{get;set;}
	public String pageTemplateName {get;set;}
	public String savePage{get;set;}
	public String cancelPage{get;set;}

	public POC_FinancialBatchEditCtrl(ApexPages.StandardController stdController) {
		recordId = ApexPages.CurrentPage().getParameters().get('id');
		pageTemplateName = 'POC_FinancialBatchEdit';
	}

	public string getKeyValueMap(){
		Map<String,String> keyValueMap = new Map<String,String>(); 
		return JSON.serialize(keyValueMap);
    }
}