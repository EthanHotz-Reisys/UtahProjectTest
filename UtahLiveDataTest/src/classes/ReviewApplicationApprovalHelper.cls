global with sharing class ReviewApplicationApprovalHelper extends GNT.FlexTableActionHandler {
    
    global override Map<String,Object> clickHandler(){
        Map<String,Object> resultMap = new Map<String,Object>();
        
        
        String ns = AppUtils.getNamespacePrefix();         
        Id reviewStepId = urlParams.get('reviewStepId');
        
        
        List<Id> selectedRecords = new List<Id>();
        ReviewStep__c reviewStep = [SELECT ID, RecordType.DeveloperName FROM ReviewStep__c WHERE Id = :reviewStepId];
        if(reviewStep.RecordType.DeveloperName == 'Application'){
            selectedRecords = GNT.RecordIdStorageHelper.getRecordIds('RSApplicationSelectedForFinalApprover');
        }else{
            selectedRecords = GNT.RecordIdStorageHelper.getRecordIds('RSPreapplicationSelectedForFinalApprover');
        }
        
        
        try{
            List<GNT.TaskCreationHandler.TaskBulkClass> taskBulkList =  new List<GNT.TaskCreationHandler.TaskBulkClass> ();
            List<ReviewStepApplication__c> selectedReviewStepApps = [SELECT Id,Name, RecordTypeId,Application__c, 
                Application__r.OwnerId, PreApplication__r.OwnerId, ReviewStep__r.ApprovalEmailTemplate__c, 
                Application__r.Announcement__r.ApplicationFinalApprover__c,PreApplication__c, PreApplication__r.Announcement__r.PreApplicationFinalApprover__c,
                Application__r.Announcement__c,Application__r.Title__c,PreApplication__r.Announcement__c, PreApplication__r.Title__c,
                decision__c,Status__c,DecidedOn__c
                    FROM ReviewStepApplication__c WHERE Id IN :selectedRecords LIMIT :GNT.AppUtils.SOQL_LIMIT];
            
            if(selectedReviewStepApps.size() > 0){
                system.debug('Review Step Application####'+selectedReviewStepApps);
                Id targetObjectId ,whatId;//= new List<Id>();
                Id reviewApplications;// = new List<id>();
                
                Map<Id,Id> sendEmailMap = new Map<Id,Id>();
                String templateName = selectedReviewStepApps[0].ReviewStep__r.ApprovalEmailTemplate__c;
                List<EmailTemplate> template = [SELECT id FROM EmailTemplate WHERE DeveloperName = :templateName LIMIT 1];

                if(template != null && template.size() > 0){
                    for(ReviewStepApplication__c app : selectedReviewStepApps) {
                        if(app.Decision__c != 'Promoted'){
                            app.Status__c = 'Approved';
                            app.Decision__c = 'Promoted';
                            app.DecidedOn__c = System.now();
                            app.DecidedBy__c = UserInfo.getUserId();
                        }
                     GNT.TaskCreationHandler.TaskBulkClass taskBulkInstance = new GNT.TaskCreationHandler.TaskBulkClass();
                        
                        taskBulkInstance.action = 'Review Applications';
                        if(app.RecordTypeId == Schema.SObjectType.ReviewStepApplication__c.getRecordTypeInfosByName().get('Application').getRecordTypeId()) {
                            taskBulkInstance.ownerUserId = app.Application__r.Announcement__r.ApplicationFinalApprover__c;
                            taskBulkInstance.recordId = app.Application__r.Announcement__c;
                            taskBulkInstance.recordName = app.Application__r.Title__c;
                        }else{
                            taskBulkInstance.ownerUserId = app.PreApplication__r.Announcement__r.PreApplicationFinalApprover__c;
                            taskBulkInstance.recordId = app.PreApplication__r.Announcement__c;
                            taskBulkInstance.recordName = app.PreApplication__r.Title__c;
                        }
                        taskBulkList.add(taskBulkInstance);
                        
                        for(ID id :selectedRecordIds){
                            if(id == app.id){
                                if(app.RecordTypeId == Schema.SObjectType.ReviewStepApplication__c.getRecordTypeInfosByName().get('Application').getRecordTypeId()) {
                                    targetObjectId = app.application__r.OwnerId;
                                    whatId = app.application__c;
                                }else{
                                    targetObjectId = app.preapplication__r.OwnerId;
                                    whatId = app.preapplication__c;
                                }
                                
                                app.ApplicantNotifiedOn__c = System.now();
                                app.ApplicantNotified__c = true;
                                sendEmailMap.put(targetObjectId,whatId);
                                break;
                            }
                        }
                    }
                    
                    if(selectedReviewStepApps.size() > 0){
                        update selectedReviewStepApps;
                        
                        if(reviewStep.RecordType.DeveloperName == 'Application'){
                         GNT.RecordIdStorageHelper.deleteRecordIds('RSApplicationSelectedForFinalApprover');
                        }else{
                         GNT.RecordIdStorageHelper.deleteRecordIds('RSPreapplicationSelectedForFinalApprover');
                        }
                        
                        //Create Tasks
                     GNT.TaskCreationHandler.createBulkTasks(taskBulkList, true);
                        
                        List<User> lstUser = [SELECT u.ContactId FROM User u WHERE u.Id IN :sendEmailMap.keySet()];
                        Map<Id,Id> appIdToContIdMap = new Map<Id,Id>();
                        for(User u : lstUser){
                            appIdToContIdMap.put(sendEmailMap.get(u.id),u.contactId);
                        }
                     GNT.AppUtils.sendEmailUsingTemplate(template[0].id,appIdToContIdMap, true);
                        //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'Mail Sent Successfuly!!');
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, GNT.ErrorMessageHelper.fetchMessage('M01-GRNTR-45133'));
                        ApexPages.addMessage(myMsg);
                    }
                }
            }
        }
        catch(DMLException e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, e.getMessage());
            ApexPages.addMessage(myMsg);
        }
        
        String PageReferenceURL = '/apex/'+ns+'ReviewStepView?id=' + reviewStepId;
        resultMap.put('PageReference',PageReferenceURL);
        return resultMap;
    }    
}