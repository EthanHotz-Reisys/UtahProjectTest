@isTest
private class TestSubmissionRequestEditCtrl{
   
      static testMethod void testController() {  
          UserTriggerHelper.skipTrigger=true;
          User u = TestHelper.getAdminUser(true); 
        
          System.runAs(u){
              AppUtils.skipStepReviewTrigger = true;
              ProgramTriggerHelper.skipTrigger=true;
              AnnouncementTriggerHelper.skipTrigger=true;
              ApplicationTriggerHelper.skipTrigger=true;
              ApplicationTriggerHelper.skipTrigger = true;
              List<String> IdSet = new List<String>();
            
              Announcement__c ann = TestHelper.getAnnouncement(true);
              Application__c app = TestHelper.getApplication(ann.Id,true);
             
              
              ChangeRequest__c changeReq = new ChangeRequest__c(Application__c=app.Id,Status__c='Approved');
              insert changeReq;
          
              Test.startTest();
              ApexPages.StandardController sc = new ApexPages.standardController(changeReq);
              ApexPages.CurrentPage().getParameters().put('id',changeReq.Id);
              ApexPages.CurrentPage().getParameters().put('applicationid',app.Id);    
              SubmissionRequestEditCtrl ctrl= new SubmissionRequestEditCtrl(sc);
              ctrl.getKeyValueMap();
              ApexPages.CurrentPage().getParameters().put('applicationid',null);    
              SubmissionRequestEditCtrl ctrl1= new SubmissionRequestEditCtrl(sc);
              Test.stopTest();
        }
    
   }
   
}