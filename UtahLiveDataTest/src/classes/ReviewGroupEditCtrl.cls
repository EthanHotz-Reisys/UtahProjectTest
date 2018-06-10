public with sharing class ReviewGroupEditCtrl {
    
    //Properties
    public ID recordId{get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    public ReviewGroup__c reviewGrp{get;set;}
    public String recordType {get;set;}
    public String templateName {get;set;}
    
    public ReviewGroupEditCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');   
        if(recordId != null){
            reviewGrp = [SELECT ID,Name,Announcement__c,AnnouncementName__c,RecordType.Name FROM ReviewGroup__c WHERE Id = :recordId];
            recordType = reviewGrp.RecordType.Name;
            if(recordType != null && recordType == 'Application') {
                templateName = 'ApplicationReviewGroup';
            } else if(recordType != null && recordType == 'Pre-Application') {
                templateName = 'PreapplicationReviewGroup';
            }
        }
        savePage = Page.ReviewGroupView;
        savePage.getParameters().put('id', recordId);
        cancelPage = Page.ReviewGroupView;
        cancelPage.getParameters().put('id', recordId);
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('reviewGroupId',ApexPages.currentPage().getParameters().get('id'));
        if(recordId != null){
            keyValueMap.put('announcementId',reviewGrp.Announcement__c);
        }
        return JSON.serialize(keyValueMap);
    }
}