global with sharing class PanelApplicationAddHelper extends GNT.FlexTableActionHandler {
    global override Map<String,Object> clickHandler(){
        Map<String,Object> resultMap = new Map<String,Object>();
        Boolean allowReview = true;
        Id panelId = urlParams.get('id');
        ReviewPanel__c revPanel = [Select Id,ReviewStep__c,ReviewStepName__c,ReviewStep__r.ReviewGroup__r.CurrentReviewStep__c, 
            ReviewStep__r.StepNumber__c FROM ReviewPanel__c where id =: panelId limit 1];
        
        ReviewStep__c rstep = [Select Id,StepNumber__c From ReviewStep__c Where Name = :revPanel.ReviewStep__r.ReviewGroup__r.CurrentReviewStep__c LIMIT 1];
        List<ReviewStepApplication__c> rsApplications = [Select id,IsOGMPromoted__c,Decision__c FROM ReviewStepApplication__c where ReviewStep__c =: revPanel.ReviewStep__c and Decision__c = 'Pending' and IsOGMPromoted__c = true];
        if(rsApplications.size() > 0) {
            allowReview = true;
        }
        if((revPanel.ReviewStepName__c != revPanel.ReviewStep__r.ReviewGroup__r.CurrentReviewStep__c 
            && rstep != null && revPanel.ReviewStep__r.StepNumber__c < rstep.StepNumber__c)) {
            resultMap.put('Message','Applications have been sent to '+revPanel.ReviewStep__r.ReviewGroup__r.CurrentReviewStep__c+' Step, you cannot add Applications now');
        }
        else if(allowReview == true || (revPanel.ReviewStepName__c == revPanel.ReviewStep__r.ReviewGroup__r.CurrentReviewStep__c && revPanel.ReviewStep__r.StepNumber__c >= rstep.StepNumber__c)) {
            String pageReferenceUrl = '/apex/PanelApplicationAdd?id='+panelId+'&tabName=Applications';
            resultMap.put('PageReference',pageReferenceUrl);
        }
        return resultMap;
    }
}