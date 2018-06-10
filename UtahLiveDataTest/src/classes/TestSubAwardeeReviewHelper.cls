/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestSubAwardeeReviewHelper {

   static testMethod void myUnitTest() {
   /*
       UserTriggerHelper.skipTrigger=true;
       User u = TestHelper.getAdminUser(true);
       Account acct = null;
       Program__c pgm = null;
        
       System.runAs(u) {
           GrantTriggerHelper.skipTrigger = true;
           AwardTriggerHelper.skipTrigger = true;
           RolesAndResponsibilitiesTriggerHelper.skipTrigger = true;
           AccountTriggerHelper.skipTrigger = true;
           TaskTriggerHelper.skipTrigger=true;
           GNT__KeyValueStore__c key= new GNT__KeyValueStore__c(Name='ENTERPRISE',GNT__BooleanValue__c=true);
           system.debug('-------------Entering Grant creation-------------');
            
           Grant__c grant = TestHelper.getGrant(true);
           grant.GranteePOC__c = u.Id;
           update grant;
            
           system.debug('Grant ID is : ' + grant.Id);
           //StrategicPlan__c strategicPlan = TestHelper.getStrategicPlan(true);  
           acct=TestHelper.getAccount(true);    
           pgm = TestHelper.getProgram(acct.Id,true);     
            
           Award__c award = TestHelper.getAwards(grant.Id,true);
           award.GrantAwardName__c= 'Sample Award Name';
           award.Approver__c = u.Id;
           award.Status__c='Sent to Grantee Review';
           update award;
            
           RolesAndResponsibilities__c rolesAndResponsibilities = TestHelper.getRolesAndResponsibilities(true,pgm.Id);           
           //award.Status__c = 'Sent to Grantee Review';
           //update award;
           system.debug('Award ID is : ' + award.id);
           
           Test.startTest(); 
           ApexPages.currentPage().getParameters().put('Id', award.Id); 
           SubAwardeeReviewHelper subAwardeeReviewHelper = new SubAwardeeReviewHelper();
           subAwardeeReviewHelper.whenClicked();
           Test.stopTest();
        }
        */
    }
        

    
    static testMethod void myUnitTest2() {
    /*
        UserTriggerHelper.skipTrigger=true;
        User u = TestHelper.getAdminUser(true);
        Account acct = null;
        Program__c pgm = null;
        
        System.runAs(u) {
            GrantTriggerHelper.skipTrigger = true;
            AwardTriggerHelper.skipTrigger = true;
            RolesAndResponsibilitiesTriggerHelper.skipTrigger = true;
            AccountTriggerHelper.skipTrigger = true;
            TaskTriggerHelper.skipTrigger=true;
            GNT__KeyValueStore__c key= new GNT__KeyValueStore__c(Name='ENTERPRISE',GNT__BooleanValue__c=true);
            system.debug('-------------Entering Grant creation-------------');
            
            Grant__c grant = TestHelper.getGrant(true);
            grant.GranteePOC__c = u.Id;
            update grant;
            
            system.debug('Grant ID is : ' + grant.Id);
            //StrategicPlan__c strategicPlan = TestHelper.getStrategicPlan(true);  
            acct=TestHelper.getAccount(true);    
            pgm = TestHelper.getProgram(acct.Id,true);     
            
            Award__c award = TestHelper.getAwards(grant.Id,true);
            award.GrantAwardName__c= 'Sample Award Name';
            award.Approver__c = u.Id;
            award.Status__c='Approved';
            update award;
            
            RolesAndResponsibilities__c rolesAndResponsibilities = TestHelper.getRolesAndResponsibilities(true,pgm.Id);           
            //award.Status__c = 'Sent to Grantee Review';
            //update award;
            system.debug('Award ID is : ' + award.id);
            
            ApexPages.currentPage().getParameters().put('Id', award.Id);
            
            SubAwardeeReviewHelper subAwardeeReviewHelper = new SubAwardeeReviewHelper();
            subAwardeeReviewHelper.whenClicked();
        }
        */
    }
    
       static testMethod void myUnitTest3() {
       /*
           UserTriggerHelper.skipTrigger=true;
           User u = TestHelper.getAdminUser(true);
           Account acct = null;
           Program__c pgm = null;
        
           System.runAs(u) {
               GrantTriggerHelper.skipTrigger = true;
               AwardTriggerHelper.skipTrigger = true;
               RolesAndResponsibilitiesTriggerHelper.skipTrigger = true;
               AccountTriggerHelper.skipTrigger = true;
               TaskTriggerHelper.skipTrigger=true;
               GNT__KeyValueStore__c key= new GNT__KeyValueStore__c(Name='ENTERPRISE',GNT__BooleanValue__c=true);
               system.debug('-------------Entering Grant creation-------------');
            
               Grant__c grant = TestHelper.getGrant(true);
               grant.GranteePOC__c = u.Id;
               update grant;
            
               system.debug('Grant ID is : ' + grant.Id);
               //StrategicPlan__c strategicPlan = TestHelper.getStrategicPlan(true);  
               acct=TestHelper.getAccount(true);    
               pgm = TestHelper.getProgram(acct.Id,true);     
            
               Award__c award = TestHelper.getAwards(grant.Id,true);
               award.GrantAwardName__c= 'Sample Award Name';
               award.Approver__c = u.Id;
               award.Status__c='Grantee Accepted';
               update award;
            
               RolesAndResponsibilities__c rolesAndResponsibilities = TestHelper.getRolesAndResponsibilities(true,pgm.Id);           
               //award.Status__c = 'Sent to Grantee Review';
               //update award;
               system.debug('Award ID is : ' + award.id);
            
               Test.startTest();
               ApexPages.currentPage().getParameters().put('Id', award.Id);
               SubAwardeeReviewHelper subAwardeeReviewHelper = new SubAwardeeReviewHelper();
               subAwardeeReviewHelper.whenClicked();
               Test.stopTest();
        }
        */
    }
    
        static testMethod void myUnitTest4() {
        /*
            UserTriggerHelper.skipTrigger=true;
            User u = TestHelper.getAdminUser(true);
            Account acct = null;
            Program__c pgm = null;
        
            System.runAs(u) {
                GrantTriggerHelper.skipTrigger = true;
                AwardTriggerHelper.skipTrigger = true;
                RolesAndResponsibilitiesTriggerHelper.skipTrigger = true;
                AccountTriggerHelper.skipTrigger = true;
                TaskTriggerHelper.skipTrigger=true;
                GNT__KeyValueStore__c key= new GNT__KeyValueStore__c(Name='ENTERPRISE',GNT__BooleanValue__c=true);
                system.debug('-------------Entering Grant creation-------------');
            
                Grant__c grant = TestHelper.getGrant(true);
                grant.GranteePOC__c = u.Id;
                update grant;
            
                system.debug('Grant ID is : ' + grant.Id);
                //StrategicPlan__c strategicPlan = TestHelper.getStrategicPlan(true);  
                acct=TestHelper.getAccount(true);    
                pgm = TestHelper.getProgram(acct.Id,true);     
                Award__c award = TestHelper.getAwards(grant.Id,true);
                RolesAndResponsibilities__c rolesAndResponsibilities = TestHelper.getRolesAndResponsibilities(true,pgm.Id);           

                Test.startTest();
                ApexPages.currentPage().getParameters().put('Id', award.Id);
                SubAwardeeReviewHelper subAwardeeReviewHelper = new SubAwardeeReviewHelper();
                subAwardeeReviewHelper.whenClicked();
                Test.stopTest();
        }
        */
    }
}