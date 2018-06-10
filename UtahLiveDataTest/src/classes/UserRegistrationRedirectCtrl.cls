/*
* Redirect page controller for Reviewer Email Registration
* CHANGE HISTORY
* =============================================================================
* Date          Name            Description
* 08/19/2015    Shrawan Raina   Created for reviewer registration via Email
* 09/04/2015    Shrawan Raina   Edited -- Added condition for Reviewer Status
* =============================================================================
*/
public without sharing class UserRegistrationRedirectCtrl {
    public UserRegistrationRedirectCtrl() {}
    private PageReference p;
    public PageReference redirect() {
        try{
            List<Contact> invitedList = new List<Contact>();
            String uniqueToken = ApexPages.currentPage().getParameters().get('t');
            String recordType = ApexPages.currentPage().getParameters().get('RecordType');
          
       
            System.debug('uniqueToken:<<<' + uniqueToken);
            if(uniqueToken != null && uniqueToken != ''){
                invitedList = [SELECT Id,SecurityToken__c FROM Contact WHERE SecurityToken__c =: uniqueToken AND ReviewerStatus__c = 'Invitation Sent'];
            }
            System.debug('invitedList:<<<' + invitedList);
            if(invitedList.size() > 0){
                redirectToUserReg(invitedList[0], true,recordType);
                p.setRedirect(true);
                return p;
            }
            else{
               redirectToUserReg(null, false,recordType);
                p.setRedirect(true);
                return p; 
            }
            p = Page.ErrorMessage;
            p.setRedirect(true);
            return p;
        }
        catch(Exception e){
            System.debug('The following exception has occured: ' + e.getMessage());
            return null;
        }
        return p;
    }

    private void redirectToUserReg(Contact reviewerContact, boolean isReviewer, String recordType){
        // For Reviewer Registration
        String ndaText = '';
        String coiText = '';
     
        
        if(isReviewer && reviewerContact != null && recordType == null){
           /* List<UserRegistration__c> userRegList = new List<UserRegistration__c>([SELECT Id FROM UserRegistration__c WHERE Contact__c =: reviewerContact.Id]);
            System.debug('userRegList:<<<' + userRegList);
            if(userRegList.size() == 0){
                //Creating a new UserReg record
                UserRegistration__c userReg = new UserRegistration__c();
                GNT.AppUtils.copyRecord('Contact', AppUtils.getNamespacePrefix() + 'UserRegistration__c', reviewerContact.Id, userReg);
                //Check if NDA is required
                Boolean isNDAPage = GNT.KeyValueStoreHelper.getBooleanValue('NDAPageRequired',true);
                System.debug('isNDAPage:<<<' + isNDAPage);
                if(isNDAPage){
                    ndaText = GNT.KeyValueStoreHelper.getTextValue('Non Disclosure Agreement For Reviewer', true);
                    List<GNT__HelpConfig__c> ndaHelp = new List<GNT__HelpConfig__c>([SELECT Id, GNT__HelpText__c, GNT__Header__c FROM GNT__HelpConfig__c WHERE GNT__UniqueName__c = :ndaText LIMIT 1]);
                    if(ndaHelp != null && ndaHelp.size() > 0){
                        userReg.NDAText__c = ndaHelp[0].GNT__HelpText__c;
                        userReg.NDASignDate__c = System.today();
                    }
                    coiText = GNT.KeyValueStoreHelper.getTextValue('Conflict Of Interest Information', true);
                    List<GNT__HelpConfig__c> coiHelp = new List<GNT__HelpConfig__c>([SELECT Id, GNT__HelpText__c, GNT__Header__c FROM GNT__HelpConfig__c WHERE GNT__UniqueName__c = :coiText LIMIT 1]);
                    if(coiHelp != null && coiHelp.size() > 0){
                        userReg.COIText__c = coiHelp[0].GNT__HelpText__c;
                        userReg.COISignDate__c = System.today();
                    }
                }
                Id userRegRecordType = Schema.SObjectType.UserRegistration__c.getRecordTypeInfosByName().get('Reviewer').getRecordTypeId();
                userReg.RecordTypeId = userRegRecordType;
                userReg.UserRole__c = 'Reviewer';
                userReg.UserRole1__c = 'External Reviewer';
                setDefaultValues(userReg);
                insert userReg;
                p = new pageReference('/UserRegistrationEdit?id=' + userReg.Id);
            }
            else{
                p = new PageReference('/UserRegistrationEdit?id=' + userRegList[0].Id);
            }  */
                 p = new PageReference('/apex/ExternalRegistrationNDA');
                 //PageReference pg = Page.ReviewerEmailRegistrationView;
                  System.debug('p:<<<'+ reviewerContact.SecurityToken__c);
                 p.getParameters().put('SecurityToken', reviewerContact.SecurityToken__c);
                 p.getParameters().put('RecordType', 'Reviewer');
                 //p.setRedirect(true); 
               
             
             
        } else if(recordType == 'IndApplicant'){
                 p = new PageReference('/apex/ExternalRegistrationNDA'); 
                 //PageReference pg = Page.ReviewerEmailRegistrationView;
                 //p.getParameters().put('SecurityToken', uniqueToken);
                 p.getParameters().put('RecordType', 'IndApplicant');
                 p.setRedirect(true); 
            }
          
        // For Applicant Registration - swati
        else if(recordType == 'Applicant' && !isReviewer && reviewerContact == null){
             // p = new PageReference('/ApplicantRegistrationView');
              p = new PageReference('/apex/ExternalRegistrationNDA'); 
              p.getParameters().put('RecordType', 'Applicant');
              p.setRedirect(true); 
              
        } else if(recordType == 'Reviewer'){
             p = new PageReference('/apex/ExternalRegistrationNDA'); 
              p.getParameters().put('RecordType', 'Reviewer');
              p.setRedirect(true); 
        } else if(isReviewer && reviewerContact != null && recordType == 'AdditionalApplicant'){ 
              p = new PageReference('/apex/ExternalRegistrationNDA'); 
              p.getParameters().put('SecurityToken', reviewerContact.SecurityToken__c);
              p.getParameters().put('RecordType', 'AdditionalApplicant');
              p.setRedirect(true); 
        }else if(isReviewer && reviewerContact != null && recordType == 'AdditionalApplicantSecondary'){ 
              p = new PageReference('/apex/ExternalRegistrationNDA'); 
              p.getParameters().put('SecurityToken', reviewerContact.SecurityToken__c);
              p.getParameters().put('RecordType', 'AdditionalApplicantSecondary');
              p.setRedirect(true); 
        } else if(isReviewer && reviewerContact != null && recordType == 'Applicant'){ 
              p = new PageReference('/apex/ExternalRegistrationNDA'); 
              p.getParameters().put('SecurityToken', reviewerContact.SecurityToken__c);
              p.getParameters().put('RecordType', 'Applicant');
              p.setRedirect(true); 
        }
       // System.debug('p:<<<'+ p);
    }
    /*
        Shrawan Raina - 11182015 Moved from CommunitySelfRegistrationCtrl
    */
    public void setDefaultValues(UserRegistration__c userReg) {
        if (String.isEmpty(userReg.City__c)) {
            userReg.City__c = 'NA';
        }
        if (String.isEmpty(userReg.Country__c)) {
            userReg.Country__c = 'NA';
        }
        if (String.isEmpty(userReg.Street__c)) {
            userReg.Street__c = 'NA';
        }
        if (String.isEmpty(userReg.State__c)) {
            userReg.State__c = 'NA';
        }
        if (String.isEmpty(userReg.ZipCode__c)) {
            userReg.ZipCode__c = 'NA';
        }


        if (String.isEmpty(userReg.PhysicalCity__c)) {
            userReg.PhysicalCity__c = 'NA';
        }
        if (String.isEmpty(userReg.PhysicalCountry__c)) {
            userReg.PhysicalCountry__c = 'NA';
        }
        if (String.isEmpty(userReg.PhysicalStreet__c)) {
            userReg.PhysicalStreet__c = 'NA';
        }
        if (String.isEmpty(userReg.PhysicalState__c)) {
            userReg.PhysicalState__c = 'NA';
        }
        if (String.isEmpty(userReg.PhysicalZipCode__c)) {
            userReg.PhysicalZipCode__c = 'NA';
        }

        if (String.isEmpty(userReg.PhoneNumber__c)) {
            userReg.PhoneNumber__c = 'NA';
        }
        if (String.isEmpty(userReg.Fax__c)) {
            userReg.Fax__c = 'NA';
        }
        if (String.isEmpty(userReg.OrganizationCityAddress__c)) {
            userReg.OrganizationCityAddress__c = 'NA';
        }
        if (String.isEmpty(userReg.OrganizationState__c)) {
            userReg.OrganizationState__c = 'NA';
        }
        //userReg.Name = userReg.FirstName__c + ' ' + userReg.LastName__c;
    }

}