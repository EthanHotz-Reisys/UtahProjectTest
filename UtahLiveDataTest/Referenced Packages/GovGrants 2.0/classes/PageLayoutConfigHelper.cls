/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class PageLayoutConfigHelper {
    global PageLayoutConfigHelper() {

    }
    global PageLayoutConfigHelper(String layoutId, Id recordId) {

    }
    global PageLayoutConfigHelper(String layoutId, Boolean isViewLayout) {

    }
    global PageLayoutConfigHelper(String layoutId, Boolean isViewLayout, String packageId) {

    }
    global PageLayoutConfigHelper(String layoutId, Integer sequenceNumber, Boolean isViewLayout) {

    }
    global PageLayoutConfigHelper(String layoutId, String tabName, Boolean isViewLayout) {

    }
    global PageLayoutConfigHelper(String layoutId, Boolean firstTabOnly, Boolean restOfTheTabs, Boolean isViewLayout) {

    }
global class AlternativeRendering {
    global String autoCompleteSobject {
        get;
    }
    global String checkBoxAlignment {
        get;
        set;
    }
    global Map<String,String> dbValueMap {
        get;
        set;
    }
    global List<System.SelectOption> displayValues {
        get;
    }
    global Map<Object,Object> selectMap;
    global String typex {
        get;
    }
    global AlternativeRendering(GNT__DynamicFieldConfig__c cs) {

    }
}
global class Layout {
    global String activeTabId {
        get;
        set;
    }
    global Integer activeTabSize {
        get;
        set;
    }
    global Boolean closeOnSave {
        get;
        set;
    }
    global Double completionPercent {
        get;
        set;
    }
    global String EditlayoutMode {
        get;
        set;
    }
    global String externalHeaderDescription {
        get;
        set;
    }
    global Set<String> fieldsToQuery;
    global String header {
        get;
        set;
    }
    global String headerDescription {
        get;
        set;
    }
    global String headerOverride {
        get;
        set;
    }
    global Boolean hideApprovalComponentInEdit {
        get;
        set;
    }
    global Boolean hidePDFDownload {
        get;
        set;
    }
    global Boolean hideTakeSnapshot {
        get;
        set;
    }
    global Boolean isEditLayout {
        get;
        set;
    }
    global String layoutId {
        get;
        set;
    }
    global GNT.DynamicMessageHolder messages {
        get;
        set;
    }
    global String name {
        get;
        set;
    }
    global String objectName {
        get;
        set;
    }
    global String ProgressbarGroupName {
        get;
        set;
    }
    global Set<String> queues;
    global Boolean refreshAllFlexTables {
        get;
        set;
    }
    global Boolean ShowCustomButtonsonFooter {
        get;
        set;
    }
    global List<GNT.PageLayoutConfigHelper.Tab> tabs {
        get;
        set;
    }
    global String ViewlayoutMode {
        get;
        set;
    }
    global Layout() {

    }
}
}
