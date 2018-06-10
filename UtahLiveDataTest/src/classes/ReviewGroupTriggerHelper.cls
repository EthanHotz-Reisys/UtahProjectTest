public with sharing class ReviewGroupTriggerHelper extends GNT.TriggerHelper {

public static boolean skipTrigger = false;

    public override void processAfterInsert(){  
     if(!skipTrigger) {
        shareAccesstoUsers();
        createReviewSteps();
        }
    }
    
    public override void processAfterUpdate(){
      if(!skipTrigger) {      
        updateAnnoucementReviewStepStatus();
      }
    }
    
    private void updateAnnoucementReviewStepStatus(){
        List<ReviewGroup__c> mapReviewGroups = [SELECT Id, Announcement__c,Status__c ,RecordTypeId,CurrentReviewStep__c,CurrentReviewStepId__c 
                                                                                FROM ReviewGroup__c 
                                                                                    WHERE Id IN :Trigger.newMap.keySet()];
        List<Announcement__c> annListToUpdate =     new List<Announcement__c>();    
        
        for(ReviewGroup__c reviewGrp : mapReviewGroups ){
            if(reviewGrp.Status__c == 'Closed'){
                annListToUpdate.add(new Announcement__c(Id=reviewGrp.Announcement__c, ApplicationsReviewStatus__c = 'Completed' ));
            }
             if(reviewGrp.CurrentReviewStep__c != null){
                annListToUpdate.add(new Announcement__c(Id=reviewGrp.Announcement__c, CurrentReviewStep__c = reviewGrp.CurrentReviewStep__c, CurrentReviewStepId__c= reviewGrp.CurrentReviewStepId__c ));
            }
        }
        
        if(annListToUpdate.size() > 0){
            update annListToUpdate;
        }                                                                   
    }

    // Give Edit access to Review group for Announcement R&R Users
    private void shareAccesstoUsers(){
        List<ID> annIds = new List<Id>();
        List<ID> rgIds = new List<Id>();
        List<ID> rgOwnerId = new List<Id>();
        List<ReviewGroup__Share> shareList = new List<ReviewGroup__Share>();
        List<ReviewGroup__c> mapReviewGroups = [SELECT Id, Announcement__c,Status__c ,RecordTypeId,CurrentReviewStep__c,CurrentReviewStepId__c,OwnerId
                                                                                FROM ReviewGroup__c 
                                                                                    WHERE Id IN :Trigger.newMap.keySet()];

        for(ReviewGroup__c rg : mapReviewGroups){
            annIds.add(rg.Announcement__c);           
            rgIds.add(rg.Id);
            rgOwnerId.add(rg.OwnerId);
        }

        List<RolesAndResponsibilities__c> rrList = [Select Id, Name__c from RolesAndResponsibilities__c where Announcement__c IN :annIds AND Name__c != null and Name__c Not In :rgOwnerId];

        for(Id rgId :rgIds){
            for(RolesAndResponsibilities__c rr: rrList){
                if(rr.Name__c!=userinfo.getuserId()){
                    ReviewGroup__Share rgShare = new ReviewGroup__Share();
                    rgShare.ParentId=rgId;
                    rgShare.UserOrGroupId =rr.Name__c;
                    rgShare.RowCause=Schema.ReviewGroup__Share.RowCause.SharetoAnnouncementReviewerAndApprover__c;
                    rgShare.AccessLevel='Edit';
                    shareList.add(rgShare);
                    system.debug('**rgShare**'+rgShare); 
                }
            
           }
        }
         if(shareList.size() > 0){
                    if(Schema.sObjectType.ReviewGroup__Share.isCreateable()){
                        SystemContextMethodsHelper.updateReviewGroupShares(shareList);
                    }
             }
         }

    /*
        Method:createReviewSteps
        Purpose: To fetch review step templates from associated announcement and create review steps for both application & pre-application
    */
    private void createReviewSteps(){
           
       //Get all the new Review Group records that have just been inserted.
        Map<Id,ReviewGroup__c> mapReviewGroups = new Map<Id,ReviewGroup__c>([SELECT Id, Announcement__c ,RecordTypeId
                                                                                FROM ReviewGroup__c 
                                                                                    WHERE Id IN :Trigger.newMap.keySet()]);
   
        //Get the record type for review groups
        Id reviewGroupRecTypeIdForApp = Schema.SObjectType.ReviewGroup__c.getRecordTypeInfosByName().get('Application').getRecordTypeId();
        Id reviewGroupRecTypeIdForPreapp = Schema.SObjectType.ReviewGroup__c.getRecordTypeInfosByName().get('Pre-Application').getRecordTypeId();
        
        //Create a map of review group and linked announcement(Key-> Review group Id, Value-> Announcement Id)
        //We will create 2 maps,each for application and pre application
        Map<Id,Id> rgAnnForAppMap = new Map<Id,Id>();
        Map<Id,Id> rgAnnForPreAppMap = new Map<Id,Id>();
        Set<Id> annIdSet = new Set<Id>();
        for(ReviewGroup__c rg : mapReviewGroups.values()){           
            if(rg.RecordTypeId == reviewGroupRecTypeIdForApp){
                rgAnnForAppMap.put(rg.Id,rg.Announcement__c);
            }else if(rg.RecordTypeId == reviewGroupRecTypeIdForPreapp ){
                rgAnnForPreAppMap.put(rg.Id,rg.Announcement__c);
            }
            annIdSet.add(rg.Announcement__c);
        }
        
        
        
        //Fetch all review step templates of all announcements that are to be processed
        List<ReviewStepTemplate__c> rstList = [SELECT Id, Name, Announcement__c,RecordTypeId, Description__c,ReviewFormConfig__c,EndDate__c,Program__c,ReviewPackage__c,UserType__c,
                                                StartDate__c,StepNumber__c,OwnerId, ReviewStepLayout__c, ApprovalEmailTemplate__c, ReviewLevelAcceptance__c,ApplicationAssignment__c,
                                                RejectionEmailTemplate__c, PreventDuplicateReviewers__c, ExecutiveApprover__c ,RejectionConfirmationFlexTableName__c, 
                                                ApprovalConfirmationFlexTableName__c,IsStepRequiredInApp__c, PanelHeadAssignNotificationTemplate__c 
                                                    FROM ReviewStepTemplate__c 
                                                        WHERE Announcement__c IN :annIdSet];
        
        
        //Proceed ahead only if review step templates list is not empty.
        if(!rstList.isEmpty()){  
            //Create 2 maps of announcement and related review step templates, again for application & pre-application
            Map<Id,List<ReviewStepTemplate__c>> annRSTForAppMap = new Map<Id,List<ReviewStepTemplate__c>>();
            Map<Id,List<ReviewStepTemplate__c>> annRSTForPreAppMap = new Map<Id,List<ReviewStepTemplate__c>>();
            ReviewGroup__c reviewGrp;
            
            //Get the record type ids for Review Step Template
            Id rstRecTypeIdApp = Schema.SObjectType.ReviewStepTemplate__c.getRecordTypeInfosByName().get('Application').getRecordTypeId();
            Id rstRecTypeIdPreApp = Schema.SObjectType.ReviewStepTemplate__c.getRecordTypeInfosByName().get('Pre-Application').getRecordTypeId();
            
            for(ReviewStepTemplate__c rst:rstList){
                List<ReviewStepTemplate__c> annRstForAppList;
                List<ReviewStepTemplate__c> annRstForPreAppList;
                
                if(rst.RecordTypeId == rstRecTypeIdApp){
                    annRstForAppList = annRSTForAppMap.get(rst.Announcement__c);
                    if(annRstForAppList == null){
                        annRstForAppList = new List<ReviewStepTemplate__c>();                    
                    }                    
                    annRstForAppList.add(rst);
                    annRSTForAppMap.put(rst.Announcement__c,annRstForAppList);  
                }else if(rst.RecordTypeId == rstRecTypeIdPreApp){
                    annRstForPreAppList = annRSTForPreAppMap.get(rst.Announcement__c);
                    if(annRstForPreAppList == null){
                        annRstForPreAppList = new List<ReviewStepTemplate__c>();                    
                    }                    
                    annRstForPreAppList.add(rst);
                    annRSTForPreAppMap.put(rst.Announcement__c,annRstForPreAppList);  
                }               
            }   
            // At this stage we should have 2 maps with announcement and their corresponding review step templates
            
            
            
            //Holder for our new Review Step objects to be inserted
            List<ReviewStep__c> newReviewStepsList = new List<ReviewStep__c>();

            //Get the record type ids for Review Step, they will assigned to relevant records
            Id rsRecTypeIdApp = Schema.SObjectType.ReviewStep__c.getRecordTypeInfosByName().get('Application').getRecordTypeId();
            Id rsRecTypeIdPreApp = Schema.SObjectType.ReviewStep__c.getRecordTypeInfosByName().get('Pre-Application').getRecordTypeId();
            
            //Iterate over incoming review groups and create relevent review steps with the help of review step templates
            for( ReviewGroup__c rg : mapReviewGroups.values() ){
                
                Id annId;
                reviewGrp=rg;

                List<ReviewStepTemplate__c> annRstList = new List<ReviewStepTemplate__c>();
                if(rg.RecordTypeId == reviewGroupRecTypeIdForApp){
                    //Get the announcement Id
                    annId = rgAnnForAppMap.get(rg.Id);
                    //Get the list of review step templates
                    annRstList = annRSTForAppMap.get(annId);
                    
                    if(annRstList == null){
                        continue;
                    }
                }else if(rg.RecordTypeId == reviewGroupRecTypeIdForPreapp){
                    //Get the announcement Id
                    annId = rgAnnForPreAppMap.get(rg.Id);
                    //Get the list of review step templates
                    annRstList = annRSTForPreAppMap.get(annId);
                    
                    if(annRstList == null){
                        continue;
                    }
                }
                for(ReviewStepTemplate__c rst:annRstList){                                
                    //Creating a review step will depend on what record type is Review Group.
                    ReviewStep__c reviewStep = new ReviewStep__c();
                    Boolean createReviewStep = false;
                    if(rg.RecordTypeId == reviewGroupRecTypeIdForApp && rst.RecordTypeId == rstRecTypeIdApp){// if Review Step Template is of record type Application                    
                        reviewStep.RecordTypeId = rsRecTypeIdApp;   
                        createReviewStep = true;                
                    }else if(rg.RecordTypeId == reviewGroupRecTypeIdForPreapp && rst.RecordTypeId == rstRecTypeIdPreApp){//else if Review Step Template is of record type Pre-Application                    
                        reviewStep.RecordTypeId = rsRecTypeIdPreApp;   
                        createReviewStep = true;                     
                    }
                    
                    if(createReviewStep == true && rst.IsStepRequiredInApp__c){
                        reviewStep.Name=rst.Name;
                        reviewStep.ReviewStepTemplate__c=rst.Id;                
                        reviewStep.Description__c=rst.Description__c;
                        reviewStep.EndDate__c=rst.EndDate__c;                
                        reviewStep.ReviewPackage__c=rst.ReviewPackage__c;
                        reviewStep.StartDate__c=rst.StartDate__c;                
                        reviewStep.StepNumber__c=rst.StepNumber__c;
                        reviewStep.ExecutiveApprover__c=rst.ExecutiveApprover__c;                        
                        reviewStep.ReviewStepLayout__c = rst.ReviewStepLayout__c;
                        reviewStep.RejectionEmailTemplate__c = rst.RejectionEmailTemplate__c;
                        reviewStep.ApprovalEmailTemplate__c = rst.ApprovalEmailTemplate__c;
                        reviewStep.RejectionConfirmationFlexTableName__c = rst.RejectionConfirmationFlexTableName__c;
                        reviewStep.ApprovalConfirmationFlexTableName__c = rst.ApprovalConfirmationFlexTableName__c;
                        reviewStep.PreventDuplicateReviewers__c = rst.PreventDuplicateReviewers__c;          
                        reviewStep.ReviewGroup__c = rg.Id;
                        reviewStep.ApplicationAssignment__c = rst.ApplicationAssignment__c==null? 'Auto-Assign to All' : rst.ApplicationAssignment__c ;
                        reviewStep.ReviewFormConfig__c = rst.ReviewFormConfig__c;
                        reviewStep.ReviewLevelAcceptance__c = rst.ReviewLevelAcceptance__c;
                        reviewStep.UserType__c = rst.UserType__c;
                        reviewStep.ReviewDueDate__c= System.today().addDays(7);
                        reviewStep.PanelHeadAssignNotificationTemplate__c = rst.PanelHeadAssignNotificationTemplate__c;
                        
                        newReviewStepsList.add(reviewStep);
                        System.debug('--creating review step in RG Trigger** '+reviewStep);
                    }
                }            
            }
            
            //Insert the new Review Step records
            if(newReviewStepsList.size() > 0){
                insert newReviewStepsList;
            }


            List<ReviewStep__c> reviewSteps = [ Select Id, StepNumber__c from ReviewStep__c where ReviewGroup__c IN :Trigger.newMap.keySet() order by StepNumber__c asc];

            reviewGrp.CurrentReviewStepId__c=reviewSteps[0].Id;
            update reviewGrp;


        }        
    }
}