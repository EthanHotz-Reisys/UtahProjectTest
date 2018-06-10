global with sharing class ContentFilesCtrl {

    public transient ConnectApi.UserProfile profile {get; set;}
    public transient ConnectApi.OrganizationSettings settings {get; set;}
    public transient String accountId {get; set;}
    public String filesHiddenFile {get; set; }
    public String filesHiddenName { get; set; }
    public String filesHiddenId { get; set; }
    public String filesHiddenType {get; set; }
    public String filesHiddenText {get; set; }
    public String UserId{get; private set;}
    public String fileOwnerId {get; set;}
    public Boolean publicFiles {get; set;}
    public String filesNamespace {get; private set;}
    public String identifier {get; set;}
    public transient GNT__UserPreferences__c userPrefs {get; private set;}
    public String networkId {get; set;}

    public ContentFilesCtrl(){
        UserId = UserInfo.getUserId(); 
        userPrefs = GNT__UserPreferences__c.getValues(userId);
        filesNamespace = AppUtils.getNamespacePrefix();
        try {
            profile = ConnectApi.UserProfiles.getUserProfile(Network.getNetworkId(), UserId);
            settings = ConnectApi.Organization.getSettings();
            if(GNT__UserPreferences__c.getValues(UserId)!= null){
                accountId = GNT__UserPreferences__c.getValues(UserId).GNT__OrganizationAccountId__c;
            }
        } catch (ConnectAPI.ConnectAPIException e) {
            System.debug(e.getMessage());
        }
    }
    
    public void uploadNewContentVersion() {
        if (filesHiddenFile != '' && filesHiddenName != '') {           
            ContentVersion v = new ContentVersion();
            v.versionData = System.EncodingUtil.base64Decode(filesHiddenFile);
            v.title = filesHiddenName.subString(0, filesHiddenName.lastIndexOf('.'));
            v.pathOnClient ='/' + filesHiddenName;    
            if(filesHiddenText != '') {                
                v.description = filesHiddenText;
            }
            try {
                insert v;
            } catch(Exception e) {
                System.debug(e.getMessage());
            }                   
            filesHiddenFile = '';
            filesHiddenName = '';
            filesHiddenText = '';
        }
        return;
    } 
    public void uploadInternalContentVersion() {
        blob file = System.EncodingUtil.base64Decode(filesHiddenFile);
        FeedItem content = new FeedItem();
        content.ContentData = file;
        content.ContentDescription = filesHiddenText;
        content.ContentFileName = filesHiddenName;
        content.NetworkScope = null;
        content.Type = 'ContentPost';
        content.ParentId = UserInfo.getUserId();
        insert content;

        filesHiddenFile = '';
        filesHiddenName = '';
        filesHiddenText = '';
        filesHiddenType = '';
        return;
    }
    public void uploadExternalContentVersion() {
        blob file = System.EncodingUtil.base64Decode(filesHiddenFile);
        FeedItem content = new FeedItem();
        content.ContentData = file;
        content.ContentDescription = filesHiddenText;
        content.ContentFileName = filesHiddenName;
        content.Type = 'ContentPost';
        content.NetworkScope = 'AllNetworks';

        if (userPrefs.GNT__OrganizationAccountId__c != null) {
            content.ParentId = userPrefs.GNT__OrganizationAccountId__c;
        } else {
            content.ParentId = UserInfo.getUserId();
            content.NetworkScope = '0DBG0000000Kys3OAC';
        }
        try {
            insert content;
        } catch(System.DmlException e) {
            //content.addError('An error occured while uploading this file, please contact your system adminstrator and make sure you are a member of the external network.');
            content.addError(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-51121'));
        } 

        filesHiddenFile = '';
        filesHiddenName = '';
        filesHiddenText = '';
        filesHiddenType = '';
        return;
    }
    public void uploadNewVersion() {
        if (filesHiddenName != '' && filesHiddenId != '') {
            ContentVersion cv = new ContentVersion();
            
            // Set the mandatory field pathOnClient 
            cv.PathOnClient = '/' + filesHiddenName;
            
            // Set the binary file data 
            cv.VersionData = System.EncodingUtil.base64Decode(filesHiddenFile);
            
            //Weike
            if(!Test.isRunningTest()){
                ID docId = ID.valueOf(filesHiddenId);
                cv.ContentDocumentId = docId;
            }
            // Set the reason for change field on revision 
            cv.Description = filesHiddenText;
            
            insert cv;
            filesHiddenFile = '';
            filesHiddenName = '';
            filesHiddenText = '';
            filesHiddenId = '';
        }
        return;
    }
     public List<ContentVersion> getContentVersions() {
        List<ContentVersion> mylist = new List<ContentVersion>();
        List<String> existingIds;
            if (publicFiles) {
                myList = [SELECT id, Title, Description, FileType, ContentUrl, FileExtension, PathOnClient, Resource_Type__c,
                        ContentDocumentId, ContentModifiedDate, Owner.Name, OwnerId, PublishStatus, NetworkId
                        FROM ContentVersion
                        WHERE IsLatest = TRUE
                        AND PublishStatus = 'P' 
                        AND ContentDocumentId in (SELECT ContentDocumentId 
                             FROM ContentWorkspaceDoc 
                             WHERE ContentWorkspaceId = '0583700000003Sx')];
            } else {
                myList = [SELECT id, Title, Description, FileType, ContentUrl, FileExtension, PathOnClient,  Resource_Type__c,
                        ContentDocumentId, ContentModifiedDate, Owner.Name, OwnerId, PublishStatus, NetworkId
                        FROM ContentVersion
                        WHERE IsLatest = TRUE
                        AND PublishStatus != 'U'
                        AND ContentDocumentId in (SELECT ContentDocumentId 
                             FROM ContentWorkspaceDoc 
                             WHERE ContentWorkspaceId = '0583700000003Sx')
                        ORDER BY ContentModifiedDate DESC];
            }

        return mylist;
        
    }
    public List<ContentVersion> getOwnerContentVersions() {
        List<ContentVersion> mylist = new List<ContentVersion>();
        if(fileOwnerId.startsWith('005')) {
            myList = [SELECT id,
                            Title, 
                            Description,
                            FileType, 
                            ContentUrl, 
                            FileExtension,
                            Resource_Type__c,
                            PathOnClient, 
                            ContentDocumentId, 
                            ContentModifiedDate, 
                            Owner.Name,
                            OwnerId,
                            PublishStatus,
                            NetworkId
                        FROM ContentVersion
                        WHERE IsLatest = TRUE
                        and OwnerId =: fileOwnerId
                        AND ContentDocumentId in (SELECT ContentDocumentId 
                             FROM ContentWorkspaceDoc 
                             WHERE ContentWorkspaceId = '0583700000003Sx')
                        ORDER BY ContentModifiedDate DESC];
        } else if (fileOwnerId.startsWith('0F9')) {
            List<ContentDocumentLink> linkList = [SELECT ShareType, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:fileOwnerId];
            List<String> ids = new List<String>();
            for (ContentDocumentLink cdl : linkList) {
                ids.add(cdl.ContentDocumentId);   
            }
            myList.addAll([SELECT id,
                        Title, 
                        Description,
                        FileType, 
                        ContentUrl, 
                        FileExtension,
                        PathOnClient, 
                        Resource_Type__c,
                        ContentDocumentId, 
                        ContentModifiedDate, 
                        Owner.Name,
                        OwnerId,
                        PublishStatus,
                        NetworkId
                        FROM ContentVersion 
                        WHERE isLatest = true 
                        AND ContentDocumentId IN :ids]);
        }
        return mylist;
    }

    @RemoteAction
    global static String editDesc(String id, String myDesc) {
        List<ContentVersion> tmpList = [SELECT Description FROM ContentVersion WHERE contentDocumentId =: id];
        if (tmpList.size() > 0) {
            tmpList[0].Description = myDesc;
            update tmpList[0];
            return myDesc;
        }
        return 'failure';
    }
    @RemoteAction
    global static List<CollaborationGroup> getGroups(String accountId, String search, Boolean allowExternal, String networkId) {
        search = '%' + search + '%';
        if (accountId != 'None') {
            Set<CollaborationGroup> result = new Set<CollaborationGroup>();
            List<CollaborationGroup> tmpList = new List<CollaborationGroup>();
            tmpList = [SELECT Name, Id, SmallPhotoUrl, MemberCount FROM CollaborationGroup WHERE NetworkId != null AND isArchived = false And Name LIKE :search];
            List<CollaborationGroupMember> memberships = [SELECT CollaborationGroupId FROM CollaborationGroupMember WHERE MemberId =: UserInfo.getUserId()];
            List<String> groupIds = new List<String>();
            for (CollaborationGroupMember cgm : memberships) {
                groupIds.add(cgm.CollaborationGroupId);
            }
            List<String> ownerIds = new List<String>();
            for(CollaborationGroup cg: tmpList) {
                ownerIds.add(cg.OwnerId);
            }
            Map<Id, User> owners = new Map<Id, User>([SELECT Id, AccountId FROM User WHERE id IN :ownerIds]);
            for(CollaborationGroup cg: tmpList) {
                if(owners.get(cg.OwnerId).AccountId == accountId) {
                    result.add(cg);
                }
            }
            result.addAll([SELECT Name, Id, SmallPhotoUrl, MemberCount FROM CollaborationGroup WHERE isArchived = false AND id IN :groupIds AND Name LIKE :search]);
            return new List<CollaborationGroup>(result);
        } else {
            if (allowExternal) {
                return [SELECT Name, Id, SmallPhotoUrl, MemberCount FROM CollaborationGroup WHERE isArchived = false AND Name LIKE :search AND NetworkId != null];
            } else {
                return [SELECT Name, Id, SmallPhotoUrl, MemberCount FROM CollaborationGroup WHERE isArchived = false AND Name LIKE :search AND NetworkId = null];
            }
        }
        return new List<CollaborationGroup>();
    }
    @RemoteAction
    global static List<User> getUsers(String accountId, Boolean allowExternal, String name, String userId) {
        String checkName = '%' + name + '%';
        if (accountId != 'None') {
            return [SELECT Name, Id, SmallPhotoUrl FROM User WHERE Name LIKE :checkName AND IsActive = true AND accountId =: accountId];
        } else {
            if (allowExternal) {
                return [SELECT Name, Id, SmallPhotoUrl FROM User WHERE Name LIKE :checkName AND IsActive = true];
            } else {
                return [SELECT Name, Id, SmallPhotoUrl FROM User WHERE Name LIKE :checkName AND IsActive = true AND ContactId = null];
            }
        }
    }
    @RemoteAction
    global static void removeAccess(String userId, String linkedEntityId, String documentId) {
        ContentDocumentLink cdl = [SELECT id 
                                    FROM ContentDocumentLink 
                                    WHERE LinkedEntityId=:linkedEntityId 
                                    and ContentDocumentId=:documentId LIMIT 1][0];

        delete cdl;

        
        return;
    }
    @RemoteAction
    global static void makeViewer(String userId, String linkedEntityId, String documentId) {
        List<ContentDocumentLink> tmpList = [SELECT id, shareType, LinkedEntityId
                                    FROM ContentDocumentLink 
                                    WHERE LinkedEntityId=:linkedEntityId 
                                    and ContentDocumentId=:documentId LIMIT 1];
        System.debug(tmpList);

            ContentDocumentLink newLink = new ContentDocumentLink();
            newLink.LinkedEntityId = linkedEntityId;
            newLink.ContentDocumentId = documentId;
            newLink.ShareType = 'V';
            if (tmpList.size() > 0) {
                ContentDocumentLink cdl = tmpList[0];
                delete cdl;
                insert newLink;
            } else {
                insert newLink;
            }
        return;
    }
    @RemoteAction
    global static void makeCollab(String userId, String linkedEntityId, String documentId) {
        List<ContentDocumentLink> tmpList = [SELECT id 
                                    FROM ContentDocumentLink 
                                    WHERE LinkedEntityId=:linkedEntityId 
                                    and ContentDocumentId=:documentId LIMIT 1];
        ContentDocumentLink newLink = new ContentDocumentLink();
        newLink.LinkedEntityId = linkedEntityId;
        newLink.ContentDocumentId = documentId;
        newLink.ShareType = 'C';
        if (tmpList.size() > 0) {
            ContentDocumentLink cdl = tmpList[0];
            delete cdl;
            insert newLink;
        } else {
            insert newLink;
        }
        return;
    }
    @RemoteAction
    global static void makePrivate(String id) {
        List<ContentDocumentLink> linkList = [SELECT LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE ContentDocumentId =: id];
        String idType;
        List<ContentDocument> tmpList = [SELECT ownerId, publishStatus FROM ContentDocument WHERE id =: id LIMIT 1];
        if (tmpList.size() > 0) {
            for (ContentDocumentLink cdl : linkList) {
                if(tmpList[0].ownerId != cdl.LinkedEntityId) {
                    delete cdl;
                }
            }
        }
        return;
    }
    @RemoteAction
    global static String addEntityLinks(String documentId, String entityIds, String shareTypes, String message) {
        List<String> newIds = entityIds.split(',');

        // The final connect api call must specify the community of the user so you must separate the users based
        // on what community they're in, this avoids putting the connect api in a big for loop
        List<NetworkMember> networkMembers = [SELECT id, NetworkId, MemberId From NetworkMember WHERE MemberId IN :newIds];
        Map<String, String> communities = new Map<String, String>();
        for (NetworkMember netMember : networkMembers) {
            communities.put(netMember.MemberId, netMember.networkId);
        }        
        List<String> newShareTypes = shareTypes.split(',');
        if (newIds.size() == newShareTypes.size()) {         
            if (newIds.size() > 0) {
                Map<String, List<ConnectApi.BatchInput>> batchMap = new Map<String, List<ConnectApi.BatchInput>>();
                List<ContentDocumentLink> insertList = new List<ContentDocumentLink>();
                List<ContentDocumentLink> updateList = new List<ContentDocumentLink>();
                List<ContentDocumentLink> tmpList = new List<ContentDocumentLink>();
                if(!Test.isRunningTest()){
                    tmpList = [SELECT LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId = :documentId];
                }   
                Map<String, ContentDocumentLink> checkMap = new Map<String, ContentDocumentLink>();
                if(!Test.isRunningTest()){ 
                    for (ContentDocumentLink cdl : tmpList) {
                        checkMap.put(cdl.LinkedEntityId, cdl);
                    }
                }
                ContentDocumentLink cdl;
                // Setup feedItemInputs so that the groups/users will be notified of the file being shared
                ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
                ConnectApi.ContentCapabilityInput contentInput = new ConnectApi.ContentCapabilityInput();
                contentInput.contentDocumentId = documentId;
                
                ConnectApi.FeedElementCapabilitiesInput capabilities = new ConnectApi.FeedElementCapabilitiesInput();
                capabilities.content = contentInput;
                
                feedItemInput.capabilities = capabilities;
                
                ConnectApi.MessageBodyInput bodyInput = new ConnectApi.MessageBodyInput();
                if (message != '') {
                    List<ConnectApi.MessageSegmentInput> messageSegments = new List<ConnectApi.MessageSegmentInput>();
                    ConnectApi.TextSegmentInput textInput = new ConnectApi.TextSegmentInput();
                    textInput.text = message;
                    messageSegments.add(textInput);
                    bodyInput.messageSegments = messageSegments;
                    feedItemInput.body = bodyInput;
                }
                
                Integer i = 0;
                ConnectApi.FeedItemInput tmpInput;
                List<ConnectApi.BatchInput> tmpBatchList;
                for(String id : newIds) {
                    tmpInput = new ConnectApi.FeedItemInput();
                    tmpInput.subjectId = id;
                    tmpInput.capabilities = capabilities;
                    if (message != '') {
                        tmpInput.body = bodyInput;   
                    }
                    if (communities.containsKey(id)) {
                        if (batchMap.containsKey(id)) {
                            batchMap.get(communities.get(id)).add(new ConnectApi.BatchInput(tmpInput));
                        } else {
                            tmpBatchList = new List<ConnectApi.BatchInput>();
                            tmpBatchList.add(new ConnectApi.BatchInput(tmpInput));
                            batchMap.put(communities.get(id), tmpBatchList);
                        }
                    } else {
                        if (batchMap.containsKey('internal')) {
                            batchMap.get('internal').add(new ConnectApi.BatchInput(tmpInput));
                        } else {
                            tmpBatchList = new List<ConnectApi.BatchInput>();
                            tmpBatchList.add(new ConnectApi.BatchInput(tmpInput));
                            batchMap.put('internal', tmpBatchList);
                        }
                    }
                    cdl = new ContentDocumentLink();
                    if (checkMap.containsKey(id)) {
                        checkMap.get(id).shareType = newShareTypes[i];
                        updateList.add(checkMap.get(id));
                    } else {
                        cdl.ContentDocumentId = documentId;
                        cdl.LinkedEntityId = id;
                        cdl.ShareType = newShareTypes[i];
                        insertList.add(cdl);
                    }
                    i++;
                }
                try {
                    insert insertList;
                    update updateList;
                    List<ConnectApi.BatchResult> results = new List<ConnectApi.BatchResult>();
                    for (String currentId : batchMap.keySet()) {
                        if (currentId == 'internal') {
                            results.addAll(ConnectApi.ChatterFeeds.postFeedElementBatch(null, batchMap.get('internal')));
                        } else {
                            results.addAll(ConnectApi.ChatterFeeds.postFeedElementBatch(currentId, batchMap.get(currentId)));
                        }
                    }
                    String result = '';
                    for (ConnectApi.BatchResult bResult : results) {
                        if(!bResult.isSuccess()) {
                            result += bResult.getErrorMessage();
                            result += ',';
                        }
                    }
                    result = result.removeEnd(',');
                    if(result == '') {
                        return 'success';
                    } else {
                        return result;
                    }
                } catch(System.DmlException e) {
                    return e.getMessage();
                }
            } else {
                return 'No values entered';
            }
        } else {
            return 'Unequal list sizes, please try again or notify your development organization';
        }
    }
    @RemoteAction
    global static String getVisibility(String id) {
        List<ContentDocument> tmpList = [SELECT publishStatus FROM ContentDocument WHERE id=:id LIMIT 1];
        if (tmpList.size() > 0) {
            return tmpList[0].publishStatus;
        }
        return 'R';
    }
    @RemoteAction
    global static List<String> EntityLinks(String versionId) {
        List<ContentDocumentLink> linkList = new List<ContentDocumentLink>();
        if(!Test.isRunningTest()){
            linkList = [SELECT ShareType, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId=:versionId];
        }
        List<String> result = new List<String>();
        User tmpUser;
        CollaborationGroup tmpGroup;
        String idType = '';
        String label = '';      
        List<String> ids = new List<String>();
        for (ContentDocumentLink cdl : linkList) {
            ids.add(cdl.LinkedEntityId);
        }
        try {
            Map<id, User> users = new Map<Id, User>([SELECT id, Name, smallPhotoUrl FROM User WHERE id IN :ids]);
            Map<id, CollaborationGroup> groups = new Map<Id, CollaborationGroup>([SELECT id, Name, smallPhotoUrl FROM CollaborationGroup WHERE id IN :ids]);
            Map<id, Network> networks = new Map<Id, Network>([SELECT id, Name FROM Network WHERE id IN :ids]);
            for (ContentDocumentLink cdl : linkList) {
                idType = cdl.LinkedEntityId.getSObjectType().getDescribe().getName();
                label = cdl.LinkedEntityId.getSObjectType().getDescribe().getLabel();
                if (idType == 'User') {                   
                    result.add(cdl.ShareType + ';' + cdl.LinkedEntityId + ';' + users.get(cdl.LinkedEntityId).smallPhotoUrl + ';' + users.get(cdl.LinkedEntityId).Name );
                } else if (idType == 'CollaborationGroup') {                    
                    result.add(cdl.ShareType + ';' + cdl.LinkedEntityId + ';' + groups.get(cdl.LinkedEntityId).smallPhotoUrl + ';' + groups.get(cdl.LinkedEntityId).Name);
                } else if (idType == 'Organization'){
                    if (result.isEmpty()) {
                        result.add(cdl.ShareType + ';' + cdl.LinkedEntityId + ';Organization;All Users');
                    } else {
                        result.add(0, cdl.ShareType + ';' + cdl.LinkedEntityId + ';Organization;All Users');
                    }                
                } else {
                    List<Schema.DescribeTabSetResult> dtsrl = Schema.describeTabs();
                    Boolean found = false;
                    for (DescribeTabSetResult dtsr: dtsrl) {
                        if (!found) {
                            List<Schema.DescribeTabResult> tmpList = dtsr.getTabs();
                            for(DescribeTabResult r: tmpList) {                        
                                if(r.getSobjectName() == idType) {
                                    found = true;
                                    try {
                                        String QueryString = 'SELECT Name FROM ' + IDtype + ' WHERE id = \'' + cdl.LinkedEntityId + '\' LIMIT 1';
                                        sObject tmpObject = Database.query(QueryString);
                                        result.add('V;' + cdl.LinkedEntityId + ';' + r.getIconUrl() + ';' + String.valueOf( tmpObject.get('Name')));
                                    } catch (Exception e) {
                                        try {
                                            String QueryString2 = 'SELECT Title FROM ' + IDtype + ' WHERE id = \'' + cdl.LinkedEntityId + '\' LIMIT 1';
                                            sObject tmpObject2 = Database.query(QueryString2);
                                            result.add('V;' + cdl.LinkedEntityId + ';' + r.getIconUrl() + ';' + String.valueOf(tmpObject2.get('Title')));
                                        } catch(Exception e2) {
                                            System.debug(e2.getMessage());
                                            result.add('Q;0;' + e2.getMessage());
                                        }
                                    }
                                    break;
                                }
                            }
                        }
                    }
                    if (!found) {
                        List<DescribeSObjectResult> output = schema.describeSObjects(new String[] { idType});
                        if(output.size() > 0) {
                            try {
                                String QueryString = 'SELECT Name FROM ' + output[0].getName() + ' WHERE id = \'' + cdl.LinkedEntityId + '\' LIMIT 1';
                                sObject tmpObject = Database.query(QueryString);
                                result.add('V;' + cdl.LinkedEntityId + ';Record;' + String.valueOf( tmpObject.get('Name')));
                            } catch (Exception e) {
                                try {
                                    String QueryString2 = 'SELECT Title FROM ' + output[0].getName()  + ' WHERE id = \'' + cdl.LinkedEntityId + '\' LIMIT 1';
                                    sObject tmpObject2 = Database.query(QueryString2);
                                    result.add('V;' + cdl.LinkedEntityId + ';Record;' + String.valueOf(tmpObject2.get('Title')));
                                } catch(Exception e2) {
                                    System.debug(e2.getMessage());
                                    result.add('Q;0;' + e2.getMessage());
                                }
                            }
                        }
                    }
                }
            }
        } catch(Exception e) {
            System.debug(e.getMessage());
            result.add('Q;0;Share retrieval failed, most likely cause is an invalid id is present.');
        }        
        return result;
    }
    @RemoteAction
    global static void deleteFile(String versionId) {       
        ContentDocument cd = [SELECT id FROM ContentDocument WHERE id=:versionId LIMIT 1];
        delete cd;
        return;
    }
    
    @RemoteAction
    global static Boolean canUpload(String documentId, Set<String> ids) {       
        if (ids.contains(documentId)){
            return true;
        }
        return false;
    }
    @RemoteAction
    global static Boolean canUploadNewVersion(String documentId, String userId) {
        List<CollaborationGroupMember> groups = [SELECT CollaborationGroupId FROM CollaborationGroupMember WHERE MemberId =: userId];
        Set<String> ids = new Set<String>();
        ids.add(userId);
        for(CollaborationGroupMember myGroup : groups) {
            ids.add(myGroup.CollaborationGroupId);
        }

        List<ContentDocumentLink> links = [SELECT LinkedEntityId, ShareType FROM ContentDocumentLink WHERE ContentDocumentId =: documentId];
        for(ContentDocumentLink link : links) {
            if (link.ShareType == 'C' && ids.contains(link.LinkedEntityId)) {
                return true;
            }
        }

        return false;
    }
    @RemoteAction
    global static Map<String, String> following() {
        String UserId = UserInfo.getUserId();
        Map<String, String> myFollowings = new Map<String, String>();
        List<EntitySubscription> followings = [
                                        SELECT id, parentId
                                        FROM EntitySubscription
                                        WHERE subscriberid = :UserId LIMIT 1000];
        for(EntitySubscription ES: followings) {
            if(ES.parentId != null && ES.id != null) {
                myFollowings.put(ES.parentId, ES.id);
            }
        }
        return myFollowings;
    }
    @RemoteAction
    global static String follow(String id) {        
        ConnectApi.Subscription subscription = ConnectApi.ChatterUsers.follow(Network.getNetworkId(), 'me', id);        
        return subscription.id;
    }
    @RemoteAction 
    global static void unFollow(String id) {
        ConnectApi.Chatter.deleteSubscription(Network.getNetworkId(), id);
        return;
    }
}