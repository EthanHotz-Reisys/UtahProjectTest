global with sharing class SendApproveRejectEmailHelper extends GNT.FlexTableActionHandler {
    
    global override Map<String,Object> clickHandler(){
        Map<String,Object> resultMap = new Map<String,Object>();
        String ns = AppUtils.getNamespacePrefix(); 
        Id reviewStepId = urlParams.get('reviewStepId');
        String action = urlParams.get('action');        
        List<Id> selectedRecords = new List<Id>();        
        Id targetObjectId ;
        Map<Id,Id> appOwnerIdToAppIdMap = new Map<Id,Id>();
        // GET THE CURRENT REVIEW STEP
        ReviewStep__c reviewStep = [Select Id,Name,RejectionEmailTemplate__c,
                                    ApprovalEmailTemplate__c, RecordType.DeveloperName 
                                    from ReviewStep__c where Id =: reviewStepId];        
        
        String templateName = '';
        
        if(action.equalsIgnoreCase('promoteemail')){
            templateName = reviewStep.ApprovalEmailTemplate__c;
        }
        else if(action.equalsIgnoreCase('rejectemail')){
            templateName = reviewStep.RejectionEmailTemplate__c;
        }

        try{
            //GET THE CURRENTLY SELECTED REVIEW STEP APPLICATIONS
            if(!String.isEmpty(templateName)){
                List<ReviewStepApplication__c> selectedReviewStepApps = [SELECT Id,Name,RecordType.Name,ApplicantNotifiedOn__c,
                                                                         application__r.OwnerId, preapplication__r.OwnerId, ApplicantNotified__c,
                                                                         Application__c,PreApplication__c
                                                                         FROM ReviewStepApplication__c 
                                                                         WHERE Id IN :selectedRecordIds  
                                                                         LIMIT :GNT.AppUtils.SOQL_LIMIT];                 
                
                if(selectedReviewStepApps != null){
                    for(ReviewStepApplication__c app: selectedReviewStepApps) {

                        if(app.RecordTypeId == Schema.SObjectType.ReviewStepApplication__c.getRecordTypeInfosByName().get('Application').getRecordTypeId()) {
                            targetObjectId = app.application__r.OwnerId;
                            appOwnerIdToAppIdMap.put(targetObjectId,app.Application__c);
                        }else{
                            targetObjectId = app.preapplication__r.OwnerId;
                            appOwnerIdToAppIdMap.put(targetObjectId,app.PreApplication__c);
                        }
                        app.ApplicantNotifiedOn__c = System.now();
                        app.ApplicantNotified__c = true;
                    }   
                    upsert selectedReviewStepApps;

                    List<EmailTemplate> template = [SELECT id FROM EmailTemplate WHERE DeveloperName = :templateName LIMIT 1];
                    if(template.size() > 0){
                        List<User> lstUser = [SELECT u.ContactId FROM User u WHERE u.Id IN :appOwnerIdToAppIdMap.keySet()];
                        Map<Id,Id> appIdToContIdMap = new Map<Id,Id>();
                        for(User u : lstUser){
                            appIdToContIdMap.put(appOwnerIdToAppIdMap.get(u.id),u.contactId);
                        }
                        GNT.AppUtils.sendEmailUsingTemplate(template[0].id,appIdToContIdMap,true); 
                    }
                }    
            }else{
                //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'Email template is not defined at Review step level.');
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-87846'));
                ApexPages.addMessage(myMsg);
                return null;
            }
        }catch(DMLException e) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, e.getMessage());
            ApexPages.addMessage(myMsg);
            return null;
        }
        String PageReferenceURL = '/apex/'+ns+'ReviewStepView?id=' + reviewStepId;
        resultMap.put('PageReference',PageReferenceURL);
        return resultMap;
    }
}