public with sharing class TaskScheduleGroupViewCtrl {
    
    
    public ID recordId{get;set;}
      
    public TaskScheduleGroupViewCtrl (ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');
        
    }
   
}