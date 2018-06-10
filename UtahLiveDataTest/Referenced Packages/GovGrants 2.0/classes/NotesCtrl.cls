/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class NotesCtrl {
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
    global NotesCtrl() {

    }
    @RemoteAction
    global static Map<String,Object> deleteNote(String noteId) {
        return null;
    }
    @RemoteAction
    global static Map<String,Object> fetchNotes(String parentObjectIds, String pblockId, Boolean isView) {
        return null;
    }
}
