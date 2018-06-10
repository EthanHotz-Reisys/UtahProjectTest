/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class FlexTableCtrl {
    global String dataTableConfigName {
        get;
        set;
    }
    global String flexHeaderDescription {
        get;
        set;
    }
    global String FlexTableFieldAPIs {
        get;
        set;
    }
    global String flexTableHeaderTitle {
        get;
        set;
    }
    global String flexTablePropInfo {
        get;
        set;
    }
    global String keyValueMap {
        get;
        set;
    }
    global String listKeyValueMap {
        get;
        set;
    }
    global String objectName {
        get;
        set;
    }
    global String phase {
        get;
        set;
    }
    global String searchTerm {
        get;
        set;
    }
    global String sObjectNameForFieldHistory {
        get;
        set;
    }
    global FlexTableCtrl() {

    }
    @RemoteAction
    global static Map<String,Object> deleteRecord(String objectName, String recordId) {
        return null;
    }
    @RemoteAction
    global static Map<String,Object> deleteRecords(Map<String,List<String>> objectNameToIdsMap) {
        return null;
    }
    @RemoteAction
    global static Map<String,Object> executeClass(String className, Map<String,String> idsMap, Map<String,String> keyValueMap, GNT__DataTableAction__c actionConfig, String dataTableConfigName, String URL) {
        return null;
    }
    global static Map<String,Object> fetchAutoSuggestData(String fieldName, String sobjName, String searchTerm, String filterClause) {
        return null;
    }
    global static Map<String,Object> fetchAutoSuggestData(String fieldName, String sobjName, String searchTerm, String filterClause, String keyValueMapString) {
        return null;
    }
    @RemoteAction
    global static Map<String,Object> fetchAutoSuggestData(String fieldName, String flexDetailId, String sobjName, String searchTerm, String filterClause, String keyValueMapString) {
        return null;
    }
    @RemoteAction
    global static Map<String,Object> fetchEditableGridData(String editableGridName, String keyValueMap, String listKeyValueMap, Boolean sforce1) {
        return null;
    }
    @RemoteAction
    global static Map<String,Object> fetchGridType(String dataTableConfigName, String keyValueMap, String listKeyValueMap, Boolean sforce1) {
        return null;
    }
    @RemoteAction
    global static Map<String,Object> fetchInitialDataWithFilter(String dataTableConfigName, String keyValueMap, String listKeyValueMap, Boolean sforce1, String filterClause, Map<String,Object> paramMap) {
        return null;
    }
    @RemoteAction
    global static Map<String,Object> fetchInitialData(String dataTableConfigName, String keyValueMap, String listKeyValueMap, Boolean sforce1) {
        return null;
    }
    @RemoteAction
    global static Map<String,Object> fetchInitialHistoryData(String dataTableConfigName, String objName, String childObject, Boolean isHistoryField, String recId, String keyValueMap, String listKeyValueMap, Boolean sforce1) {
        return null;
    }
    @RemoteAction
    global static Map<String,Object> fetchInitialSearchDataWithSorting(String searchTerm, String objectName, String phaseName, String keyValueMap, String listKeyValueMap, Boolean sforce1, String orderBy, String sortDirection) {
        return null;
    }
    global static Map<String,Object> fetchInitialSearchData(String searchTerm, String objectName, String phaseName, String keyValueMap, String listKeyValueMap, Boolean sforce1) {
        return null;
    }
    global static Map<String,Object> fetchLookupData(String fieldName, String sobjName, String searchTerm) {
        return null;
    }
    global static Map<String,Object> fetchLookupData(String fieldName, String sobjName, String searchTerm, String filterClause) {
        return null;
    }
    @RemoteAction
    global static Map<String,Object> fetchMiniLayout(Id referenceId) {
        return null;
    }
    @RemoteAction
    global static Map<String,Object> fetchN2GData(String editableGridName, String keyValueMap, String listKeyValueMap, Boolean sforce1) {
        return null;
    }
    @RemoteAction
    global static Map<String,Object> fetchPreviewData(String dataTableConfigName, Boolean sforce1) {
        return null;
    }
    @RemoteAction
    global static Map<String,Object> fetchStickySearchSuggestionsData(String paramMap) {
        return null;
    }
    @RemoteAction
    global static Map<String,Object> getAccountHierarchy(String accId) {
        return null;
    }
    @RemoteAction
    global static Map<String,Object> getPageRecordsForFlexGrid(String queryColumns, String childRelationShipQueries, String hideDecisionFields, String objectName, String filterClause, String sortBy, String sortDir, Integer pageNumber, Integer pageSize, Boolean isSOSL) {
        return null;
    }
    @RemoteAction
    global static Map<String,Object> getPageRecordsForN2GNew2(String queryColumns, String childRelationShipQueries, String hideDecisionFields, String objectName, String filterClause, String sortBy, String sortDir, Integer pageNumber, Integer pageSize, Boolean isSOSL, String parentObjectName, String childObjectName, String configFilterClause, String parentLookupField) {
        return null;
    }
    @RemoteAction
    global static Map<String,Object> getPageRecordsForN2GNew(String queryColumns, String childRelationShipQueries, String hideDecisionFields, String objectName, String filterClause, String sortBy, String sortDir, Integer pageNumber, Integer pageSize, Boolean isSOSL, String parentObjectName, String childObjectName, String configFilterClause) {
        return null;
    }
    @RemoteAction
    global static Map<String,Object> getPageRecordsForN2G(String queryColumns, String childRelationShipQueries, String hideDecisionFields, String objectName, String filterClause, String sortBy, String sortDir, Integer pageNumber, Integer pageSize, Boolean isSOSL, String parentObjectName, String childObjectName) {
        return null;
    }
    @RemoteAction
    global static Map<String,Object> getPageRecordsWithMergeFields(String queryColumns, String hideDecisionFields, String objectName, Integer pageNumber, Integer pageSize, String sortBy, String sortDir, String searchTerm, String filterClause, Boolean isSOSL, String mergeFields) {
        return null;
    }
    @RemoteAction
    global static Map<String,Object> getPageRecords(String queryColumns, String hideDecisionFields, String objectName, Integer pageNumber, Integer pageSize, String sortBy, String sortDir, String searchTerm, String filterClause, Boolean isSOSL) {
        return null;
    }
    @RemoteAction
    global static void markFlexTableAsActive(Map<String,Object> args) {

    }
    @RemoteAction
    global static Map<String,Object> paintLookupFlexTable(String fieldAPINames, String sobjectName, String filterClause, Map<String,Object> paramMap) {
        return null;
    }
    @RemoteAction
    global static List<String> refreshTables(String pageLayoutName) {
        return null;
    }
    @RemoteAction
    global static Map<String,Object> updateFlexTableWithStickySearch(Map<String,Object> paramMap) {
        return null;
    }
    @RemoteAction
    global static Map<String,Object> updateRows(String updatedRows, String parentTableMetadata) {
        return null;
    }
}
