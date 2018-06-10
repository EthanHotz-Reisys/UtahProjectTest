/*
    This class has methods to execute methods related to account trigger
    **********************************************************
    Audit History
    **********************************************************
    2014-03-11  Manasi Gangal       Created
    2014-04-17  Ryan Chadwick       Modified - SOQL LIMIT clauses
    2014-04-28  Glen Watson         Formatted & refactored
    2015-02-24  William Moore       Added renameCommunityGroup
    2015-02-24  Tanmay Deshpande    Added autoCreateUserRegistrations
    2015-08-06  Shrawan Raina       Modified Inactivated all method calls and Activating the calling Trigger for Person Account
    **********************************************************
*/

public with sharing class AccountTriggerHelper extends GNT.TriggerHelper {
    public static boolean skipRoleDeletion = false;
    public static boolean skipAll = false;
    public static boolean skipTrigger = false;
    public static List<account> duplicateAccounts;


    public override void processBeforeInsert() {
        if (skipAll == false) {
            insertLatLong();
            filterDuplicateAccounts();
            checkAccountNameAndTypeOnInsert();
            updateFedAssuranceID();
            if (!skipTrigger) {
                updateParentAccount(); // If internal account is insert and Parent is not specified Make Enterprise as the Parent Account
            }
        }
    }

    public override void processAfterInsert() {
        if (skipAll == false) {

            system.debug('Trigger.New-------->>>>' + Trigger.New);
            system.debug('Trigger.NewMap-------->>>>' + Trigger.NewMap);
            updateParentRecordCount(selectParentIds(Trigger.new));
            createQueueForRecipient((List<Account>)Trigger.new);
            if (!System.isFuture() && !System.isBatch()) {
                updateRoleHierarchyOnInsert(selectedIds(trigger.new));
            }


        }//Todo
        /* 1.Write this into a try catch block*/
    }


    public override void processBeforeDelete() {
        if (skipAll == false) {
            validateAccountOnDelete();
        }
    }

    public override void processBeforeUpdate() {
        if (skipAll == false) {
            insertLatLong();
            checkAccountNameAndTypeOnUpdate();
            updateStatus();
            updateFedAssuranceID();


        }

    }



    public override void processAfterDelete() {
        //only update records that still exist
        /*
        Set<Id> existingIds = new Set<Id>();
        for(Account acct : [SELECT Id FROM Account WHERE Id IN :selectParentIds(Trigger.old)]) {
            existingIds.add(acct.Id);
        }
        updateParentRecordCount(existingIds);
        */
    }


    @TestVisible private void updateParentAccount() {
        //If the current record is the root (ENTERPRISE) account, then ignore the validation and keep parent id as null.
        if (Trigger.new.size() == 1 && Trigger.New.get(0).get('Name') == GNT.KeyValueStoreHelper.getTextValue('ENTERPRISE', true)) {
            return;
        }

        Id recordTypeInternalId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Internal').getRecordTypeId();

        List<Account> enterPriseAccount = [Select Id from Account where Name = : GNT.KeyValueStoreHelper.getTextValue('ENTERPRISE', true) and RecordType.Name = :'Internal'];

        System.debug('>>>>>>>>>>' + enterPriseAccount);
        System.debug('>>>>>>>>>>' + enterPriseAccount.size());

        if (enterPriseAccount.size() == 0) {
            for (Account acc : (List<Account>)Trigger.new) {
                //acc.addError('Enterprise Account is not Set');
                acc.addError(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-45897'));
            }
            return;
        }

        for (Account acc : (List<Account>)Trigger.new) {
            if (acc.RecordTypeId == recordTypeInternalId && acc.ParentId == null) {
                acc.ParentId = enterPriseAccount[0].Id;
            }
        }
    }


    public override void processAfterUpdate() {

        //optimization: don't recalculate accounts whose children haven't been reparented
        Set<Id> childAccountsChanged = new Set<Id>();
        for (Account newAccount : (Account[])Trigger.new) {
            Account oldAccount = (Account)Trigger.oldMap.get(newAccount.Id);
            if (newAccount.parentId != oldAccount.parentId) {
                if (newACcount.parentId != null) {
                    childAccountsChanged.add(newACcount.parentId);
                }
                if (oldAccount.parentId != null) {
                    childAccountsChanged.add(oldAccount.parentId);
                }
            }
            if (newAccount.Name != oldAccount.Name) {
                //   renameCommunityGroup(newAccount.Name, oldAccount.Name);
            }
        }
        updateParentRecordCount(childAccountsChanged);
        updateRoleHierarchy();

        /* // Not Sure about this functionality yet
        Boolean autoCreateUserRegRecords = GNT.KeyValueStoreHelper.getBooleanValue('AutoCreateUserRegistrationRecords',true);
            if(autoCreateUserRegRecords){
                autoCreateUserRegistrations();
            }
         */
    }

    private void createQueueForRecipient(List<Account> newAccountList) {
        List<Account> recipientAccountList = new List<Account>();
        for (Account acc : newAccountList) {
            if (acc.RecordTypeName__c == 'Recipient') {
                recipientAccountList.add(acc);
            }
        }

        List<Group> newQueueList = new List<Group>();
        for (Account acc : recipientAccountList) {
            Group g = new Group(Type = 'Queue',  Name = 'SubQueue' + acc.Id, DeveloperName = 'SubQueue' + acc.Id);
            newQueueList.add(g);
        }
        insert newQueueList;

        if (!System.isFuture() && !System.isBatch()) {
            createSobjectSupport((new Map<Id, Group>(newQueueList)).keySet());
        }
    }

    @future
    private static void createSobjectSupport(Set<Id> queueIdSet) {
        List<Group> newQueueList = new List<Group>([SELECT Id, Name FROM Group WHERE Id IN :queueIdSet AND Type = 'Queue']);
        List<QueueSObject> newQueueSobjectList = new List<QueueSObject>();
        for (Group q : newQueueList) {
            QueueSObject appQ = new QueueSObject(SobjectType = 'Application__c', QueueId = q.Id);
            QueueSObject grantQ = new QueueSObject(SobjectType = 'Grant__c', QueueId = q.Id);
            newQueueSobjectList.add(appQ);
            newQueueSobjectList.add(grantQ);
        }
        insert newQueueSobjectList;
    }

    private void filterDuplicateAccounts() {
        Map<String, Account> existingAccountsMap = new Map<String, Account>();
        duplicateAccounts = new List<Account>();
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('External').getRecordTypeId();
        List<Account> existingAccountsList = [SELECT Id, Name, EINText__c, DUNS__c FROM Account WHERE RecordTypeId = :recordTypeId];
        if (existingAccountsList.size() > 0) {
            for (Account acc : existingAccountsList) {
                if (!String.isEmpty(acc.EINText__c) && !String.isEmpty(acc.DUNS__c)  ) {
                    String einDunsCombination = acc.EINText__c + '' + acc.DUNS__c;
                    existingAccountsMap.put(einDunsCombination, acc);
                }
            }
        }

        for (Account acc : (List<Account>)Trigger.new) {
            String einDunsCombo = acc.EINText__c + '' + acc.DUNS__c;
            if (existingAccountsMap != null) {
                Account duplicate = existingAccountsMap.get(einDunsCombo);
                if (duplicate != null) {
                    //acc.addError('Duplicate Account with Same Combination EIN and DUNS');
                    acc.addError(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-45862'));
                    duplicateAccounts.add(acc);
                }
            }
        }

    }

    /*SM    private void autoCreateUserRegistrations(){
            try{
                List<UserRegistration__c> userRegistrationsList = new List<UserRegistration__c>();
                Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('External').getRecordTypeId();
                for(Account acc : (List<Account>)Trigger.New){
                    if(acc.RecordTypeId == recordTypeId){
                        UserRegistration__c userReg = new UserRegistration__c();
                        userReg.IsAutoCreteatedRecord__c = true;
                        userReg.Status__c = 'Approved';
                        GNT.AppUtils.copyRecord(acc,userReg, false);
                        userRegistrationsList.add(userReg);
                    }
                }
                if(userRegistrationsList.size() > 0){
                    database.insert(userRegistrationsList,false);
                }
            //    sendMailToAdminAfterUserRegUpload(userRegistrationsList);
            }
            catch(DMLException e){
                String errorMessage = e.getMessage();
            }
        }   */

    /*SM    private void sendMailToAdminAfterUserRegUpload(List<userRegistration__c> userRegistrationsList){
            String emailSubject = 'Bulk creation of user registration records';
            String emailHtmlBody = 'Hi '+ UserInfo.getFirstName() +',' +' following User Registration records have been created successfully<br/>';
            List<String> emailAddress = New List<String>{UserInfo.getUserEmail()};
            emailHtmlBody += '<table border="1" style="width:50%">';
                emailHtmlBody += '<tr>';
                emailHtmlBody += '<td>';
                emailHtmlBody += 'Organization Name';
                emailHtmlBody += '</td>';
                emailHtmlBody += '<td>';
                emailHtmlBody += 'EIN';
                emailHtmlBody += '</td>';
                emailHtmlBody += '<td>';
                emailHtmlBody += 'DUNS';
                emailHtmlBody += '</td>';
                emailHtmlBody += '</tr>';
                for(UserRegistration__c userReg : userRegistrationsList){
                    emailHtmlBody += '<tr>';
                    emailHtmlBody += '<td>';
                    emailHtmlBody += userReg.OrganizationName__c;
                    emailHtmlBody += '</td>';
                    emailHtmlBody += '<td>';
                    emailHtmlBody += userReg.EINText__c;
                    emailHtmlBody += '</td>';
                    emailHtmlBody += '<td>';
                    emailHtmlBody += userReg.DUNS__c;
                    emailHtmlBody += '</td>';
                    emailHtmlBody += '</tr>';
                }
                emailHtmlBody += '</table>';
                GNT.AppUtils.sendEmail(emailAddress,emailSubject,'',emailHtmlBody);
        }   */

    /*SM    private void sendMailToAdminAfterAccountsUpload(){
            String emailSubject = 'Bulk creation of external organization(Account) records';
            String emailHtmlBody = 'Hi '+ UserInfo.getFirstName() +',' +' following External Organization records are duplicate and are not inserted successfully.<br/>';
            List<String> emailAddress = New List<String>{UserInfo.getUserEmail()};
            emailHtmlBody += '<table border="1" style="width:50%">';
                emailHtmlBody += '<tr>';
                emailHtmlBody += '<td>';
                emailHtmlBody += 'Organization Name';
                emailHtmlBody += '</td>';
                emailHtmlBody += '<td>';
                emailHtmlBody += 'EIN';
                emailHtmlBody += '</td>';
                emailHtmlBody += '<td>';
                emailHtmlBody += 'DUNS';
                emailHtmlBody += '</td>';
                emailHtmlBody += '</tr>';
                for(Account acc : duplicateAccounts){
                    emailHtmlBody += '<tr>';
                    emailHtmlBody += '<td>';
                    emailHtmlBody += acc.Name;
                    emailHtmlBody += '</td>';
                    emailHtmlBody += '<td>';
                    emailHtmlBody += acc.EINText__c;
                    emailHtmlBody += '</td>';
                    emailHtmlBody += '<td>';
                    emailHtmlBody += acc.DUNS__c;
                    emailHtmlBody += '</td>';
                    emailHtmlBody += '</tr>';
                }
                emailHtmlBody += '</table>';
                GNT.AppUtils.sendEmail(emailAddress,emailSubject,'',emailHtmlBody);
        }   */

    /* This method checks if Account to be deleted has child Accounts and refrains from deleting the Account by throwing error */
    private void validateAccountOnDelete() {
        List<Account> accounts = trigger.old;
        Set<String> accountList = new Set<String>();
        for (Account account : accounts) {
            if (account.ChildRecordCount__c > 0) {
                //account.addError('Account cannot be deleted as it has child accounts associated with it.');
                account.addError(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-81915'));
            } else {
                accountList.add(account.Name);
            }
        }
        if (accountList != null && accountList.size() > 0 && !System.isBatch() && !System.isFuture() && !skipRoleDeletion) {
            deleteRoleRelatedToAccount(accountList);
        }
    }



    /* This method delete the roles associated to the account to be deleted */
    @future
    private static void deleteRoleRelatedToAccount(Set<String> accountNames) {

        List<UserRole> roles = new List<UserRole>();
        List<UserRole> userRoles = [select Id, Name from UserRole where Name in:accountNames];
        Map<String, UserRole > userRoleMap = new Map<String, UserRole>();
        for (UserRole role : userRoles) {
            userRoleMap.put(role.Name, role);
        }

        for (String accountName : accountNames) {
            UserRole role = userRoleMap.get(accountName);
            if (role != null) {
                roles.add(role);
            }
        }
        if (roles != null && roles.size() > 0 ) {
            if (Schema.sObjectType.UserRole.isDeletable()) {
                delete roles;
            }
        }
    }

    private static Set<ID> selectedIds(List<Account> accounts) {
        Set<Id> accountIds = new Set<ID>();
        for (Account a : accounts) {
            accountIds.add(a.Id);
        }
        return accountIds;
    }
    private static Boolean checkIfUniqueOrganization(List<Account> newAccount) {
        // Set a boolean variable that will decide whether or not to fire a query for
        // organization check
        Boolean checkForOrg = false;
        for (Account account : newAccount) {
            if (account.type == 'Organization') {
                checkForOrg = true;
            }
        }
        if (checkForOrg) {
            List<Account> accountList = [select name, type from Account where type = 'Organization'];
            if (accountList != null && accountList.size() > 0) {
                return true;
            }
        }

        return false;
    }

    /* Method to check if name is unique and add an error message */
    private void checkAccountNameAndTypeOnInsert() {
        Map<String, Account> accountMap = checkIfUniqueName(Trigger.new);
        Boolean orgExists = checkIfUniqueOrganization(Trigger.new);
        for (Account account : (List<Account>)Trigger.new) {
            if (accountMap.get(account.name) != null) {
                //account.addError('Name exists.Please enter unique name.');
                account.addError(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-57495'));
            } else if (account.type == 'Organization') {
                if (orgExists) {
                    //account.addError('Only one Organization can exist in the hierarchy.');
                    account.addError(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-32422'));
                }
            }
        }
    }
    /* Method to check if name is unique and add an error message */
    private void checkAccountNameAndTypeOnUpdate() {
        System.debug('checkAccountNameAndTypeOnUpdate - Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getLimitQueries());
        Map<String, Account> accountMap = checkIfUniqueName(Trigger.new);
        Map<Id, Account> oldaccountMap = (Map<Id, Account>)Trigger.oldMap;
        Boolean orgExists = checkIfUniqueOrganization(Trigger.new);
        for (Account account : (List<Account>)Trigger.new) {
            if (accountMap .get(account.name) != null && oldaccountMap.get(account.id).name != account.name) {
                //account.addError('Name exists.Please enter unique name');
                account.addError(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-57495'));
            } else if (oldaccountMap.get(account.id).type != 'Organization' && account.type == 'Organization') {
                if (orgExists) {
                    //account.addError('Only one Organization can exist in the hierarchy.');
                    account.addError(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-32422'));
                }
            }
        }
    }

    /* This method inserts a new Role when new account is created */
    @future
    private static void updateRoleHierarchyOnInsert(Set<Id> accountIds) {
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        List<Account> accounts = [select Name, RecordTypeId, Parent.Name, ParentId from Account where Id in :accountIds];
        Set<String> accountNames = new Set<String>();
        for (Account a : accounts) {
            if (a.ParentId != null) {
                accountNames.add(a.Parent.Name);
            }
            accountNames.add(a.Name);
        }
        List<UserRole> roleIds = new List<UserRole>();
        Map<String, UserRole> roleMap  = new Map<String, UserRole>();
        List<UserRole> userRoles = [select Name, DeveloperName, Id from UserRole where Name in :accountNames];

        for (UserRole role : userRoles) {
            roleMap.put(role.Name, role);
        }
        for (Account a : accounts) {
            if (a.RecordTypeId == recordTypeId) {
                UserRole role = new UserRole(Name = a.Name , DeveloperName = getName(a.Name));
                if (a.ParentId != null) {
                    UserRole parentRole = roleMap.get(a.Parent.Name);
                    if (parentRole != null) {
                        role.ParentRoleId = parentRole.Id;
                    }
                }

                roleIds.add(role);
            }
        }
        if (Schema.sObjectType.UserRole.isCreateable() && !skipTrigger) {
            insert roleIds;
        }
    }

    /*This method creates a set of Ids on which update is to be executed for creating roles*/
    public void updateRoleHierarchy() {
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        Set<Id> childAccountsParentChanged = new Set<Id>();
        Set<Id> childAccountsNameChanged = new Set<Id>();
        Map<Id, String> oldChildAccountsNameChanged = new Map<Id, String>();
        for (Account newAccount : (Account[])Trigger.new) {
            Account oldAccount = (Account)Trigger.oldMap.get(newAccount.Id);
            if (newAccount.RecordTypeId == recordTypeId) {
                if (newAccount.parentId != oldAccount.parentId) {
                    childAccountsParentChanged.add(newACcount.id);
                }
                if (newAccount.Name != oldAccount.Name) {
                    childAccountsNameChanged.add(newACcount.id);
                    oldChildAccountsNameChanged.put(oldAccount.Id, oldAccount.Name);
                }
            }
        }
        if (childAccountsParentChanged != null && childAccountsParentChanged.size() > 0) {

            updateParentRole(childAccountsParentChanged );
        }

        if (childAccountsNameChanged != null && childAccountsNameChanged.size() > 0) {
            updateRoleName(oldChildAccountsNameChanged, childAccountsNameChanged);
        }
    }

    private static Set<Id> selectParentIds(Account[] accounts) {
        Set<Id> parentIds = new Set<Id>();
        for (Account acct : accounts) {
            if (String.isNotBlank(acct.ParentId)) {
                parentIds.add(acct.parentId);
            }
        }
        return parentIds;
    }

    /* Method to fetch only alphanumeric content */
    private static string getName(String roleName) {
        Pattern isAlphaNumericPattern = Pattern.compile('[a-zA-Z0-9]+');
        Matcher isAlphaNumericMatcher = isAlphaNumericPattern.matcher(roleName);
        String newRoleName;
        while (isAlphaNumericMatcher.find()) {
            if (String.isEmpty(newRoleName)) {
                newRoleName =  isAlphaNumericMatcher.group();
            } else {
                newRoleName += isAlphaNumericMatcher.group();
            }
        }
        if (String.isEmpty(newRoleName))
            return roleName;
        return newRoleName;
    }

    /*Future method  is created to update roles as updating in same context throws MIX DML ERROR */

    @future
    private static void updateParentRole(Set<Id>accountIds) {
        List<Account> accountList = [select id, Name, Parent.Name, parentId from Account where id in:accountIds];
        Set<String> accountNames = new Set<String>();
        for (Account account : accountList) {
            accountNames.add(account.Name);
            if (account.Parent.Name != null) {
                accountNames.add(account.Parent.Name);
            }
        }
        List<UserRole> updatedRoleIds = new List<UserRole>();
        Map<String, UserRole> roleMap  = new Map<String, UserRole>();
        List<UserRole> userRoles = [select Name, DeveloperName, Id from UserRole where Name in :accountNames ];
        for (UserRole role : userRoles) {
            roleMap.put(role.Name, role);
        }
        for (Account account : accountList) {
            UserRole role  = roleMap.get(account.Name);
            if (role == null) {
                role = new UserRole(Name = account.Name, DeveloperName = getName(account.Name));
            }
            if (account.parentId != null) {
                UserRole parentRole =  roleMap.get(account.Parent.Name);
                role.ParentRoleId = parentRole.id;
            }
            updatedRoleIds.add(role);
        }
        //Weike , to skip test
        if (!Test.isRunningTest()) {
            if (Schema.sObjectType.UserRole.isUpdateable() && Schema.sObjectType.UserRole.isCreateable()) {
                upsert updatedRoleIds;
            }
        }
    }

    /* Method to update corresponding Role Name if account name changes */
    // @future
    private static void updateRoleName(Map<Id, String> oldAccName, Set<Id>accountIds) {
        List<Account> accountList = [select id, Name from Account where id in:accountIds];
        Set<String> accountNames = new Set<String>();
        for (Account account : accountList) {
            accountNames.add(account.Name);
        }
        List<UserRole> updatedRoleIds = new List<UserRole>();
        Map<String, UserRole> roleMap  = new Map<String, UserRole>();
        List<UserRole> userRoles = [select Name, DeveloperName, Id from UserRole where Name in :oldAccName.values()];
        for (UserRole role : userRoles) {
            roleMap.put(role.Name, role);
        }
        for (Account account : accountList) {
            UserRole role  = roleMap.get(oldAccName.get(account.Id));
            if (role == null) {
                role = new UserRole(Name = account.Name, DeveloperName = getName(account.Name));
            }
            role.Name = account.Name;
            role.DeveloperName = getName(account.Name);
            updatedRoleIds.add(role);
        }
        if (Schema.sObjectType.UserRole.isUpdateable() && Schema.sObjectType.UserRole.isCreateable()) {
            upsert updatedRoleIds;
        }
    }

    private static void updateParentRecordCount(Set<Id> accountIdsToUpdate) {
        //get the number of children for each account
        Map<Id, Account> accountsToUpdate = new Map<Id, Account>();
        for (AggregateResult aggResult : [SELECT parentId, COUNT(Id) cnt FROM Account WHERE parentId IN :accountIdsToUpdate GROUP BY parentId]) {
            Id id = (Id)aggResult.get('parentId');
            accountsToUpdate.put(id, new Account(Id = id, ChildRecordCount__c = (Integer)aggResult.get('cnt')));
        }
        //if there are no children COUNT(Id) doesn't return a row. Populate these manually
        for (Id accountId : accountIdsToUpdate) {
            if (!accountsToUpdate.containsKey(accountId)) {
                accountsToUpdate.put(accountId, new Account(Id = accountId, ChildRecordCount__c = 0));
            }
        }
        if (Schema.sObjectType.Account.isUpdateable()) {
            update accountsToUpdate.values();
        }
    }

    private static Map<String, Account> checkIfUniqueName(List<Account> newAccount) {
        Set<String> nameSet = new Set<String>();
        Map<String, Account> nameMap = new  Map<String, Account>();
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        for (Account account : newAccount) {
            if (account.RecordTypeId == recordTypeId) {
                nameSet.add(account.name);
            }
        }
        List<Account> accountList = [select name, type from Account where Name in :nameSet and RecordType.id = :recordTypeId ];

        if (accountList != null && accountList.size() > 0) {
            for (Account account : accountList) {
                nameMap.put(account.name, account);
            }
        }
        System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getLimitQueries() + ' - Size ' + newAccount.size());
        return nameMap;
    }

    /* METHOD TO UPDATE THE STATUS OF THE ACCOUNT IF AN ACTIVE ACCOUNT IS UPDATED*/
    private static void updateStatus() {
    }
    /*SM@future
        static void renameCommunityGroup(String newName, String oldName) {
            List<CollaborationGroup> groups = [SELECT id, Name FROM CollaborationGroup WHERE Name =: oldName LIMIT 1];
            if (groups.size() > 0) {
                groups[0].Name = newName;
                update groups[0];
            }
        }   */


    private void insertLatLong() {
        System.debug('insertLatLong - Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getLimitQueries());
        Map<String, Account> accountZipCode = new Map<String, Account>();

        for (Account acc : (List<Account>)Trigger.new) {
            // if billing zip code is 5-4 then just take the first  5 digits
            accountZipCode.put(acc.BillingPostalCode, acc);
        }

        List<USDemographicInfo__c> demoGraphicInfo = [Select Id, Name, Location__latitude__s, Location__longitude__s from  USDemographicInfo__c where Name in:accountZipCode.keyset()];
        Map<String, USDemographicInfo__c> zipLatLongMap = new Map<String, USDemographicInfo__c>();

        for (USDemographicInfo__c usdemoInfo : demoGraphicInfo) {
            zipLatLongMap.put(usdemoInfo.Name, usdemoInfo);
        }

        for (Account acc : (List<Account>)Trigger.new) {
            USDemographicInfo__c demoInfo = zipLatLongMap.get(acc.BillingPostalCode);
            if (demoInfo != null) {
                acc.Location__longitude__s = demoInfo.Location__longitude__s;
                acc.Location__latitude__s = demoInfo.Location__latitude__s;
            }
        }
        System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getLimitQueries());
    }

    private void updateFedAssuranceID() {
        Document doc = [SELECT ID, developername from Document where DeveloperName = 'FederalAssurances' LIMIT 1];
        for (Account account : (List<Account>)Trigger.new) {
            //account.docID__c = doc.ID;
            account.FederalAssuranceForm__c = '/servlet/servlet.FileDownload?file=' + doc.id;
        }
    }


}