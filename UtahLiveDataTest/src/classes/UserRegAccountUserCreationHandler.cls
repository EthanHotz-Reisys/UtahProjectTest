global with sharing class UserRegAccountUserCreationHandler extends GNT.BatchApexHandler{ /* implements Database.Batchable<sObject> {*/
   List<String> newQueueNameList = new List<String>();
   List<User> newUserList = new List<User>();
 //global Database.QueryLocator start(Database.BatchableContext BC){
     global override String getQuery() {
 
    String query = 'Select id,name, PrimaryRepPrefix__c, PrimaryRepFirstName__c, PrimaryRepLastName__c, PrimaryRepAddress1__c, '+
                    'PrimaryRepAddress2__c, PrimaryRepCity__c, PrimaryRepState__c, PrimaryRepZipCode__c, PrimaryRepCountry__c,PrimaryRepPhone__c, '+
                    'PrimaryRepTitle__c, PrimaryRepEmail__c, SecondaryRepPrefix__c, SecondaryRepFirstName__c,SecondaryRepLastName__c, SecondaryRepAddress1__c,'+
                    'SecondaryRepAddress2__c, SecondaryRepCity__c, SecondaryRepState__c,SecondaryRepZipCode__c, SecondaryRepCountry__c, SecondaryRepPhone__c, '+                    
                    'SecondaryRepTitle__c, SecondaryRepEmail__c,Status__c,  Organization__c, EINText__c, OrganizationTypeSInglePicklist__c, OrganizationTypeOther__c,'+
                    'OrgnizationPhoneNumber__c,OrganizationFax__c, Website__c, DCSupplySchedule__c, FedralGSASchedule__c, DUNS__c, DUNSExpirationDate__c, '+
                    'OrganizationFiscalYearStartDate__c,OrganizationFiscalYearEndDate__c, OrganizationDescription__c,OrganizationStreetAddress__c, '+
                    'OrganizationCityAddress__c,County__c, StateDropdownList__c, OrganizationZipCode__c, OrganizationsCountry__c, UserRole__c, isApplicant__c,'+
                    'IsReviewer__c, Comments__c,AccountCreateFlag__c, ContactFlag__c, OrganizationName__c,Sams__c, recordtype.DeveloperName, PrimaryRepSponsoringAgency__c, SecondaryRepSponsoringAgency__c from UserRegistration__c ' +
                    'where AccountCreateFlag__c=true  and Status__c=\'Approved\''; 
                
    
  //  return Database.getQueryLocator(query);
  return query;
 }
 
 //global void execute(Database.BatchableContext BC, List<UserRegistration__c> records) {
    global override void execute(List<SObject>records){
        List<UserRegistration__c> record = (List<UserRegistration__c>)records;
    startCreationProcess(record);
    
 }
 
 // method that starts the creation of Account,Contact and User
 Private void startCreationProcess(List<UserRegistration__c> records){
    List<UserRegistration__c> uRegToUpdate = new List<UserRegistration__c>();
    List<Account> accountList = new List<Account>();
    Map<Id,UserRegistration__c> uRegMap =  new Map<Id,UserRegistration__c>(); 
    Map<Id,Account> uRegAccountMap =  new Map<Id,Account>();
    Map<Id,List<Contact>> uRegContactMap = new Map<Id,List<Contact>>();
    List<Contact> contactList = new List<Contact>();
    List<User> userList = new List<User>();
    Map<Id,UserRegistration__c> ConuRegMap = new Map<Id,UserRegistration__c>();
    
    
    Set<Id> uRegIds = new Set<Id>();
    Savepoint sp = Database.setSavepoint();
    Boolean isError=false;
    String errorContent ='';
    try{
        for(UserRegistration__c uReg : records){            
            uRegToUpdate.add(uReg);
            accountList.add(createOrganization(uReg));
            uReg.AccountCreateFlag__c=false;
            uRegMap.put(uReg.Id,uReg);
            uRegIds.add(uReg.id);
        }
        if(accountList.size()>0){
            insert accountList;
        }
        accountList = [Select Id,Name,UserRegistration__c from Account where UserRegistration__c in :uRegIds];
    
        for(Account account:accountList){
            newQueueNameList.add('SubQueue' + account.Id);
            uRegAccountMap.put(account.UserRegistration__c, account);
            List<Contact> accountContactList = createExternalContact(uRegMap.get(account.UserRegistration__c), account.Id);
            uRegContactMap.put(account.UserRegistration__c,accountContactList);
            for(Contact contact:accountContactList){
                contactList.add(contact);
            }
        }
        if(contactList.size() > 0){
            insert contactList;
        }
         List<Contact> accountContactList = new List<Contact>();
       

         for(UserRegistration__c uReg : records){
              accountContactList.addAll(uRegContactMap.get(uReg.Id));
              ConuRegMap.put(uReg.Contact__c,uReg);
         }
        
        Map<Id, Contact> conUserMap= new Map<Id, Contact>(); 
        if(!accountContactList.isEmpty()){ 
                   conUserMap = new Map<Id, Contact>([select Id, FirstName, LastName, Email,SponsoringAgency__c,UserRole__c,userregistration__r.RecordType.DeveloperName,accountId,account.name from Contact where id in: accountContactList]);
         }
         
         String spaProfile= GNT.KeyValueStoreHelper.getTextValue('SPAProfile', true);
         List<Profile> pList =  [Select Id from Profile where Name=:spaProfile limit 1];
         for(Contact contact:accountContactList){
                    User user = createExternalUser(ConuRegMap,uRegAccountMap,contact.Id,conUserMap,pList[0].Id);
                    userList.add(user);
         }
        if(userList.size()>0){
            insert userList;
        }

        for(User u : userList){
            newUserList.add(u);
        }
        
     // added method to update the PointofContactUser__c on account with the userID if the contact is the primary contact
          List<Account> accountUpdate = new List<Account>();
          Set<Id> primaryConIds = new Set<Id>();
                 
          for(contact con : contactList){
           if(con.KeyContact__c == true && con.userRole__c == 'Primary'){
            primaryConIds.add(con.Id);      
           }
        }
        Map<Id, User> userMap = new Map<Id, User>(); 
        List<User> uList;
         if(!primaryConIds.isEmpty()){ 
               uList = [select id , name ,ContactId,AccountId  from user where ContactId in: primaryConIds];
         } 
         for(User U :uList){
         userMap.put(u.AccountId,u);
         }
         
        for(Account acc :accountList){
            user u = usermap.get(acc.Id);
            if(u != null){
                acc.PointofContactUser__c = u.Id;
            }
        }
        
        if(accountList.size() > 0){
          update accountList;
        } 
        
        // code ends  
        if(uRegToUpdate.size() > 0){
            update uRegToUpdate;    
        }
    }catch(Exception ex){
        Database.rollback(sp);
        isError=true;
        System.debug('UserRegistrationTaskCreationHandler>>>execute Exception ' + ex.getMessage());
        errorContent =  ' Stack Trace - ' + ex.getStackTraceString();
        errorContent = errorContent+ ' Message - ' + ex.getMessage() + '  Line Number - ' +ex.getLineNumber();   
    }

     if(isError) {
    // Error occured, send email          
         String msgDetails = 'User Registration Error Occured on '+system.now();
         msgDetails+='\n  Errors Reported are shown below: \n '+errorContent;
         /*Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
          mail.setTargetObjectId(lstids[0]);
          mail.saveAsActivity = false;            
          mail.setSubject(' User Creation in External Registration has completed with Errors ');
          system.debug(msgDetails);
          mail.setPlainTextBody(msgDetails);
          mails.add(mail);
          Messaging.sendEmail(mails);
          */
          new GNT.EmailFeeder().TargetObjectId(UserInfo.getUserId()).htmlBody(msgDetails).subject('User Creation in External Registration has completed with Errors').send();
    }
 }  
 
 // global void finish(Database.BatchableContext BC){ 
   global override void finish(){
            createSupportSobject(newQueueNameList);
            addRecipientToQueue(newUserList);   
           scheduleMe();  
  } 
 
     //Run this batch job once every 5 mins.
    global static void scheduleMe() {
       // CreateCommunityUserBatch batch = new CreateCommunityUserBatch();
        UserRegAccountUserCreationHandler batch = new UserRegAccountUserCreationHandler();
        String cronExpression = GNT.BatchApexJobScheduler.prepareJobsSchTime(System.now(), 2);
        String jobName = GNT.BatchApexJobScheduler.getUniqueJobName('UserRegAccountUserCreationHandler');
        if (!Test.isRunningTest()) {
            System.schedule(jobName, cronExpression, new GNT.BatchApexJobScheduler(batch, 1));
        }
    } 

    public static void createSupportSobject(List<String> newQueueNameList){
        List<Group> newQueueList = new List<Group>([SELECT Id, Name FROM Group WHERE Name IN :newQueueNameList AND Type = 'Queue']);
        List<QueueSObject> newQueueSobjectList = new List<QueueSObject>();
        for(Group q : newQueueList){
            QueueSObject appQ = new QueueSObject(SobjectType = 'Application__c', QueueId = q.Id);
            QueueSObject grantQ = new QueueSObject(SobjectType = 'Grant__c', QueueId = q.Id);
            newQueueSobjectList.add(appQ);
            newQueueSobjectList.add(grantQ);
        }
        insert newQueueSobjectList;
    }

    private void addRecipientToQueue(List<User> newUserList){
        List<User> newRecipientUserList = new List<User>([SELECT Id, Name, AccountId FROM User WHERE IsActive = true AND Id IN :newUserList]);
        List<String> orgNameList = new List<String>();
        for(User u : newRecipientUserList){
            orgNameList.add('SubQueue' + u.AccountId);
        }

        List<Group> groupList = new List<Group>([SELECT Id, Name FROM Group WHERE Name IN :orgNameList AND Type = 'Queue']);
        Map<String, Id> nameIdMap = new Map<String, Id>();
        for(Group g : groupList){
            nameIdMap.put(g.Name, g.Id);
        }

        List<GroupMember> newMemberList = new List<GroupMember>();
        for(User u : newRecipientUserList){
            if(nameIdMap.get('SubQueue' + u.AccountId) != null){
                GroupMember member = new GroupMember(UserOrGroupId = u.Id, GroupId = nameIdMap.get('SubQueue' + u.AccountId));
                newMemberList.add(member);            
            }
        }
        
        insert newMemberList;
    } 
    /*Account Creation Method*/
    private Account createOrganization(UserRegistration__c uReg){

        Account account = new Account();
        account.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Recipient').getRecordTypeId();
        account.OwnerId = [select id From User where Profile.Name = 'System Administrator' AND UserRoleId != null and isActive = true LIMIT 1].Id;
        account.Name=uReg.OrganizationName__c;        
        account.EINText__c=uReg.EINText__c;
        account.Code__c = uReg.Name;
        account.ApplicantType__c=uReg.OrganizationTypeSInglePicklist__c ;
        account.ApplicantTypeOther__c=uReg.OrganizationTypeOther__c ;
        account.Phone=uReg.OrgnizationPhoneNumber__c;
        account.Fax=uReg.OrganizationFax__c ;
        account.Website=uReg.Website__c ;
        account.DCSupplySchedule__c=uReg.DCSupplySchedule__c ;
        account.FedralGSASchedule__c=uReg.FedralGSASchedule__c ;
        account.DUNS__c=uReg.DUNS__c ;
        account.DUNSExpirationDate__c=uReg.DUNSExpirationDate__c ;
        account.OrganizationFiscalYearStartDate__c=uReg.OrganizationFiscalYearStartDate__c;
        account.OrganizationFiscalYearEndDate__c=uReg.OrganizationFiscalYearEndDate__c ;
        account.Description=uReg.OrganizationDescription__c;
        account.BillingStreet=uReg.OrganizationStreetAddress__c;
        account.BillingCity=uReg.OrganizationCityAddress__c;
        account.BillingState=uReg.StateDropdownList__c ;
        account.BillingPostalCode=uReg.OrganizationZipCode__c ;
        account.BillingCountry=uReg.OrganizationsCountry__c ; 
        account.Status__c = 'Active';
        account.Comments__c=uReg.Comments__c;
        account.OrganizationID__c =uReg.Name;
        account.UserRegistration__c=uReg.Id;
        account.Sams__c=uReg.Sams__c;
        return account;        
    }
    
   /*Portal user Contact creation Method*/
    private List<Contact> createExternalContact(UserRegistration__c uReg, Id accountId){
        List<Contact> contactList = new List<Contact>();
        Contact portalContact = new Contact();
        Contact secContact;
        portalContact.AccountId = accountId;        
        portalContact.Title     =   uReg.PrimaryRepPrefix__c;
        portalContact.FirstName =   uReg.PrimaryRepFirstName__c;
        portalContact.LastName  =   uReg.PrimaryRepLastName__c;
        portalContact.Address1__c   = uReg.PrimaryRepAddress1__c;
        portalContact.Address2__c   = uReg.PrimaryRepAddress2__c;
        portalContact.MailingCity   = uReg.PrimaryRepCity__c;
        portalContact.MailingState  = uReg.PrimaryRepState__c;
        portalContact.MailingPostalCode = uReg.PrimaryRepZipCode__c;
        portalContact.MailingCountry    = uReg.PrimaryRepCountry__c;
        portalContact.Phone = uReg.PrimaryRepPhone__c;
        portalContact.PositionTitle__c  = uReg.PrimaryRepTitle__c;
        portalContact.Email = uReg.PrimaryRepEmail__c;
        portalContact.SponsoringAgency__c = uReg.PrimaryRepSponsoringAgency__c;
        portalContact.IsUser__c=true;
        portalContact.UserRole__c='Primary';
        portalContact.KeyContact__c = true;
        portalContact.ReviewerStatus__c='Active';
        portalContact.AffiliatedInstitution__c = uReg.OrganizationName__c;
        portalContact.UserRegistration__c = uReg.Id;
        
        contactList.add(portalContact);
        if(uReg.SecondaryRepEmail__c <> null){
            secContact = new Contact();
            secContact.AccountId = accountId;        
            secContact.Title    =   uReg.SecondaryRepPrefix__c;
            secContact.FirstName    =   uReg.SecondaryRepFirstName__c;
            secContact.LastName     =   uReg.SecondaryRepLastName__c;
            secContact.Address1__c  = uReg.SecondaryRepAddress1__c;
            secContact.Address2__c  = uReg.SecondaryRepAddress2__c;
            secContact.MailingCity  = uReg.SecondaryRepCity__c;
            secContact.MailingState = uReg.SecondaryRepState__c;
            secContact.MailingPostalCode    = uReg.SecondaryRepZipCode__c;
            secContact.MailingCountry   = uReg.SecondaryRepCountry__c;
            secContact.Phone    = uReg.SecondaryRepPhone__c;
            secContact.PositionTitle__c = uReg.SecondaryRepTitle__c;
            secContact.Email    = uReg.SecondaryRepEmail__c;
            secContact.SponsoringAgency__c = uReg.SecondaryRepSponsoringAgency__c;
            secContact.IsUser__c=true;
            secContact.UserRole__c='Secondary';
            secContact.ReviewerStatus__c='Active';
            secContact.AffiliatedInstitution__c = uReg.OrganizationName__c;
            secContact.UserRegistration__c = uReg.Id;
            contactList.add(secContact);
        }                     
        return contactList;
    }
      
        private User createExternalUser(Map<Id,UserRegistration__c> ConuRegMap, Map<Id,Account> uRegAccountMap, Id ConId,Map<Id,Contact> ConMap,Id profSec){ 
                  
            User userObj = new User();  
            Contact contact = ConMap.get(ConId);
            Id profileId = AppUtils.getCommunityProfileId(contact.userregistration__r.RecordType.DeveloperName);
            Id profileIdSecUser = profSec;
            if(profileId != null){
                List<User> UserList = new List<User>();
                string email = contact.Email+'%';
                System.debug('email ----->>>>'+email ); 
                UserList = [Select id from user where username like :email ]; 
                 System.debug('UserList ----->>>>'+UserList ); 
                integer UniqueUsername = GNT.KeyValueStoreHelper.getIntegerValue('UniqueUsername', true);
                integer size = UserList.size()+UniqueUsername ;
                 System.debug('size ----->>>>'+size ); 
               
                userObj.Username = contact.Email+size;
                System.debug('Username ----->>>>'+userObj.Username);   
                userObj.Email = contact.Email;
                userObj.FirstName = contact.FirstName; 
                userObj.LastName = contact.LastName;
                if(contact.SponsoringAgency__c != null){
                    userObj.SponsoringAgency__c = contact.SponsoringAgency__c;
                }
                String nickname = contact.FirstName+' '+contact.LastName+'%';
                List<User> nicknameList = [Select id , username from user where CommunityNickname like :nickname]; 
                integer sizeNickName = nicknameList.size()+UniqueUsername ;
                userObj.CommunityNickname = contact.FirstName+' '+contact.LastName+sizeNickName;
                
                String alias = contact.LastName;
                alias = alias.length() > 5 ? alias.substring(0,4) : contact.LastName;
                userObj.Alias = alias ;
                String timeZoneKey = GNT.KeyValueStoreHelper.getTextValue('UserRegistrationTimeZoneSidKey', true);
                if(String.isEmpty(timeZoneKey)){
                    timeZoneKey = 'America/New_York';
                }
                userObj.TimeZoneSidKey = timeZoneKey;
                userObj.EmailEncodingKey = 'UTF-8' ;
                userObj.LanguageLocaleKey = 'en_US' ;
                userObj.LocaleSidKey = 'en_US' ;
                //userObj.ContactId = contactId;
                userObj.ContactId = contact.Id;
                if(contact.UserRole__c == 'Secondary'){
                  userObj.profileId = profileIdSecUser ;
                }
                userObj.profileId = profileId ;
               // userObj.GNT__OrganizationId__c = account.Id;
                userObj.GNT__OrganizationId__c = contact.AccountId;
                system.debug('userObj.GNT__OrganizationId__c----->>>>'+userObj.GNT__OrganizationId__c);
               // userObj.OrganizationAccountName__c = account.Name;
                userObj.OrganizationAccountName__c = contact.Account.Name;
                userObj.IsApplicant__c = true;
                //userObj.IsReviewer__c = uReg.IsReviewer__c ;
                //userObj.IsApplicant__c = uReg.IsApplicant__c ;
               // userObj.DepartmentCode__c = uReg.Name;
            }
                
        return userObj;
    }
 
}