@isTest
private class TestManageInterfaceViewCtrl{

  @isTest static void testController() {

    List<InterfaceConfig__c> interfaceConfigs = new List<InterfaceConfig__c>();

    InterfaceConfig__c interfaceConfig1 = new InterfaceConfig__c();
    interfaceConfig1.Name = 'GuideStar/Simplify Interface';
    interfaceConfig1.isEnabled__c = true;  
    interfaceConfig1.Password__c = 'somepassword';
    interfaceConfig1.Product_Id__c = '/products';
    interfaceConfig1.Purpose__c = 'some purpose';
    interfaceConfig1.Url__c = 'https://Sometest.guidestar.org/';
    interfaceConfig1.Username__c = 'someUserName1';
    interfaceConfig1.Version__c = 'v1/charitycheck/';
    interfaceConfig1.API_Key__c = '4b6dv37fq3cbq147a591a11038029c20';

    InterfaceConfig__c interfaceConfig2 = new InterfaceConfig__c();
    interfaceConfig2.Name = 'Dun and Bradstreet Interface';
    interfaceConfig2.isEnabled__c = false;  
    interfaceConfig2.Password__c = 'somepassword2';
    interfaceConfig2.Product_Id__c = '/DCP_STD';
    interfaceConfig2.Purpose__c = 'some purpose 2';
    interfaceConfig2.Url__c = 'https://someservice.dnb.com/';
    interfaceConfig2.Username__c = 'someUserName2';
    interfaceConfig2.Version__c = 'V5.0/organizations/';
    interfaceConfig1.API_Key__c = '6b1dv37fq3cbq147a591a11036722c20';

    interfaceConfigs.add(interfaceConfig1);
    interfaceConfigs.add(interfaceConfig2);

    insert interfaceConfigs;

    Test.startTest();     
      ManageInterfaceViewCtrl ctrl= new ManageInterfaceViewCtrl();
    Test.stopTest();
  }

}