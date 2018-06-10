/*
     
    **********************************************************
    2/10/2016  Davinder Singh       Created
    **********************************************************  
*/

//Creates Task for Announcement POC to notify non-winners

global with sharing class NotifyNonWinnersHelper extends GNT.FlexTableActionHandler{
    
    global NotifyNonWinnersHelper() {}
      Map<String,Object> resultMap = new Map<String,Object>(); 

     Id revStepId ;
    public override Map<String,Object> clickHandler(){
          
         revStepId = urlParams.get('id');
        
        Savepoint sp = Database.setSavePoint();  
        try {  
         if(selectedRecordIds==null || selectedRecordIds.size()==0)
        {
         resultMap.put('Message','No Applications has been selected.');
                return resultMap;
        
        }
        
         Set<Id> appIds = new Set<Id>();
         
         system.debug('---selectedRecordIds---'+selectedRecordIds);
           
            String ns = AppUtils.getNamespacePrefix(); 
            
            List<ReviewStepApplication__c> revAppList = [Select Id, Name, Application__c from ReviewStepApplication__c where Id IN : selectedRecordIds ];
            
            for(ReviewStepApplication__c rsa : revAppList){
            appIds.add(rsa.Application__c);
            }
            
            system.debug('---appIds---'+appIds);
            
            List<Application__c> appList = [SELECT Id, Name, Announcement__r.PointofContact__c,Title__c FROM Application__c WHERE Id IN : appIds AND status__c NOT IN ('Rejection Initiated', 'Rejected')];
                                            
           System.debug('---appList ---'+appList);
    

            if(appList!=null && appList.size()>0)
            {
            UpdateApplication(appList);
            }
            else
            {
              //resultMap.put('Message','Rejection Notification can not be initiated for selected applications.');
              resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-59867'));
                return resultMap;
            
            }
           
           
        } catch(Exception e) {
            Database.rollBack(sp);
               
        }
        
         //resultMap.put('Message','Rejection Notification has been initiated for selected applications.');
         resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-30368'));
        return resultMap;
    }
    
    private void UpdateApplication(List<Application__c> appList)
    {
               
      List<Application__c> applicationList = new List<Application__c>();
      
      List<Task> announcementTasks = new List<Task>();
      
      for(Application__c app :  applist)
      {
      
      
      
      /*List<Task> notifyNonWinnersTasks = GNT.TaskCreationHandler.createTasks(app.Announcement__r.PointofContact__c,
                                                                    app.Id, 'Notify Announcement NonWinners',
                                                                    app.Name, null, false, null,
                                                                    'Other', false);*/
      List<Task> notifyNonWinnersTasks = GNT.TaskCreationHandler.createTasks(app.Announcement__r.PointofContact__c,
                                                                    app.Id, 'Notify Announcement NonWinners',
                                                                    app.Name, null, false, null,
                                                                    'Other', app.Title__c, false);                                                              
         
             if(notifyNonWinnersTasks != null && notifyNonWinnersTasks .size() > 0) {
                                announcementTasks.add(notifyNonWinnersTasks [0]);
                                
                                
              app.status__c='Rejection Initiated';
                                
              applicationList .add(app);
                                
            }
    
        
         }
   
      
       
       system.debug('announcementTasks: '+announcementTasks);
       if(announcementTasks!=null && announcementTasks.size()>0)
       {
         insert announcementTasks;
         update applicationList ;
       
       }
          
      
    }
}