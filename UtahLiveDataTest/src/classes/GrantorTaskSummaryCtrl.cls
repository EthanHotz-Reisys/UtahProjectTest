/*
    Class that gets the Task Counts for Assigned Tasks and Unassigned Tasks
    for the logged in User from the ProcessInstanceWorkitem Object
    ***********************************************************
    Audit History
    ***********************************************************
    03/13/2014      Vineeth Shetty             Created
    *********************************************************** 
*/

public with sharing class GrantorTaskSummaryCtrl {
    
    public List<taskSummaryWrapper> assignedTaskSummaryWrapperList {get;set;}
    public List<taskSummaryWrapper> unassignedTaskSummaryWrapperList {get;set;}
    public Integer TotalAssignedTaskCount {get;set;}
    public Integer TotalUnassignedTaskCount {get;set;}
    public taskCountDueDateWrapper taskSummaryByDueDate {get;set;}
    
    public GrantorTaskSummaryCtrl(){
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