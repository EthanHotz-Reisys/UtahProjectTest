/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class ConfigDataService {
    global ConfigDataService() {

    }
    webService static ggcs.ConfigDataService.SObjectResponse handle(ggcs.ConfigDataService.SObjectRequest request) {
        return null;
    }
global class SField {
    @WebService
    webService String fieldName;
    @WebService
    webService String fieldValue;
    global SField() {

    }
    global SField(String fieldName, String fieldValue) {

    }
}
global class SObjectKey {
    @WebService
    webService String sobjectName;
    @WebService
    webService List<String> uniqueFieldNames;
}
global class SObjectRequest {
    @WebService
    webService List<ggcs.ConfigDataService.SObjectKey> keys;
    @WebService
    webService List<ggcs.ConfigDataService.SObjectTable> tables;
    global SObjectRequest() {

    }
}
global class SObjectResponse {
    @WebService
    webService String errorMessage;
    @WebService
    webService Boolean success;
    @WebService
    webService List<ggcs.ConfigDataService.SObjectTable> tables;
    global SObjectResponse() {

    }
}
global class SObjectTable {
    @WebService
    webService List<ggcs.ConfigDataService.SRecord> deleteRecords;
    @WebService
    webService List<ggcs.ConfigDataService.SRecord> insertRecords;
    @WebService
    webService String sobjectName;
    @WebService
    webService List<ggcs.ConfigDataService.SRecord> updateRecords;
    global SObjectTable() {

    }
}
global class SRecord {
    @WebService
    webService Boolean attempted;
    @WebService
    webService String errorMessage;
    @WebService
    webService List<ggcs.ConfigDataService.SField> fieldValues;
    @WebService
    webService String sobjectName;
    @WebService
    webService Boolean success;
    @WebService
    webService String uniqueFieldValue;
    global SRecord() {

    }
    global SRecord(String uniqueFieldValue) {

    }
    global SRecord(String uniqueFieldValue, List<ggcs.ConfigDataService.SField> fields) {

    }
    global SRecord(String uniqueFieldValue, ggcs.ConfigDataService.SField field) {

    }
}
}
