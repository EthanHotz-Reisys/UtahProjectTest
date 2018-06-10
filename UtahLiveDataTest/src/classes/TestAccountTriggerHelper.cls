@isTest
public class TestAccountTriggerHelper {
    
    @isTest static void test_method_insert() {
    
    /*
        User currentUser = TestHelper.getAdminUser(false);
        system.debug('currentUser ' + currentUser.Name);

        //GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c', 'StateasGrantee');
        AccountTriggerHelper.skipTrigger=true;

        Id recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Internal').getRecordTypeId(); 
        Account enterAcc = new Account(Name = 'ENTERPRISE',RecordTypeId = recTypeId);
        insert enterAcc;
        system.debug('Account Name ' + enterAcc.Name);
        GNT__KeyValueStore__c ea = new GNT__KeyValueStore__c(Name='ENTERPRISE',GNT__TextValue__c='ENTERPRISE',
                                                    GNT__Description__c='This is the Enterprise account that is set in the Role hierarchy the corresponding Account is also created',
                                                    GNT__Admin_Question__c = 'Loren Ipsum');

        insert ea;        
        system.debug('KeyValueStoreHelper Name ' + GNT.KeyValueStoreHelper.getTextValue('ENTERPRISE',true));


        system.runAs(currentUser){
            Account acc = TestHelper.getAccount(true);
            TestHelper.getAccount(acc.Id, false) ;
        }
*/
    }
    /////////////////////////////
     @isTest static void test_method_insert1() {
     
     /*
        User currentUser = TestHelper.getAdminUser(false);
        system.debug('currentUser ' + currentUser.Name);

        //GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c', 'StateasGrantee');
        AccountTriggerHelper.skipTrigger=true;

        Id recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('External').getRecordTypeId(); 
        //Account enterAcc = new Account(Name = 'ENTERPRISE',RecordTypeId = recTypeId);
         Account account = TestHelper.getAccount(false);
          account.ApplicantType__c = 'State governments';
          account.type = 'Customer';
          account.EINText__c = '999';
          account.DUNS__c= '888';
          account.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('External').getRecordTypeId();
          insert account;
        
        //insert enterAcc;
        //system.debug('Account Name ' + enterAcc.Name);
        GNT__KeyValueStore__c ea = new GNT__KeyValueStore__c(Name='ENTERPRISE',GNT__TextValue__c='ENTERPRISE',
                                                    GNT__Description__c='This is the Enterprise account that is set in the Role hierarchy the corresponding Account is also created',
                                                    GNT__Admin_Question__c = 'Loren Ipsum');

        insert ea;        
        system.debug('KeyValueStoreHelper Name ' + GNT.KeyValueStoreHelper.getTextValue('ENTERPRISE',true));


        system.runAs(currentUser){
            Account acc = TestHelper.getAccount(true);
            TestHelper.getAccount(acc.Id, false) ;
        }
*/
    }
    ////////////////////////////
    
    @isTest static void test_method_delete() {
    /*
        User currentUser = TestHelper.getAdminUser(false);
        system.debug('currentUser ' + currentUser.Name);

        //GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c', 'StateasGrantee');
        AccountTriggerHelper.skipTrigger=true;

        Id recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Internal').getRecordTypeId(); 
        Account enterAcc = new Account(Name = 'ENTERPRISE',RecordTypeId = recTypeId);
        Test.startTest();
        System.runas(new User(Id = UserInfo.getUserId())){
                insert enterAcc;
            }
        
        system.debug('Account Name ' + enterAcc.Name);
        GNT__KeyValueStore__c ea = new GNT__KeyValueStore__c(Name='ENTERPRISE',GNT__TextValue__c='ENTERPRISE',
                                                    GNT__Description__c='This is the Enterprise account that is set in the Role hierarchy the corresponding Account is also created',
                                                    GNT__Admin_Question__c = 'Loren Ipsum');
        
        System.runas(new User(Id = UserInfo.getUserId())){
             insert ea;
        }
                
        system.debug('KeyValueStoreHelper Name ' + GNT.KeyValueStoreHelper.getTextValue('ENTERPRISE',true));

        Account parent = new Account(Name = 'test');
            System.runas(new User(Id = UserInfo.getUserId())){
                insert parent;
            }
        UserRole userRole = new UserRole(Name = 'test', DeveloperName = 'test');
        System.runas(new User(Id = UserInfo.getUserId())){
             insert userRole;
        }
        enterAcc.parentId = parent.Id;
        System.runas(new User(Id = UserInfo.getUserId())){
             update enterAcc;
        }
        Test.stopTest();
        system.runAs(currentUser){
            Account acc = TestHelper.getAccount(true);
            TestHelper.getAccount(acc.Id, false) ;
            Delete acc;
        }
*/
    }

    @isTest static void test_method_update() {
    /*
        User currentUser = TestHelper.getAdminUser(false);
        system.debug('currentUser ' + currentUser.Name);

        //GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c', 'StateasGrantee');
        AccountTriggerHelper.skipTrigger=true;

        Id recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Internal').getRecordTypeId(); 
        Account enterAcc = new Account(Name = 'ENTERPRISE',RecordTypeId = recTypeId);
        insert enterAcc;
        system.debug('Account Name ' + enterAcc.Name);
        GNT__KeyValueStore__c ea = new GNT__KeyValueStore__c(Name='ENTERPRISE',GNT__TextValue__c='ENTERPRISE',
                                                    GNT__Description__c='This is the Enterprise account that is set in the Role hierarchy the corresponding Account is also created',
                                                    GNT__Admin_Question__c = 'Loren Ipsum');

        insert ea;        
        system.debug('KeyValueStoreHelper Name ' + GNT.KeyValueStoreHelper.getTextValue('ENTERPRISE',true));


        system.runAs(currentUser){
            Account acc = TestHelper.getAccount(true);
            Account acc1 = [Select Name from Account where Id = :acc.Id];
            acc1.Name = 'Update Account';
            update acc1;
        }
*/
    }
    
}