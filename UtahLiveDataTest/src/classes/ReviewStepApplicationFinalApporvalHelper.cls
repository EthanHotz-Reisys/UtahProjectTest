global with sharing class ReviewStepApplicationFinalApporvalHelper  extends GNT.FlexTableActionHandler {
    global override Map<String,Object> clickHandler(){ //ApplicationsReviewStatus__c
        Map<String,Object> resultMap = new Map<String,Object> ();
        String reviewStepId = urlParams.get('id');
        ReviewStep__c reviewStep = [select ReviewGroup__c,ReviewGroup__r.Announcement__c,ReviewGroup__r.AnnouncementName__c,ReviewGroup__r.currentReviewStep__c, 
                                            StepNumber__c,SDDNotified__c, ReviewGroup__r.Announcement__r.Name, RecordType.Name, 
                                            DepartmentName__c From ReviewStep__c Where id = :reviewStepId];
        ReviewGroup__c rg = new ReviewGroup__c(id=reviewStep.ReviewGroup__c, Status__c='Submit for Approve');
       // rg.CurrentReviewStep__c='Internal Review';
        upsert rg;
                                            
        //GNT.TaskCreationHandler.createApprovalProcessTasks(rg.Id, 'Review ReviewGroup', rg.Name, null, System.TODAY() + 7,  true);
        GNT.TaskCreationHandler.createApprovalProcessTasks(rg.Id, 'Review ReviewGroup', rg.Name, null, System.TODAY() + 7, rg.AnnouncementName__c,  true);

        return resultMap;
    }

}