global with sharing class DirectlyRegisterActivateUserFromContact extends GNT.DynamicLayoutActionRedirect{
    
    global override PageReference whenClicked(){ 
        Savepoint savestate = Database.setSavepoint();
        Map<String,Object> retVal = new Map<String,Object>();
        Id recordId = layoutHolder.getPrimarySObject().Id;  //Current Contact Id
        
        try{
            System.debug('MANUALDEBUG >>> recordId: ' + recordId);
            Contact currentContact = [SELECT Id, AccountId, ApplicantType__c, UserRole__c, Name, Phone FROM Contact WHERE Id =: recordId];
            System.debug('MANUALDEBUG >>> currentContact: ' + currentContact);
            
            /*
            String contactType;
            if (currentContact.ApplicantType__c == '') {
                contactType = 'Additional Applicant';
            }
            else if (currentContact.ApplicantType__c == '') {
                contactType = '';
            }
            */
            RecordType currentRecordType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE DeveloperName =: currentContact.ApplicantType__c];
            System.debug('MANUALDEBUG >>> currentRecordType : ' + currentRecordType);
            
            System.debug('MANUALDEBUG >>> Creating UserRegistration');
            UserRegistration__c userToActivate = new UserRegistration__c();  
            userToActivate.Account__c = currentContact.AccountId;
            userToActivate.Contact__c = currentContact.Id;
            userToActivate.RecordTypeId = currentRecordType.Id;
            userToActivate.PrimaryRepPhone__c = currentContact.Phone;
            insert userToActivate;
            System.debug('MANUALDEBUG >>> userToActivate: ' + userToActivate);
            
            System.debug('MANUALDEBUG >>> Updating Contact with UserRegistration');
            currentContact.UserRegistration__c = userToActivate.Id;
            update currentContact;
            System.debug('MANUALDEBUG >>> currentContact: ' + currentContact);
            
            System.debug('MANUALDEBUG >>> Initiating User Registration');
            userToActivate.Status__c = 'Approved';
            update userToActivate;
            System.debug('MANUALDEBUG >>> userToActivate: ' + userToActivate);
            
            PageReference pf = Page.OrganizationView;
            pf.getParameters().put('id', currentContact.AccountId);
            pf.setRedirect(true);
            return pf;
        }
        catch(Exception e){
            Database.rollback(savestate);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, e.getMessage())); 
            return null;
        }   
    }
}