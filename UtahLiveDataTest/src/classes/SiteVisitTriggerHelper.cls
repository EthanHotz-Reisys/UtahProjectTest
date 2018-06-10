global with sharing class SiteVisitTriggerHelper extends GNT.TriggerHelper{

    public static Boolean skipTrigger= false;
    public static boolean firstRun = true;
    global override void processBeforeInsert() {
     //  updateApprovalManagerField();
    
    }

    public override void processBeforeUpdate(){  
        if(skipTrigger == false){      
        String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
    
        if(appName == 'StateasGrantor'){   
          updateSiteVisitReport(Trigger.new);
        }
        }       
    }
        
    global override void processAfterInsert() {
        if(skipTrigger == false){
        createSiteVisitShares(Trigger.New);
    //   updateSiteSchedule();
    //   createTaskForSiteVisitor();
     //  updateLocationFields(trigger.newMap.keySet());
      copyRolesAndResponsibilities();
      if(!System.isFuture() && !System.isBatch()){ 
            taskAndNotificationForAdhoc((List<SiteVisit__c>)Trigger.New);
        }
      }     
    }
    
    global override void processBeforeDelete() {
    //   checkIfDeleteAllowed();
    }
    
    global override void processAfterUpdate() {
        if(skipTrigger == false){
        String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
    
      system.debug('updateSubmissionHistory----appName --'+appName );
    if(appName == 'StateasGrantee'){
         updateSubmissionHistory(); 
        }
        approvalSendBack(Trigger.New, Trigger.Old);
        }
    }
           
    /*private void updateApprovalManagerField(){
        List<SiteVisit__c> siteVisits = trigger.new;
        for(SiteVisit__c siteVisit : siteVisits ){
            siteVisit.ApprovalManager__c = siteVisit.GrantAssignedToID__c;
        }
    }*/
    private void approvalSendBack(List<SiteVisit__c> siteVis, List<SiteVisit__c> siteVisOld){
        List<Id> listids = new List<Id>();
        for (SiteVisit__c site : siteVis) {
            for (SiteVisit__c siteOld : siteVisOld) {
                if (site.Id == siteOld.Id && site.Status__c == 'Visited' && siteOld.Status__c == 'Report Submitted') {
                    listids.add(site.Id);
                }
            }
        }
        if (listids.size() > 0) {
            approvalSendBackHelper(listids);
        }
     }

     @future
    private static void approvalSendBackHelper(List<Id> listids){
        List<SiteVisit__c> siteList = [SELECT Id,GrantAdministrator__c,Name,SiteVisitName__c FROM SiteVisit__c WHERE Id IN: listids];
        for (SiteVisit__c sites : siteList) {
            GNT.TaskCreationHandler.createTasks(sites.GrantAdministrator__c, sites.Id, 'Redo Site Visit', sites.Name, null, false, System.TODAY() + 7, 'Redo Site Visit', sites.SiteVisitName__c, true);
        }
    }


    private Void updateSiteVisitReport(List<SiteVisit__c> listVisit  )
    {
    //  List<SiteVisit__c> listVisit = new List<SiteVisit__c>(Trigger.new);
    Map<Id,SiteVisit__c> oldMap = (Map<Id,SiteVisit__c>) Trigger.oldMap;

       for(SiteVisit__c sVisit : listVisit){
            if(sVisit.Recommendation__c != null &&  sVisit.ProgramRating__c!=null && oldMap.get(sVisit.Id).Status__c=='Planned' ){
              sVisit.status__c='Visited';
             // listVisit.add(sVisit);
            }

          }

          

    }
    
  // To Copy Roles and Responsibility from Award when new Site Visit is Created
  private void copyRolesAndResponsibilities()
  {

    List<String> awdID = new List<String>();
    List<RolesAndResponsibilities__c> rolesList = new List<RolesAndResponsibilities__c>();
    String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
    String developerName;
    
    if(appName == 'StateasGrantee'){
        developerName = 'SiteVisit';
    }
    else{
        developerName = 'GrantorSiteVisit';
    }
    
    
  for(SiteVisit__c sVisit : (List<SiteVisit__c>)Trigger.new){
            if(sVisit.Award__c != null){
                awdID.add(sVisit.Award__c);  
            }                     
        } 
        system.debug('imhere');
        // GNT.AppUtils.soqlList(awdID) is returning List<String>, awdID is already a list of string - So no need to call that method - Sarat
        //String query =  'Select Id,Name__c,BusinessRole__c,Award__c,Notify__c,Responsibility__c,SiteVisit__c from RolesAndResponsibilities__c where Award__c in '+ GNT.AppUtils.soqlList(awdID);       
        String query =  'Select Id,Name__c,BusinessRole__c,Award__c,Notify__c,Responsibility__c,SiteVisit__c,UserType__c from RolesAndResponsibilities__c where Award__c IN :awdID';     
        List<RolesAndResponsibilities__c> lstRoles = Database.query(query);
        
        system.debug('imhere----->>>>>>>' + lstRoles);

        List<RecordType> recType = [select Id, Name FROM RecordType where SobjectType=:AppUtils.getNamespacePrefix()+'RolesAndResponsibilities__c' and DeveloperName=:developerName  Limit 1];
    
        String recId = recType[0].Id;

          for(SiteVisit__c sVisit : (List<SiteVisit__c>)Trigger.new){
               system.debug('---sVisit.Id---'+sVisit.Id);
            for(RolesAndResponsibilities__c roleandresp : (List<RolesAndResponsibilities__c>)lstRoles){

              // Adding only Program R&R
              if((roleandresp.BusinessRole__c.equalsIgnoreCase('Program Approver') || roleandresp.BusinessRole__c.equalsIgnoreCase('Grants Administrator')) && sVisit.Award__c==roleandresp.Award__c){
                 RolesAndResponsibilities__c rolesSV = new RolesAndResponsibilities__c();

                rolesSV.Name__c=roleandresp.Name__c;
                //rolesSV.Role__c=roleandresp.Role__c;
                rolesSV.BusinessRole__c=roleandresp.BusinessRole__c;
                rolesSV.SiteVisit__c=sVisit.Id;
                rolesSV.Notify__c=roleandresp.Notify__c;
                rolesSV.RecordTypeId=recId;
                rolesSV.Responsibility__c=roleandresp.Responsibility__c;
                rolesSV.UserType__c=roleandresp.UserType__c;

                 rolesList.add(rolesSV);   
              }
       
                    }
                }      

                if(rolesList!=null && rolesList.size()>0)
                {
                  insert rolesList;
             
                }

  }

   // Update Submission History for Site Visits
    private void updateSubmissionHistory()
    {    
    system.debug('updateSubmissionHistory----');
    
      List<SubmissionTracking__c> subTrckList= new List<SubmissionTracking__c>();
           
        Id poc;
        Id progRptPgmApprover;


        for(SiteVisit__c rpt : (List<SiteVisit__c>)Trigger.new){
            system.debug('updateSubmissionHistory---1-');
   
                if(rpt.status__c=='Submitted to Grantor')
                { 
                
                 system.debug('updateSubmissionHistory--2--');
   
                SubmissionTracking__c subTrck = new SubmissionTracking__c();
                subTrck.SubmissionId__c = rpt.Id;
                subTrck.TrackingType__c = 'Info';
                subTrck.Comments__c = 'Site Visit Report Submitted : '+ rpt.Name;
                subTrck.Status__c = 'Submitted to Grantor';
                subTrck.TrackingNumber__c = rpt.Name;
        

                subTrckList.add(subTrck);
                
                }
       
        }      
        
      
        
       if(subTrckList!=null && subTrckList.size()>0)
       {
        system.debug('updateSubmissionHistory----3');
   
       insert subTrckList;
       }
       
    
    
    
    }

    private void taskAndNotificationForAdhoc(List<SiteVisit__c> svList){
    if(!Test.isRunningTest()){
            List<GNT.TaskCreationHandler.TaskBulkClass> tasksList = new List<GNT.TaskCreationHandler.TaskBulkClass>();
            List<GNT.EmailFeeder> emails = new List<GNT.EmailFeeder>();
            for(SiteVisit__c sv : svList){
                GNT.TaskCreationHandler.TaskBulkClass task = new GNT.TaskCreationHandler.TaskBulkClass();
                task.ownerUserId = sv.GrantAdministrator__c;
                task.recordId = sv.Id;
                task.action = 'Site Visit Preparation';
                task.recordName = sv.SiteVisitName__c;
                task.dueDate = System.TODAY() + 7;
                task.subject = 'Populate site visit details';
                tasksList.add(task);
                emails.add(new GNT.EmailFeeder().TargetObjectID(sv.GrantAdministrator__c).template('SiteVisitCreated').contextRecordId(sv.Id));
            }

            List<Task> insertedTaskList = GNT.TaskCreationHandler.createBulkTasks(tasksList, true);
            GNT.EmailFeeder.SendEmails(emails);
        }
    } 

   /* @future (callout=true)
    private static void  updateLocationFields(Set<Id> siteVisitIds){
            SiteVisitTriggerHelper.firstRun = false;
            List<SiteVisit__c> updatedsiteVisits = new List<SiteVisit__c>();
             List<SiteVisit__c> siteVisits =[select Street__c, City__c,State__c, SiteVisitLocation__Latitude__s,SiteVisitLocation__Longitude__s from SiteVisit__c where id in :siteVisitIds];
             for(SiteVisit__c siteVisit : siteVisits ){
                    Map<String, Object> result = MapQuestAddressInformationCtrl.GetLatLangAddressRemote(siteVisit.Street__c, siteVisit.City__c, siteVisit.State__c);
                    if(result.size() > 0){
                        
                        siteVisit.SiteVisitLocation__Latitude__s = (Decimal)(result.get('lat'));
                        siteVisit.SiteVisitLocation__Longitude__s = (Decimal)(result.get('lng'));
                        updatedsiteVisits.add(siteVisit);
                    }
                    
             }
             if(updatedsiteVisits.size () > 0){
                
                update updatedsiteVisits;
             }
    }*/
    
   /* private void createTaskForSiteVisitor(){
            List<SiteVisit__c> siteVisits = trigger.new;
            List<Task> taskList = new List<Task>();
            for(SiteVisit__c siteVisit : siteVisits){
                Task submitTask = new Task();
                submitTask.subject = 'Submit Site Visit Report for Grant '+siteVisit.GrantNumber__c;
                submitTask.WhatId= siteVisit.Id;
                submitTask.OwnerId = siteVisit.SiteVisitor__c;
                submitTask.GNT__action__c = 'Submit Site Visit Report';
                submitTask.GNT__documentType__c = 'Site Visit';
                submitTask  = GNT.AppUtils.assignTaskForSObject(submitTask, siteVisit.Id);  
                submitTask.ActivityDate = siteVisit.VisitDateandTime__c.date().addDays(7);//Date.today().addDays(7);
                taskList.add(submitTask );   
            }
            if(taskList.size () > 0){
                insert taskList;
            }
    }*/
    
   /* private void notifyGranteePOCOfSiteVisit(){
            List<SiteVisit__c> siteVisits = trigger.new;
            Map<Id,Id> siteVisitContactId = new Map<Id,Id>();
            for(SiteVisit__c siteVisit : siteVisits){
                siteVisitContactId.put(siteVisit.id,siteVisit.GranteePOCID__c);
            }
            if(siteVisitContactId.size () > 0){
                List<EmailTemplate> template = [select id from EmailTemplate where DeveloperName = 'Notify_Grantee_of_the_Site_Visit' limit 1 ];
                if(template.size () > 0){
                 AppUtils.sendEmailUsingTemplate(template[0].id, siteVisitContactId, true);
                }
            }
    }*/
    
   /* private void updateSiteSchedule(){
        Set<Id> siteScheduleIds = new Set<Id>();
        List<SiteVisit__c> siteVisits = trigger.new;
        for(SiteVisit__c siteVisit : siteVisits ){
            //siteScheduleIds.add(siteVisit.SiteVisitSchedule__c);
        }
        
        Map<Id,SiteVisitSchedule__c> siteScheduleMap = new Map<Id,SiteVisitSchedule__c>([select status__c from 
            SiteVisitSchedule__c where id in :siteScheduleIds]);
        List<SiteVisitSchedule__c> schedules = new  List<SiteVisitSchedule__c>();
        for(SiteVisitSchedule__c schedule :siteScheduleMap.values()){
            if(schedule.status__c.equalsIgnoreCase('Finalized')){
                schedule.status__c = 'In Progress';
                schedules.add(schedule);
            }
        }
        if(schedules != null && schedules.size() > 0){
            update schedules;     
        }   
     }*/
      
      /*
          This method prevent deletion of  SiteVisit if
          Schedule is finalized
      */
     /* private void checkIfDeleteAllowed(){
        Map<Id,Id> siteScheduleVisitMap = new Map<Id,Id> ();
        List<SiteVisit__c> siteVisits = trigger.old;
        for(SiteVisit__c siteVisit : siteVisits ){
            //siteScheduleVisitMap.put(siteVisit.id,siteVisit.SiteVisitSchedule__c);
        }
        Map<Id,SiteVisitSchedule__c> siteScheduleMap = new Map<Id,SiteVisitSchedule__c>([select status__c from SiteVisitSchedule__c 
                where id in :siteScheduleVisitMap.values()]);
        
        
         
            Check the status of scedule and if finalized
            prevent user from deleting the site visit
         
        for(SiteVisit__c siteV : siteVisits ){
                SiteVisitSchedule__c siteSchedule = siteScheduleMap.get(siteScheduleVisitMap.get(siteV.id));
                if(siteSchedule.status__c == 'Finalized'){
                   //siteV.addError('Site Visit cannot be deleted from a Finalized Schedule');
                   siteV.addError(GNT.ErrorMessageHelper.fetchMessage('M01-GRNTR-61470'));
                } 
            }
        } */
        
       private void createSiteVisitShares(List<SiteVisit__c> sVisits) {
        List<String> reportIds = new List<String>();
        Map<String, Map<String, SiteVisit__Share>> shareMap = new Map<String, Map<String, SiteVisit__Share>>();
        for(SiteVisit__c report: sVisits) {
            reportIds.add(report.id);
            if(!shareMap.containsKey(report.id)) {
                shareMap.put(report.id, new Map<String, SiteVisit__Share>());
            }
        }
        List<SiteVisit__Share> currentShares = [SELECT ParentId, AccessLevel, UserOrGroupId FROM SiteVisit__Share WHERE ParentId IN: reportIds];
        System.debug(currentShares);
        for(SiteVisit__Share ps: currentShares) {
            shareMap.get(ps.ParentId).put(ps.userOrGroupId, ps);
        }
        SiteVisit__Share share;
        List<SiteVisit__Share> shares = new List<SiteVisit__Share>();
        List<SiteVisit__c> reportslist = [select id,Award__r.CreatedById,ApprovalManager__c,Award__r.ProgramManager__c,ProjectManager__c, GrantAdministrator__c, ProgramApprover__c,OwnerId  
                                                  from SiteVisit__c where id IN:reportIds ];
      
        for(SiteVisit__c report: reportslist) {
            System.debug('**report: ' + report);
            system.debug('Grant Admin is ' +report.GrantAdministrator__c);
                if(report.GrantAdministrator__c != null) {
                    share = new SiteVisit__Share(parentId = report.id, AccessLevel = 'Edit', UserOrGroupId = report.GrantAdministrator__c, RowCause = Schema.SiteVisit__Share.RowCause.SharetoApprover__c);
                    shares.add(share);
                    shareMap.get(report.id).put(report.GrantAdministrator__c, share);
                }
                //if(report.Award__r.CreatedById != null && report.Award__r.CreatedById!=report.OwnerId) {
                //    share = new SiteVisit__Share(parentId = report.id, AccessLevel = 'Edit', UserOrGroupId = report.Award__r.CreatedById, RowCause = Schema.SiteVisit__Share.RowCause.SharetoApprover__c);
                //    shares.add(share);
                //    shareMap.get(report.id).put(report.Award__r.CreatedById, share);
                //}
                //if(report.ApprovalManager__c != null  && report.Award__r.CreatedById!=report.OwnerId) {
                //    share = new SiteVisit__Share(parentId = report.id, AccessLevel = 'Edit', UserOrGroupId = report.ApprovalManager__c, RowCause = Schema.SiteVisit__Share.RowCause.SharetoApprover__c);
                //    shares.add(share);
                //    shareMap.get(report.id).put(report.ApprovalManager__c, share);
                //}
                //if(report.Award__r.ProgramManager__c != null  && report.Award__r.CreatedById!=report.OwnerId) {
                //    share = new SiteVisit__Share(parentId = report.id, AccessLevel = 'Edit', UserOrGroupId = report.Award__r.ProgramManager__c, RowCause = Schema.SiteVisit__Share.RowCause.SharetoApprover__c);
                //    shares.add(share);
                //    shareMap.get(report.id).put(report.Award__r.ProgramManager__c, share);
                //}
                //if(report.ProjectManager__c != null  && report.Award__r.CreatedById!=report.OwnerId) {
                //    share = new SiteVisit__Share(parentId = report.id, AccessLevel = 'Edit', UserOrGroupId = report.ProjectManager__c, RowCause = Schema.SiteVisit__Share.RowCause.SharetoApprover__c);
                //    shares.add(share);
                //    shareMap.get(report.id).put(report.ProjectManager__c, share);
                //}
                //if(report.ProgramApprover__c != null && report.Award__r.CreatedById!=report.OwnerId) {
                //    share = new SiteVisit__Share(parentId = report.id, AccessLevel = 'Edit', UserOrGroupId = report.ProgramApprover__c, RowCause = Schema.SiteVisit__Share.RowCause.SharetoApprover__c);
                //    shares.add(share);
                //    shareMap.get(report.id).put(report.ProgramApprover__c, share);
                //}
            }
      
        System.debug('Shares: ' + shares);
    
     try{
            if(shares.size() > 0) {
                    System.debug('Upsert');
                     SystemContextMethodsHelper SystemContextMethodsHelper = new SystemContextMethodsHelper();
                SystemContextMethodsHelper.upsertSiteVisitShare(shares);
                }
            }
            catch(Exception exc){
                system.debug(exc.getStackTraceString());
                system.debug(exc.getMessage());
            }
   }

}