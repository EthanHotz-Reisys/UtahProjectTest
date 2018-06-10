@isTest
private class TestProgramWBSHelperClass {

    @isTest static void testOnAfterTaskUpdateHandler() {
        Test.startTest();
        UserTriggerHelper.skiptrigger = true;
        Map<String, Object> temp = new Map<String, Object>();
        Map<String, Object> temp2 = new Map<String, Object>();
        WBSTaskSchedule__c ts = new WBSTaskSchedule__c();
        ProgramWBSHelperClass programHelper = new ProgramWBSHelperClass();
        UserTriggerHelper.skiptrigger = true;
        insert ts;
        temp2.put('id', ts.Id);
        temp2.put('text', 'test');
        User u = TestHelper.getAdminUser(true);
        temp2.put('owner', u.Id);
        temp2.put('description', 'test');
        temp2.put('milestone', true);
        temp2.put('progress', 5);
        temp2.put('status', 'Assigned');
        temp2.put('start_date', String.valueOf(Date.today() - 5));
        temp2.put('end_date', String.valueOf(Date.today()));
        temp2.put('duration', 5);
        temp.put('item', temp2);
        
        programHelper.keyValueMap = temp;

        temp.put('eventMethodname', 'onAfterTaskUpdate');
        Map<String, Object> result = programHelper.handleEvent();
        System.debug(result.get('Message'));
        Test.stopTest();

    }
    
    @isTest static void testOnAfterTaskDelete() {
        Test.startTest();
        UserTriggerHelper.skiptrigger = true;
        Map<String, Object> temp = new Map<String, Object>();
        Map<String, Object> temp2 = new Map<String, Object>();
        WBSTaskSchedule__c ts = new WBSTaskSchedule__c();
        ProgramWBSHelperClass programHelper = new ProgramWBSHelperClass();
        UserTriggerHelper.skiptrigger = true;
        insert ts;
        temp2.put('id', ts.Id);
        temp2.put('text', 'test');
        User u = TestHelper.getAdminUser(true);
        temp2.put('owner', u.Id);
        temp2.put('description', 'test');
        temp2.put('milestone', true);
        temp2.put('progress', 5);
        temp2.put('status', 'Assigned');
        temp2.put('start_date', String.valueOf(Date.today() - 5));
        temp2.put('end_date', String.valueOf(Date.today()));
        temp2.put('duration', 5);
        temp.put('item', temp2);
        
        programHelper.keyValueMap = temp;

        temp.put('eventMethodname', 'onAfterTaskDelete');
        Map<String, Object> result = programHelper.handleEvent();
        System.debug(result.get('Message'));
        Test.stopTest();

    }
    @isTest static void testOnAfterTaskAdd() {
    /*
        Test.startTest();
        AccountTriggerHelper.skiptrigger = true;
        ProgramTriggerHelper.skiptrigger = true;
        Account account = TestHelper.getAccount(true);
        Program__c program = TestHelper.getProgram(account.Id, true);
        UserTriggerHelper.skiptrigger = true;
        Map<String, Object> temp = new Map<String, Object>();
        Map<String, Object> temp2 = new Map<String, Object>();
        Map<String, Object> temp3 = new Map<String, Object>();
        Map<String, Object> temp4 = new Map<String, Object>();
        WBSTaskSchedule__c ts = new WBSTaskSchedule__c();
        WBSTaskSchedule__c ts1 = new WBSTaskSchedule__c();
        ProgramWBSHelperClass programHelper = new ProgramWBSHelperClass();
        UserTriggerHelper.skiptrigger = true;
        insert ts;
        insert ts1;
        String str = '{"programid" :"' + program.Id + '"}';
        temp2.put('parent', ts1.Id);
        temp2.put('id', ts.Id);
        temp2.put('text', 'test');
        User u = TestHelper.getAdminUser(true);
        temp2.put('owner', u.Id);
        temp2.put('description', 'test');
        temp2.put('milestone', true);
        temp2.put('progress', 5);
        temp2.put('status', 'Assigned');
        temp2.put('start_date', String.valueOf(Date.today() - 5));
        temp2.put('end_date', String.valueOf(Date.today()));
        temp2.put('duration', 5);
        temp2.put('wbsno', 'test');
        temp.put('item', temp2);
        temp.put('paramtersMap', str);
        temp.put('idMapper', temp4);
        
        programHelper.keyValueMap = temp;

        temp.put('eventMethodname', 'onAfterTaskAdd');
        Map<String, Object> result = programHelper.handleEvent();
        System.debug(result.get('Message'));
        Test.stopTest();
*/
    }
    @isTest static void testAfterLinkAddHandler() {
    /*
        Test.startTest();
        AccountTriggerHelper.skiptrigger = true;
        ProgramTriggerHelper.skiptrigger = true;
        Account account = TestHelper.getAccount(true);
        Program__c program = TestHelper.getProgram(account.Id, true);
        UserTriggerHelper.skiptrigger = true;
        Map<String, Object> temp = new Map<String, Object>();
        Map<String, Object> temp2 = new Map<String, Object>();
        Map<String, Object> temp3 = new Map<String, Object>();
        Map<String, Object> temp4 = new Map<String, Object>();
        WBSTaskSchedule__c ts = new WBSTaskSchedule__c();
        WBSTaskSchedule__c ts1 = new WBSTaskSchedule__c();
        ProgramWBSHelperClass programHelper = new ProgramWBSHelperClass();
        UserTriggerHelper.skiptrigger = true;
        insert ts;
        insert ts1;
        String str = '{"programid" :"' + program.Id + '"}';
        temp2.put('parent', ts1.Id);
        temp2.put('id', ts.Id);
        temp2.put('text', 'test');
        User u = TestHelper.getAdminUser(true);
        temp2.put('owner', u.Id);
        temp2.put('description', 'test');
        temp2.put('milestone', true);
        temp2.put('progress', 5);
        temp2.put('status', 'Assigned');
        temp2.put('start_date', String.valueOf(Date.today() - 5));
        temp2.put('end_date', String.valueOf(Date.today()));
        temp2.put('duration', 5);
        temp2.put('wbsno', 'test');
        
        temp2.put('source', ts.Id);
        temp2.put('target', ts1.Id);
        temp4.put('source', ts.Id);
        temp4.put('target', ts1.Id);

        temp.put('item', temp2);
        temp.put('paramtersMap', str);
        temp.put('idMapper', temp4);
        
        programHelper.keyValueMap = temp;

        temp.put('eventMethodname', 'onAfterLinkAdd');
        Map<String, Object> result = programHelper.handleEvent();
        System.debug(result.get('Message'));
        Test.stopTest();
*/
    }
    @isTest static void testPublishTasks() {
    /*
        Test.startTest();
        User u = TestHelper.getAdminUser(true);
        System.runAs(u){
        AccountTriggerHelper.skiptrigger = true;
        ProgramTriggerHelper.skiptrigger = true;
        Account account = TestHelper.getAccount(true);
        Program__c program = TestHelper.getProgram(account.Id, true);
        UserTriggerHelper.skiptrigger = true;
        Map<String, Object> temp = new Map<String, Object>();
        Map<String, Object> temp2 = new Map<String, Object>();
        Map<String, Object> temp3 = new Map<String, Object>();
        Map<String, Object> temp4 = new Map<String, Object>();
        
        WBSTaskSchedule__c ts = new WBSTaskSchedule__c(Name = 'test', Status__c = 'Created', OwnerId = u.Id, 
            StartDate__c = Date.today() - 5, EndDate__c = Date.today()
            );
        WBSTaskSchedule__c ts1 = new WBSTaskSchedule__c();
        ProgramWBSHelperClass programHelper = new ProgramWBSHelperClass();
        UserTriggerHelper.skiptrigger = true;
        insert ts;
        insert ts1;
        String str = '{"programid" :"' + program.Id + '"}';
        temp2.put('parent', ts1.Id);
        temp2.put('id', ts.Id);
        temp2.put('text', 'test');
        
        temp2.put('owner', u.Id);
        temp2.put('description', 'test');
        temp2.put('milestone', true);
        temp2.put('progress', 5);
        temp2.put('status', 'Assigned');
        temp2.put('start_date', String.valueOf(Date.today() - 5));
        temp2.put('end_date', String.valueOf(Date.today()));
        temp2.put('duration', 5);
        temp2.put('wbsno', 'test');
        
        temp2.put('source', ts.Id);
        temp2.put('target', ts1.Id);
        temp4.put('source', ts.Id);
        temp4.put('target', ts1.Id);

        temp.put('item', temp2);
        temp.put('paramtersMap', str);
        temp.put('idMapper', temp4);
        
        programHelper.keyValueMap = temp;

        temp.put('eventMethodname', 'publishTasks');
        
            Map<String, Object> result = programHelper.handleEvent();
            System.debug(result.get('Message'));
        }
        Test.stopTest();
*/
    }

    @isTest static void testException1() {
        Test.startTest();
        ProgramWBSHelperClass programHelper = new ProgramWBSHelperClass();
        Map<String, Object> temp = new Map<String, Object>();
        programHelper.keyValueMap = temp;
        temp.put('eventMethodname', 'onAfterTaskUpdate');
        Map<String, Object> result = programHelper.handleEvent();
        System.debug(result.get('Message'));
        Test.stopTest();

    }

    @isTest static void testException12() {
        Test.startTest();
        User u = TestHelper.getAdminUser(true);
        System.runAs(u){
        Map<String, Object> temp = new Map<String, Object>();
        Map<String, Object> temp2 = new Map<String, Object>();
        Map<String, Object> idMapper = new Map<String, Object>();
        WBSTaskSchedule__c ts = new WBSTaskSchedule__c(Name = 'test', Status__c = 'Created', OwnerId = u.Id, 
            StartDate__c = Date.today() - 5, EndDate__c = Date.today()
            );
        idMapper.put('5', ts.Id);
        temp2.put('id', 5);
        temp.put('item', temp2);
        temp.put('idMapper', idMapper);
        temp.put('eventMethodname', 'onAfterTaskUpdate');
        ProgramWBSHelperClass programHelper = new ProgramWBSHelperClass();
        programHelper.keyValueMap = temp;
        Map<String, Object> result = programHelper.handleEvent();
        Test.stopTest();
        }
    }
@isTest static void testException13() {
        Test.startTest();
        User u = TestHelper.getAdminUser(true);
        System.runAs(u){
        Map<String, Object> temp = new Map<String, Object>();
        Map<String, Object> temp2 = new Map<String, Object>();
        Map<String, Object> idMapper = new Map<String, Object>();
        WBSTaskSchedule__c ts = new WBSTaskSchedule__c(Name = 'test', Status__c = 'Created', OwnerId = u.Id, 
            StartDate__c = Date.today() - 5, EndDate__c = Date.today()
            );
        idMapper.put('5', ts.Id);
        temp2.put('id', 5);
        temp.put('item', temp2);
        temp.put('idMapper', idMapper);
        temp.put('eventMethodname', 'onAfterTaskAdd');
        ProgramWBSHelperClass programHelper = new ProgramWBSHelperClass();
        programHelper.keyValueMap = temp;
        Map<String, Object> result = programHelper.handleEvent();
        Test.stopTest();
        }
    }
    @isTest static void testException2() {
        Test.startTest();
        ProgramWBSHelperClass programHelper = new ProgramWBSHelperClass();
        Map<String, Object> temp = new Map<String, Object>();
        programHelper.keyValueMap = temp;
        temp.put('eventMethodname', 'onAfterTaskAdd');
        Map<String, Object> result = programHelper.handleEvent();
        System.debug(result.get('Message'));
        Test.stopTest();

    }

    @isTest static void testException3() {
        Test.startTest();
        ProgramWBSHelperClass programHelper = new ProgramWBSHelperClass();
        Map<String, Object> temp = new Map<String, Object>();
        programHelper.keyValueMap = temp;
        temp.put('eventMethodname', 'onAfterTaskDelete');
        Map<String, Object> result = programHelper.handleEvent();
        System.debug(result.get('Message'));
        Test.stopTest();

    }

    @isTest static void testException5() {
        Test.startTest();
        ProgramWBSHelperClass programHelper = new ProgramWBSHelperClass();
        Map<String, Object> temp = new Map<String, Object>();
        programHelper.keyValueMap = temp;
        temp.put('eventMethodname', 'publishTasks');
        Map<String, Object> result = programHelper.handleEvent();
        System.debug(result.get('Message'));
        Test.stopTest();

    }
    
}