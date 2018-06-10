@isTest
private with sharing class TestApplicationServiceAreaTriggerHelper{
    static testMethod void testController() {
          UserTriggerHelper.skipTrigger = true;
          User u = TestHelper.getAdminUser(true);
          System.runAs(u){
              AnnouncementTriggerHelper.skipTrigger=true;
              ApplicationTriggerHelper.skipTrigger = true;
              Announcement__c ann = TestHelper.getAnnouncement(true);
              Application__c app = Testhelper.getApplication(ann.Id,true);
              ServiceArea__c servArea = TestHelper.getServiceArea(true);
              AnnouncementServiceArea__c annServArea = new AnnouncementServiceArea__c();
              annServArea .Announcement__c = ann.Id;
              annServArea .ServiceArea__c = servArea.Id;
              insert annServArea;
              List<BudgetCategory__c> budCat = TestHelper.getBudgetCategory(true);
              ApplicationBudgetCategory2__c appBudCat = new ApplicationBudgetCategory2__c(Application__c=app.Id,BudgetCategory__c=budCat[0].Id);
              List<ApplicationBudgetCategory2__c> newLst=new List<ApplicationBudgetCategory2__c>();
              newLst.add(appBudCat);
              insert newLst;
              //insert appBudCat;
              ApplicationServiceArea__c appServArea= new ApplicationServiceArea__c ();
              appServArea .Application__c= app.Id;
              appServArea .ServiceArea__c = annServArea.Id;
              List<ApplicationServiceArea__c> newLst1=new List<ApplicationServiceArea__c>();
              newLst1.add(appServArea);
              insert newLst1;
              delete newLst1;
              
             
              
         }
        
    }
}