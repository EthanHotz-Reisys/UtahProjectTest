public with sharing class MonitoringPhaseViewCtrl {

    //Properties
    
    public String requestType{get;set;}
    public String pageFlexGridName {get;set;}
    public String pageTitle {get;set;}

    public MonitoringPhaseViewCtrl(){
        requestType= ApexPages.CurrentPage().getParameters().get('reqType');
        
         if(!String.isEmpty(requestType) && requestType.equalsIgnoreCase('SiteVisits')){
            pageFlexGridName = 'SiteVisitsGridView';     
            pageTitle = 'Active Site Visits';      
        }        
        else if(requestType.equalsIgnoreCase('ProgressReports')){
            pageFlexGridName ='InactiveExternalReviewers';
            pageTitle = 'Inactive External Reviewers';
        }
        else if(requestType.equalsIgnoreCase('RiskAssessment')){
            pageFlexGridName ='RiskAssessmentGridView';
            pageTitle = 'Active Risk Assessments';
        }
        else{
            pageFlexGridName ='InactiveExternalReviewers';
            pageTitle = 'Inactive External Reviewers'; 
        }                        
             
            
    }

}