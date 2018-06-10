/*
    This is a helper class for the PreApplication Trigger 
    **********************************************************
    Audit History 
    **********************************************************
    2014-04-23  Manasi Gangal      Created 
    2014-04-29  Hafsa Syed          Added incrementTotalPreApplications and decrementTotalPreapplications method 
    2014-05-13  Ryan Chadwick       Added submitted by method
    2014-05-15  Vani Valluru        Added UpdatePreAppTemplName method and Added SetPreAppTemplName 
    **********************************************************  
*/ 

public with sharing class PreApplicationTriggerHelper extends GNT.TriggerHelper{
    public static Boolean skipTrigger= false;
    
   public String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
 
    public override void processBeforeInsert() {
        if(skipTrigger == false){
          GNT.NameTemplateTriggerHelper.beforeInsert();
        
        if(appName =='StateasGrantor'){ 
            updateAssignedTo(); 
            populateExternalOrg(Trigger.New);           
            UpdatePreAppTemplName(Trigger.New);
            checkAnnouncementDeadline(Trigger.New);
        } 
        if(appName =='StateasGrantee'){
            changeRecordType(Trigger.new);
        }
          if(appName =='Recipient'){
          checkRequestdAmount(Trigger.New);
          shareWithInternalUsers(Trigger.New);        
        } 
        
        }
    }
    public override void processAfterInsert() {
        //TODO: temporarily commenting out the logic as we should build UI for owner to perform manual share
        //shareToExternalUser();
       if(skipTrigger == false){      
        if(appName =='StateasGrantee'){
            updateAnnouncement(Trigger.new);
            PopulateRolesAndResponsiblities(Trigger.new);
        } 
        /* Hiding Pre-Application button after creation */
        if(appName =='Recipient'){
          updateQualifiedOpportunity(Trigger.New);          
        } 
          createBudPeriodProjAreaBudCat(Trigger.New);
       }
    }
    public override void processBeforeUpdate() {
    if(skipTrigger == false){
        if(appName =='StateasGrantor'){
            updateSubmittedtoInternalCheckbox(Trigger.New,(Map<Id,PreApplication__c>)Trigger.oldMap);
            updateSubmittedBy();            
            UpdatePreAppTemplName(Trigger.New);
            checkAnnouncementDeadline(Trigger.New);
            autoCreateApplication();
         } 
          if(appName =='Recipient'){
          checkRequestdAmount(Trigger.New);
          shareWithInternalUsers(Trigger.New);        
        } 
        deleteTasksForReviewers((List<PreApplication__c>) Trigger.new);
    }   
    }
    
    public override void processAfterUpdate() {
    if(skipTrigger == false){
         incrementTotalPreApplications(Trigger.New, (Map<Id,PreApplication__c>)Trigger.oldMap);
         if(appName =='StateasGrantor'){
             addSharingSettings((Map<Id,PreApplication__c>)Trigger.newMap);
             sendSubmissionEmail();
         }
    }
    }
    
    public override void processBeforeDelete(){
    if(skipTrigger == false){
        decrementTotalPreApplications(Trigger.Old);
    }
    }
    
    
    private void changeRecordType(List<Preapplication__c> lstPreApplication){

        RecordType recordType = [Select Id,DeveloperName,Name from RecordType where Name =:'Grantee' and sObjectType =: AppUtils.getNamespacePrefix()+'Preapplication__c'];
        for(Preapplication__c preApp: lstPreApplication){
            preApp.RecordTypeId = recordType.Id; 
            preApp.Status__c = 'Created'; 
        } 
    }
    
    /* Hiding Pre-Application button after creation */


      private void updateQualifiedOpportunity(List<Preapplication__c > applications){
        List<Id> listIds = new List<Id>();
        for (Preapplication__c childObj :applications){
              listIds.add(childObj.Announcement__c);
            }
                List<OpportunityQualification__c> qualifiedAnnlist =[Select Id, FundingOpportunity__c,PreApplicationCreated__c  from OpportunityQualification__c WHERE FundingOpportunity__c IN :listIds];
                for (OpportunityQualification__c qualAnn : qualifiedAnnlist){
                
                 for(Preapplication__c app : applications){
                 if(qualAnn.PreApplicationCreated__c==false){
                    qualAnn.PreApplicationCreated__c =true;
                
                }
    
          }
      
      }
      update qualifiedAnnlist;
  }
  
     /*
        This method will check Requested amount in between Award ceiling and award floor
    */
     private void checkRequestdAmount(List<PreApplication__c> preAppList) {       
       
            for(PreApplication__c newapp : preAppList){
            
              if (newapp.AwardFloor__c !=null && newapp.AwardCeiling__c != null) {
                if(newapp.RequestedAmount__c > newapp.AwardCeiling__c ||newapp.RequestedAmount__c < newapp.AwardFloor__c){
                     //newapp.addError('Requested Amount should be in between the Award Floor and Award Ceiling');
                     newapp.addError(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-30985'));
                     //errors.add('Requested Amount should be in between the Award Floor and Award Ceiling');
                }
              }else if(newapp.AwardFloor__c !=null && newapp.AwardCeiling__c == null ){
                if(newapp.RequestedAmount__c < newapp.AwardFloor__c){
                    // newapp.addError('Requested Amount should be greater than Award Floor');
                    newapp.addError(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-48653'));
                }
                }else if(newapp.AwardFloor__c ==null && newapp.AwardCeiling__c != null){
                    if(newapp.RequestedAmount__c > newapp.AwardCeiling__c){
                    // newapp.addError('Requested Amount should be less than Award Ceiling');
                    newapp.addError(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-27331'));
                }
                }
               
              }
            }
    ///////////


     /*
    *   Send confirmation mail to applicant that Pre-Application has been submitted for Review
    */
    
    private void sendSubmissionEmail(){
        Map<Id,Id> targetObjectWhatIdMap = new Map<Id,Id>();
        Map<Id,Id> WhatIdtemplateMap = new Map<Id,Id>();
        List<Id> ownerIds = new List<Id>();
        boolean sendEmail = false;
        Map<Id,PreApplication__c> oldApplicationMap = (Map<Id,PreApplication__c>)trigger.oldMap;
        for(PreApplication__c newapp :(List<PreApplication__c>)Trigger.new){
            ownerIds.add(newapp.ownerId);
        }
        Map<Id,User> userMap = new Map<Id,User>([select contactId from user where id in :ownerIds]);
        Map<Id,Id> userContactMap = new Map<Id,Id>();
        for(Id userId : userMap.keySet()){
            userContactMap.put(userId,userMap.get(userId).contactId);
        }
        for(PreApplication__c newapp :(List<PreApplication__c>)Trigger.new){
            if(newapp.EnablePreApplicationSubmissionEmail__c == true  && !String.isEmpty(newApp.PreApplicationSubmissionTemplate__c) && 
                newapp.Status__c == 'Submitted' && oldApplicationMap.get(newapp.id).Status__c != 'Submitted'){
                targetObjectWhatIdMap.put(newapp.id,userContactMap.get(newapp.ownerId));
                WhatIdtemplateMap.put(newapp.id,newapp.PreApplicationSubmissionTemplate__c);
                sendEmail = true;
            }
        }
        if(sendEmail){
            GNT.AppUtils.sendEmailUsingTemplate(WhatIdtemplateMap,targetObjectWhatIdMap,true);
        }
    }
    /*share with external users of same organization*/
    /* Commenting this method as it is not used in this class. The call to this method is commented too on line 33*/
    
    /* private void shareToExternalUser(){
        Id roleId = UserInfo.getUserRoleId();
        List<Group> publicGroup  = [select id from Group where type='Role' and relatedId =:roleId];     
        if(publicGroup != null && publicGroup.size() > 0){
        List<PreApplication__Share> preApplicationShares  = new List<PreApplication__Share>();
        List<PreApplication__c> preAppList = trigger.new;
            for(PreApplication__c preApp : preAppList){
                PreApplication__Share preApplicationShare= new PreApplication__Share();
                preApplicationShare.parentId = preApp.id;
                preApplicationShare.UserOrGroupId = publicGroup[0].id;
                preApplicationShare.AccessLevel = 'edit';
                preApplicationShares.add(PreApplicationShare);
            }
            if(preApplicationShares.size ()>0){
                insert preApplicationShares;
            }
        }
    } */
    
    /* This method creates application from Pre-Application,if Pre-Application is approved*/
    private void autoCreateApplication(){
        Map<Id,PreApplication__c> preApplMap = (Map<Id,PreApplication__c>)trigger.oldMap;
        List<PreApplication__c> preAppList = new List<PreApplication__c>();
        List<PreApplication__c> preApplications = trigger.new;
        for(PreApplication__c preApplication:preApplications){
            if(preApplication.status__c == 'Approved' && preApplMap.get(preApplication.id).status__c != 'Approved'){
                preAppList.add(preApplication);
            }
        }
        createApplication(preAppList);
    }
    private void createApplication(List<PreApplication__c>preAppList){
        List<Id> IdList = new List<Id>();
        for(PreApplication__c preApp :preAppList){
            IdList.add(preApp.id);
        }
        List<Sobject> applications = GNT.AppUtils.copyRecords(AppUtils.getNamespacePrefix()+'PreApplication__c', AppUtils.getNamespacePrefix()+'Application__c', IdList, true);
        Integer i = 0;
        for(Sobject application :applications){
            if(i <= preAppList.size()){
                preAppList[i].ApplicationID__c = application.id;
            }
            i++;    
        }
    }
    /* This method populates the ExternalOrganization field on application based on the Owner's Organization.*/
    private void populateExternalOrg(List<PreApplication__c> preapplicationList){
        Set<Id> ownerIdSet = new Set<Id>();
        for(PreApplication__c preapp :preapplicationList){
            ownerIdSet.add(preapp.OwnerId);   
        }
        Map<Id, User> userMap = new Map<Id, User>([SELECT Id, GNT__OrganizationId__c FROM User WHERE Id IN :ownerIdSet]);                                                                                     
        for(PreApplication__c preappln :preapplicationList){
            User owner = userMap.get(preappln.OwnerId);
            if (owner != null){
                preappln.ExternalOrganization__c = owner.GNT__OrganizationId__c;
            }         
        }              
    }
    
    /*
    * Populates the AssignedTo__c field on Application with Announcement.OwnerId
    */
    private void updateAssignedTo(){
        List<Id> AnnId = new List<Id>();
        for(PreApplication__c preapp :  (List<PreApplication__c>) Trigger.New){
            AnnId.add(preapp.Announcement__c);
        }
        
        Map<Id,Id> mapAnnOwner = new Map<Id,Id>();
        for(Announcement__c ann : [Select Id,OwnerId FROM Announcement__c WHERE ID IN : AnnId]){
            mapAnnOwner.put(ann.Id,ann.OwnerId);
        }
        
        for(PreApplication__c newpreapp : (List<PreApplication__c>)Trigger.new){
            newpreapp.AssignedTo__c = mapAnnOwner.get(newpreapp.Announcement__c);
        }
    }
    
    /*
     * Populates the SubmittedBy__c field if submitted from external to internal
     */
    private void updateSubmittedBy(){
        for(PreApplication__c newapp : (List<PreApplication__c>)Trigger.new){
            if(Trigger.oldMap.containsKey(newapp.Id)){
                PreApplication__c oldapp = (PreApplication__c)Trigger.oldMap.get(newapp.Id);
                if(newapp.Status__c == 'Submitted' && oldapp.Status__c != 'Submitted'){
                    newapp.SubmittedBy__c = UserInfo.getUserId();
                    newapp.SubmittedOn__c = System.now();
                    newapp.SubmittedToInternal__c = true;
                }
            }
        }
    }

     /* This method updates to Submitted to internal checkbox when status changes from Completed to Submitted */
    private void updateSubmittedtoInternalCheckbox(List<PreApplication__c > preapplicationList,Map<Id,PreApplication__c> oldMap){
        for(PreApplication__c preapplication :preapplicationList){
            if(oldMap.get(preapplication.id).status__c != 'Submitted' && preapplication.Status__c == 'Submitted'){
                 preapplication.Submitted_to_Internal__c = true;   
             }
        }
     }
     
     private void incrementTotalPreapplications(List<Preapplication__c> PreapplicationList, Map<Id,Preapplication__c> oldMap){
        Set<Id> announceIds = new Set<Id>();
        for(Preapplication__c app :PreapplicationList){
            announceIds.add(app.Announcement__c);
        }

        Map<Id, Announcement__c> announceMap = new Map<Id, Announcement__c>([SELECT Id, 
                                                                            NumberOfPreApplications__c 
                                                                            FROM Announcement__c 
                                                                            WHERE Id IN :announceIds]);
        List<Announcement__c> announceList = new List<Announcement__c>();
                                                                            
        for(PreApplication__c appln :PreapplicationList){
            if (oldMap.get(appln.id).Submitted_to_Internal__c == false && appln.Submitted_to_Internal__c == true){    
                Announcement__c announce = announceMap.get(appln.Announcement__c);
                if (announce.NumberOfPreApplications__c == null){
                    announce.NumberOfPreApplications__c = 0;
                }
                announce.NumberOfPreApplications__c = announce.NumberOfPreApplications__c + 1;                
                announceList.add(announce);  
            } 
            
        }                  
        SystemContextMethodsHelper SystemContextMethodsHelper = new SystemContextMethodsHelper();
        SystemContextMethodsHelper.updateAnnouncements(announceList); 
    }  
    
     private void decrementTotalPreApplications(List<PreApplication__c> applicationList){
        Set<Id> announceIds = new Set<Id>();
        for(PreApplication__c app :applicationList){
            announceIds.add(app.Announcement__c);
        }

        Map<Id, Announcement__c> announceMap = new Map<Id, Announcement__c>([SELECT Id, 
                                                                            NumberOfPreApplications__c 
                                                                            FROM Announcement__c 
                                                                            WHERE Id IN :announceIds]);
        for(PreApplication__c appln :applicationList){
            if (appln.Submitted_to_Internal__c == true){    
                Announcement__c announce = announceMap.get(appln.Announcement__c);
                if (announce.NumberOfPreApplications__c != null){
                    announce.NumberOfPreApplications__c = announce.NumberOfPreApplications__c - 1;
                }                       
            } 
        }          

        List<Announcement__c> annToUpdate = new List<Announcement__c>();
        for(Announcement__c ann :announceMap.values()){
            annToUpdate.add(ann);
        }
        SystemContextMethodsHelper SystemContextMethodsHelper = new SystemContextMethodsHelper();
        SystemContextMethodsHelper.updateAnnouncements(annToUpdate);
    }
    /* Add Share object to manually share the  Pre Application created by  Community users with Internal SF users 
             based on Account 
    */
    private void addSharingSettings(Map<Id,PreApplication__c> preApplicationMap){
        List<Id> announcementList = new List<Id>();
        List<PreApplication__Share> preApplicationShares  = new List<PreApplication__Share>();
        List<String> accountNames = new List<String>();
        Map<String,Group> groupMap = new Map<String,Group>();
        Program__c program;
        String accountName;
        
        System.debug('Inside addSharingSettings**');
        
        for(PreApplication__c preApplication : preApplicationMap.values()){
            announcementList.add(preApplication.Announcement__c);
        }
        Map<Id,Announcement__c> announcementMap =new Map<Id,Announcement__c>(
            [select id,Program__r.account__r.name 
                from Announcement__c 
                    where id in :announcementList]);
        
        for(Announcement__c announcement: announcementMap.values()){
            if(!String.isEmpty(announcement.Program__r.account__r.name)){
                accountNames.add(announcement.Program__r.account__r.name.replace(' ',''));
            }
        }
        // Query roles associated with Announcement's Program's account
        List<Group> groups= [select id,Name,type,developerName 
                             from Group where type= 'Role' and  
                             developerName in :accountNames];
        
        for(Group grp : groups){
            groupMap.put(grp.developerName,grp); 
        }
        
        // Share the Pre-Application  with the correcsponding account roles.
        for(PreApplication__c PreApplication : PreApplicationMap.values()){
            if(PreApplication.Status__c == 'Submitted to Grantor'){  
                PreApplication__Share preApplicationShare= new PreApplication__Share();
                preApplicationShare.ParentId = PreApplication.Id;
                Announcement__c announcement = announcementMap.get(PreApplication.Announcement__c);
                if(announcement != null){
                    accountName = announcement.Program__r.account__r.name;
                    if(!String.isEmpty(accountName)){
                        Group grp = groupMap.get(accountName.replace(' ',''));
                        if(grp != null){ 
                            preApplicationShare.UserOrGroupId = grp.id;
                            preApplicationShare.AccessLevel = 'edit';
                            preApplicationShare.RowCause = Schema.PreApplication__Share.RowCause.PreApplication_After_Submission_Sharing__c;
                            preApplicationShares.add(preApplicationShare);   
                        }
                    }
                }
            }
        }
        // Insert all of the newly created Share records and capture save result 
        if(preApplicationShares.size() > 0){
            insert preApplicationShares;
        }
    }
    /*/*This method gets the data from the Announcement field on Preapplication  */
       public static void UpdatePreAppTemplName(List<Preapplication__c> lApplication){
        Set<String> sAnnouncIds = new Set<String>();
        List<Preapplication__c> lApp = new List<Preapplication__c>();
        // Iterate the list of Application records and collect a Set of Announcment object ids
        for(Preapplication__c ObjApp : lApplication){
            if(ObjApp.Announcement__c != null && ObjApp.PageTemplateName__c == null){
                sAnnouncIds.add(ObjApp.Announcement__c);
                lApp.add(ObjApp);
            }
        }
        // If the size of Set is greater than 0 then process records
        if(sAnnouncIds.size() > 0)
            SetPreAppTemplName(lApp, sAnnouncIds);
    }
       /* This method sets the data on pagetemplate field on the PreApplication based on Announcement and pageTemplateConfig.*/
       public static void SetPreAppTemplName(List<Preapplication__c> lApplication, Set<String> sAnnouncIds)
    {
        /*// Query the Announcement object where the IDs are from the Application.AnnouncementIDs
        Map<Id,Announcement__c> mAnnouncement = new Map<Id,Announcement__c>([Select g.ApplicationPackage__r.GNT__PageTemplateConfig__r.Name, 
                                                                                    g.ApplicationPackage__r.GNT__PageTemplateConfig__c, 
                                                                                    g.ApplicationPackage__c From Announcement__c g 
                                                                                    where Id in : sAnnouncIds and 
                                                                                    g.ApplicationPackage__r.GNT__PageTemplateConfig__c != null]);
        // Iterate all the Applciation records and set the PageTemplateConfig.Name
        for(Preapplication__c ObjApp : lApplication){
              if(ObjApp.Announcement__c != Null){
                Announcement__c ObjAnn = mAnnouncement.get(ObjApp.Announcement__c);
                if(ObjAnn != null && ObjAnn.ApplicationPackage__c != null && ObjAnn.ApplicationPackage__r.GNT__PageTemplateConfig__c != null)
                    ObjApp.PageTemplateName__c = ObjAnn.ApplicationPackage__r.GNT__PageTemplateConfig__r.Name;
            }
        }*/
    }
    /*
        This method will check Announcement deadline date and PreApplication Deadline Date and time.
    */
     private void checkAnnouncementDeadline(List<PreApplication__c> preAppList) {       
        GNT__UserPreferences__c userPrefs = GNT__UserPreferences__c.getValues(UserInfo.getUserId());
        if (userPrefs.GNT__ProfileName__c == 'Applicant') {
            Set<Id> annIds = new Set<Id>();
            for(PreApplication__c newapp : preAppList){
              annIds.add(newapp.Announcement__c);
            }

            Map<Id, Announcement__c> annMap = new Map<Id, Announcement__c>([Select Id, PreApplicationDeadlineWithDateTime__c, 
              PreApplicationPostDeadlineMessage__c from Announcement__c where Id in :annIds]);

            for(PreApplication__c newapp : preAppList){
              Announcement__c ann = annMap.get(newapp.Announcement__c);
              if (ann.PreApplicationDeadlineWithDateTime__c < System.now()) {
                newapp.addError(ann.PreApplicationPostDeadlineMessage__c);
              }
            }
        }
    }

    private void PopulateRolesAndResponsiblities(List<PreApplication__c> PreAppList){
     
        Map<Id,Id> annIds = new Map<Id,Id>();
        Map<Id,Id> projectDirector = new Map<Id,Id>();
        String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
        String developerName;
    
        if(appName == 'StateasGrantee'){
            developerName = 'PreApplication';
         }
          else{
            developerName = 'GrantorPreApplication';
         }
    

        for(PreApplication__c newapp : PreAppList){
           annIds.put(newapp.Announcement__c,newapp.Id); 
           projectDirector.put(newapp.Id,newapp.ProjectDirector__c);  
        }  
        List<RolesAndResponsibilities__c> roleAndResponsiblility = [Select Name__c,BusinessRole__c,Responsibility__c,Announcement__c from RolesAndResponsibilities__c where BusinessRole__c!= 'Owner' and Announcement__c in :annIds.keyset() ];          
        RecordType appRecordType = [SELECT CreatedById,Description,DeveloperName,Id,Name,SobjectType FROM RecordType where sObjectType =: AppUtils.getNamespacePrefix()+'RolesAndResponsibilities__c' and DeveloperName =:developerName ];
        Map<Id,List<RolesAndResponsibilities__c>> annRoleMap = new Map<Id,List<RolesAndResponsibilities__c>>();       
       
        for(RolesAndResponsibilities__c role :roleAndResponsiblility){              
            List<RolesAndResponsibilities__c> lstRolesResp = annRoleMap.get(role.Announcement__c);
            if(lstRolesResp == null){
                lstRolesResp = new List<RolesAndResponsibilities__c>(); 
                annRoleMap.put(role.Announcement__c,lstRolesResp);
            }  
            lstRolesResp.add(role);
        }  

        List<RolesAndResponsibilities__c> lstRolesAndResponsibilities = new List<RolesAndResponsibilities__c>();
        for(PreApplication__c newapp : PreAppList){
            Id preApplicationId = annIds.get(newapp.Announcement__c);       
            Id projectDirec = projectDirector.get(preApplicationId);   
            List<RolesAndResponsibilities__c> roleAndResp = annRoleMap.get(newapp.Announcement__c);
            if(roleAndResp != null){
                for(RolesAndResponsibilities__c role : roleAndResp ){
                    RolesAndResponsibilities__c rolesAndResp = new RolesAndResponsibilities__c();
                    rolesAndResp.Name__c= role.Name__c;
                    rolesAndResp.Responsibility__c = role.Responsibility__c;
                    //rolesAndResp.Role__c = role.Role__c;
                    rolesAndResp.BusinessRole__c= role.BusinessRole__c;
                    rolesAndResp.PreApplication__c = preApplicationId; 
                    rolesAndResp.RecordTypeId = appRecordType.Id; 
                    lstRolesAndResponsibilities.add(rolesAndResp);
                }   
             //   lstRolesAndResponsibilities = populateOwner(lstRolesAndResponsibilities, preApplicationId , UserInfo.getUserId(), 'Owner of Record', 'Owner', 'Program');
              //  lstRolesAndResponsibilities = populateOwner(lstRolesAndResponsibilities, preApplicationId , projectDirec, 'Project Director', 'Reviewer', 'Program');

            }    
        } 
        insert lstRolesAndResponsibilities;
    }


    /* Commenting this method as it is not used in this class. The call to this method has been commented on line 413 */
    
    /* private List<RolesAndResponsibilities__c> populateOwner(List<RolesAndResponsibilities__c>  lstRolesAndResponsibilities,Id preapplicationId , Id userId,String respon, String bizRole, String role){
       
        RolesAndResponsibilities__c rolesAndResp = new RolesAndResponsibilities__c();
        rolesAndResp.Name__c= UserInfo.getUserId();
        rolesAndResp.Responsibility__c = respon;  
        rolesAndResp.BusinessRole__c= bizRole; 
        //rolesAndResp.Role__c = role; 
        rolesAndResp.Preapplication__c = preapplicationId;
        lstRolesAndResponsibilities.add(rolesAndResp);          
        return lstRolesAndResponsibilities;  
    }*/

    private void updateAnnouncement(List<Preapplication__c> appList){
  
        Map<Id,Id> oppAnnMap = new Map<Id,Id>(); 
        for(Preapplication__c preapp: appList){   
            oppAnnMap.put(preapp.Id,preapp.Announcement__c); 
        }   

        List<Announcement__c> lstAnnouncements = [Select Id,Status__c from Announcement__c where Id in : oppAnnMap.values() ];

        for(Announcement__c announcement : lstAnnouncements){ 
            announcement.Status__c = 'Converted to Pre-Application';
        }
        update lstAnnouncements;
    }

    // Charan - This method is used to delete all Reviewers task when the Status of Pre-Application is changed to Reviewed */
    private void deleteTasksForReviewers(List<Preapplication__c> preApps){
        List<String> preAppIds = new List<String>();
        for(Preapplication__c preApp:preApps){
            if(preApp.Status__c=='Reviewed'){
                preAppIds.add(preApp.Name);
            }
        }
        List<Task> tsk = [SELECT Id FROM Task WHERE TrackingNumberLink1__c in:preAppIds and GNT__TaskAction__c in ('Review Pre-Application (Grantee)','Review Pre-Application') AND Status in ('Not Started','In Progress')];
        delete tsk;
    }

    private void shareWithInternalUsers(List<Preapplication__c> lstApp){
        for(Preapplication__c app: lstApp){ 
            app.PreAppGroupCode__c =app.PreAppGroupCodeFormula__c;
        }          
    }  
    

     private void createBudPeriodProjAreaBudCat(List<PreApplication__c> apps){
        Set<Id> appIds = new Set<Id>();
        Set<Id> announcementIds = new Set<Id>();
        Map<Id,List<PreApplication__c>> annAppListMap = new Map<Id,List<PreApplication__c>>();
        Map<Id, List<BudgetPeriod__c>> annBpListMap = new Map<Id, List<BudgetPeriod__c>>();
        Map<Id, List<AnnouncementServiceArea__c>> annAsaListMap = new Map<Id, List<AnnouncementServiceArea__c>>();
        Map<Id, List<FundingOpportunityBudgetCategory__c>> annFoBcListMap = new Map<Id, List<FundingOpportunityBudgetCategory__c>>();
        Map<Id,Map<Id, BudgetPeriod__c>> appBpIdMap = new Map<Id,Map<Id, BudgetPeriod__c>>();
        Map<Id,Map<Id, PreApplicationServiceArea__c>> appAsaIdMap = new Map<Id,Map<Id, PreApplicationServiceArea__c>>();
        
        List<BudgetPeriod__c> annBudPeriodList;
        List<AnnouncementServiceArea__c> annSaList;
        List<BudgetPeriod__c> budgetPeriodList = new List<BudgetPeriod__c>();
        List<PreApplicationServiceArea__c> appSaList = new List<PreApplicationServiceArea__c>();
        List<PreApplicationBudgetCategory__c> appBudCatList = new List<PreApplicationBudgetCategory__c>(); 
        List<BudgetPeriod__c> budPeriodList;
        List<AnnouncementServiceArea__c>  annServiceAreaList;
        List<FundingOpportunityBudgetCategory__c>  foBudList;
        Map<Id,String> annBudgetPeriodMap = new Map<Id,String>();
        BudgetPeriod__c firstBP= new BudgetPeriod__c();       

        for(PreApplication__c app:apps){            
            announcementIds.add(app.Announcement__c);           
        }
        budPeriodList = [Select id, SupportYear__c, BudgetEndDate__c, FundingOpportunity__c,SequenceNumber__c,Notes__c, BudgetStartDate__c, Status__c 
                        from BudgetPeriod__c where FundingOpportunity__c in :announcementIds];
        system.debug('BudPeriodList is:'+budPeriodList);
        annServiceAreaList = [Select Id, BudgetPeriod__c, ServiceArea__c,Announcement__c from AnnouncementServiceArea__c where Announcement__c  in :announcementIds];
        system.debug('Announcementservicearea is:'+annServiceAreaList);
        Map<Id,Announcement__c> annIdMap = new Map<Id,Announcement__c>([Select Id,name,ConstructionPackageIncluded__c from Announcement__c where id in :announcementIds]);
        // Only for Grantor Flow
        foBudList = [Select Id,FundingOpportunity__c,BudgetPeriod__c,FundingOpportunityProjectArea__c,FundingOpportunityBudgetPeriod__r.FundingOpportunityProjectArea__c ,FundingOpportunityBudgetPeriod__r.BudgetPeriod__c ,BudgetCategory__c 
                    from FundingOpportunityBudgetCategory__c where FundingOpportunity__c in :announcementIds];
        List<Application__c> appList = [Select Id, Name, Announcement__r.BudgetingPeriod__c from Application__c where Announcement__c IN : announcementIds];                                                                                                           
        for(BudgetPeriod__c bp:budPeriodList){
            List<BudgetPeriod__c> newBudPeriodList;
            
            if(annBpListMap.get(bp.FundingOpportunity__c) <> null){
                annBpListMap.get(bp.FundingOpportunity__c).add(bp);
            }else{
                newBudPeriodList = new List<BudgetPeriod__c>();
                newBudPeriodList.add(bp);
                annBpListMap.put(bp.FundingOpportunity__c,newBudPeriodList);                
            }
        }
        
        for(Application__c app :appList){
            annBudgetPeriodMap.put(app.Id,app.Announcement__r.BudgetingPeriod__c);
        }

        for(AnnouncementServiceArea__c asa:annServiceAreaList){
            List<AnnouncementServiceArea__c> asaList;
            
            if(annAsaListMap.get(asa.Announcement__c) <> null){
                annAsaListMap.get(asa.Announcement__c).add(asa);
            }else{
                asaList = new List<AnnouncementServiceArea__c>();
                asaList.add(asa);
                annAsaListMap.put(asa.Announcement__c,asaList);             
            }
        }
      
        for(FundingOpportunityBudgetCategory__c foBc:foBudList){
            List<FundingOpportunityBudgetCategory__c> foBcList;
            
            if(annFoBcListMap.get(foBc.FundingOpportunity__c) <> null){
                annFoBcListMap.get(foBc.FundingOpportunity__c).add(foBc);
            }else{
                foBcList = new List<FundingOpportunityBudgetCategory__c>();
                foBcList.add(foBc);
                annFoBcListMap.put(foBc.FundingOpportunity__c,foBcList);                
            }
        }
        
        for(PreApplication__c app:apps){
            String budPeriodSetting = annBudgetPeriodMap.get(app.Id);
            System.debug('**budPeriodSetting--'+budPeriodSetting);
            annBudPeriodList = annBpListMap.get(app.Announcement__c);
            if(annBudPeriodList <> null){
                if(budPeriodSetting=='Only First Budget Period'){
                    System.debug('**budPeriodSetting-only first BP-');
                    BudgetPeriod__c bp = annBudPeriodList[0];
                    BudgetPeriod__c appBp = new BudgetPeriod__c();
                    appBp.Application__c = app.Id;
                    appBp.SupportYear__c=bp.SupportYear__c;
                    appBp.BudgetEndDate__c=bp.BudgetEndDate__c;
                    appBp.Notes__c=bp.Notes__c;
                    appBp.BudgetStartDate__c=bp.BudgetStartDate__c;
                    appBp.Status__c=bp.Status__c;
                    appBp.SequenceNumber__c=bp.SequenceNumber__c;
                    firstBP=appBp;
                    budgetPeriodList.add(appBp);
                        if(appBpIdMap.get(app.Id) <> null){
                            appBpIdMap.get(app.Id).put(bp.Id,appBp);
                        }else{
                            Map<Id, BudgetPeriod__c> bpIdMap = new Map<Id, BudgetPeriod__c>();
                            bpIdMap.put(bp.Id,appBp);                           
                            appBpIdMap.put(app.Id, bpIdMap);
                        } 
                }
                else{
                    System.debug('**budPeriodSetting-all BPs-');
                    Integer count=0;
                    System.debug('**budPeriodSetting-annBudPeriodList-'+annBudPeriodList);   
                    for(BudgetPeriod__c bp:annBudPeriodList){
                        System.debug('**budPeriodSetting-bp-'+bp);                 
                        BudgetPeriod__c appBp = new BudgetPeriod__c();
                        appBp.PreApplication__c = app.Id;
                        appBp.SupportYear__c=bp.SupportYear__c;
                        appBp.BudgetEndDate__c=bp.BudgetEndDate__c;
                        appBp.Notes__c=bp.Notes__c;
                        appBp.BudgetStartDate__c=bp.BudgetStartDate__c;
                        appBp.Status__c=bp.Status__c;
                        appBp.SequenceNumber__c=bp.SequenceNumber__c;
                        if(count==0)
                        firstBP=appBp;
                        count++;
                        budgetPeriodList.add(appBp);
                            if(appBpIdMap.get(app.Id) <> null){
                                appBpIdMap.get(app.Id).put(bp.Id,appBp);
                            }else{
                                Map<Id, BudgetPeriod__c> bpIdMap = new Map<Id, BudgetPeriod__c>();
                                bpIdMap.put(bp.Id,appBp);                           
                                appBpIdMap.put(app.Id, bpIdMap);
                            }   
                    }
                 } // End of else              
            }            
        }
        if(budgetPeriodList.size()>0){
            insert budgetPeriodList;
        }
        for(PreApplication__c app:apps){
            annSaList = annAsaListMap.get(app.Announcement__c);     
            if(annSaList <> null){
                for(AnnouncementServiceArea__c asa:annSaList){
                    PreApplicationServiceArea__c appSa = new PreApplicationServiceArea__c();
                    appSa.ServiceAreaLookup__c = asa.ServiceArea__c;
                    appSa.PreApplication__c=app.Id;
                    appSa.ServiceArea__c=asa.Id;
                    if(asa.BudgetPeriod__c <> null){
                        if(appBpIdMap.get(app.Id) <> null){
                            if(appBpIdMap.get(app.Id).get(asa.BudgetPeriod__c) <> null){
                                appSa.BudgetPeriod__c = ((BudgetPeriod__c)appBpIdMap.get(app.Id).get(asa.BudgetPeriod__c)).Id;
                            }
                        }
                    }
                    appSaList.add(appSa);
                    if(appAsaIdMap.get(app.Id) <> null){
                        appAsaIdMap.get(app.Id).put(asa.Id,appSa);
                    }else{
                        Map<Id, PreApplicationServiceArea__c> appIdMap = new Map<Id, PreApplicationServiceArea__c>();
                        appIdMap.put(asa.Id,appSa);                         
                        appAsaIdMap.put(app.Id, appIdMap);
                    }                    
                }
            }
        }
        if(appSaList.size()>0){
            insert appSaList;
        }       
       List<RecordType> recordTypeList = [select Id, Name, SobjectType FROM RecordType where SobjectType=:AppUtils.getNamespacePrefix()+'BudgetCategory__c' and Name='External'];
       List<BudgetCategory__c> nonConlstBudgetCat = [Select Id,Name from BudgetCategory__c where Status__c='Active' AND recordTypeId =:recordTypeList[0].Id AND Class__c ='Non Construction'];
       List<BudgetCategory__c> conlstBudgetCat = [Select Id,Name from BudgetCategory__c where Status__c='Active' AND recordTypeId =:recordTypeList[0].Id AND Class__c ='construction'];
      
        for(PreApplication__c app:apps){
            // Check Grantee or Grantor here
            if(GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c')=='StateasGrantee'){
                for(BudgetPeriod__c bp: (List<BudgetPeriod__c>)budgetPeriodList){
                    for(PreApplicationServiceArea__c asa:appSaList){
                        if(annIdMap.get(app.Announcement__c).ConstructionPackageIncluded__c){   // construction categories
                            for(BudgetCategory__c objBC : conlstBudgetCat){
                                PreApplicationBudgetCategory__c abc = new PreApplicationBudgetCategory__c();
                                abc.PreApplication__c=app.Id;
                                abc.BudgetCategory__c=objBC.Id;
                                abc.BudgetPeriod__c=bp.Id;   
                                if(firstBP.Id==abc.BudgetPeriod__c)
                                abc.IsFirstBudgetPeriodRelated__c=true;
                                abc.ServiceArea__c=asa.Id;  
                                appBudCatList.add(abc);  
                            }
                        }else{
                             for(BudgetCategory__c objBC : nonConlstBudgetCat){
                                PreApplicationBudgetCategory__c abc = new PreApplicationBudgetCategory__c();
                                abc.PreApplication__c=app.Id;
                                abc.BudgetCategory__c=objBC.Id;
                                abc.BudgetPeriod__c=bp.Id;   
                                if(firstBP.Id==abc.BudgetPeriod__c)
                                abc.IsFirstBudgetPeriodRelated__c=true;
                                abc.ServiceArea__c=asa.Id;  
                                appBudCatList.add(abc);  
                             }
                         }                    
                    }  // close the Service Area
               }// close the budget Period 
            }          
            else{  // As Grantor/Recipient flow
                foBudList = annFoBcListMap.get(app.Announcement__c);
                if(foBudList <> null){
                Integer count =0;
                for(FundingOpportunityBudgetCategory__c foBd: foBudList){
                    PreApplicationBudgetCategory__c abc = new PreApplicationBudgetCategory__c();
                    abc.PreApplication__c=app.Id;
                    abc.BudgetCategory__c=foBd.BudgetCategory__c;
                    if(foBd.BudgetPeriod__c <> null){
                        if(appBpIdMap.get(app.Id) <> null){
                            if(appBpIdMap.get(app.Id).get(foBd.BudgetPeriod__c) <> null){
                                abc.BudgetPeriod__c = ((BudgetPeriod__c)appBpIdMap.get(app.Id).get(foBd.BudgetPeriod__c)).Id;
                                system.debug('firstBP.Id--'+firstBP.Id);
                                system.debug('abc.BudgetPeriod__c--'+abc.BudgetPeriod__c);
                                if(firstBP.Id==abc.BudgetPeriod__c)
                                abc.IsFirstBudgetPeriodRelated__c=true;
                                system.debug('abc--'+abc);
                            }                            
                        }
                    }
                    if(foBd.FundingOpportunityProjectArea__c <> null){
                        if(appAsaIdMap.get(app.Id) <> null){
                            if(appAsaIdMap.get(app.Id).get(foBd.FundingOpportunityProjectArea__c) <> null){
                                abc.ServiceArea__c= ((PreApplicationServiceArea__c)appAsaIdMap.get(app.Id).get(foBd.FundingOpportunityProjectArea__c)).Id;
                            }   
                        }
                    }
                    if(abc.BudgetPeriod__c!=null && abc.ServiceArea__c!=null){
                     appBudCatList.add(abc); 
                    }     
                }
            } 
          }                
        }
        if(appBudCatList.size()>0){
            insert appBudCatList;
        }
    }
}