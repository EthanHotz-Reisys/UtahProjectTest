/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class AttachmentsCtrl {
    global String classification {
        get;
        set;
    }
    global Boolean isDigiSign {
        get;
        set;
    }
    global Boolean isPreviewAttach {
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
    global AttachmentsCtrl() {

    }
    @RemoteAction
    global static Map<String,Object> deleteAttchment(String attachmentId) {
        return null;
    }
    global static Map<String,Object> fetchAttachments(String parentObjectIds, String pblockId, Boolean isView, Boolean loadConfigData, Boolean isDigiSign) {
        return null;
    }
    @RemoteAction
    global static Map<String,Object> fetchAttachments(String parentObjectIds, String pblockId, Boolean isView, Boolean loadConfigData, Boolean isDigiSign, Boolean isHistory) {
        return null;
    }
}
