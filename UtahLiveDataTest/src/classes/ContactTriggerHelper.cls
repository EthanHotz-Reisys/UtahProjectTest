/*
    This class has methods to execute methods related to Contact Trigger
    **********************************************************
    Audit History
    **********************************************************
    2014-05-27   Nakul Kadam       Created
    11/11/2015   Shrawan Raina     Added before insert for security token
     8/16/2016   Swati Singh     Added updateStatus() method
    **********************************************************
*/
public class ContactTriggerHelper extends GNT.TriggerHelper {

    public class MoreThanOneBAException extends Exception {}
    public class KeyPOCEditRoleException extends Exception{}

    public static Boolean skipSyncEmail = false;
    public static Boolean skipTrigger = false;

    public override void processBeforeUpdate() {
        setFirstLoginFlagOnUserRecord();
        checkNumberOfBAs((List<Contact>) Trigger.New);
        //updateOrgBA((List<Contact>) Trigger.New);
    }

    public override void processBeforeInsert() {
        assignSecurityToken();
        updateStatus();
        checkNumberOfBAs((List<Contact>) Trigger.New);
        //updateOrgBA((List<Contact>) Trigger.New);
    }

    public override void processAfterInsert() {
        updateOrgBA((List<Contact>) Trigger.New);
    }

    private void updateStatus() {
        for (Contact con : (List<Contact>) Trigger.new) {
            if (con.AccountRecordType__c == 'Internal' || con.AccountRecordType__c == 'NGO') {
                con.ReviewerStatus__c = 'Active';
            }
            /*else {
             con.ReviewerStatus__c = 'New';
            } */

        }
    }


    private void assignSecurityToken() {
        for (Contact con : (List<Contact>) Trigger.new) {
            con.SecurityToken__c = GNT.AppUtils.generateToken(32);
        }
    }

    // Sync User email when Contact email updated, need to prevent recursive
    public override void processAfterUpdate() {
        System.debug('ENTERING AFTER UPDATE');
        updateUserEmail();
        updateTheRole(Trigger.New);
        updateOrgBA((List<Contact>) Trigger.New);
        validatekeyPOCEdit((List<Contact>) Trigger.New);
    }

    /*
        This method is used to set the IsFirstLoginDone__c flag to true for the contact currently being updated
    */
    private void setFirstLoginFlagOnUserRecord() {
        Set<Id> contIds = new Set<Id>();
        for (Contact cont : (Contact[])trigger.new) {
            contIds.add(cont.Id);
        }
        List<User> userList = [Select Id from User Where ContactId in :contIds AND IsFirstLoginDone__c = false];
        if (userList.size () > 0) {
            setFirstLoginFlagOnUserRecordFuture(contIds);
            setFirstUserPrefOnUserRec(contIds);
        }
    }

    @future
    static void setFirstLoginFlagOnUserRecordFuture(Set<Id> contIds) {
        if (contIds.size() > 0) {
            List<User> updateUserList = new List<User>();
            List<User> userList = [Select Id from User Where ContactId in :contIds AND IsFirstLoginDone__c = false];
            if (userList != null && userList.size() > 0) {
                for (User uObj : userList) {
                    uObj.IsFirstLoginDone__c = true;
                    updateUserList.add(uObj);
                }
                if (updateUserList.size() > 0) {
                    if (Schema.sObjectType.User.isUpdateable()) {
                        update updateUserList;
                    }
                }
            }
        }
    }

    @future
    static void setFirstUserPrefOnUserRec(Set<Id> contIds) {
        if (contIds.size() > 0) {
            List<User> updateUserList = new List<User>();
            List<User> userList = [Select Id from User Where ContactId in :contIds AND IsFirstLoginDone__c = false];
            List<GNT__UserPreferences__c> userPref = new List<GNT__UserPreferences__c>();

            if (userList != null && userList.size() > 0) {
                for (User uObj : userList) {
                    GNT__UserPreferences__c uPref = GNT__UserPreferences__c.getValues(uObj.id);
                    if (uPref != null) {
                        uPref.GNT__FirstLoginDone__c = true;
                        userPref.add(uPref);
                    }
                }
                if (userPref.size () > 0) {
                    update userPref;
                }
            }
        }
    }

    private static void updateUserEmail() {
        if (UserTriggerHelper.skipSyncEmail == true) {
            return;
        }

        Map<Id, String> updatedContacts = new Map<Id, String>();
        List<Contact> contactList = (List<Contact>)trigger.new;
        Map<Id, Contact> oldContactMap = (Map<Id, Contact>)trigger.oldMap;

        for (Contact eachContact : contactList) {
            if (oldContactMap.get(eachContact.Id).Email != eachContact.Email) {
                updatedContacts.put(eachContact.Id, eachContact.Email);
            }
        }

        if (updatedContacts.size() > 0) {
            setUserEmail(updatedContacts);
        }
    }

    @future
    static void setUserEmail(Map<Id, String> updateContacts) {
        Map<Id, User> userMap = new Map<Id, User>([SELECT Id, Email, ContactId FROM User
                WHERE ContactId in :updateContacts.keySet()]);
        List<User> users = new List<User>();

        for (User eachUser : userMap.values()) {
            eachUser.Email = updateContacts.get(eachUser.ContactId);
            users.add(eachUser);
        }

        if (users.size() > 0) {
            skipSyncEmail = true;
            update users;
        }
    }

    private void updateTheRole(List<Contact> contactList) {

        System.debug('ENTERING THE METHOD');
        
        Set<Id> userId = new Set<Id>();
        Set<Id> contactId = new Set<Id>();
        for (Contact contactIterator : contactList) {
            Contact contactOld = (Contact) Trigger.OldMap.get(contactIterator.Id);
            if (contactIterator.UserRole__c != contactOld.UserRole__c) {
                contactId.add(contactIterator.Id);
            }
        }

        System.debug('LEON TEST DEBUG=======>' + contactId);

        if (contactId.size() > 0) {
            updateContactHelper(contactId);
        }
    }

    @future
    private static void updateContactHelper(Set<Id> contactId) {
        Id spiProfile;
        Id spaProfile;
        System.debug('ENTERING THE FUTURE METHOD');
        List<User> userList = [Select id, contact.UserRole__c from User where contactId IN: contactId];
        List<Profile> profilelist = [Select id, Name from Profile where Name = 'SPI'OR Name = 'SPA' ];
        for (Profile profile : profilelist) {
            if (profile.Name == 'SPI') {
                spiProfile = profile.Id;
            } else {
                spaProfile = profile.Id;
            }

        }

        for (User u : userList) {
            System.debug('Important message here================>'+u.contact.UserRole__c);
            if (u.contact.UserRole__c == 'Primary') {
                u.ProfileId = spiProfile;
            } else if(u.contact.UserRole__c == 'Secondary') {
                u.ProfileId = spaProfile;
            }
        }

        update userList;
    }


    private void checkNumberOfBAs(List<Contact> triggerList) {
        try {
            List<Id> triggerListIds = new List<Id>();
            List<Id> leaIdList = new List<Id>();
            List<Contact> contactList = new List<Contact>();
            for (Contact contactIterator : triggerList) {
                if (contactIterator.KeyContact__c != null && contactIterator.KeyContact__c == true) {
                    leaIdList.add(contactIterator.AccountId);
                    triggerListIds.add(contactIterator.Id);
                    contactList.add(contactIterator);
                }
            }
            if (leaIdList.size() > 0) {
                //Check if any of the other users in the LEA(s) are set as the BA
                List<Contact> leaListBA = [SELECT Id, AccountId, KeyContact__c FROM Contact WHERE AccountId IN: leaIdList AND Id NOT IN: triggerListIds AND KeyContact__c = true];
                if (leaListBA.size() > 0) { //We already have someone set as the BA in the LEA(s)
                    for (Contact contactIterator : contactList) {
                        contactIterator.KeyContact__c = false;
                        String errorOutput = 'Please deselect the existing Key POC / Default Internal Approver first.';
                        contactIterator.addError(errorOutput);
                        throw new MoreThanOneBAException(errorOutput);
                    }
                }
            }
        } catch (MoreThanOneBAException e) {
            System.debug(e);
        } catch (Exception e) {
            System.debug(e);
        }
    }
      private void validatekeyPOCEdit(List<Contact> triggerList){

        List<Id> triggerListIds = new List<Id>();
        List<Id> leaIdList = new List<Id>();
        List<Contact> leaListBA = new List<Contact>();
        for (Contact contactIterator : triggerList) {
            if (contactIterator.KeyContact__c != null && contactIterator.KeyContact__c == true) {
                leaIdList.add(contactIterator.AccountId);
                 triggerListIds.add(contactIterator.Id);
                }
        }
        if (leaIdList.size() > 0) {
            leaListBA = [SELECT Id, AccountId, KeyContact__c FROM Contact WHERE AccountId IN: leaIdList AND Id IN: triggerListIds AND KeyContact__c = true];
               
            for (Contact cont: triggerList){
                Contact oldContact = (Contact) Trigger.oldMap.get(cont.id);
                if (oldContact.keyContact__c && (String.valueOf(cont.userRole__c) != String.valueOf(oldContact.userRole__c)) && leaListBA.size()!=0){
                        cont.addError(new KeyPOCEditRoleException('You cannot change the role of Key POC.'));
                        System.debug('contactdebug'+cont);
                        //throw new KeyPOCEditRoleException('test');
                    }
                if (cont.keyContact__c && cont.userRole__c == 'Secondary'){
                    cont.addError(new KeyPOCEditRoleException('You cannot make a secondary user Key POC.'));
                }

            }
        }

    }

    private void updateOrgBA(List<Contact> triggerList) {
        try {
            List<Id> triggerListIds = new List<Id>();
            List<Id> leaIdList = new List<Id>();
            Map<Id, Id> leaMapContact = new Map<Id, Id>();
            for (Contact contactIterator : triggerList) {
                if (contactIterator.KeyContact__c != null && contactIterator.KeyContact__c == true) {
                    leaIdList.add(contactIterator.AccountId);
                    triggerListIds.add(contactIterator.Id);
                    leaMapContact.put(contactIterator.AccountId, contactIterator.Id);
                }
            }
            if (leaIdList.size() > 0) {
                //Check if any of the other users in the LEA(s) are set as the BA
                List<Contact> leaListBA = [SELECT Id, AccountId, KeyContact__c FROM Contact WHERE AccountId IN: leaIdList AND Id NOT IN: triggerListIds AND KeyContact__c = true];
                if (leaListBA.size() > 0) { //We already have someone set as the BA in the LEA(s)
                    String errorOutput = 'Please deselect the existing Key POC / Default Internal Approver first.';
                    for (Contact contactIterator : leaListBA) {
                        contactIterator.addError(errorOutput);
                    }
                    throw new MoreThanOneBAException(errorOutput);
                } else {
                    if (triggerListIds.size() > 0) { //If the Ids from the trigger exist, thus if it is on an after insert/update
                        List<Account> leaList = [SELECT Id FROM Account WHERE Id IN: leaIdList];
                        List<User> userList = [SELECT Id, ContactId FROM User WHERE ContactId IN: triggerListIds];
                        Map<Id, Id> contactMapUser = new Map<Id, Id>();
                        for (User userIterator : userList) {
                            contactMapUser.put(userIterator.ContactId, userIterator.Id);
                        }
                        for (Account leaIterator : leaList) {
                            leaIterator.PointofContactUser__c = contactMapUser.get(leaMapContact.get(leaIterator.Id));
                        }
                        update leaList;
                    }
                }
            }
        } catch (MoreThanOneBAException e) {
            System.debug(e);
        } catch (Exception e) {
            System.debug(e);
        }
    }
}