global with sharing class AssignAppsAndNotifyReviewerHelper extends GNT.FlexTableActionHandler {
    
    global override Map<String,Object> clickHandler(){
        System.debug('**AssignAppsAndNotifyReviewerHelper**');
        Map<String,Object> resultMap = new Map<String,Object>();        
        if(selectedRecordIds != null && selectedRecordIds.size() > 0){            
            String ns = AppUtils.getNamespacePrefix(); 
            Date dueDate;
            Id panelId = urlParams.get('panelId');
            String tabName = urlParams.get('tabName');
            Id panelUserId = urlParams.get('id');
            Savepoint sp = Database.setSavepoint();                
            try{
                
                ReviewPanel__c reviewPanel = [SELECT Id, RecordTypeId,ReviewStep__c, ReviewerAssignNotificationTemplate__c,
                        EndDate__c, TaskDueDate__c, DueDateOffset__c FROM ReviewPanel__c WHERE Id=:panelId];
                PanelUser__c panelUser = [Select Id, Reviewer__c,Reviewer__r.Email,Reviewer__r.IsExternalUser__c, NoOfApplicationsAssigned__c From PanelUser__c Where Id = :panelUserId];
                
                Id rpAppRecTypeId = Schema.SObjectType.ReviewPanel__c.getRecordTypeInfosByName().get('Application').getRecordTypeId();
                Id rpPreAppRecTypeId = Schema.SObjectType.ReviewPanel__c.getRecordTypeInfosByName().get('Pre-Application').getRecordTypeId();                
                List<PanelApplication__c> panelAppList = [Select id, Application__c,TotalScore__c,NumberOfReviews__c, ReviewPanel__r.ReviewStep__r.ReviewGroup__r.Announcement__r.Program__r.ReviewProcess__c, NoOfReviewersAssigned__c From PanelApplication__c Where Id IN : selectedRecordIds];

                List<Id> oneStepAppIdList = new List<Id>();
                for(PanelApplication__c pa : panelAppList){
                    if(pa.ReviewPanel__r.ReviewStep__r.ReviewGroup__r.Announcement__r.Program__r.ReviewProcess__c == 'One step review'){
                        oneStepAppIdList.add(pa.Application__c);
                    }
                }

                List<Review__c> reviewList = new List<Review__c>([SELECT Id, Application__c, OwnerId, PanelApplication__c, TotalScoreFromSME__c, NumberOfReviews__c,
                                                                PanelUser__c, ReviewPanel__c, Status__c, OneStepReviewCompletionStatus__c,
                                                                ReviewStep__c FROM Review__c WHERE Application__c IN :oneStepAppIdList]);

                Map<Id, Map<Id, Review__c>> appIdMap = new Map<Id, Map<Id, Review__c>>();

                for(Review__c review : reviewList){
                    if(appIdMap.get(review.Application__c) == null){
                        Map<Id, Review__c> reviewIdMap = new Map<Id, Review__c>();
                        reviewIdMap.put(review.OwnerId, review);
                        appIdMap.put(review.Application__c, reviewIdMap);
                    }else{
                        appIdMap.get(review.Application__c).put(review.OwnerId, review);
                    }
                }

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
                Integer numberOfManulReview = 0;
                for(PanelApplication__c pApp : panelAppList){
                    if(pApp.ReviewPanel__r.ReviewStep__r.ReviewGroup__r.Announcement__r.Program__r.ReviewProcess__c == 'One step review' && appIdMap.get(pApp.Application__c) != null && appIdMap.get(pApp.Application__c).get(panelUser.Reviewer__c) != null){
                        Review__c review = appIdMap.get(pApp.Application__c).get(panelUser.Reviewer__c);
                        review.PanelApplication__c = pApp.Id;
                        review.TotalScoreFromSME__c = pApp.TotalScore__c;
                        review.NumberOfReviews__c = pApp.NumberOfReviews__c;
                        review.PanelUser__c = panelUser.Id;
                        review.ReviewPanel__c = panelId;
                        review.Status__c = 'Review In Progress';
                        review.OneStepReviewCompletionStatus__c = 'Application Incomplete';
                        review.ReviewStep__c=reviewPanel.ReviewStep__c;                    
                        reviewsList.add(review);
                        pApp.NoOfReviewersAssigned__c = (pApp.NoOfReviewersAssigned__c == null ? 0 : pApp.NoOfReviewersAssigned__c) + 1;
                        numberOfManulReview++;
                    }else{
                        Review__c review = new Review__c();
                        if(reviewPanel.RecordTypeId == rpAppRecTypeId){
                            review.Application__c = pApp.Application__c;
                        }else{
                            review.PreApplication__c = pApp.PreApplication__c;
                        }
                        review.PanelApplication__c = pApp.Id;
                        review.TotalScoreFromSME__c = pApp.TotalScore__c;
                        review.NumberOfReviews__c = pApp.NumberOfReviews__c;
                        review.PanelUser__c = panelUser.Id;
                        review.ReviewPanel__c = panelId;
                        review.Status__c = 'Assigned';
                        review.ReviewStep__c=reviewPanel.ReviewStep__c;                    
                        reviewsList.add(review);
                    }
                }
                
                update panelAppList;
                panelUser.NoOfApplicationsAssigned__c = (panelUser.NoOfApplicationsAssigned__c == null ? 0 : panelUser.NoOfApplicationsAssigned__c) + numberOfManulReview;
                update panelUser;
                
                if(Schema.sObjectType.Review__c.isCreateable()){
                    upsert reviewsList;
                    Map<Id,Id> targetObjIdToWhatIdMap = new Map<Id,Id>();
                    Map<Id,Review__c> reviewsMap = new Map<Id,Review__c>([SELECT Id,Name,Status__c,ReviewPanel__c,Application__r.GrantorOrganizationName__c,ReviewStepNumber__c,Application__c,PreApplication__c ,ReviewStepName__c,
                                                                  Application__r.Title__c,PreApplication__r.Title__c,OwnerId,Owner.Email,
                                                                  Application__r.OwnerId,PreApplication__r.OwnerId,Application__r.Name,Application__r.ExternalOrganizationName__c
                                                                  FROM Review__c WHERE Id IN :reviewsList]);

                    List<Review__c> reviewsToBeUpdatedList = new List<Review__c>();
                    List<Task> taskList = new List<Task>();

                    Map<Id, List<Sobject>> srcIdToTargetSobjectsMap = new Map<Id, List<Sobject>>();
                    for(Review__c review : reviewsMap.values()){
                        System.debug('**reviewsList124**'+review);
                        review.Status__c = 'Sent for Review';
                        reviewsToBeUpdatedList.add(review);
                        //Create a Task for the Reviewer of the Application
                        Task taskInstance = new Task();   
                        if(review.Application__c != null){
                            system.debug('Reviewer is external ??' +panelUser.Reviewer__r.IsExternalUser__c);
                            //if(panelUser.Reviewer__r.IsExternalUser__c == False){          
                                //taskInstance = GNT.TaskCreationHandler.createTasks(review.OwnerId, review.Id , 'Review Grantor Application', review.Application__r.Title__c, null, false, dueDate, 'Review', false).get(0);
                                if (review.Application__r.GrantorOrganizationName__c =='UOVC')
                                taskInstance = GNT.TaskCreationHandler.createTasks(review.OwnerId, review.Id , 'Application Review', review.Application__r.Name, null, false, dueDate, 'Review', review.ReviewStepName__c + ', ' + review.Application__r.Title__c + ', ' + review.Application__r.ExternalOrganizationName__c, false).get(0);
                                if (review.Application__r.GrantorOrganizationName__c =='USBE')
                                taskInstance = GNT.TaskCreationHandler.createTasks(review.OwnerId, review.Id , 'Application Review USBE', review.Application__r.Name, null, false, dueDate, 'Review', review.ReviewStepName__c + ', ' + review.Application__r.Title__c + ', ' + review.Application__r.ExternalOrganizationName__c, false).get(0);
                                if(review.ReviewStepNumber__c == 2){
                                    new GNT.EmailFeeder().TargetObjectId(review.OwnerId).template('Application_SME_Review').contextRecordId(review.ReviewPanel__c).send();
                                }
                                GNT.EmailFeeder email = new GNT.EmailFeeder().contextRecordId(review.Id).template('Review_Initiated').TargetObjectId(review.OwnerId);
            					GNT.EmailFeeder.SendEmails(new List<GNT.EmailFeeder>{email});
                                
                            //}else{
                            //    taskInstance = GNT.TaskCreationHandler.createTasks(review.OwnerId, review.Id , 'Recipient Application Review', review.Application__r.Name, null, false, dueDate, 'Review', review.ReviewStepName__c, false).get(0);
                            //}
                        }else{  
                            //taskInstance = GNT.TaskCreationHandler.createTasks(review.OwnerId, review.Id , 'Review Pre-Application', review.PreApplication__r.Title__c, null, false, dueDate, 'Review', false).get(0);                              
                            taskInstance = GNT.TaskCreationHandler.createTasks(review.OwnerId, review.Id , 'Review Pre-Application', review.PreApplication__r.Name, null, false, dueDate, 'Review', review.ReviewStepName__c, false).get(0);
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
                     //   update reviewsToBeUpdatedList ;
                        insert taskList;                        
                        //String templateName = reviewPanel.ReviewerAssignNotificationTemplate__c;
                        String templateName = 'Application_SME_Review';
                        if(!String.isEmpty(templateName)){
                            List<EmailTemplate> template = [SELECT id, Body FROM EmailTemplate WHERE DeveloperName = :templateName LIMIT 1];
                            system.debug('template name and body is ' +templateName +'' +template[0].Body+''+template[0].id);
                            if(template.size() > 0){                                
                                List<User> userList = [SELECT u.Email FROM User u WHERE u.Id IN :targetObjIdToWhatIdMap.keySet()];
                                Contact cont = [select id, Email from Contact where email <> null limit 1];
                                Map<Id, String[]> userIdToAddress = new Map<Id, String[]>();
                                Map<Id, String[]> recIdToAddressMap = new Map<Id, String[]> ();
                                /////
                                for(User userObj : userList){
                                    String[] toAddressTemp = userIdToAddress.get(userObj.Id);
                                    if(toAddressTemp == null){
                                        toAddressTemp = new String[] {};
                                    }
                                    toAddressTemp.add(userObj.Email);
                                    userIdToAddress.put(userObj.Id, toAddressTemp);
                                }
                                /////
                                
                                for(Id userId : userIdToAddress.keySet()){
                                    Id reviewId = targetObjIdToWhatIdMap.get(userId);
                                     system.debug('reviewId '+reviewId);   
                                    recIdToAddressMap.put(reviewId, userIdToAddress.get(userId));
                                }
                                //AppUtils.sendEmailUsingTemplate(template[0].Id, recIdToAddressMap, cont.Id,false);
                                /*for(User userObj : userList){
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
                                //resultMap.put('Message','Applications are sent for review');
                                resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-52680'));*/
                            }
                        }
                    }
                }
                
            }catch(Exception e){
                Database.rollback(sp);
                resultMap.put('Message',e.getMessage());
            }
            String PageReferenceURL = '/apex/'+ns+'ReviewPanelView?id=' + panelId;
            if(!String.isEmpty(tabName)){
                PageReferenceURL+='&tabName='+tabName;
            }
            resultMap.put('PageReference',null);
            //resultMap.put('Message','Application successfully assigned to Reviewer.');
            resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-04667'));
            return resultMap;
        }else{
            throw new GNT.AppUtils.ValidationException('Please select one or more records');
        }
        return null;
    }
}