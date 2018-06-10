@isTest
private with sharing class TestApplicationWithdrawal{

    static testMethod void testExecute1() {
    /*
        AnnouncementTriggerHelper.skipTrigger=true;
        AccountTriggerHelper.skipTrigger=true;
        USBEAnnouncementTriggerHelper.skipTrigger=true;
        ApplicationTriggerHelperUSBE.skipTrigger=true;
        ApplicationTriggerHelper.skipTrigger=true;

        Account acc=TestHelper.getAccount(true);
        User u = TestHelper.getAdminUser(true);

        Program__c prog=TestHelper.getProgram(acc.id,true);

        Announcement__c ann=TestHelper.getAnnouncement(prog.id,true);
        
        Application__c app=TestHelper.getApplication(ann.id,false);
        app.PrimaryApplicant__c=u.id;
        app.WaiveWithdraw__c = 'Withdraw';
        app.Approver__c=u.id;
        insert app;
        
        Task tsk=TestHelper.getTask(false);
        tsk.WhatId=app.id;
        tsk.OwnerId=u.Id;
        tsk.Status='In Progress';
        insert tsk;

        ApplicationWithdrawal appwithdrawal=new ApplicationWithdrawal();  
        appwithdrawal.selectedRecordId=app.ID;
        appwithdrawal.selectedAction='Approve';
       
        
    
        System.runAs(u){
            Test.startTest();  
            appwithdrawal.execute();
            appwithdrawal.selectedAction='Reject';
            appwithdrawal.execute();

            Test.stopTest();
        }
*/
    }


    static testMethod void testExecute2() {
    /*
        AnnouncementTriggerHelper.skipTrigger=true;
        AccountTriggerHelper.skipTrigger=true;
        USBEAnnouncementTriggerHelper.skipTrigger=true;
        ApplicationTriggerHelperUSBE.skipTrigger=true;
        ApplicationTriggerHelper.skipTrigger=true;

        Account acc=TestHelper.getAccount(true);
        User u = TestHelper.getAdminUser(true);

        Program__c prog=TestHelper.getProgram(acc.id,true);

        Announcement__c ann=TestHelper.getAnnouncement(prog.id,true);
        
        Application__c app=TestHelper.getApplication(ann.id,false);
        app.PrimaryApplicant__c=u.id;
        app.WaiveWithdraw__c = 'Waive';
        app.Approver__c=u.id;
        insert app;
        
        Task tsk=TestHelper.getTask(false);
        tsk.WhatId=app.id;
        tsk.OwnerId=u.Id;
        tsk.Status='In Progress';
        insert tsk;

        ApplicationWithdrawal appwithdrawal=new ApplicationWithdrawal();  
        appwithdrawal.selectedRecordId=app.ID;
        appwithdrawal.selectedAction='Approve';
       
        
    
        System.runAs(u){
            Test.startTest();  
            appwithdrawal.execute();
            appwithdrawal.selectedAction='Reject';
            appwithdrawal.execute();

            Test.stopTest();
        }
*/
    }
    
  }