global class CloseRelatedTasks implements Database.Batchable<sObject>{
               
     private String query;
     String taskAction = null; 
     global CloseRelatedTasks(String taskAction) {
          this.taskAction = taskAction;
     }
     global CloseRelatedTasks() {}
     
     global Database.QueryLocator start(Database.BatchableContext BC) {
          if(taskAction != null) {
               query = 'Select Id, WhatId, Status, GNT__TaskAction__c, CreatedDate FROM Task Where Status = \'Completed\' And LastModifiedDate = TODAY AND GNT__TaskAction__c ='+'\''+taskAction+'\'';
          }
          else {
               query = 'Select Id, WhatId, Status, GNT__TaskAction__c, CreatedDate FROM Task Where Status = \'Completed\' And LastModifiedDate = TODAY';
          }
          
          return Database.getQueryLocator(query);
     }

     global void execute(Database.BatchableContext BC, List<sObject> scope) {
          Set<Id> completedParentTasks = new Set<Id>();
          Map<Id, Map<String, List<Task>>> taskMap = new Map<Id, Map<String, List<Task>>>();
          for(SObject s : scope) {
               Task t = (Task) s;
               completedParentTasks.add(t.WhatId);
               if(!taskMap.containsKey(t.whatId)) {
                    taskMap.put(t.whatId, new Map<String, List<Task>>());
               }
               if(!taskMap.get(t.whatId).containsKey(t.GNT__TaskAction__c)) {
                    taskMap.get(t.whatId).put(t.GNT__TaskAction__c, new List<Task>());
               }
               taskMap.get(t.whatId).get(t.GNT__TaskAction__c).add(t);
          }

          List<Task> relatedTasks = [Select Id, WhatId, Status, GNT__TaskAction__c, CreatedDate FROM Task WHERE WhatId in : completedParentTasks And (Status = 'In Progress' 
                                                                                                                   OR Status = 'Not Started')];
          if(relatedTasks.size() > 0) {
               for(Task t: relatedTasks) {
                    if(taskMap.get(t.whatId).containsKey(t.GNT__TaskAction__c)) {
                         for(Task t2: taskMap.get(t.whatId).get(t.GNT__TaskAction__c)) {
                              //(t.CreatedDate.getTime() - t2.CreatedDate.getTime())/(1000*60)
                              //Above is equal to difference in minutes between the created time of the two tasks
                              if(Math.abs((t.CreatedDate.getTime() - t2.CreatedDate.getTime())/(1000*5)) <= 1) {
                                   t.Status = 'Completed';
                              }
                         }
                    }
               }  
               update relatedTasks;
          }

     }
     
     global void finish(Database.BatchableContext BC) {
         scheduleMe();           
     }
     
      global static void scheduleMe() {
        CloseRelatedTasks batch = new CloseRelatedTasks();        
        String cronExpression = GNT.BatchApexJobScheduler.prepareJobsSchTime(System.now(), 2); 
        String jobName = GNT.BatchApexJobScheduler.getUniqueJobName('CloseRelatedTasks');  
        if (!Test.isRunningTest()) {
            System.schedule(jobName, cronExpression, new GNT.BatchApexJobScheduler(batch, 1));
        }
    }               
}