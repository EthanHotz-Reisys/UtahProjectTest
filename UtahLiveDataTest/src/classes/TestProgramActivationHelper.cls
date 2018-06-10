@isTest(seealldata=true)
private with sharing class TestProgramActivationHelper{

    static testMethod void testWhenClicked(){
        
        Account acct= null;
        Contact ct = null;
        Program__c prog=null;
        FundingSource__c FS= null;
        FundingAccount__c FA = null;
        ProgramFundingAccount__c progFA = null;
        ServiceArea__c serviceArea = null;
        ProgramServiceArea__c progSA = null;
        ProgramContacts__c progContact = null;
        User u = new User(Id=UserInfo.getUserId());
     
        System.runAs(u){
            GNT__KeyValueStore__c key= new GNT__KeyValueStore__c(Name='ENTERPRISE',GNT__BooleanValue__c=true);
             AccountTriggerHelper.skipTrigger=true;
             ProgramTriggerHelper.skipTrigger=true;
            acct=TestHelper.getAccount(true);
            ct = new Contact(Firstname='FirstName', Lastname='LastName',Email='email@email.com', Title='Title',Phone ='123-123-1234',AccountId=acct.Id);
            insert ct;
            prog=TestHelper.getProgram(acct.Id,true);
            FS = TestHelper.getFundingSource(true);
            FA = TestHelper.getFundingAccount(true,FS.Id);
            progFA= TestHelper.getProgramFundingAccount(true,FA.Id,prog.Id);
            serviceArea = TestHelper.getServiceArea(true);
            progSA = TestHelper.getProgramServiceArea(true,prog.Id,serviceArea.Id);
            progContact = new ProgramContacts__c(Program__c=prog.Id,Contact__c=ct.Id);
            insert progContact;
            
            
        }
        
        Test.startTest();
        ProgramActivationHelper programHelper = new ProgramActivationHelper();
        ApexPages.currentPage().getParameters().put('Id',prog.Id);
        programHelper.whenClicked();
        Test.stopTest();  
    
    }
    
      static testMethod void testWhenClicked2(){
        
        Account acct= null;
        Program__c prog=null;
        User u = new User(Id=UserInfo.getUserId());
     
        System.runAs(u){
            GNT__KeyValueStore__c key= new GNT__KeyValueStore__c(Name='ENTERPRISE',GNT__BooleanValue__c=true);
             AccountTriggerHelper.skipTrigger=true;
             ProgramTriggerHelper.skipTrigger=true;
            acct=TestHelper.getAccount(true); 
             prog=TestHelper.getProgram(acct.Id,true);
        }
        
        Test.startTest();
        ProgramActivationHelper programHelper = new ProgramActivationHelper();
        ApexPages.currentPage().getParameters().put('Id',prog.Id);
        programHelper.whenClicked();
        Test.stopTest();
     
    
    
    
    }

}