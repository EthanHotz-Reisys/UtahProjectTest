global with sharing class CollabSideBarExternalCtrl {
    
    public  String profileNamespace {get; private set;}
    public  ConnectApi.UserProfile profile {get; private set;}
    public ConnectApi.UserSettings settings {get;private set;}
    public  String userId {get; private set;}
    public  boolean IsInternal {get; private set;}
    public String userContactId {get;set;}
    public User externalUser {get;set;}
    public ConnectApi.UserProfile subjectProfile {get;set;}
    public String communityId {get; private set;}
    
    global CollabSideBarExternalCtrl() {
        profileNamespace = AppUtils.getNameSpacePrefix();
        settings = ConnectApi.Organization.getSettings().userSettings;
        userId = UserInfo.getUserId();
        IsInternal = GNT__UserPreferences__c.getValues(UserInfo.getUserId()).GNT__IsInternal__c;     
        profile = ConnectApi.UserProfiles.getUserProfile(Network.getNetworkId(), UserInfo.getUserId());
        userInfo();                                    
    }
    public void userInfo() {
        externalUser = [SELECT aboutMe, badgeText, ContactId, fullPhotoUrl ,MobilePhone, Fax, Extension, phone, id,  firstName, lastName, 
                            name, CommunityNickname, email, title, city, state, postalCode, country, street, manager.name, manager.smallPhotoUrl, 
                            manager.id, UserRoleId, UserPreferencesShowCountryToExternalUsers, UserPreferencesShowPostalCodeToExternalUsers,
                            UserPreferencesShowStateToExternalUsers, UserPreferencesShowCityToExternalUsers,
                            UserPreferencesShowStreetAddressToExternalUsers, UserPreferencesShowMobilePhoneToExternalUsers,
                            UserPreferencesShowFaxToExternalUsers, UserPreferencesShowWorkPhoneToExternalUsers,
                            UserPreferencesShowEmailToExternalUsers, UserPreferencesShowTitleToExternalUsers,
                            UserPreferencesShowManagerToExternalUsers FROM User WHERE id =: userId LIMIT 1]; 
        System.debug('externalUser--->>>'+externalUser);                            
        if(externalUser != Null) {
            List<NetworkMember> tmpMembers = [SELECT id, NetworkId FROM NetworkMember WHERE MemberId =: externalUser.id LIMIT 1];
            System.debug('tmpMembers--->>>'+tmpMembers);
            if(!tmpMembers.isEmpty()) {
                communityId = tmpMembers[0].NetworkId;
            }
        }
        subjectProfile = ConnectApi.UserProfiles.getUserProfile(communityId, externalUser.id);
        System.debug('CollabSideBarExternalCtrl subjectProfile--->>>'+subjectProfile);
    }
    @RemoteAction
    global static String uploadUserPhoto(String profileHiddenFile,string profileHiddenType,string profileHiddenName, Boolean isLast, Boolean isFirst){
        Document document = new Document();
        if(isFirst) {
            document.AuthorId = UserInfo.getUserId();
            document.FolderId = UserInfo.getUserId(); // put it in running user's folder
            delete [select Body from Document where Name=:(UserInfo.getUserId() + 'ProfilePhoto') and AuthorId = :UserInfo.getUserId() and FolderId=:UserInfo.getUserId()];
            if(isLast) {
                document.Body = System.EncodingUtil.base64Decode(profileHiddenFile.substringAfter(','));
            } else {
                document.Body = Blob.valueof( profileHiddenFile.substringAfter(',') );
            }
            document.Name = UserInfo.getUserId() + 'ProfilePhoto';
            insert document;
        } else {
            document = [select Body from Document where Name=:(UserInfo.getUserId() + 'ProfilePhoto') and AuthorId = :UserInfo.getUserId() and FolderId=:UserInfo.getUserId() limit 1];
            String blobStr = document.body.toString() + profileHiddenFile;
            if(isLast) {
                document.body = EncodingUtil.base64Decode(blobStr);
            } else {
                document.body = Blob.valueof(blobStr);
            }
            update document;
        }
        
        if(isLast) {
            ConnectApi.BinaryInput feedBinary = new ConnectApi.BinaryInput(document.Body, profileHiddenType, profileHiddenName);
            GNT__UserPreferences__c userPref = GNT__UserPreferences__c.getValues(UserInfo.getUserId());
            if(!Test.isRunningTest()){
                ConnectApi.Photo photo = ConnectApi.ChatterUsers.setPhoto(Network.getNetworkId(), UserInfo.getUserId(), feedBinary);
                userPref.GNT__SmallPhotoURL__c = photo.smallPhotoUrl;
            }         
            update userPref;
            delete [select Body from Document where Name=:(UserInfo.getUserId() + 'ProfilePhoto') and AuthorId = :UserInfo.getUserId() and FolderId=:UserInfo.getUserId()];
        }
        profileHiddenFile = '';
        profileHiddenType = '';
        profileHiddenName = '';
        return null;
    }
    @RemoteAction
    global static void deleteUserPhoto(String id) {
        ConnectApi.ChatterUsers.deletePhoto(Network.getNetworkId(), id);
        GNT__UserPreferences__c userPref = GNT__UserPreferences__c.getValues(UserInfo.getUserId());
        userPref.GNT__SmallPhotoURL__c = 'https://c.na11.content.force.com/profilephoto/005/T';
        try {
            update userPref;
        } catch (System.DmlException e) {
            //Do something with exception
        }
        return;
    }
}