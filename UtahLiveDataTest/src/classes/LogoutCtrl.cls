/**
* Class to handle the Logout page
* 
* CHANGE HISTORY
* =============================================================================
* Date          Name            Description
* 05/21/2014    Kunal Shah      Created
* 8/10/2014     Nakul Kadam     Updated to redirect the Reviewer user to appropriate page
* 2017-04-01    Shah Kadirmohideen  Code Reviewed
* =============================================================================
*/

public with sharing class LogoutCtrl {
    
    public string loginPage {get;set;}
    public string cookieName {get;set;}
    
    public LogoutCtrl(){
        User user = [Select IsExternalUser__c, IsApplicant__c from User where Id=:UserInfo.getUserId()];
        if (user.IsExternalUser__c) {
            if (user.IsApplicant__c) {
                loginPage = GNT.KeyValueStoreHelper.getTextValue('ExternalLoginPage', true) + '/ApplicantLogin4?username=null';
                cookieName = 'apex__isApplicant';
            }
            else {  //reviewer
                //loginPage = GNT.KeyValueStoreHelper.getTextValue('ExternalLoginPage', true) + '/' + AppUtils.getNamespacePrefix() + 'ReviewerLogin';
                loginPage = GNT.KeyValueStoreHelper.getTextValue('ExternalLoginPage', true) + '/ApplicantLogin4?username=null';
                cookieName = 'apex__isReviewer';
            }
        }
        else {
            loginPage = GNT.KeyValueStoreHelper.getTextValue('InternalLoginPage', true);
            cookieName = 'apex__isInternal';
        }
    }
}