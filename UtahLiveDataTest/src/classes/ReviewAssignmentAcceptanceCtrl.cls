/**
* Acceptance page controller for the ReviewAssignment__c object
* 
* CHANGE HISTORY
* =============================================================================
* Date          Name            Description
* 05/21/2014    Ryan Chadwick   Created
* 11/14/2014    Nakul           Updated as per new changes 
* =============================================================================
*/

public with sharing class ReviewAssignmentAcceptanceCtrl {

    //Properties
    public ID recordId{get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    public String pageTemplateName{get;set;}
    private Review__c reviewAssignmentObj;
    private PanelApplication__c reviewStepApplicationObj;
    public String AppPreappName{get;set;}
    
    public ReviewAssignmentAcceptanceCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('Id');
        
        List<Review__c> reviewList = [Select Application__c, Application__r.Name , PreApplication__c, PreApplication__r.Name From Review__c Where Id =: recordId LIMIT 1];
        if(reviewList.size() > 0){
        	if(reviewList[0].Application__c != null){
        		AppPreappName = reviewList[0].Application__r.Name;
        	}else{
        		AppPreappName = reviewList[0].PreApplication__r.Name;
        	}
        }
        savePage = Page.ReviewRedirect;
        savePage.getParameters().put('id', recordId);
        
        cancelPage = Page.ReviewAcceptanceView;
        cancelPage.getParameters().put('id', recordId);
        
        if(recordId != null){
            pageTemplateName = 'ReviewAcceptanceTemplate';          
        }
    }
}