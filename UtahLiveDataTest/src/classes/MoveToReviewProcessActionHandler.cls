global with sharing class MoveToReviewProcessActionHandler extends GNT.FlexTableActionHandler {
    global override Map<String,Object> clickHandler() {
        Map<String,Object> resultMap = new Map<String,Object>();
        try{
            List<Application__c> appList = new List<Application__c>([SELECT Id, Announcement__c, Status__c, Announcement__r.Name FROM Application__c WHERE Id IN :selectedRecordIds]);

            if(appList.size() == 0){
                resultMap.put('Error','Please select a application to move to review');
                return resultMap;
            }

            for(Application__c app : appList){
                if(app.Status__c != 'Submitted to Grantor'){
                    resultMap.put('Error', 'Only applications "Submitted to Grantor" can be moved to review');
                    return resultMap;
                }
            }

            List<Id> annIdList = new List<Id>();
            
            for(Application__c app : appList){
                annIdList.add(app.Announcement__c);
            }
            List<ReviewStep__c> rsList = [SELECT Id, ReviewGroup__r.Announcement__c, StepNumber__c, RecordTypeId, Status__c FROM ReviewStep__c WHERE ReviewGroup__r.Announcement__c IN :annIdList AND StepNumber__c = 1];
            Map<Id, Id> annIdToRSIdForApplication = new Map<Id, Id>();
            
            for(ReviewStep__c rs : rsList){
                annIdToRSIdForApplication.put(rs.ReviewGroup__r.Announcement__c, rs.Id);
            } 
            List<ReviewStepApplication__c> rsaList = [SELECT Id, RecordTypeId, Application__c, PreApplication__c, ReviewStep__c FROM ReviewStepApplication__c WHERE ReviewStep__c IN : annIdToRSIdForApplication.values()];
            Map<Id, Id> appIdToStepAppIdMap = new Map<Id, Id>();

            for(ReviewStepApplication__c rsa : rsaList){
                appIdToStepAppIdMap.put(rsa.Application__c, rsa.Id);
            }

            Id appRecTypeId = Schema.SObjectType.ReviewStepApplication__c.getRecordTypeInfosByName().get('Application').getRecordTypeId();
            List<ReviewStepApplication__c> stepApplications = new List<ReviewStepApplication__c>();
            List<PanelApplication__c> panelApplications = new List<PanelApplication__c>(); 

            for(Application__c app : appList){
                if(appIdToStepAppIdMap.get(app.Id) == null){
                    Id revStepId = annIdToRSIdForApplication.get(app.Announcement__c);
                    if(revStepId != null){
                        stepApplications.add(new ReviewStepApplication__c(ReviewStep__c = revStepId, Application__c = app.Id, RecordTypeId = appRecTypeId));
                        app.Status__c = 'Review Initiated';
                    }else{
                        //resultMap.put('Message', 'Review Process of Announcement ' + app.Announcement__r.Name + ' doesn\'t start yet.');
                        resultMap.put('Error', 'You cannot move Applications to Review unless the Review Process for their corresponding Announcement has been initiated.');
                        return resultMap;
                    }
                }
            }
             
            if(stepApplications.size() > 0){
                insert stepApplications;
            }

            update appList;

            resultMap.put('Message', 'Successfully moved the application to review. '); 
        }catch(Exception e){
            resultMap.put('Error', 'Failed to move the application to review.' );
        }
        resultMap.put('PageReference', null);
        return resultMap;
    }
}