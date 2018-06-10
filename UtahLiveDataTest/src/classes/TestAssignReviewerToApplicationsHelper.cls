@isTest
private class TestAssignReviewerToApplicationsHelper{
   
      static testMethod void testclickHandler() {
          UserTriggerHelper.skipTrigger = true;   
          User u = TestHelper.getAdminUser(true); 
        
          System.runAs(u){
              AppUtils.skipStepReviewTrigger = true;
              ApplicationTriggerHelper.skipTrigger = true;
              AnnouncementTriggerHelper.skipTrigger = true;
              PanelUserTriggerHelper.skipAll = true;
              ReviewTriggerHelper.skipTrigger = true;
              List<String> IdSet = new List<String>();
              
              Announcement__c ann = TestHelper.getAnnouncement(true);
              Application__c app = TestHelper.getApplication(ann.Id,true);
              PreApplication__c preApp = Testhelper.getPreApplication(true);
              
           
              ReviewStep__c revStep = TestHelper.getReviewStep(true);
              ReviewPanel__c revPanel = new ReviewPanel__c(ReviewStep__c=revStep.Id);
              insert revPanel;
              
              PanelUser__c panelUser = new Paneluser__c(ReviewPanel__c=revPanel.Id,Reviewer__c=u.Id);
              insert panelUser;
              
              PanelApplication__c panelApp= new PanelApplication__c(ReviewPanel__c=revPanel.Id,Application__c=app.Id, PreApplication__c=preApp.Id);
              insert panelApp;
              IdSet.add(panelApp.Id);
              
              Review__c rev = new Review__c(Application__c = app.Id,PanelApplication__c=panelApp.Id,PanelUser__c=panelUser.Id,ReviewPanel__c=revPanel.Id);
              insert rev;
              
              Test.startTest();
              AssignReviewerToApplicationsHelper ctrl = new AssignReviewerToApplicationsHelper();
              ctrl.selectedRecordIds = IdSet;
              ctrl.urlparams.put('id',panelUser.Id); 
              ctrl.urlparams.put('panelId',revPanel.Id); 
              ctrl.urlparams.put('tabName','Test');
              ctrl.ClickHandler();  
              delete panelUser;
              ctrl.ClickHandler();      
              Test.stopTest();
        }
    
   }
}