global with sharing class AssignPanelAppAndNotifyReviewersHelper extends GNT.FlexTableActionHandler {
    
    global override Map<String,Object> clickHandler(){
        Map<String,Object> resultMap = new Map<String,Object>();        
        if(selectedRecordIds != null && selectedRecordIds.size() > 0){            
            String ns = AppUtils.getNamespacePrefix(); 
            Id panelId = urlParams.get('panelId');
            String tabName = urlParams.get('tabName');
            Id panelAppId = urlParams.get('id');
                        
            try{
                ReviewPanel__c reviewPanel = [SELECT Id, RecordTypeId, ReviewerAssignNotificationTemplate__c,
                        EndDate__c, TaskDueDate__c, DueDateOffset__c FROM ReviewPanel__c WHERE Id=:panelId];
                PanelApplication__c panelApp = [Select Id, Application__c, PreApplication__c From PanelApplication__c Where Id = :panelAppId];
                
                Id rpAppRecTypeId = Schema.SObjectType.ReviewPanel__c.getRecordTypeInfosByName().get('Application').getRecordTypeId();
                Id rpPreAppRecTypeId = Schema.SObjectType.ReviewPanel__c.getRecordTypeInfosByName().get('Pre-Application').getRecordTypeId();
                
                List<PanelUser__c> panelUserList = [Select id, Reviewer__c From PanelUser__c Where Id IN : selectedRecordIds];
                
                Map<Id, Id> pUserToUserIdMap = new Map<Id, Id>();
                for(PanelUser__c puser : panelUserList){
                    pUserToUserIdMap.put(puser.Id, puser.Reviewer__c);
                }
                
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
                
                List<Review__c> reviewsList = new List<Review__c>();
                for(String selectedId : selectedRecordIds){
                    Review__c review = new Review__c();
                    if(reviewPanel.RecordTypeId == rpAppRecTypeId){
                        review.Application__c = panelApp.Application__c;
                    }else{
                        review.PreApplication__c = panelApp.PreApplication__c;
                    }
                    review.PanelApplication__c = panelApp.Id;
                    review.PanelUser__c = selectedId;            
                    review.ReviewPanel__c = panelId;
                    reviewsList.add(review);
                }
                                                
                if(Schema.sObjectType.Review__c.isCreateable()){
                    Database.saveResult [] saveResult = Database.insert(reviewsList, true);
                    List<Id> reviewIds = new List<Id>();
                    for (Database.SaveResult sr : saveResult ) {
                        reviewIds.add(sr.getId());
                    }
                    
                    Map<Id,Id> targetObjIdToWhatIdMap = new Map<Id,Id>();
                
                    if(reviewIds.size() > 0){
                        Map<Id,Review__c> reviewsMap = new Map<Id,Review__c>([SELECT Id,Name,Status__c,Application__c,PreApplication__c ,
                                                                      Application__r.Title__c,PreApplication__r.Title__c,
                                                                      Application__r.OwnerId,PreApplication__r.OwnerId, OwnerId
                                                                      FROM Review__c WHERE Id IN :reviewIds]);
                
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
                                    // resultMap.put('Message','Applications are sent for review');
                                    resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-42215'));
                                }
                            }
                        }
                    }
                }
            }catch(Exception e){
                throw new GNT.AppUtils.ValidationException(e.getMessage());
            }
            String PageReferenceURL = '/apex/'+ns+'ReviewPanelView?id=' + panelId;
            if(!String.isEmpty(tabName)){
                PageReferenceURL+='&tabName='+tabName;
            }
            resultMap.put('PageReference',PageReferenceURL);
            return resultMap;
        }else{
            //throw new GNT.AppUtils.ValidationException('Please select one or more records');
             throw new GNT.AppUtils.ValidationException(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-85230'));
        }
        return null;
    }
}