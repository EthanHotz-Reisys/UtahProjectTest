public with sharing class TaskDueDateFlexTableCtrl {
    public string getListParams(){
        Map<String,List<String>> listParams = new Map<String,List<String>>();
        String flexTableName = ApexPages.currentPage().getParameters().get('flexTableName');
        GNT__UserPreferences__c pref = GNT__UserPreferences__c.getInstance(); 
        String activeAppName = GNT__CustomAppConfig__c.getValues(pref.GNT__ActiveAppName__c).name;
        List<GNT__CustomAppPhaseConfig__c> customPhase = GNT__CustomAppPhaseConfig__c.getall().values();
        Map<String,Integer> phaseNames = new Map<String,Integer>();
        Map<String,String> phaseLabel = new Map<String,String>(); 
        List<String> phasesList = new List<String>();
        BusinessHours  bh = [SELECT Id FROM BusinessHours WHERE IsDefault = true];
        List<Id>taskIds = new List<Id>();
        for(GNT__CustomAppPhaseConfig__c phase: customPhase){
            if(phase.GNT__CustomAppName__c == activeAppName && phase.GNT__isPhase__c && phase.GNT__Active__c){
                phasesList.add(phase.name);
            }   
        }
        system.debug('Phases List####'+phasesList);
        List<Task> tasks = [select Id,ActivityDate  from Task where status in ('Not Started','In Progress') 
            and ownerId =: UserInfo.getUserId() and GNT__PhaseName__c in :phasesList and GNT__LateTasks__c = false];
            system.debug('Tasks$$$'+tasks);
        if(flexTableName.equalsIgnoreCase('TasksDueInSevenDays')){
           for(Task t: tasks){
                Datetime activityDateTime = datetime.newInstance(t.ActivityDate.year(), t.ActivityDate.month(),t.ActivityDate.day());
                Datetime businessDateTime = BusinessHours.add(bh.id,activityDateTime , -(Long)(1000L*60*60*168));             
                date d = date.newinstance(businessDateTime .year(), businessDateTime .month(), businessDateTime .day());
                system.debug('Activity Date: '+t.ActivityDate);
                system.debug('d:'+d);
                if(system.today() > d && system.today() <=t.ActivityDate){
                    taskIds.add(t.id);
                }
            }
        }else if(flexTableName.equalsIgnoreCase('TasksDueInThirtyDays')){
             for(Task t: tasks){
                Datetime activityDateTime = datetime.newInstance(t.ActivityDate.year(), t.ActivityDate.month(),t.ActivityDate.day());
                Datetime businessDateTime = BusinessHours.add(bh.id,activityDateTime , -(Long)(1000L*60*60*720));             
                date d = date.newinstance(businessDateTime .year(), businessDateTime .month(), businessDateTime .day());
                Datetime businessDateTimeToday = BusinessHours.add(bh.id,system.now(), (Long)(1000L*60*60*168));             
                date dToday = date.newinstance(businessDateTimeToday .year(), businessDateTimeToday .month(), businessDateTimeToday .day());
                if(dToday  >= d && dToday <=t.ActivityDate){
                    taskIds.add(t.id);
                }
            }
        }else if(flexTableName.equalsIgnoreCase('TasksAllOthers')){
             for(Task t: tasks){
                    Datetime activityDateTime = datetime.newInstance(t.ActivityDate.year(), t.ActivityDate.month(),t.ActivityDate.day());
                    Datetime businessDateTime = BusinessHours.add(bh.id,activityDateTime , -(Long)(1000L*60*60*720));             
                    date d = date.newinstance(businessDateTime .year(), businessDateTime .month(), businessDateTime .day());
                    system.debug('Activity Date: '+t.ActivityDate);
                    system.debug('d:'+d);
                    if(system.today() < d){
                         taskIds.add(t.id);
                    }
            }
        }
        
        listParams.put('taskIds',taskIds);
        return JSON.serialize(listParams);
    }

}