global with sharing class SendForReviewFromPanelHelper extends GNT.FlexTableActionHandler {
    
    global override Map<String,Object> clickHandler(){
        Savepoint sp = Database.setSavepoint();
        Map<String,Object> resultMap = new Map<String,Object>();
        try{
            String panelId = urlParams.get('id');
            Map<Id,Id> targetObjIdToWhatIdMap = new Map<Id,Id>();
            
            ReviewPanel__c reviewPanel = [SELECT Id, RecordTypeId, ReviewerAssignNotificationTemplate__c,
                        EndDate__c, TaskDueDate__c, DueDateOffset__c FROM ReviewPanel__c WHERE Id=:panelId];
                        
            Date dueDate;
            if(!String.isEmpty(reviewPanel.TaskDueDate__c) && reviewPanel.TaskDueDate__c == 'Today + Offset Days'){
                if(reviewPanel.DueDateOffset__c != null){
                    dueDate = Date.today();
                    dueDate = dueDate.addDays(Integer.valueOf(reviewPanel.DueDateOffset__c));
                }
            }else{
                if(reviewPanel.EndDate__c != null){
                    dueDate = reviewPanel.EndDate__c;
                }
            }
            
            Map<Id,Review__c> reviewsMap = new Map<Id,Review__c>([SELECT Id,Name,Status__c,Application__c,PreApplication__c ,
                                                          Application__r.Title__c,PreApplication__r.Title__c,OwnerId,Owner.Email,
                                                          Application__r.OwnerId,PreApplication__r.OwnerId
                                                          FROM Review__c WHERE ReviewPanel__c = :panelId AND Status__c = 'Assigned']);

            if(reviewsMap.size() > 0){
                List<Review__c> reviewsToBeUpdatedList = new List<Review__c>();
                List<Task> taskList = new List<Task>();
                Map<Id, List<Sobject>> srcIdToTargetSobjectsMap = new Map<Id, List<Sobject>>();
                for(Review__c review : reviewsMap.values()){
                    review.Status__c = 'Sent for Review';
                    reviewsToBeUpdatedList.add(review);
                    //Create a Task for the Reviewer of the Application
                    Task taskInstance = new Task();   
                    if(review.Application__c != null){                                
                        //taskInstance = GNT.TaskCreationHandler.createTasks(review.OwnerId, review.Id , 'Review Application', review.Application__r.Title__c, null, false, dueDate, 'Review', false).get(0);
                        taskInstance = GNT.TaskCreationHandler.createTasks(review.OwnerId, review.Id , 'Review Application', review.Application__r.Title__c, null, false, dueDate, 'Review', review.Name, false).get(0);
                    }else{                                
                        //taskInstance = GNT.TaskCreationHandler.createTasks(review.OwnerId, review.Id , 'Review Pre-Application', review.PreApplication__r.Title__c, null, false, dueDate, 'Review', false).get(0);
                        taskInstance = GNT.TaskCreationHandler.createTasks(review.OwnerId, review.Id , 'Review Pre-Application', review.PreApplication__r.Title__c, null, false, dueDate, 'Review', review.Name, false).get(0);
                    }
                    system.debug('taskInstance: '+taskInstance);
                    targetObjIdToWhatIdMap.put(review.OwnerId, review.Id);                            
                    List<Task> tasks = srcIdToTargetSobjectsMap.get(review.id);
                    if(tasks == null){
                        tasks = new List<Task>();
                    }
                    if(taskInstance != null){
                        tasks.add(taskInstance);
                    }
                    srcIdToTargetSobjectsMap.put(review.id ,tasks);    
                }
                taskList = GNT.AppUtils.copyRecords(AppUtils.getNamespacePrefix()+'Review__c','Task',srcIdToTargetSobjectsMap,false);                        
                
                if(Schema.sObjectType.Review__c.isUpdateable()){
                    update reviewsToBeUpdatedList ;
                    system.debug('taskList999: '+taskList[0].CreatedById);
                    insert taskList;
                    
                    String templateName = reviewPanel.ReviewerAssignNotificationTemplate__c;
                    if(!String.isEmpty(templateName)){
                        List<EmailTemplate> template = [SELECT id, Body FROM EmailTemplate WHERE DeveloperName = :templateName LIMIT 1];
                        if(template.size() > 0){
                            
                            List<User> userList = [SELECT u.Email FROM User u WHERE u.Id IN :targetObjIdToWhatIdMap.keySet()];
                            Map<Id, String[]> userIdToAddress = new Map<Id, String[]>();
                            for(User userObj : userList){
                                String[] toAddressTemp = userIdToAddress.get(userObj.Id);
                                if(toAddressTemp == null){
                                    toAddressTemp = new String[] {};
                                }
                                toAddressTemp.add(userObj.Email);
                                userIdToAddress.put(userObj.Id, toAddressTemp);
                            }
                            
                            Map<Id, String[]> recIdToAddressMap = new Map<Id, String[]> ();
                            
                            for(Id userId : userIdToAddress.keySet()){
                                Id reviewId = targetObjIdToWhatIdMap.get(userId);
                                recIdToAddressMap.put(reviewId, userIdToAddress.get(userId));
                            }
                            
                            Contact cont = [select id, Email from Contact where email <> null limit 1];
                            
                            AppUtils.sendEmailUsingTemplate(template[0].Id, recIdToAddressMap, cont.Id, false);
                        }
                    }
                    //resultMap.put('Message','Applications are successfully sent for review');  
                    resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-67023'));  
                }
            }else{
                //resultMap.put('Message','Either all the Applications are already sent for review or no Applications are present in the panel for review');  
                resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-67867')); 
            }
        }catch(Exception e){
            resultMap.put('Message',e.getMessage());    
            Database.rollback(sp);
        }
        return resultMap;
    }
}