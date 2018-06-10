/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class AppUtils {
    global static Boolean callFutureMethodUserTrigger;
    global static Boolean skipAccountTrigger;
    global static Boolean skipDOH_ProgramTrigger;
    global static Boolean skipDOH_ReviewStepTriggerHelper;
    global static Boolean skipDOH_UserTrigger;
    global static Boolean skipDohAnnouncementTrigger;
    global static Boolean skipDohApplicationTrigger;
    global static Boolean skipGrantMonitoringPlanTrigger;
    global static Boolean skipPhaseConfigTrigger;
    global static Boolean skipStepReviewTrigger;
    global static Boolean skipTriggerInRecallBatch;
    global static Integer SOQL_LIMIT;
    global AppUtils() {

    }
    global static Map<String,Id> GetRecordTypeIdsByDeveloperName(Schema.SObjectType token) {
        return null;
    }
    global static Datetime addBusinessDays(Datetime actualDate, Integer offsetDays) {
        return null;
    }
    global static String applyNamespacePrefix(String fieldName) {
        return null;
    }
    global static Task assignTaskForSObject(Task approvalTask, String recordId) {
        return null;
    }
    global static Boolean checkAdminUser() {
        return null;
    }
    global static String concatenate(List<String> arr, String sep) {
        return null;
    }
    global static String concatenate(Set<Id> arr, String sep) {
        return null;
    }
    global static String concatenate(Set<String> arr, String sep) {
        return null;
    }
    global static void copyFieldValues(SObject fromRec, SObject toRec, Set<String> fieldsToExclude) {

    }
    global static void copyRecord(SObject source, SObject target, Boolean create) {

    }
    global static void copyRecord(String sourceObject, String targetObject, Id sourceRecordIDs, SObject sobjectRec) {

    }
    global static void copyRecord(String sourceObject, String targetObject, Id sourceRecordIDs, SObject sobjectRec, String groupName) {

    }
    global static List<SObject> copyRecords(String sourceObject, String targetObject, List<Id> sourceRecordIDs, Boolean create) {
        return null;
    }
    global static List<SObject> copyRecords(String sourceObject, String targetObject, Map<Id,List<SObject>> srcIdToTargetSobjectsMap, Boolean create) {
        return null;
    }
    global static GNT.AppUtils.ValidationException createValidationException(Exception ex) {
        return null;
    }
    global static List<String> decodeToArray(String dbVal) {
        return null;
    }
    global static void dumpUrlParameters() {

    }
    global static String encodeToString(String displayVal) {
        return null;
    }
    global static String encodeToString(List<String> displayVals) {
        return null;
    }
    global static String fieldsList(List<String> inStr) {
        return null;
    }
    global static String formatCurrency(Decimal numberTobeFormatted) {
        return null;
    }
    global static String generateToken(Integer length) {
        return null;
    }
    global static List<String> getCountryPickListValues() {
        return null;
    }
    global static String getCurrentFiscalYear() {
        return null;
    }
    global static String getDefaultPhase() {
        return null;
    }
    global static List<String> getFiscalYearPickListValues() {
        return null;
    }
    global static System.PageReference getHomePage() {
        return null;
    }
    global static Boolean getIsNewUserRegWindowOpen() {
        return null;
    }
    global static Set<String> getMergeFieldsForTemplate(Set<String> fields, String objectType) {
        return null;
    }
    global static List<String> getMergeFields(String header) {
        return null;
    }
    global static String getMonthName(Integer month) {
        return null;
    }
    global static String getNameSpacePrefix() {
        return null;
    }
    global static Integer getNumericValueFromString(String data) {
        return null;
    }
    global static String getOrgWideEmailAddress() {
        return null;
    }
    global static List<String> getPickListValues(String objectAPIName, String fieldAPIName) {
        return null;
    }
    global static String getProfileInfo() {
        return null;
    }
    global static Map<String,String> getRelationshipFieldMap(String objectName) {
        return null;
    }
    global static String getRetURL() {
        return null;
    }
    global static System.PageReference getReturnPage() {
        return null;
    }
    global static String getRoleInfo() {
        return null;
    }
    global static String getSelectedTabName() {
        return null;
    }
    global static List<String> getStringsFromMultiSelect(String values) {
        return null;
    }
    global static List<String> getUserMergeFields(String header) {
        return null;
    }
    global static String getUserType() {
        return null;
    }
    global static Boolean isAdminUser() {
        return null;
    }
    global static Boolean isApplicant() {
        return null;
    }
    global static Boolean isHistoryTable(String objectName) {
        return null;
    }
    global static Boolean isInternalUser() {
        return null;
    }
    global static Boolean isMultiSelectEmpty(String values) {
        return null;
    }
    global static Boolean isSandbox() {
        return null;
    }
    global static Boolean isSite() {
        return null;
    }
    global static Boolean isSystemAdminUser() {
        return null;
    }
    global static void notifyTechSupport(Exception e) {

    }
    global static void notifyTechSupport(List<Database.SaveResult> saveResult, List<SObject> sobejctList, String clsName) {

    }
    global static List<System.SelectOption> prepareSelectOption(Schema.DescribeFieldResult describeField) {
        return null;
    }
    global static Boolean readOnlyOrEditableForComponent(Boolean isViewLayout, Boolean isInternal, Boolean isApplicant, String profileNames, String recordId, String readContext, String userType, String userProfile, String userRole, String userRoles) {
        return null;
    }
    global static String removeNamespacePrefix(String fieldName) {
        return null;
    }
    global static String replaceFields(String text, List<String> mergeFields, SObject record) {
        return null;
    }
    global static String replaceMergeFields(String text, Id recordId) {
        return null;
    }
    global static String replaceMergeFields(String text, SObject record) {
        return null;
    }
    global static String replaceMergeFieldsForTemplates(String text, SObject record) {
        return null;
    }
    global static String replaceUserFields(String text, List<String> fields) {
        return null;
    }
    global static void resetWhereOrAndClause() {

    }
    global static List<Object> reverse(List<Object> anArray) {
        return null;
    }
    global static List<String> selectField(List<SObject> objs, String fieldName) {
        return null;
    }
    global static void sendEmailUsingTemplate(Id templateId, Map<Id,Id> appIdToContIdMap, Boolean setOWD) {

    }
    global static void sendEmailUsingTemplate(Id templateId, Map<Id,List<String>> recIdToAddressMap, Id dummyContactId, Boolean setOWD) {

    }
    global static void sendEmailUsingTemplate(Id templateId, Map<Id,Set<Id>> appIdToContIdSetMap, Boolean setOWD) {

    }
    global static void sendEmailUsingTemplate(Map<Id,Id> WhatIdtemplateMap, Map<Id,Id> sendEmailMap, Boolean setOWD) {

    }
    global static void sendEmailUsingTemplate(Map<Id,Id> recIdToTemplateIdMap, Map<Id,List<String>> recIdToAddressMap, Id dummyContactId, Boolean setOWD) {

    }
    global static void sendEmail(List<String> toAddresses, List<String> ccAddresses, String replyToEmail, Boolean bccSender, String subject, String plainTextBody, String htmlBody) {

    }
    global static void sendEmail(List<String> toAddresses, String subject, String plainTextBody, String htmlBody) {

    }
    global static void sendEmail(List<String> toAddresses, String subject, String plainTextBody, String htmlBody, Boolean setOWD) {

    }
    global static List<Messaging.SingleEmailMessage> sendTaskNotification(List<String> toAddresses, String subject, String body, Boolean setOWD) {
        return null;
    }
    global static void setReturnOnPage(String url, System.PageReference page) {

    }
    global static String setTabCookie(String tabName) {
        return null;
    }
    global static void setTabCookie() {

    }
    global static String setTabNameFromID() {
        return null;
    }
    global static Boolean showHideComponent(Boolean isViewLayout, Boolean isInternal, Boolean isApplicant, String profileNames, String recordId, String hideContext, String userType, String userProfile) {
        return null;
    }
    global static Boolean showHideComponent(Boolean isViewLayout, Boolean isInternal, Boolean isApplicant, String profileNames, String recordId, String hideContext, String userType, String userProfile, String operator) {
        return null;
    }
    global static Boolean showHideComponent(Boolean isViewLayout, Boolean isInternal, Boolean isApplicant, String profileNames, String recordId, String hideContext, String userType, String userProfile, String roleNames, String userRole) {
        return null;
    }
    global static Boolean showHideComponent(Boolean isViewLayout, Boolean isInternal, Boolean isApplicant, String profileNames, String recordId, String hideContext, String userType, String userProfile, String roleNames, String userRole, String operator) {
        return null;
    }
    global static String soqlList(List<String> inStr) {
        return null;
    }
    global static String soqlList(List<User> Ids) {
        return null;
    }
    global static String soqlList(Set<Id> inStr) {
        return null;
    }
    global static String soqlList(Set<String> inStr) {
        return null;
    }
    global static List<SObject> sortList(List<SObject> items, String sortField, Boolean ascending) {
        return null;
    }
    global static Approval.ProcessResult submitRecordForApproval(Id recordId) {
        return null;
    }
    global static String toString(Exception ex) {
        return null;
    }
    global static String trim(String str) {
        return null;
    }
    global static String urlParam(String key) {
        return null;
    }
    webService static Boolean validateExpression(String expression) {
        return null;
    }
    global static String whereOrAndClause() {
        return null;
    }
global class AgencyAutocomplete {
    global String agencyAbbr {
        get;
        set;
    }
    global String agencyName {
        get;
        set;
    }
    global AgencyAutocomplete(String agencyName, String agencyAbbr) {

    }
}
global class ValidationException extends Exception {
}
}
