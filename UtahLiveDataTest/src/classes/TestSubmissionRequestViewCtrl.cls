@isTest
private class TestSubmissionRequestViewCtrl{
   
      static testMethod void testController() {  
          UserTriggerHelper.skipTrigger=true;
          User u = TestHelper.getAdminUser(true); 
        
          System.runAs(u){

              AnnouncementTriggerHelper.skipTrigger = true;
              ApplicationTriggerHelper.skipTrigger = true;
              Announcement__c ann = TestHelper.getAnnouncement(true);
              Application__c app = TestHelper.getApplication(ann.Id,true);
             
              
              ChangeRequest__c changeReq = new ChangeRequest__c(Application__c=app.Id,Status__c='Approved');
              insert changeReq;
          
              Test.startTest();
              ApexPages.StandardController sc = new ApexPages.standardController(changeReq);
              ApexPages.CurrentPage().getParameters().put('id',changeReq.Id);
       
              SubmissionRequestViewCtrl ctrl= new SubmissionRequestViewCtrl(sc);
              ctrl.savePage= new PageReference('myPage.TestPage');
              Test.stopTest();
        }
    
   }
   
}