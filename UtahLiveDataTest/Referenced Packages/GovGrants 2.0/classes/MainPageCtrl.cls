/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class MainPageCtrl {
    global Boolean adminSetupFlag {
        get;
        set;
    }
    global String clientFooterLogoDocId {
        get;
        set;
    }
    global String clientFooterLogoText {
        get;
        set;
    }
    global String expandTextCharSize {
        get;
        set;
    }
    global String expandTextLessStr {
        get;
        set;
    }
    global String expandTextMoreStr {
        get;
        set;
    }
    global List<GNT.MainPageCtrl.FooterConfig> footerList {
        get;
        set;
    }
    global Boolean hidepublicSearch {
        get;
        set;
    }
    global Boolean hideSidebar {
        get;
        set;
    }
    global Boolean homeTabFlag {
        get;
        set;
    }
    global Boolean isGuest {
        get;
        set;
    }
    global Boolean isMaintenance {
        get;
        set;
    }
    global String maintenanceMessage {
        get;
        set;
    }
    global String maintenanceTitle {
        get;
        set;
    }
    global Boolean showFeedbackComponent {
        get;
        set;
    }
    global String themeDocURL {
        get;
        set;
    }
    global List<String> URLStringList {
        get;
        set;
    }
    global MainPageCtrl() {

    }
    @RemoteAction
    global static void hideUserSideBarPreference() {

    }
    global Boolean hidepublicSearchBar() {
        return null;
    }
    global Boolean showHideHomeTab() {
        return null;
    }
    @RemoteAction
    global static void showUserSideBarPreference() {

    }
global class FooterConfig implements System.Comparable {
    global String displayText {
        get;
        set;
    }
    global Boolean lastEntry {
        get;
        set;
    }
    global String targetURL {
        get;
        set;
    }
    global FooterConfig(String displayText, String targetURL, Integer sequence) {

    }
    global Integer compareTo(Object other) {
        return null;
    }
}
}
