@isTest
private with sharing class TestFormEdit{
    static testMethod void testController() {
       
          User u = TestHelper.getAdminUser(true);
          System.runAs(u){
              
              Form__c form = new Form__c();
              insert form;

              GNT__PageLayoutConfig__c testLayout =TestHelper.getPageLayoutConfig(false);
              testLayout.Name='Test View Layout';
              testLayout.GNT__Description__c='Test Page Layout';
              testLayout.GNT__ObjectAPIName__c='Form__c';
              insert testLayout;

              
              GNT__PageTemplate__c pageTemp = TestHelper.ggsTempPack1_PageTemplate(false);
              pageTemp.GNT__EditLayoutConfig__c =testLayout.Id;
              pageTemp.GNT__PrintLayoutConfig__c = testLayout.Id;
              pageTemp.GNT__ViewLayoutConfig__c = testLayout.Id;
              pageTemp.GNT__OMBNumber__c=form.Id;
              pageTemp.GNT__PackageType__c='Application';
              pageTemp.GNT__ParentObjectFieldAPI__c='Application__c';
              pageTemp.GNT__SObjectName__c='Form__c';
              insert pageTemp;
              
              GNT__Package__c tempPack = TestHelper.getPackage(true,pageTemp.Id);
              
              GNT__PackageFormConfig__c pkgConfig = new GNT__PackageFormConfig__c(GNT__PackageConfig__c=tempPack.Id,GNT__FormConfig__c=pageTemp.Id);
              insert pkgConfig;
              
              Test.startTest();
              ApexPages.StandardController sc = new ApexPages.standardController(form);
              ApexPages.currentPage().getParameters().put('id',form.id);
              ApexPages.currentPage().getParameters().put('pkId',tempPack.id);
              ApexPages.CurrentPage().getParameters().put('template',pageTemp.Name);
              FormEdit ctrl = new FormEdit(sc);
              ctrl.savePage = new PageReference('myPage.testPage1');
              ctrl.cancelPage = new PageReference('myPage.testPage2');
              ctrl.templateName = 'Test Template';
              Test.stopTest();
          }
        
    }
    
       static testMethod void testController2() {
       
          User u = TestHelper.getAdminUser(true);
          System.runAs(u){
              
              Form__c form = new Form__c();
              insert form;

              GNT__PageLayoutConfig__c testLayout =TestHelper.getPageLayoutConfig(false);
              testLayout.Name='Test View Layout';
              testLayout.GNT__Description__c='Test Page Layout';
              testLayout.GNT__ObjectAPIName__c='Form__c';
              insert testLayout;

              
              GNT__PageTemplate__c pageTemp = TestHelper.ggsTempPack1_PageTemplate(false);
              pageTemp.GNT__EditLayoutConfig__c =testLayout.Id;
              pageTemp.GNT__PrintLayoutConfig__c = testLayout.Id;
              pageTemp.GNT__ViewLayoutConfig__c = testLayout.Id;
              pageTemp.GNT__OMBNumber__c=form.Id;
              pageTemp.GNT__PackageType__c='Application';
              pageTemp.GNT__ParentObjectFieldAPI__c='Application__c';
              pageTemp.GNT__SObjectName__c='Form__c';
              insert pageTemp;
              
              GNT__Package__c tempPack = TestHelper.getPackage(true,pageTemp.Id);
              
              GNT__PackageFormConfig__c pkgConfig = new GNT__PackageFormConfig__c(GNT__PackageConfig__c=tempPack.Id,GNT__FormConfig__c=pageTemp.Id);
              insert pkgConfig;
              
              Test.startTest();
              ApexPages.StandardController sc = new ApexPages.standardController(form);
              ApexPages.currentPage().getParameters().put('id',form.id);
              ApexPages.currentPage().getParameters().put('pkId',pkgConfig.id);
              ApexPages.CurrentPage().getParameters().put('template',pageTemp.Name);
              FormEdit ctrl = new FormEdit(sc);
              ctrl.savePage = new PageReference('myPage.testPage1');
              ctrl.cancelPage = new PageReference('myPage.testPage2');
              ctrl.templateName = 'Test Template';
              Test.stopTest();
          }
        
    }
}