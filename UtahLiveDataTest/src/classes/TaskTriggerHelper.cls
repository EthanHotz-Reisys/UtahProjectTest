/*
    This is a helper class for the Task Trigger
    
    *******************************************************************************************************************
    Audit History
    ********************************************************************************************************************
    2014-05-27  Vineeth Shetty      Created 
    2017-04-01  Shah Kadirmohideen  Code Reviewed
    **********************************************************************************************************************  
*/ 
public with sharing class TaskTriggerHelper extends GNT.TriggerHelper{       
    public static Boolean skipTrigger = false;
    public override void processAfterInsert() {
        if(!skipTrigger) {
            sendNotificationEmail(trigger.new);
        }
    }
    
    public override void processAfterUpdate(){
        changeTaskDetailRecStatus();
    }

    
    
    public override void processBeforeInsert(){
        if(!skipTrigger) {
            //populateActivityDuplicateDate(Trigger.new);
            populateAssignedToUserType(Trigger.new);
            //updatePhaseName(Trigger.new);
            updateApplicationId(Trigger.new);
        }
       
    }

    public override void processBeforeUpdate(){
        //populateActivityDuplicateDate(Trigger.new);
        //closeRelatedTasks();
    }
    
    public static boolean skipCloseTaskMethod = false;
    
    // commented out these methods because the methods are not used- Charan
   /* private void closeRelatedTasks(){
        if(!TaskTriggerHelper.skipCloseTaskMethod){
            Task tsk = (Task)trigger.new[0];  //Shah CRF: not bulkified. This could cause issue during data migration.
            Task tskOld = (Task)trigger.oldMap.get(tsk.Id);
            if(tsk.status == 'Completed' && tskOld.Status == 'In Progress'){
                List<task> taskList = [Select id, Status from Task Where 
                    WhatId = :tsk.WhatId AND Status != 'Completed' AND GNT__AssignedToQueue__c = true 
                        AND GNT__GroupId__c = :tsk.GNT__GroupId__c AND ID != :tsk.Id AND GNT__TaskAction__c = :tsk.GNT__TaskAction__c];
                for(Task t : taskList){
                    t.Status = 'Completed';
                }
                TaskTriggerHelper.skipCloseTaskMethod = true;
                SystemContextMethodsHelper sc = new SystemContextMethodsHelper();
                sc.updateTasks(taskList);
                //update taskList;
            }
        }
    }
    
    public void populateActivityDuplicateDate(List<Task> taskList){
        for(Task taskInstance : taskList){
            taskInstance.GNT__ActivityDuplicateDate__c = taskInstance.ActivityDate;  
        }       
    }*/
    private void changeTaskDetailRecStatus(){
        Map<Id,String> taskDetailId = new Map<Id,String>();
        Map<Id,Task> taskOldMap = (Map<Id,Task>)trigger.oldMap;
        for(Task t : (List<Task>)trigger.new){
            if(t.status == 'Completed' && taskOldMap.get(t.id).status != 'Completed'){
                if(!String.isEmpty(t.GNT__TaskScheduleDetailId__c)){
                    taskDetailId.put((Id)t.GNT__TaskScheduleDetailId__c,'Completed');
                }
            }
            if(t.status == 'In Progress' && taskOldMap.get(t.id).status != 'In Progress'){
                if(!String.isEmpty(t.GNT__TaskScheduleDetailId__c)){
                    taskDetailId.put((Id)t.GNT__TaskScheduleDetailId__c,'In Progress');
                }
            }
        }
        
        List<TaskScheduleDetail__c> taskScheduleDetails = [select status__c from TaskScheduleDetail__c where id in:taskDetailId.keySet()];
        for(TaskScheduleDetail__c taskScheduleDetail :taskScheduleDetails){
            taskScheduleDetail.status__c = taskDetailId.get(taskScheduleDetail.id);
        }
        update taskScheduleDetails;
    }
    private void populateAssignedToUserType(List<Task> taskList){
        Set<Id> assignedToSet = new Set<Id>();
        Map<id,User> userMap;
        for(Task taskInstance : taskList){
            assignedToSet.add(taskInstance.OwnerId);
        }
        Boolean isExternalUser;
        if(assignedToSet != null && assignedToSet.size() > 0){
            userMap = new Map<id,User>([SELECT id,IsExternalUser__c FROM User WHERE id=:assignedToSet]);
        }
        for(Task taskInstance : taskList){
            User user = userMap.get(taskInstance.OwnerId);
            if(user != null){
                isExternalUser = user.IsExternalUser__c;
                if(isExternalUser){
                    taskInstance.AssignedToUserType__c = 'External';
                }else{
                    taskInstance.AssignedToUserType__c = 'Internal';
                }
            }
        }
    
    }
    
    public void updateApplicationId(List<Task> taskList) {
        Map<Id,Task> taskReviewApp = new Map<Id,Task>();
        for(Task task : taskList) {
            if(task.GNT__TaskAction__c == 'Review Application') {
                taskReviewApp.put(task.WhatID,task);
            }
        }
        Map<Id,Review__c> reviews = new Map<Id,Review__c>([Select Id,Application__r.Name,Application__c FROM Review__c where id in: taskReviewApp.keySet()]);
        for(Task taskInstance : taskList) {
            if(taskInstance.GNT__TaskAction__c == 'Review Application') {
                //taskInstance.GNT__ApplicationId__c = reviews.get(taskInstance.WhatId).Application__c;
                //taskInstance.GNT__ApplicationName__c = reviews.get(taskInstance.WhatId).Application__r.Name;
            }
        }
        system.debug('application id: '+ taskList);
        
    }
 
    private void sendNotificationEmail(List<Task>taskList){  
        //Shah CRF: trigger based email notification could be problematic during data migration.
        //It is recommended to send emails using batch process or from controller to prevent accidental large emails.
        System.debug('tasklist----->'+taskList);
        Set<String> emailTemplateNames = new Set<String>();
        Map<Id,String> taskTemplateMap = new Map<Id,String>();
        Map<Id,List<String>>  whatIdToAddressMap = new Map<Id,List<String>>();
        List<Id>taskConfigIds = new List<Id>();
        Map<String,List<Id>> sobjectIdMap = new Map<String,List<Id>>();
        Map<Id,Id> taskConfigId = new Map<Id,Id>();
        for(Task t: taskList){  
            taskConfigIds.add(t.GNT__TaskConfigId__c);
            taskConfigId.put(t.id,t.GNT__TaskConfigId__c);
            System.debug('t----------->>>>>'+t);
            String objectType = '';
            if(t.whatId == null){
                if(t.whoId != null){
                    objectType = String.valueOf(t.whoId.getSobjectType());
                }
            }else{
                objectType = String.valueOf(t.whatId.getSobjectType());
            }
           
            List<Id> idList = sobjectIdMap.get(objectType);
            if(idList == null){
                idList = new List<Id>();
            }       
            idList.add(t.whatId);
            sobjectIdMap.put(objectType,idList);
            List<String>emailIds = whatIdToAddressMap.get(t.whatId);
            if(emailIds == null){
                emailIds = new List<String>();
            }
            emailIds.add(t.AssignedToEmailAddress__c);
            whatIdToAddressMap.put(t.whatId,emailIds);
        }
        
        
        Map<Id,GNT__TaskConfig__c> taskConfigMap = new Map<Id,GNT__TaskConfig__c>([select GNT__PhaseConfig__c,GNT__TaskAction__c,GNT__SendTaskAssignmentNotification__c,GNT__EmailTemplateConfig__r.GNT__EmailTemplateDeveloperName__c
                    from GNT__TaskConfig__c where Id in :taskConfigIds]); 
        for(Task t:taskList){
            GNT__TaskConfig__c taskConfig = taskConfigMap.get(t.GNT__taskConfigId__c);
            if(taskConfig != null){
                if(taskConfig.GNT__SendTaskAssignmentNotification__c && !String.isEmpty(taskConfig.GNT__EmailTemplateConfig__c)){
                    taskTemplateMap.put(t.id,taskConfig.GNT__EmailTemplateConfig__r.GNT__EmailTemplateDeveloperName__c);
                    emailTemplateNames.add(taskConfig.GNT__EmailTemplateConfig__r.GNT__EmailTemplateDeveloperName__c);
                }
            }
        }

        //Shah CRF: email template handling could be handled by a separate reusable framework to avoid code duplication.
        if(emailTemplateNames.size () > 0 ){
            Map<Id,EmailTemplate> emailTemplates = new Map<Id,EmailTemplate> ([select id,htmlValue,body,subject,DeveloperName from EmailTemplate where DeveloperName in:emailTemplateNames ]);
            if( emailTemplates != null && emailTemplates.size () > 0 ){
                Map<String,EmailTemplate> developerNameMap = new Map<String,EmailTemplate>();
                for(EmailTemplate emailTemplate : emailTemplates.values()){
                    developerNameMap.put(emailTemplate.developerName,emailTemplate);
                }
                Map<String,Set<String>> objectFieldsMap = new Map<String,Set<String>>();
                for(Task t: taskList){
                        String objectType = String.valueOf(t.whatId.getSobjectType());
                        EmailTemplate  e = developerNameMap.get(taskTemplateMap.get(t.id));
                        List<String> fields = GNT.AppUtils.getMergeFields(e.htmlvalue);
                        List<String> subjects  =GNT.AppUtils.getMergeFields(e.subject);
                        Set<String> fieldSets = new Set<String>();
                        fieldSets.addAll(fields);
                        fieldSets.addAll(subjects);
                        Set<String> mergeFields=  GNT.AppUtils.getMergeFieldsForTemplate(fieldSets,objectType);
                        set<string> objectFields = objectFieldsMap.get(objectType);
                        if(objectFields == null){
                            objectFields = new Set<String>();
                        }
                        if(mergeFields != null) {
                             objectFields.addAll(mergeFields);
                        }
                       
                        objectFieldsMap.put(objectType,objectFields);
                }
                Map<Id,Sobject> sobjectMap = new Map<Id,Sobject>();
                List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
                for(String objectName : sobjectIdMap.keySet()){
                    List<Id> recordIds = sobjectIdMap.get(objectName );
                    Set<String> objFields = objectFieldsMap.get(objectName );
                    String query = 'select id, ' +GNT.AppUtils.concatenate(objFields ,',')+ ' from ' + objectName+ ' where id in:recordIds';
                    system.debug('Query: '+query);
                    system.debug ('objFields ' + objFields);
                    system.debug('objidmap ' + objectFieldsMap);
                    List<Sobject> sobjects = Database.query(query);
                    for(Sobject s : sobjects){
                        sobjectMap.put(s.id,s);
                    }
                }
                for(task t: taskList){
                        String objectType = String.valueOf(t.whatId.getSobjectType());
                        EmailTemplate  e = developerNameMap.get(taskTemplateMap.get(t.id));
                        String eBody = e.HTMLValue.remove(objectType+'.');
                        String eSubject = e.subject.remove(objectType+'.');
                        string subject = GNT.AppUtils.replaceMergeFieldsForTemplates(eSubject,sobjectMap.get(t.whatId)); 
                        string body = GNT.AppUtils.replaceMergeFieldsForTemplates(eBody,sobjectMap.get(t.whatId));  
                        messages.addAll(GNT.AppUtils.sendTaskNotification(whatIdToAddressMap.get(t.whatId),subject,body,true));
                }
                if (!Test.isRunningTest()) {
                    Messaging.sendEmail( messages );
                }
            }
        }
    }
    
    public void updatePhaseName(List<Task> taskList) {
       
        List<String> taskActions = new List<String>();
        Set<Id> phases = new Set<Id>();
        Map<String,List<Id>> actionPhaseMap = new Map<String,List<Id>>();
       
        for(Task t: taskList){
            taskActions.add(t.GNT__TaskAction__c);
        }
        List<GNT__TaskConfig__c> taskConfig = [select GNT__PhaseConfig__c,GNT__TaskAction__c from GNT__TaskConfig__c where 
                    GNT__TaskAction__c in :taskActions]; 
        for(GNT__TaskConfig__c config : taskConfig){
            List<Id> phaseIds = actionPhaseMap.get(config.GNT__TaskAction__c);
            if(phaseIds == null){
                phaseIds = new List<Id>();
            }
            phaseIds.add(config.GNT__PhaseConfig__c);
            actionPhaseMap.put(config.GNT__TaskAction__c,phaseIds);
            phases.add(config.GNT__PhaseConfig__c);
        }
        Map<Id,GNT__PhaseConfig__c> phaseMap = new Map<Id,GNT__PhaseConfig__c>([select GNT__CustomAppName__c,id,name from GNT__PhaseConfig__c where id in:phases]);
        for(Task task: taskList){
                GNT__UserPreferences__c pref = GNT__UserPreferences__c.getInstance(task.ownerId); 
                System.debug('pref==='+pref);
                String activeAppName = '';
                if(pref != null){
                    System.debug('GNT__CustomAppConfig__c.getValues' + GNT__CustomAppConfig__c.getValues(pref.Id));
                    if(GNT__CustomAppConfig__c.getValues(pref.GNT__ActiveAppName__c) != null){
                        activeAppName = GNT__CustomAppConfig__c.getValues(pref.GNT__ActiveAppName__c).name;
                    }
                    
                }
            List<Id> pIds = new List<Id>();
            pIds = actionPhaseMap.get(task.GNT__TaskAction__c);
            if(pIds!=null){
                for(Id pId :pIds){
                    GNT__PhaseConfig__c phase = phaseMap.get(pId);
                    system.debug('Phase: '+phase);
                    if(phase.GNT__CustomAppName__c.equalsIgnoreCase(activeAppName)){
                        task.GNT__PhaseName__c = phase.name;
                        task.GNT__CustomAppName__c = phase.GNT__CustomAppName__c;
                    }
                }
            } 
        }

    }   
    

    
}