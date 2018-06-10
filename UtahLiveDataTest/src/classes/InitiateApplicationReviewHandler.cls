global with sharing class InitiateApplicationReviewHandler extends GNT.FlexTableActionHandler { 

    public InitiateApplicationReviewHandler(){}
    
   
    global override Map<String,Object> clickHandler(){ 

        Map<String,Object> resultMap = new Map<String, Object>();
        
          system.debug('selectedRecordIds ----'+selectedRecordIds);
    Savepoint sp = Database.setSavepoint();
     Boolean revPanelFlag=false;
 
    try{
    
    if(selectedRecordIds==null )
    {
       //resultMap.put('Message','Please select the Announcement to Start Review');
       resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-79582'));
       return resultMap;
    
    }
    else{
    
    //1.  Check the Raedy for Review Status
    
    
      Id announcementId=selectedRecordIds[0];   
         Announcement__c ann = [Select Id, Name, ApplicationsReviewStatus__c from Announcement__c where Id =:announcementId Limit 1 ];
        List<ReviewStepTemplate__c> rstList = [SELECT Id,Name,StepNumber__c,NumberOfReviewPanels__c,MultiplePanelsRequired__c FROM ReviewStepTemplate__c WHERE Announcement__c =: announcementId order by StepNumber__c asc];
                                                
         system.debug('---rstList---'+rstList);
     
            if(rstList!=null || rstList.size() > 0){                                    
            
            ReviewStepTemplate__c firstRST = rstList[0];
            
             List<ReviewPanelTemplate__c> rptList = [SELECT Id,Name,ReviewersCount__c FROM ReviewPanelTemplate__c WHERE ReviewStepTemplate__c=: firstRST.Id ];
           
           system.debug('---rptList ---'+rptList);
           
              for(ReviewPanelTemplate__c revPanel : rptList)
              {
              system.debug('---revPanel.ReviewersCount__c---'+revPanel.ReviewersCount__c);     
              if(revPanel.ReviewersCount__c<1)
                  {
                      revPanelFlag=true;
                      break;
                  }
              
              }
              
              
              if(revPanelFlag)
              {
              //resultMap.put('Message',firstRST.Name+' '+' does not have Reviewers in all the associated Panels.');
              resultMap.put('Message',firstRST.Name+' '+GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-87257'));
              return resultMap;              
              }
              
              system.debug('after step 1  ');
    
    // 2. Create Review Groups
    
    ReviewTasksHandler rth=new ReviewTasksHandler(announcementId);
            rth.insertReviewTasks(); 
    
     system.debug('after step 2  ');
    
    //3. assign applications and initiate reviews
    
    ReviewStep__c revStep = [Select Id from ReviewStep__c where ReviewGroup__r.Announcement__c =:announcementId and stepNumber__c =1 limit 1];
          ApplicationReviewHelper arh=new ApplicationReviewHelper();
            arh.createReviewTasks(revStep.Id);      
            
            
             system.debug('after step 3  ');
    }

    
}

} catch(Exception e){
        
            Database.rollback(sp);
                system.debug(e.getMessage());
            resultMap.put('Message','Error message: '+e.getMessage());

            return resultMap;
        }

     //resultMap.put('Message','Review process Initiated for Applications for Selected Announcements');
     resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-50344'));
       return resultMap;
  
    }
    
    
    }