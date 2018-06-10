global class ApplicationWBSHelperClass extends GNT.WBSEventHandler {
      global override Map<String,Object> handleEvent(){
        Map<String,Object> retVal = new Map<String,Object>();        
        System.debug('--**keyValueMap --'+keyValueMap );          
        if(keyValueMap.get('eventMethodname') == 'onAfterTaskAdd'){
            retVal =  onAfterTaskAddHandler(keyValueMap);   
        }else if(keyValueMap.get('eventMethodname') == 'onAfterTaskUpdate'){
            retVal =  onAfterTaskUpdateHandler(keyValueMap);   
        }else if(keyValueMap.get('eventMethodname') == 'onAfterTaskDelete'){
            retVal =  onAfterTaskDeleteHandler(keyValueMap);   
        }else if(keyValueMap.get('eventMethodname') == 'onAfterLinkAdd'){
            retVal =  onAfterLinkAddHandler(keyValueMap);   
        }else if(keyValueMap.get('eventMethodname') == 'publishTasks'){
            system.debug('inside publish tasks');
            retVal =  publishTasks(keyValueMap);  
        }     
        return retVal;
    }
    public Map<String,Object> onAfterTaskUpdateHandler(Map<String,Object> keyValueMap){
        Map<String,Object> retVal = new Map<String,Object>(); 
        try{
            WBSTaskSchedule__c wbsTask = new WBSTaskSchedule__c();
            Map<String,Object> item = (Map<String,Object>)keyValueMap.get('item');
            system.debug('item ========'+item );   
            
            Object wbstaskId = item.get('id');
            system.debug('wbstaskId ========'+wbstaskId );
            if(wbstaskId instanceof Id){
                wbsTask.Id = (String)wbstaskId; 
            }else{
                Map<String,Object> idMapper= (Map<String,Object>)keyValueMap.get('idMapper');
                system.debug('idMapper ========'+idMapper );
                system.debug('idMapper ========' +idMapper.get(String.valueOf((Long)wbstaskId)));
                wbsTask.Id = (Id)idMapper.get(String.valueOf((Long)wbstaskId));   
            }  
            
            Boolean isSuccess = true;
            String message = '';
            /*----- Title field -----*/
            system.debug('i(String)item.get(text)======'+(String)item.get('text') );
            if((String)item.get('text') != null){
                wbsTask.Name = (String)item.get('text');
            }else{
                isSuccess = false;
                message += 'Title is a required field.\n';        
            }
            
            /*----- Assigned To field -----*/            
            if((String)item.get('owner') != null){
                wbsTask.OwnerId = (String)item.get('owner');
            }else{
                isSuccess = false;
                message += 'Assigned To is a required field.';        
            }     
            
            wbsTask.Description__c = (String)item.get('description');
            wbsTask.Milestone__c = (Boolean)item.get('milestone'); 
            wbsTask.ProgressIndicator__c = (Integer)item.get('progress');
            wbsTask.Status__c  = (String)item.get('status'); 
            
            /*----- Start date field -----*/
            if((String)item.get('start_date') != null){
                String sDateString = (String)item.get('start_date');  
                wbsTask.StartDate__c = Date.valueOf(sDateString);
            }else{
                isSuccess = false;
                message += 'Start date is a required field.';        
            }
            
            /*----- End date field -----*/
            if((String)item.get('end_date') != null){
                String eDateString = (String)item.get('end_date'); 
                wbsTask.EndDate__c = Date.valueOf(eDateString);
            }else{
                isSuccess = false;
                message += 'End date is a required field.' ;       
            }
            
            if(wbsTask.StartDate__c > wbsTask.EndDate__c){
                isSuccess = false;
                message += 'Start date should be earlier than End date.' ; 
            }
            
            wbsTask.TaskDuration__c = (Integer)item.get('duration');
            
            if(isSuccess == true){
                update wbsTask;
                retVal.put('Success',true);
                retVal.put('WbsTask',wbsTask);
                retVal.put('Id',wbsTask.Id);            
                retVal.put('keyValueMap',keyValueMap); 
            }else{
                retVal.put('Success',false);
                retVal.put('ShowMessage',true);
                retVal.put('Message',message);
            }            
        }catch(Exception e){
            retVal.put('Success',false);
            retVal.put('ShowMessage',true);
            retVal.put('Message',e.getMessage());
        }
        return retVal;
    }
    public Map<String,Object> onAfterTaskDeleteHandler(Map<String,Object> keyValueMap){
        Map<String,Object> retVal = new Map<String,Object>();
        try{
            Map<String,Object> item = (Map<String,Object>)keyValueMap.get('item');
            system.debug('item ========'+item ); 
            
            String wbsid;
            Object wbstaskId = item.get('id');
            system.debug('wbstaskId ========'+wbstaskId );
            if(wbstaskId instanceof Id){
                wbsid = (String)wbstaskId; 
            }else{
                Map<String,Object> idMapper= (Map<String,Object>)keyValueMap.get('idMapper');
                system.debug('idMapper ========'+idMapper );
                system.debug('idMapper ========' +idMapper.get(String.valueOf((Long)wbstaskId)));
                wbsid = (Id)idMapper.get(String.valueOf((Long)wbstaskId));   
            } 
            
            WBSTaskSchedule__c wbsTask = [SELECT Id FROM WBSTaskSchedule__c WHERE Id=:wbsid ];
            delete wbsTask;
            retVal.put('Success',true);
        }catch(Exception e){
            retVal.put('Success',false);
            retVal.put('ShowMessage',true);
            retVal.put('Message',e.getMessage());
        }   
        retVal.put('DeleteSuccess',true);
        return retVal;
    }
    public Map<String,Object> onAfterTaskAddHandler(Map<String,Object> keyValueMap){
        Map<String,Object> retVal = new Map<String,Object>(); 
        WBSTaskSchedule__c wbsTask = new WBSTaskSchedule__c();
        try{
            Map<String,Object> item = (Map<String,Object>)keyValueMap.get('item');
            system.debug('item ========'+item );       
            
            Boolean isSuccess = true;
            String message = '';
            /*----- Title field -----*/
            system.debug('i(String)item.get(text)======'+(String)item.get('text') );
            if((String)item.get('text') != null){
                wbsTask.Name = (String)item.get('text');
            }else{
                isSuccess = false;
                message += 'Title is a required field.\n';        
            }
            
            /*----- Assigned To field -----*/
            
            if((String)item.get('owner') != null){
                wbsTask.OwnerId = (String)item.get('owner');
            }else{
                isSuccess = false;
                message += 'Assigned To is a required field.';        
            }
            
            wbsTask.WBSNumber__c = (String)item.get('wbsno');
            wbsTask.Description__c = (String)item.get('description');            
            wbsTask.Milestone__c = (Boolean)item.get('milestone') == null ? false : (Boolean)item.get('milestone'); 
            wbsTask.ProgressIndicator__c = (Integer)item.get('progress');
            wbsTask.Status__c  = (String)item.get('status');   
            
            
            /*----- Start date field -----*/
            if((String)item.get('start_date') != null){
                String sDateString = (String)item.get('start_date');  
                wbsTask.StartDate__c = Date.valueOf(sDateString);
            }else{
                isSuccess = false;
                message += 'Start date is a required field.';        
            }
            
            /*----- End date field -----*/
            if((String)item.get('end_date') != null){
                String eDateString = (String)item.get('end_date'); 
                wbsTask.EndDate__c = Date.valueOf(eDateString);
            }else{
                isSuccess = false;
                message += 'End date is a required field.' ;       
            }
            
            if(wbsTask.StartDate__c > wbsTask.EndDate__c){
                isSuccess = false;
                message += 'Start date should be earlier than End date.' ; 
            }
            wbsTask.TaskDuration__c = (Integer)item.get('duration');
            Map<String,Object> paramMap = (Map<String,Object>)System.JSON.deserializeUntyped((String)keyValueMap.get('paramtersMap'));
            String applicationId=(String)paramMap.get('applicationid');
            wbsTask.Application__c=applicationId;
            system.debug('**item.gprent----*'+item.get('parent'));
            if(item.get('parent') != 0){
                Map<String,Object> idMapper= (Map<String,Object>)keyValueMap.get('idMapper');
                String parentId = (String)item.get('parent');
                system.debug('**idMapper======>>>>'+idMapper);
                system.debug('(Id)idMapper.get(parentId)------>>>>'+(Id)idMapper.get(parentId));
                if((Id)idMapper.get(parentId) == null){
                    wbsTask.ParentWBSTaskSchedule__c = parentId;
                }else{
                    wbsTask.ParentWBSTaskSchedule__c = (Id)idMapper.get(parentId);
                }
            }
        
            if(isSuccess == true){
                insert wbsTask;
                retVal.put('Success',true);
                retVal.put('WbsTask',wbsTask);            
                retVal.put('Id',wbsTask.Id);
                retVal.put('applicationId',applicationId);
                retVal.put('keyValueMap',keyValueMap);
            }else{
                retVal.put('Success',false);
                retVal.put('ShowMessage',true);
                retVal.put('Message',message);
            }           
        } catch(Exception e){
            retVal.put('Success',false);
            retVal.put('ShowMessage',true);
            retVal.put('Message',e.getMessage());
        }           
        return retVal;  
    }
    public Map<String,Object> onAfterLinkAddHandler(Map<String,Object> keyValueMap){
        Map<String,Object> retVal = new Map<String,Object>(); 
        Map<String,Object> idMapper = (Map<String,Object>)keyValueMap.get('idMapper');
        Map<String,Object> item = (Map<String,Object>)keyValueMap.get('item');
        System.debug('---source --'+(String)item.get('source'));
        System.debug('---target --'+(String)item.get('target'));
        WBSTaskScheduleLink__c wbsLink = new WBSTaskScheduleLink__c();
        String sourceId = (String)item.get('source');
        String targetId = (String)item.get('target');
        System.debug('---213213--'+(String)idMapper.get(sourceId));
        System.debug('---12313--'+(String)idMapper.get(targetId));
        wbsLink.SourceTask__c = (String)idMapper.get(sourceId) == null ? sourceId : (String)idMapper.get(sourceId);
        wbsLink.TargetTask__c = (String)idMapper.get(targetId) == null ? targetId : (String)idMapper.get(targetId);
        wbsLink.Type__c = (String)item.get('type');
        insert wbsLink;
        retVal.put('WbsLink',wbsLink); 
        retVal.put('Id',wbsLink.Id);
        return retVal; 
    }
    public Map<String,Object> publishTasks(Map<String,Object> keyValueMap){
        Map<String,Object> retVal = new Map<String,Object>(); 
 
        Savepoint sp = Database.setSavepoint();
        Set<Id> userIds = new Set<Id>();
        List<GNT.TaskCreationHandler.TaskBulkClass> tasksList = new List<GNT.TaskCreationHandler.TaskBulkClass>();
        System.debug('---UserInfo----'+UserInfo.getuserId());
        for(List<WBSTaskSchedule__c> wbsTasks : [SELECT Id,Name,Status__c,OwnerId,StartDate__c,EndDate__c,Application__c,Milestone__c 
                                                    FROM WBSTaskSchedule__c  
                                                        WHERE CreatedbyId =: UserInfo.getuserId() AND Status__c = 'Created' AND Milestone__c = true]){
           System.debug('---wbsTasks--'+wbsTasks);
            for(WBSTaskSchedule__c wbs: wbsTasks){
                wbs.Status__c = 'Assigned'; 
                GNT.TaskCreationHandler.TaskBulkClass task = new GNT.TaskCreationHandler.TaskBulkClass();
                task.ownerUserId = wbs.OwnerId;
                task.recordId = wbs.Application__c;
              
                task.action = 'Application Wbs Publish';
                task.recordName = wbs.Name;
                task.startDate = wbs.StartDate__c;
                task.dueDate = wbs.EndDate__c;
                task.subject ='Publish WBS task';
                userIds.add(wbs.OwnerId);                   
                tasksList.add(task);
            }
            update  wbsTasks;  
            System.debug('---tasksList--'+tasksList);
            System.debug('---wbsTasks--'+wbsTasks);
            
        }  
        List<Task> insertedTaskList = GNT.TaskCreationHandler.createBulkTasks(tasksList,true); 
        System.debug('---insertedTaskList --'+insertedTaskList );
        if(insertedTaskList.size() > 0){
            System.debug('userIds----------------------->' + userIds);
            List<EmailTemplate> etList = [SELECT DeveloperName,Id,Name FROM EmailTemplate WHERE DeveloperName = 'WBSTaskCreated'];          
            Map<Id, String[]> recIdToAddressMap = new Map<Id, String[]> ();
            Map<Id,User> userMap = new Map<Id,User>([SELECT Id,Email FROM User WHERE Id =:userIds]);
            for(Task t : insertedTaskList){
                List<String> toAddress = new List<String>();
                User u = userMap.get(t.OwnerId);
                toAddress.add(u.Email);
                recIdToAddressMap.put(t.WhatId,toAddress);
            }   
            Contact contact = new Contact(Firstname='FirstName', Lastname='LastName',Email='email@email.com', Title='Title',Phone ='123-123-1234');
            insert contact;
            GNT.AppUtils.sendEmailUsingTemplate(etList[0].Id, recIdToAddressMap, contact.Id, false);
            delete contact;
            retVal.put('Success',true);
            retVal.put('Refresh',true);
            retVal.put('Message','Success');
            retVal.put('ShowMessage',true);
        }else{
            Database.rollback(sp);
            retVal.put('Success',false);
            retVal.put('Message','All milestone tasks created by you have been assigned. Please add one new milestone task');
            retVal.put('ShowMessage',true); 
        }                    
 
        return retVal; 
    }
}