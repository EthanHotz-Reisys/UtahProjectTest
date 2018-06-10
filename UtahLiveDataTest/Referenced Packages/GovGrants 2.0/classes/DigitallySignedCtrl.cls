/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class DigitallySignedCtrl {
    global String classification {
        get;
        set;
    }
    global Boolean isDigiSign {
        get;
        set;
    }
    global String pageBlockId {
        get;
        set;
    }
    global Id parentObjectId {
        get;
        set;
    }
    global Integer timeOffset {
        get;
        set;
    }
    global String titleValue {
        get;
        set;
    }
    global DigitallySignedCtrl() {

    }
    @RemoteAction
    global static void cancelSignature(String apiKey, String apiSig, String DocverifyId) {

    }
    @RemoteAction
    global static Map<String,Object> deleteDocument(String docId) {
        return null;
    }
    @RemoteAction
    global static Map<String,Object> fetchDocuments(String parentObjectId, String pblockId, Boolean isView, Boolean loadConfigData, Boolean isDigiSign) {
        return null;
    }
}
