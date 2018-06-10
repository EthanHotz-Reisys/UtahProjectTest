/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class SchemaManager {
    global SchemaManager() {

    }
    global static Boolean doesObjExist(String objectName) {
        return null;
    }
    global static Schema.DescribeFieldResult fetchDescribeFieldResult(String objectName, String fieldName) {
        return null;
    }
    global static List<String> getFieldNameList(Id objectId) {
        return null;
    }
    global static GNT.SchemaManager.Field getFieldSchemaResult(String objectName, String fieldName) {
        return null;
    }
    global static Map<String,Schema.SObjectField> getFieldsMap(String objectName) {
        return null;
    }
    global static Map<String,GNT.SchemaManager.SObjectWrapper> getObjectsForReferenceFields(String objectName) {
        return null;
    }
    global static GNT.SchemaManager.SObjectWrapper getSObject(Id objectId) {
        return null;
    }
    global static GNT.SchemaManager.SObjectWrapper getSObject(String objectName) {
        return null;
    }
    global static Schema.SObjectField getSObjectField(String objectName, String fieldName) {
        return null;
    }
    global static GNT.SchemaManager.Field getSObjectFieldSet(String objectName, String fieldSetName) {
        return null;
    }
    global static List<String> getTextAreaFieldNames(String sObjectName) {
        return null;
    }
global class Field {
    global Schema.DescribeFieldResult fieldDesc;
    global String fieldName;
    global Schema.FieldSet fieldSetDesc;
    global Boolean isRelationshipField;
    global Boolean isUpdatable;
    global String objectName;
    global Schema.SObjectType objectType;
    global Field(String objectName, Schema.SObjectType objectType, String fieldName, Boolean isRelationshipField) {

    }
}
global class SObjectFieldSetWrapper {
    global String fieldSetName;
    global Schema.FieldSet fieldSetResult;
    global GNT.SchemaManager.SObjectWrapper objectWrapper;
    global SObjectFieldSetWrapper(GNT.SchemaManager.SObjectWrapper objectWrapper, Schema.FieldSet fieldSetResult) {

    }
}
global class SObjectFieldWrapper {
    global String fieldName;
    global Schema.DescribeFieldResult fieldResult;
    global GNT.SchemaManager.SObjectWrapper objectWrapper;
    global SObjectFieldWrapper(GNT.SchemaManager.SObjectWrapper objectWrapper, Schema.DescribeFieldResult fieldResult) {

    }
}
global class SObjectWrapper {
    global Map<String,GNT.SchemaManager.SObjectFieldSetWrapper> fieldSetsMap;
    global Map<String,GNT.SchemaManager.SObjectFieldWrapper> fieldsMap;
    global String objectName;
    global Schema.DescribeSObjectResult objectResult;
    global Schema.SObjectType objectType;
    global SObjectWrapper(String objectName) {

    }
    global GNT.SchemaManager.SObjectFieldWrapper getField(String fieldName) {
        return null;
    }
    global GNT.SchemaManager.SObjectFieldSetWrapper getFieldSet(String fieldSetName) {
        return null;
    }
}
}
