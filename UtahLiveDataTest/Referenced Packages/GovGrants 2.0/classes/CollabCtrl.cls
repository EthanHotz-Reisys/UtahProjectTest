/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class CollabCtrl {
    global String themeDocURL {
        get;
        set;
    }
    global CollabCtrl() {

    }
    @RemoteAction
    global static List<String> EntityLinks(String versionId) {
        return null;
    }
    @RemoteAction
    global static void addBookmark(String community, String feedElementID) {

    }
    @RemoteAction
    global static Boolean canUpload(String documentId, String userId) {
        return null;
    }
    @RemoteAction
    global static CollaborationGroup createGroup(Boolean isExternal, String community, Boolean canHaveChatterGuests, String name, String description, Boolean isAutoArchiveDisabled, String visibility) {
        return null;
    }
    @RemoteAction
    global static void deleteComment(String community, String commentID) {

    }
    @RemoteAction
    global static void deleteFeedElement(String community, String feedElementID) {

    }
    @RemoteAction
    global static void deleteGroupMember(String community, String id, String groupId) {

    }
    @RemoteAction
    global static String follow(String community, String id) {
        return null;
    }
    @RemoteAction
    global static Map<String,String> following() {
        return null;
    }
    @RemoteAction
    global static List<GNT.ElementCommentInfo> getAllComments(String community, String id) {
        return null;
    }
    @RemoteAction
    global static Map<String,Integer> getCollabCount(Boolean communityChk, String accountId) {
        return null;
    }
    @RemoteAction
    global static List<User> getColleagues(Boolean inCommunity, String accountId, String search, Boolean searching) {
        return null;
    }
    @RemoteAction
    global static GNT.ElementCommentInfo getCommentInfo(String community, String id) {
        return null;
    }
    @RemoteAction
    global static ConnectApi.ChatterLikePage getCommentLikes(String community, String id, Integer token) {
        return null;
    }
    @RemoteAction
    global static List<User> getCommunityUsers(Boolean searching, String text) {
        return null;
    }
    @RemoteAction
    global static GNT.FeedElementInfo getElementInfo(String community, String id) {
        return null;
    }
    @RemoteAction
    global static ConnectApi.ChatterLikePage getElementLikes(String community, String id, Integer token) {
        return null;
    }
    @RemoteAction
    global static String getFullPhotoUrl(String newId) {
        return null;
    }
    @RemoteAction
    global static List<List<String>> getGroupsList() {
        return null;
    }
    @RemoteAction
    global static List<CollaborationGroup> getGroups(Boolean inCommunity, String accountId, String search, Boolean searching) {
        return null;
    }
    @RemoteAction
    global static List<GNT.FeedElementInfo> getNewsFeedNextPage(String community, String referenceId, String pageToken, Integer remotePageSize, String sortOrderString, String remoteSearchCriteria, Boolean remoteSearching, String news) {
        return null;
    }
    @RemoteAction
    global static List<GNT.CollabCtrl.customGroup> getNextGroupPage(Integer pageToken, String remoteSearchCriteria, Boolean remoteSearching) {
        return null;
    }
    @RemoteAction
    global static List<GNT.CollabCtrl.customUser> getNextUserPage(Integer pageToken, String remoteSearchCriteria, Boolean remoteSearching) {
        return null;
    }
    @RemoteAction
    global static List<List<String>> getOrganizationGroupsList() {
        return null;
    }
    @RemoteAction
    global static void joinGroup(String userId, String newId) {

    }
    @RemoteAction
    global static ConnectApi.ChatterLike likeComment(String communityId, String commentId) {
        return null;
    }
    @RemoteAction
    global static ConnectApi.ChatterLike likeFeedElement(String communityId, String feedElementId) {
        return null;
    }
    @RemoteAction
    global static GNT.ElementCommentInfo postFeedComment(String communityId, String feedElementId, String text) {
        return null;
    }
    @RemoteAction
    global static GNT.FeedElementInfo postLinkFeedElement(String community, String id, String feedElementText, String linkName, String linkUrl) {
        return null;
    }
    @RemoteAction
    global static GNT.FeedElementInfo postTextFeedElement(String community, String id, String feedElementText) {
        return null;
    }
    @RemoteAction
    global static void removeBookmark(String community, String feedElementID) {

    }
    @RemoteAction
    global static ConnectApi.GroupMembershipRequest requestGroupMembership(String community, String id) {
        return null;
    }
    @RemoteAction
    global static GNT.FeedElementInfo shareFeedElement(String feedElementId, String shareId, String comment) {
        return null;
    }
    @RemoteAction
    global static void unFollow(String community, String id) {

    }
    @RemoteAction
    global static void unLikeElement(String communityId, String likeId) {

    }
global class customGroup {
}
global class customUser {
}
}
