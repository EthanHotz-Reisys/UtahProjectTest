/**
 A controller for handling the login functionality
 **********************************************************
 Audit History
 **********************************************************
 1/27/2014   Manasi Gangal Created
 **********************************************************  
*/
public with sharing class CommunityLoginCtrl {
     public List<String> URLStringList{get; set;}
     /** This is a hack to determine is the page is using SSL or not.  If CipherSuite is defined that means it is HTTPS **/
    public Boolean hasSSL { get { return ApexPages.currentPage().getHeaders().get('CipherSuite') != null; } }
    public string userName {get;set;}
    public string password {get;set;}
    /** This is used to determine the device type **/
    public String userAgent { get { return ApexPages.currentPage().getHeaders().get('USER-AGENT');  } set; }
   
    /** This will return which Salesforce Server you are on, example: na8.salesforce.com **/
    public String currentServer { get {return ApexPages.currentPage().getHeaders().get('X-Salesforce-Forwarded-To'); } }
   
    public String registrationPageUrl {get;set;}
    public String completeLogoUrl {get;set;}
    public List<string> completeBannerUrls {get;set;}
    public boolean isReviewer {get;set;}
    public boolean NDAPageRequired{get;set;}
    public Boolean displayTerms {get; set;}
    
    private String ns;
    public CommunityLoginCtrl(){
        ns = AppUtils.getNamespacePrefix();
        NDAPageRequired = GNT.KeyValueStoreHelper.getBooleanValue('NDAPageRequired',true);
        displayTerms = GNT.KeyValueStoreHelper.getBooleanValue('DisplayTermsConditionsOnLoginPage',true);
        isReviewer = false;
        if(String.valueOf(ApexPages.CurrentPage()).contains('Reviewer')){
            isReviewer = true;
        }
        String uName = Apexpages.CurrentPage().getParameters().get('username');
        if(uName != 'null'){
            userName = uName;
        } 
        
        Initialize();
    }
    public Boolean getIsNewUserRegWindowOpen(){
        return GNT.AppUtils.getIsNewUserRegWindowOpen();
    }
    public string getNamespace(){
        return AppUtils.getNamespacePrefix();
    }
    
    public void Initialize(){
        String uniqueToken = ApexPages.currentPage().getParameters().get('t');
         getSliderImageURL();
        completeBannerUrls = new List<String>();
        completeLogoUrl = '';     
        Boolean separatePageRequired = GNT.KeyValueStoreHelper.getBooleanValue('ReviewerRegistrationPageRequired',true);
        
        if(separatePageRequired != null && separatePageRequired && isReviewer){
            registrationPageUrl = GNT.KeyValueStoreHelper.getTextValue('ExternalLoginPage', true) + '/'+ns+'c?isReviewer=true&t='+uniqueToken; 
        }else{
            registrationPageUrl = GNT.KeyValueStoreHelper.getTextValue('ExternalLoginPage', true) + '/'+ns+'CommunitySelfRegistration?isReviewer='+isReviewer;
        }  
    }
    
    /** Check the useragent string and assign the device **/
    public String deviceType { get; set; } {
        if (userAgent != null){
            if(userAgent.contains('iPhone')) deviceType = 'iPhone';
            else if(userAgent.contains('iPad')) deviceType = 'iPad';
            else if(userAgent.contains('BlackBerry')) deviceType = 'BlackBerry';
            else deviceType = 'Other';
        }
    }
    
    /** You could query a custom object to determine your home page, check the device or simply hard code it here **/   
    public String returnUrl {get; set; } {
        if (deviceType == 'iPad') {
            returnUrl = '/apex/tablet';
        } else {
            returnUrl = '/home/home.jsp';
        }
    }

    public void dummyRefresh(){
        Initialize();
        
    }
    
    public string getAcceptTermsURL(){
        String url;
        List<GNT__CustomAppFooterConfig__c> entries = [Select GNT__TargetURL__c from GNT__CustomAppFooterConfig__c where GNT__CustomAppName__c='Recipient' and 
                GNT__TermsAndConditions__c=true and GNT__Active__c = true and Name='EL1'limit 1];
                system.debug('entries==================>>>'+entries);
        if(entries.size() == 1){
            url = entries.get(0).GNT__TargetURL__c;
        }
        return url;
    }

    public  PageReference forwardToCustomAuthPage() {
        string host = ApexPages.currentPage().getHeaders().get('host');
        Id annId = System.currentPageReference().getParameters().get('announcementId');
        Id appId = System.currentPageReference().getParameters().get('Id');
        string startURL =  System.currentPageReference().getParameters().get('startURL');
        string t =  System.currentPageReference().getParameters().get('t');
        string isPreApplication = System.currentPageReference().getParameters().get('isPreApplication');
        if(appId != null){
            return new PageReference('https://'+host+'/'+ns+'CommunityLogin?Id='+appId);
        } 
        if(annId != null){
            return new PageReference('https://'+host+'/'+ns+'CommunityLogin?announcementId='+annId+'&isPreApplication='+isPreApplication);
        }else if(!String.isEmpty(startURL)){
            return new PageReference('https://'+host+'/'+ns+'CommunityLogin?startURL='+startURL+'?t='+t);
        }
        else{
            return new PageReference('https://'+host+'/'+ns+'CommunityLogin');
        }
    }
    
    public PageReference login() {
        System.PageReference returnPage;
        String annIdParam = System.currentPageReference().getParameters().get('announcementId');
        String appId = System.currentPageReference().getParameters().get('Id');
        string isPreApplication = System.currentPageReference().getParameters().get('isPreApplication');
        string startURLParam =  System.currentPageReference().getParameters().get('startURL');
        string t =  System.currentPageReference().getParameters().get('t');
        String startURL = '/'+ns+'ApplicationEdit';
        if(appId != null){
            startURL  = '/'+appId+'/e';
            returnPage = Site.login(username, password, startURL); 
        }else if(annIdParam != null){
            if(isPreApplication == 'true'){
                startURL  = '/'+ns+'PreApplicationEdit';
                startURL += '?announcementId='+ annIdParam;
                returnPage = Site.login(username, password, startURL); 
            }else{
                startURL = '/'+ns+'ApplicationEdit';
                startURL += '?announcementId='+ annIdParam;
                returnPage = Site.login(username, password, startURL);
            }
        }else if(!String.isEmpty(startURLParam)){
            if(!String.isEmpty(t)){
                startURL = startURLParam+'?t='+t; 
                returnPage = Site.login(username, password, startURL);
            }else{
                startURL = startURLParam; 
                returnPage = Site.login(username, password, startURL);
            }  
        }
        else{
            returnPage = Site.login(username, password, null);
        }
        if(returnPage != null){
            List<User> userObj = [Select Id, GNT__OrganizationId__c, ContactId,SmallPhotoUrl,IsFirstLoginDone__c,
                            ProfileId, Profile.Name,IsApplicant__c,IsReviewer__c,OrganizationAccountName__c,
                            ProfileName__c ,IsExternalUser__c
                                From User Where username =: username];
            if(userObj != null && userObj.size()> 0){
                setCookie(userObj.get(0).IsApplicant__c);
                
            AppUtils.createUserPreference();    
               // populateThemeIdInCustomSetting(userObj);
            }
        }else{
           // ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter correct username and password');
           // ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR,GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-62573'));
           // ApexPages.addMessage(errorMsg);
            returnPage = new PageReference(GNT.KeyValueStoreHelper.getTextValue('ExternalLoginPage', true));
        }
        return returnPage;
    }
    
   //This call is used to populate Images for Slider shown on External Login Page
    public List<string> getSliderImageURL(){
        String orgId = UserInfo.getOrganizationId();
        String docName = GNT.KeyValueStoreHelper.getTextValue('GovGrantsExternalBanner',true);
        List<Document> docList= new List<Document>();
        String query='SELECT id, Name FROM Document WHERE Name Like \''+docName+'%'+'\'';
        docList= Database.query(query);              
        String baseURL; 
        if(docList.size() > 0){
            URLStringList = new List<String>(); 
            for(Document doc:docList ){
                baseURL = URL.getSalesforceBaseUrl().toExternalForm();
                URLStringList .add(baseURL+'/servlet/servlet.ImageServer?oid='+orgId +'&id='+doc.id);
             }
             return URLStringList; 
        }else{
            return null;
        
        }  
    }
    
    public static void setCookie(Boolean isApplicantUser){
         if(isApplicantUser){
            Cookie isApplicant = ApexPages.currentPage().getCookies().get('isApplicant');
            isApplicant = new Cookie('isApplicant','true',null,-1,false);
            ApexPages.currentPage().setCookies(new Cookie[]{isApplicant});
         }
         else{
            Cookie isReviewer = ApexPages.currentPage().getCookies().get('isReviewer');
            isReviewer = new Cookie('isReviewer','true',null,-1,false);
            ApexPages.currentPage().setCookies(new Cookie[]{isReviewer});
         }
    }
    
    public static void  populateThemeIdInCustomSetting(List<User>userObj){
        
        Id themeDocId;
        GNT__UserPreferences__c uPrefProfileOrgLevel = GNT__UserPreferences__c.getInstance(userObj[0].ProfileId);
        GNT__UserPreferences__c uPref = GNT__UserPreferences__c.getValues(userObj[0].id);
       
        
        
        if(uPref != null){
            if(uPrefProfileOrgLevel != null){
                // Populate user GDC <== Profile GPC, only if these values are not set (NULL)
                uPref.GNT__GrantorDashboardCharts__c = uPref.GNT__GrantorDashboardCharts__c == null ? uPrefProfileOrgLevel.GNT__GrantorPhaseCharts__c : uPref.GNT__GrantorDashboardCharts__c;
                uPref.GNT__GranteeDashboardCharts__c = uPref.GNT__GranteeDashboardCharts__c == null ? uPrefProfileOrgLevel.GNT__GranteePhaseCharts__c : uPref.GNT__GranteeDashboardCharts__c;
                uPref.GNT__RecipientDashboardCharts__c = uPref.GNT__RecipientDashboardCharts__c == null ? uPrefProfileOrgLevel.GNT__RecipientPhaseCharts__c : uPref.GNT__RecipientDashboardCharts__c;
                
                // Populate user GPC <== Profile GPC, only if these values are not set (NULL)
                uPref.GNT__GrantorPhaseCharts__c = uPref.GNT__GrantorPhaseCharts__c == null ? uPrefProfileOrgLevel.GNT__GrantorPhaseCharts__c : uPref.GNT__GrantorPhaseCharts__c;
                uPref.GNT__GranteePhaseCharts__c = uPref.GNT__GranteePhaseCharts__c == null ? uPrefProfileOrgLevel.GNT__GranteePhaseCharts__c : uPref.GNT__GranteePhaseCharts__c;
                uPref.GNT__RecipientPhaseCharts__c = uPref.GNT__RecipientPhaseCharts__c == null ? uPrefProfileOrgLevel.GNT__RecipientPhaseCharts__c : uPref.GNT__RecipientPhaseCharts__c;
                
            }
                    
            if(uPref.GNT__ThemeDocumentId__c == null){
                String themeName = '';
                // Get the theme name associated with the Account
                List<Account> userAcc = [Select Id, ThemeName__c from Account Where Id =:userObj[0].GNT__OrganizationId__c LIMIT 1];
                
                if(userAcc.size() > 0){
                    themeName = userAcc[0].ThemeName__c;
                }
                
                // get Doc id from theme config
                if(themeName != ''){
                    GNT__ThemeConfig__c themeConfig = GNT__ThemeConfig__c.getValues(themeName);
                    
                    if(themeConfig != null && themeConfig.GNT__Active__c == true){
                        themeDocId = themeConfig.GNT__CSSDocumentId__c;
                    }
                }
               
                // Fallback - Else check for profile level first and then org level info from User Pref. Used getInstance method for this.
                if(themeDocId == null){
                    GNT__UserPreferences__c uPrefHierarchyInstance = GNT__UserPreferences__c.getInstance(userObj[0].ProfileId);
                    Id themeIdUserPref = uPrefHierarchyInstance.GNT__ThemeDocumentId__c;
                    
                    if(uPrefHierarchyInstance != null){
                        Map<String, GNT__ThemeConfig__c> allThemesMap = GNT__ThemeConfig__c.getAll();
                        for(GNT__ThemeConfig__c theme : allThemesMap.values()){
                            Id themeId = theme.GNT__CSSDocumentId__c;
                            
                            if(theme.GNT__Active__c && themeId == themeIdUserPref){
                                themeDocId = theme.GNT__CSSDocumentId__c;
                                break;
                            }
                        }
                    }
                }
                
                // update the user preference user record with the css document id
                if(themeDocId != null){
                    //uPref.GNT__ThemeDocumentId__c = themeDocId;
                    upsert uPref;
                }
            }
            
            
            if(( String.isEmpty(uPref.GNT__ProfileName__c))){
                
                uPref.GNT__SmallPhotoURL__c = userObj[0].SmallPhotoUrl;
                uPref.GNT__OrganizationAccountName__c = userObj[0].OrganizationAccountName__c;
                uPref.GNT__ContactId__c = userObj[0].ContactId;
                uPref.GNT__ProfileName__c = userObj[0].Profile.Name;
                uPref.GNT__IsApplicant__c = userObj[0].IsApplicant__c;
                uPref.GNT__IsReviewer__c =  userObj[0].IsReviewer__c;
                uPref.GNT__isInternal__c =  !userObj[0].IsExternalUser__c;
                uPref.GNT__FirstLoginDone__c = userObj[0].IsFirstLoginDone__c;
                upsert uPref;
            }
            // Commented this and moved the upsert statement above because the GUEST user returns FALSE for below IF condition.
            
                //upsert uPref;
            
        }else{
            GNT__UserPreferences__c uPrefUser = GNT__UserPreferences__c.getInstance(userObj[0].ProfileId);
            
            
            uPrefUser.Id = null;
            // Populate user GDC <== Profile GPC
            uPrefUser.GNT__GrantorDashboardCharts__c = uPrefUser.GNT__GrantorPhaseCharts__c;
            uPrefUser.GNT__GranteeDashboardCharts__c = uPrefUser.GNT__GranteePhaseCharts__c;
            uPrefUser.GNT__RecipientDashboardCharts__c = uPrefUser.GNT__RecipientPhaseCharts__c;
            
            
            List<GNT__CustomAppConfig__c> appConfigList = [Select Name, GNT__AvailableForProfiles__c 
                    From GNT__CustomAppConfig__c Where GNT__Active__c = true Order by GNT__Sequence__c];
                    
            String activeAppName = '';
            for(GNT__CustomAppConfig__c capp : appConfigList){
                if(capp.GNT__AvailableForProfiles__c.contains(userObj[0].Profile.Name)){
                    activeAppName = capp.Name;
                    break;
                }
            }
            uPrefUser.GNT__ActiveAppName__c = activeAppName;
            uPrefUser.GNT__SmallPhotoURL__c = userObj[0].SmallPhotoUrl;
            uPrefUser.GNT__OrganizationAccountName__c = userObj[0].OrganizationAccountName__c;
            uPrefUser.GNT__ContactId__c = userObj[0].ContactId;
            uPrefUser.GNT__ProfileName__c = userObj[0].Profile.Name;
            uPrefUser.GNT__IsApplicant__c = userObj[0].IsApplicant__c;
            uPrefUser.GNT__IsReviewer__c =  userObj[0].IsReviewer__c;
            uPrefUser.GNT__isInternal__c =  !userObj[0].IsExternalUser__c;
            uPrefUser.GNT__FirstLoginDone__c = userObj[0].IsFirstLoginDone__c;
            uPrefUser.setupOwnerId = userObj[0].id;
            
            insert uPrefUser;  
        }
    } 

}