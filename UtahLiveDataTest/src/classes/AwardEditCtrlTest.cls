@isTest(seealldata=false)
public class AwardEditCtrlTest {
    static testMethod void someTest() {
        //Grant__c gr = TestHelper.getGrant(true);
        AnnouncementTriggerHelper.skipTrigger = true;
        ApplicationtriggerHelper.skiptrigger = true;
        UserTriggerHelper.skipTrigger = true;
        RolesandResponsibilitiesTriggerHelper.skipTrigger = true;
        GranttriggerHelper.skipTrigger = true;
        Announcement__c ann = TestHelper.getAnnouncement(true);
        Application__c app = TestHelper.getApplication(ann.Id,true);
        BudgetPeriod__c budPeriod=null;
        Grant__c gr = new Grant__c();
        gr.ProjectPeriodStartDate__c=Date.newInstance(2015,3,14);
        gr.ProjectPeriodEndDate__c=Date.newInstance(2016,3,14);
        gr.Program__c=ann.Program__c;
        gr.IssueDate__c = Date.newInstance(2014,3,14);
        insert gr;
         
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
        aw.Announcement__c = ann.Id;
        insert aw;
        
        budPeriod = new BudgetPeriod__c();
        insert budPeriod;
        
        ApexPages.StandardController sc = new ApexPages.standardController(gr);        
        ApexPages.currentPage().getParameters().put('Id',aw.id);
        ApexPages.currentPage().getParameters().put('applicationId',app.Id);
        ApexPages.currentPage().getParameters().put('grantId',null);
        ApexPages.currentPage().getParameters().put('BudgetPeriodid',budPeriod.Id);
        AwardEditCtrl e = new AwardEditCtrl(sc);
        ApexPages.currentPage().getParameters().put('applicationId',null);
        ApexPages.currentPage().getParameters().put('grantId',gr.Id);        
        e = new AwardEditCtrl(sc);
        e.getKeyValueMap();
        
        e = new AwardEditCtrl(sc);
    }
    
    static testMethod void someTest2() {
        //Grant__c gr = TestHelper.getGrant(true);
         UserTriggerHelper.skipTrigger = true;
        AnnouncementTriggerHelper.skipTrigger = true;
        ApplicationtriggerHelper.skiptrigger = true;
        RolesandResponsibilitiesTriggerHelper.skipTrigger = true;
        GranttriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
        
        System.runAs(u){
            GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateasGrantor');
            Announcement__c ann = TestHelper.getAnnouncement(true);
            Application__c app = TestHelper.getApplication(ann.Id,true);
         
            Grant__c gr = new Grant__c();
            gr.ProjectPeriodStartDate__c=Date.newInstance(2015,3,14);
            gr.ProjectPeriodEndDate__c=Date.newInstance(2016,3,14);
            gr.IssueDate__c = Date.newInstance(2014,3,14);
            gr.Program__c=ann.Program__c;
            insert gr;
         
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
            aw.Announcement__c = ann.Id;
            insert aw;
                
            GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateasGrantor');
            ApexPages.StandardController sc = new ApexPages.standardController(gr);        
            ApexPages.currentPage().getParameters().put('Id',aw.id);
            ApexPages.currentPage().getParameters().put('applicationId',null);
            ApexPages.currentPage().getParameters().put('grantId',null);
        //ApexPages.currentPage().getParameters().put('BudgetPeriodid');
       
            ApexPages.currentPage().getParameters().put('applicationId',null);
            ApexPages.currentPage().getParameters().put('grantId',gr.Id);        
            AwardEditCtrl e = new AwardEditCtrl(sc);
            e.getKeyValueMap();
      }
    }
    
    static testMethod void someTest3() {
        //Grant__c gr = TestHelper.getGrant(true);
         UserTriggerHelper.skipTrigger = true;
        AnnouncementTriggerHelper.skipTrigger = true;
        ApplicationtriggerHelper.skiptrigger = true;
        RolesandResponsibilitiesTriggerHelper.skipTrigger = true;
        GranttriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
        
        System.runAs(u){
            GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateasGrantor');
            Announcement__c ann = TestHelper.getAnnouncement(true);
            ann.MatchRequired__c=false;
            update ann;
            Application__c app = TestHelper.getApplication(ann.Id,true);
         
            Grant__c gr = new Grant__c();
            gr.ProjectPeriodStartDate__c=Date.newInstance(2015,3,14);
            gr.ProjectPeriodEndDate__c=Date.newInstance(2016,3,14);
            gr.IssueDate__c = Date.newInstance(2014,3,14);
            gr.Program__c=ann.Program__c;
            insert gr;
         
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
            aw.Announcement__c = ann.Id;
            insert aw;
                
            GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateasGrantor');
            ApexPages.StandardController sc = new ApexPages.standardController(gr);        
            ApexPages.currentPage().getParameters().put('Id',null);
            ApexPages.currentPage().getParameters().put('applicationId',null);
            ApexPages.currentPage().getParameters().put('grantId',null);
        //ApexPages.currentPage().getParameters().put('BudgetPeriodid');
       
            ApexPages.currentPage().getParameters().put('applicationId',app.Id);
            ApexPages.currentPage().getParameters().put('grantId',gr.Id);        
            AwardEditCtrl e = new AwardEditCtrl(sc);
            e.getKeyValueMap();
      }
    }
}