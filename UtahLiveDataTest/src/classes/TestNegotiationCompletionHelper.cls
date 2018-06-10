@isTest
private class TestNegotiationCompletionHelper{
   
      static testMethod void testclickHandler() {  
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
              IdSet.add(app.Id);
              
            ChangeRequest__c changeReq = new ChangeRequest__c(Application__c=app.Id,Status__c='Approved');
             // ChangeRequest__c changeReq = new ChangeRequest__c(Status__c='Approved');
              insert changeReq;
          
              Test.startTest();
              NegotiationCompletionHelper nch = new NegotiationCompletionHelper();
              nch.urlparams.put('id',app.Id);
              nch.selectedRecordIds = IdSet;
              nch.ClickHandler();
              Test.stopTest();
        }
    
   }
   
    static testMethod void testclickHandler2() {  
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
              
              IdSet.add(app.Id);
              
              //ChangeRequest__c changeReq = new ChangeRequest__c(Status__c='Approved');
              ChangeRequest__c changeReq = new ChangeRequest__c(Application__c=app.Id,Status__c='Approved');
              insert changeReq;
          
              Test.startTest();
              NegotiationCompletionHelper nch = new NegotiationCompletionHelper();
              nch.urlparams.put('id',app.Id);
              nch.selectedRecordIds = IdSet;
              nch.ClickHandler();
              ann.ApplicationswithNegotiationCompleted__c=1;
              update ann;
              nch.ClickHandler();
              Test.stopTest();
        }
    
   }
   
     static testMethod void testclickHandler3() {  
          User u = TestHelper.getAdminUser(true); 
        
          System.runAs(u){
              AppUtils.skipStepReviewTrigger = true;
              ProgramTriggerHelper.skipTrigger=true;
              AnnouncementTriggerHelper.skipTrigger=true;
              ApplicationTriggerHelper.skipTrigger=true;
              ApplicationTriggerHelper.skipTrigger = true;
              List<String> IdSet = new List<String>();
            
              Announcement__c ann = TestHelper.getAnnouncement(true);
              ann.ApplicationswithNegotiationCompleted__c=null;
              update ann;
              Application__c app = TestHelper.getApplication(ann.Id,true);
              IdSet.add(app.Id);
              
              ChangeRequest__c changeReq = new ChangeRequest__c(Application__c=app.Id,Status__c='Submitted');
              insert changeReq;
          
              Test.startTest();
              NegotiationCompletionHelper nch = new NegotiationCompletionHelper();
              nch.urlparams.put('id',app.Id);
              nch.selectedRecordIds = IdSet;
              nch.ClickHandler();
              ann.ApplicationswithNegotiationCompleted__c=1;
              update ann;
              nch.ClickHandler();
              Test.stopTest();
        }
    
   }
   
       static testMethod void testclickHandler4() {  
          User u = TestHelper.getAdminUser(true); 
        
          System.runAs(u){
              AppUtils.skipStepReviewTrigger = true;
              ProgramTriggerHelper.skipTrigger=true;
              AnnouncementTriggerHelper.skipTrigger=true;
              ApplicationTriggerHelper.skipTrigger=true;
              ApplicationTriggerHelper.skipTrigger = true;
              List<String> IdSet = new List<String>();
            
              Announcement__c ann = TestHelper.getAnnouncement(true);
             // Application__c app = TestHelper.getApplication(ann.Id,false);
             Application__c app = TestHelper.getApplication(ann.Id,true);
              IdSet.add(app.Id);

              ChangeRequest__c changeReq = new ChangeRequest__c(Application__c=app.Id,Status__c='Submitted');
              insert changeReq;
          
              Test.startTest();
              NegotiationCompletionHelper nch = new NegotiationCompletionHelper();
              nch.urlparams.put('id',app.Id);
              nch.selectedRecordIds = IdSet;
              nch.ClickHandler();
              Test.stopTest();
        }
    
   }
}