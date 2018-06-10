global class ReviewStepTemplateTriggerHelper extends GNT.TriggerHelper{
    public static boolean skipTrigger = false;
    
    global override void processAfterInsert() 
    {           
           System.debug('--ReviewStepTemplateTriggerHelper---processAfterInsert---');  
           if (skipTrigger==false){
              cloneReviewPanelTemplates();
              addShareSettingAfterInsert();      
           }
    }
   
    global override void processAfterUpdate(){ 
        if (skipTrigger==false){
            addShareSettingAfterUpdate();
         } 
    } 
    
    private void addShareSettingAfterInsert(){
        SystemContextMethodsHelper ctxtHelper = new SystemContextMethodsHelper ();
        List<ReviewStepTemplate__c> reviewStepTemplates =  trigger.new;
        List<ReviewStepTemplate__share> reviewStepShares = new List<ReviewStepTemplate__share>();
        for(ReviewStepTemplate__c reviewStepTemplate : reviewStepTemplates ){
                if(UserInfo.getUserId() != reviewStepTemplate.ownerId){
                    system.debug('--inside1--UserInfo.getUserId()--'+UserInfo.getUserId());
                    system.debug('--inside1--reviewStepTemplate.ownerId--'+reviewStepTemplate.ownerId);
                    ReviewStepTemplate__Share reviewStepShare  = new ReviewStepTemplate__share();
                    reviewStepShare.ParentId = reviewStepTemplate.Id; 
                    reviewStepShare.UserOrGroupId = UserInfo.getUserId();
                    reviewStepShare.AccessLevel = 'edit';
                    reviewStepShares.add(reviewStepShare);
                }
        }
        
        if(reviewStepShares != null && reviewStepShares.size() > 0){
            ctxtHelper.updateReviewStepTemplates(reviewStepShares);
        }
    }
    
    private void cloneReviewPanelTemplates(){
        SystemContextMethodsHelper ctxtHelper = new SystemContextMethodsHelper ();
        //Get all reviewStepTemplates        
        System.debug('--Inside cloneReviewPanelTemplates---');  
        Set<Id> annIdSet = new Set<Id>();
        Map<Id, ReviewStepTemplate__c> rstMap = new Map<Id, ReviewStepTemplate__c>([SELECT Id, Program__c,Announcement__c,ClonedFrom__c
                                                                                    FROM ReviewStepTemplate__c 
                                                                                        WHERE Id IN :Trigger.NewMap.keyset() ]);
        
        System.debug('rstMap---'+rstMap);  
        Map<Id,Id> rstIdClonedFromIdMap = new Map<Id,Id>();
        for(ReviewStepTemplate__c rst:rstMap.values()){
            rstIdClonedFromIdMap.put(rst.ClonedFrom__c,rst.Id);
            annIdSet.add(rst.Announcement__c);
        }
                  
        System.debug('rstIdClonedFromIdMap---'+rstIdClonedFromIdMap);  
                                                                                         
        Map<Id, ReviewPanelTemplate__c> rptMap = new Map<Id, ReviewPanelTemplate__c>(
                    [SELECT Id,Name,RecordTypeId,ReviewStepTemplate__c,Purpose__c,PanelLayout__c,
                     AutoAssignSubmittedApplication__c,Description__c ,ReviewerAssignNotificationTemplate__c, 
                     Chair__c, EndDate__c, ExcludeFromScoring__c, GroupName__c, StartDate__c, UserType__c,                              
                     ReviewPackage__c,Sequence__c,IsDefaultPanel__c, TaskDueDate__c, DueDateOffset__c,GroupId__c
                     FROM ReviewPanelTemplate__c 
                     WHERE ReviewStepTemplate__c IN :rstIdClonedFromIdMap.keySet() ]);                                                                                
                                                                                                
        List<ReviewPanelTemplate__c> rptList = new List<ReviewPanelTemplate__c>();
        
        Id rstAppRecTypeId = Schema.SObjectType.ReviewPanelTemplate__c.getRecordTypeInfosByName().get('Application').getRecordTypeId();
        Id rstPreAppRecTypeId = Schema.SObjectType.ReviewPanelTemplate__c.getRecordTypeInfosByName().get('Pre-Application').getRecordTypeId();

        
        for(ReviewPanelTemplate__c rptObj : rptMap.values()){   
        System.debug('**rptObj**'+rptObj);         
            ReviewPanelTemplate__c newRptObj = rptObj.clone(false,true,false,false);
            newRptObj.Name = rptObj.Name; 
            newRptObj.Sequence__c = rptObj.Sequence__c;
            newRptObj.ReviewPackage__c = rptObj.ReviewPackage__c;  
            newRptObj.ClonedFrom__c = rptObj.id;
            newRptObj.Purpose__c = rptObj.Purpose__c;
            newRptObj.IsDefaultPanel__c=rptObj.IsDefaultPanel__c;
            newRptObj.TaskDueDate__c = rptObj.TaskDueDate__c;
            newRptObj.DueDateOffset__c = rptObj.DueDateOffset__c;
            newRptObj.AutoAssignSubmittedApplication__c = rptObj.AutoAssignSubmittedApplication__c;
            newRptObj.ReviewerAssignNotificationTemplate__c = rptObj.ReviewerAssignNotificationTemplate__c;
            newRptObj.Chair__c = rptObj.Chair__c;
            newRptObj.EndDate__c = rptObj.EndDate__c;
            newRptObj.StartDate__c = rptObj.StartDate__c;
            newRptObj.ExcludeFromScoring__c = rptObj.ExcludeFromScoring__c;
            newRptObj.GroupName__c = rptObj.GroupName__c;
            newRptObj.GroupId__c = rptObj.GroupId__c;
            newRptObj.Description__c = rptObj.Description__c;
            newRptObj.UserType__c = rptObj.UserType__c;
            newRptObj.ReviewStepTemplate__c = rstIdClonedFromIdMap.get(rptObj.ReviewStepTemplate__c);
            rptList.add(newRptObj); // add to the list  
            system.debug('**newRptObj--'+newRptObj);           
        }                   
       ctxtHelper.updateReviewPanelTemplates(rptList);
    }
    
    
    private void addShareSettingAfterUpdate(){
        SystemContextMethodsHelper ctxtHelper = new SystemContextMethodsHelper ();
        List<ReviewStepTemplate__c> reviewStepTemplates =  trigger.new;
        Map<Id,ReviewStepTemplate__c> reviewStepMap = (Map<Id,ReviewStepTemplate__c>)trigger.oldMap;
        List<ReviewStepTemplate__share> reviewStepShares = new List<ReviewStepTemplate__share>();
        for(ReviewStepTemplate__c reviewStepTemplate : reviewStepTemplates ){       
                if(reviewStepMap.get(reviewStepTemplate.id).ownerId != reviewStepTemplate.ownerId){
                    ReviewStepTemplate__Share reviewStepShare  = new ReviewStepTemplate__share();
                    reviewStepShare.ParentId = reviewStepTemplate.Id; 
                    reviewStepShare.UserOrGroupId = reviewStepMap.get(reviewStepTemplate.id).ownerId;
                    reviewStepShare.AccessLevel = 'read';
                    reviewStepShares.add(reviewStepShare);
                }
        }
        
        if(reviewStepShares != null && reviewStepShares.size() > 0){
          ctxtHelper.updateReviewStepTemplates(reviewStepShares);
        }
    }
    
}