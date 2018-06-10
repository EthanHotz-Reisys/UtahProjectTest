@isTest
private with sharing class TestSiteVisitActivityAddEditCtrl{
    static testMethod void testController() {
          UserTriggerHelper.skipTrigger = true;
          User u = TestHelper.getAdminUser(true);
          
          System.runAs(u){
            GrantTriggerHelper.skipTrigger = true;
            
            SiteVisit__c sv = TestHelper.getSiteVisit(false);
            //Date myDate = Date.newInstance(2016, 11, 18);
            //Time myTime = Time.newInstance(3, 3, 3, 0);
            DateTime dt = DateTime.now();
            sv.VisitEndDateTime__c = dt;
            insert sv;
            
            SiteVisitActivity__c sva = new SiteVisitActivity__c(SiteVisit__c=sv.Id);
            insert sva;
            
            Test.startTest();
            ApexPages.StandardController sc = new ApexPages.standardController(sva);
            ApexPages.currentPage().getParameters().put('Id',sva.id);
            ApexPages.currentPage().getParameters().put('siteVisitId',sv.id);
            ApexPages.CurrentPage().getParameters().put('requestType','External');
            
            SiteVisitActivityAddEditCtrl ctrl = new SiteVisitActivityAddEditCtrl(sc);
            ctrl.resultType = 'Test';
            ctrl.getKeyValueMap();
            Test.stopTest();
            
        }
        
    }
    
        static testMethod void testController2() {
          UserTriggerHelper.skipTrigger = true;
          User u = TestHelper.getAdminUser(true);
          
          System.runAs(u){
            GrantTriggerHelper.skipTrigger = true;
            
            SiteVisit__c sv = TestHelper.getSiteVisit(false);
            //Date myDate = Date.newInstance(2016, 11, 18);
            //Time myTime = Time.newInstance(3, 3, 3, 0);
            DateTime dt = DateTime.now();
            sv.VisitEndDateTime__c = dt;
            insert sv;
            
            SiteVisitActivity__c sva = new SiteVisitActivity__c(SiteVisit__c=sv.Id);
            insert sva;
            
            Test.startTest();
            ApexPages.StandardController sc = new ApexPages.standardController(sva);
            ApexPages.currentPage().getParameters().put('Id',sva.id);
            ApexPages.currentPage().getParameters().put('siteVisitId',sv.id);
            ApexPages.CurrentPage().getParameters().put('requestType','Internal');
            
            SiteVisitActivityAddEditCtrl ctrl = new SiteVisitActivityAddEditCtrl(sc);
            ctrl.getKeyValueMap();
            Test.stopTest();
            
        }
        
    }
}