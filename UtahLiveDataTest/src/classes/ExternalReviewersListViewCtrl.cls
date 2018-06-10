public with sharing class ExternalReviewersListViewCtrl {
    
       
    //Properties
    
    public String isActive{get;set;}
    public String pageFlexTableName {get;set;}
    public String pageTitle {get;set;}
    
         
    public ExternalReviewersListViewCtrl(){
        isActive = ApexPages.CurrentPage().getParameters().get('isActive');
        
         if(!String.isEmpty(isActive) && isActive.equalsIgnoreCase('true')){
            pageFlexTableName = 'ActiveExternalReviewers';     
            pageTitle = 'Active External Reviewers';      
        }        
        else if(isActive.equalsIgnoreCase('false')){
            pageFlexTableName='InactiveExternalReviewers';
            pageTitle = 'Inactive External Reviewers';
        }
        else{
            pageFlexTableName='InactiveExternalReviewers';
            pageTitle = 'Inactive External Reviewers';
        }                        
             
            
    }
    

}