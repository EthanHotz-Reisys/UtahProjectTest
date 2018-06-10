global with sharing class AddReviewPanelHelper extends GNT.FlexTableActionHandler {
    
    public AddReviewPanelHelper() {}

    global override Map<String,Object> clickHandler(){
        Map<String, Object> resultMap = new Map<String, Object>();   
        try{
            String reviewStepId = urlParams.get('id');

            ReviewStep__c reviewStep = [Select Id, ReviewStepTemplate__c, RecordTypeId from ReviewStep__c where Id = :reviewStepId limit 1];

            ReviewStepTemplate__c rst = [Select Id, Name, RecordTypeId from ReviewStepTemplate__c where Id = :reviewStep.ReviewStepTemplate__c limit 1];

            ReviewPanelTemplate__c rpt = [Select Id, GroupId__c, GroupName__c, RecordTypeId, Chair__c, AutoAssignSubmittedApplication__c,
                                                Sequence__c, ReviewPackage__c, Name, IsDefaultPanel__c, Description__c, UserType__c, PanelLayout__c, Purpose__c,
                                                ExcludeFromScoring__c, EndDate__c, ReviewStepTemplate__r.StepNumber__c, TaskDueDate__c, DueDateOffset__c, 
                                                ReviewerAssignNotificationTemplate__c from ReviewPanelTemplate__c where ReviewStepTemplate__c = :rst.Id limit 1];

            Id rsRecTypeIdApp = Schema.SObjectType.ReviewStep__c.getRecordTypeInfosByName().get('Application').getRecordTypeId();
            Id rsRecTypeIdPreApp = Schema.SObjectType.ReviewStep__c.getRecordTypeInfosByName().get('Pre-Application').getRecordTypeId();
            
            Id rptRecTypeIdApp = Schema.SObjectType.ReviewPanelTemplate__c.getRecordTypeInfosByName().get('Application').getRecordTypeId();
            Id rptRecTypeIdPreApp = Schema.SObjectType.ReviewPanelTemplate__c.getRecordTypeInfosByName().get('Pre-Application').getRecordTypeId();
            
            Id rpRecTypeIdApp = Schema.SObjectType.ReviewPanel__c.getRecordTypeInfosByName().get('Application').getRecordTypeId();
            Id rpRecTypeIdPreApp = Schema.SObjectType.ReviewPanel__c.getRecordTypeInfosByName().get('Pre-Application').getRecordTypeId();

            ReviewPanel__c reviewPanel = new ReviewPanel__c();

            if(reviewStep.RecordTypeId == rsRecTypeIdApp && rpt.RecordTypeId == rptRecTypeIdApp){
                reviewPanel.RecordTypeId = rpRecTypeIdApp;
            }

            reviewPanel.ReviewStep__c = reviewStep.Id;
            reviewPanel.Chair__c = rpt.Chair__c;
            reviewPanel.GroupId__c = rpt.GroupId__c;
            reviewPanel.GroupName__c = rpt.GroupName__c;
            reviewPanel.Sequence__c = rpt.Sequence__c;
            reviewPanel.IsDefaultPanel__c = rpt.IsDefaultPanel__c;
            reviewPanel.ReviewPackage__c = rpt.ReviewPackage__c;
            reviewPanel.AutoAssignSubmittedApplication__c = rpt.AutoAssignSubmittedApplication__c;
            reviewPanel.PanelName__c = rpt.Name;
            reviewPanel.UserType__c = rpt.UserType__c;
            reviewPanel.Purpose__c = rpt.Description__c;
            //reviewPanel.ReviewFormConfig__c = rpt.ReviewFormConfig__c;
            //reviewPanel.ReviewPanelTemplate__c = rpt.Id;
            reviewPanel.PanelLayout__c = rpt.PanelLayout__c;
            reviewPanel.ExcludeFromScoring__c = rpt.ExcludeFromScoring__c;
            reviewPanel.TaskDueDate__c = rpt.TaskDueDate__c;
            reviewPanel.DueDateOffset__c = rpt.DueDateOffset__c;

            //if(rpt.ReviewStepTemplate__r.StepNumber__c == 1)
            //  reviewPanel.EndDate__c = rpt.EndDate__c;
            //reviewPanel.Purpose__c = rpt.Purpose__c;
            reviewPanel.ReviewerAssignNotificationTemplate__c = rpt.ReviewerAssignNotificationTemplate__c;

            insert reviewPanel;
            resultMap.put('Message', 'New Panel has been successfully added');
            resultMap.put('Type','success');

            
        }catch(Exception e){
            resultMap.put('Message', e.getMessage());
            resultMap.put('Type', 'danger');
        }
        return resultMap;
    }
}