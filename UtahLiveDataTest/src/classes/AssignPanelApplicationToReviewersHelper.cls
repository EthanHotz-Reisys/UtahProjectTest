global with sharing class AssignPanelApplicationToReviewersHelper extends GNT.FlexTableActionHandler {
    
    global override Map<String,Object> clickHandler(){
        Map<String,Object> resultMap = new Map<String,Object>();
        SavePoint sp = Database.setSavepoint();
        try{
            if(selectedRecordIds.size() > 0){
                String ns = AppUtils.getNamespacePrefix(); 
                Id panelId = urlParams.get('panelId');
                String tabName = urlParams.get('tabName');
                Id panelAppId = urlParams.get('id');
                
                ReviewPanel__c reviewPanel = [SELECT Id, RecordTypeId,TaskDueDate__c,DueDateOffset__c,EndDate__c FROM ReviewPanel__c WHERE Id=:panelId];
                PanelApplication__c panelApp = [Select Id, Application__c, PreApplication__c From PanelApplication__c Where Id = :panelAppId];
                system.debug('reviewPanel: '+reviewPanel);
                system.debug('panelApp: '+panelApp);
                Id rpAppRecTypeId = Schema.SObjectType.ReviewPanel__c.getRecordTypeInfosByName().get('Application').getRecordTypeId();
                Id rpPreAppRecTypeId = Schema.SObjectType.ReviewPanel__c.getRecordTypeInfosByName().get('Pre-Application').getRecordTypeId();
                
                List<PanelUser__c> panelUserList = [Select id, Reviewer__c From PanelUser__c Where Id IN : selectedRecordIds];       
                Map<Id, Id> pUserToUserIdMap = new Map<Id, Id>();
                for(PanelUser__c puser : panelUserList){
                    pUserToUserIdMap.put(puser.Id, puser.Reviewer__c);           
                }
                
                /*Date dueDate;
                if(!String.isEmpty(reviewPanel.TaskDueDate__c) && reviewPanel.TaskDueDate__c == 'Today + Offset Days'){
                    if(reviewPanel.DueDateOffset__c != null){
                        dueDate = Date.today();
                        dueDate = dueDate.addDays(Integer.valueOf(reviewPanel.DueDateOffset__c));
                    }
                }else{
                    if(reviewPanel.EndDate__c != null){
                        dueDate = reviewPanel.EndDate__c;
                    }
                }*/
                Map<Id,Review__c> reviewsMap = new Map<Id,Review__c>([SELECT Id,PanelApplication__c,PanelUser__c 
                                                                            FROM Review__c WHERE ReviewPanel__c =:panelId]);        
                system.debug('reviewsMap: '+reviewsMap);
                Map<String,Review__c> appUserReviewMap = new Map<String,Review__c>();
                for(Review__c rev: reviewsMap.values()){
                    appUserReviewMap.put(rev.PanelApplication__c +''+ rev.PanelUser__c,rev);    
                }   
                system.debug('appUserReviewMap: '+appUserReviewMap);            
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
                    review.Status__c = 'Assigned';  
                    if(appUserReviewMap.get(review.PanelApplication__c+''+review.PanelUser__c) == null){
                        reviewsList.add(review);
                    }
                }    
                system.debug('reviewsList: '+reviewsList);                    
                if(Schema.sObjectType.Review__c.isCreateable()){
                    system.debug('creatable: ');
                    insert reviewsList;
                    /*Database.saveResult [] saveResult = Database.insert(reviewsList, true);
                    List<Id> reviewIds = new List<Id>();
                    for (Database.SaveResult sr : saveResult ) {
                        reviewIds.add(sr.getId());
                    }*/
                    //createTaskForReview(reviewIds,dueDate);
                }
                
                String PageReferenceURL = '/apex/'+ns+'ReviewPanelView?id=' + panelId;
                if(!String.isEmpty(tabName)){
                    PageReferenceURL+='&tabName='+tabName;
                }
                resultMap.put('PageReference',PageReferenceURL);
            }else{
                //resultMap.put('Message','Please select Reviewers to assign to this application');   
                resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-33231'));   
            }
        }catch(Exception e){
            resultMap.put('Message',e.getMessage());    
            Database.rollback(sp);
        }
        return resultMap;
    }
                
        /*private void createTaskForReview(List<Id> reviewIds,Date dueDate){
                Map<Id,Id> targetObjIdToWhatIdMap = new Map<Id,Id>();
                if(reviewIds.size() > 0){
                        Map<Id,Review__c> reviewsMap = new Map<Id,Review__c>([SELECT Id,Name,Status__c,Application__c,PreApplication__c ,
                                                                      Application__r.Title__c,PreApplication__r.Title__c,
                                                                      Application__r.OwnerId,PreApplication__r.OwnerId,ownerId
                                                                      FROM Review__c WHERE Id IN :reviewIds]);
                
                        List<Review__c> reviewsToBeUpdatedList = new List<Review__c>();
                        List<Task> taskList = new List<Task>();
                        Map<Id, List<Sobject>> srcIdToTargetSobjectsMap = new Map<Id, List<Sobject>>();
                        for(Review__c review : reviewsMap.values()){
                            //Create a Task for the Reviewer of the Application
                            Task taskInstance = new Task();                         
                            if(review.Application__c != null){                              
                                taskInstance = GNT.TaskCreationHandler.createTasks(review.ownerId, review.Id , 'Review Application', review.Application__r.Title__c, null, false, dueDate, 'Review', false).get(0);
                            }
                            else{                               
                                taskInstance = GNT.TaskCreationHandler.createTasks(review.ownerId, review.Id , 'Review Pre-Application', review.PreApplication__r.Title__c, null, false, dueDate, 'Review', false).get(0);
                            }
                            targetObjIdToWhatIdMap.put(review.ownerId, review.Id);                          
                           List<Task> tasks = srcIdToTargetSobjectsMap.get(review.id);
                           if(tasks == null){
                                tasks = new List<Task>();
                           }
                           tasks.add(taskInstance);
                           srcIdToTargetSobjectsMap.put(review.id ,tasks);    
                        }
                        taskList = GNT.AppUtils.copyRecords(AppUtils.getNamespacePrefix()+'Review__c','Task',srcIdToTargetSobjectsMap,false);                      
                        insert taskList;
                 }
            }   */ 
}