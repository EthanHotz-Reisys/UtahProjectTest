@isTest(SeeAllData=false)
public class TestAnnouncementEditCtrl {
    static testMethod void granteeTest() {
         Announcement__c announcement = null;
         //Announcement__c ann = TestHelper.getAnnouncement(true);     
       /* Account acc = new Account();
        acc.Name = 'test '+system.currentTimeMillis();
        acc.status__c = 'Active';
        insert acc;
        Program__c program = TestHelper.getProgram(acc.id,false);
        program.status__c = 'Active';
        insert program;*/
       /* ReviewStepTemplate__c template = TestHelper.getReviewStepTemplate(program.Id, true, 'Application');
        ReviewPanelTemplate__c rpt = TestHelper.getReviewPanelTemplate(template.Id, 'Application', true);
        PanelUserTemplate__c put = TestHelper.getPanelUserTemplate(rpt.Id, true);*/
        User u = new User(Id=UserInfo.getUserId());        
        System.runAs(u){
            GNT__KeyValueStore__c key= new GNT__KeyValueStore__c(Name='ENTERPRISE',GNT__BooleanValue__c=true);
            ProgramTriggerHelper.skipTrigger=true;
            GNT.TriggerHelper.skipTrigger=true;
            announcement=TestHelper.getAnnouncement(true);        
        }             
         ApexPages.StandardController sc = new ApexPages.standardController(announcement);
         ApexPages.currentPage().getParameters().put('id',announcement.Id);
         ApexPages.CurrentPage().getParameters().put('programid',announcement.Program__c);                 
         AnnouncementEditCtrl e = new AnnouncementEditCtrl(sc);
         e.getKeyValueMap();    
    }  
     static testMethod void grantorTest() {
         Announcement__c announcement = null;
         //Announcement__c ann = TestHelper.getAnnouncement(true);     
       /* Account acc = new Account();
        acc.Name = 'test '+system.currentTimeMillis();
        acc.status__c = 'Active';
        insert acc;
        Program__c program = TestHelper.getProgram(acc.id,false);
        program.status__c = 'Active';
        insert program;*/
        /*ReviewStepTemplate__c template = TestHelper.getReviewStepTemplate(program.Id, true, 'Application');
        ReviewPanelTemplate__c rpt = TestHelper.getReviewPanelTemplate(template.Id, 'Application', true);
        PanelUserTemplate__c put = TestHelper.getPanelUserTemplate(rpt.Id, true);*/
        User u = new User(Id=UserInfo.getUserId());        
        System.runAs(u){
            GNT__KeyValueStore__c key= new GNT__KeyValueStore__c(Name='ENTERPRISE',GNT__BooleanValue__c=true);
            ProgramTriggerHelper.skipTrigger=true;
            GNT.TriggerHelper.skipTrigger=true;
            announcement=TestHelper.getGrantorAnnouncement(true);        
        }              
         ApexPages.StandardController sc = new ApexPages.standardController(announcement);
         ApexPages.currentPage().getParameters().put('id',announcement.Id);
         ApexPages.CurrentPage().getParameters().put('programid',announcement.Program__c);                 
         AnnouncementEditCtrl e = new AnnouncementEditCtrl(sc);
         e.getKeyValueMap();    
    }        
}