@isTest
private class TestExtRegNDADisagreeHelper{

    static testMethod void testWhenClicked1() {
        ExternalRegistrationNDADisagreeHelper extReg= new ExternalRegistrationNDADisagreeHelper();  
        //Test.startTest();
       // FOALead__c fOALead = TestHelper.getFOALead(true);
        //contact con = null;
        Contact con = TestHelper.getContact(true);
        con.SecurityToken__c = 'ABC';
        update con;
        UserRegistration__c uReg = new UserRegistration__c();
        uReg.OrganizationName__c ='TestORG';
        uReg.LastName__c = 'Betty';
        uReg.username__c = System.now().millisecond() + 'test@123test.com';
        uReg.EINo__c = Math.Random();
        uReg.Email__c = 'test15@test.com';
        uReg.Contact__c = con.ID;
        //uReg.RecordType.DeveloperName = 'Reviewer';
        insert uReg;
        
         Test.startTest();
         ApexPages.StandardController sc = new ApexPages.standardController(uReg);
         ApexPages.currentPage().getParameters().put('Id',uReg.Id);
         ApexPages.currentPage().getParameters().put('SecurityToken',con.SecurityToken__c);
         extReg.whenClicked();
        Test.stopTest();      
    }
    
       static testMethod void testWhenClicked2() {
        ExternalRegistrationNDADisagreeHelper extReg= new ExternalRegistrationNDADisagreeHelper();  
        //Test.startTest();
       // FOALead__c fOALead = TestHelper.getFOALead(true);
        //contact con = null;
        Contact con = TestHelper.getContact(true);
        con.SecurityToken__c = '';
        update con;
        UserRegistration__c uReg = new UserRegistration__c();
        uReg.OrganizationName__c ='TestORG';
        uReg.LastName__c = 'Betty';
        uReg.username__c = System.now().millisecond() + 'test@123test.com';
        uReg.EINo__c = Math.Random();
        uReg.Email__c = 'test15@test.com';
        uReg.Contact__c = con.ID;
        //uReg.RecordType.DeveloperName = 'Reviewer';
        insert uReg;
        
         Test.startTest();
         ApexPages.StandardController sc = new ApexPages.standardController(uReg);
         ApexPages.currentPage().getParameters().put('Id',uReg.Id);
         ApexPages.currentPage().getParameters().put('SecurityToken',con.SecurityToken__c);
         extReg.whenClicked();
        Test.stopTest();      
    }
    
         static testMethod void testWhenClicked3() {
        ExternalRegistrationNDADisagreeHelper extReg= new ExternalRegistrationNDADisagreeHelper();  
        //Test.startTest();
       // FOALead__c fOALead = TestHelper.getFOALead(true);
        //contact con = null;
        Contact con = TestHelper.getContact(false);
        con.SecurityToken__c = 'ABC';
        insert con;
        UserRegistration__c uReg = new UserRegistration__c();
        uReg.OrganizationName__c ='TestORG';
        uReg.LastName__c = 'Betty';
        uReg.username__c = System.now().millisecond() + 'test@123test.com';
        uReg.EINo__c = Math.Random();
        uReg.Email__c = 'test15@test.com';
        uReg.Contact__c = con.ID;
        //uReg.RecordType.DeveloperName = 'Reviewer';
        insert uReg;
        
         Test.startTest();
         ApexPages.StandardController sc = new ApexPages.standardController(uReg);
         ApexPages.currentPage().getParameters().put('Id',uReg.Id);
         ApexPages.currentPage().getParameters().put('SecurityToken',con.SecurityToken__c);
         extReg.whenClicked();
        Test.stopTest();      
    }
    
     
}