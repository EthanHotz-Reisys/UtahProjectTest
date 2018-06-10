public with sharing class NotesEditCtrl{
    public String attachmentId {get;set;}
    public NotesWrapper editAttachmentWrapper {get;set;}
    public String classificationVal {get;set;}
    public String attachmentName {get;set;} 
    public NotesEditCtrl(){
        attachmentId = apexpages.currentpage().getparameters().get('NoteId');
        if(attachmentId != null && attachmentId !=''){
            Note editAttachment =  [SELECT Id, Body,Title,ParentId , OwnerId, CreatedDate,LastModifiedDate, Owner.Name 
                                                        FROM Note
                                                            WHERE Id =:attachmentId];                       
            editAttachmentWrapper = new NotesWrapper(editAttachment);                  
        }
    }
     public class NotesWrapper implements Comparable{                          
        public DateTime lastModifiedDate {get;set;}
        public Id objId {get;set;}
        public Note note{get;set;}
        public NotesWrapper(Note note){           
            this.note = note;                                  
        }
        public Integer compareTo(Object ObjToCompare) {
            return Integer.valueOf(((NotesWrapper )objToCompare).lastModifiedDate.getTime() - lastModifiedDate.getTime());
        }
    }
     public void updateNote() {
        try{
            if(Schema.sObjectType.Note.isUpdateable()){         
                update editAttachmentWrapper.note;
            }
            }

                            
         catch(DMLException e) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, e.getMessage());
            ApexPages.addMessage(myMsg);
        }        
    } 

    
}