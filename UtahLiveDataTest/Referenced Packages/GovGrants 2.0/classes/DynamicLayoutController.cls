/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class DynamicLayoutController {
    global String accessMessage {
        get;
        set;
    }
    global System.PageReference cancelPage {
        get;
        set;
    }
    global String chartParameters {
        get;
        set;
    }
    global Double currentOrder {
        get;
        set;
    }
    global String currentPageURL {
        get;
        set;
    }
    global System.PageReference deletePage {
        get;
        set;
    }
    global Boolean enableNativeLayoutFromDynamicLayout {
        get;
        set;
    }
    global String flexTableParameterJSON {
        get;
        set;
    }
    global String flexTableParameterJSONChanged {
        get;
        set;
    }
    global String flexTableParameters {
        get;
        set;
    }
    global String formnumber {
        get;
        set;
    }
    global String formSaved {
        get;
        set;
    }
    global List<String> formTypeList {
        get;
        set;
    }
    global List<System.SelectOption> formTypeList1 {
        get;
        set;
    }
    global String formversion {
        get;
        set;
    }
    global Boolean hasDeleteAccess {
        get;
        set;
    }
    global Boolean hasErrors {
        get;
        set;
    }
    global String header {
        get;
        set;
    }
    global Boolean hideSidebarUser {
        get;
        set;
    }
    global String keyValueMapForFlexTable {
        get;
        set;
    }
    global Double lastFormOrder {
        get;
        set;
    }
    global GNT.DynamicLayoutHolder layoutHolder {
        get;
        set;
    }
    global String layoutId {
        get;
        set;
    }
    global List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {
        get;
        set;
    }
    global String listParameters {
        get;
        set;
    }
    global String listParams {
        get;
        set;
    }
    global String pageBlockIds {
        get;
        set;
    }
    global GNT__PageTemplate__c pageTemplate {
        get;
        set;
    }
    global String parentLytId {
        get;
        set;
    }
    global String parId {
        get;
        set;
    }
    global String pckgName {
        get;
        set;
    }
    global String pkgId {
        get;
        set;
    }
    global String pkgName {
        get;
        set;
    }
    global String rcrdId {
        get;
        set;
    }
    global System.PageReference savePage {
        get;
        set;
    }
    global String selectedPageLayoutId {
        get;
        set;
    }
    global Integer sequenceNumber {
        get;
        set;
    }
    global String themeDocumentId {
        get;
        set;
    }
    global String tmplName {
        get;
        set;
    }
    global String type {
        get;
        set;
    }
    global String windowTitle {
        get;
        set;
    }
    global DynamicLayoutController() {

    }
    global DynamicLayoutController(ApexPages.StandardController controller) {

    }
    global static Map<String,Object> decideActions(String recordId, String layoutId) {
        return null;
    }
    @RemoteAction
    global static Map<String,Object> decideActions(String recordId, String layoutId, Map<String,Object> paramMap) {
        return null;
    }
    @RemoteAction
    global static Map<String,String> fetchHelpDataRemote(Id helpConfigId) {
        return null;
    }
    @RemoteAction
    global static Map<String,Object> fetchMiniLayout(Id referenceId) {
        return null;
    }
    @RemoteAction
    global static void markPageLayoutAsActive(Map<String,Object> args) {

    }
    @RemoteAction
    global static String navForms1(String url, String value, String selectedform) {
        return null;
    }
    @RemoteAction
    global static void postHistorySnapshot(String actionId, Id recordId, String tmplName, String flexTableParameterJSON, String listParams) {

    }
}
