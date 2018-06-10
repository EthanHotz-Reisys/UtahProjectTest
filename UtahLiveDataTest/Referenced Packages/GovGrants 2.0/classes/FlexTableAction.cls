/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global abstract class FlexTableAction {
    global GNT__DataTableAction__c actionConfig;
    global String dataTableConfigName;
    global Id selectedRecordId;
    global List<String> selectedRecordIds;
    global Map<String,String> urlParams;
    global FlexTableAction() {

    }
    global abstract System.PageReference whenClicked();
}
