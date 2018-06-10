global with sharing class ApplicationReviewHelper extends GNT.FlexTableActionHandler { 

    public ApplicationReviewHelper(){}
    
    Map<String,Object> resultMap = new Map<String, Object>();
    Savepoint sp ;
    global override Map<String,Object> clickHandler(){         
    sp = Database.setSavepoint();    
    String reviewStepId = urlParams.get('id');
    resultMap = createReviewTasks(reviewStepId);    
    return resultMap;
    }

    public Map<String,Object> createReviewTasks(Id reviewStepId)
    {
    Date dueDate;
    try{    
        List<ReviewStepApplication__c> rsaList = [Select Id, Name,Application__c from ReviewStepApplication__c where ReviewStep__c=:reviewStepId ];
        system.debug('---rsaList---'+rsaList);
        List<ReviewStep__c> revStepList = [Select Id,ReviewersCount__c, CountReviewPanels__c,Name,Status__c, StepNumber__c from ReviewStep__c where id=:reviewStepId limit 1];
        system.debug('---revStepList---'+revStepList);
        ReviewStep__c revStep = revStepList[0];
        Integer countReviewer = Integer.valueOf(revStep.ReviewersCount__c);
     
         //if(countReviewer < 1 && revStep.StepNumber__c == 1){
         //   //resultMap.put('Message','The Review Step does not have any Reviewers in the associated Panels.');
         //   resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-17055'));
         //   return resultMap;
         //   }
         if(revStep.status__c == 'In Progress'){
            //resultMap.put('Message','Applications are already under Review.');
            resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-52680'));
            return resultMap;
            }
         if(revStep.status__c == 'Completed'){
            //resultMap.put('Message','Application Review is Completed.');
            resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-32804'));
            return resultMap;
            }   
        system.debug('---countReviewer---'+countReviewer);
        List<PanelApplication__c> panelAppList = new List<PanelApplication__c>();
        List<ReviewPanel__c> revPanelList= [Select Id, ReviewersCount__c,EndDate__c from ReviewPanel__c where ReviewStep__c = :reviewStepId];
        //Check Review Panel has a Review Due Date
          for(ReviewPanel__c revPanel : revPanelList){
             if(revPanel.EndDate__c==null){
                 resultMap.put('PageReference',null);
                 //resultMap.put('Message','Please Enter Review Due Date.');
                 resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-12032'));
                 return resultMap;
              }else if(revPanel.EndDate__c <= Date.today()){
                 resultMap.put('Message','End Date must be a future date');
              }else{
               dueDate = revPanel.EndDate__c;
              }
          }     
        
        // Iterate over this list and create
        // for(ReviewStepApplication__c revStepApp : rsaList){         
        //    system.debug('revStepApp---'+revStepApp);
        //     for(ReviewPanel__c revPanel : revPanelList){
        //         system.debug('revPanel---'+revPanel);
        //         if(revPanel.ReviewersCount__c>0){
        //         PanelApplication__c panelApp = new PanelApplication__c();
        //         panelApp.Application__c=revStepApp.Application__c;
        //         panelApp.ReviewPanel__c=revPanel.Id;
        //         panelAppList.add(panelApp);
        //         }
        //     }
        // }    
       
        //if(revStep.StepNumber__c == 1){
        //  if(panelAppList!=null && panelAppList.size()>0){
        //        insert panelAppList;
        //        revStep.status__c='In Progress';
        //        update revStep; 
        //        system.debug('---panelAppList---'+panelAppList);    
        //  }
        //}else{
          revStep.status__c='In Progress';
          update revStep;
        //}
        /*      
        List<PanelUser__c> puList = [Select Id, Name,ReviewPanel__c, Reviewer__c from PanelUser__c where ReviewPanel__c IN (Select Id from ReviewPanel__c where ReviewStep__c = :reviewStepId)];    
        List<Review__c> reviewsList = new List<Review__c>();
        for( PanelApplication__c panelApp : panelAppList){
            // create reviews for all panel users in the rev panel and all applications in panel applications 
            for(PanelUser__c panelUser : puList){
              if(panelUser.ReviewPanel__c==panelApp.ReviewPanel__c){
                Review__c review = new Review__c();
                review.PanelUser__c=panelUser.Id;
                review.Application__c=panelApp.Application__c;
                review.PanelApplication__c=panelApp.Id;
                review.ReviewPanel__c=panelApp.ReviewPanel__c;
                review.ReviewStep__c=reviewStepId;
                review.Status__c = 'Assigned';
                system.debug('---review---'+review);
                reviewsList.add(review);
                }           
            }  
        } 
        // Create Tasks for Reviewer
                if(Schema.sObjectType.Review__c.isCreateable()){
                        Database.saveResult [] saveResult = Database.insert(reviewsList, true);
                        List<Id> reviewIds = new List<Id>();
                        for (Database.SaveResult sr : saveResult ){
                            reviewIds.add(sr.getId());
                        }
                   
                        Map<Id,Id> targetObjIdToWhatIdMap = new Map<Id,Id>();                
                        if(reviewIds.size() > 0){
                            Map<Id,Review__c> reviewsMap = new Map<Id,Review__c>([SELECT Id,Name,Status__c,Application__c,PreApplication__c ,ReviewStepName__c,
                                                                          Application__r.Title__c,PreApplication__r.Title__c,Application__r.Name, 
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
                                    //taskInstance = GNT.TaskCreationHandler.createTasks(review.OwnerId, review.Id , 'Review Grantor Application', review.Application__r.Title__c, null, false, dueDate, 'Review', false).get(0);
                                    taskInstance = GNT.TaskCreationHandler.createTasks(review.OwnerId, review.Id , 'Application Review', review.Application__r.Name, null, false, dueDate, 'Review', review.ReviewStepName__c, false).get(0);
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
                                system.debug('Task Created ---'+taskList);    
                                // Hardcoded for now
                                String templateName = 'Notify_Reviewer_to_Review_Application';
                                if(!String.isEmpty(templateName)){
                                    List<EmailTemplate> template = [SELECT id, Body FROM EmailTemplate WHERE DeveloperName = :templateName LIMIT 1];
                                     system.debug('-- template ---'+template);
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
                                        system.debug('-- recIdToAddressMap ---'+recIdToAddressMap);
                                        system.debug('-- cont ---'+cont);
                                  //      GNT.AppUtils.sendEmailUsingTemplate(template[0].Id, recIdToAddressMap, cont.Id, false);
                                        resultMap.put('Message','Applications are sent for review');
                                    }
                                }
                            }
                        }     
                    }
                  */  
        PageReference p = Page.ReviewStepView;
          p.getParameters().put('id', reviewStepId);
          p.setRedirect(true);
          resultMap.put('PageReference',p);
          //resultMap.put('Message','The Application Review has been successfully Initiated.');
          resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-79376'));
        return resultMap;
 } catch(Exception e){
            Database.rollback(sp);
            system.debug(LoggingLevel.ERROR,e);
            //resultMap.put('Message','Error in Initiating Review');
            resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-22883'));
            return resultMap;
        }
 PageReference p = Page.ReviewStepView;
      p.getParameters().put('id', reviewStepId);
      p.setRedirect(true);
      resultMap.put('PageReference',p);
      //resultMap.put('Message','The Application Review has been successfully Initiated.');
      resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-79376'));
    return resultMap;
    }
}