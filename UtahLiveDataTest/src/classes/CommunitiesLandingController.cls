/**
 * An apex page controller that takes the user to the right start page based on credentials or lack thereof

 **********************************************************
 Audit History
 **********************************************************
 1/27/2014   Manasi Gangal Created
 **********************************************************  
*/
 
public with sharing class CommunitiesLandingController {
    public boolean isWarning {get; set;}
    public String warningTitle {get; set;}
    public String warningMessage {get; set;}
    String ns = AppUtils.getNamespacePrefix();
    // Code we will invoke on page load.
    public PageReference forwardToStartPage() { 
        isWarning = false; 
        Id annId = System.currentPageReference().getParameters().get('announcementId');
        String isPreApplication = System.currentPageReference().getParameters().get('preApplication');
        String applicationID = System.currentPageReference().getParameters().get('startURL');
        String appId = System.currentPageReference().getParameters().get('Id');
        string host = ApexPages.currentPage().getHeaders().get('host');
        String userName = System.currentPageReference().getParameters().get('username');
        if(UserInfo.getUserType() == 'Guest'){      // Redirect to appropriate page 
            String pageName;
            for(LoginPageConfig__c loginConfig : LoginPageConfig__c.getAll().values())  {
                if(loginConfig.Active__c == true && loginConfig.userType__c == 'Applicant'){
                    pageName = AppUtils.getNamespacePrefix()+loginConfig.pageName__c;
                    break;
                }
            }
            if(!String.isEmpty(pageName)){
                if(appId != null){                  
                        return new PageReference('https://'+host+'/'+pageName+'?Id='+appId + '&username=' + userName);                  
                }else if(annId != null){                
                        return new PageReference('https://'+host+'/'+pageName+'?announcementId='+annId+'&isPreApplication='+isPreApplication + '&username='+userName );                 
                }else{                
                        return new PageReference('https://'+host+'/'+pageName +'?username='+userName );                 
                }
             }else{
                // Do we need to have some kind of default page for login if the sutom setting does not specify any?
             }
         }
         else{ 
            GNT__SystemMaintenance__c sysMaintenance = GNT__SystemMaintenance__c.getInstance(UserInfo.getUserId());            
            if(sysMaintenance.GNT__Active__c == true && System.now() >= sysMaintenance.GNT__WarningFrom__c && System.now() <= sysMaintenance.GNT__WarningTo__c){                
                isWarning = true;
                warningTitle = sysMaintenance.GNT__WarningTitle__c;
                List<GNT__HelpConfig__c> helpList = [Select id,Name,GNT__HelpText__c FROM GNT__HelpConfig__c WHERE Name=:sysMaintenance.GNT__WarningMessage__c limit 1]; 
                warningMessage = helpList[0].GNT__HelpText__c;
                return new PageReference('/apex/' + ns + 'SystemMaintenanceWarning');
            }  
            else{ 
                return redirectToHomePage();
            }
        }
        return null;
    }
    
    public PageReference redirectToHomePage(){
            List<User> userObj = [Select Id, GNT__OrganizationId__c, ContactId,SmallPhotoUrl,IsFirstLoginDone__c,
                            ProfileId, Profile.Name,IsApplicant__c,IsReviewer__c,OrganizationAccountName__c,
                            ProfileName__c ,IsExternalUser__c
                                From User Where Id =: UserInfo.getUserId()];
            User loggedInUser = userObj[0];            
            CommunityLoginCtrl.setCookie(loggedInUser.IsApplicant__c);
            CommunityLoginCtrl.populateThemeIdInCustomSetting(userObj); 
            Boolean byPassProfileEditPage = false;
            if (loggedInUser.IsApplicant__c) {
                bypassProfileEditPage = GNT.KeyValueStoreHelper.getBooleanValue('ByPassProfileEditPage', true);
            }
            else {
                byPassProfileEditPage = GNT.KeyValueStoreHelper.getBooleanValue('ByPassProfileEditPageForReviewer', true) ;
            }

            if(byPassProfileEditPage == null){
                byPassProfileEditPage = false;
            }
            
            if(loggedInUser.IsFirstLoginDone__c == true || byPassProfileEditPage){
                String appHomeTab = '';
                GNT__UserPreferences__c uPref = GNT__UserPreferences__c.getInstance(UserInfo.getUserId());
                String appName = uPref.GNT__ActiveAppName__c;
                Map<String, GNT__CustomAppPhaseConfig__c> appPhaseConfigMap = GNT__CustomAppPhaseConfig__c.getAll();
                for(GNT__CustomAppPhaseConfig__c appPhase : appPhaseConfigMap.values()){
                    if(appPhase.GNT__CustomAppName__c == appName && appPhase.GNT__Active__c == true && appPhase.GNT__SelectedByDefault__c == true){
                        appHomeTab = appPhase.Name;
                        break;
                    }
                } 
                
                return new PageReference('/apex/' + ns + 'PhaseView?t='+appHomeTab+'&Id='+loggedInUser.ContactId);
                
            }else{
                loggedInUser.IsFirstLoginDone__c = true;
                update loggedInUser;
                
             GNT__UserPreferences__c uPref = GNT__UserPreferences__c.getValues(UserInfo.getUserId());
                uPref.GNT__FirstLoginDone__c = true;
                update uPref;
                return new PageReference('/apex/' + ns + 'CommunityUserProfileView?Id='+loggedInUser.ContactId);
            }
    }
    public CommunitiesLandingController() {
       
    }
}