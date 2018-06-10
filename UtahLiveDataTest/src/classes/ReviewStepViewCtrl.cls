public with sharing class ReviewStepViewCtrl {

    //Properties
    public ID recordId{get;set;}
    public ReviewStep__c reviewStep{get;set;}
    public String recordType {get;set;}
    public String pageHeader {get;set;}
    public string templateName {get;set;}
    private String panelId {get;set;}

    public ReviewStepViewCtrl(ApexPages.StandardController stdController){
        pageHeader = 'Review Step';
        recordId = ApexPages.CurrentPage().getParameters().get('id'); 
        system.debug('  recordId---'+recordId);  
        if(recordId != null){
            //reviewStep = [SELECT ID,Name,RecordType.DeveloperName, AnnouncementId__c, CountReviewPanels__c, ReviewGroup__c, ReviewGroup__r.Announcement__r.Name, ReviewGroup__r.Announcement__r.Program__r.ReviewProcess__c, 
            //    ReviewStepLayout__r.Name FROM ReviewStep__c WHERE Id = :recordId];
            SystemContextMethodsHelper syscon = new SystemContextMethodsHelper();
            reviewStep = syscon.getRevStep(recordId);
            system.debug('  reviewStep---'+reviewStep);
            recordType = reviewStep.RecordType.DeveloperName;
            pageHeader += '-' + reviewStep.Name;
 
            Announcement__c ann = [SELECT ID,OrganizationName__c from announcement__c where id = :reviewStep.ReviewGroup__r.Announcement__c  LIMIT 1];
            if (reviewStep.ReviewGroup__r.Announcement__r.Program__r.ReviewProcess__c != null && reviewStep.ReviewGroup__r.Announcement__r.Program__r.ReviewProcess__c == 'One step review') {
                if (reviewStep.Name == 'Funding Decision Memo') {
                    if (ann.OrganizationName__c == 'UOVC')
                    templateName = 'OneStepReviewFundingDecisionMemoTemplate';
                    if (ann.OrganizationName__c == 'USBE')
                    templateName = 'OneStepReviewFundingDecisionMemoUSBETemplate';
                }
                else {
                    templateName = 'ApplicationOneReviewStep';
                }
            }
            else { //Is not a One Step Review workflow
                if (reviewStep.Name == 'Funding Decision Memo') {
                    if (ann.OrganizationName__c == 'UOVC')
                    templateName = 'FundingDecisionMemoTemplate';
                    if (ann.OrganizationName__c == 'USBE')
                    templateName = 'FundingDecisionMemoUSBETemplate';
                
                }
                else {
                    templateName = reviewStep.ReviewStepLayout__r.Name;
                }
            }
         
        }
        
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('reviewStepId',ApexPages.currentPage().getParameters().get('id'));
      //  keyValueMap.put('recordType',recordType);
        keyValueMap.put('recordTypeName',recordType);
        keyValueMap.put('revGroupId',reviewStep.ReviewGroup__c);
        keyValueMap.put('foName',reviewStep.ReviewGroup__r.Announcement__r.Name);
        keyValueMap.put('announcementID',reviewStep.AnnouncementId__c);
        system.debug('  keyValueMap---'+keyValueMap);

        return JSON.serialize(keyValueMap);
    }


}