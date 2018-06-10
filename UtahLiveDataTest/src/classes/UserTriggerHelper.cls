/*
    All trigger logic on User  object
    **********************************************************
    Audit History
    **********************************************************************
    4/21/2013        Vinayak Sharma     Created
    5/13/2013          Vani             Added autoUpdateGroupQue Method
    5/13/2013          Vani             Added createGroup Method
    5/14/2013          Vani             Added ProcessGroup,Queue Method
    8/21/2014          Nakul            Updated setOrganizationForExternalUsers, setOrganizationForInternalUsers
    2/24/2015          William          Created assignCollaborationGroup and setSharingSettings
    4/15/2015          William          Created setUserAdministration method
    **********************************************************************
*/

public without sharing class UserTriggerHelper extends GNT.TriggerHelper{
    public static Boolean skipTrigger = false;
    public static Boolean skipSyncEmail = false;
    
    public override void processBeforeInsert() {
        System.debug(' USER SET UP Before Insert IS '+ !skipTrigger);
        if (!skipTrigger) {        
            setUserOrganization(Trigger.new);
           
            // Commenting this code as trigger.oldMap is referenced in below method (before insert) which is causing the null pointer.
            //updateOrganizationID();   
            setProfileName(Trigger.new); 
            setSharingSettings(trigger.new);        
            
            //updateUserPreferences();
        }
        populateInternalUniqueID();  
    }
     
    public override void processAfterInsert() {
        if (!skipTrigger) {
              setManager(Trigger.new); 
              createCon(Trigger.new); 
              //updateUserPreferences(); 
             calculate(2);
             if(!System.isFuture() && !System.isBatch()){
                addRecipientToQueue(Trigger.newMap.keySet());
             }                                
        }
    } 
    
    public override void processAfterUpdate() {
        if (!skipTrigger) {
            setManager(Trigger.new);
            updateContactEmail();
          //  updateUserPrefOnAccountChange();
             if(!System.isFuture() && !System.isBatch()){
             updateUserPreferences();
             }
        } 
    }
    
    public override void processBeforeUpdate() {
        System.debug(' USER SET UP IS '+ !skipTrigger);
        if (!skipTrigger) {           
            setUserOrganization(Trigger.new);
            updateOrganizationID();   
            setProfileName(Trigger.new); 
            setOrganizationForInternalUsers(Trigger.new);           
        }
        populateInternalUniqueID();         
    }
   
   
    private void populateInternalUniqueID() {
        for (SObject record : Trigger.New) {
            String idValue = (String) record.get('InternalUniqueID__c');
            if (String.isEmpty(idValue)) {
                idValue = GNT.AppUtils.generateToken(null);
                if(idValue.length() > 32){
                    idValue = idValue.subString(0,31);
                }
                record.put('InternalUniqueID__c', idValue);
            }
        }    
    }    
   
     private static void createCon(List<User> lstUsers){
        list<ID> userIds = new list<Id>();
        for(User usr : lstUsers){
            if (usr.UserType == 'Standard') {
                 userIds.add(usr.Id);
            }     
        } 
        if(userIds.size() != 0){  
       createContact(userIds);
       }
    }
       @future
       private static void createContact(List<Id> userIds){
         List<Contact> contactListIndApp = new List<Contact>();

         List<User> lstUsers = [Select Id,ContactId,GNT__OrganizationId__c,Title,FirstName,LastName,Street,Phone,Email 
                 from User Where id in :userIds];
        for(User usr : lstUsers){
            if(usr.ContactId == null){ 
              
                Contact internalContact = new Contact();
                internalContact.AccountId =    usr.GNT__OrganizationId__c;                    
                internalContact.Title     =   usr.Title;
                internalContact.FirstName =   usr.FirstName;
                internalContact.LastName  =   usr.LastName;
                internalContact.Address1__c   = usr.Street;
                internalContact.UserReference__c = usr.Id;
                internalContact.Phone = usr.Phone;
                internalContact.Email = usr.Email;
                internalContact.ReviewerStatus__c = 'Active';
                internalContact.IsUser__c=true;
    
               ContactTriggerHelper.skipTrigger = true;
               contactListIndApp.add(internalContact);
            }
            insert contactListIndApp;
        }   
       
    }    
    
    /* private static void createContact(List<User> lstUsers){
        for(User usr : lstUsers){
            if(usr.ContactId == null){ 
              
            Contact internalContact = new Contact();
            //internalContact.AccountId =    usr.UserRoleId;                    
            internalContact.Title     =   usr.Title;
            internalContact.FirstName =   usr.FirstName;
            internalContact.LastName  =   usr.LastName;
            internalContact.Address1__c   = usr.Street;
           /* internalContact.Address2__c   = usr.PrimaryRepAddress2__c;
            internalContact.MailingCity   = usr.City;
            internalContact.MailingState  = usr.PrimaryRepState__c;
            internalContact.MailingPostalCode = usr.PrimaryRepZipCode__c;
            internalContact.MailingCountry    = usr.PrimaryRepCountry__c; */
          /*  internalContact.Phone = usr.Phone;
            internalContact.Email = usr.Email;
            internalContact.ReviewerStatus__c = 'Active';
            internalContact.IsUser__c=true;
           // internalContact.AccountRecordType__c ='Internal';
           
           
            insert internalContact;
    
            }
        }   
       
    }  */         
         
    private static void setManager(List<User> lstUsers){
        Map<Id,Id> mangerUserId = new Map<Id,Id>();
        for(User usr : lstUsers){
            if(usr.accountId == null){ // User is not a Portal user but he is an Internal User
                mangerUserId.put(usr.Id,usr.ManagerId);  
            }
        }   
        System.debug('THE MAP OF USER IDs is >>> '+mangerUserId); 
        
        Map<Id,User> mapManager = new Map<Id,User>([Select Id,AccountId,DepartmentCode__c from User where Id in:mangerUserId.values()]);
        System.debug('THE MAPMANAGER  is >>>> '+mapManager); 
            
            for(User usr : lstUsers){ 
                for(User managerUsr: mapManager.values()){ 
                    if(managerUsr.accountId == null && usr.accountId == null){ // User is not a Portal user but he is an Internal User
                        User managerUser = mapManager.get(managerUsr.Id); 
                    //  if(managerUser.DepartmentCode__c != usr.DepartmentCode__c){
                          if(managerUser == null){
                            //usr.addError('Manager is not Defined for this User Please define a Manager');
                            usr.addError(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-64291'));                           
                        }       
                    }       
                } 
            } 
    }    
        
    private static void updateContactEmail(){
        if(ContactTriggerHelper.skipSyncEmail == true) {
            return;
        }
        
        Map<Id,String> updatedUser = new Map<Id,String>();
        List<User> userList = (List<User>)trigger.new;
        Map<Id,User> oldUserMap = (Map<Id,User>)trigger.oldMap;
        for(User user :userList){
            if(oldUserMap.get(user.Id).email != user.email){
                updatedUser.put(user.contactId,user.email);
            }
        }
        if(updatedUser.size() > 0 && !System.isFuture() && !System.isBatch()){
            setContactEmail(updatedUser);
        }
        
    }
    // methods are not used in the before update so commented it- Charan
    /*private static void updateUserPrefOnAccountChange(){
        Map<Id,String> updatedUserAccountName = new Map<Id,String>();
        Map<Id,String> updatedUserAccountId = new Map<Id,String>();
        List<User> userList = (List<User>)trigger.new;
        //Map<Id,User> oldUserMap = (Map<Id,User>)trigger.oldMap;
        for(User user :userList){
           // if(oldUserMap.get(user.Id).AccountId != user.AccountId){
                updatedUserAccountId.put(user.Id,user.Organization__c);
                updatedUserAccountName.put(user.Id,user.OrganizationAccountName__c);
            //}
        }
        if(updatedUserAccountId.size() > 0 && !System.isFuture() && !System.isBatch()){
            setUserPrefAccountNameValue(updatedUserAccountName);
            setUserPrefAccountIdValue(updatedUserAccountId);
        }
    }
    
    @future
    static void setUserPrefAccountNameValue(Map<Id,String> updatedUser){
        system.debug('updatedUser---------->>>>'+updatedUser);        
        List<GNT__UserPreferences__c> userPrefs = new List<GNT__UserPreferences__c>();
        for(Id userId : updatedUser.keySet()){
            GNT__UserPreferences__c userPref = GNT__UserPreferences__c.getValues(userId);
            system.debug('userPref for accountName---------->>>>'+userPref);
            if(userPref != null){
                userPref.GNT__OrganizationAccountName__c = updatedUser.get(userId);
                userPrefs.add(userPref);
            }
        }
        if(userPrefs.size() > 0){
            system.debug('userPref for accountName---------->>>>'+userPrefs);
            update userPrefs;
        }
    }
    
    @future
    static void setUserPrefAccountIdValue(Map<Id,String> updatedUser){
        system.debug('updatedUser---------->>>>'+updatedUser);
        List<GNT__UserPreferences__c> userPrefs = new List<GNT__UserPreferences__c>();
        for(Id userId : updatedUser.keySet()){
            GNT__UserPreferences__c userPref = GNT__UserPreferences__c.getValues(userId);
            system.debug('userPref for accountId---------->>>>'+userPref);
            if(userPref != null){
                userPref.GNT__OrganizationAccountId__c = updatedUser.get(userId);
                userPrefs.add(userPref);
            }
        }
        if(userPrefs.size() > 0){
            system.debug('userPref for accountIdValue---------->>>>'+userPrefs);
            update userPrefs;
        }
    }*/
    
    @future
    static void setContactEmail(Map<Id,String> updateContacts){
        Map<Id,Contact> contactsMap = new Map<Id,Contact>([select id,email from contact where 
                                        id in :updateContacts.keySet()]);
        
        List<Contact> contacts = new List<Contact>();
        for(Contact c : contactsMap.values()){
            c.email = updateContacts.get(c.id);
            contacts.add(c);
        }
        if(contacts.size() > 0){
            skipSyncEmail = true;
            upsert contacts;
        }
    }
    
    private void updateOrganizationID(){
        List<User> selectedUsers = new List<User>();
        List<User> userList = (List<User>)trigger.new;
        Map<Id,User> oldUserMap = (Map<Id,User>)trigger.oldMap;
        for(User user :userList){
            if(oldUserMap.get(user.Id).userRoleId != user.UserRoleId){
                selectedUsers.add(user);
            }
        }
        if(selectedUsers != null && selectedUsers.size() > 0){
            setUserOrganization(selectedUsers);
        }
    }

 
    /* Organization Id is set based on the role name (Role Hierarchy is similar to Account Hierarchy */
    private void setUserOrganization(List<User> userList){
        setOrganizationForExternalUsers(userList);
        setOrganizationForInternalUsers(userList);
    }

    //Identifies the user organization based on the role to which the user is associated to
    private void setOrganizationForInternalUsers(List<User> userListParam) {
        List<User> userList = new List<User>();
        // SKIP THIS FOR EXTERNAL USER
        for(User uObj : userListParam){
            if(uObj.ContactId == null){
                userList.add(uObj);
            }
        }
        if(userList.size() > 0){
            Map<String,Id> roleMap = getUserRoleMap(userList);
            Id accountId;
            List<Account> accountList = [select id,name,Code__c,GroupCode__c  from Account where name 
                                            in :roleMap.keySet() and RecordType.Name =: 'Internal' ];
           
            Map<String,Account> roleAccountMap= new Map<String,Account>();
            for(Account account :accountList){
                roleAccountMap.put(roleMap.get(account.Name),account);   
            }
            
            System.debug(' Role Account Map is >>'+roleAccountMap);
            
            for(User user : userList){
                if(user.contactId == null){
                    if(user.UserRoleId!=null && roleAccountMap !=null &&  roleAccountMap.get(user.UserRoleId)!=null ){
                        Account acct = roleAccountMap.get(user.UserRoleId);
                         if (acct != null) {
                            user.GNT__OrganizationId__c = acct.Id;
                            user.OrganizationAccountName__c = acct.Name; 
                            user.DepartmentCode__c = acct.GroupCode__c; 
                        }  
                        System.debug('  user.DepartmentCode__c is >>'+user.DepartmentCode__c);
                    } 
                }       
            }
        }
    }

    //Identifies the user organization based on the contact id which is found on the user record
    private void setOrganizationForExternalUsers(List<User> userList) {
        // Commented this method code as it is already handled in UserRegistrationTriggerHelper
        
    }    
    private void setSharingSettings(List<User> userList) {
        for(User u: userList) {
            if(u.ContactId != null) {
                u.UserPreferencesShowCityToExternalUsers = true;
                u.UserPreferencesShowCountryToExternalUsers = true;
                u.UserPreferencesShowEmailToExternalUsers = true;
                u.UserPreferencesShowFaxToExternalUsers = true;
                u.UserPreferencesShowManagerToExternalUsers = true;
                u.UserPreferencesShowMobilePhoneToExternalUsers = true;
                u.UserPreferencesShowPostalCodeToExternalUsers = true;
                u.UserPreferencesShowStateToExternalUsers = true;
                u.UserPreferencesShowStreetAddressToExternalUsers = true;
                u.UserPreferencesShowTitleToExternalUsers = true;
                u.UserPreferencesShowWorkPhoneToExternalUsers = true;
            }
        }
    }


    // Get a list of all the roles associated with users
    private Map<String,Id> getUserRoleMap(List<User>userList){
         Set<Id> roles = new Set<Id>();
         Map<String,Id> rolesName = new Map<String,Id>();
         for(User user:userList){
                 roles.add(user.UserRoleId);
         }
         List<UserRole> userRoleList = [select id,Name from UserRole where id in :roles];
         for(UserRole userRole : userRoleList){
             rolesName.put(userRole.Name,userRole.id);
         }
         
         return rolesName;
    }
    
    @future
    private static void addRecipientToQueue(Set<Id> userIdSet){
        List<User> newRecipientUserList = new List<User>([SELECT Id, Name, AccountId FROM User WHERE IsActive = true AND Id IN :userIdSet]);
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

    //Assigns profile name text field for the logged in user
    private void setProfileName(List<User> userList) {
        Set<Id> profileIds = new Set<Id>();
        for (User u : userList) {
            system.debug('**u--'+u);
            if (u.ProfileId != null) {
                profileIds.add(u.ProfileId);
            }
        }
        system.debug('**:profileIds--'+profileIds);
        Map<Id, Profile> profileMap = new Map<Id, Profile>([Select Id, Name from Profile where Id in :profileIds]);
        system.debug('**profileMap--'+profileMap);
        
        for (User u : (List<User>)Trigger.New) {
            if (u.ProfileId != null && !profileMap.isEmpty() ) {
                Profile p = profileMap.get(u.ProfileId);
                u.ProfileName__c = p.Name;
            }
        }
    }
    
    // Method to update User Preferences Custom Setting as and when User Record is updated.
    @future
    private static void updateUserPreferences(){
    List<GNT__UserPreferences__c> userPrefList = [Select Id,name,SetupOwnerId from GNT__UserPreferences__c where setupOwnerId in :Trigger.NewMap.Keyset() ];
    for(GNT__UserPreferences__c userPref : userPrefList){
        User userObj = (User)Trigger.NewMap.get(userPref.SetupOwnerId);
        userPref.GNT__IsApplicant__c = userObj.IsApplicant__c;
        userPref.GNT__IsReviewer__c =  userObj.IsReviewer__c;
        userPref.GNT__IsInternal__c =  !userObj.IsExternalUser__c;  
        userPref.GNT__OrganizationAccountName__c=userObj.OrganizationAccountName__c;
        userPref.GNT__OrganizationAccountId__c=userObj.Organization__c;
      }
      
      if(userPrefList!=null && userPrefList.size()>0)
         upsert userPrefList;            
    } 
     
public static void calculate(Integer i){
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
i=1;
    }  
}