global with sharing class ReviewApplicationPromoteHelper extends GNT.FlexTableActionHandler {
    
    public ReviewApplicationPromoteHelper (){}
    
    global override Map<String,Object> clickHandler(){
        
        Map<String,Object> resultMap = new Map<String,Object>(); 
                        system.debug('-inside clickHandler');
                        Savepoint sp = Database.setSavepoint();
        
        String ns = AppUtils.getNamespacePrefix(); 
        Id reviewStepId = urlParams.get('reviewStepId');
        String action = urlParams.get('action');
        
     //   List<Id> selectedRecords = new List<Id>();
        
        // GET THE CURRENT REVIEW STEP
        System.debug('revstepid '+reviewStepId);
        ReviewStep__c reviewStep = [Select Id,Name,StepNumber__c,ReviewGroup__c,LastStep__c,ReviewStepExpired__c,
                                    RecordType.Name, RecordType.DeveloperName 
                                    from ReviewStep__c where Id =: reviewStepId];
        
        
        /*if(reviewStep.RecordType.DeveloperName == 'Application'){
            selectedRecords = GNT.RecordIdStorageHelper.getRecordIds('RSApplicationSelectedForPromotion');
        }else{
            selectedRecords = GNT.RecordIdStorageHelper.getRecordIds('RSPreapplicationSelectedForPromotion');
        }*/
        Id targetObjectId ;
        Map<Id,Id> appOwnerIdToAppIdMap = new Map<Id,Id>();
        Id nextReviewStepId;
        Integer currentStep = Integer.valueOf(reviewStep.StepNumber__c);
        Integer nextStep = currentStep + 1;
        try{
            List<ReviewStep__c> nextReviewSteps = [SELECT Id,Name,ReviewGroup__c FROM ReviewStep__c 
                                                    WHERE StepNumber__c >=: nextStep 
                                                    AND ReviewGroup__c =: reviewStep.ReviewGroup__c 
                                                    Order by StepNumber__c LIMIT 1 ];
           
                                                    
            //CHECK IF THE NEXT STEP EXISTS                                     
            if(nextReviewSteps.size() > 0){
                
                Id reviewApplications;
                nextReviewStepId = nextReviewSteps.get(0).Id;
                //GET THE CURRENTLY SELECTED REVIEW STEP APPLICATIONS
                List<ReviewStepApplication__c> selectedReviewStepApps = [SELECT Id,Name,RecordType.Name,Decision__c, DecidedOn__c,
                                                                         application__r.OwnerId, preapplication__r.OwnerId,
                                                                         Application__c,PreApplication__c, ReviewStep__r.ApprovalEmailTemplate__c 
                                                                         FROM ReviewStepApplication__c 
                                                                         WHERE Id IN :selectedRecordIds
                                                                         LIMIT :GNT.AppUtils.SOQL_LIMIT]; // AND Status__c = 'Promoted'
                
                
                List<ReviewStepApplication__c> lstPromotedApps = new List<ReviewStepApplication__c>();
                
                if(nextReviewStepId != null && selectedReviewStepApps != null){
                    for(ReviewStepApplication__c app: selectedReviewStepApps) {
                        if(app.Decision__c != 'Promoted'){
                            ReviewStepApplication__c promotedApp = new ReviewStepApplication__c();
                            if(reviewStep.RecordType.Name == 'Application'){
                                promotedApp.Application__c = app.Application__c;   
                                promotedApp.RecordTypeId=Schema.SobjectType.ReviewStepApplication__c.getRecordTypeInfosByName().get('Application').getRecordTypeId();
                            }else{
                                promotedApp.PreApplication__c = app.PreApplication__c;
                                promotedApp.RecordTypeId=Schema.SobjectType.ReviewStepApplication__c.getRecordTypeInfosByName().get('Pre-Application').getRecordTypeId();
                            }
                            promotedApp.ReviewStep__c = nextReviewStepId;
                            lstPromotedApps.add(promotedApp);   
                            
                            app.Status__c = 'Approved';
                            app.Decision__c = 'Promoted';
                            app.DecidedOn__c = System.now();
                            app.DecidedBy__c = UserInfo.getUserId();
                        }
                        for(Id selectedId :selectedRecordIds){
                            if(selectedId == app.id){
                                if(app.RecordTypeId == Schema.SObjectType.ReviewStepApplication__c.getRecordTypeInfosByName().get('Application').getRecordTypeId()) {
                                    targetObjectId = app.application__r.OwnerId;
                                    appOwnerIdToAppIdMap.put(targetObjectId,app.Application__c);
                                }else{
                                    targetObjectId = app.preapplication__r.OwnerId;
                                    appOwnerIdToAppIdMap.put(targetObjectId,app.PreApplication__c);
                                }
                                app.ApplicantNotifiedOn__c = System.now();
                                app.ApplicantNotified__c = true;
                                
                                break;
                            }
                        }
                        lstPromotedApps.add(app);
                    }   
                }
                // update old RSA to Promoted and create new RSA for next Review Step
                if(lstPromotedApps.size()>0){
                    //upsert lstPromotedApps;
                    Database.UpsertResult[] results = Database.upsert(lstPromotedApps, false);
                    
                    if(reviewStep.RecordType.DeveloperName == 'Application'){
                        GNT.RecordIdStorageHelper.deleteRecordIds('RSApplicationSelectedForPromotion');
                    }else{
                        GNT.RecordIdStorageHelper.deleteRecordIds('RSPreapplicationSelectedForPromotion');
                    }
                    
                    String templateName = selectedReviewStepApps[0].ReviewStep__r.ApprovalEmailTemplate__c;
                    List<EmailTemplate> template = [SELECT id FROM EmailTemplate WHERE DeveloperName = :templateName LIMIT 1];
                    if( templateName !=null && template.size() > 0){
                        List<User> lstUser = [SELECT u.ContactId FROM User u WHERE u.Id IN :appOwnerIdToAppIdMap.keySet()];
                        Map<Id,Id> appIdToContIdMap = new Map<Id,Id>();
                        for(User u : lstUser){
                            appIdToContIdMap.put(appOwnerIdToAppIdMap.get(u.id),u.contactId);
                        }
                        GNT.AppUtils.sendEmailUsingTemplate(template[0].id,appIdToContIdMap,true); 
                    }
                }else{
                    ApexPages.Message myMsg;
                    if(reviewStep.RecordType.Name == 'Application'){
                        //myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'Please select atleast one application to promote.');
                        myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,GNT.ErrorMessageHelper.fetchMessage('M01-GRNTR-74690'));
                    }else{
                        //myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'Please select atleast one pre-application to promote.');
                        myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,GNT.ErrorMessageHelper.fetchMessage('M01-GRNTR-45294'));
                    }
                    ApexPages.addMessage(myMsg);
                    return null;
                }                 
            }else if(reviewStep.LastStep__c){            
               
                    approveAppOrPreApp(selectedRecordIds);
                
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
    
    private void approveAppOrPreApp(List<Id> selectedRecords){
        Id targetObjectId ;
        Map<Id,Id> appOwnerIdToAppIdMap = new Map<Id,Id>();
        system.debug('**selectedRecords**'+selectedRecords);
        
        List<ReviewStepApplication__c> selectedReviewStepApps = [SELECT Id,Name,RecordType.Name,Decision__c, DecidedOn__c,
                         application__r.OwnerId, preapplication__r.OwnerId, Application__c,PreApplication__c, PreApplication__r.status__c,
                         ReviewStep__r.ApprovalEmailTemplate__c 
                         FROM ReviewStepApplication__c 
                         WHERE Id IN :selectedRecords  
                         LIMIT :GNT.AppUtils.SOQL_LIMIT];
                         
        Set<Id> preAppIds = new Set<Id>();
        Set<Id> appIds = new Set<Id>();
        
        for(ReviewStepApplication__c rsa : selectedReviewStepApps){

            rsa.Status__c = 'Approved';
            rsa.Decision__c = 'Promoted';
            rsa.DecidedOn__c = System.now();
            for(Id selectedId : selectedRecordIds){
                
                
                if(selectedId == rsa.id){
                    if(rsa.RecordTypeId == Schema.SObjectType.ReviewStepApplication__c.getRecordTypeInfosByName().get('Application').getRecordTypeId()) {
                        targetObjectId = rsa.application__r.OwnerId;
                        appOwnerIdToAppIdMap.put(targetObjectId,rsa.Application__c);
                        
                        appIds.add(rsa.Application__c);
                    }else{
                        targetObjectId = rsa.preapplication__r.OwnerId;
                        appOwnerIdToAppIdMap.put(targetObjectId,rsa.PreApplication__c);
                        preAppIds.add(rsa.PreApplication__c);
                    }
                    rsa.ApplicantNotifiedOn__c = System.now();
                    rsa.ApplicantNotified__c = true;
                    
                    break;
                }
            }
        }
        
        
        

        if(preAppIds.size() > 0){
            List<PreApplication__c> preAppList = [select status__c from PreApplication__C where id in :preAppIds];
            
            for(PreApplication__c preApp :preAppList){
                preApp.status__c = 'Approved';
            }           
            update preAppList;
        }
        if(appIds.size() > 0){
            List<Application__c> appList = [select status__c from Application__C where id in :appIds];
            
            for(Application__c app :appList){
                app.status__c = 'Approved';
            }           
            update appList;
        }
        
        update selectedReviewStepApps;
        
        String templateName = selectedReviewStepApps[0].ReviewStep__r.ApprovalEmailTemplate__c;
        List<EmailTemplate> template = [SELECT id FROM EmailTemplate WHERE DeveloperName = :templateName LIMIT 1];
        if( templateName !=null && template.size() > 0){
            List<User> lstUser = [SELECT u.ContactId FROM User u WHERE u.Id IN :appOwnerIdToAppIdMap.keySet()];
            Map<Id,Id> appIdToContIdMap = new Map<Id,Id>();
            for(User u : lstUser){
                appIdToContIdMap.put(appOwnerIdToAppIdMap.get(u.id),u.contactId);
            }
            GNT.AppUtils.sendEmailUsingTemplate(template[0].id,appIdToContIdMap,true); 
        }
    }
}