public with sharing class PerformanceMeasureViewCtrl {
    //Properties
    public ID recordId{get;set;}
    public PageReference deleteURL{get;set;}
    private String awardId;
    public String pageTemplateName {get;set;}
    
    public PerformanceMeasureViewCtrl (ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id'); 
        String type= ApexPages.CurrentPage().getParameters().get('type'); 
        PerformanceMeasure__c perfMeasure = [Select Id, Name, Objective__r.Award__c,KPI__c,Deliverable__c,ReportingRequirement__c,WBSTask__c from PerformanceMeasure__c where Id=:recordId];
        awardId=perfMeasure.Objective__r.Award__c;          
        pageTemplateName='PerformanceMeasure KPI';   
        if(perfMeasure.KPI__c!=null){
          pageTemplateName='PerformanceMeasure KPI';   
        }else if(perfMeasure.Deliverable__c!=null){
          pageTemplateName='PerformanceMeasure Deliverable';   
        }else if(perfMeasure.ReportingRequirement__c!=null){
          pageTemplateName='PerformanceMeasure Reporting Requirement';   
        }else if(perfMeasure.WBSTask__c!=null){
          pageTemplateName='PerformanceMeasure WBSTask';   
        }           
    } 
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('awardId',awardId);        
        return JSON.serialize(keyValueMap);
    }

}