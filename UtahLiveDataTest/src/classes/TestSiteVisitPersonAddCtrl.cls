@isTest
private with sharing class  TestSiteVisitPersonAddCtrl {
      
     @isTest
    public static void testExternalLinksConfigLayoutEditCtrl(){
        UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
           AnnouncementTriggerHelper.skipTrigger=true;
           RolesAndResponsibilitiesTriggerHelper.skipTrigger=true;
           GrantTriggerHelper.skipTrigger=true;
           AwardTriggerHelper.skipTrigger=true;
           SiteVisitTriggerHelper.skipTrigger=true;

        System.runAs(u){
            Test.startTest();
            Announcement__c ann = TestHelper.getAnnouncement(true); 
            SiteVisitSchedule__c sitesch= TestHelper.getSiteVisitSchedule(true); 
             
           
            Grant__c grant = TestHelper.getGrant(false);
           grant.Status__c = 'Active';
           grant.ProjectPeriodStartDate__c=Date.today();
            grant.GrantAbbreviation__c='12345';
            
            
            //Grant__c grant = TestHelper.getGrant(false);
        //grant.Program__c = program.id;
        //grant.Status__c = 'Active';
       // grant.ProjectPeriodStartDate__c=Date.today();
      //  grant.NumberofProjectsFunded__c='1';
        insert grant;
            //insert grant;  
        Award__c award = TestHelper.getAwards(grant.Id,true);    
            SiteVisit__c site =TestHelper.getSiteVisit(false);
            site.Grant__c=grant.Id;
            site.VisitEndDateTime__c=DateTime.now();
           
            insert site;
            
           
           
            ApexPages.CurrentPage().getParameters().put('id', award.Id);
            ApexPages.CurrentPage().getParameters().put('siteVisitId', site.Id);
            ApexPages.CurrentPage().getParameters().put('userType', 'Internal');
            //ApexPages.CurrentPage().getParameters().put('orgId', 'wert3445555');
            SiteVisitPersonAddCtrl ctrl = new SiteVisitPersonAddCtrl();
            ctrl.getKeyValueMap();
            Test.stopTest();
        }
    }
}