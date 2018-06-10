@isTest
private with sharing class TestSiteVisitTrigger{
    static SiteVisitSchedule__c svs;
    static SiteVisit__c sv;
    @isTest
    private static void testInsert(){
        UserTriggerHelper.skipTrigger=true;
        User u=TestHelper.getAdminUser(true);
        System.runAs(u){
            Test.startTest();
            /*
            Grant__c grant = TestHelper.getGrant(false);
        //grant.Program__c = program.id;
        grant.Status__c = 'Active';
        grant.ProjectPeriodStartDate__c=Date.today();
        grant.NumberofProjectsFunded__c='1';
        insert grant;
        
             ProjectInformation__c proj = new ProjectInformation__c();
             proj.AwardedAmount__c=100;
             proj.Code__c='1234';
             proj.Description__c='test';
             proj.Grant__c=grant.id;
             insert proj;
             
            
            Award__c aw=TestHelper.getAwards(grant.id,true);
            
            RolesAndResponsibilities__c rr = new RolesAndResponsibilities__c();
            rr.Name__c=u.id;
            rr.Role__c='jkl';
            rr.BizRole__c='qq';
            rr.Award__c=aw.id;
            rr.Notify__c=true;
            rr.Responsibility__c='qwwe';
            rr.SiteVisit__c='qws';
            insert rr;
            */
            svs=new SiteVisitSchedule__c(Status__c='In Progress');
            insert svs;
            
            //sv=new SiteVisit__c();
             //sv.Status__c='Approved';
           // insert sv;
           
            //update sv;
            //delete sv;
            Test.stopTest();
            //System.assert(sv.id!=null);
        }
    }
    //@isTest
    //private static void testInsert1(){
    //    UserTriggerHelper.skipTrigger=true;
    //    User u=TestHelper.getStandardPlatformUser(true);
    //    System.runAs(u){
    //        Test.startTest();
    //        svs=new SiteVisitSchedule__c(Status__c='In Progress');
    //        insert svs;
    //        Test.stopTest();
    //    }
    //}
    //@isTest
    //private static void testInsert2(){
    //    UserTriggerHelper.skipTrigger=true;
    //    User u=TestHelper.getStandardUser(true);
    //    System.runAs(u){
    //        Test.startTest();
    //        svs=new SiteVisitSchedule__c(Status__c='In Progress');
    //        insert svs;
    //        Test.stopTest();
    //    }
    //}


}