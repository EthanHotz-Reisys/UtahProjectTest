@isTest
private with sharing class TestSiteVisitScheduleEditCtrl{
      static ApexPages.StandardController controller;
        private static void setup(){                        
            
            SiteVisitSchedule__c siteVisitSchedule = new SiteVisitSchedule__c();
            siteVisitSchedule.Status__c = 'Finalized';
            insert siteVisitSchedule;
            
            controller = new ApexPages.StandardController(siteVisitSchedule);
            ApexPages.CurrentPage().getParameters().put('id',siteVisitSchedule.id);                      
        }
        
        @isTest
        private static void testAll(){
            user u = TestHelper.getAdminUser(true);
            system.runAs(u){
                Test.startTest();
                setup();
                SiteVisitScheduleEditCtrl ctrl = new SiteVisitScheduleEditCtrl(controller);
              String keyValueMap = ctrl.getKeyValueMap();
                Test.stopTest();
                system.assertNotEquals(keyValueMap,null);
            }
        }
}