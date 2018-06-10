@IsTest
        public with sharing class TestActivateReportBatch {
             @IsTest
            private static void testInsert() 
            {
            /*
                UserTriggerHelper.skipTrigger = true;
                GrantTriggerHelper.skipTrigger = true;
                AwardTriggerHelper.skipTrigger=true;
                AccountTriggerHelper.skipTrigger=true;
                User u = TestHelper.getAdminUser(true);
        
                 System.runAs(u) {
                    Test.startTest();
                     UserTriggerHelper.skipTrigger = true;
                    Grant__c grant = TestHelper.getGrant(false);
        //grant.Program__c = program.id;
        grant.Status__c = 'Active';
        grant.ProjectPeriodStartDate__c=Date.today();
        insert grant;
                    Award__c aw = TestHelper.getAwards(grant.id,true);
                    
                TermCondition__c termCond= TestHelper.getTermCondition(true,'Term');
                Database.BatchableContext BC;
                ProgressReports__c pr = new ProgressReports__c();
                
                pr.Name='test';
                pr.Status__c='abc';
                pr.Award__c =aw.id;
                pr.TermandCondition__c=termCond.Id;
                insert pr;
                
            //ProgressReports__c pr=[Select Id,Name,Status__c,ReportingPeriodEndDate__c from ProgressReports__c limit 1];
            
            String query = 'Select Id,Name,Status__c,ReportingPeriodEndDate__c from ProgressReports__c where status__c =\'Draft\'';
  
         Database.getQueryLocator(query);
        
        //ActivateReportBatch arb= new ActivateReportBatch();
        
        //arb.execute(BC, pr);
        
        Test.stopTest();
                 }
                 
                 */
        }
        
        }