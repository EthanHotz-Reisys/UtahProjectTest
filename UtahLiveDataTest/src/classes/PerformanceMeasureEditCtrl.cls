public with sharing class PerformanceMeasureEditCtrl {
    //Properties
    public ID recordId{get;set;}
    public PageReference deleteURL{get;set;}
    private String awardId;
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    public transient List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    public String pageTemplateName {get;set;}
    
    public PerformanceMeasureEditCtrl (ApexPages.StandardController stdController){
        listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
        recordId = ApexPages.CurrentPage().getParameters().get('id'); 
        String type= ApexPages.CurrentPage().getParameters().get('type'); 
        String objectiveId= ApexPages.CurrentPage().getParameters().get('objectiveId');        
        pageTemplateName='PerformanceMeasure KPI';  
		GoalObjective__c thisGoal = [Select Award__c from GoalObjective__c where Id = :objectiveId];
		awardId = thisGoal.Award__c;
        if(type!=null){   // This is the flow for New Record
             if(type=='KPI'){
              pageTemplateName='PerformanceMeasure KPI';   
            }
            else if(type=='Deliverable'){
              pageTemplateName='PerformanceMeasure Deliverable';   
            }else if(type=='Reporting Requirement'){
              pageTemplateName='PerformanceMeasure Reporting Requirement';   
            }else if(type=='WBS Task'){
              pageTemplateName='PerformanceMeasure WBSTask';   
            }  
        } 
        else{   // Editing an existing Record
            PerformanceMeasure__c perfMeasure = [Select Id, Name, Objective__r.Award__c,KPI__c,Deliverable__c,ReportingRequirement__c,WBSTask__c from PerformanceMeasure__c where Id=:recordId];
            if(perfMeasure.KPI__c!=null){
              pageTemplateName='PerformanceMeasure KPI';   
            }
            else if(perfMeasure.Deliverable__c!=null){
              pageTemplateName='PerformanceMeasure Deliverable';   
            }else if(perfMeasure.ReportingRequirement__c!=null){
              pageTemplateName='PerformanceMeasure Reporting Requirement';   
            }else if(perfMeasure.WBSTask__c!=null){
              pageTemplateName='PerformanceMeasure WBSTask';   
            }    
        }
        
        if(objectiveId!=null){
         GNT.DynamicLayoutDefaultValueHelper dv1 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Objective__c',objectiveId,true);
         listDefaultValues.add(dv1);        
         GNT.DynamicLayoutDefaultValueHelper dv2 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Type__c',type,true);
         listDefaultValues.add(dv2);
        } 
        savePage = Page.PerformanceMeasureView;
        savePage.getParameters().put('id', recordId);
        if (!String.isEmpty(recordId)) {
            cancelPage = Page.DeliverableView;
            cancelPage.getParameters().put('id', recordId);   
        }      
    } 
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
    //    keyValueMap.put('goalId',recordId);
        keyValueMap.put('awardId',awardId);        
        return JSON.serialize(keyValueMap);
    }

}