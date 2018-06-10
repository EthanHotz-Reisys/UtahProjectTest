/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class CollabFilesCtrl {
    global CollabFilesCtrl() {

    }
    @RemoteAction
    global static List<String> EntityLinks(String versionId) {
        return null;
    }
    @RemoteAction
    global static String addEntityLinks(String documentId, String entityIds, String shareTypes, String message) {
        return null;
    }
    @RemoteAction
    global static Boolean canUploadNewVersion(String documentId, String userId) {
        return null;
    }
    @RemoteAction
    global static void deleteFile(String versionId) {

    }
    @RemoteAction
    global static String editDesc(String id, String myDesc) {
        return null;
    }
    @RemoteAction
    global static String follow(String id) {
        return null;
    }
    @RemoteAction
    global static Map<String,String> following() {
        return null;
    }
    @RemoteAction
    global static List<CollaborationGroup> getGroups(String accountId, String search, Boolean allowExternal, String networkId) {
        return null;
    }
    @RemoteAction
    global static List<User> getUsers(String accountId, Boolean allowExternal, String name, String userId) {
        return null;
    }
    @RemoteAction
    global static void makeCollab(String userId, String linkedEntityId, String documentId) {

    }
    @RemoteAction
    global static void makePrivate(String id) {

    }
    @RemoteAction
    global static void makeViewer(String userId, String linkedEntityId, String documentId) {

    }
    @RemoteAction
    global static void removeAccess(String userId, String linkedEntityId, String documentId) {

    }
    @RemoteAction
    global static void unFollow(String id) {

    }
}
