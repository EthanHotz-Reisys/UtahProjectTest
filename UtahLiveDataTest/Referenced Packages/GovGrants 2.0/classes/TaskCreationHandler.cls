/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class TaskCreationHandler {
    global TaskCreationHandler() {

    }
    global static List<Task> createApprovalProcessTasks(Id recordId, String action, String recordName, Date dueDate, Boolean create) {
        return null;
    }
    global static List<Task> createApprovalProcessTasks(Id recordId, String action, String recordName, String groupName, Date dueDate, Boolean create) {
        return null;
    }
    global static List<Task> createApprovalProcessTasks(Id recordId, String action, String recordName, String groupName, Date dueDate, String subject, Boolean create) {
        return null;
    }
    global static List<Task> createBulkTasks(List<GNT.TaskCreationHandler.TaskBulkClass> bulkList, Boolean create) {
        return null;
    }
    global static List<Task> createTasks(Id ownerUserId, Id recordId, String action, String recordName, String groupName, Boolean taskCompleted, Date dueDate, String taskType, Boolean create) {
        return null;
    }
    global static List<Task> createTasks(Id ownerUserId, Id recordId, String action, String recordName, String groupName, Boolean taskCompleted, Date dueDate, String taskType, String subject, Boolean create) {
        return null;
    }
    global static List<Task> createTasks(Id ownerUserId, Id recordId, String action, String recordName, String groupName, Boolean taskCompleted, Date dueDate, String taskType, String subject, Boolean associateWithApproval, Boolean create) {
        return null;
    }
    global static void recallRecord(Id recordId, String comments) {

    }
global class TaskBulkClass {
    global String action {
        get;
        set;
    }
    global String comments {
        get;
        set;
    }
    global Date dueDate {
        get;
        set;
    }
    global String groupName {
        get;
        set;
    }
    global Id ownerUserId {
        get;
        set;
    }
    global Id recordId {
        get;
        set;
    }
    global String recordName {
        get;
        set;
    }
    global Date startDate {
        get;
        set;
    }
    global String subject {
        get;
        set;
    }
    global Boolean taskCompleted {
        get;
        set;
    }
    global String taskScheduleDetailId {
        get;
        set;
    }
    global String taskType {
        get;
        set;
    }
    global TaskBulkClass() {

    }
}
}
