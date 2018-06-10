/****************************************************************************************************
This class creates a review group for an announcement on 2 occassions:
1. After the pre-application deadline has crossed
2. After the application deadline has crossed
****************************************************************************************************
Audit History
****************************************************************************************************
05-07-2014      Prem Pal      Created
05-12-2014      Hafsa Syed    Updated to check conditions for preapplication 
13-Nov-2014     Prem Pal      Updated the class to include panel related changes
*****************************************************************************************************
*/

global without sharing class ReviewTasksHandler{ 
    global ReviewTasksHandler(){}    
    Id annId;
    List<Id> annIDList;
    Id reviewGroupId;
    
    global ReviewTasksHandler(Id annId){
        this.annId = annId;
    }
    global ReviewTasksHandler(List<Id> annIdList){
        this.annIDList = annIdList;
    }
    
   global void insertReviewTasks(){
        try{
        List<Announcement__c> annList = new List<Announcement__c>();
      if(annId != null){
        System.debug('annIdNotNUll'+annId);
            annList = [SELECT Id,ApplicationDeadlineWithDateTime__c, PreApplicationRequired__c,NumberOfPreApplications__c,ApplicationReviewGroupCreated__c,
                NumberOfApplications__c ,PreApplicationDeadlineWithDateTime__c, PreApplicationReviewGroupCreated__c, ApplicationsReviewStatus__c                                                                    
                FROM Announcement__c 
                WHERE Id = :annId];
        System.debug('annIdNotNUll'+annList);
        }else if(annIDList!=null){
            annList = [SELECT Id,ApplicationDeadlineWithDateTime__c, PreApplicationRequired__c,NumberOfPreApplications__c,ApplicationReviewGroupCreated__c,
                NumberOfApplications__c ,PreApplicationDeadlineWithDateTime__c, PreApplicationReviewGroupCreated__c, ApplicationsReviewStatus__c                                                                    
                FROM Announcement__c 
                WHERE Id IN :annIdList];
        }else{       
            annList = [SELECT Id,ApplicationDeadlineWithDateTime__c, PreApplicationRequired__c,NumberOfPreApplications__c,ApplicationReviewGroupCreated__c,
                NumberOfApplications__c ,PreApplicationDeadlineWithDateTime__c, PreApplicationReviewGroupCreated__c, ApplicationsReviewStatus__c                                                                    
                FROM Announcement__c 
                WHERE (ApplicationDeadlineWithDateTime__c < TODAY OR PreApplicationDeadlineWithDateTime__c < TODAY ) AND  ApplicationsReviewStatus__c != 'Completed' ];
        }    

        system.debug('---annList---'+annList);

        Map<Id,Announcement__c> annMap = new Map<Id,Announcement__c>();
        Set<Id> annIdSet = new Set<Id>();
         
        for(Announcement__c ann : annList){
            if(ann.PreApplicationReviewGroupCreated__c == false){
                annMap.put(ann.Id, ann);
            }else{
                annIdSet.add(ann.Id);
            }
            
            if(ann.ApplicationReviewGroupCreated__c == false){
                annMap.put(ann.Id, ann);
            }else{
                annIdSet.add(ann.Id);
            }
        }


        system.debug('---annMap---'+annMap);
        system.debug('---annIdSet---'+annIdSet);
            
        //Proceed only if the announcements list is not empty
        if(!annMap.isEmpty()){
            //Get all the review groups for the incoming announcements, ideally this list should be empty.               
            List<ReviewGroup__c> rglist = [SELECT id, Announcement__c,RecordTypeId 
                                                FROM ReviewGroup__c 
                                                    WHERE Announcement__c in :annMap.keySet()];
            

            system.debug('---rglist---'+rglist);

            //Get the record type for review groups
            Id reviewGroupRecTypeIdForApp = Schema.SObjectType.ReviewGroup__c.getRecordTypeInfosByName().get('Application').getRecordTypeId();
            Id reviewGroupRecTypeIdForPreapp = Schema.SObjectType.ReviewGroup__c.getRecordTypeInfosByName().get('Pre-Application').getRecordTypeId();
            
            //4. Create a Map of (Key-> Announcement Id,Value-> Review Group Id), ideally which should also be empty.
            //   This is one to two grpTaskMapping, each annoucment has one review group for Application and other for Pre-application(optional)           
            Map<Id,Id> annRgForAppMap = new Map<Id,Id>();
            Map<Id,Id> annRgForPreAppMap = new Map<Id,Id>();
            if(!rglist.isEmpty()){  
                for(ReviewGroup__c rg:rglist){
                    if(rg.RecordTypeId == reviewGroupRecTypeIdForApp){
                        annRgForAppMap.put(rg.Announcement__c,rg.Id);
                    }else if(rg.RecordTypeId == reviewGroupRecTypeIdForPreapp ){
                        annRgForPreAppMap.put(rg.Announcement__c,rg.Id);
                    }
                }   
            }           
             
             
            // Get all the review step templates for announcement
            Map<Id,ReviewStepTemplate__c> rstMap = new Map<Id,ReviewStepTemplate__c>([SELECT Id, RecordTypeId,Announcement__c                                                                       
                                                                            FROM ReviewStepTemplate__c 
                                                                                WHERE Announcement__c IN :annMap.keySet()]);
            
              system.debug('---rstMap---'+rstMap);


            Map<Id,Integer> annRstMapForApp = new Map<Id,Integer>();
            Map<Id,Integer> annRstMapForPreApp = new Map<Id,Integer>();
            
            Id rstRecTypeIdApp = Schema.SObjectType.ReviewStepTemplate__c.getRecordTypeInfosByName().get('Application').getRecordTypeId();
            Id rstRecTypeIdPreapp = Schema.SObjectType.ReviewStepTemplate__c.getRecordTypeInfosByName().get('Pre-Application').getRecordTypeId();
            
            //Create 2 maps (Key->Annoucement id, Value-> Count of review step template) for application & pre-application
            //These maps will be used to populate the "Number of review steps" field in Review Group
            if(!rstMap.isEmpty()){  
                for(ReviewStepTemplate__c rst:rstMap.values()){
                    if(rst.RecordTypeId == rstRecTypeIdApp){
                        Integer rstCount = annRstMapForApp.get(rst.Announcement__c);
                          system.debug('---rstMap-rstCount--'+rstCount);

                        annRstMapForApp.put(rst.Announcement__c,rstCount == null ? 1 : (rstCount + 1));
                    }else if(rst.RecordTypeId == rstRecTypeIdPreapp){
                        Integer rstCount = annRstMapForPreApp.get(rst.Announcement__c);
                        annRstMapForPreApp.put(rst.Announcement__c,rstCount == null ? 1 : (rstCount + 1));
                    }
                }   
            }           
             
            //5. Create a list of review group to be inserted
            List<ReviewGroup__c> reviewGrouplist = new List<ReviewGroup__c>();            
            List<Announcement__c> announcementUpdateList = new List<Announcement__c>();

            Boolean updateAnn;
            for(Announcement__c ann : annMap.values()){
                updateAnn = false;
                //Proceed only if review group has not been already created
                if(annRgForAppMap.get(ann.Id) == null ){        
                    //Create a review group for applications only if applications are created
                        ReviewGroup__c rgapp = new ReviewGroup__c();
                        rgapp.Announcement__c = ann.Id;
                        rgapp.RecordTypeId = reviewGroupRecTypeIdForApp ;
                        rgapp.NumberOfReviewSteps__c = annRstMapForApp.get(ann.Id);
                        rgapp.Status__c='In Progress';
                        rgapp.CurrentReviewStep__c='Pre-screen Review';
                        reviewGrouplist.add(rgapp);                        
                        system.debug('---RG Created--'+rgapp);
                        ann.ApplicationReviewGroupCreated__c = true;
                        ann.ApplicationsReviewStatus__c = 'In Progress';
                        ann.CurrentReviewStep__c='Pre-screen Review';
                        updateAnn = true;
                }
                if(annRgForPreAppMap.get(ann.Id) == null ){     // && ann.PreApplicationDeadlineWithDateTime__c == System.today() - 1
                    //Create a review group for pre-applications only if pre-application is required & pre-applications are created
                    if (ann.PreApplicationRequired__c == true){//&& (ann.NumberOfPreApplications__c > 0)
                        ReviewGroup__c rgPreapp = new ReviewGroup__c();
                        rgPreapp.Announcement__c = ann.Id;                        
                        rgPreapp.RecordTypeId = reviewGroupRecTypeIdForPreApp ;
                        rgPreapp.NumberOfReviewSteps__c = annRstMapForPreApp.get(ann.Id);
                   //     reviewGrouplist.add(rgPreapp);                        
                        ann.PreApplicationReviewGroupCreated__c = true;
                        ann.ApplicationsReviewStatus__c = 'In Progress';
                        updateAnn = true;
                    }
                }
                if(updateAnn){
                    announcementUpdateList.add(ann);
                }
            }             

            List<Application__c> appList = [SELECT Id, Name ,Status__c, Announcement__r.Program__r.ReviewProcess__c, GrantorOrganizationName__c FROM Application__c WHERE Announcement__c IN :annMap.keySet() and Status__c='Submitted to Grantor'];
            List<Application__c> appListNeedUpdate = new List<Application__c>();
            for(Application__c app : appList){
                if(app.Announcement__r.Program__r.ReviewProcess__c != 'One step review' && app.GrantorOrganizationName__c != 'USBE'){
                    app.Status__c='Review Initiated';
                    appListNeedUpdate.add(app);
                }
            }
            update appListNeedUpdate; // Must be updated before
            if(reviewGrouplist.size() > 0){
                 insert reviewGrouplist ;
                  system.debug('---ReviewGroup Inserted --'+reviewGrouplist);
                  reviewGroupId=reviewGrouplist[0].Id;              
                  update announcementUpdateList;
                  system.debug('---announcementUpdateList1--'+announcementUpdateList);
            }           
        }

        system.debug('---annIdSet--'+annIdSet);

        // Path 2 - Add Applications and Preapplications to the RS that are already created
        if(annIdSet.size() > 0){
            addAppPreappToStepsAndPanels(annIdSet);
        }
        }catch(Exception e){
            GNT.AppUtils.notifyTechSupport(e);
            system.debug(e.getStackTraceString());
            throw e;
        }
    }


     global void createReviewGroup(){
        try{
        List<Announcement__c> annList = new List<Announcement__c>();
        
          annList = [SELECT Id,ApplicationDeadlineWithDateTime__c, PreApplicationRequired__c,NumberOfPreApplications__c,ApplicationReviewGroupCreated__c,
                NumberOfApplications__c ,PreApplicationDeadlineWithDateTime__c, PreApplicationReviewGroupCreated__c, ApplicationsReviewStatus__c                                                                    
                FROM Announcement__c 
                WHERE ApplicationsReviewStatus__c = 'Not Started']; 
        

        system.debug('--createReviewGroup-annList---'+annList); 

        Map<Id,Announcement__c> annMap = new Map<Id,Announcement__c>();
        Set<Id> annIdSet = new Set<Id>();
         
        for(Announcement__c ann : annList){
            if(ann.PreApplicationReviewGroupCreated__c == false){
                annMap.put(ann.Id, ann);
            }else{
                annIdSet.add(ann.Id);
            }
            
            if(ann.ApplicationReviewGroupCreated__c == false){
                annMap.put(ann.Id, ann);
            }else{
                annIdSet.add(ann.Id);
            }
        }


        system.debug('---annMap---'+annMap);
        system.debug('---annIdSet---'+annIdSet);
            
        //Proceed only if the announcements list is not empty
        if(!annMap.isEmpty()){
            //Get all the review groups for the incoming announcements, ideally this list should be empty.               
            List<ReviewGroup__c> rglist = [SELECT id, Announcement__c,RecordTypeId 
                                                FROM ReviewGroup__c 
                                                    WHERE Announcement__c in :annMap.keySet()];
            

            system.debug('-inside createReviewGroup--rglist---'+rglist);

            //Get the record type for review groups
            Id reviewGroupRecTypeIdForApp = Schema.SObjectType.ReviewGroup__c.getRecordTypeInfosByName().get('Application').getRecordTypeId();
            Id reviewGroupRecTypeIdForPreapp = Schema.SObjectType.ReviewGroup__c.getRecordTypeInfosByName().get('Pre-Application').getRecordTypeId();
            
            //4. Create a Map of (Key-> Announcement Id,Value-> Review Group Id), ideally which should also be empty.
            //   This is one to two grpTaskMapping, each annoucment has one review group for Application and other for Pre-application(optional)           
            Map<Id,Id> annRgForAppMap = new Map<Id,Id>();
            Map<Id,Id> annRgForPreAppMap = new Map<Id,Id>();
            if(!rglist.isEmpty()){  
                for(ReviewGroup__c rg:rglist){
                    if(rg.RecordTypeId == reviewGroupRecTypeIdForApp){
                        annRgForAppMap.put(rg.Announcement__c,rg.Id);
                    }else if(rg.RecordTypeId == reviewGroupRecTypeIdForPreapp ){
                        annRgForPreAppMap.put(rg.Announcement__c,rg.Id);
                    }
                }   
            }           
             
             
            // Get all the review step templates for announcement
            Map<Id,ReviewStepTemplate__c> rstMap = new Map<Id,ReviewStepTemplate__c>([SELECT Id, RecordTypeId,Announcement__c                                                                       
                                                                            FROM ReviewStepTemplate__c 
                                                                                WHERE Announcement__c IN :annMap.keySet()]);
            
              system.debug('---rstMap---'+rstMap);


            Map<Id,Integer> annRstMapForApp = new Map<Id,Integer>();
            Map<Id,Integer> annRstMapForPreApp = new Map<Id,Integer>();
            
            Id rstRecTypeIdApp = Schema.SObjectType.ReviewStepTemplate__c.getRecordTypeInfosByName().get('Application').getRecordTypeId();
            Id rstRecTypeIdPreapp = Schema.SObjectType.ReviewStepTemplate__c.getRecordTypeInfosByName().get('Pre-Application').getRecordTypeId();
            
            //Create 2 maps (Key->Annoucement id, Value-> Count of review step template) for application & pre-application
            //These maps will be used to populate the "Number of review steps" field in Review Group
            if(!rstMap.isEmpty()){  
                for(ReviewStepTemplate__c rst:rstMap.values()){
                    if(rst.RecordTypeId == rstRecTypeIdApp){
                        Integer rstCount = annRstMapForApp.get(rst.Announcement__c);
                          system.debug('---rstMap-rstCount--'+rstCount);

                        annRstMapForApp.put(rst.Announcement__c,rstCount == null ? 1 : (rstCount + 1));
                    }else if(rst.RecordTypeId == rstRecTypeIdPreapp){
                        Integer rstCount = annRstMapForPreApp.get(rst.Announcement__c);
                        annRstMapForPreApp.put(rst.Announcement__c,rstCount == null ? 1 : (rstCount + 1));
                    }
                }   
            }           
             
            //5. Create a list of review group to be inserted
            List<ReviewGroup__c> reviewGrouplist = new List<ReviewGroup__c>();            
            List<Announcement__c> announcementUpdateList = new List<Announcement__c>();
            Boolean updateAnn;
            for(Announcement__c ann : annMap.values()){
                updateAnn = false;
                //Proceed only if review group has not been already created
                if(annRgForAppMap.get(ann.Id) == null ){        
                    //Create a review group for applications only if applications are created
                        ReviewGroup__c rgapp = new ReviewGroup__c();
                        rgapp.Announcement__c = ann.Id;
                        rgapp.RecordTypeId = reviewGroupRecTypeIdForApp ;
                        rgapp.NumberOfReviewSteps__c = annRstMapForApp.get(ann.Id);
                        rgapp.Status__c='Ready for Review';
                        reviewGrouplist.add(rgapp);
                        ann.ApplicationReviewGroupCreated__c = true;
                        ann.ApplicationsReviewStatus__c = 'Ready for Review';
                        updateAnn = true;
                }
                if(annRgForPreAppMap.get(ann.Id) == null ){     // && ann.PreApplicationDeadlineWithDateTime__c == System.today() - 1
                    //Create a review group for pre-applications only if pre-application is required & pre-applications are created
                    if (ann.PreApplicationRequired__c == true){//&& (ann.NumberOfPreApplications__c > 0)
                        ReviewGroup__c rgPreapp = new ReviewGroup__c();
                        rgPreapp.Announcement__c = ann.Id;                        
                        rgPreapp.RecordTypeId = reviewGroupRecTypeIdForPreApp ;
                        rgPreapp.NumberOfReviewSteps__c = annRstMapForPreApp.get(ann.Id);
                        reviewGrouplist.add(rgPreapp);                        
                        ann.PreApplicationReviewGroupCreated__c = true;
                        ann.ApplicationsReviewStatus__c = 'Ready for Review';
                        updateAnn = true;
                    }
                }
                if(updateAnn){
                    announcementUpdateList.add(ann);
                }
            } 
            if(reviewGrouplist.size() > 0){
                 insert reviewGrouplist ;             
                update announcementUpdateList;
            }           
        }

     }catch(Exception e){
            GNT.AppUtils.notifyTechSupport(e);
            system.debug(e.getStackTraceString());
        }
    }
    
    
    private void addAppPreappToStepsAndPanels(Set<Id> annIdSet){
        // get the review step records from already created Review groups
        Id firstRevStepId;
        List<ReviewStep__c> rsList = [Select Id, ReviewGroup__r.Announcement__c, StepNumber__c, RecordTypeId, Status__c From ReviewStep__c 
            Where ReviewGroup__r.Announcement__c IN :annIdSet];
        List<ReviewPanel__c> reviewPanelList = [SELECT Id, RecordTypeId, ReviewStep__r.StepNumber__c,ReviewStep__r.AnnouncementId__c,
                                               AutoAssignSubmittedApplication__c FROM ReviewPanel__c 
                                               WHERE ReviewStep__c IN : rsList AND ReviewStep__r.StepNumber__c = 1 ];
        Map<Id, Id> rsIdToRpIdMap = new Map<Id, Id>();  
        for(ReviewPanel__c rp : reviewPanelList){
            rsIdToRpIdMap.put(rp.ReviewStep__c, rp.Id);
        }
        
        Id stepPreAppRecTypeId = Schema.SObjectType.ReviewStep__c.getRecordTypeInfosByName().get('Pre-Application').getRecordTypeId();  
        Id stepAppRecTypeId = Schema.SObjectType.ReviewStep__c.getRecordTypeInfosByName().get('Application').getRecordTypeId();  
        
        Map<Id, Id> annIdToRSIdForApplication = new Map<Id, Id>();
        Map<Id, Id> annIdToRSIdForPreApplication = new Map<Id, Id>();
        
        // Create map (AnnId --> review step Id), seperate maps for Application and PreApplication
        // Key is Ann Id and Value is step id of the first step
        for(ReviewStep__c rs : rsList){
            if(rs.StepNumber__c == 1 && rs.RecordTypeId == stepAppRecTypeId){
                annIdToRSIdForApplication.put(rs.ReviewGroup__r.Announcement__c, rs.Id);
                firstRevStepId=rs.Id;
                rs.Status__c = 'In Progress';
            }
            if(rs.StepNumber__c == 1 && rs.RecordTypeId == stepPreAppRecTypeId){
                annIdToRSIdForPreApplication.put(rs.ReviewGroup__r.Announcement__c, rs.Id);
                firstRevStepId=rs.Id;
                rs.Status__c = 'In Progress';
            }
        }        

        //if(GNT__UserPreferences__c.getValues(userInfo.getUserId()).GNT__IsInternal__c == true){
        //    ReviewGroup__c revGroup = [Select Id,Name, CurrentReviewStep__c, CurrentReviewStepId__c from ReviewGroup__c where id =:reviewGroupId limit 1 ];
        //    revGroup.CurrentReviewStepId__c=firstRevStepId;
        //    update revGroup;
        //}else{
        //    update rsList;
        //}
        // Get all the Review step Applications already created against the RS ids of first step
        List<ReviewStepApplication__c> rsaList = [Select Id, RecordTypeId, Application__c, PreApplication__c, ReviewStep__c From ReviewStepApplication__c Where ReviewStep__c IN : annIdToRSIdForPreApplication.values() OR ReviewStep__c IN : annIdToRSIdForApplication.values()];
        
        // get all the panel applications already added to panels
        List<PanelApplication__c> panelAppList = [Select Id, RecordTypeId, Application__c, PreApplication__c From PanelApplication__c 
            Where ReviewPanel__r.ReviewStep__c IN : annIdToRSIdForPreApplication.values() OR ReviewPanel__r.ReviewStep__c IN : annIdToRSIdForApplication.values()];
            
        Id preAppRecTypeId = Schema.SObjectType.ReviewStepApplication__c.getRecordTypeInfosByName().get('Pre-Application').getRecordTypeId();  
        Id appRecTypeId = Schema.SObjectType.ReviewStepApplication__c.getRecordTypeInfosByName().get('Application').getRecordTypeId();  
        
        Map<Id, Id> appIdToStepAppIdMap = new Map<Id, Id>();
        Map<Id, Id> appIdToStepIdMap = new Map<Id, Id>();
        List<ReviewStepApplication__c> stepApplications = new List<ReviewStepApplication__c>();
        
        // Create 2 maps
        // 1. App/PreApp Id --> review step application Id
        // 2. App/PreApp Id --> review step Id
        for(ReviewStepApplication__c rsa : rsaList){
            if(rsa.RecordTypeId == appRecTypeId){
                appIdToStepAppIdMap.put(rsa.Application__c, rsa.Id);
                appIdToStepIdMap.put(rsa.Application__c, rsa.ReviewStep__c);
            }else{
                appIdToStepAppIdMap.put(rsa.PreApplication__c, rsa.Id);
                appIdToStepIdMap.put(rsa.PreApplication__c, rsa.ReviewStep__c);
            }
        }
        
        // get all the PreApplications
        List<PreApplication__c> preAppList = [SELECT ID,Announcement__c FROM PreApplication__c 
                        WHERE Id NOT IN : appIdToStepAppIdMap.keySet() and SubmittedOn__c != null AND Announcement__c IN :annIdSet];
        // get all the Applications
        List<Application__c> appList = [SELECT ID,Announcement__c FROM Application__c 
                WHERE Id NOT IN : appIdToStepAppIdMap.keySet() and SubmittedOn__c != null and Status__c='Submitted to Grantor' AND Announcement__c IN :annIdSet];

        System.debug('appList----------------------->' + appList);
        
        List<PanelApplication__c> panelApplications = new List<PanelApplication__c>();
        Id panelAppRecTypeId = Schema.SObjectType.PanelApplication__c.getRecordTypeInfosByName().get('Application').getRecordTypeId();
        Id panelPreAppRecTypeId = Schema.SObjectType.PanelApplication__c.getRecordTypeInfosByName().get('Pre-Application').getRecordTypeId();
        
        // check if the RSA already exists, If NOT then create new one
        for(PreApplication__c preapp : preAppList){
            if(appIdToStepAppIdMap.get(preapp.Id) == null){
                Id revStepId = annIdToRSIdForPreApplication.get(preapp.Announcement__c);
                if(revStepId != null){
                    Id reviewPanelId = rsIdToRpIdMap.get(revStepId);
                    if(reviewPanelId != null){
                        panelApplications.add(new PanelApplication__c(ReviewPanel__c = reviewPanelId, PreApplication__c = preapp.Id, RecordTypeId = panelPreAppRecTypeId));
                    }
                    stepApplications.add(new ReviewStepApplication__c(ReviewStep__c = revStepId, PreApplication__c = preapp.Id, RecordTypeId = preAppRecTypeId));
                }
            }
        }
        
        for(Application__c app : appList){
            if(appIdToStepAppIdMap.get(app.Id) == null){
                Id revStepId = annIdToRSIdForApplication.get(app.Announcement__c);
                if(revStepId != null){
                    Id reviewPanelId = rsIdToRpIdMap.get(revStepId);
                    if(reviewPanelId != null){
                        panelApplications.add(new PanelApplication__c(ReviewPanel__c = reviewPanelId, Application__c = app.Id, RecordTypeId = panelAppRecTypeId));
                    }
                    stepApplications.add(new ReviewStepApplication__c(ReviewStep__c = revStepId, Application__c = app.Id, RecordTypeId = appRecTypeId));
                }
            }
        }
          
        if(stepApplications.size() > 0){
            System.debug(stepApplications);
            insert stepApplications;
            system.debug('--Step Applications are added!!!!!!!!!!!!!!!!!!');
        }
        /*
        if(panelApplications.size() > 0){
            insert panelApplications;
            system.debug('--Panel Applications are added!!!!!!!!!!!!!!!!!!');
        }
        */
        // TODO: if the RP is AutoAssignment the add the App or Preapp to PanelApp 
    }
    
    global void processSingleAppOrPreapp(Id recordId){
        try{
            Schema.SobjectType sobjType = recordId.getSobjectType();
            Set<Id> annIds = new Set<Id>();
            
            if(Schema.PreApplication__c.SobjectType == sobjType){
                PreApplication__c preapp = [Select Announcement__c from PreApplication__c Where id = :recordId];
                annIds.add(preapp.Announcement__c);
            }else if(Schema.Application__c.SobjectType == sobjType){
                Application__c app = [Select Announcement__c from Application__c Where id = :recordId];
                annIds.add(app.Announcement__c);
            }
            System.debug('annIds.size()--------------------->' + annIds);
            if(annIds.size() > 0){
                addAppPreappToStepsAndPanels(annIds); 
            }
        }catch(Exception e){
            GNT.AppUtils.notifyTechSupport(e);
        }
    }
}