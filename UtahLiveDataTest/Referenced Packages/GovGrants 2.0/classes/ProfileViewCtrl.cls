/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class ProfileViewCtrl {
    @RemoteAction
    global static void deleteUserPhoto(String id) {

    }
    @RemoteAction
    global static ConnectApi.Subscription follow(String id) {
        return null;
    }
    @RemoteAction
    global static ConnectApi.UserPage getAllUsers(Integer token) {
        return null;
    }
    global static ConnectApi.FollowerPage getFollowers(String id, Integer token) {
        return null;
    }
    @RemoteAction
    global static ConnectApi.FollowerPage getFollowers(String community, String id, Integer token) {
        return null;
    }
    @RemoteAction
    global static ConnectApi.FollowingPage getFollowings(String id, Integer token) {
        return null;
    }
    @RemoteAction
    global static List<ContentVersion> getGroupFiles(String id) {
        return null;
    }
    @RemoteAction
    global static ConnectApi.GroupMemberPage getGroupMembers(String id, Integer token) {
        return null;
    }
    global static Set<Id> getGroupsForIds(Set<Id> userOrGroupIds) {
        return null;
    }
    @RemoteAction
    global static List<User> getManagers(String name, String roleId) {
        return null;
    }
    @RemoteAction
    global static List<ContentVersion> getMyFiles(String id) {
        return null;
    }
    @RemoteAction
    global static List<CollaborationGroup> getMyGroups(String id) {
        return null;
    }
    @RemoteAction
    global static List<ConnectApi.GroupMembershipRequest> getPendingRequests(String id) {
        return null;
    }
    @RemoteAction
    global static ConnectApi.FollowingPage getUserFollowings(String community, String id, Integer token, String filterType) {
        return null;
    }
    @RemoteAction
    global static void unFollow(String id) {

    }
    @RemoteAction
    global static String uploadUserPhoto(String profileHiddenFile, String profileHiddenType, String profileHiddenName, Boolean isLast, Boolean isFirst) {
        return null;
    }
    global static void uploadUserPhoto(String profileHiddenFile, String profileHiddenType, String profileHiddenName) {

    }
global class fakeContentVersion {
    global fakeContentVersion() {

    }
}
}
