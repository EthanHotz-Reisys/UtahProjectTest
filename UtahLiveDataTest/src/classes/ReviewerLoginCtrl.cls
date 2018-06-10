/*
    10/8/2014        Nakul Kadam        Created
*/
public with sharing class ReviewerLoginCtrl {

    public PageReference forwardToStartPage() {
        String ns = AppUtils.getNamespacePrefix();
        Id annId = System.currentPageReference().getParameters().get('announcementId');
        String isPreApplication = System.currentPageReference().getParameters().get('preApplication');
        string host = ApexPages.currentPage().getHeaders().get('host');
        String username=System.currentPageReference().getParameters().get('username');
        String startUrl = System.currentPageReference().getParameters().get('startURL');
        
        if(UserInfo.getUserType() == 'Guest' || Test.isRunningTest()){      // Redirect to appropriate page 
            String pageName;
            for(LoginPageConfig__c loginConfig : LoginPageConfig__c.getAll().values()){
                if(loginConfig.Active__c == true && loginConfig.userType__c == 'Reviewer'){
                    pageName = AppUtils.getNamespacePrefix()+loginConfig.pageName__c;
                    break;
                }
            }
            if(!String.isEmpty(pageName)){
                if(annId != null){
                    return new PageReference('https://'+host+'/'+pageName+'?announcementId='+annId+'&isPreApplication='+isPreApplication + '&username='+username  );
                }else if(System.currentPageReference().getParameters().get('id') != null){
                	return new PageReference('https://'+host+'/'+pageName+'?id='+ System.currentPageReference().getParameters().get('id')+'&username='+username);
                }else if(!String.isEmpty(startUrl)){
                	return new PageReference('https://'+host+'/'+pageName+'?startURL='+startUrl);
                }else{
                    return new PageReference('https://'+host+'/'+pageName+'?username='+username);
                }
             }else{
                // Do we need to have some kind of default page for login if the sutom setting does not specify any?
             }
         }
         else{
          GNT__UserPreferences__c uPref = GNT__UserPreferences__c.getValues(UserInfo.getUserId());
            List<User> userObj = [Select Id, GNT__OrganizationId__c, ContactId,SmallPhotoUrl,IsFirstLoginDone__c,
   	 						ProfileId, Profile.Name,IsApplicant__c,IsReviewer__c,OrganizationAccountName__c,
   	 					 ProfileName__c ,IsExternalUser__c
                                From User Where Id =: UserInfo.getUserId()];
         	User loggedInUser = userObj[0];
            Boolean byPassProfileEditPage = GNT.KeyValueStoreHelper.getBooleanValue('ByPassProfileEditPageForReviewer', true) ;
            if(byPassProfileEditPage == null){
            	byPassProfileEditPage = false;
            }
            if(loggedInUser.IsFirstLoginDone__c == true || byPassProfileEditPage){
            	String appHomeTab = '';
				String appName = uPref.GNT__ActiveAppName__c;
				system.debug('appName--->>>'+appName);
				Map<String, GNT__CustomAppPhaseConfig__c> appPhaseConfigMap = GNT__CustomAppPhaseConfig__c.getAll();
				for(GNT__CustomAppPhaseConfig__c appPhase : appPhaseConfigMap.values()){
					if(appPhase.GNT__CustomAppName__c == appName && appPhase.GNT__Active__c == true && appPhase.GNT__SelectedByDefault__c == true){
						appHomeTab = appPhase.Name;
						break;
					}
				}
                return new PageReference('/apex/' + ns + 'PhaseView?t=RecipientHome&Id='+loggedInUser.ContactId);
            }else{
            	loggedInUser.IsFirstLoginDone__c = true;
            	update loggedInUser;
            	
            	uPref.GNT__FirstLoginDone__c = true;
            	update uPref;
                return new PageReference('/apex/' + ns + 'CommunityUserProfileEdit?Id='+loggedInUser.ContactId);
            }
        }
        return null;
    }

}