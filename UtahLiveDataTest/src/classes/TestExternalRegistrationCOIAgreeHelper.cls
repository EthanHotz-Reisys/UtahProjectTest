@isTest
private class TestExternalRegistrationCOIAgreeHelper {

    static testMethod void testWhenClicked() {
        ExternalRegistrationCOIAgreeHelper extReg= new ExternalRegistrationCOIAgreeHelper();  
        //Test.startTest();
       // FOALead__c fOALead = TestHelper.getFOALead(true);
        UserRegistration__c uReg = new UserRegistration__c();
        uReg.OrganizationName__c ='TestORG';
        uReg.LastName__c = 'Betty';
        uReg.username__c = System.now().millisecond() + 'test@123test.com';
        uReg.EINo__c = Math.Random();
        uReg.Email__c = 'test15@test.com';
        //uReg.RecordType.DeveloperName = 'Reviewer';
        insert uReg;
         Test.startTest();
        
     
         
         ApexPages.StandardController sc = new ApexPages.standardController(uReg);
         ApexPages.currentPage().getParameters().put('Id',uReg.Id);
       
         
    
        extReg.whenClicked();
        Test.stopTest();      
    }
}