public with sharing class GetFolderHelper {
    
    public static ID getFolderId(){
       List<Document> documents = [SELECT Id, FolderId, Folder.Name FROM Document WHERE Folder.Name = 'FINET' LIMIT 1];
       Id folderId = documents[0].FolderId;
       return folderId;
    }
    
    
}