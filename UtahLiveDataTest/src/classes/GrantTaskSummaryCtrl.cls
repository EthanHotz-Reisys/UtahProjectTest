/*
    Class that gets the Task Counts for Assigned Tasks and Unassigned Tasks
    for the logged in User from the ProcessInstanceWorkitem Object
    ***********************************************************
    Audit History
    ***********************************************************
    03/13/2014      Vineeth Shetty             Created
    07/20/2015      Manasi Gangal              Modified
    *********************************************************** 
*/

public with sharing class GrantTaskSummaryCtrl {
    
    public List<taskSummaryWrapper> assignedTaskSummaryWrapperList {get;set;}
    public List<taskSummaryWrapper> unassignedTaskSummaryWrapperList {get;set;}
    public Integer TotalAssignedTaskCount {get;set;}
    public Integer TotalUnassignedTaskCount {get;set;}
    public taskCountDueDateWrapper taskSummaryByDueDate {get;set;}
    
    public GrantTaskSummaryCtrl(){
        taskSummaryByDueDate = new taskCountDueDateWrapper();
        initializeTaskCount();
    }
    
    //Get User Type
    public String getUserType(){
        return UserInfo.getUserType();
    }
    
    /* Method gets the Task Count from Task Summary Hirarchy Custom Setting for User(Assigned) and Profile(Unassigned) tasks
    */
    public void initializeTaskCount(){
        
        assignedTaskSummaryWrapperList = new List<taskSummaryWrapper>();
        unassignedTaskSummaryWrapperList = new List<taskSummaryWrapper>();
        TotalAssignedTaskCount = 0;
        TotalUnassignedTaskCount = 0;
        Integer countString = 0,unassignedCountString = 0;
        String flexTableName = GNT.KeyValueStoreHelper.getTextValue('TaskDisplayFlexTable',true);
      
        GNT__UserPreferences__c pref = GNT__UserPreferences__c.getInstance(); 
        String activeAppName = GNT__CustomAppConfig__c.getValues(pref.GNT__ActiveAppName__c).name;
        List<GNT__CustomAppPhaseConfig__c> customPhase = GNT__CustomAppPhaseConfig__c.getall().values();
        Map<String,Integer> phaseNames = new Map<String,Integer>();
        Map<String,String> phaseLabel = new Map<String,String>(); 
        List<String> phasesList = new List<String>();
        for(GNT__CustomAppPhaseConfig__c phase: customPhase){
            if(phase.GNT__CustomAppName__c == activeAppName && phase.GNT__isPhase__c && phase.GNT__Active__c){
                phaseNames.put(phase.name.toLowerCase(),Integer.valueOF(phase.GNT__Sequence__c));
                phaseLabel.put(phase.name.toLowerCase(),phase.GNT__TabName__c);
                phasesList.add(phase.name);
            }
            
        }
        AggregateResult[] groupedTasks = [select count(id) taskCount,   GNT__PhaseName__c from Task where status in ('Not Started','In Progress') 
            and ownerId =: UserInfo.getUserId() and     GNT__PhaseName__c in :phasesList group by    GNT__PhaseName__c];
        Map<String,Integer> phaseCountMap = new Map<String,Integer> ();
               
        for(AggregateResult grpTasks  : groupedTasks){
                countString = 0;
                Object phaseName = grpTasks.get(AppUtils.getNamespacePrefix()+'PhaseName__c');
                if(phaseName != null)
                phaseCountMap.put(String.valueOf(phaseName).toLowerCase(),(Integer)grpTasks.get('taskCount'));
               
        }
        
        assignedTaskSummaryWrapperList = new List<taskSummaryWrapper>();
        system.debug('phaseCountMap========'+phaseCountMap);
        system.debug('PhaseNames---'+phaseNames);
        for(String phase :phaseNames.keyset()){
            taskSummaryWrapper taskSummaryWrapper = new taskSummaryWrapper();
            SYSTEM.DEBUG('phaseCountMap.get(phase.toLowerCase())==='+phaseCountMap.get(phase.toLowerCase()));
            
            if(!phaseCountMap.containsKey(phase.toLowerCase())){
                taskSummaryWrapper.taskCount = 0;
            }else{
                taskSummaryWrapper.taskCount =phaseCountMap.get(phase.toLowerCase());
            } 
            taskSummaryWrapper.taskLabel = phaseLabel.get(phase.toLowerCase());
            taskSummaryWrapper.actionUrl = 'FlexTableView?flexTableName='+flexTableName+'&phaseName='+phase;
            taskSummaryWrapper.sequence = phaseNames.get(phase.toLowerCase());
            if(phase == 'No Phase associated'){
                taskSummaryWrapper.actionUrl ='#';
                taskSummaryWrapper.sequence = 99;
            }
            assignedTaskSummaryWrapperList.add(taskSummaryWrapper); 
        }
        //phaseNames
        assignedTaskSummaryWrapperList.sort();
        List<Task> dueDateTaskList = [Select GNT__LateTasks__c, DueInSevenDaysTasks__c, DueInThirtyDaysTasks__c, DueComingMonthsTasks__c
                                        From Task Where OwnerId = :UserInfo.getUserId() AND GNT__phaseName__c in :phasesList and Status IN ('Not Started','In Progress') LIMIT :GNT.AppUtils.SOQL_LIMIT];
                                        
        for(Task dueDateTaskInstance :dueDateTaskList){
            if(dueDateTaskInstance.GNT__LateTasks__c == true){
                taskSummaryByDueDate.lateTaskCount++;
            }
            if(dueDateTaskInstance.DueInSevenDaysTasks__c == true){
                taskSummaryByDueDate.dueSevenDaysTaskCount++;
            }
            if(dueDateTaskInstance.DueInThirtyDaysTasks__c == true){
                taskSummaryByDueDate.dueThirtyDaysTaskCount++;
            }
            if(dueDateTaskInstance.DueComingMonthsTasks__c == true){
                taskSummaryByDueDate.OtherTaskCount++;
            }
        }
        
        
    }
    
    public class taskSummaryWrapper implements Comparable{
        public Integer taskCount {get;set;}
        public String taskLabel {get;set;}
        public String actionUrl {get;set;}
        public Decimal sequence {get;set;}
        
        public taskSummaryWrapper(){
            taskCount = 0;
        }
        
        public Integer compareTo(Object compareTo){
            taskSummaryWrapper compareToTaskSummary = (taskSummaryWrapper)compareTo;
            if(sequence == compareToTaskSummary.sequence) return 0;
            if(sequence > compareToTaskSummary.sequence) return 1;
            return -1; 
        } 
    }
    
    public class taskCountDueDateWrapper{
        public Decimal lateTaskCount {get;set;}
        public Decimal dueSevenDaysTaskCount {get;set;}
        public Decimal dueThirtyDaysTaskCount {get;set;}
        public Decimal OtherTaskCount {get;set;}
        
        public String lateTaskUrl {get;set;}
        public String dueSevenDaysUrl {get;set;}
        public String dueThirtyDaysUrl {get;set;}
        public String OtherUrl {get;set;}
        
        public taskCountDueDateWrapper(){
            
            lateTaskCount = 0;
            dueSevenDaysTaskCount = 0;
            dueThirtyDaysTaskCount = 0;
            OtherTaskCount = 0;
            
            lateTaskUrl = GNT.KeyValueStoreHelper.getTextValue('FT_TasksLate', true);
            dueSevenDaysUrl = GNT.KeyValueStoreHelper.getTextValue('FT_TasksDueInSevenDays', true);
            dueThirtyDaysUrl = GNT.KeyValueStoreHelper.getTextValue('FT_TasksDueInThirtyDays', true);
            OtherUrl = GNT.KeyValueStoreHelper.getTextValue('FT_TasksAllOthers', true);
            
        }
    }
    
}