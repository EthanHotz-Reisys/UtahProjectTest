/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class UsefulLinksCtrl {
    global Integer actualItemCount {
        get;
        set;
    }
    global List<GNT.UsefulLinksCtrl.UsefulLinkWrapper> extendedLinksList {
        get;
        set;
    }
    global Integer minItemsCount {
        get;
        set;
    }
    global List<GNT.UsefulLinksCtrl.UsefulLinkWrapper> minLinksList {
        get;
        set;
    }
    global UsefulLinksCtrl() {

    }
    global void initialize() {

    }
global class UsefulLinkWrapper {
    global String label {
        get;
        set;
    }
    global Boolean openInNewWindow {
        get;
        set;
    }
    global String url {
        get;
        set;
    }
    global UsefulLinkWrapper(String label, String url, Boolean openInNewWindow) {

    }
}
}
