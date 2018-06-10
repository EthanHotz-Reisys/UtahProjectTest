@isTest
private with sharing class TestReviewStepTemplateTriggerHelper {
    testmethod static void testTriggerSameOwner() {
        AccountTriggerHelper.skipAll = true;
        UserTriggerHelper.skipTrigger=true;
        
        Account account = TestHelper.getAccount(false);
        account.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        insert account;

        Program__c program = TestHelper.getProgram(account.id,false);
        program.status__c = 'Active';
        insert program;

        Test.startTest();

        ReviewStepTemplate__c template = TestHelper.getReviewStepTemplate(program.Id, true, 'Application');
        update template;
        system.assert(template != null);
        Test.stopTest();
    }

    testmethod static void testTriggerDiffOwner() {
        AccountTriggerHelper.skipAll = true;
        UserTriggerHelper.skipTrigger=true;
        
        User u = new User(Id=UserInfo.getUserId());
        System.runAs(u) {
            u = TestHelper.getAdminUser(true);
        }
        Account account = TestHelper.getAccount(false);
        account.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        insert account;

        Program__c program = TestHelper.getProgram(account.id,false);
        program.status__c = 'Active';
        insert program;

        Test.startTest();

        ReviewStepTemplate__c template = TestHelper.getReviewStepTemplate(program.Id, false, 'Application');
        template.OwnerId = u.Id;
        insert template;
        update template;
        Test.stopTest();
        system.assertEquals(template.OwnerId,u.Id);
    }

}