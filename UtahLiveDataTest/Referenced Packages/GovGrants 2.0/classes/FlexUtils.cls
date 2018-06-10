/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class FlexUtils {
    global FlexUtils() {

    }
    global static Map<String,GNT.FlexUtils.FormCompletionDTO> getLayoutCompletion(Id recordId, String packageId) {
        return null;
    }
    global static Map<String,GNT.FlexUtils.FormCompletionDTO> getLayoutCompletion(Id recordId, String packageId, List<String> formTypes) {
        return null;
    }
    global static Map<String,GNT.FlexUtils.FormCompletionDTO> getLayoutCompletion(Id recordId, String packageId, List<String> formTypes, String formId) {
        return null;
    }
global class FormCompletionDTO {
    global String layoutId;
    global GNT__PackageFormConfig__c packageForm;
    global String recordId;
    global Decimal savePercentage;
    global Decimal submitPercentage;
    global Decimal totalPercentage;
    global FormCompletionDTO(String layoutId, Decimal savePercentage, Decimal submitPercentage, Decimal totalPercentage, String recordId) {

    }
    global FormCompletionDTO(String layoutId, Decimal savePercentage, Decimal submitPercentage, Decimal totalPercentage, String recordId, GNT__PackageFormConfig__c packageForm) {

    }
}
}
