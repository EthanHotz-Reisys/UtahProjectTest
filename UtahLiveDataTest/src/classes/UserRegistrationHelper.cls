global with sharing class UserRegistrationHelper extends GNT.DynamicLayoutActionRedirect{
    
    
    global override PageReference whenClicked(){ 
         Savepoint sp = Database.setSavepoint();
        // Id recordId = layoutHolder.getPrimarySObject().Id;
         Id recordId = apexpages.currentpage().getparameters().get('id');
         UserRegistration__c uReg = [Select id, PrimaryRepPrefix__c, PrimaryRepFirstName__c, PrimaryRepLastName__c, PrimaryRepAddress1__c, 
                                     PrimaryRepAddress2__c, PrimaryRepCity__c, PrimaryRepState__c, PrimaryRepZipCode__c, PrimaryRepCountry__c, 
                                     PrimaryRepPhone__c, PrimaryRepTitle__c, PrimaryRepEmail__c, SecondaryRepPrefix__c, SecondaryRepFirstName__c, 
                                     SecondaryRepLastName__c, SecondaryRepAddress1__c, SecondaryRepAddress2__c, SecondaryRepCity__c,  
                                     SecondaryRepZipCode__c, SecondaryRepCountry__c, SecondaryRepPhone__c, SecondaryRepTitle__c, SecondaryRepEmail__c, 
                                     Status__c, Organization__c, EINText__c, OrganizationTypeSInglePicklist__c, OrganizationTypeOther__c, OrgnizationPhoneNumber__c,
                                     OrganizationFax__c, Website__c, DCSupplySchedule__c, FedralGSASchedule__c, DUNS__c, DUNSExpirationDate__c, OrganizationFiscalYearStartDate__c,
                                     OrganizationFiscalYearEndDate__c, OrganizationDescription__c,OrganizationStreetAddress__c, OrganizationCityAddress__c,
                                     County__c, OrganizationState__c, OrganizationZipCode__c, SecondaryRepState__c, OrganizationsCountry__c, UserRole__c, isApplicant__c, 
                                     IsReviewer__c, Comments__c, RecordType.DeveloperName
                                     from UserRegistration__c where id = :recordId];
        
        
          //  if(!uReg.Status__c.equals('Verified')){
           // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Click Verify Button to Check for valid DUNs and EIN before approving.'));
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, GNT.ErrorMessageHelper.fetchMessage('')));
             //  } 
        try{
            if(uReg.Comments__c == null){
               // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Please click the edit button and enter the Approval comments'));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-70697')));
                return null;
            }
            createRecord(uReg);
            uReg.Status__c='Approved';
            update uReg;
                        
        }catch(Exception e){
            Database.rollback(sp);
            //System.Debug('UserRegistrationHelper whenClicked...'+e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, e.getMessage())); 
        }   
        PageReference pageRef= new PageReference('/apex/InternalUserRegistrationView?id='+recordId);
        pageRef.setRedirect(true);
        return pageRef;                      
    }
    
    private void createRecord(UserRegistration__c uReg){
        Id accountId = ((Account)createOrganization(uReg)).Id;
        Account account = [Select id, Name from Account where id = :accountId];
        List<Contact> contactList = createExternalContact(uReg,account.Id);
        for(Contact contact:contactList){
            //User user = createExternalUser(uReg, account, contact.Id);    
        }
    }

    /*Account Creation Method*/
    private Account createOrganization(UserRegistration__c uReg){
        Account account = new Account();
        //AppUtils.copyRecord(uReg, account, false);        
        account.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('External').getRecordTypeId();
        account.OwnerId = [select id From User where Profile.Name = 'System Administrator' AND UserRoleId != null and isActive = true LIMIT 1].Id;
        account.Name=uReg.Organization__c;
        
        account.EINText__c=uReg.EINText__c;
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
        //uReg.County__c ;
        account.BillingState=uReg.OrganizationState__c ;
        account.BillingPostalCode=uReg.OrganizationZipCode__c ;
        account.BillingCountry=uReg.OrganizationsCountry__c ; 
        account.Status__c = 'Active';
        account.Comments__c=uReg.Comments__c;
        insert account;
        system.debug('*** account'+account.id);
        return account;
    }
    
   /*Portal user Contact creation Method*/
    private List<Contact> createExternalContact(UserRegistration__c uReg, Id accountId){
        List<Contact> contactList = new List<Contact>();
        Contact portalContact = new Contact();
        Contact secContact;
        portalContact.AccountId = accountId;        
        //AppUtils.copyRecord(uReg, portalContact, false);
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
        portalContact.UserRole__c='Primary';
        
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
            secContact.UserRole__c='Secondary';
            contactList.add(secContact);
        }
        if(contactList!=null && contactList.size()>0){
            insert contactList;
        }                
        return contactList;
    }
    
    /* Portal User Creation method */
    //private User createExternalUser(UserRegistration__c uReg, Account account, Id contactId){        
    //        User userObj = new User();        
    //        Contact contact =     [Select Id, FirstName, LastName, Email from Contact where id = :contactId]; 
    //        Id profileId = AppUtils.getCommunityProfileId(uReg.RecordType.DeveloperName);

    //        if(profileId != null){
    //            userObj.Username = contact.Email ;
    //            userObj.Email = contact.Email;
    //            userObj.FirstName = contact.FirstName;
    //            userObj.LastName = contact.LastName;
    //            userObj.CommunityNickname = contact.FirstName+' '+contact.LastName ;
    //            String alias = contact.LastName;
    //            alias = alias.length() > 5 ? alias.substring(0,4) : contact.LastName;
    //            userObj.Alias = alias ;
    //            String timeZoneKey = GNT.KeyValueStoreHelper.getTextValue('UserRegistrationTimeZoneSidKey', true);
    //            if(String.isEmpty(timeZoneKey)){
    //                timeZoneKey = 'America/New_York';
    //            }
    //            userObj.TimeZoneSidKey = timeZoneKey;
    //            userObj.EmailEncodingKey = 'UTF-8' ;
    //            userObj.LanguageLocaleKey = 'en_US' ;
    //            userObj.LocaleSidKey = 'en_US' ;
    //            userObj.ContactId = contactId;
    //            userObj.profileId = profileId ;
    //            userObj.GNT__OrganizationId__c = account.Id;
    //            system.debug('userObj.GNT__OrganizationId__c----->>>>'+userObj.GNT__OrganizationId__c);
    //            userObj.OrganizationAccountName__c = account.Name;
    //            userObj.IsReviewer__c = uReg.IsReviewer__c ;
    //            userObj.IsApplicant__c = uReg.IsApplicant__c ;
    //            insert userObj;                      
    //        }
                
    //    return userObj;
    //}
}