/*
    Provides search functionality for partners and also allows creation of new partners,
    delete partners and edit partners.
    
    ***********************************************************
    Audit History
    ***********************************************************
    2012-11-30      Jagan Valayapathy   Created
    2014-02-26      Glen Watson         Uncommented the debug lines
    2014-05-09      Hafsa Syed          Updated getCurrentFiscalYear
    *********************************************************** 
*/
global with sharing class AppUtils {  
    public static Boolean skipAccountTrigger = false;
    public static Boolean skipDohAnnouncementTrigger = false;
    public static Boolean skipDohApplicationTrigger = false;
    public static Boolean skipDOH_ProgramTrigger = false;
    public static Boolean skipStepReviewTrigger = false;
    public static Boolean skipDOH_UserTrigger = false;
    public static Boolean skipAnnoucementTrigger = false;
         
    //Input value points to UserRegistration__c.RecordType.DeveloperName
    public static Id getCommunityProfileId(String recordTypeName) {
        System.debug('recordTypeName: ' + recordTypeName);
        for (CommunityProfileConfig__c profileConfig : CommunityProfileConfig__c.getAll().values()) {
            if (profileConfig.ExternalRegistrationRecordType__c == recordTypeName) {
                System.debug('config: ' + profileConfig);
                List<Profile> pList = [Select Id from Profile where Name=:profileConfig.ProfileName__c limit 1];
                if (pList.size() == 1) {
                    return pList.get(0).Id;
                }
            }
        }
        return null;
    }
    
    public static PageReference getHomePage() {
        String activeAppName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
        List<GNT__PhaseConfig__c> phaseConfigAttributes = [select  GNT__URL__c FROM GNT__PhaseConfig__c where GNT__CustomAppName__c = : activeAppName 
                                                      and GNT__SelectedByDefault__c = true limit 1];
        if(phaseConfigAttributes.size() > 0) {
            String url = phaseConfigAttributes[0].GNT__URL__c;
            return new PageReference(url);
        }
        return null;
    }
    
    public static void createUserPreference(){
    System.debug(LoggingLevel.ERROR,'inside createUserPreference');
         GNT__UserPreferences__c pref = GNT__UserPreferences__c.getValues(userInfo.getUserId());
          System.debug('inside createUserPreference--pref--'+pref);
       if(pref == null){
            List<User> userObj = [Select Id, ContactId,SmallPhotoUrl,IsFirstLoginDone__c,
                            ProfileId, Profile.Name,IsApplicant__c,IsReviewer__c,OrganizationAccountName__c,
                            ProfileName__c ,IsExternalUser__c, AccountId
                                From User Where Id =: UserInfo.getUserId()];
            GNT__UserPreferences__c prefProfile = GNT__UserPreferences__c.getValues(userInfo.getProfileId());
             System.debug(LoggingLevel.ERROR,'inside createUserPreference--prefProfile--'+prefProfile);
            if(prefProfile == null){
                pref = prefProfile = GNT__UserPreferences__c.getOrgDefaults();
                pref.id = null;
                pref.SetupOwnerId = userInfo.getUserId();
                prefProfile.id = null;
                prefProfile.SetupOwnerId = userInfo.getProfileId();
                upsert prefProfile;
            }else{
                pref = prefProfile;
                pref.id = null;
                pref.SetupOwnerId = userInfo.getUserId();
                pref.GNT__OrganizationAccountId__c = null;
            }
            System.debug('pref=========' + pref);
            System.debug('userObj=========' + userObj);
            pref.GNT__SmallPhotoURL__c = userObj[0].SmallPhotoUrl;
            pref.GNT__OrganizationAccountName__c = userObj[0].OrganizationAccountName__c;
            pref.GNT__OrganizationAccountId__c = userObj[0].AccountId;
            pref.GNT__ContactId__c = userObj[0].ContactId;
            pref.GNT__ProfileName__c = userObj[0].Profile.Name;
            pref.GNT__IsApplicant__c = userObj[0].IsApplicant__c;
            pref.GNT__IsReviewer__c =  userObj[0].IsReviewer__c;
            pref.GNT__IsInternal__c =  !userObj[0].IsExternalUser__c;
            pref.GNT__FirstLoginDone__c = userObj[0].IsFirstLoginDone__c;
            upsert pref;
            if(UserInfo.getUserType()=='Standard'){
                populateInternalThemeId(userObj);
            }
       }else if(pref.GNT__FirstLoginDone__c == false){
        System.debug(LoggingLevel.ERROR,'inside createUserPreference--pref-first login false-');
            List<User> userObj = [Select Id, ContactId,SmallPhotoUrl,IsFirstLoginDone__c,
                            ProfileId, Profile.Name,IsApplicant__c,IsReviewer__c,OrganizationAccountName__c,
                            ProfileName__c ,IsExternalUser__c
                                From User Where Id =: UserInfo.getUserId()];
            pref.GNT__SmallPhotoURL__c = userObj[0].SmallPhotoUrl;
            pref.GNT__OrganizationAccountName__c = userObj[0].OrganizationAccountName__c;
            pref.GNT__ContactId__c = userObj[0].ContactId;
            pref.GNT__ProfileName__c = userObj[0].Profile.Name;
            pref.GNT__IsApplicant__c = userObj[0].IsApplicant__c;
            pref.GNT__IsReviewer__c =  userObj[0].IsReviewer__c;
            pref.GNT__IsInternal__c =  !userObj[0].IsExternalUser__c;
            pref.GNT__FirstLoginDone__c = userObj[0].IsFirstLoginDone__c;
            upsert pref;
       } 
         System.debug(LoggingLevel.ERROR,'inside createUserPreference--pref55--'+pref);
    }
    
    public static Object getFieldValue(Sobject record, String fieldAPIName) {
        if(String.isEmpty(fieldAPIName)) {
            return null;
        }
        Object value = null;
        if(fieldAPIName.contains('.')){
            List<String> relationshipFields = fieldAPIName.split('\\.');
            Sobject temp;
            integer i = 0;
            for(i=0;i<relationshipFields.size()-1;i++){    
                String singleField = relationshipFields[i];                                                 
                if(temp == null){
                    temp = record.getSobject(singleField);
                    
                }else{
                    temp = temp.getSobject(singleField);
                }   
            } 
            if(temp != null && temp.get(relationshipFields[i]) != null){
                value = temp.get(relationshipFields[i]);
            }
        }else{
            value = record.get(fieldAPIName);
        }
        return value;
    }
    
    private static void populateInternalThemeId(List<User> userObj){
        String themeName = '';
        if(userObj != null && userObj.size() > 0 ){
            // fetch profile level or org level userpreference record.
            GNT__UserPreferences__c uPrefProfileOrgLevel = GNT__UserPreferences__c.getInstance(userObj[0].ProfileId);
            GNT__UserPreferences__c uPref = GNT__UserPreferences__c.getValues(UserInfo.getUserId());
            if(uPref != null){
                // populate charts ids
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
                // populdate theme id
                if(uPref.GNT__ThemeDocumentId__c == null){
                    // Scan Acc hierarchy to get theme name - then get Doc id from theme config
                
                    List<Account> parentAcc = [Select Id, ParentId, Parent.ParentId, 
                            Parent.Parent.ParentId, ThemeName__c from Account 
                                Where Id =:userObj[0].OrganizationAccountName__c];
                    // check ThemeName__c in immidiate parent account
                    if(parentAcc != null && parentAcc.size() > 0 && parentAcc[0].ThemeName__c != null){
                        themeName = parentAcc[0].ThemeName__c;
                        
                    }
                    // Else check ThemeName__c in outer most parent account in the same hierarchy
                    else if(parentAcc != null && parentAcc.size() > 0){
                        Id parentId;
                        if(parentAcc[0].Parent.Parent.ParentId != null){
                            parentId = parentAcc[0].Parent.Parent.ParentId;
                        }else if(parentAcc[0].Parent.ParentId != null){
                            parentId = parentAcc[0].Parent.ParentId;
                        }else if(parentAcc[0].ParentId != null){
                            parentId = parentAcc[0].ParentId;
                        }
                        List<Account> outerMostAcc = [Select Id, ThemeName__c 
                                                from Account Where Id =:parentId];
                        if(outerMostAcc != null && outerMostAcc.size() > 0){
                            themeName = outerMostAcc[0].ThemeName__c;
                        }
                    }
                    
                    Id themeDocId;
                    // get Doc id from theme config
                    if(themeName != ''){
                        GNT__ThemeConfig__c themeConfig = GNT__ThemeConfig__c.getValues(themeName);
                        if(themeConfig != null && themeConfig.GNT__Active__c == true){
                            themeDocId = themeConfig.GNT__CSSDocumentId__c;
                        }
                    }
                    // Fallback - Else check for profile level first and then org level info from User Pref. using getInstance()
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
                    if(themeDocId != null){
                      //  uPref.GNT__ThemeDocumentId__c = themeDocId;                     
                        upsert uPref;
                    }
                }
                
                // Commented this and moved the upsert statement above because the GUEST user returns FALSE for below IF condition.
                /*if(Schema.sObjectType.UserPreferences__c.isUpdateable() && Schema.sObjectType.UserPreferences__c.isCreateable()){
                    upsert uPref;
                }*/
            }
            // create user preference record if not present already
            else{
                GNT__UserPreferences__c uPrefUser = GNT__UserPreferences__c.getInstance();
                uPrefUser.SetupOwnerId = UserInfo.getUserId();
                // Populate user GDC <== Profile GPC
                uPrefUser.GNT__GrantorDashboardCharts__c = uPrefUser.GNT__GrantorPhaseCharts__c;
                uPrefUser.GNT__GranteeDashboardCharts__c = uPrefUser.GNT__GranteePhaseCharts__c;
                uPrefUser.GNT__RecipientDashboardCharts__c = uPrefUser.GNT__RecipientPhaseCharts__c;
                
                //Map<String, CustomAppConfig__c> appConfig = CustomAppConfig__c.getAll();
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
                
                    insert uPrefUser;
               
            }
        }
   }
   
   public static sobject getSObjectFromJSON() {
        String pageDataHolderId = ApexPages.CurrentPage().getParameters().get('pageDataHolder');
        GNT__PageDataHolder__c pageDataHolder = [select id, GNT__JSONData1__c from GNT__PageDataHolder__c where id=:pageDataHolderId];
        SObject record;
        if(pageDataHolder.GNT__JSONData1__c != null) {
            record = (SObject)JSON.deserialize(pageDataHolder.GNT__JSONData1__c, SObject.Class);
        }
        return record;
   }
   
   public static void sendEmailToUsersUsingContact(Id templateId, Map<Id,Set<Id>> appIdToContIdSetMap) {
        Savepoint sp = Database.setSavepoint();
        Set<Id> userIds = new Set<Id>();
        Map<String, String> idByEmail = new Map<String, String>();
        for(Id recId : appIdToContIdSetMap.keySet()) {
            userIds.addAll(appIdToContIdSetMap.get(recId));
        }
        System.debug('userIds--' + userIds);
        List<User> users = [select id, FirstName, LastName, Email from User where Id in:userIds];
        //List<Contact> contacts = new List<Contact>();
        for(User user : users) {
            idByEmail.put(user.Id, user.Email);
        }
        Map<Id, String[]> recIdToEmail = new Map<Id, String[]>();
        for(Id recId : appIdToContIdSetMap.keySet()) {
            String[] emailLst = new List<String>();
            for(Id userId : appIdToContIdSetMap.get(recId)) {
                emailLst.add(idByEmail.get(userId));
            }
            recIdToEmail.put(recId, emailLst);
        }
        List<Contact> cnts = [select id from Contact limit 1];
        System.debug('recIdToEmail---' + recIdToEmail);
        sendEmailUsingTemplate(templateId, recIdToEmail, cnts[0].Id, false);
            //System.debug(idByEmail + '----' );
            //contacts.add(new Contact(FirstName = user.FirstName, LastName = user.LastName, Email = user.Email));
        /*insert contacts;
        Map<String, String> conIdByEmail = new Map<String, String>();
        for(Contact con : contacts) {
            conIdByEmail.put(con.Email+con.FirstName+con.LastName, con.Id);
        }
        for(String userId : idByEmail.keySet()) {
            System.debug(idByEmail.get(userId) + '----' + conIdByEmail.get(idByEmail.get(userId)));
            idByEmail.put(userId, conIdByEmail.get(idByEmail.get(userId)));
        }
        for(Id sobjId : appIdToContIdSetMap.keySet()) {
            Set<Id> conIdLst = new Set<Id>();
            for(Id userId : appIdToContIdSetMap.get(sobjId)) {
                conIdlst.add(idByEmail.get(userId));
            }
            appIdToContIdSetMap.put(sobjId, conIdlst);
        }
        sendEmailUsingTemplate(templateId, appIdToContIdSetMap);
        //Database.rollback( sp );*/
   }
   
   // method to send email to users without contact using email templates
    global static void sendEmailUsingTemplate(Id templateId, Map<Id, String[]> recIdToAddressMap, Id dummyContactId,  boolean setOWD){
        List<GNT.EmailFeeder> emailFeeders = new List<GNT.EmailFeeder>();
        
        String templateName = [select DeveloperName from EmailTemplate where Id = :templateId].DeveloperName;
        for(Id whatId : recIdToAddressMap.keyset()){
            String[] contIdSet = recIdToAddressMap.get(whatId);
            for(String contId : contIdSet){
                GNT.EmailFeeder emailFeeder = new GNT.EmailFeeder();
                emailFeeder.contextRecordId(whatId).template(templateName).toEmail(contId).send(); 
                emailFeeders.add(emailFeeder);
            }
        }
        GNT.EmailFeeder.SendEmails(emailFeeders);
        /*List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<OrgWideEmailAddress> owaList = new List<OrgWideEmailAddress>();

        if(setOWD){
            String OWDName = GNT.KeyValueStoreHelper.getTextValue('OWDName',true);   
            owaList=[select id, DisplayName from OrgWideEmailAddress where DisplayName=:OWDName LIMIT 1];
        }
        
        for(Id recId : recIdToAddressMap.keySet()){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTemplateId(templateId);
            mail.setWhatId(recId);    
            mail.setTargetObjectId(dummyContactId);
            mail.setToAddresses(recIdToAddressMap.get(recId));
            mail.saveAsActivity = false;
            if(setOWD && owaList!= null && owaList.size () > 0){
                mail.setOrgWideEmailAddressId(owaList[0].id);
            }
            mails.add(mail);
        }
        if (!Test.isRunningTest()) {
            // Send the emails in a transaction, then roll it back
            Savepoint sp = Database.setSavepoint();
            Messaging.sendEmail(mails);
            Database.rollback(sp);
        }
        // For each SingleEmailMessage that was just populated by the sendEmail() method, copy its
        // contents to a new SingleEmailMessage. Then send those new messages.
        List<Messaging.SingleEmailMessage> lstMsgsToSend = new List<Messaging.SingleEmailMessage>();
        for (Messaging.SingleEmailMessage email : mails) {
            Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
            emailToSend.setToAddresses(email.getToAddresses());
            emailToSend.setPlainTextBody(email.getPlainTextBody());
            emailToSend.setHTMLBody(email.getHTMLBody());
            emailToSend.setSubject(email.getSubject());
            lstMsgsToSend.add(emailToSend);
        }
        if (!Test.isRunningTest()) {
            Messaging.sendEmail(lstMsgsToSend);
        }*/
    }
    
   public static void sendEmailUsingTemplate(Id templateId, Map<Id,Set<Id>> appIdToContIdSetMap){
        List<GNT.EmailFeeder> emailFeeders = new List<GNT.EmailFeeder>();
        
        String templateName = [select DeveloperName from EmailTemplate where Id = :templateId].DeveloperName;
        for(Id whatId : appIdToContIdSetMap.keyset()){
            Set<Id> contIdSet = appIdToContIdSetMap.get(whatId);
            for(Id contId : contIdSet){
                GNT.EmailFeeder emailFeeder = new GNT.EmailFeeder();
                emailFeeder.contextRecordId(whatId).template(templateName).TargetObjectId(contId).send(); 
                emailFeeders.add(emailFeeder);
            }
        }
        GNT.EmailFeeder.SendEmails(emailFeeders);
        
        /*
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<OrgWideEmailAddress> owaList = new List<OrgWideEmailAddress>();

        for(Id whatId : appIdToContIdSetMap.keyset()){
            Set<Id> contIdSet = appIdToContIdSetMap.get(whatId);
            for(Id contId : contIdSet){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTemplateId(templateId);
                mail.setWhatId(whatId);
                mail.saveAsActivity = false;   
                System.debug('contId--' + contId); 
                mail.setTargetObjectId(contId);
                
                mails.add(mail);
            }
        }
        if (!Test.isRunningTest()) {
            Messaging.sendEmail(mails);
        }*/
    }
   
   public static String getNameSpacePrefix(){
    return '';
   }
    public static String concatenate(String[] arr, String sep) {
        String result = '';
        if (arr == null) return result;
        Integer i=1;
        for (String ele : arr) {
            result += ele;
            if (i < arr.size()) result += sep;
            i++;
        }
        return result;
    }
   // Check the Budget Periods for following
    // 1. Sum of BPs = PP  2.  There is no Gap in BPs  3. There is no overlap in BPs
    Public Static Boolean validateBudgetPeriods(Date startDate, Date endDate, List<BudgetPeriod__c> budPeriod){
      
      Date bpStartDate , bpEndDate;
      Integer size = budPeriod.size();
      System.debug('TESTTERTE======>'+budPeriod.size());
      if(size>0){
          bpStartDate=budPeriod[0].BudgetStartDate__c;
          System.debug('TESTTERTE11======>'+bpStartDate);
          bpEndDate=budPeriod[size-1].BudgetEndDate__c;
          System.debug('TESTTERTE22======>'+bpEndDate);
          System.debug('PARMATERLIST =================>'+startDate+endDate+budPeriod);
          if(startDate != bpStartDate || endDate!=bpEndDate ){
             return false;
          }
          for(Integer i = 0; i<size-1; i++){
            if(budPeriod[i].BudgetEndDate__c.adddays(1)!=budPeriod[i+1].BudgetStartDate__c ){
              return false;
            }
          }
      }  
      else { return false; }

      return true;
    }
    
    
    public class EntityHierarchyResolver {
          public Map<String, List<String>> entityNames = new Map<String, List<String>>{
               'Program__c' => new List<String>{'Announcement__c'}, 
               'Announcement__c' => new List<String>{'Application__c'}, 
               'Application__c' => new List<String>{'Grant__c'},
               'Grant__c' => new List<String>{'Award__c'},
               'Award__c' => new List<String>{'PaymentRequest__c', 'AmendmentRequest__c'} 
          };
         public Map<string, string> fieldNames = new Map<string,string>{
               'Program__c' => 'Id', 
               'Announcement__c' => 'Program__c', 
               'Application__c' => 'Announcement__c', 
               'Grant__c' => 'Application__c', 
               'Award__c' => 'Grant__c',
               'PaymentRequest__c' => 'Award__c',
               'AmendmentRequest__c' => 'Award__c'
          };
          public Set<Id> getIds(string entityName, Set<Id> ids){
               Set<Id> results = new Set<Id>();
               if(fieldNames.containsKey(entityName) &&  ids != null && ids.size() > 0 ){
                    if(fieldNames.get(entityName).length()> 0){
                         string query= 'Select Id from ' + entityName + ' where ' +  fieldNames.get(entityName) + ' in '  + GNT.AppUtils.soqlList(ids);
                         System.debug(query);
                         List<SObject> entities = Database.query(query);
                         System.debug('>>>'+entities.size());
                         Set<Id> myIds = resolveSObjects(entities);
                         if(myIds != null && myIds.size() > 0){
                              results.addAll(myIds);
                         }
                    }
                    if(entityNames.containsKey(entityName)){
                         List<String> children = entityNames.get(entityName);
                         for(string child : children){
                              system.debug('>>> for child' + child);
                              Set<Id> childIds = getIds(child, results);
                              if(childIds != null && childIds.size() > 0){
                                   results.addAll(childIds);
                              }
                         }
                    }
               }
               return results;
          }     
          public Set<Id> resolveSObjects(List<SObject> entities){
               Set<Id> ids = new Set<Id>();
               for(SObject entity : entities){
                    Id id = (Id) entity.get('Id');
                         if(id != null){
                              ids.add(id);
                         }
               }
               return ids;
          }
     }
    

    public class TaskEmailWrapper {
        private List<Id> objectIdList = new List<Id>(); //
        private List<User> userList = new List<User>(); //Each must have Id, ContactId, and Email
        private String taskActionName;
        private String taskSubject;
        private Date taskStartDate;
        private Date taskEndDate;
        private String emailTemplateDevName;
        private Map<Id, List<User>> accountIdMapUserList = new Map<Id, List<User>>();
        private Map<String, String> objectTypeMapRecipientOrgApi = new Map<String, String>{ 
            'Award__c' => 'Grant__r.InternalOrganization__c', 'Application__c' => 'ExternalOrganization__c', 'AmendmentRequest__c' => 'Grant__r.InternalOrganization__c'
        };

        public void setObjectList(List<Id> recordList) {
            objectIdList.addAll(recordList);
        }
        public void setObjectList(Id record) {
            objectIdList.add(record);
        }
        public void setUserIds(List<Id> users) {
            userList = [SELECT Id, ContactId, Email FROM User WHERE Id IN: users];
        }
        public void setUserIds(Id users) {
            setUserIds(new List<Id>{users});
        }
        public void setUserList(List<User> users) {
            userList.addAll(users);
        }
        public void setUserList(User users) {
            userList.add(users);
        }
        public void setTaskActionName(String actionName) {
            taskActionName = actionName;
        }
        public void setTaskSubject(String subjectName) {
            taskSubject = subjectName;
        }
        public void setTaskStartDate(Date startDate) {
            taskStartDate = startDate;
        }
        public void setTaskEndDate(Date endDate) {
            taskEndDate = endDate;
        }
        public void setEmailTemplateDevName(String emailDevName) {
            emailTemplateDevName = emailDevName;
        }   
        public void setAccountIdMapUserList(Map<Id, List<User>> accIdMapUsers) { //Map of account Id to User objects
            for (Id idIterator : accIdMapUsers.keySet()) {
                List<User> orgUserList = new List<User>();
                orgUserList.addAll(accIdMapUsers.get(idIterator));
                accountIdMapUserList.put(idIterator, orgUserList);
            }
        }

        //List<SObject> objectList, String taskActionName, String taskSubject, DateTime taskStartDate, DateTime taskEndDate, List<User> userList, String emailTemplateDevName
        public String massSendTaskEmail() {
            if (objectIdList.size() == 0 || taskActionName == null || taskSubject == null || taskStartDate == null || taskEndDate == null || emailTemplateDevName == null || userList == null) {
                return 'Error';
            }
            else {
                try {
                    EmailTemplate emailTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: emailTemplateDevName LIMIT 1];
                    String query = 'SELECT Id, Name FROM ' + String.valueOf(objectIdList[0].getSObjectType()) + ' WHERE Id IN ' + GNT.AppUtils.soqlList(objectIdList);
                    List<SObject> objectList = Database.query(query);
                    List<GNT.TaskCreationHandler.TaskBulkClass> tasksList = new List<GNT.TaskCreationHandler.TaskBulkClass>();
                    Map<Id, User> userIdMapUserObj = new Map<Id, User>();
                    for (SObject objectIterator : objectList) {
                        for (User userIterator : userList) {
                            GNT.TaskCreationHandler.TaskBulkClass task = new GNT.TaskCreationHandler.TaskBulkClass();
                            task.ownerUserId = userIterator.Id;
                            task.recordId = objectIterator.Id;
                            task.action = taskActionName;
                            task.recordName = String.valueOf(objectIterator.get('Name'));
                            task.startDate = taskStartDate;
                            task.dueDate = taskEndDate;
                            task.subject = taskSubject;                
                            tasksList.add(task);
                            userIdMapUserObj.put(userIterator.Id, userIterator);
                        }
                    }
                    if(tasksList.size() > 0){
                        List<Task> insertedTaskList = GNT.TaskCreationHandler.createBulkTasks(tasksList,true); 
                        Map<Id, String[]> recIdToAddressMap = new Map<Id, String[]> ();
                        for(Task taskIterator : insertedTaskList){
                            List<String> toAddress = recIdToAddressMap.get(taskIterator.WhatId); 
                            if (toAddress == null) {
                                toAddress = new List<String>();
                                recIdToAddressMap.put(taskIterator.WhatId,toAddress);
                            }
                            User u = userIdMapUserObj.get(taskIterator.OwnerId);
                            toAddress.add(u.Email);
                            //recIdToAddressMap.put(idIterator,toAddress);
                        }  
                        GNT.AppUtils.sendEmailUsingTemplate(emailTemplate.Id, recIdToAddressMap, userList[0].ContactId, false); //Need to use a dummy contact for the GNT method to run
                    }   
                    return 'Success';
                }
                catch (Exception e) {
                    return 'Error';
                }
            }   
        }
        public String massSendTaskEmailMapOrg() {
            if (objectIdList.size() == 0 || taskActionName == null || taskSubject == null || taskStartDate == null || taskEndDate == null || emailTemplateDevName == null || accountIdMapUserList.size() == 0 || userList == null) {
                return 'Error';
            }
            else {
                try {
                    EmailTemplate emailTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: emailTemplateDevName LIMIT 1];
                    String appendOrgApiName = objectTypeMapRecipientOrgApi.get(String.valueOf(objectIdList[0].getSObjectType()));
                    String query = 'SELECT Id, Name, ' + appendOrgApiName + ' FROM ' + String.valueOf(objectIdList[0].getSObjectType()) + ' WHERE Id IN ' + GNT.AppUtils.soqlList(objectIdList);
                    List<SObject> objectList = Database.query(query);
                    List<GNT.TaskCreationHandler.TaskBulkClass> tasksList = new List<GNT.TaskCreationHandler.TaskBulkClass>();
                    Map<Id, User> userIdMapUserObj = new Map<Id, User>();
                    for (SObject objectIterator : objectList) {
                        List<User> objectOrgUserList;
                        if (String.valueOf(objectIdList[0].getSObjectType()) == 'Award__c' || String.valueOf(objectIdList[0].getSObjectType()) == 'AmendmentRequest__c') {
                           objectOrgUserList = accountIdMapUserList.get(String.valueOf(objectIterator.getSobject('Grant__r').get('InternalOrganization__c')));
                        }
                        else {
                           objectOrgUserList = accountIdMapUserList.get(String.valueOf(objectIterator.get(appendOrgApiName)));
                        }
                        for (User userIterator : objectOrgUserList) {
                            GNT.TaskCreationHandler.TaskBulkClass task = new GNT.TaskCreationHandler.TaskBulkClass();
                            task.ownerUserId = userIterator.Id;
                            task.recordId = objectIterator.Id;
                            task.action = taskActionName;
                            task.recordName = String.valueOf(objectIterator.get('Name'));
                            task.startDate = taskStartDate;
                            task.dueDate = taskEndDate;
                            task.subject = taskSubject;                
                            tasksList.add(task);
                            userIdMapUserObj.put(userIterator.Id, userIterator);
                        }
                    }
                    if(tasksList.size() > 0){
                        List<Task> insertedTaskList = GNT.TaskCreationHandler.createBulkTasks(tasksList,true); 
                        Map<Id, String[]> recIdToAddressMap = new Map<Id, String[]> ();
                        for(Task taskIterator : insertedTaskList){
                            List<String> toAddress = recIdToAddressMap.get(taskIterator.WhatId); 
                            if (toAddress == null) {
                                toAddress = new List<String>();
                                recIdToAddressMap.put(taskIterator.WhatId,toAddress);
                            }
                            User u = userIdMapUserObj.get(taskIterator.OwnerId);
                            toAddress.add(u.Email);
                            //recIdToAddressMap.put(idIterator,toAddress);
                        }  
                        GNT.AppUtils.sendEmailUsingTemplate(emailTemplate.Id, recIdToAddressMap, userList[0].ContactId, false); //Need to use a dummy contact for the GNT method to run
                    }   
                    return 'Success';
                }
                catch (Exception e) {
                    return 'Error';
                }
            }   
        }
        public String massSendTaskMapOrg() {
            if (objectIdList.size() == 0 || taskActionName == null || taskSubject == null || taskStartDate == null || taskEndDate == null || accountIdMapUserList.size() == 0 || userList == null) {
                return 'Error';
            }
            else {
                try {
                    String appendOrgApiName = objectTypeMapRecipientOrgApi.get(String.valueOf(objectIdList[0].getSObjectType()));
                    String query = 'SELECT Id, Name, ' + appendOrgApiName + ' FROM ' + String.valueOf(objectIdList[0].getSObjectType()) + ' WHERE Id IN ' + GNT.AppUtils.soqlList(objectIdList);
                    List<SObject> objectList = Database.query(query);
                    List<GNT.TaskCreationHandler.TaskBulkClass> tasksList = new List<GNT.TaskCreationHandler.TaskBulkClass>();
                    Map<Id, User> userIdMapUserObj = new Map<Id, User>();
                    for (SObject objectIterator : objectList) {
                        List<User> objectOrgUserList; // = accountIdMapUserList.get(String.valueOf(objectIterator.get(appendOrgApiName)));
                        if (String.valueOf(objectIdList[0].getSObjectType()) == 'Award__c' || String.valueOf(objectIdList[0].getSObjectType()) == 'AmendmentRequest__c') {
                           objectOrgUserList = accountIdMapUserList.get(String.valueOf(objectIterator.getSobject('Grant__r').get('InternalOrganization__c')));
                        }
                        else {
                           objectOrgUserList = accountIdMapUserList.get(String.valueOf(objectIterator.get(appendOrgApiName)));
                        }
                        for (User userIterator : objectOrgUserList) {
                            GNT.TaskCreationHandler.TaskBulkClass task = new GNT.TaskCreationHandler.TaskBulkClass();
                            task.ownerUserId = userIterator.Id;
                            task.recordId = objectIterator.Id;
                            task.action = taskActionName;
                            task.recordName = String.valueOf(objectIterator.get('Name'));
                            task.startDate = taskStartDate;
                            task.dueDate = taskEndDate;
                            task.subject = taskSubject;                
                            tasksList.add(task);
                            userIdMapUserObj.put(userIterator.Id, userIterator);
                        }
                    }
                    if(tasksList.size() > 0){
                        List<Task> insertedTaskList = GNT.TaskCreationHandler.createBulkTasks(tasksList,true); 
                    }   
                    return 'Success';
                }
                catch (Exception e) {
                    return 'Error';
                }
            }   
        }
        public String massSendEmail() {
            Map<Id, Map<Id,User>> objectIDMapLEAUserMap = new Map<Id, Map<Id,User>>();
            if (objectIdList.size() == 0 || emailTemplateDevName == null || userList == null || accountIdMapUserList.size() == 0) {
                return 'Error';
            }
            else {
                try {
                    EmailTemplate emailTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: emailTemplateDevName LIMIT 1];
                    String query = 'SELECT Id, Name FROM ' + String.valueOf(objectIdList[0].getSObjectType()) + ' WHERE Id IN ' + GNT.AppUtils.soqlList(objectIdList);
                    List<SObject> objectList = Database.query(query);
                    List<GNT.TaskCreationHandler.TaskBulkClass> tasksList = new List<GNT.TaskCreationHandler.TaskBulkClass>();
                    Map<Id, User> userIdMapUserObj = new Map<Id, User>();
                    for (SObject objectIterator : objectList) {
                        for (User userIterator : userList) {
                            userIdMapUserObj.put(userIterator.Id, userIterator);
                        }
                        objectIDMapLEAUserMap.put(objectIterator.Id, userIdMapUserObj);
                    }
                    Map<Id, String[]> recIdToAddressMap = new Map<Id, String[]> ();
                    for(Id idIterator : objectIDMapLEAUserMap.keySet()){
                        List<String> toAddress = recIdToAddressMap.get(idIterator); 
                        if (toAddress == null) {
                            toAddress = new List<String>();
                            recIdToAddressMap.put(idIterator,toAddress);
                        }
                        Map<Id, User> userIdMapUsers = objectIDMapLEAUserMap.get(idIterator);
                        for (Id userId : userIdMapUsers.keySet()) {
                            User u = userIdMapUsers.get(userId);
                            toAddress.add(u.Email);
                            //recIdToAddressMap.put(idIterator,toAddress);
                        }
                    }
                    System.debug(emailTemplate.Id);
                    System.debug(recIdToAddressMap);
                    System.debug(userList[0].ContactId);
                    GNT.AppUtils.sendEmailUsingTemplate(emailTemplate.Id, recIdToAddressMap, userList[0].ContactId, false); //Need to use a dummy contact for the GNT method to run
                    return 'Success';
                }
                catch (Exception e) {
                    return 'Error';
                }
            }   
        }
        public String massSendEmailMapOrg() {
            if (objectIdList.size() == 0 || emailTemplateDevName == null || accountIdMapUserList.size() == 0 || userList == null) {
                return 'Error';
            }
            else {
                try {
                    EmailTemplate emailTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: emailTemplateDevName LIMIT 1];
                    String appendOrgApiName = objectTypeMapRecipientOrgApi.get(String.valueOf(objectIdList[0].getSObjectType()));
                    String query = 'SELECT Id, Name, ' + appendOrgApiName + ' FROM ' + String.valueOf(objectIdList[0].getSObjectType()) + ' WHERE Id IN ' + GNT.AppUtils.soqlList(objectIdList);
                    List<SObject> objectList = Database.query(query);
                    Map<Id, List<User>> objectIDMapLEAUserMap = new Map<Id, List<User>>();
                    for (SObject objectIterator : objectList) {
                        List<User> objectOrgUserList;
                        if (String.valueOf(objectIdList[0].getSObjectType()) == 'Award__c' || String.valueOf(objectIdList[0].getSObjectType()) == 'AmendmentRequest__c') {
                           objectOrgUserList = accountIdMapUserList.get(String.valueOf(objectIterator.getSobject('Grant__r').get('InternalOrganization__c')));
                        }
                        else {
                           objectOrgUserList = accountIdMapUserList.get(String.valueOf(objectIterator.get(appendOrgApiName)));
                        }
                        objectIDMapLEAUserMap.put(objectIterator.Id, objectOrgUserList);
                    }
                    Map<Id, String[]> recIdToAddressMap = new Map<Id, String[]> ();
                    for(Id idIterator : objectIDMapLEAUserMap.keySet()){ //Iterate through all the objects
                        List<String> toAddress = recIdToAddressMap.get(idIterator); 
                        if (toAddress == null) {
                            toAddress = new List<String>();
                            recIdToAddressMap.put(idIterator,toAddress);
                        }
                        List<User> userIdMapUsers = objectIDMapLEAUserMap.get(idIterator);
                        for (User u : userIdMapUsers) {
                            toAddress.add(u.Email); 
                        }
                    }
                    GNT.AppUtils.sendEmailUsingTemplate(emailTemplate.Id, recIdToAddressMap, userList[0].ContactId, false); //Need to use a dummy contact for the GNT method to run
                    return 'Success';
                    }
                catch (Exception e) {
                    return 'Error';
                }
            }   
        }
    }
}