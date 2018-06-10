/*
     
    **********************************************************
            1/11/2016  Davinder Singh       Created
    **********************************************************  
*/

//Handles application review readyness
global with sharing class ApplicationReviewCheckHelper extends GNT.DynamicLayoutActionRedirect{    
    global ApplicationReviewCheckHelper() {}
      Map<String,Object> resultMap = new Map<String,Object>(); 

      global override PageReference whenClicked(){
        Boolean revPanelFlag=false;
        Savepoint sp = Database.setSavePoint();  
        try {  
        Id announcementId=ApexPages.CurrentPage().getParameters().get('id');   
        Announcement__c ann = [Select Id, Name, ApplicationsReviewStatus__c,Program__c from Announcement__c where Id =:announcementId Limit 1 ];
        List<ReviewStepTemplate__c> rstList = [SELECT Id,Name,StepNumber__c,NumberOfReviewPanels__c,MultiplePanelsRequired__c FROM ReviewStepTemplate__c WHERE Announcement__c=: ann.id order by StepNumber__c asc];
        if(rstList!=null || rstList.size() > 0){                                    
           ReviewStepTemplate__c firstRST = rstList[0];
           List<ReviewPanelTemplate__c> rptList = [SELECT Id,Name,ReviewersCount__c FROM ReviewPanelTemplate__c WHERE ReviewStepTemplate__c=: firstRST.Id ];
           for(ReviewPanelTemplate__c revPanel : rptList)
              {
              if(revPanel.ReviewersCount__c<1){
                  revPanelFlag=true;
                  break;
                }
              }
              if(revPanelFlag){
              // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Roles Tab -' + firstRST.Name +' does not have Reviewers in all the associated Panels in Application Review Steps.'));
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-24073') +' '+ firstRST.Name +' '+GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-78480')));
             return null;
              }
              else{
              ann.ApplicationsReviewStatus__c='Ready for Review';
              update ann;   
              }
         } 
         else{
              // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'The announcement does not have required Application Review Steps.'));
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-83356')));
              return null;
         }         
        } catch(Exception e) {
            Database.rollBack(sp);               
        }        
         // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Announcement is Ready for Review.'));    
         ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-16413')));       
         return null;
    }
}