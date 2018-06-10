global with sharing class PanelUserAddHelper extends GNT.FlexTableActionHandler {
    global override Map<String,Object> clickHandler(){
        Map<String,Object> resultMap = new Map<String,Object>();
        Boolean allowReview = false;

        system.debug('inside PanelUserAddHelper---');

        Id panelId = urlParams.get('id');

          system.debug('inside PanelUserAddHelper---panelId--'+panelId);

        ReviewPanel__c revPanel = [Select Id,ReviewStep__c,ReviewStepName__c,ReviewStep__r.ReviewGroup__r.CurrentReviewStep__c FROM ReviewPanel__c where id =: panelId limit 1];
        
  system.debug('inside PanelUserAddHelper---revPanel--'+revPanel);

        List<ReviewStepApplication__c> rsApplications = [Select id,Decision__c FROM ReviewStepApplication__c where ReviewStep__c =: revPanel.ReviewStep__c and Decision__c = 'Pending' ];
     system.debug('inside PanelUserAddHelper---rsApplications--'+rsApplications);


        if(rsApplications.size() > 0) {
            allowReview = true;
        }
        if(revPanel.ReviewStepName__c != revPanel.ReviewStep__r.ReviewGroup__r.CurrentReviewStep__c) {
            resultMap.put('Message','Applications have been sent to '+revPanel.ReviewStep__r.ReviewGroup__r.CurrentReviewStep__c+' Step, you cannot add Reviewers now');
        }
        else if(allowReview == true || (revPanel.ReviewStepName__c == revPanel.ReviewStep__r.ReviewGroup__r.CurrentReviewStep__c)) {
            String pageReferenceUrl = '/apex/PanelUserAdd?id='+panelId+'&tabName=Reviewers';
            resultMap.put('PageReference',pageReferenceUrl);
        }
        return resultMap;
    }
}