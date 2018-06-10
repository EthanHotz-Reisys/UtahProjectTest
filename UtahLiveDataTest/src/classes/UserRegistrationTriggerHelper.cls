/**
    **********************************************************
    Audit History
    **********************************************************
    4/21/2014     Nakul Kadam         Created class
    09/08/2015    Shrawan Raina       Edited
    12/02/2015    swati singh         Edited
    **********************************************************
*/
public class UserRegistrationTriggerHelper extends GNT.TriggerHelper {
    public Boolean autoCreateUserRegRecords = GNT.KeyValueStoreHelper.getBooleanValue('AutoCreateUserRegistrationRecords', true);
    public static Boolean skipTrigger = false;
    public static Boolean skipAfterUpdate = false;
    public static Boolean skipBeforeUpdate = false;
    public override void processBeforeInsert() {
    }

    public override void processAfterInsert() {
    }

    public override void processBeforeUpdate() {
        List<UserRegistration__c> uRegListOldStatus = trigger.old;
        List<UserRegistration__c> uRegListNewStatus = trigger.new;
        if (skipBeforeUpdate == false) {
            if (uRegListOldStatus[0].status__c == 'Submitted for Approval' && uRegListNewStatus[0].status__c == 'Submitted for Approval') {
                uRegListNewStatus[0].addError('You cannot edit the record as it has already been submitted for approval');
            } else {
                CopyOrgToRepAdd();
                validateRepInformation();
                updateForAccountCreation(trigger.new);
                //setComment();
            }





        }
    }

    /* This method reviewerContactAndUserCreate is used to create contact and user for a reviewer through web , reviewer through email , Individual applicant */
    public override void processAfterUpdate() {

        if (skipAfterUpdate == false) {
            reviewerContactAndUserCreate(trigger.new);

        }
    }

    public void reviewerContactAndUserCreate(List<UserRegistration__c> uRegList) {
        List<Contact> contactList = new List<Contact>();
        List<Contact> contactListUpdate = new List<Contact>();
        List<Contact> contactListIndApp = new List<Contact>();
        List<Contact> contactListAddApp = new List<Contact>();
        List<Contact> contactListChildApp = new List<Contact>();
        List<Account> accountListChildApp = new List<Account>();

        List<RecordType> recordTypeReviewerList = new List<RecordType>();
        List<RecordType> recordTypeIndAppList = new List<RecordType>();
        List<RecordType> recordTypeAddAppList = new List<RecordType>();
        List<RecordType> recordTypeChildAppList = new List<RecordType>();

        Account account;
        Account accountInd;
        contact cont = new contact();
        Account accountAdd = new account();
        Account accountChild = new account();
        List<User> userList = new List<User>();

        List<RecordType> recordTypeList = [select Id, Name, SobjectType FROM RecordType where SobjectType = :AppUtils.getNameSpacePrefix() + 'UserRegistration__c' and Name IN('Reviewer', 'Ind Applicant', 'Additional Applicant', 'Additional Applicant Secondary', 'Applicant')];
        for (RecordType recordType : recordTypeList) {
            if (recordType.name == 'Reviewer') {
                recordTypeReviewerList.add(recordType);
            } else if (recordType.name == 'Ind Applicant') {
                recordTypeIndAppList.add(recordType);
            } else if (recordType.name == 'Additional Applicant') {
                recordTypeAddAppList.add(recordType);
            } else if (recordType.name == 'Additional Applicant Secondary') {
                recordTypeAddAppList.add(recordType);
            } else {
                recordTypeChildAppList.add(recordType);
            }
        }

        List<Account> accountList = [Select id, Name from Account where Name IN('SME Reviewer System Account', 'Individuals System Account')];
        for (Account acc : accountList) {
            if (acc.name == 'SME Reviewer System Account') {
                account = acc;
            } else if (acc.name == 'Individuals System Account') {
                accountInd = acc;
            }

        }

        List<Contact> ConList = new List<Contact>();
        ConList = [select id, name, Title, userRegistration__c from contact where userRegistration__c in: uRegList];
        Map<Id, Contact> contactMap = new Map<Id, Contact>();
        for (Contact U : ConList) {

            contactMap.put(u.userRegistration__c, u);

        }
        /* account map for update account */
        Set<Id> AccIdSet = new Set<Id>();
        for (UserRegistration__c uReg : uRegList) {
            AccIdSet.add(uReg.Account__c);
        }
        List<Account> AccList = new List<Account>();
        AccList = [select id, name, UserRegistration__c from Account where ID in: AccIdSet];
        Map<Id, Account> accountMap = new Map<Id, Account>();
        for (Account a : AccList) {

            accountMap.put(a.UserRegistration__c, a);

        }

        for (UserRegistration__c uReg : uRegList) {
            if (uReg.RecordTypeid == recordTypeReviewerList[0].id && uReg.Status__c == 'Approved' && uReg.Contact__c == NULL) {

                contactList = createExternalContact(uReg, account.Id);
                System.debug('contactList----->>>>' + contactList);

            } else if (uReg.RecordTypeid == recordTypeReviewerList[0].id && uReg.Status__c == 'Approved' && uReg.Contact__c != NULL) {
                contactListUpdate = updateExternalContact(uReg, contactMap, account.Id);

            } else if ((uReg.RecordTypeid == recordTypeAddAppList[0].id || uReg.RecordTypeid == recordTypeAddAppList[1].id) && uReg.Status__c == 'Approved' && uReg.Contact__c != NULL) {

                cont = [Select id, Name, accountId from contact where id = : uReg.Contact__c];
                accountAdd = [Select id, Name from Account where id = : cont.accountId];
                contactListAddApp = updateExtContAddApp(uReg, contactMap);

            } else if (uReg.RecordTypeid == recordTypeIndAppList[0].id && uReg.Status__c == 'Approved' && uReg.Contact__c == NULL ) {
                contactListIndApp = createExternalIndAppContact(uReg, accountInd.Id);

            }/*else  if(uReg.RecordTypeid ==recordTypeChildAppList[0].id && uReg.Status__c == 'Approved' && uReg.Contact__c != NULL && uReg.Contact__r.account.ParentID != NULL){

                  accountListChildApp = updateAccount(UReg,accountMap);
                  accountChild  = accountMap.get(uReg.Id);
                  contactListChildApp  = updateExtContAddApp(uReg,contactMap);
            } */
        }
        if (contactList.size() > 0) {
            insert contactList;
        }
        if (contactListIndApp.size() > 0) {
            insert contactListIndApp;
        }
        if (contactListUpdate.size() > 0) {
            update contactListUpdate;
        }
        if (contactListAddApp.size() > 0) {
            update contactListAddApp;
        }
        if (contactListChildApp.size() > 0) {
            update contactListChildApp;
        }
        if (accountListChildApp.size() > 0) {
            update accountListChildApp ;
        }
////////////////////////////////////////////////////////////
        // List<Contact> contactList1 = [select Id, Name FROM Contact where id=: contactList[0].id ];

        System.debug('contactList----->>>>contactList--' + contactList);
        System.debug('contactList----->>>>uRegList--' + uRegList);
        for (UserRegistration__c uReg : uRegList) {
            if (contactList.size() > 0) {
                for (Contact contact : contactList) {
                    system.debug('Ureg id is ' +uReg.Id+ ' Account Id is '+account.Id+' Contact id is '+contact.Id);
                    User user = createExternalUser(uReg, account, contact.Id);
                    System.debug('contactList----->>>>user --' + user );
                    userList.add(user);
                }
            } else if (contactListIndApp.size() > 0) {
                for (Contact contact : contactListIndApp) {
                    User user = createExternalUser(uReg, accountInd, contact.Id);
                    System.debug('contactListIndApp----->>>>user --' + user );
                    userList.add(user);
                }
            } else if (contactListUpdate.size() > 0) {
                for (Contact contact : contactListUpdate) {
                    User user = createExternalUser(uReg, account, contact.Id);
                    System.debug('contactListUpdate----->>>>user --' + user );
                    userList.add(user);
                }
            } else if (contactListAddApp.size() > 0) {
                for (Contact contact : contactListAddApp) {
                    User user = createExternalUser(uReg, accountAdd, contact.Id);
                    System.debug('contactListUpdate----->>>>user --' + user );
                    userList.add(user);
                }
            } else if (contactListChildApp.size() > 0) {
                for (Contact contact : contactListChildApp) {
                    User user = createExternalUser(uReg, accountChild, uReg.Contact__c);
                    System.debug('contactListUpdate----->>>>user --' + user );
                    userList.add(user);
                }
            }

        }
        System.debug('contactList----->>>>userList--' + userList);
        if (userList.size() > 0) {
            SystemContextMethodsHelper systemcontext = new SystemContextMethodsHelper();
            systemcontext.insertUsers(userList);
            //insert userList;
        }

////////////////////////////////////
    }

    public void updateForAccountCreation(List<UserRegistration__c> uRegList) {
        List<RecordType> recordTypeList = [select Id, Name, SobjectType FROM RecordType where SobjectType = :AppUtils.getNamespacePrefix() + 'UserRegistration__c' and Name = 'Applicant'];

        //List<UserRegistration__c> updateList = new List<UserRegistration__c>();
        for (UserRegistration__c uReg : uRegList) {

            if (uReg.RecordTypeid == recordTypeList[0].id && uReg.Status__c == 'Approved' && ((UserRegistration__c) Trigger.oldMap.get(uReg.Id)).Status__c == 'Verified') {
                uReg.AccountCreateFlag__c = true;
                //updateList.add(uReg);
            }
            if (uReg.RecordTypeid == recordTypeList[0].id && uReg.Status__c == 'Approved' && ((UserRegistration__c) Trigger.oldMap.get(uReg.Id)).Status__c == 'Submitted for Approval') {
                //uReg.AccountCreateFlag__c=true;
                //updateList.add(uReg);
                uReg.addError('Please click verify Button to Check for valid DUNs and EIN');
                // uReg.addError(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-91525'));


            }
        }
        /*if(updateList.size()>0){
            update updateList;
        }*/
    }

    /* Update a child recipient account after registration */
    private List<Account> updateAccount(UserRegistration__c uReg, Map<id, Account> accountMap) {
        List<Account> accountListUpdate = new List<Account>();
        Account account = accountMap.get(uReg.Id);
        account.OwnerId = [select id From User where Profile.Name = 'System Administrator' AND UserRoleId != null and isActive = true LIMIT 1].Id;
        account.Name = uReg.OrganizationName__c;
        account.EINText__c = uReg.EINText__c;
        account.Code__c = uReg.Name;
        account.ApplicantType__c = uReg.OrganizationTypeSInglePicklist__c ;
        account.ApplicantTypeOther__c = uReg.OrganizationTypeOther__c ;
        account.Phone = uReg.OrgnizationPhoneNumber__c;
        account.Fax = uReg.OrganizationFax__c ;
        account.Website = uReg.Website__c ;
        account.DCSupplySchedule__c = uReg.DCSupplySchedule__c ;
        account.FedralGSASchedule__c = uReg.FedralGSASchedule__c ;
        account.DUNS__c = uReg.DUNS__c ;
        account.DUNSExpirationDate__c = uReg.DUNSExpirationDate__c ;
        account.OrganizationFiscalYearStartDate__c = uReg.OrganizationFiscalYearStartDate__c;
        account.OrganizationFiscalYearEndDate__c = uReg.OrganizationFiscalYearEndDate__c ;
        account.Description = uReg.OrganizationDescription__c;
        account.BillingStreet = uReg.OrganizationStreetAddress__c;
        account.BillingCity = uReg.OrganizationCityAddress__c;
        account.BillingState = uReg.OrganizationState__c ;
        account.BillingPostalCode = uReg.OrganizationZipCode__c ;
        account.BillingCountry = uReg.OrganizationsCountry__c ;
        account.Status__c = 'Active';
        account.Comments__c = uReg.Comments__c;
        account.OrganizationID__c = uReg.Name;
        account.UserRegistration__c = uReg.Id;
        account.Sams__c = uReg.Sams__c;
        accountListUpdate.add(account);
        System.debug('accountListUpdate----->>>>' + accountListUpdate);
        return accountListUpdate;
    }


    /*
    create a contact for reviewer
    */
    private List<Contact> createExternalContact(UserRegistration__c uReg, Id accountId) {
        List<Contact> contactList = new List<Contact>();
        Contact portalContact = new Contact();
        portalContact.AccountId = accountId;
        portalContact.Title     =   uReg.ExternalReviewerPrefix__c;
        portalContact.FirstName =   uReg.ExternalReviewerFirstName__c;
        portalContact.LastName  =   uReg.ExternalReviewerLastName__c;
        portalContact.Address1__c   = uReg.ExternalReviewerAddress1__c;
        portalContact.Address2__c   = uReg.ExternalReviewerAddress2__c;
        portalContact.MailingCity   = uReg.ExternalReviewerCity__c;
        portalContact.MailingState  = uReg.StateDropdownList__c;
        portalContact.MailingPostalCode = uReg.ExternalReviewerZipCode__c;
        portalContact.MailingCountry    = uReg.ExternalReviewerCountry__c;
        portalContact.Phone = uReg.ExternalReviewerPhone__c;
        portalcontact.SponsoringAgency__c = uReg.SMESponsoringAgency__c;
        //portalContact.PositionTitle__c  = uReg.PrimaryRepTitle__c;
        portalContact.Email = uReg.ExternalReviewerEmail__c;
        portalContact.IsUser__c = true;
        portalContact.ReviewerStatus__c = 'Active';
        // portalContact.UniqueID__c = uReg.Name;
        portalContact.AffiliatedInstitution__c = uReg.AffiliatedInstitution__c;
        portalContact.Description = uReg.ExternalReviewerProfileDescription__c;
        portalContact.UniqueID__c = uReg.UniqueID__c;
        portalContact.PrimaryAreaOfExpertisePicklist__c = uReg.PrimaryAreaOfExpertisePicklist__c;
        portalContact.SecondaryAreaOfExpertisePicklist__c = uReg.SecondaryAreaOfExpertisePicklist__c;
        portalContact.TertiaryAreaOfExpertisePicklist__c = uReg.TertiaryAreaOfExpertisePicklist__c;
        portalContact.PrimaryAreaOfExpertise__c = uReg.PrimaryAreaOfExpertise__c;
        portalContact.SecondaryAreaOfExpertise__c = uReg.SecondaryAreaOfExpertise__c;
        portalContact.TertiaryAreaOfExpertise__c = uReg.TertiaryAreaOfExpertise__c;
        portalContact.Education__c = uReg.ExternalReviewerEducation__c;
        portalcontact.userregistration__c = uReg.Id;
        contactList.add(portalContact);
        System.debug('contactList----->>>>' + contactList);
        return contactList;
    }

    /*
     create a contact for ind applicant
    */
    private List<Contact> createExternalIndAppContact(UserRegistration__c uReg, Id accountId) {
        List<Contact> contactListIndApp = new List<Contact>();
        Contact portalContact = new Contact();
        portalContact.AccountId = accountId;
        portalContact.Title     =   uReg.PrimaryRepPrefix__c;
        portalContact.FirstName =   uReg.PrimaryRepFirstName__c;
        portalContact.LastName  =   uReg.PrimaryRepLastName__c;
        portalContact.Address1__c   = uReg.PrimaryRepAddress1__c;
        portalContact.Address2__c   = uReg.PrimaryRepAddress2__c;
        portalContact.MailingCity   = uReg.PrimaryRepCity__c;
        //DPS    portalContact.MailingState  = uReg.PrimaryRepState__c;
        portalContact.MailingPostalCode = uReg.PrimaryRepZipCode__c;
        portalContact.MailingCountry    = uReg.PrimaryRepCountry__c;
        portalContact.Phone = uReg.PrimaryRepPhone__c;
        portalContact.PositionTitle__c  = uReg.PrimaryRepTitle__c;
        portalContact.Email = uReg.PrimaryRepEmail__c;
        portalContact.IsUser__c = true;
        portalContact.UserRole__c = 'Primary';
        portalContact.UniqueID__c = uReg.UniqueID__c;
        portalContact.UniqueIdType__c = uReg.UniqueIdType__c;
        portalContact.AffiliatedInstitution__c = uReg.AffiliatedInstitution__c;
        portalContact.Description = uReg.ExternalReviewerProfileDescription__c;
        portalContact.Sams__c = uReg.Sams__c;
        contactListIndApp.add(portalContact);
        System.debug('contactListIndApp----->>>>' + contactListIndApp);
        return contactListIndApp;
    }

    /*
    update a contact for reviewer through email
    */
    private List<Contact> updateExternalContact(UserRegistration__c uReg, Map<id, Contact> ContactMap, Id accountId) {
        List<Contact> contactListUpdate = new List<Contact>();
        Contact portalContact = ContactMap.get(uReg.Id);
        //Contact portalContact = [SELECT Id, UserRegistration__c FROM Contact WHERE userRegistration__c =: ureg.id limit 1];
        //Contact portalContact = new Contact();
        portalContact.AccountId = accountId;
        portalContact.Title     =   uReg.ExternalReviewerPrefix__c;
        // portalContact.FirstName =   uReg.ExternalReviewerFirstName__c;
        // portalContact.LastName  =   uReg.ExternalReviewerLastName__c;
        portalContact.Address1__c   = uReg.ExternalReviewerAddress1__c;
        portalContact.Address2__c   = uReg.ExternalReviewerAddress2__c;
        portalContact.MailingCity   = uReg.ExternalReviewerCity__c;
        portalContact.MailingState  = uReg.StateDropdownList__c;
        portalContact.MailingPostalCode = uReg.ExternalReviewerZipCode__c;
        portalContact.MailingCountry    = uReg.ExternalReviewerCountry__c;
        portalContact.Phone = uReg.ExternalReviewerPhone__c;
        portalContact.IsUser__c = true;
        portalContact.ReviewerStatus__c = 'Active';
        portalContact.AffiliatedInstitution__c = uReg.AffiliatedInstitution__c;
        portalContact.Description = uReg.ExternalReviewerProfileDescription__c;
        //portalContact.PositionTitle__c  = uReg.PrimaryRepTitle__c;
        //portalContact.Email = uReg.ExternalReviewerEmail__c;
        portalContact.UniqueID__c = uReg.UniqueID__c;
        portalContact.PrimaryAreaOfExpertisePicklist__c = uReg.PrimaryAreaOfExpertisePicklist__c;
        portalContact.SecondaryAreaOfExpertisePicklist__c = uReg.SecondaryAreaOfExpertisePicklist__c;
        portalContact.TertiaryAreaOfExpertisePicklist__c = uReg.TertiaryAreaOfExpertisePicklist__c;
        portalContact.PrimaryAreaOfExpertise__c = uReg.PrimaryAreaOfExpertise__c;
        portalContact.SecondaryAreaOfExpertise__c = uReg.SecondaryAreaOfExpertise__c;
        portalContact.TertiaryAreaOfExpertise__c = uReg.TertiaryAreaOfExpertise__c;
        portalContact.Education__c = uReg.ExternalReviewerEducation__c;
        contactListUpdate.add(portalContact);
        System.debug('contactListUpdate----->>>>' + contactListUpdate);
        return contactListUpdate;
    }

    /*
        update a contact for additional applicant and child applicant through email
    */
    private List<Contact> updateExtContAddApp(UserRegistration__c uReg, Map<Id, Contact> contactMap) {
        List<Contact> contactListAddApp = new List<Contact>();
        Contact portalContact = contactMap.get(uReg.Id);
        System.debug(portalContact);
        System.debug(uReg.ExternalReviewerPrefix__c);
        //Contact portalContact = [SELECT Id, UserRegistration__c FROM Contact WHERE userRegistration__c =: ureg.id limit 1];
        portalContact.Title     =   uReg.ExternalReviewerPrefix__c;
        // portalContact.FirstName =   uReg.ExternalReviewerFirstName__c;
        // portalContact.LastName  =   uReg.ExternalReviewerLastName__c;
        portalContact.Address1__c   = uReg.PrimaryRepAddress1__c;
        portalContact.Address2__c   = uReg.PrimaryRepAddress2__c;
        portalContact.MailingCity   = uReg.PrimaryRepCity__c;
        //DPS    portalContact.MailingState  = uReg.PrimaryRepState__c;
        portalContact.MailingPostalCode = uReg.PrimaryRepZipCode__c;
        portalContact.MailingCountry    = uReg.PrimaryRepCountry__c;
        portalContact.Phone = uReg.PrimaryRepPhone__c;
        portalContact.IsUser__c = true;
        portalContact.ReviewerStatus__c = 'Active';
        //portalContact.PositionTitle__c  = uReg.PrimaryRepTitle__c;
        //portalContact.Email = uReg.ExternalReviewerEmail__c;
        contactListAddApp.add(portalContact);
        System.debug('contactListAddApp----->>>>' + contactListAddApp);
        return contactListAddApp;
    }

    /* create a user for a reviewer */
    private User createExternalUser(UserRegistration__c uReg, Account account, Id contactId) {
        User userObj = new User();
        //Contact contact =     [Select Id, FirstName, LastName, Email from Contact where id = :contactId];
        
        Contact contact =     [Select Id, FirstName, LastName, Email, ApplicantType__c, SponsoringAgency__c from Contact where id = :contactId];
        RecordType recType = [Select DeveloperName from RecordType where Id=:uReg.RecordTypeId];

        //RecordType recType = [Select Id,DeveloperName from RecordType where DeveloperName like :contact.ApplicantType__c];

        system.debug('Record type is ' +recType.Id + ' Record Type dev name is '+recType.DeveloperName);

        Id profileId = AppUtils.getCommunityProfileId(recType.DeveloperName);
        system.debug('profile Id is' +AppUtils.getCommunityProfileId(recType.DeveloperName));

        if (profileId != null) {
            List<User> UserList = new List<User>();
            string email = contact.Email + '%';
            System.debug('email ----->>>>' + email );
            UserList = [Select id from user where username like :email ];
            System.debug('UserList ----->>>>' + UserList );
            integer UniqueUsername = GNT.KeyValueStoreHelper.getIntegerValue('UniqueUsername', true);
            integer size = UserList.size() + UniqueUsername ;
            System.debug('size ----->>>>' + size );
            if (UserList.size() > 0) { userObj.Username = contact.Email + size + (DateTime.now().millisecond());}
            else { DateTime myDateTime = DateTime.now(); userObj.Username = contact.Email + (myDateTime.millisecond()); }
            System.debug('Username ----->>>>' + userObj.Username );
            /////////////////////////////////
            // userObj.Username = contact.Email+'SME';
            userObj.Email = contact.Email;
            userObj.FirstName = contact.FirstName;
            userObj.LastName = contact.LastName;
            userObj.SponsoringAgency__c = contact.SponsoringAgency__c;
            String nickname = contact.FirstName + ' ' + contact.LastName + '%';
            List<User> nicknameList = [Select id , username from user where CommunityNickname like :nickname];
            integer sizeNickName = nicknameList.size() + UniqueUsername;
            userObj.CommunityNickname = contact.FirstName + ' ' + contact.LastName + sizeNickName;
            String alias = contact.LastName;
            alias = alias.length() > 5 ? alias.substring(0, 4) : contact.LastName;
            userObj.Alias = alias ;
            String timeZoneKey = GNT.KeyValueStoreHelper.getTextValue('UserRegistrationTimeZoneSidKey', true);
            if (String.isEmpty(timeZoneKey)) {
                timeZoneKey = 'America/New_York';
            }
            userObj.TimeZoneSidKey = timeZoneKey;
            userObj.EmailEncodingKey = 'UTF-8' ;
            userObj.LanguageLocaleKey = 'en_US' ;
            userObj.LocaleSidKey = 'en_US' ;
            userObj.ContactId = contactId;
            userObj.profileId = profileId ;
            userObj.GNT__OrganizationId__c = account.Id;
            system.debug('userObj.GNT__OrganizationId__c----->>>>' + userObj.GNT__OrganizationId__c);
            userObj.OrganizationAccountName__c = account.Name;
            userObj.IsReviewer__c = uReg.IsReviewer__c ;
            userObj.IsApplicant__c = uReg.IsApplicant__c ;
            userObj.DepartmentCode__c = uReg.Name;
        }

        return userObj;
    }


    /*
         copy fields form POC to Applicant
    */
    private void CopyPOCToApplicant() {
        for (UserRegistration__c ureg : (List<UserRegistration__c>) Trigger.New) {
            if (ureg.IsApplicantSameAsPOC__c != false) {

                if (ureg.OrganizationStreetAddress__c != null) ureg.ApplicantAddress1__c =  ureg.OrganizationStreetAddress__c;
                if (ureg.StateDropdownList__c != null) ureg.PhysicalState__c = ureg.StateDropdownList__c;
                if (ureg.OrganizationZipCode__c != null) ureg.PhysicalZipCode__c = ureg.OrganizationZipCode__c;
                if (ureg.OrganizationsCountry__c != null) ureg.PhysicalCountry__c = ureg.OrganizationsCountry__c;
                if (ureg.OrganizationCityAddress__c != null) ureg.PhysicalCity__c = ureg.OrganizationCityAddress__c;
                if (ureg.PrimaryPOCPrefix__c != null) ureg.Prefix__c =  ureg.PrimaryPOCPrefix__c;
                if (ureg.PrimaryPOCFirstName__c != null) ureg.FirstName__c = ureg.PrimaryPOCFirstName__c;
                if (ureg.PrimaryPOCLastName__c != null) ureg.LastName__c = ureg.PrimaryPOCLastName__c;
                if (ureg.PrimaryPOCEmail__c != null) ureg.Email__c =  ureg.PrimaryPOCEmail__c;
                if (ureg.PrimaryPOCPhone__c != null) ureg.PhoneNumber__c = ureg.PrimaryPOCPhone__c;
                //ureg.Fax__c =  ureg.PrimaryPOCFax__c;

            }

        }
    }

    //Set comment to reject registrations

    //private void setComment(){
    //    List<UserRegistration__c> urgList = (List<UserRegistration__c>) Trigger.New;
    //    UserRegistration__c urg = new UserRegistration__c();
    //    if(urgList[0].Status__c == 'Rejected'){
    //        urg = urgList[0];
    //    }else{
    //        return;
    //    }
    //    ProcessInstance pi = new ProcessInstance();
    //    ProcessInstanceStep pr = new ProcessInstanceStep();

    //    pi = [Select id, TargetObjectId From ProcessInstance where TargetObjectId = :urg.Id order by CreatedDate DESC limit 1];
    //    pr = [Select id, CreatedDate, Comments From ProcessInstanceStep where ProcessInstanceId = :pi.Id AND StepStatus = 'Rejected' order by CreatedDate DESC limit 1];

    //    urg.Comments__c = pr.Comments;

    //    return;
    //}

    // To Validate Primary, Secondary Representative Information
    private void validateRepInformation() {
        for (UserRegistration__c ureg : (List<UserRegistration__c>) Trigger.New) {
            if (ureg.SecondaryRepresentativeRequired__c == true) {
                /*if(ureg.SecondaryRepFirstName__c==null) ureg.addError('Please provide First Name for Secondary Representative');
                if(ureg.SecondaryRepLastName__c==null) ureg.addError('Please provide Last Name for Secondary Representative');
                if(ureg.SecondaryRepAddress1__c==null) ureg.addError('Please provide Address Line 1 for Secondary Representative');
                if(ureg.SecondaryRepZipCode__c==null) ureg.addError('Please provide Zip Code for Secondary Representative');
                if(ureg.SecondaryRepCity__c==null) ureg.addError('Please provide City for Secondary Representative');
                if(ureg.SecondaryRepState__c==null) ureg.addError('Please provide State for Secondary Representative');
                if(ureg.SecondaryRepPhone__c==null) ureg.addError('Please provide Phone No. for Secondary Representative');
                if(ureg.SecondaryRepEmail__c==null) ureg.addError('Please provide Email for Secondary Representative');
                if(ureg.SecondaryRepEmail__c==ureg.PrimaryRepEmail__c) ureg.addError('Please provide different Email for Secondary Representative');*/
                if(ureg.SecondaryRepSponsoringAgency__c==null) ureg.addError('Please provide Sponsoring Agency for Secondary Representative');
                if (ureg.SecondaryRepFirstName__c == null) ureg.addError(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-54552'));
                if (ureg.SecondaryRepLastName__c == null) ureg.addError(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-44036'));
                if (ureg.SecondaryRepAddress1__c == null) ureg.addError(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-72638'));
                if (ureg.SecondaryRepZipCode__c == null) ureg.addError(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-80900'));
                if (ureg.SecondaryRepCity__c == null) ureg.addError(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-50103'));
                if (ureg.SecondaryRepState__c == null) ureg.addError(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-69577'));
                if (ureg.SecondaryRepPhone__c == null) ureg.addError(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-22095'));
                if (ureg.SecondaryRepEmail__c == null) ureg.addError(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-18201'));
                if (ureg.SecondaryRepEmail__c == ureg.PrimaryRepEmail__c) ureg.addError(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-75852'));

            } else {
                ureg.SecondaryRepFirstName__c = null;
                ureg.SecondaryRepLastName__c = null;
                ureg.SecondaryRepAddress1__c = null;
                ureg.SecondaryRepCity__c = null;
                ureg.SecondaryRepState__c = null;
                ureg.SecondaryRepPhone__c = null;
                ureg.SecondaryRepEmail__c = null;
                ureg.SecondaryRepZipCode__c = null;
                ureg.SecondaryRepAddress1__c = null;
            }
        }
    }

    /*
     copy fields from Organization Address to pri and sec rep address
    */
    private void CopyOrgToRepAdd() {
        List<RecordType> recordTypeList = [select Id, Name, SobjectType FROM RecordType where SobjectType = :AppUtils.getNamespacePrefix() + 'UserRegistration__c' and Name = 'Applicant'];
        for (UserRegistration__c ureg : (List<UserRegistration__c>) Trigger.New) {

            if (uReg.RecordTypeid == recordTypeList[0].id) {
                if (ureg.OrganizationStreetAddress__c != null) {
                    ureg.PrimaryRepAddress1__c =  ureg.OrganizationStreetAddress__c;
                    ureg.SecondaryRepAddress1__c =  ureg.OrganizationStreetAddress__c;
                }

                if (ureg.OrganizationStreet2Address__c != null) {
                    ureg.PrimaryRepAddress2__c =  ureg.OrganizationStreet2Address__c;
                    ureg.SecondaryRepAddress2__c =  ureg.OrganizationStreet2Address__c;
                }
                if (ureg.OrganizationZipCode__c != null) {
                    if (ureg.PrimaryRepZipCode__c == null) {
                        ureg.PrimaryRepZipCode__c = ureg.OrganizationZipCode__c;
                    }
                    if (ureg.SecondaryRepZipCode__c == null) {
                        ureg.SecondaryRepZipCode__c = ureg.OrganizationZipCode__c;
                    }
                }
                if (ureg.OrganizationCityAddress__c != null) {
                    ureg.PrimaryRepCity__c = ureg.OrganizationCityAddress__c;
                    ureg.SecondaryRepCity__c = ureg.OrganizationCityAddress__c;
                }
                if (ureg.StateDropdownList__c != null) {
                    ureg.PrimaryRepState__c = ureg.StateDropdownList__c;
                    ureg.SecondaryRepState__c = ureg.StateDropdownList__c;
                }
                // if(ureg.OrganizationsCountry__c!=null) ureg.PhysicalCountry__c = ureg.OrganizationsCountry__c;


            }

        }
    }


}