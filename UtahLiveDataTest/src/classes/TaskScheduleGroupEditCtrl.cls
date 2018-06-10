global with sharing class TaskScheduleGroupEditCtrl extends GNT.MasterCtrl {
    
    //Properties
    public ID recordId{get;set;}
    public PageReference savePage {get;set;}
    
      
    public TaskScheduleGroupEditCtrl (ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');   
    
        savePage = Page.TaskScheduleGroupView;
        savePage.getParameters().put('id', recordId);
        
    }
   
}