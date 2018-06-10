/**
* @author: Sarat Mahavratayajula. 2016-08-03
*/
@isTest
private with Sharing class TestUSPSAddressInformationCtrl {
    
    @isTest
    public static void test1 () {

        // Skip unwanted triggers
        UserRegistrationTriggerHelper.skipTrigger = true;

        USPSAddress uspsAddress = new USPSAddress();
        uspsAddress.Address1 = 'Some address 1';
        uspsAddress.Address2 = 'Some Address 2';
        uspsAddress.City = 'Some City ';
        uspsAddress.State = 'Some State';
        uspsAddress.Zip5 = '25789';
        uspsAddress.Zip4 = '1245';

        Id recordTypeId1 = TestHelper.getRecordType(Schema.Sobjecttype.UserRegistration__c,'Applicant');

        UserRegistration__c userReg = new UserRegistration__c();
        userReg.RecordTypeId = recordTypeId1;
        userReg.FirstName__c = 'testFirstName';
        userReg.City__c = 'testCity';
        userReg.State__c = 'testState';
        userReg.Street__c = 'testStreet';
        userReg.PhysicalCountry__c = 'testPhysicalCountry';
        userReg.ZipCode__c = 'testZip';
        insert userReg;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockUSPSAddressInformationCtrlResponse());
            USPSAddressInformationCtrl.CheckAddress(uspsAddress);
        Test.stopTest();
        
    }
}