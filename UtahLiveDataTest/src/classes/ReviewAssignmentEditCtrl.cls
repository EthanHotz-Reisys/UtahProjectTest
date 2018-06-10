/**
    Controller for ReviewAssignmentEdit page
    **********************************************************
    Audit History
    **********************************************************
    4/27/2014   Kunal Shah              Created
    11/19/2014  Nakul           Updated for Review panel changes
    **********************************************************  
*/
public with sharing class ReviewAssignmentEditCtrl {
    
    //Properties
    public ID recordId{get;set;}
    public ID taskId{get;set;}
    public Review__c assignment{get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    public String pageTemplateName {get;set;}
    
    public ReviewAssignmentEditCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');
        taskId = ApexPages.CurrentPage().getParameters().get('taskId');
        String isChair = ApexPages.CurrentPage().getParameters().get('isChair');
        assignment = [SELECT Id, Name, ReviewPanel__r.ReviewStep__r.ReviewFormConfig__r.Name,Application__c,Application__r.OwnerId, 
            PreApplication__c,PreApplication__r.OwnerId, ReviewPanel__r.ReviewStep__r.ReviewGroup__r.Announcement__r.Program__r.ReviewProcess__c 
                    FROM Review__c WHERE id =: recordId];
                    system.debug('assignment=====>>>'+assignment);
                    system.debug('isChair=====>>>'+isChair);
                     system.debug('assignment.ReviewPanel__r.ReviewPackage__r.GNT__PageTemplateConfig__r.Name=====>>>'+assignment.ReviewPanel__r.ReviewStep__r.ReviewFormConfig__r.Name);
        if(!String.isEmpty(isChair) && isChair.equalsIgnoreCase('true')){
            pageTemplateName = 'ReviewModifyDecisionTemplate';
        }
        else if (assignment.ReviewPanel__r.ReviewStep__r.ReviewGroup__r.Announcement__r.Program__r.ReviewProcess__c == 'One step review') {
            pageTemplateName = 'OneStepReviewForm';
        }
        else{
            pageTemplateName = assignment.ReviewPanel__r.ReviewStep__r.ReviewFormConfig__r.Name;
        }
        
        savePage = Page.ReviewAssignmentView;
        savePage.getParameters().put('id', recordId);
        savePage.getParameters().put('taskId', taskId);
        system.debug('task Id on ReviewAssignmentEditCtrl is ' +taskId);
        cancelPage = Page.ReviewAssignmentView;
        cancelPage.getParameters().put('id', recordId);
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('parentid',ApexPages.currentPage().getParameters().get('id'));
        keyValueMap.put('taskId', taskId);
        if(assignment.PreApplication__c != null){
            keyValueMap.put('parentOwnerId',assignment.PreApplication__r.OwnerId);
        }else
        {
            keyValueMap.put('parentOwnerId',assignment.Application__r.OwnerId);
        }
        return JSON.serialize(keyValueMap);
    }
}