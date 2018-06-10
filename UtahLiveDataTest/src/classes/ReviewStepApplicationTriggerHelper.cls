/*
    All Trigger logic for Review Step Application Object
    ***********************************************************
    Audit History
    ***********************************************************
    06/25/2014      Kunal Shah              Created
    *********************************************************** 
*/

global with sharing class ReviewStepApplicationTriggerHelper extends GNT.TriggerHelper{
    global static boolean skipTrigger = false;
    public override void processBeforeInsert(){
        copyFieldValues();
    }
    public override void processAfterInsert(){
        //updateSMEScoreOnMgmt(trigger.newMap.keySet());
        //skipIfRecordAlreadyPresent();
       //updateApplicationCurrentReviewStep(trigger.newMap.keySet());
    }
    
    public override void processBeforeUpdate(){
        if(skipTrigger == false){
            updateDecisionDetails();
            updateFinalDecision();
     
            processRejectRequest();
            copyFieldValues();
        }
    }

    public override void processAfterUpdate() {
        if(skipTrigger == false){
            copyGrantAmountToApplication((List<ReviewStepApplication__c>)Trigger.New);
        }
        //closeOGMTask();
        //Award Enhancement
        
    }

    private static void copyGrantAmountToApplication(List<ReviewStepApplication__c> revStepApps){
        Map<Id,ReviewStepApplication__c> applicationToReviewStepApp= new Map<Id,ReviewStepApplication__c>();
        List<Id> applicationIds = new List<Id>();
        for(ReviewStepApplication__c revStepApp : revStepApps){
            if(revStepApp.Application__c!=null){
                applicationIds.add(revStepApp.Application__c);
                applicationToReviewStepApp.put(revStepApp.Application__c,revStepApp);
            }
        }
        List<Application__c> applications = [SELECT id,Name,FinalGrantAmountNegotiated__c from Application__c WHERE Id IN :applicationIds];
        for(Application__c application : applications){
            ReviewStepApplication__c revStepApp = applicationToReviewStepApp.get(application.Id);
            application.FinalGrantAmountNegotiated__c = revStepApp.AmountThisAction__c;
        }
        ApplicationTriggerHelper.skipTrigger=True;
        update applications;
        ApplicationTriggerHelper.skipTrigger=False;
    }
   
    private static void copyFieldValues(){
        Map<Id, List<Sobject>> appIdToSobjectMap = new Map<Id, List<Sobject>>();
        
        for(ReviewStepApplication__c rsa : (List<ReviewStepApplication__c>)trigger.new){
            if(rsa.Application__c != null){
                List<Sobject> newList = appIdToSobjectMap.get(rsa.Application__c);
                if(newList == null){
                    newList = new List<Sobject>();
                }
                newList.add(rsa);
                appIdToSobjectMap.put(rsa.Application__c, newList);
            }/*else if(rsa.PreApplication__c != null){
                // Todo- check if the simmilar implementation reqd for preapplication
            }*/
        }
        if(appIdToSobjectMap.size() > 0){
            GNT.AppUtils.copyRecords(AppUtils.getNamespacePrefix()+'Application__c',AppUtils.getNamespacePrefix()+'ReviewStepApplication__c', appIdToSobjectMap, false);
        }
    }
    private static void updateDecisionDetails(){
        for(ReviewStepApplication__c rsa : (List<ReviewStepApplication__c>)trigger.new){
            ReviewStepApplication__c oldRsa = (ReviewStepApplication__c)trigger.oldMap.get(rsa.Id);
            if(oldRsa.Decision__c != rsa.Decision__c){
                rsa.DecidedBy__c = UserInfo.getUserId();
                rsa.DecidedOn__c = System.now();
            }
        }
    }
    
    /*@future
    private static void updateApplicationCurrentReviewStep(Set<Id> rsaIdSet) {
        Map<Id,Id> applicationsMap = new Map<Id,Id>();
        Map<Id,Id> reviewGroups = new Map<Id,Id>();
        List<Id> reviewSteps = new List<Id>();

        Map<Id,ReviewStepApplication__c> rsaMap = new Map<Id,ReviewStepApplication__c>();
        
        List<ReviewStepApplication__c> lstRsa = [Select Id, Application__c,ReviewStep__r.ReviewGroup__c,ReviewStep__r.OGMApproved__c,ReviewStep__r.ODApproved__c,ReviewStep__r.SDDApproved__c, ReviewStep__c 
                                                From ReviewStepApplication__c 
                                                Where Id IN :rsaIdSet];
        for(ReviewStepApplication__c rsa : lstRsa) {
            rsaMap.put(rsa.Id,rsa);
        }
        
        system.debug('rsaMap: '+rsaMap);
        for(ReviewStepApplication__c rsApps : rsaMap.values()) {
            applicationsMap.put(rsApps.Id,rsApps.Application__c);
            reviewSteps.add(rsApps.ReviewStep__c);
            reviewGroups.put(rsApps.Id,rsApps.ReviewStep__r.ReviewGroup__c);
        }
        if(lstRsa[0].ReviewStep__r.SDDApproved__c != true && lstRsa[0].ReviewStep__r.OGMApproved__c != true && lstRsa[0].ReviewStep__r.ODApproved__c != true) {
            system.debug('appsMap: '+applicationsMap);
            system.debug('reviewSteps: '+reviewSteps);
            Map<Id,Application__c> appsMap = new Map<Id,Application__c>([Select id,CurrentReviewStep__c,CurrentReviewStepId__c FROM Application__c where id in: applicationsMap.values()]);
            Map<Id,ReviewGroup__c> reviewGroupsMap = new Map<Id,ReviewGroup__c>([Select id,CurrentReviewStep__c,CurrentReviewStepId__c FROM ReviewGroup__c where id in: reviewGroups.values()]);
            Map<Id,String> appToReviewStepName = new Map<Id,String>();
            Map<Id,ReviewStep__c> revStepMap = new Map<Id,ReviewStep__c>([Select Name,Id FROM ReviewStep__c where Id in: reviewSteps]);
            Map<Id,Id> appToAnnouncement = new Map<Id,Id>();

            for(ReviewStepApplication__c rsApplication : rsaMap.values()) {
                appsMap.get(applicationsMap.get(rsApplication.Id)).CurrentReviewStep__c = revStepMap.get(rsApplication.ReviewStep__c).Name;
                appsMap.get(applicationsMap.get(rsApplication.Id)).CurrentReviewStepId__c = revStepMap.get(rsApplication.ReviewStep__c).Id;
                reviewGroupsMap.get(rsApplication.ReviewStep__r.ReviewGroup__c).CurrentReviewStep__c = revStepMap.get(rsApplication.ReviewStep__c).Name;
                reviewGroupsMap.get(rsApplication.ReviewStep__r.ReviewGroup__c).CurrentReviewStepId__c = revStepMap.get(rsApplication.ReviewStep__c).Id;
                system.debug('New RSA curr step: '+revStepMap.get(rsApplication.ReviewStep__c).Name);
                system.debug('Application curr step: '+rsApplication.Id+'>>>>>'+reviewGroupsMap.get(rsApplication.ReviewStep__r.ReviewGroup__c).CurrentReviewStepId__c);
            }
            update appsMap.values();
            update reviewGroupsMap.values();

            system.debug('appsMap: '+appsMap.values());
       // system.debug('currRevApps: '+announcementList);
        }
    }*/
    
    private void processRejectRequest(){
        List<Id> reviewStepIds = new List<Id>();
        Map<Id,Id> rsaPreAppMap = new Map<Id,Id>();
        Map<Id,Id> rsaAppMap = new Map<Id,Id>();
        Map<Id,ReviewStepApplication__c> rsaMap = new Map<Id,ReviewStepApplication__c>();
        rsaMap = (Map<Id,ReviewStepApplication__c>)trigger.oldMap;        
        for(ReviewStepApplication__c rsa : (List<ReviewStepApplication__c>)trigger.new){ 
           if(rsa.status__c == 'Rejected' && rsaMap.get(rsa.id).Status__c == 'Approved'){
             if(rsa.PreApplication__c != null){
                 rsaPreAppMap.put(rsa.id,rsa.PreApplication__c);   
             }else{
                 rsaAppMap.put(rsa.id,rsa.Application__c);       
             }
           }
        }
        
        Map<Id,Application__c> appList = new Map<Id,Application__c> ();
        Map<Id,PreApplication__c> preappList = new Map<Id,PreApplication__c> ();
        if(rsaAppMap.size() > 0){
            appList = new Map<Id,Application__c>([select Status__c , Name from Application__c where id in :rsaAppMap.values()]);    
        }
        if(rsaPreAppMap.size() > 0){
            preappList = new Map<Id,PreApplication__c>( [select Name, Status__c from PreApplication__c where id in :rsaPreAppMap.values()]);
        }
           
           
        for(ReviewStepApplication__c rsa :  (List<ReviewStepApplication__c>)trigger.new){
            if(rsa.PreApplication__c != null){
                SObject PreApp = preappList.get(rsaPreAppMap.get(rsa.id));
                if(preApp != null){
                    if(PreApp.get('Status__c') == 'Approved'){
                        rsa.addError(Label.CantRejectApprovedItem+PreApp.get('Name'));
                    }else{
                        reviewStepIds.add(rsa.id);
                    }
                }
             }else{
                SObject App = appList.get(rsaAppMap.get(rsa.id));
                if(App != null){
                    if(App.get('Status__c') == 'Approved'){
                        rsa.addError(Label.CantRejectApprovedItem+App.get('Name'));
                    }else{
                        reviewStepIds.add(rsa.id);
                    }
                }
             }             
        }
        if(reviewStepIds.size () > 0){
            cleanUpReviewAfterReject(reviewStepIds);
        }
    }
    
    private void skipIfRecordAlreadyPresent(){
        //Get the record type ids for Review Step
        Id rsRecTypeIdApp = Schema.SObjectType.ReviewStepApplication__c.getRecordTypeInfosByName().get('Application').getRecordTypeId();       
        Set<Id> appId = new Set<Id>();
        Set<Id> preappId = new Set<Id>();
        Set<Id> revStepId = new Set<Id>();
        Map<Id, Id> rsaAppIdToRsaIdMap = new Map<Id, Id>();
        // get review step id
        for(ReviewStepApplication__c rsa : (List<ReviewStepApplication__c>) Trigger.new){
            revStepId.add(rsa.ReviewStep__c);
            
            if(rsa.RecordTypeId == rsRecTypeIdApp){
                appId.add(rsa.Application__c);
                rsaAppIdToRsaIdMap.put(rsa.Application__c, rsa.Id);
            }else{
                preappId.add(rsa.PreApplication__c);
                rsaAppIdToRsaIdMap.put(rsa.PreApplication__c, rsa.Id);
            }
        }
        
        // query RSA related to this review step
        
        List<ReviewStepApplication__c> lstStepApp = [Select id, Application__c, PreApplication__c From ReviewStepApplication__c Where ReviewStep__c IN :revStepId AND ID NOT IN :Trigger.new AND (Application__c IN :appId OR PreApplication__c IN : preappId )];
        for(ReviewStepApplication__c stepApp : lstStepApp){
            // check applications
            if(stepApp.RecordTypeId == rsRecTypeIdApp){
                // if the app is already present
                if(appId.contains(stepApp.Application__c)){
                    Id rsaId = rsaAppIdToRsaIdMap.get(stepApp.Application__c);
                    //trigger.newMap.get(rsaId).addError('Application already exists in this review step');
                    trigger.newMap.get(rsaId).addError(GNT.ErrorMessageHelper.fetchMessage('M01-GRNTR-28239'));
                }
            }else{
                // if the app is already present
                if(preappId.contains(stepApp.PreApplication__c)){
                    Id rsaId = rsaAppIdToRsaIdMap.get(stepApp.PreApplication__c);
                    //trigger.newMap.get(rsaId).addError('Pre-Application already exists in this review step');
                    trigger.newMap.get(rsaId).addError(GNT.ErrorMessageHelper.fetchMessage('M01-GRNTR-88613'));
                }
            }
        }
    }
    


    /* METHOD TO UPDATE THE FinalDecisionMade__c ON STEP APPLICATION WHEN STATUS IS APPROVED OR PROMOTED 
        FinalDecisionMade__c IS USED TO CHECK IF ITS A USER DRIVEN STATUS, HENCE SKIP updateStatus()
    */
    private void updateFinalDecision(){
        for(ReviewStepApplication__c rsa : (List<ReviewStepApplication__c>) Trigger.new){
            if(rsa.Status__c == 'Approved'){
                rsa.FinalDecisionMade__c = true;
            }
            Map<Id, Application__c> appMap = new Map<Id, Application__c>();
            system.debug('====In update final decision=======');
            if(rsa.Decision__c == 'Recommended for Award'||rsa.Decision__c == 'Recommended for Award with Reservation'){
                 Application__c app = new Application__c(Id=rsa.Application__c, Status__c='Revision In Progress');
                 system.debug('====app======='+app);
                 appMap.put(app.Id, app);
            }
            update appMap.values();
        }
    }
    
    
      public static void cleanUpReviewAfterReject(List<Id>reviewStepApplicationIds){
        List<ReviewStepApplication__c> reviewStepApplications = [select id,Status__c,Application__c,PreApplication__c,ReviewStep__r.ReviewGroup__c,
                    ReviewStep__c,ReviewStep__r.StepNumber__c
                    from ReviewStepApplication__c where id in :reviewStepApplicationIds and  ReviewStep__r.LastStep__c = false];
        Integer stepNumber ;
        List<Id> reviewGroupIds = new List<Id>();
        List<Id> applicationPreAppIds = new List<Id>();        
        if(reviewStepApplications.size ()  > 0){
            for(ReviewStepApplication__c rsa :reviewStepApplications){
                reviewGroupIds.add(rsa.ReviewStep__r.ReviewGroup__c) ;
                if(rsa.Application__c!=null){
                    applicationPreAppIds.add(rsa.Application__c);
                }else{
                    applicationPreAppIds.add(rsa.PreApplication__c);
                }
                stepNumber = Integer.valueOf(rsa.ReviewStep__r.StepNumber__c);
            }
            List<Id> reviewStepIds = new List<Id>();
            List<ReviewStep__c> reviewStep = [select id,StepNumber__c from ReviewStep__c where ReviewGroup__c in:reviewGroupIds];
            for(ReviewStep__c step : reviewStep){
                if(step.StepNumber__c > stepNumber){
                    reviewStepIds.add(step.id);
                }
            }
                        
            List<ReviewStepApplication__c> reviewStepApplicationsNextStep = [select id 
                        from ReviewStepApplication__c where ReviewStep__c in :reviewStepIds and  (Application__c in :applicationPreAppIds or  PreApplication__c in : applicationPreAppIds) ];
                        
            if(reviewStepApplicationsNextStep.size () > 0){
                delete reviewStepApplicationsNextStep;
            }
            
            List<PanelApplication__c> panelApplication = [select id
                        from PanelApplication__c where ReviewPanel__r.ReviewStep__c in :reviewStepIds and  (Application__c in :applicationPreAppIds or  PreApplication__c in : applicationPreAppIds) ];
            
            List<Review__c> reviewList = [select id from Review__c where PanelApplication__c in:panelApplication];
            
            if(reviewList.size () > 0){
                delete reviewList;
            }
            
            if(panelApplication.size () > 0){
                delete panelApplication;
            }
        }
    }
}