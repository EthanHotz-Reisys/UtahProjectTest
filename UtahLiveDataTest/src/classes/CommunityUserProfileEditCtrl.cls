public class CommunityUserProfileEditCtrl {

    //Properties
    public PageReference savePage {get; set;}
    public PageReference cancelPage {get; set;}
    public String flexTableParameters {get; set;}
    public boolean isFirstLogin {get; set;}
    public String templateName {get; set;}
    public Id recordId {get; set;}
    public String userRole;
    public Map<String, String> keyValueMap = new Map<String, String>();

    public CommunityUserProfileEditCtrl(ApexPages.StandardController stdController) {
        String contactId = ApexPages.currentPage().getParameters().get('Id');
        system.debug('contactId--->>>' + contactId);
        if (!String.isEmpty(contactId)) {
            recordId =  contactId;
        } else {
            system.debug('id parameter is null');
            List<User> currentUser = [SELECT contactId, Id FROM User WHERE Id = :userInfo.getUserId()];
            if (currentUser.size() > 0) {
                recordId =  currentUser[0].ContactId;
            }
        }

        Contact contactApplicantOrReviewer = [SELECT Id, Name, UserRoleFormula__c FROM Contact WHERE Id = :recordId];
        userRole = contactApplicantOrReviewer.UserRoleFormula__c;
        if (!String.isEmpty(userRole) && userRole.equalsIgnoreCase('external reviewer')) {
            templateName = 'ContactViewForExternalReviewer';
        } else if (!String.isEmpty(userRole) && userRole.containsIgnoreCase('applicant')) {
            templateName = 'ExtUserRegistrationProfile';
        } else {
            templateName = 'Contact';
        }
        //system.debug('templateName ====>>'+templateName );
        keyValueMap.put('ContactId', contactId); // recordId );
        flexTableParameters = JSON.serialize(keyValueMap);
        String appHomeTab = '';
        GNT__UserPreferences__c uPref = GNT__UserPreferences__c.getInstance(UserInfo.getUserId());
        if (uPref != null) {
            String appName = uPref.GNT__ActiveAppName__c;
            Map<String, GNT__CustomAppPhaseConfig__c> appPhaseConfigMap = GNT__CustomAppPhaseConfig__c.getAll();
            for (GNT__CustomAppPhaseConfig__c appPhase : appPhaseConfigMap.values()) {
                if (appPhase.GNT__CustomAppName__c == appName && appPhase.GNT__Active__c == true && appPhase.GNT__SelectedByDefault__c == true) {
                    appHomeTab = appPhase.Name;
                    break;
                }
            }
        }
        //isFirstLogin = isfirstLogin();
        System.debug('isFirstLogin--->>>' + isFirstLogin);
        //if(isFirstLogin == true){
        savePage = Page.GNT__PhaseView;
        savePage.getParameters().put('t', appHomeTab);
        cancelPage = Page.GNT__PhaseView;
        cancelPage.getParameters().put('t', appHomeTab);
        //}
        /*else{
            savePage = Page.CommunityUserProfileView;
            savePage.getParameters().put('id',contactId);
            cancelPage = Page.CommunityUserProfileView;
            cancelPage.getParameters().put('id',contactId);
        } */

    }
    public boolean isFirstLogin() {
        boolean hideSidebar = false;
        User loggedInUser;
        List<User> userObj = [Select Id, UserType, Firstname, Lastname, OrganizationAccountName__c,
                              LastLoginDate, ContactId, smallphotourl, Profile.Name, IsApplicant__c, IsFirstLoginDone__c
                              from User where Id = :UserInfo.getUserId()];
        loggedInUser =   userObj[0];
        if (Network.getNetworkId() != null) {
            // Code to check the whether the first login of the user has been already done or not
            Boolean byPassProfileEditPage = false;
            if (loggedInUser.IsFirstLoginDone__c != null && !loggedInUser.IsFirstLoginDone__c) {
                hideSidebar = true;
            }
        }
        return hideSidebar;
    }
}