global with sharing class ReviewRejectHelper extends GNT.FlexTableActionHandler{

   global override Map<String,Object> clickHandler(){
        Map<String,Object> resultMap = new Map<String,Object>();
        String ns = AppUtils.getNamespacePrefix();         
        Id reviewStepId = urlParams.get('id');        
        ReviewStep__c reviewStep = [SELECT ID, RecordType.DeveloperName FROM ReviewStep__c WHERE Id = :reviewStepId];
        try{    
            List<Task> taskList = new List<Task>();
            List<ReviewStepApplication__c> selectedReviewStepApps = [SELECT Id,Name, RecordTypeId,  
                Status__c,  DecidedOn__c, DecidedBy__c, Decision__c, ApplicantNotifiedOn__c, ApplicantNotified__c,
                Application__r.OwnerId, PreApplication__r.OwnerId, ReviewStep__r.RejectionEmailTemplate__c
                    FROM ReviewStepApplication__c WHERE Id IN :selectedRecordIds LIMIT :GNT.AppUtils.SOQL_LIMIT];
            
            if(selectedReviewStepApps.size() > 0){
                Id targetObjectId,whatId ;
                Id reviewApplications;
                    for(ReviewStepApplication__c app : selectedReviewStepApps) {
                        if(app.Decision__c != 'Rejected'){
                            app.Status__c = 'Rejected';
                            app.Decision__c = 'Rejected';
                            app.DecidedOn__c = System.now();
                            app.DecidedBy__c = UserInfo.getUserId();
                        }
                    }
                    
                    if(selectedReviewStepApps.size() > 0){
                        update selectedReviewStepApps;
                        resultMap.put('Message','Review Rejected');
                    }
            }
        }
        catch(DMLException e){
        		resultMap.put('Message','Error :'+e.getMessage());
        }
        return resultMap;
    }
}