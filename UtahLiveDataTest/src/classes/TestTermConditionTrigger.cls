@isTest
private with sharing class TestTermConditionTrigger{

    @isTest
    static void testAll(){ 
    /*
        UserTriggerHelper.skipTrigger=true;
        user u = TestHelper.getAdminUser(true);
        AccounttriggerHelper.skipTrigger= true;
        AwardTriggerHelper.skipTrigger= true;
        GrantTriggerHelper.skipTrigger= true;
        system.runAs(u){   
        test.StartTest();  
          
            Account acc=TestHelper.getAccount(false);
            acc.Name='REI ORGANIZATION1';
            insert acc;
            UserRole userrole=new UserRole(Name='new userrole',DeveloperName='REIORGANIZATION1PartnerExecutive');
            insert userrole;    
            
           
           
            //Grant__c grant = testHelper.getGrant(false);                    
            //grant.ExternalOrganization__c = acc.id;
            Grant__c grant = TestHelper.getGrant(false);
            //grant.Program__c = program.id;
            grant.Status__c = 'Active';
            grant.ProjectPeriodStartDate__c=Date.today();
            
            grant.ExternalOrganization__c = acc.id;
            insert grant;
            //insert grant;
            
            TermCondition__c tnc = TestHelper.getTermCondition(false,'Condition');
            tnc.Frequency__c = 'Monthly';
            tnc.SubmissionRequired__c = true;
            
            tnc.DueDateDays__c = 3;
            tnc.TaskAvailability__c = 4;
            
            tnc.Grant__c = grant.id;
            tnc.ReportStartDate__c = 'Fixed';
            tnc.ReportEndDate__c = 'Fixed';
            tnc.FixedStartDate__c = system.today();
            tnc.FixedEndDate__c = system.today()+233;
            tnc.UpcomingReportSubmissionDate__c = null;
            insert tnc;
            
            tnc.RecordTypeId = Schema.SObjectType.TermCondition__c.getRecordTypeInfosByName().get('Payment Request').getRecordTypeId();
            
            update tnc;  
            Award__c award = TestHelper.getAwards(grant.id,true);
          
            TermCondition__c tnc_2 = TestHelper.getTermCondition(false,'Condition');
            tnc_2.Frequency__c = 'Quarterly';
            tnc_2.SubmissionRequired__c = true;
            
            tnc_2.DueDateDays__c = 3;
            tnc_2.TaskAvailability__c = 4;
            
            tnc_2.Award__c = award.id;
            tnc_2.ReportStartDate__c = 'Fixed';
            tnc_2.ReportEndDate__c = 'Fixed';
            tnc_2.FixedStartDate__c = system.today();
            tnc_2.FixedEndDate__c = system.today()+233;
            tnc_2.UpcomingReportSubmissionDate__c = null;
            insert tnc_2;
            tnc_2.RecordTypeId = Schema.SObjectType.TermCondition__c.getRecordTypeInfosByName().get('Payment Request').getRecordTypeId();
            
            update tnc_2;  

            
            TermCondition__c tnc_3 = TestHelper.getTermCondition(false,'Condition');
            tnc_3.Frequency__c = 'Annually';
            tnc_3.SubmissionRequired__c = true;
            
            tnc_3.DueDateDays__c = 3;
            tnc_3.TaskAvailability__c = 4;
            
            tnc_3.Award__c = award.id;
            tnc_3.ReportStartDate__c = 'Fixed';
            tnc_3.ReportEndDate__c = 'Fixed';
            tnc_3.FixedStartDate__c = system.today();
            tnc_3.FixedEndDate__c = system.today()+378;
            tnc_3.UpcomingReportSubmissionDate__c = null;
            insert tnc_3;            
            tnc_3.RecordTypeId = Schema.SObjectType.TermCondition__c.getRecordTypeInfosByName().get('Payment Request').getRecordTypeId();
            
            update tnc_3; 
          
            
            TermCondition__c tnc_4 = TestHelper.getTermCondition(false,'Condition');
            tnc_4.Frequency__c = 'Semi-Annually';
            tnc_4.SubmissionRequired__c = true;
            
            tnc_4.DueDateDays__c = 3;
            tnc_4.TaskAvailability__c = 4;
            
            tnc_4.Award__c = award.id;
            tnc_4.ReportStartDate__c = 'Fixed';
            tnc_4.ReportEndDate__c = 'Fixed';
            tnc_4.FixedStartDate__c = system.today();
            tnc_4.FixedEndDate__c = system.today()+378;
            tnc_4.UpcomingReportSubmissionDate__c = null;
            insert tnc_4;            
            test.StopTest();
            system.assertEquals(tnc_4.FixedEndDate__c,system.today()+378);
            
        }       
        */
    }
    
    @isTest
    static void testDateDiffGrant(){ 
        UserTriggerHelper.skipTrigger=true;
        user u = TestHelper.getAdminUser(true);
        system.runAs(u){   
        test.StartTest(); 
            TermCondition__c tnc_2; 
            try{  
                Account acc=TestHelper.getAccount(false);
                acc.Name='REI ORGANIZATION1';
                insert acc;
                UserRole userrole=new UserRole(Name='new userrole',DeveloperName='REIORGANIZATION1PartnerExecutive');
                insert userrole;    
                
            
                Grant__c grant = testHelper.getGrant(false);                    
                grant.ExternalOrganization__c = acc.id;
                grant.BudgetPeriodStartDate__c = system.today();
                grant.BudgetPeriodEndDate__c = system.today()+10;
                grant.ProjectPeriodStartDate__c = system.today();
                grant.ProjectPeriodEndDate__c = system.today()+10;
                insert grant;
                TermCondition__c tnc = TestHelper.getTermCondition(false,'Condition');
                tnc.Frequency__c = 'Monthly';
                tnc.SubmissionRequired__c = true;
                
                tnc.DueDateDays__c = 3;
                tnc.TaskAvailability__c = 4;
               
                tnc.Grant__c = grant.id;
                tnc.ReportStartDate__c = 'Budget Period Start Date';
                tnc.ReportEndDate__c = 'Budget Period End Date';
                tnc.CalReportingStartDate__c = system.today();
                tnc.CalReportingEndDate__c = system.today()+10;
                insert tnc;
                update tnc;  
                
                Award__c award = TestHelper.getAwards(grant.id,false);
                award.BudgetPeriodStartDate__c = system.today();
                award.BudgetPeriodEndDate__c = system.today()+10;
                insert award;
                
                tnc_2 = TestHelper.getTermCondition(false,'Condition');
                tnc_2.Frequency__c = 'Quarterly';
                tnc_2.SubmissionRequired__c = true;
               
                tnc_2.DueDateDays__c = 3;
                tnc_2.TaskAvailability__c = 4;
                
                tnc_2.grant__c= grant.id;
                tnc_2.ReportStartDate__c = 'Project Period Start Date';
                tnc_2.ReportEndDate__c = 'Project Period End Date';
                tnc_2.CalReportingStartDate__c = system.today();
                tnc_2.CalReportingEndDate__c = system.today()+60;
                insert tnc_2;
            }catch(Exception e){
                Boolean expectedExceptionThrown1 =  e.getMessage().contains('Beginning Date and Ending Date are too close to each other and the gap between them is shorter than the frequency') ? true : false;
                System.AssertEquals(expectedExceptionThrown1, false);
                
               
            }
            test.StopTest();
            //system.assertEquals(tnc_2.CalReportingEndDate__c,system.today()+60);
        }       
    }
    
    
    @isTest
    static void testDateDiffGrantNegative(){ 
        UserTriggerHelper.skipTrigger=true;
        user u = TestHelper.getAdminUser(true);
        system.runAs(u){   
        test.StartTest(); 
            TermCondition__c tnc; 
            try{  
                Account acc=TestHelper.getAccount(false);
                acc.Name='REI ORGANIZATION1';
                insert acc;
                UserRole userrole=new UserRole(Name='new userrole',DeveloperName='REIORGANIZATION1PartnerExecutive');
                insert userrole;    
                
  
                         
                Grant__c grant = testHelper.getGrant(false);                    
                grant.ExternalOrganization__c = acc.id;
                grant.BudgetPeriodStartDate__c = system.today();
                grant.BudgetPeriodEndDate__c = system.today()+10;
                insert grant;
                
                tnc = TestHelper.getTermCondition(false,'Condition');
                tnc.Frequency__c = 'Monthly';
                tnc.SubmissionRequired__c = true;
               
                tnc.DueDateDays__c = null;
                tnc.TaskAvailability__c = 4;
                
                tnc.Grant__c = grant.id;
                tnc.ReportStartDate__c = 'Budget Period Start Date';
                tnc.ReportEndDate__c = 'Budget Period End Date';
                tnc.CalReportingStartDate__c = system.today();
                tnc.CalReportingEndDate__c = system.today()+60;
                insert tnc;
                update tnc;  
                
            }catch(Exception e){
                Boolean expectedExceptionThrown2 =  e.getMessage().contains('If Submission Required is checked, please make sure you have populated') ? true : false;
                System.AssertEquals(expectedExceptionThrown2, false);
            }
            
            test.StopTest();
            //system.assertEquals(tnc.CalReportingEndDate__c,system.today()+60);
        }       
    }
}