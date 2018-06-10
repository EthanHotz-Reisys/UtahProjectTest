global without sharing class ChangeRequestTriggerHelper extends GNT.TriggerHelper {
    global override void processAfterInsert() {
        //changeApplicationStatus();
        notifyApplicant();
        changeApplicationStatusOnInsert();
    }
    
    global override void processBeforeInsert(){
        //NameTemplateTriggerHelper.beforeInsert(); 
        updateChnageRequestPendingOnInsert();
        setApprover();
    }
    
    global override void processBeforeUpdate(){
        upateChnageRequestPendingOnUpdate();
        changeApplicationStatus();
        //finalSubmissionRequest();
    }
    global override void processAfterUpdate(){
        updateApplicationStatus();
        updateApplicationStatusUSBE();
    }

    /* PRIVATE METHODS */
    
    private static void notifyApplicant(){
        List<Id>appIds = new List<Id>(); 
        Map<Id,Id>ownerIdAppMap = new Map<Id,Id>();//key->app id
        for(ChangeRequest__c req :(List<ChangeRequest__c>)Trigger.new){
            if (req.Application__c != null) {
                appIds.add(req.Application__c);
            }
        }
        List<Application__c> appList = [select Announcement__r.ChangeRequestAssignmentEmailTemplate__r.GNT__EmailTemplateDeveloperName__c,OwnerId from Application__c
                                                                where id in:appIds];
        Map<Id,String> templateNameAppId = new Map<Id,String>();
        Map<Id,Id> appTemplateMap = new Map<Id,Id>();
        for(Application__c app :appList){
            templateNameAppId.put(app.id,app.Announcement__r.ChangeRequestAssignmentEmailTemplate__r.GNT__EmailTemplateDeveloperName__c);
            ownerIdAppMap.put(app.Id,app.OwnerId);
        }
        Map<Id,User> userMap = new Map<Id,User>([select contactId from User where id in:ownerIdAppMap.values()]);
        Map<Id,Id>appContactIdMap = new Map<Id,Id>();
        for(Id ids : ownerIdAppMap.keySet()){
            User u = userMap.get(ownerIdAppMap.get(ids));
            appContactIdMap.put(ids,u.contactId);
        }
        
        Map<Id,EmailTemplate> emailTemplates = new Map<Id,EmailTemplate>([select id,DeveloperName from EmailTemplate where DeveloperName in:templateNameAppId.values()]);
        Map<Id,Id> appIdTemplateIdMap = new Map<Id,Id>();
        Map<String,Id> nameIdMap = new Map<String,Id>();
        for(EmailTemplate template : emailTemplates.values()){
            nameIdMap.put(template.DeveloperName,template.id);
        }
        
        for(Application__c app : appList){
            Id templateId = nameIdMap.get(templateNameAppId.get(app.Id));
            appIdTemplateIdMap.put(app.id,templateId);
        }               
    }
    private void updateChnageRequestPendingOnInsert(){
        for(ChangeRequest__c req :(List<ChangeRequest__c>)Trigger.new){
            req.ChangeRequestPendingOn__c = 'External';
        }
    }
    
    private void setApprover(){
    	List<ChangeRequest__c> reqList = Trigger.new;
    	Set<Id> appIds = new Set<Id>();
    	for (ChangeRequest__c req : reqList){
    		appIds.add(req.Application__c);
    	}
    	List<Application__c> appList = [SELECT Id,Approver__c,OwnerId FROM Application__c WHERE Id IN: appIds];
    	
    	for (ChangeRequest__c req : reqList){
    		for (Application__c app : appList){
    			if (req.Application__c == app.Id){
    				req.Approver__c = app.Approver__c;
    				req.Applicant__c = app.OwnerId;
    			}
    		}
    	}
    }
    
    //When new change request is created, make the application status as in progress.
    private void changeApplicationStatus() {
        //Map<Id, Application__c> appMap = new Map<Id, Application__c>(); //key->app id
        List<Application__c> appList = new List<Application__c>();
        for(ChangeRequest__c req :(List<ChangeRequest__c>)Trigger.new){
            ChangeRequest__c oldReq = (ChangeRequest__c)Trigger.oldMap.get(req.Id);
                 system.debug('--req--'+req);
            if (req.Application__c != null) {

                //Application__c app = new Application__c(Id=req.Application__c, Status__c='In Progress', ChangeRequestStatus__c = 'Change Request Assigned');
                //Change made by Prasanna - Negotiation In Progress
                if(req.status__c == 'Initiated' && oldReq.Status__c =='Not Initiated'){
                    Application__c app = new Application__c(Id=req.Application__c, Status__c='Revision Initiated', ChangeRequestStatus__c = 'Change Request Assigned');
        //      appMap.put(app.Id, app);
                appList.add(app);
            }
                
            }
        }
        if(appList.size()>0)
            update appList;
        //update appMap.values();
    }

    //When new change request is created, make the application status as in progress.
    private void changeApplicationStatusOnInsert() {
        //Map<Id, Application__c> appMap = new Map<Id, Application__c>(); //key->app id
        List<Application__c> appList = new List<Application__c>();
        for(ChangeRequest__c req :(List<ChangeRequest__c>)Trigger.new){
           system.debug('--req--'+req);
            if (req.Application__c != null) {

                if(req.status__c == 'Initiated'){
                    Application__c app = new Application__c(Id=req.Application__c, Status__c='Revision Initiated', ChangeRequestStatus__c = 'Change Request Assigned');
                appList.add(app);
            }
                
            }
        }
        if(appList.size()>0)
            update appList;
    }
    
    private void updateApplicationStatus() {
         Map<Id, Application__c> appMap = new Map<Id, Application__c>(); //key->app id
         Map<Id,String> appStausMap = new Map<Id,String>();
         List<Application__c> appList = new List<Application__c> ();
         List<Id>appId = new List<Id>();
         Map<Id,ChangeRequest__c> oldRequestMap = (Map<Id,ChangeRequest__c>)trigger.oldMap;
        for(ChangeRequest__c req :(List<ChangeRequest__c>)Trigger.new){
                if (req.Application__c != null) {
                    if(req.Status__c == 'Rejected' && oldRequestMap.get(req.id).Status__c == 'Initiated') { 
                        appId.add(req.Application__c);
                        appStausMap.put(req.Application__c,'Change Request Rejected');
                    }else if(req.Status__c == 'Accepted' && oldRequestMap.get(req.id).Status__c == 'Initiated') {   
                        appId.add(req.Application__c);
                        appStausMap.put(req.Application__c,'Change Request Accepted');
                    }
                }
        }
        appList = [select Status__c,ChangeRequestStatus__c from Application__c where id in :appId];
        for(Application__c app :appList){
            if(appStausMap.get(app.id) == 'Change Request Rejected'){
                app.status__c = 'Submitted';
            }
            app.ChangeRequestStatus__c =appStausMap.get(app.id);
            
        }
        update appList;
    }
    
    private void updateApplicationStatusUSBE(){
    	List<ChangeRequest__c> reqList = Trigger.New;
    	Set<Id> appIds = new Set<Id>();
    	for (ChangeRequest__c req : reqList){
    		ChangeRequest__c reqOld = (ChangeRequest__c) Trigger.oldMap.get(req.Id);
    		if (reqOld.Status__c == 'Submitted for Approval' && req.Status__c == 'Submitted'){
    			appIds.add(req.Application__c);
    		}
    	}
    	
    	if (appIds.size() > 0){
    		List<Application__c> appList = [SELECT Id FROM Application__c WHERE Id IN: appIds];
    		for (Application__c app : appList){
    			app.ChangeRequestStatus__c = 'Revision Request Completed';
    		}
    		update appList;
    	}
    }
    
     private void upateChnageRequestPendingOnUpdate() {
         Map<Id,ChangeRequest__c> oldRequestMap = (Map<Id,ChangeRequest__c>)trigger.oldMap;
        
            for(ChangeRequest__c req :(List<ChangeRequest__c>)Trigger.new){
                if (req.Application__c != null) {
                    if(req.Status__c == 'Rejected' && oldRequestMap.get(req.id).Status__c == 'Initiated') { 
                            req.ChangeRequestPendingOn__c = '';
                    }
                }
            }
        
    }

  /**  private void finalSubmissionRequest(){
        Id appId;
        Id userId;
        List<Application__c> appList;
        ChangeRequest__c changeReq;
        Application__c app;
        Task task;
        for(ChangeRequest__c req :(List<ChangeRequest__c>)Trigger.new){
            ChangeRequest__c oldReq = (ChangeRequest__c)Trigger.oldMap.get(req.Id);
            //if(req.status__c == 'Submitted By Applicant' && (oldReq.DEDecision__c != req.DEDecision__c || oldReq.PODecision__c != req.PODecision__c || oldReq.GMDecision__c != req.GMDecision__c)){
            if(req.status__c == 'Submitted By Applicant' && (oldReq.GMTaskStatus__c != req.GMTaskStatus__c || oldReq.POTaskStatus__c != req.POTaskStatus__c || oldReq.DETaskStatus__c != req.DETaskStatus__c)){             
                changeReq = [Select Id,Status__c, Name, Type__c, DueDate__c,Comments__c, 
                Application__r.Id, OwnerId, PODecision__c,  POComments__c, DEComments__c, 
                DEDecision__c, GMComments__c,  GMDecision__c, Application__r.ProjectOfficer__r.Id, 
                Application__r.DataEvaluator__r.Id, Application__r.GrantMonitor__r.Id from 
                ChangeRequest__c where id=:req.id Limit 1];
                appId = changeReq.Application__r.Id;
                if(UserInfo.getUserId()==changeReq.Application__r.ProjectOfficer__r.Id){
                    
                    userId=changeReq.Application__r.ProjectOfficer__r.Id;
                }
                if(UserInfo.getUserId()==changeReq.Application__r.GrantMonitor__r.Id){
                    
                    userId=changeReq.Application__r.GrantMonitor__r.Id;
                    
                }
                if(UserInfo.getUserId()==changeReq.Application__r.DataEvaluator__r.Id){
                    
                    userId=changeReq.Application__r.DataEvaluator__r.Id;
                }
                List<Task> taskList = [Select Id, Status, WhatId from Task where 
                                       ObjectRelationName__c=:changeReq.Name AND 
                                       OwnerId = :userId AND WhatId = :changeReq.Id Limit 1];
                if(taskList != null && taskList.size()>0){
                    task = taskList[0];
                    task.Status='Completed';
                    update task;
                }
                if(req.PODecision__c != 'None' && req.GMDecision__c != 'None' && req.DEDecision__c != 'None'){
                    req.Status__c = 'Completed By Internal';
                    //update changeReq;
                    appList = [Select ChangeRequestStatus__c From Application__c Where id = :appId Limit 1];
                    app = appList[0];
                    app.ChangeRequestStatus__c='Change Request Completed by Internal';
                    update app;
                }


            }
    }
    } */
}