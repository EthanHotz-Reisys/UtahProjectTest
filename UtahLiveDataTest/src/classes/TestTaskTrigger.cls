/**
Test class for TaskTrigger and TaskTriggerHelper
*****************************************************
???????         Vineeth                 created
6/20/2014       Ryan Chadwick           implemented test cases
7/22/2015       Jianwen                 Edited
***************************************************** 
*/
 
 
@isTest
private class TestTaskTrigger {

     @IsTest
    public static void testBeforeInsert(){
        
       /*
        User u = TestHelper.getAdminUser(true);
        GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateasGrantee');
        System.runAs(u){
        
        AccountTriggerHelper.skipTrigger = true;
        UserTriggerHelper.skipTrigger=true;
        Account tester = new Account ();
        tester.Name = 'Jianwen';
        tester.BillingCity='LA';
        insert tester;
        
        //TestHelper.getTaskActionMapping();
        Task theTask = TestHelper.getTask(false);
        theTask.WhatId = tester.Id;
        
        Test.startTest();
        insert theTask;
        update theTask;
        Test.stopTest();
       }
*/
    }
    
    @IsTest
    public static void testBeforeUpdate(){
       /*
     
        AccountTriggerHelper.skipTrigger = true;
        UserTriggerHelper.skipTrigger=true;
        Account tester = new Account ();
        tester.Name = 'Jianwen';
        tester.BillingCity='LA';
        insert tester;
        
        //TestHelper.getTaskActionMapping();
        Task theTask = TestHelper.getTask(false);
        theTask.WhatId = tester.Id;
        insert theTask;
        Date tempDate = System.today().addDays(1);
        
        //execute
        Test.startTest();
        Test.stopTest();
        
        //assert
        
        */
    }

    
    @IsTest
    public static void testUnassignedBulk(){
    /*
        List<Task> taskList = new List<Task>();
        UserTriggerHelper.skipTrigger=true;
        //arrange
        User u = TestHelper.getAdminUser(true);
        System.runAs(u) {        
            //TestHelper.getTaskActionMapping();
        }
        AccountTriggerHelper.skipTrigger = true;
        Account tester = new Account ();
        tester.Name = 'Jianwen';
        tester.BillingCity='LA';
        insert tester;
         
        System.runAs(u){
            //execute
            Test.startTest();
           //getBulkTasks
           
        
            String[] theDocs = new List<String> {'Announcement', 'Application', 'Pre-Application','Progress Report', 'Program',
                                'Funding Source', 'Funding Account', 'Review Award', 'Create Award', 
                                'Organization', 'User', 'Submission Package'};
        
       
           //endGetBulkTasks
            TaskTriggerHelper tth = new TaskTriggerHelper();
           // tth.decrementTaskSummaryCustomSetting(taskList);
            // Map<String, Object> result1 = tth.deserializeJSON(tas, null, true);
           // Map<String, Object> result2 = tth.deserializeJSON(tas, null, false);
            //String result = tth.updateSummaryCounts(null, 'test', true, true);
            Test.stopTest();
            //System.assert(result1 != null);
            //System.assert(result2 != null);
            //System.assert(result != null);
        }
        //assert
        System.assertNotEquals(taskList,null);
        
        */
    }

    @IsTest
    public static void testAssignedBulk(){
    /*
        List<Task> taskList = new List<Task>();
        //arrange
        UserTriggerHelper.skipTrigger=true;
        User u = TestHelper.getAdminUser(true);
        
        System.runAs(u) {        
            //TestHelper.getTaskActionMapping();
        }
        AccountTriggerHelper.skipTrigger = true;
        Account tester = new Account ();
        tester.Name = 'Jianwen';
        tester.BillingCity='LA';
        insert tester;
         
        System.runAs(u){
            //execute
            Test.startTest();
            //getAssignedBulk
             
        
            String[] theDocs = new List<String> {'Announcement', 'Application', 'Pre-Application','Progress Report', 'Program',
                                    'Funding Source', 'Funding Account', 'Review Award', 'Create Award', 
                                'Organization', 'User', 'Submission Package'};
            
            Test.stopTest();
        }
        //assert
        System.assertNotEquals(taskList,null);
        
        */
    }      
}