public with sharing class QuarterlyExpenditureReportCtrl{
    
    public Id recordId{get;set;}
    public Id awardId{get;set;}
   
    public QuarterlyExpenditureReportCtrl(){
    	recordId = ApexPages.CurrentPage().getParameters().get('id');
    }
    
    public string getKeyValueMap(){
        Map<String,Object> keyValueMap = new Map<String,Object>();
        keyValueMap.put('awardId',ApexPages.CurrentPage().getParameters().get('id'));
        return JSON.serialize(keyValueMap);
    }
}