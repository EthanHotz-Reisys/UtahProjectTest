global class BatchGroupTaskMappingCleanup implements Database.Batchable<sObject> {
    String query;
    global BatchGroupTaskMappingCleanup() {}
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([Select Id, Name, ParentRecordId__c From GroupTaskMapping__c 
                                            order by CreatedDate desc]);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
            try{

                Map<String, List<GroupTaskMapping__c>> parentMap = new Map<String, List<GroupTaskMapping__c>>();  //key->parent id
                Map<String, GroupTaskMapping__c> taskMap = new Map<String, GroupTaskMapping__c>(); 
                for(Sobject s : scope){
                    GroupTaskMapping__c gtm = (GroupTaskMapping__c)s;
                    taskMap.put(gtm.Name, gtm);
                    List<GroupTaskMapping__c> innerList = parentMap.get(gtm.ParentRecordId__c);
                    if (innerList == null) {
                        innerList = new List<GroupTaskMapping__c>();
                    }
                    innerList.add(gtm);
                    parentMap.put(gtm.ParentRecordId__c, innerList);
                }

                //Find the tasks records those are in completed status
                List<GroupTaskMapping__c> grpTaskListToDelete = new List<GroupTaskMapping__c>();
                List<Task> tasksToDelete = new List<Task>();
                List<Task> completedTasks = [Select Id From Task Where Id in :taskMap.keySet() and Status = 'Completed'];
                for(Task task : completedTasks ){
                    GroupTaskMapping__c grpTaskMapping = taskMap.get(task.Id);
                    if (grpTaskMapping != null) {
                        List<GroupTaskMapping__c> taskList = parentMap.get(grpTaskMapping.ParentRecordId__c);
                        if (taskList != null) {
                            for (GroupTaskMapping__c tm : taskList) {
                                if (tm.Id != grpTaskMapping.Id) {
                                    tasksToDelete.add(new Task(Id=tm.Name));
                                }
                                grpTaskListToDelete.add(tm);    
                            }
                        }
                    }
                }

                delete tasksToDelete;

                delete grpTaskListToDelete;

            //Reschedule the current job to run again after 5 mins
            //BatchApexJobScheduler.abortObsoleteScheduledJobEntries(null);
            //scheduleJob();
        }
        catch (Exception e) {
            //GNT.AppUtils.notifyTechSupport(e);
            System.debug('exception: ' + e);
            //TODO: notify admin
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
}