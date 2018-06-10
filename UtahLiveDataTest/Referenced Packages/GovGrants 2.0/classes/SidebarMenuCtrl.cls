/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class SidebarMenuCtrl {
    global String hideSidebar {
        get;
        set;
    }
    global String icon {
        get;
        set;
    }
    global String parameterMap {
        get;
        set;
    }
    global String tabId {
        get;
        set;
    }
    global String type {
        get;
        set;
    }
    global SidebarMenuCtrl() {

    }
    global SidebarMenuCtrl(String tabId, String parameterMap, String type, String hiddenSidebar) {

    }
    @RemoteAction
    global static Map<String,Object> fetchAccordionData(String tabName, String paramMap, String type, String hiddenSidebar) {
        return null;
    }
    @RemoteAction
    global static void updateUserPreference(Boolean accordionCollapsed, List<String> expandedArray, List<String> collapsedArray) {

    }
}
