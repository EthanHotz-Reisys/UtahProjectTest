@isTest
public class AwardViewCtrlTest {
    static testMethod void someTest() {
        //Grant__c gr = TestHelper.getGrant(true);
         AnnouncementTriggerHelper.skipTrigger = true;
         ApplicationtriggerHelper.skiptrigger = true;
         RolesandResponsibilitiesTriggerHelper.skipTrigger = true;
         GranttriggerHelper.skipTrigger = true;
         AwardTriggerhelper.skipTrigger = true;
         Grant__c gr = new Grant__c();
         gr.ProjectPeriodStartDate__c=Date.newInstance(2015,3,14);
         gr.ProjectPeriodEndDate__c=Date.newInstance(2016,3,14);
         gr.GrantAbbreviation__c='12345';
         gr.IssueDate__c = Date.newInstance(2014,3,14);
         insert gr;
     
        Announcement__c ann = TestHelper.getAnnouncement(true);
        Application__c app = TestHelper.getApplication(ann.Id,true);
         
        //Award__c aw = TestHelper.getAwards(gr.Id,true);
        Award__c aw  = new Award__c();
        aw.grant__c = gr.Id;
        aw.Name = Math.Random()+'AW12';
        aw.OrganizationName__c = 'Test Org';
        aw.OrganizationAddress__c = 'Test Address';
        aw.FiscalYear__c = '2013';
        aw.SupportYear__c = Decimal.valueOf('2013');
        aw.Status__c = 'Issued';
        aw.Application__c=app.Id;
        insert aw;
                
        TermCondition__c termCond = new TermCondition__c();
        termCond.Award__c= aw.Id;
        termCond.SubmissionType__c='Payment Request';
        insert termCond;
              
        
        ApexPages.StandardController sc = new ApexPages.standardController(gr);        
        ApexPages.currentPage().getParameters().put('Id',aw.id);
        //ApexPages.currentPage().getParameters().put('applicationId',app.Id);
        ApexPages.currentPage().getParameters().put('applicationId',null);
        AwardViewCtrl e = new AwardViewCtrl(sc);
        e.getKeyValueMap();
    }
    
    static testMethod void someTest2() {
        //Grant__c gr = TestHelper.getGrant(true);
         AnnouncementTriggerHelper.skipTrigger = true;
         ApplicationtriggerHelper.skiptrigger = true;
         RolesandResponsibilitiesTriggerHelper.skipTrigger = true;
         GranttriggerHelper.skipTrigger = true;
         AwardTriggerhelper.skipTrigger = true;
         Grant__c gr = new Grant__c();
         gr.ProjectPeriodStartDate__c=Date.newInstance(2015,3,14);
         gr.ProjectPeriodEndDate__c=Date.newInstance(2016,3,14);
         gr.GrantAbbreviation__c='12345';
         gr.IssueDate__c = Date.newInstance(2014,3,14);
         insert gr;
     
        Announcement__c ann = TestHelper.getAnnouncement(true);
        Application__c app = TestHelper.getApplication(ann.Id,true);
         
        //Award__c aw = TestHelper.getAwards(gr.Id,true);
        Award__c aw  = new Award__c();
        aw.grant__c = gr.Id;
        aw.Name = Math.Random()+'AW12';
        aw.OrganizationName__c = 'Test Org';
        aw.OrganizationAddress__c = 'Test Address';
        aw.FiscalYear__c = '2013';
        aw.SupportYear__c = Decimal.valueOf('2013');
        aw.Status__c = 'Issued';
        aw.Application__c=app.Id;
        insert aw;
             
        
        ApexPages.StandardController sc = new ApexPages.standardController(gr);        
        ApexPages.currentPage().getParameters().put('Id',aw.id);
        //ApexPages.currentPage().getParameters().put('applicationId',app.Id);
        ApexPages.currentPage().getParameters().put('applicationId',app.Id);
        AwardViewCtrl e = new AwardViewCtrl(sc);
    }
    
     static testMethod void someTest3() {
        //Grant__c gr = TestHelper.getGrant(true);
         AnnouncementTriggerHelper.skipTrigger = true;
         ApplicationtriggerHelper.skiptrigger = true;
         RolesandResponsibilitiesTriggerHelper.skipTrigger = true;
         GranttriggerHelper.skipTrigger = true;
         AwardTriggerhelper.skipTrigger = true;
         Grant__c gr = new Grant__c();
         gr.ProjectPeriodStartDate__c=Date.newInstance(2015,3,14);
         gr.ProjectPeriodEndDate__c=Date.newInstance(2016,3,14);
         gr.GrantAbbreviation__c='12345';
         gr.IssueDate__c = Date.newInstance(2014,3,14);
         insert gr;
     
        Announcement__c ann = TestHelper.getAnnouncement(true);
        Application__c app = TestHelper.getApplication(ann.Id,true);
         
        //Award__c aw = TestHelper.getAwards(gr.Id,true);
        Award__c aw  = new Award__c();
        aw.grant__c = gr.Id;
        aw.Name = Math.Random()+'AW12';
        aw.OrganizationName__c = 'Test Org';
        aw.OrganizationAddress__c = 'Test Address';
        aw.FiscalYear__c = '2013';
        aw.SupportYear__c = Decimal.valueOf('2013');
        aw.Status__c = 'Issued';
        aw.Application__c=app.Id;
        insert aw;
                
        TermCondition__c termCond = new TermCondition__c();
        termCond.Award__c= aw.Id;
        termCond.SubmissionType__c='Progress Report';
        insert termCond;
              
        
        ApexPages.StandardController sc = new ApexPages.standardController(gr);        
        ApexPages.currentPage().getParameters().put('Id',aw.id);
        ApexPages.currentPage().getParameters().put('applicationId',null);
        AwardViewCtrl e = new AwardViewCtrl(sc);
    }
    
    static testMethod void someTest4() {
        //Grant__c gr = TestHelper.getGrant(true);
         AnnouncementTriggerHelper.skipTrigger = true;
         ApplicationtriggerHelper.skiptrigger = true;
         RolesandResponsibilitiesTriggerHelper.skipTrigger = true;
         GranttriggerHelper.skipTrigger = true;
         AwardTriggerhelper.skipTrigger = true;
         Grant__c gr = new Grant__c();
         gr.ProjectPeriodStartDate__c=Date.newInstance(2015,3,14);
         gr.ProjectPeriodEndDate__c=Date.newInstance(2016,3,14);
         gr.GrantAbbreviation__c='12345';
         gr.IssueDate__c = Date.newInstance(2014,3,14);
         insert gr;
     
        Announcement__c ann = TestHelper.getAnnouncement(true);
        Application__c app = TestHelper.getApplication(ann.Id,true);
         
        //Award__c aw = TestHelper.getAwards(gr.Id,true);
        Award__c aw  = new Award__c();
        aw.grant__c = gr.Id;
        aw.Name = Math.Random()+'AW12';
        aw.OrganizationName__c = 'Test Org';
        aw.OrganizationAddress__c = 'Test Address';
        aw.FiscalYear__c = '2013';
        aw.SupportYear__c = Decimal.valueOf('2013');
        aw.Status__c = 'Issued';
        aw.Application__c=app.Id;
        insert aw;
                
        TermCondition__c termCond = new TermCondition__c();
        termCond.Award__c= aw.Id;
        termCond.SubmissionType__c='Site Visit';
        insert termCond;
              
        
        ApexPages.StandardController sc = new ApexPages.standardController(gr);        
        ApexPages.currentPage().getParameters().put('Id',aw.id);
        ApexPages.currentPage().getParameters().put('applicationId',null);
        AwardViewCtrl e = new AwardViewCtrl(sc);
    }
    
}