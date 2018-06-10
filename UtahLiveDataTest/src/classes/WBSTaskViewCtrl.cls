public  class WBSTaskViewCtrl {
    
    //Properties
    public ID recordId{get;set;}
    public WBSTaskSchedule__c WBSTaskScheduleObj{get;set;}
    
    public WBSTaskViewCtrl ( ){
        recordId = ApexPages.CurrentPage().getParameters().get('id'); 
        system.debug('recordId------>>>>'+recordId);               
    }
    public PageReference redirect(){
    PageReference  p = null;
        if (recordId != null){
            WBSTaskScheduleObj = [SELECT Id,Program__c,Application__c,Award__c from WBSTaskSchedule__c  where id=:recordId];
            System.debug('===WBSTaskScheduleObj==='+WBSTaskScheduleObj);
                if(WBSTaskScheduleObj.Program__c  != null){
                     p = new PageReference('/'+WBSTaskScheduleObj.Program__c);
                     return p;
                }
                else if (WBSTaskScheduleObj.Application__c  != null){
                     p = new PageReference('/'+WBSTaskScheduleObj.Application__c);
                     return p;
                }
                else if(WBSTaskScheduleObj.Award__c  != null){
                     p = new PageReference('/'+WBSTaskScheduleObj.Award__c);
                     return p;
                }
        }
    return p;
        
    }
    
 
   
}