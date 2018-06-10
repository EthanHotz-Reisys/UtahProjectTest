/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class ExpressionBuilderCtrl {
    global ExpressionBuilderCtrl() {

    }
    @RemoteAction
    global static Map<String,Object> fetchConfigurations() {
        return null;
    }
    @RemoteAction
    global static String fetchExpressionJSON(String contextRecordId, String contextRecordJSONField) {
        return null;
    }
    @RemoteAction
    global static List<GNT.ExpressionBuilderCtrl.FieldResultWrapper> fetchInitialRelatedFields(String fieldProviderSObjectName) {
        return null;
    }
    @RemoteAction
    global static List<GNT.ExpressionBuilderCtrl.FieldResultWrapper> fetchObjectRelatedFields(String objectName, Integer fieldLevel) {
        return null;
    }
    @RemoteAction
    global static Boolean saveJSONExpression(String contextRecordId, String contextRecordJSONField, String jsonExp) {
        return null;
    }
global class FieldResultWrapper {
    global Boolean HasCrossReference {
        get;
        set;
    }
    global String Label {
        get;
        set;
    }
    global Integer Level {
        get;
        set;
    }
    global String Name {
        get;
        set;
    }
    global String ObjectName {
        get;
        set;
    }
    global String RelationshipName {
        get;
        set;
    }
    global String RelationshipObjName {
        get;
        set;
    }
    global String Type {
        get;
        set;
    }
    global FieldResultWrapper() {

    }
}
}
